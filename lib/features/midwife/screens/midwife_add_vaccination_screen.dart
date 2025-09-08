import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/baby.dart';
import '../../../services/vaccination_service.dart';

class MidwifeAddVaccinationScreen extends StatefulWidget {
  final Baby baby;
  final String motherNic;

  const MidwifeAddVaccinationScreen({
    Key? key,
    required this.baby,
    required this.motherNic,
  }) : super(key: key);

  @override
  _MidwifeAddVaccinationScreenState createState() =>
      _MidwifeAddVaccinationScreenState();
}

class _MidwifeAddVaccinationScreenState
    extends State<MidwifeAddVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccinationTypeController = TextEditingController();
  final _ageToGiveController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _effectsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'PENDING';
  bool _isSubmitting = false;

  final List<String> _statusOptions = ['PENDING', 'COMPLETED', 'OVERDUE'];

  @override
  void dispose() {
    _vaccinationTypeController.dispose();
    _ageToGiveController.dispose();
    _batchNumberController.dispose();
    _effectsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitVaccination() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await VaccinationService.createVaccinationForBaby(
        motherNic: widget.motherNic,
        babyId: widget.baby.id,
        childName: widget.baby.name,
        vaccinationType: _vaccinationTypeController.text.trim(),
        ageToGive: _ageToGiveController.text.trim(),
        vaccinationDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        batchNumber: _batchNumberController.text.trim().isEmpty
            ? null
            : _batchNumberController.text.trim(),
        effectsFollowingImmunization: _effectsController.text.trim().isEmpty
            ? null
            : _effectsController.text.trim(),
        status: _selectedStatus,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vaccination record added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding vaccination: $e'),
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
        title: Text('Add Vaccination'),
        backgroundColor: Colors.green[100],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
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
                          backgroundColor: Colors.green[100],
                          child: Text(
                            widget.baby.babyOrder.toString(),
                            style: TextStyle(
                              color: Colors.green[700],
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
                                  color: Colors.green[700],
                                ),
                              ),
                              Text('Age: ${widget.baby.ageInMonths} months'),
                              Text(
                                'Birth Date: ${widget.baby.formattedBirthDate}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Vaccination Form
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vaccination Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Vaccination Type Text Field
                        TextFormField(
                          controller: _vaccinationTypeController,
                          decoration: InputDecoration(
                            labelText: 'Vaccination Type *',
                            hintText: 'e.g., BCG, DPT, Polio, MMR, etc.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.green[600]!),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter vaccination type';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Age to Give
                        TextFormField(
                          controller: _ageToGiveController,
                          decoration: InputDecoration(
                            labelText: 'Age to Give *',
                            hintText: 'e.g., At birth, 2 months, 4 months',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter age to give';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Vaccination Date
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
                                Text(
                                  'Vaccination Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.green[700],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Status
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: _statusOptions.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),

                        SizedBox(height: 16),

                        // Batch Number (Optional)
                        TextFormField(
                          controller: _batchNumberController,
                          decoration: InputDecoration(
                            labelText: 'Batch Number (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Effects Following Immunization (Optional)
                        TextFormField(
                          controller: _effectsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText:
                                'Effects Following Immunization (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
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
                                : _submitVaccination,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSubmitting
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Add Vaccination Record',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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
