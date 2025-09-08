import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/baby.dart';
import '../../../services/growth_entry_service.dart';

class MidwifeAddGrowthScreen extends StatefulWidget {
  final Baby baby;
  final String motherNic;

  const MidwifeAddGrowthScreen({
    Key? key,
    required this.baby,
    required this.motherNic,
  }) : super(key: key);

  @override
  _MidwifeAddGrowthScreenState createState() => _MidwifeAddGrowthScreenState();
}

class _MidwifeAddGrowthScreenState extends State<MidwifeAddGrowthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _midwifeLicenseController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _midwifeLicenseController.dispose();
    super.dispose();
  }

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

  Future<void> _submitGrowthEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await GrowthEntryService.addEntry(
        motherNic: widget.motherNic,
        babyId: widget.baby.id,
        height: double.parse(_heightController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        date: _selectedDate,
        midwifeLicense: _midwifeLicenseController.text.trim().isEmpty
            ? null
            : _midwifeLicenseController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Growth record added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding growth record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Growth Record'),
        backgroundColor: Colors.blue[100],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baby Info Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            widget.baby.babyOrder.toString(),
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.baby.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text('Age: ${widget.baby.ageInMonths} months'),
                              Text(
                                'Birth Date: ${widget.baby.formattedBirthDate}',
                              ),
                              if (widget.baby.birthWeight != null)
                                Text(
                                  'Birth Weight: ${widget.baby.birthWeight}g',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Growth Form
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Growth Measurements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Height
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Height (cm) *',
                            prefixIcon: Icon(
                              Icons.height,
                              color: Colors.blue[300],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[300]!),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter height';
                            }
                            final height = double.tryParse(value.trim());
                            if (height == null) {
                              return 'Please enter a valid number';
                            }
                            if (height <= 0 || height > 200) {
                              return 'Please enter a realistic height';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Weight
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Weight (kg) *',
                            prefixIcon: Icon(
                              Icons.monitor_weight,
                              color: Colors.blue[300],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[300]!),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter weight';
                            }
                            final weight = double.tryParse(value.trim());
                            if (weight == null) {
                              return 'Please enter a valid number';
                            }
                            if (weight <= 0 || weight > 50) {
                              return 'Please enter a realistic weight';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Measurement Date
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.blue[300],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Measurement Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blue[700],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Midwife License (Optional)
                        TextFormField(
                          controller: _midwifeLicenseController,
                          decoration: InputDecoration(
                            labelText: 'Midwife License Number (Optional)',
                            prefixIcon: Icon(
                              Icons.badge,
                              color: Colors.blue[300],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[300]!),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : _submitGrowthEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSubmitting
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Add Growth Record',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Growth Tips
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Growth Tips',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Measure height without shoes\n'
                                '• Weigh without heavy clothing\n'
                                '• Best time: morning, before feeding\n'
                                '• Record measurements regularly',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
