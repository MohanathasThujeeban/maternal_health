import 'package:flutter/material.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedProblemType = 'Eye Problem';
  String _selectedGender = 'Male';
  String _selectedSeverity = 'Mild';
  DateTime _selectedDate = DateTime.now();
  bool _isFollowUpRequired = false;

  final List<String> _problemTypes = [
    'Eye Problem',
    'Ear Problem',
    'Both Eye & Ear',
    'Other',
  ];

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _severityLevels = ['Mild', 'Moderate', 'Severe'];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveReport() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Confirm Report',
            style: TextStyle(color: Color(0xFF00D4D4)),
          ),
          content: Text('Are you sure you want to save this report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report saved successfully!'),
                    backgroundColor: Color(0xFF00D4D4),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00D4D4),
                foregroundColor: Colors.white,
              ),
              child: Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _patientNameController.clear();
      _ageController.clear();
      _diagnosisController.clear();
      _treatmentController.clear();
      _notesController.clear();
      _selectedProblemType = 'Eye Problem';
      _selectedGender = 'Male';
      _selectedSeverity = 'Mild';
      _selectedDate = DateTime.now();
      _isFollowUpRequired = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('📝 Add New Report'),
        backgroundColor: Color(0xFF00D4D4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: Icon(Icons.refresh),
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👤 Patient Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _patientNameController,
                        decoration: InputDecoration(
                          labelText: 'Patient Name *',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF00D4D4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF00D4D4)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              decoration: InputDecoration(
                                labelText: 'Age *',
                                prefixIcon: Icon(
                                  Icons.cake,
                                  color: Color(0xFF00D4D4),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF00D4D4),
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter age';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(
                                  Icons.wc,
                                  color: Color(0xFF00D4D4),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF00D4D4),
                                  ),
                                ),
                              ),
                              items: _genderOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Medical Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏥 Medical Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedProblemType,
                        decoration: InputDecoration(
                          labelText: 'Problem Type *',
                          prefixIcon: Icon(
                            Icons.medical_services,
                            color: Color(0xFF00D4D4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF00D4D4)),
                          ),
                        ),
                        items: _problemTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedProblemType = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSeverity,
                        decoration: InputDecoration(
                          labelText: 'Severity Level',
                          prefixIcon: Icon(
                            Icons.priority_high,
                            color: Color(0xFF00D4D4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF00D4D4)),
                          ),
                        ),
                        items: _severityLevels.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSeverity = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Color(0xFF00D4D4),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Date: ${_selectedDate.toString().split(' ')[0]}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Diagnosis & Treatment Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💊 Diagnosis & Treatment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: InputDecoration(
                          labelText: 'Diagnosis *',
                          prefixIcon: Icon(
                            Icons.local_hospital,
                            color: Color(0xFF00D4D4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF00D4D4)),
                          ),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter diagnosis';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _treatmentController,
                        decoration: InputDecoration(
                          labelText: 'Treatment Given *',
                          prefixIcon: Icon(
                            Icons.healing,
                            color: Color(0xFF00D4D4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF00D4D4)),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter treatment details';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text('Follow-up Required'),
                        value: _isFollowUpRequired,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFollowUpRequired = value ?? false;
                          });
                        },
                        activeColor: Color(0xFF00D4D4),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Additional Notes Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 Additional Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4D4),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: Icon(
                            Icons.note_add,
                            color: Color(0xFF00D4D4),
                          ),
                          hintText: 'Any additional observations or notes...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF00D4D4)),
                          ),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearForm,
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      label: Text(
                        'Clear',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saveReport,
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'Save Report',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00D4D4),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
