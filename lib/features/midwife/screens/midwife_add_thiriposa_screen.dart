import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/baby.dart';
import '../../../services/thiriposa_service.dart';

class MidwifeAddThiriposaScreen extends StatefulWidget {
  final Baby baby;
  final String motherNic;

  const MidwifeAddThiriposaScreen({
    Key? key,
    required this.baby,
    required this.motherNic,
  }) : super(key: key);

  @override
  _MidwifeAddThiriposaScreenState createState() =>
      _MidwifeAddThiriposaScreenState();
}

class _MidwifeAddThiriposaScreenState extends State<MidwifeAddThiriposaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        Duration(days: 7),
      ), // Allow future dates up to a week
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitThiriposaRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ThiriposaService.addRecord(
        motherNic: widget.motherNic,
        babyId: widget.baby.id,
        date: _selectedDate,
        quantity: int.parse(_quantityController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thiriposa record added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding thiriposa record: $e'),
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
        title: Text('Add Thiriposa Record'),
        backgroundColor: Colors.purple[100],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[50]!, Colors.white],
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
                          backgroundColor: Colors.purple[100],
                          child: Text(
                            widget.baby.babyOrder.toString(),
                            style: TextStyle(
                              color: Colors.purple[700],
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
                                  color: Colors.purple[700],
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

                // Thiriposa Form
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thiriposa Supply Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Quantity
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Quantity (packets) *',
                            prefixIcon: Icon(
                              Icons.inventory,
                              color: Colors.purple[300],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.purple[300]!,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter quantity';
                            }
                            final quantity = int.tryParse(value.trim());
                            if (quantity == null) {
                              return 'Please enter a valid number';
                            }
                            if (quantity <= 0) {
                              return 'Quantity must be greater than 0';
                            }
                            if (quantity > 100) {
                              return 'Please enter a realistic quantity';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Supply Date
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
                                      color: Colors.purple[300],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Supply Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.purple[700],
                                ),
                              ],
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
                                : _submitThiriposaRecord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSubmitting
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Add Thiriposa Record',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Thiriposa Information
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.purple[700],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'About Thiriposa',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Thiriposa is a nutritional supplement provided to support healthy growth and development of infants and young children. '
                                'It contains essential vitamins and minerals needed for proper nutrition.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Distribution Guidelines:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[600],
                                ),
                              ),
                              Text(
                                '• Age 6-59 months: Regular distribution\n'
                                '• Follow recommended dosage\n'
                                '• Monitor for any allergic reactions\n'
                                '• Store in cool, dry place',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple[600],
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
