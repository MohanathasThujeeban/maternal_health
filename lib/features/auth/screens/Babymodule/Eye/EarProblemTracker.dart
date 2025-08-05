import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Eye/Ear Problems',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Color(0xFF00D4D4),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: BabyProblemsScreen(),
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

  // Common eye problems for babies under 5
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

  // Common ear problems for babies under 5
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
    _initializeSampleData();
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
        createdAt: DateTime.now().subtract(Duration(days: 6)),
      ),
      ProblemRecord(
        id: 2,
        patientName: 'Baby Silva',
        eyeProblem: 'None',
        earProblem: 'Ear Infection',
        symptomsDuration: '3-7 days',
        remarks: 'Fussy, pulling at ear. Prescribed antibiotic drops.',
        dateOfDiagnosis: '2024-07-12',
        createdAt: DateTime.now().subtract(Duration(days: 4)),
      ),
    ];
  }

  void _saveRecord() {
    if (_patientNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter patient name')));
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
    ).showSnackBar(SnackBar(content: Text('Record saved successfully')));
  }

  void _clearForm() {
    _patientNameController.clear();
    _remarksController.clear();
    _diagnosisDateController.text = DateTime.now().toString().split(' ')[0];
    selectedEyeProblem = null;
    selectedEarProblem = null;
    selectedDuration = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baby Eye/Ear Problems'),
        backgroundColor: Color(0xFF00D4D4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Name
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  controller: _patientNameController,
                  decoration: InputDecoration(
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

            SizedBox(height: 16),

            // Eye and Ear Problems
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Problems',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4D4),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Eye Problem
                    DropdownButtonFormField<String>(
                      value: selectedEyeProblem,
                      decoration: InputDecoration(
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

                    SizedBox(height: 16),

                    // Ear Problem
                    DropdownButtonFormField<String>(
                      value: selectedEarProblem,
                      decoration: InputDecoration(
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

            SizedBox(height: 16),

            // Duration and Date
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDuration,
                      decoration: InputDecoration(
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

                    SizedBox(height: 16),

                    TextFormField(
                      controller: _diagnosisDateController,
                      decoration: InputDecoration(
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

            SizedBox(height: 16),

            // Remarks
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    labelText: 'Doctor\'s Notes / Remarks',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note, color: Color(0xFF00D4D4)),
                  ),
                  maxLines: 3,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveRecord,
                    icon: Icon(Icons.save),
                    label: Text('Save Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00D4D4),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        showHistory = !showHistory;
                      });
                    },
                    icon: Icon(Icons.history),
                    label: Text(showHistory ? 'Hide History' : 'View History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF00D4D4),
                      side: BorderSide(color: Color(0xFF00D4D4)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // History Section
            if (showHistory) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      SizedBox(height: 16),
                      ...problemRecords
                          .map((record) => _buildHistoryItem(record))
                          .toList(),
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
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF00D4D4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                record.patientName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              Text(
                record.dateOfDiagnosis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (record.eyeProblem != 'None')
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Color(0xFF00D4D4)),
                SizedBox(width: 4),
                Text(record.eyeProblem, style: TextStyle(fontSize: 14)),
              ],
            ),
          if (record.earProblem != 'None')
            Row(
              children: [
                Icon(Icons.hearing, size: 16, color: Color(0xFF00D4D4)),
                SizedBox(width: 4),
                Text(record.earProblem, style: TextStyle(fontSize: 14)),
              ],
            ),
          if (record.remarks.isNotEmpty) ...[
            SizedBox(height: 4),
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
