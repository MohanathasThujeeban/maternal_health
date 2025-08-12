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
        primarySwatch: Colors.cyan,
        primaryColor: const Color(0xFF00D4D4),
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
  const BabyProblemsScreen({super.key});

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
        const SnackBar(content: Text('Please enter patient name')),
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Record saved successfully')));
  }

  void _clearForm() {
    _patientNameController.clear();
    _remarksController.clear();
    _diagnosisDateController.text = DateTime.now().toString().split(' ')[0];
    selectedEyeProblem = 'None';
    selectedEarProblem = 'None';
    selectedDuration = 'Less than 1 day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Eye/Ear Problems'),
        backgroundColor: const Color(0xFF00D4D4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Name
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Baby Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.child_care,
                      color: Color(0xFF00D4D4),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Eye and Ear Problems
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Problems',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4D4),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Eye Problem
                    DropdownButtonFormField<String>(
                      value: selectedEyeProblem,
                      decoration: const InputDecoration(
                        labelText: 'Eye Problem',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.visibility,
                          color: Color(0xFF00D4D4),
                        ),
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

                    const SizedBox(height: 16),

                    // Ear Problem
                    DropdownButtonFormField<String>(
                      value: selectedEarProblem,
                      decoration: const InputDecoration(
                        labelText: 'Ear Problem',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.hearing,
                          color: Color(0xFF00D4D4),
                        ),
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Duration and Date
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDuration,
                      decoration: const InputDecoration(
                        labelText: 'Symptoms Duration',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.schedule,
                          color: Color(0xFF00D4D4),
                        ),
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

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _diagnosisDateController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Diagnosis',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _diagnosisDateController.text = pickedDate
                                .toString()
                                .split(' ')[0];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Remarks
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _remarksController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor\'s Notes / Remarks',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note, color: Color(0xFF00D4D4)),
                  ),
                  maxLines: 3,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveRecord,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        showHistory = !showHistory;
                      });
                    },
                    icon: const Icon(Icons.history),
                    label: Text(showHistory ? 'Hide History' : 'View History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00D4D4),
                      side: const BorderSide(color: Color(0xFF00D4D4)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // History Section
            if (showHistory) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...problemRecords.map(
                        (record) => _buildHistoryItem(record),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ProblemRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4D4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                record.patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                record.dateOfDiagnosis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (record.eyeProblem != 'None')
            Row(
              children: const [
                Icon(Icons.visibility, size: 16, color: Color(0xFF00D4D4)),
                SizedBox(width: 4),
                // Text will come from below
              ],
            ),
          if (record.eyeProblem != 'None')
            Text(record.eyeProblem, style: const TextStyle(fontSize: 14)),
          if (record.earProblem != 'None')
            Row(
              children: const [
                Icon(Icons.hearing, size: 16, color: Color(0xFF00D4D4)),
                SizedBox(width: 4),
                // Text will come from below
              ],
            ),
          if (record.earProblem != 'None')
            Text(record.earProblem, style: const TextStyle(fontSize: 14)),
          if (record.remarks.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              record.remarks,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
