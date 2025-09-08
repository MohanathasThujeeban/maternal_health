import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/baby.dart';
import '../../../services/baby_service.dart';
import '../../../services/thiriposa_service.dart';
import '../../../services/user_service.dart';

class MidwifeThiriposaRecordsScreen extends StatefulWidget {
  const MidwifeThiriposaRecordsScreen({Key? key}) : super(key: key);

  @override
  _MidwifeThiriposaRecordsScreenState createState() =>
      _MidwifeThiriposaRecordsScreenState();
}

class _MidwifeThiriposaRecordsScreenState
    extends State<MidwifeThiriposaRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicController = TextEditingController();
  final _quantityController = TextEditingController();

  List<Map<String, dynamic>> _mothers = [];
  List<Baby> _babies = [];
  Baby? _selectedBaby;
  DateTime _selectedDate = DateTime.now();
  bool _isLoadingBabies = false;
  bool _isSubmitting = false;
  String? _motherName;

  @override
  void initState() {
    super.initState();
    _loadAllMothers();
  }

  @override
  void dispose() {
    _nicController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadAllMothers() async {
    print('_loadAllMothers called');
    setState(() {
      _mothers = []; // Clear existing data
    });

    try {
      print('Loading mothers...');
      final mothers = await UserService.getAllMothers();
      print('Received ${mothers.length} mothers: $mothers');

      setState(() {
        _mothers = mothers;
      });

      print('State updated with ${_mothers.length} mothers');
    } catch (e) {
      print('Error in _loadAllMothers: $e');
      setState(() {
        _mothers = [];
      });
      _showSnackBar('Error loading mothers: $e', isError: true);
    }
  }

  Future<void> _selectMother(Map<String, dynamic> mother) async {
    setState(() {
      _nicController.text = mother['nicNumber'] ?? '';
      _motherName = mother['fullName'];
      _babies = [];
      _selectedBaby = null;
    });

    // Auto-load babies for selected mother
    await _searchBabies();
  }

  Future<void> _searchBabies() async {
    if (_nicController.text.trim().isEmpty) {
      _showSnackBar('Please enter mother\'s NIC number', isError: true);
      return;
    }

    setState(() {
      _isLoadingBabies = true;
      _babies = [];
      _selectedBaby = null;
      _motherName = null;
    });

    try {
      final babiesData = await BabyService.getBabiesByMotherNic(
        _nicController.text.trim(),
      );

      List<Baby> babies = babiesData.map((babyData) {
        return Baby(
          id: babyData['id'],
          motherNic: babyData['motherNic'],
          motherName: babyData['motherName'] ?? 'Unknown',
          name: babyData['babyName'] ?? 'Unnamed Baby',
          dateOfBirth: babyData['dateOfBirth'] ?? '',
          gender: babyData['gender'] ?? 'Not specified',
          birthWeight: babyData['birthWeight']?.toDouble(),
          birthHeight: babyData['birthHeight']?.toDouble(),
          babyOrder: babyData['babyOrder'] ?? 1,
          isActive: babyData['isActive'] ?? true,
          createdAt: babyData['createdAt'] != null
              ? DateTime.parse(babyData['createdAt'])
              : DateTime.now(),
          updatedAt: babyData['updatedAt'] != null
              ? DateTime.parse(babyData['updatedAt'])
              : DateTime.now(),
        );
      }).toList();

      setState(() {
        _babies = babies;
        _motherName = babies.isNotEmpty ? babies.first.motherName : 'Unknown';
        _isLoadingBabies = false;
      });

      if (babies.isEmpty) {
        _showSnackBar('No babies found for this mother', isError: true);
      }
    } catch (e) {
      setState(() => _isLoadingBabies = false);
      _showSnackBar('Error searching babies: $e', isError: true);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitThiriposaRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBaby == null) {
      _showSnackBar('Please select a baby', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ThiriposaService.addRecord(
        motherNic: _nicController.text.trim(),
        babyId: _selectedBaby!.id,
        date: _selectedDate,
        quantity: int.parse(_quantityController.text.trim()),
      );

      _showSnackBar('Thiriposa record added successfully');

      // Reset form
      _quantityController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
    } catch (e) {
      _showSnackBar('Error adding thiriposa record: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Color(0xFF4FC3A1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thiriposa Records'),
        backgroundColor: Color(0xFFE8F5F2),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // All Mothers List Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Mother',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D5A),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Flexible mothers list with proper constraints
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF4FC3A1),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: _mothers.length,
                                padding: EdgeInsets.all(8),
                                itemBuilder: (context, index) {
                                  final mother = _mothers[index];
                                  return Card(
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xFF4FC3A1),
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        mother['fullName'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'NIC: ${mother['nicNumber'] ?? 'N/A'}',
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFF4FC3A1),
                                      ),
                                      onTap: () => _selectMother(mother),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Mother Search Card (Alternative method)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Or Search by NIC',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D5A),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nicController,
                                  decoration: InputDecoration(
                                    labelText: 'Mother\'s NIC Number *',
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Color(0xFF4FC3A1),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color(0xFF4FC3A1),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter mother\'s NIC';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _isLoadingBabies
                                    ? null
                                    : _searchBabies,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4FC3A1),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoadingBabies
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Search',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ],
                          ),
                          if (_motherName != null) ...[
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFE8F5F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFF4FC3A1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Color(0xFF2E7D5A)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mother: $_motherName',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D5A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Baby Selection Card
                  if (_babies.isNotEmpty) ...[
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Baby',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D5A),
                              ),
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<Baby>(
                              value: _selectedBaby,
                              decoration: InputDecoration(
                                labelText: 'Select Baby *',
                                prefixIcon: Icon(
                                  Icons.child_care,
                                  color: Color(0xFF4FC3A1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Color(0xFF4FC3A1),
                                  ),
                                ),
                              ),
                              items: _babies.map((baby) {
                                return DropdownMenuItem<Baby>(
                                  value: baby,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        baby.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Age: ${baby.ageInMonths} months | Born: ${baby.formattedBirthDate}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (Baby? newValue) {
                                setState(() {
                                  _selectedBaby = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a baby';
                                }
                                return null;
                              },
                            ),
                            if (_selectedBaby != null) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F5F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Color(0xFF4FC3A1)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFFE8F5F2),
                                      child: Text(
                                        _selectedBaby!.babyOrder.toString(),
                                        style: TextStyle(
                                          color: Color(0xFF2E7D5A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Baby ID: ${_selectedBaby!.id}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2E7D5A),
                                            ),
                                          ),
                                          Text(
                                            'Gender: ${_selectedBaby!.gender}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2E7D5A),
                                            ),
                                          ),
                                          if (_selectedBaby!.birthWeight !=
                                              null)
                                            Text(
                                              'Birth Weight: ${_selectedBaby!.birthWeight} kg',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF2E7D5A),
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
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],

                  // Thiriposa Form Card
                  if (_selectedBaby != null) ...[
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
                                color: Color(0xFF2E7D5A),
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
                                  color: Color(0xFF4FC3A1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Color(0xFF4FC3A1),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF4FC3A1),
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
                                      color: Color(0xFF2E7D5A),
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
                                  backgroundColor: Color(0xFF4FC3A1),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
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
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Information Card
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF4FC3A1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Color(0xFF2E7D5A),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'About Thiriposa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D5A),
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
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Distribution Guidelines:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        Text(
                          '• Age 6-59 months: Regular distribution\n'
                          '• Follow recommended dosage\n'
                          '• Monitor for any allergic reactions\n'
                          '• Store in cool, dry place',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
