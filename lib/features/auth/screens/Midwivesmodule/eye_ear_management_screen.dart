import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/eye_ear_record_service.dart';
import '../../../../services/baby_service.dart';

class BabyProblemsScreen extends StatefulWidget {
  final String? motherName;
  final String? motherNic;

  const BabyProblemsScreen({super.key, this.motherName, this.motherNic});

  @override
  _BabyProblemsScreenState createState() => _BabyProblemsScreenState();
}

class _BabyProblemsScreenState extends State<BabyProblemsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _diagnosisDateController =
      TextEditingController();
  final TextEditingController _nicController = TextEditingController();

  List<Map<String, dynamic>> problemRecords = [];
  List<Map<String, dynamic>> _babies = [];
  Map<String, dynamic>? _selectedBaby;
  String? _motherName;
  String? selectedEyeProblem;
  String? selectedEarProblem;
  String? selectedDuration;
  bool showHistory = false;
  bool isLoading = false;
  bool isSaving = false;

  late TabController _tabController;

  final List<String> eyeProblems = [
    'None',
    'Blocked Tear Duct',
    'Conjunctivitis (Pink Eye)',
    'Stye',
    'Eye Discharge',
    'Redness/Irritation',
    'Excessive Tearing',
    'Other',
  ];

  final List<String> earProblems = [
    'None',
    'Ear Infection',
    'Earwax Buildup',
    'Ear Discharge',
    'Hearing Concerns',
    'Ear Pain/Fussiness',
    'Other',
  ];

  final List<String> durationOptions = [
    'Less than 1 day',
    '1-3 days',
    '3-7 days',
    '1-2 weeks',
    '2-4 weeks',
    'More than 1 month',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    selectedEyeProblem = eyeProblems.first;
    selectedEarProblem = earProblems.first;
    selectedDuration = durationOptions.first;
    _diagnosisDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    // Initialize with mother data if provided
    if (widget.motherNic != null) {
      _nicController.text = widget.motherNic!;
      _motherName = widget.motherName;
      _searchBabies();
    }

    _loadExistingRecords();
  }

  Future<void> _loadExistingRecords() async {
    if (widget.motherNic == null) return;

    setState(() => isLoading = true);
    try {
      final records = await EyeEarRecordService.getRecordsByMotherNic(
        widget.motherNic!,
      );
      setState(() {
        problemRecords = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load existing records: $e');
    }
  }

  Future<void> _searchBabies() async {
    if (_nicController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter mother\'s NIC number');
      return;
    }

    setState(() => isLoading = true);
    try {
      final babies = await BabyService.getBabiesByMotherNic(
        _nicController.text.trim(),
      );

      setState(() {
        _babies = babies;
        _selectedBaby = null;
        isLoading = false;
      });

      if (babies.isNotEmpty) {
        // Get mother name from the first baby
        _motherName = babies.first['motherName'] ?? babies.first['fullName'];
        _showSuccessSnackBar(
          'Found ${babies.length} baby(ies) for this mother',
        );
      } else {
        _showErrorSnackBar('No babies found for this mother');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Error searching babies: $e');
    }
  }

  void _selectBaby(Map<String, dynamic> baby) {
    setState(() {
      _selectedBaby = baby;
      _patientNameController.text =
          baby['name'] ??
          baby['babyName'] ??
          baby['fullName'] ??
          'Baby ${baby['babyOrder'] ?? '1'}';
    });
    _loadRecordsForBaby(baby);
  }

  Future<void> _loadRecordsForBaby(Map<String, dynamic> baby) async {
    setState(() => isLoading = true);
    try {
      final records = await EyeEarRecordService.getRecordsByBabyId(baby['id']);
      setState(() {
        problemRecords = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load records for ${baby['name']}: $e');
    }
  }

  Future<void> _saveRecord() async {
    if (!_validateForm()) return;

    setState(() => isSaving = true);
    try {
      await EyeEarRecordService.createRecord(
        patientName: _patientNameController.text.trim(),
        babyId: _selectedBaby?['id'] ?? 0,
        motherNic: _nicController.text.trim(),
        eyeProblem: selectedEyeProblem ?? 'None',
        earProblem: selectedEarProblem ?? 'None',
        symptomsDuration: selectedDuration ?? '',
        remarks: _remarksController.text.trim(),
        dateOfDiagnosis: _diagnosisDateController.text,
      );

      setState(() => isSaving = false);
      _showSuccessSnackBar('Record saved successfully!');
      _clearForm();
      if (_selectedBaby != null) {
        _loadRecordsForBaby(_selectedBaby!); // Refresh the list
      }
    } catch (e) {
      setState(() => isSaving = false);
      _showErrorSnackBar('Failed to save record: $e');
    }
  }

  bool _validateForm() {
    if (_selectedBaby == null) {
      _showErrorSnackBar('Please select a baby first');
      return false;
    }
    if (_patientNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter patient name');
      return false;
    }
    if (selectedEyeProblem == 'None' && selectedEarProblem == 'None') {
      _showErrorSnackBar('Please select at least one eye or ear problem');
      return false;
    }
    if (_diagnosisDateController.text.trim().isEmpty) {
      _showErrorSnackBar('Please select diagnosis date');
      return false;
    }
    return true;
  }

  void _clearForm() {
    _patientNameController.clear();
    _remarksController.clear();
    setState(() {
      selectedEyeProblem = eyeProblems.first;
      selectedEarProblem = earProblems.first;
      selectedDuration = durationOptions.first;
    });
    _diagnosisDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B73FF), Color(0xFF8B5CF6), Color(0xFFA855F7)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(),
          body: _buildRecordManagement(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                showHistory = !showHistory;
              });
            },
            backgroundColor: const Color(0xFF6B73FF),
            icon: Icon(showHistory ? Icons.add : Icons.history),
            label: Text(showHistory ? 'Add Record' : 'View History'),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordManagement() {
    return Column(
      children: [
        if (!showHistory) ...[
          Expanded(child: _buildFormView()),
        ] else ...[
          Expanded(child: _buildHistoryView()),
        ],
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.remove_red_eye,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Eye & Ear Problems',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ],
      ),
      actions: [
        if (!showHistory)
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Form',
          ),
      ],
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMotherInfoCard(),
          const SizedBox(height: 16),
          _buildFormCard(),
        ],
      ),
    );
  }

  Widget _buildMotherInfoCard() {
    if (widget.motherName == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF9966CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mother Information',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.motherName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIC: ${widget.motherNic ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Eye & Ear Record',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B73FF),
            ),
          ),
          const SizedBox(height: 24),

          // Mother NIC Search
          _buildNicSearchSection(),
          const SizedBox(height: 20),

          // Baby Selection
          if (_babies.isNotEmpty) ...[
            _buildBabySelectionSection(),
            const SizedBox(height: 20),
          ],

          // Patient Name (readonly when baby is selected)
          _buildTextField(
            controller: _patientNameController,
            label: 'Patient (Baby) Name',
            icon: Icons.child_care,
            required: true,
            readOnly: _selectedBaby != null,
          ),
          const SizedBox(height: 20),

          // Eye Problems
          _buildEyeProblemsSection(),
          const SizedBox(height: 20),

          // Ear Problems
          _buildEarProblemsSection(),
          const SizedBox(height: 20),

          // Duration
          _buildDurationSection(),
          const SizedBox(height: 20),

          // Date
          _buildDateField(),
          const SizedBox(height: 20),

          // Remarks
          _buildTextField(
            controller: _remarksController,
            label: 'Remarks (Optional)',
            icon: Icons.note,
            maxLines: 3,
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B73FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Record',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B73FF)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: readOnly
                ? 'Selected from baby information'
                : 'Enter $label',
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B73FF)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildEyeProblemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.visibility, size: 20, color: Color(0xFF6B73FF)),
            const SizedBox(width: 8),
            const Text(
              'Eye Problems',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedEyeProblem,
            decoration: const InputDecoration(
              hintText: 'Select eye problem',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: eyeProblems.map((String problem) {
              return DropdownMenuItem<String>(
                value: problem,
                child: Text(problem),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedEyeProblem = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEarProblemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hearing, size: 20, color: Color(0xFF43A047)),
            const SizedBox(width: 8),
            const Text(
              'Ear Problems',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedEarProblem,
            decoration: const InputDecoration(
              hintText: 'Select ear problem',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: earProblems.map((String problem) {
              return DropdownMenuItem<String>(
                value: problem,
                child: Text(problem),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedEarProblem = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            const Text(
              'Symptoms Duration',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedDuration,
            decoration: const InputDecoration(
              hintText: 'Select duration',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: durationOptions.map((String duration) {
              return DropdownMenuItem<String>(
                value: duration,
                child: Text(duration),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDuration = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: Color(0xFF9C27B0),
            ),
            const SizedBox(width: 8),
            const Text(
              'Date of Diagnosis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _diagnosisDateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select date',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B73FF)),
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              _diagnosisDateController.text = DateFormat(
                'yyyy-MM-dd',
              ).format(date);
            }
          },
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6B73FF)),
            SizedBox(height: 16),
            Text('Loading records...'),
          ],
        ),
      );
    }

    if (problemRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No records found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add the first eye and ear record',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: problemRecords.length,
      itemBuilder: (context, index) {
        return _buildRecordCard(problemRecords[index]);
      },
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['patientName'] ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record['dateOfDiagnosis'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B73FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record['symptomsDuration'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF6B73FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (record['eyeProblem'] != null &&
              record['eyeProblem'] != 'None') ...[
            Row(
              children: [
                const Icon(
                  Icons.visibility,
                  size: 16,
                  color: Color(0xFF6B73FF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Eye: ${record['eyeProblem']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (record['earProblem'] != null &&
              record['earProblem'] != 'None') ...[
            Row(
              children: [
                const Icon(Icons.hearing, size: 16, color: Color(0xFF43A047)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ear: ${record['earProblem']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (record['remarks'] != null &&
              record['remarks'].toString().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record['remarks'],
                      style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patientNameController.dispose();
    _remarksController.dispose();
    _diagnosisDateController.dispose();
    _nicController.dispose();
    super.dispose();
  }

  Widget _buildNicSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_motherName != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6B73FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6B73FF).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF6B73FF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mother: $_motherName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.motherNic != null)
                        Text(
                          'NIC: ${widget.motherNic}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBabySelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.child_care, size: 20, color: Color(0xFF43A047)),
            const SizedBox(width: 8),
            const Text(
              'Select Baby',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF6B73FF), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _babies.map((baby) {
              final isSelected = _selectedBaby?['id'] == baby['id'];
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6B73FF).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF6B73FF),
                    child: Text(
                      baby['babyOrder']?.toString() ?? '1',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    baby['name'] ??
                        baby['babyName'] ??
                        baby['fullName'] ??
                        'Baby ${baby['babyOrder'] ?? '1'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Age: ${baby['ageInMonths'] ?? 0} months | Born: ${baby['dateOfBirth'] ?? baby['birthDate'] ?? 'Unknown'}',
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF6B73FF))
                      : const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF6B73FF),
                        ),
                  onTap: () => _selectBaby(baby),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
