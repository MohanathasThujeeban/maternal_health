import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../../config/api_config.dart';

class PregnantMotherDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> motherData;

  const PregnantMotherDetailsScreen({super.key, required this.motherData});

  @override
  State<PregnantMotherDetailsScreen> createState() =>
      _PregnantMotherDetailsScreenState();
}

class _PregnantMotherDetailsScreenState
    extends State<PregnantMotherDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _maternalProfile;
  List<Map<String, dynamic>> _weightRecords = [];
  List<Map<String, dynamic>> _vaccinationRecords = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAddingVaccination = false;
  String? _errorMessage;

  // Form controllers
  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _currentHeightController =
      TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _midwifeNotesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _vaccinationsController = TextEditingController();
  final TextEditingController _generalNotesController = TextEditingController();
  final TextEditingController _nutritionalSupplementsController =
      TextEditingController();

  // Vaccination form controllers
  final TextEditingController _vaccinationTypeController =
      TextEditingController();
  final TextEditingController _vaccinationChildNameController =
      TextEditingController();
  final TextEditingController _vaccinationAgeToGiveController =
      TextEditingController();
  final TextEditingController _vaccinationBatchController =
      TextEditingController();
  final TextEditingController _vaccinationEffectsController =
      TextEditingController();
  DateTime? _vaccinationDate;

  DateTime? _selectedEDD;
  int? _pregnancyWeek;
  String? _pregnancyStatus;

  final List<String> _pregnancyStatusOptions = [
    'PREGNANT',
    'ACTIVE',
    'HIGH_RISK',
    'NORMAL',
    'COMPLETED',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMaternalProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentWeightController.dispose();
    _currentHeightController.dispose();
    _bloodPressureController.dispose();
    _midwifeNotesController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _vaccinationsController.dispose();
    _generalNotesController.dispose();
    _nutritionalSupplementsController.dispose();
    _vaccinationTypeController.dispose();
    _vaccinationChildNameController.dispose();
    _vaccinationAgeToGiveController.dispose();
    _vaccinationBatchController.dispose();
    _vaccinationEffectsController.dispose();
    super.dispose();
  }

  Future<void> _loadMaternalProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/maternal-profile/${widget.motherData['nicNumber']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _maternalProfile = data['profile'];
            _populateFormFields();
            _isLoading = false;
          });
          // Load weight records after profile is loaded
          await _loadWeightRecords();
          // Load vaccinations
          await _loadVaccinations();
        } else {
          throw Exception(data['message'] ?? 'Failed to load maternal profile');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeightRecords() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/pregnancy-weight-records/mother/${widget.motherData['nicNumber']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _weightRecords = data.cast<Map<String, dynamic>>();
        });
      } else if (response.statusCode != 404) {
        // Ignore 404 as it means no records exist yet
        print('Failed to load weight records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading weight records: $e');
    }
  }

  Future<void> _loadVaccinations() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/vaccinations/mother/${widget.motherData['nicNumber']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _vaccinationRecords = data.cast<Map<String, dynamic>>();
        });
      } else if (response.statusCode != 404) {
        // Ignore 404 as it means no vaccinations yet
        print('Failed to load vaccinations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading vaccinations: $e');
    }
  }

  void _populateFormFields() {
    if (_maternalProfile == null) return;

    final profile = _maternalProfile!;

    // Don't pre-populate current weight/height fields - these should be fresh measurements
    // _currentWeightController.text = ''; // Leave empty for new measurements
    // _currentHeightController.text = ''; // Leave empty for new measurements

    _midwifeNotesController.text = profile['midwifeNotes'] ?? '';
    _medicationsController.text = profile['currentMedications'] ?? '';
    _allergiesController.text = profile['allergies'] ?? '';
    // Vaccinations are managed via dedicated endpoints; not part of profile payload
    _generalNotesController.text = profile['generalNotes'] ?? '';
    _nutritionalSupplementsController.text =
        profile['nutritionalSupplements'] ?? '';

    if (profile['expectedDeliveryDate'] != null) {
      _selectedEDD = DateTime.parse(profile['expectedDeliveryDate']);
    }

    _pregnancyWeek = profile['currentPregnancyWeek'];
    _pregnancyStatus = profile['currentPregnancyStatus'] ?? 'PREGNANT';
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Update maternal profile with basic info
      final profileUpdateBody = {
        'midwifeNotes': _midwifeNotesController.text.trim(),
        'currentMedications': _medicationsController.text.trim(),
        'allergies': _allergiesController.text.trim(),
        // vaccinations are not part of profile DTO; handled separately
        'generalNotes': _generalNotesController.text.trim(),
        'nutritionalSupplements': _nutritionalSupplementsController.text.trim(),
        'expectedDeliveryDate': _selectedEDD?.toIso8601String().split('T')[0],
        'currentPregnancyWeek': _pregnancyWeek,
        'currentPregnancyStatus': _pregnancyStatus,
      };

      final profileResponse = await http.post(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/maternal-profile/${widget.motherData['nicNumber']}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profileUpdateBody),
      );

      // Save current weight record if weight or height is provided
      if (_currentWeightController.text.isNotEmpty ||
          _currentHeightController.text.isNotEmpty) {
        final weightRecordBody = {
          'motherNic': widget.motherData['nicNumber'],
          'currentWeight': _currentWeightController.text.isNotEmpty
              ? double.tryParse(_currentWeightController.text)
              : null,
          'currentHeight': _currentHeightController.text.isNotEmpty
              ? double.tryParse(_currentHeightController.text)
              : null,
          'bloodPressure': _bloodPressureController.text.trim(),
          'pregnancyWeek': _pregnancyWeek,
          'measurementDate': DateTime.now().toIso8601String().split('T')[0],
          'midwifeNotes': _midwifeNotesController.text.trim(),
          'recordedBy': 'MW001', // Should be replaced with current midwife ID
        };

        final weightResponse = await http.post(
          Uri.parse('${ApiConfig.baseApiUrl}/pregnancy-weight-records'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(weightRecordBody),
        );

        if (weightResponse.statusCode != 201) {
          print(
            'Warning: Failed to save weight record - ${weightResponse.statusCode}',
          );
        }
      }

      if (profileResponse.statusCode == 200) {
        final data = json.decode(profileResponse.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Maternal profile and weight record updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          await _loadMaternalProfile(); // Refresh data
          await _loadWeightRecords(); // Refresh weight records
          await _loadVaccinations(); // Refresh vaccinations
        } else {
          throw Exception(data['message'] ?? 'Failed to save changes');
        }
      } else {
        throw Exception('Server error: ${profileResponse.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _addVaccination() async {
    if (_vaccinationTypeController.text.trim().isEmpty ||
        _vaccinationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaccination type and date are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isAddingVaccination = true);
    try {
      final body = {
        'motherNic': widget.motherData['nicNumber'],
        'childName': _vaccinationChildNameController.text.trim().isEmpty
            ? 'Mother'
            : _vaccinationChildNameController.text.trim(),
        'vaccinationType': _vaccinationTypeController.text.trim(),
        'ageToGive': _vaccinationAgeToGiveController.text.trim().isEmpty
            ? null
            : _vaccinationAgeToGiveController.text.trim(),
        'vaccinationDate': _vaccinationDate!.toIso8601String().split('T')[0],
        'batchNumber': _vaccinationBatchController.text.trim().isEmpty
            ? null
            : _vaccinationBatchController.text.trim(),
        'effectsFollowingImmunization':
            _vaccinationEffectsController.text.trim().isEmpty
            ? null
            : _vaccinationEffectsController.text.trim(),
      };

      final resp = await http.post(
        Uri.parse('${ApiConfig.baseApiUrl}/vaccinations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (resp.statusCode == 201) {
        // Attempt to mark the created vaccination as COMPLETED right away
        try {
          final Map<String, dynamic> created = json.decode(resp.body);
          final id = created['id'];
          if (id != null) {
            final patchResp = await http.patch(
              Uri.parse(
                '${ApiConfig.baseApiUrl}/vaccinations/$id/status?status=COMPLETED',
              ),
              headers: {'Content-Type': 'application/json'},
            );
            if (patchResp.statusCode != 200) {
              // Not critical; continue with UI update
              // ignore: avoid_print
              print(
                'Warning: Failed to mark vaccination as COMPLETED (${patchResp.statusCode})',
              );
            }
          }
        } catch (e) {
          // ignore: avoid_print
          print('Non-fatal: could not set vaccination status to COMPLETED: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _vaccinationTypeController.clear();
        _vaccinationChildNameController.clear();
        _vaccinationAgeToGiveController.clear();
        _vaccinationBatchController.clear();
        _vaccinationEffectsController.clear();
        setState(() => _vaccinationDate = null);
        await _loadVaccinations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add vaccination (${resp.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding vaccination: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isAddingVaccination = false);
    }
  }

  Widget _buildProfileTab() {
    // Show ONLY the data that midwives can update. Remove static/uneditable info.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_maternalProfile != null) ...[
            _buildSectionCard('Pregnancy Information', Icons.pregnant_woman, [
              _buildInfoRow(
                'Current Pregnancy Week',
                _maternalProfile!['currentPregnancyWeek']?.toString() ??
                    'Not set',
              ),
              _buildInfoRow(
                'Pregnancy Status',
                _maternalProfile!['currentPregnancyStatus'] ?? 'Not set',
              ),
              _buildInfoRow(
                'Expected Delivery Date',
                _formatDate(_maternalProfile!['expectedDeliveryDate']),
              ),
              _buildInfoRow(
                'Vaccinations',
                _vaccinationRecords.isNotEmpty
                    ? '${_vaccinationRecords.first['vaccinationType'] ?? 'Unknown'} on '
                          '${_formatDate(_vaccinationRecords.first['vaccinationDate'])}'
                    : 'Not recorded',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Medical Information (Updatable)',
              Icons.medical_services,
              [
                _buildInfoRow(
                  'Current Medications',
                  _maternalProfile!['currentMedications'] ?? 'Not recorded',
                ),
                _buildInfoRow(
                  'Allergies',
                  _maternalProfile!['allergies'] ?? 'Not recorded',
                ),
                _buildInfoRow(
                  'Nutritional Supplements',
                  _maternalProfile!['nutritionalSupplements'] ?? 'Not recorded',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard('Notes', Icons.note, [
              _buildInfoRow(
                'General Notes',
                _maternalProfile!['generalNotes'] ?? 'None',
              ),
              _buildInfoRow(
                'Midwife Notes',
                _maternalProfile!['midwifeNotes'] ?? 'None',
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildUpdateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Pregnancy Tracking'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDateField(
                    'Expected Delivery Date',
                    _selectedEDD,
                    (date) => setState(() => _selectedEDD = date),
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Current Pregnancy Week',
                    _pregnancyWeek?.toString() ?? '',
                    (value) =>
                        setState(() => _pregnancyWeek = int.tryParse(value)),
                  ),
                  const SizedBox(height: 16),
                  // Friendlier chip selector instead of dropdown
                  _buildChipSelector(
                    label: 'Pregnancy Status',
                    options: _pregnancyStatusOptions,
                    value: _pregnancyStatus ?? _pregnancyStatusOptions.first,
                    onSelected: (val) => setState(() => _pregnancyStatus = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Physical Measurements'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    'Current Weight (kg)',
                    _currentWeightController,
                    TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Current Height (cm)',
                    _currentHeightController,
                    TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Blood Pressure (e.g., 120/80)',
                    _bloodPressureController,
                    TextInputType.text,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Medical Information'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    'Current Medications',
                    _medicationsController,
                    TextInputType.multiline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Allergies',
                    _allergiesController,
                    TextInputType.multiline,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // Vaccinations handled below with dedicated form
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Nutritional Supplements',
                    _nutritionalSupplementsController,
                    TextInputType.multiline,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Add Vaccination'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    'Vaccination Type',
                    _vaccinationTypeController,
                    TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                  _buildQuickTypeChips(
                    ['TT1', 'TT2', 'Influenza', 'COVID-19 Booster', 'HepB'],
                    onPick: (v) =>
                        setState(() => _vaccinationTypeController.text = v),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    'Vaccination Date',
                    _vaccinationDate,
                    (date) => setState(() => _vaccinationDate = date),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Child Name (optional)',
                    _vaccinationChildNameController,
                    TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Age To Give (optional)',
                    _vaccinationAgeToGiveController,
                    TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Batch Number (optional)',
                    _vaccinationBatchController,
                    TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Effects Following Immunization (optional)',
                    _vaccinationEffectsController,
                    TextInputType.multiline,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAddingVaccination ? null : _addVaccination,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3A1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAddingVaccination
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add Vaccination',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Recent vaccinations
          if (_vaccinationRecords.isNotEmpty) ...[
            _buildSectionHeader('Recent Vaccinations'),
            Card(
              child: Column(
                children: _vaccinationRecords
                    .take(5)
                    .map(
                      (v) => ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF4FC3A1),
                          child: Icon(Icons.vaccines, color: Colors.white),
                        ),
                        title: Text(
                          v['vaccinationType'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Date: ${_formatDate(v['vaccinationDate'])} • Status: ${v['status'] ?? 'PENDING'}',
                          style: const TextStyle(fontFamily: 'SpotifyCircular'),
                        ),
                        trailing: Icon(
                          (v['status'] ?? '').toString().toUpperCase() ==
                                  'COMPLETED'
                              ? Icons.check_circle
                              : Icons.schedule,
                          color:
                              (v['status'] ?? '').toString().toUpperCase() ==
                                  'COMPLETED'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Additional Notes
          _buildSectionHeader('Additional Notes'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    'General Notes',
                    _generalNotesController,
                    TextInputType.multiline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Midwife Notes and Observations',
                    _midwifeNotesController,
                    TextInputType.multiline,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Records Section
          _buildSectionHeader('Current Pregnancy Weight Records'),
          if (_weightRecords.isNotEmpty) ...[
            Card(
              child: Column(
                children: _weightRecords.map((record) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF4FC3A1),
                      child: Icon(Icons.monitor_weight, color: Colors.white),
                    ),
                    title: Text(
                      'Week ${record['pregnancyWeek'] ?? 'N/A'} - ${record['currentWeight'] ?? 'N/A'} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record['measurementDate'] != null)
                          Text(
                            'Date: ${_formatDate(record['measurementDate'])}',
                          ),
                        if (record['bloodPressure'] != null)
                          Text('BP: ${record['bloodPressure']}'),
                        if (record['bmiCalculated'] != null)
                          Text('BMI: ${record['bmiCalculated']}'),
                        if (record['weightGainFromPrevious'] != null)
                          Text(
                            'Weight Change: ${record['weightGainFromPrevious'] > 0 ? '+' : ''}${record['weightGainFromPrevious']} kg',
                            style: TextStyle(
                              color: record['weightGainFromPrevious'] > 0
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    trailing: record['isHighRiskIndicator'] == true
                        ? const Icon(Icons.warning, color: Colors.red)
                        : const Icon(Icons.check_circle, color: Colors.green),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No weight records found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weight records will appear here after updates',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Medical History Section
          _buildSectionHeader('Medical History'),
          if (_maternalProfile != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHistoryItem(
                      'Previous Pregnancies',
                      _maternalProfile!['numberOfPregnancies']?.toString() ??
                          '0',
                    ),
                    _buildHistoryItem(
                      'Live Births',
                      _maternalProfile!['numberOfLiveBirths']?.toString() ??
                          '0',
                    ),
                    _buildHistoryItem(
                      'Stillbirths',
                      _maternalProfile!['numberOfStillbirths']?.toString() ??
                          '0',
                    ),
                    _buildHistoryItem(
                      'Abortions',
                      _maternalProfile!['numberOfAbortions']?.toString() ?? '0',
                    ),
                    _buildHistoryItem(
                      'Living Children',
                      _maternalProfile!['numberOfLivingChildren']?.toString() ??
                          '0',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_maternalProfile!['previousPregnancyComplications'] !=
                null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Previous Pregnancy Complications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _maternalProfile!['previousPregnancyComplications'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_maternalProfile!['familyMedicalHistory'] != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Family Medical History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _maternalProfile!['familyMedicalHistory'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4FC3A1)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D5A),
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E7D5A),
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D5A),
          fontFamily: 'SpotifyCircular',
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'SpotifyCircular'),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4FC3A1)),
        ),
      ),
      style: const TextStyle(fontFamily: 'SpotifyCircular'),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'SpotifyCircular'),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(selectedDate)
              : 'Select date',
          style: const TextStyle(fontFamily: 'SpotifyCircular'),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return TextFormField(
      initialValue: value,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'SpotifyCircular'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4FC3A1)),
        ),
      ),
      style: const TextStyle(fontFamily: 'SpotifyCircular'),
    );
  }

  // Chip selector for compact, touch-friendly status choice
  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required String value,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final selected = value == opt;
            return ChoiceChip(
              label: Text(
                opt,
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  color: selected ? Colors.white : const Color(0xFF2E7D5A),
                ),
              ),
              selected: selected,
              selectedColor: const Color(0xFF4FC3A1),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF4FC3A1)),
              onSelected: (_) => onSelected(opt),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Quick-pick chips for common vaccination types
  Widget _buildQuickTypeChips(
    List<String> options, {
    required ValueChanged<String> onPick,
  }) {
    final current = _vaccinationTypeController.text;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = current == opt;
        return ChoiceChip(
          label: Text(
            opt,
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF2E7D5A),
            ),
          ),
          selected: isSelected,
          selectedColor: const Color(0xFF4FC3A1),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF4FC3A1)),
          onSelected: (_) => onPick(opt),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontFamily: 'SpotifyCircular'),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D5A),
              fontFamily: 'SpotifyCircular',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not set';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F7),
      appBar: AppBar(
        title: Text(
          widget.motherData['fullName'] ?? 'Pregnant Mother Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpotifyCircular',
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'SpotifyCircular'),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.edit), text: 'Update'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3A1)),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'SpotifyCircular',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMaternalProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildUpdateTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }
}
