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
  bool _isLoading = true;
  bool _isSaving = false;
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

  void _populateFormFields() {
    if (_maternalProfile == null) return;

    final profile = _maternalProfile!;

    // Don't pre-populate current weight/height fields - these should be fresh measurements
    // _currentWeightController.text = ''; // Leave empty for new measurements
    // _currentHeightController.text = ''; // Leave empty for new measurements

    _midwifeNotesController.text = profile['midwifeNotes'] ?? '';
    _medicationsController.text = profile['currentMedications'] ?? '';
    _allergiesController.text = profile['allergies'] ?? '';
    _vaccinationsController.text = profile['vaccinations'] ?? '';
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
        'vaccinations': _vaccinationsController.text.trim(),
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

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard('Mother Information', Icons.person, [
            _buildInfoRow(
              'Full Name',
              widget.motherData['fullName'] ?? 'Unknown',
            ),
            _buildInfoRow(
              'NIC Number',
              widget.motherData['nicNumber'] ?? 'Unknown',
            ),
            _buildInfoRow(
              'Email',
              widget.motherData['email'] ?? 'Not provided',
            ),
            _buildInfoRow(
              'Phone',
              widget.motherData['phoneNumber3'] ?? 'Not provided',
            ),
          ]),
          const SizedBox(height: 16),
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
                _maternalProfile!['vaccinations'] ?? 'Not recorded',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard('Physical Measurements', Icons.monitor_weight, [
              _buildInfoRow(
                'Pre-pregnancy Weight',
                _maternalProfile!['prePregnancyWeight'] != null
                    ? '${_maternalProfile!['prePregnancyWeight']} kg'
                    : 'Not recorded',
              ),
              _buildInfoRow(
                'Pre-pregnancy Height',
                _maternalProfile!['prePregnancyHeight'] != null
                    ? '${_maternalProfile!['prePregnancyHeight']} cm'
                    : 'Not recorded',
              ),
              _buildInfoRow(
                'BMI',
                _maternalProfile!['prePregnancyBmi'] != null
                    ? '${_maternalProfile!['prePregnancyBmi']}'
                    : 'Not calculated',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard('Medical Information', Icons.medical_services, [
              _buildInfoRow(
                'Blood Type',
                _maternalProfile!['bloodType'] ?? 'Not recorded',
              ),
              _buildInfoRow(
                'Rhesus Factor',
                _maternalProfile!['rhesusFactor'] ?? 'Not recorded',
              ),
              _buildInfoRow(
                'Allergies',
                _maternalProfile!['allergies'] ?? 'None recorded',
              ),
              _buildInfoRow(
                'High Risk Pregnancy',
                _maternalProfile!['isHighRiskPregnancy'] == true ? 'Yes' : 'No',
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
                  _buildDropdownField(
                    'Pregnancy Status',
                    _pregnancyStatus,
                    _pregnancyStatusOptions,
                    (value) => setState(() => _pregnancyStatus = value),
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
                  _buildTextField(
                    'Vaccinations Received',
                    _vaccinationsController,
                    TextInputType.multiline,
                    maxLines: 3,
                  ),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
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
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: const TextStyle(fontFamily: 'SpotifyCircular'),
          ),
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
