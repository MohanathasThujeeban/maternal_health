import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Eye/Ear Problems',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF6B73FF),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const BabyProblemsScreen(),
    );
  }
}

class ProblemRecord {
  final int id;
  String patientName;
  String eyeProblem;
  String earProblem;
  String symptomsDuration;
  String remarks;
  String dateOfDiagnosis;
  DateTime createdAt;

  ProblemRecord({
    required this.id,
    required this.patientName,
    required this.eyeProblem,
    required this.earProblem,
    required this.symptomsDuration,
    required this.remarks,
    required this.dateOfDiagnosis,
    required this.createdAt,
  });
}

class BabyProblemsScreen extends StatefulWidget {
  final String? motherName;
  final String? motherNic;

  const BabyProblemsScreen({super.key, this.motherName, this.motherNic});

  @override
  _BabyProblemsScreenState createState() => _BabyProblemsScreenState();
}

class _BabyProblemsScreenState extends State<BabyProblemsScreen> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _diagnosisDateController =
      TextEditingController();

  List<ProblemRecord> problemRecords = [];
  String? selectedEyeProblem;
  String? selectedEarProblem;
  String? selectedDuration;
  bool showHistory = false;

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
    _diagnosisDateController.text = DateTime.now().toString().split(' ')[0];
    selectedEyeProblem = 'None';
    selectedEarProblem = 'None';
    selectedDuration = 'Less than 1 day';
    _initializeSampleData();
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _remarksController.dispose();
    _diagnosisDateController.dispose();
    super.dispose();
  }

  void _initializeSampleData() {
    problemRecords = [
      ProblemRecord(
        id: 1,
        patientName: 'Baby Perera',
        eyeProblem: 'Blocked Tear Duct',
        earProblem: 'None',
        symptomsDuration: '1-2 weeks',
        remarks: 'Excessive tearing in left eye. Gentle massage recommended.',
        dateOfDiagnosis: '2024-07-10',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      ProblemRecord(
        id: 2,
        patientName: 'Baby Silva',
        eyeProblem: 'None',
        earProblem: 'Ear Infection',
        symptomsDuration: '3-7 days',
        remarks: 'Fussy, pulling at ear. Prescribed antibiotic drops.',
        dateOfDiagnosis: '2024-07-12',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  void _saveRecord() {
    if (_patientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter baby name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newRecord = ProblemRecord(
      id: problemRecords.length + 1,
      patientName: _patientNameController.text,
      eyeProblem: selectedEyeProblem ?? 'None',
      earProblem: selectedEarProblem ?? 'None',
      symptomsDuration: selectedDuration ?? 'Less than 1 day',
      remarks: _remarksController.text,
      dateOfDiagnosis: _diagnosisDateController.text,
      createdAt: DateTime.now(),
    );

    setState(() {
      problemRecords.add(newRecord);
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Record saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearForm() {
    _patientNameController.clear();
    _remarksController.clear();
    _diagnosisDateController.text = DateTime.now().toString().split(' ')[0];
    setState(() {
      selectedEyeProblem = 'None';
      selectedEarProblem = 'None';
      selectedDuration = 'Less than 1 day';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMotherInfoCard(),
            _buildFormCard(),
            if (showHistory) _buildHistoryCard(),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            showHistory = !showHistory;
          });
        },
        backgroundColor: const Color(0xFF6B73FF),
        icon: Icon(showHistory ? Icons.visibility_off : Icons.history),
        label: Text(showHistory ? 'Hide History' : 'View History'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF6B73FF),
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
        IconButton(
          onPressed: _clearForm,
          icon: const Icon(Icons.refresh),
          tooltip: 'Clear Form',
        ),
      ],
    );
  }

  Widget _buildMotherInfoCard() {
    if (widget.motherName == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  'NIC: ${widget.motherNic}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Baby Health Assessment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildBabyNameField(),
            const SizedBox(height: 20),
            _buildEyeProblemsSection(),
            const SizedBox(height: 20),
            _buildEarProblemsSection(),
            const SizedBox(height: 20),
            _buildDurationSection(),
            const SizedBox(height: 20),
            _buildRemarksField(),
            const SizedBox(height: 20),
            _buildDateField(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Baby Name *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _patientNameController,
            decoration: InputDecoration(
              hintText: 'Enter baby\'s name',
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.child_care,
                  color: Color(0xFF6B73FF),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6B73FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.visibility,
                color: Color(0xFF6B73FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Eye Problems',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.hearing,
                color: Color(0xFF43A047),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ear Problems',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.access_time,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Symptoms Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Remarks / Additional Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _remarksController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter any additional notes or observations...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Diagnosis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _diagnosisDateController,
            decoration: InputDecoration(
              hintText: 'Select date',
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF6B73FF),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _diagnosisDateController.text = pickedDate.toString().split(
                    ' ',
                  )[0];
                });
              }
            },
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B73FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _saveRecord,
              icon: const Icon(Icons.save, size: 20),
              label: const Text('Save Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B73FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearForm,
            icon: const Icon(Icons.clear, size: 20),
            label: const Text('Clear Form'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B73FF),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF6B73FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF6B73FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${problemRecords.length} records',
                    style: const TextStyle(
                      color: Color(0xFF6B73FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (problemRecords.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No records found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              ...problemRecords.map((record) => _buildHistoryItem(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ProblemRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    record.patientName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      record.dateOfDiagnosis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (record.eyeProblem != 'None') ...[
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
                    'Eye: ${record.eyeProblem}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (record.earProblem != 'None') ...[
            Row(
              children: [
                const Icon(Icons.hearing, size: 16, color: Color(0xFF43A047)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ear: ${record.earProblem}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Duration: ${record.symptomsDuration}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (record.remarks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Text(
                record.remarks,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
