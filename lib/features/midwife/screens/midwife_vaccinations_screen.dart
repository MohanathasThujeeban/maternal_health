import 'package:flutter/material.dart';
import '../../../models/baby.dart';
import '../../../services/baby_service.dart';
import '../../../services/vaccination_service.dart';
import '../../../services/user_service.dart';
import 'midwife_add_vaccination_screen.dart';

class MidwifeVaccinationsScreen extends StatefulWidget {
  const MidwifeVaccinationsScreen({Key? key}) : super(key: key);

  @override
  _MidwifeVaccinationsScreenState createState() =>
      _MidwifeVaccinationsScreenState();
}

class _MidwifeVaccinationsScreenState extends State<MidwifeVaccinationsScreen> {
  final _nicController = TextEditingController();

  List<Map<String, dynamic>> _mothers = [];
  List<Baby> _babies = [];
  Baby? _selectedBaby;
  List<Map<String, dynamic>> _vaccinations = [];
  bool _isLoadingBabies = false;
  bool _isLoadingVaccinations = false;
  String? _motherName;

  @override
  void initState() {
    super.initState();
    _loadAllMothers();
  }

  @override
  void dispose() {
    _nicController.dispose();
    super.dispose();
  }

  Future<void> _loadAllMothers() async {
    try {
      final mothers = await UserService.getAllMothers();
      setState(() {
        _mothers = mothers;
      });
    } catch (e) {
      _showSnackBar('Error loading mothers: $e', isError: true);
    }
  }

  Future<void> _selectMother(Map<String, dynamic> mother) async {
    setState(() {
      _nicController.text = mother['nicNumber'] ?? '';
      _motherName = mother['fullName'];
      _babies = [];
      _selectedBaby = null;
      _vaccinations = [];
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
      _vaccinations = [];
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

  Future<void> _selectBaby(Baby baby) async {
    setState(() {
      _selectedBaby = baby;
      _isLoadingVaccinations = true;
      _vaccinations = [];
    });

    try {
      // Load vaccinations for the selected baby
      print('DEBUG: Loading vaccinations for baby ID: ${baby.id}');
      final vaccinations = await VaccinationService.getVaccinationsByBaby(
        baby.id,
      );
      print('DEBUG: Successfully loaded ${vaccinations.length} vaccinations');

      // Convert Vaccination objects to Map for compatibility with existing UI
      final vaccinationMaps = vaccinations
          .map(
            (vaccination) => {
              'id': vaccination.id,
              'vaccinationType': vaccination.vaccinationType,
              'childName': baby.name,
              'ageToGive': vaccination.ageToGive,
              'vaccinationDate': vaccination.vaccinationDate,
              'batchNumber': vaccination.batchNumber,
              'effectsFollowingImmunization':
                  vaccination.effectsFollowingImmunization,
              'status': vaccination.status,
            },
          )
          .toList();

      setState(() {
        _vaccinations = vaccinationMaps;
        _isLoadingVaccinations = false;
      });

      if (vaccinations.isEmpty) {
        print('DEBUG: No vaccination records found for ${baby.name}');
        _showSnackBar('No vaccination records found for ${baby.name}');
      } else {
        print(
          'DEBUG: Found ${vaccinations.length} vaccination records for ${baby.name}',
        );
      }
    } catch (e) {
      print('DEBUG: Error loading vaccinations for baby: $e');
      setState(() => _isLoadingVaccinations = false);
      _showSnackBar('Error loading vaccinations: $e', isError: true);
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

  void _navigateToAddVaccination() async {
    if (_selectedBaby == null || _nicController.text.isEmpty) {
      _showSnackBar(
        'Please select a baby before adding vaccination',
        isError: true,
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidwifeAddVaccinationScreen(
          baby: _selectedBaby!,
          motherNic: _nicController.text,
        ),
      ),
    );

    // If a vaccination was added successfully, reload the vaccinations
    if (result == true && _selectedBaby != null) {
      _selectBaby(_selectedBaby!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vaccination Records',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mother Selection Card
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

                // NIC Search Card
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
                          ...(_babies
                              .map(
                                (baby) => Card(
                                  elevation: 2,
                                  margin: EdgeInsets.only(bottom: 8),
                                  color: _selectedBaby?.id == baby.id
                                      ? Color(0xFFE8F5F2)
                                      : Colors.white,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Color(0xFF4FC3A1),
                                      child: Text(
                                        baby.babyOrder.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      baby.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Age: ${baby.ageInMonths} months | Born: ${baby.formattedBirthDate}',
                                    ),
                                    trailing: _selectedBaby?.id == baby.id
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF4FC3A1),
                                          )
                                        : Icon(
                                            Icons.arrow_forward_ios,
                                            color: Color(0xFF4FC3A1),
                                          ),
                                    onTap: () => _selectBaby(baby),
                                  ),
                                ),
                              )
                              .toList()),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Vaccination Records
                if (_selectedBaby != null) ...[
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.vaccines,
                                color: Color(0xFF2E7D5A),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Vaccination Records for ${_selectedBaby!.name}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D5A),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          if (_isLoadingVaccinations)
                            Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4FC3A1),
                              ),
                            )
                          else if (_vaccinations.isEmpty)
                            Container(
                              padding: EdgeInsets.all(32),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFFE8F5F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFF4FC3A1)),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.vaccines_outlined,
                                    size: 48,
                                    color: Color(0xFF4FC3A1),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No vaccination records found for ${_selectedBaby!.name}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2E7D5A),
                                      fontFamily: 'SpotifyCircular',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: _vaccinations
                                  .map(
                                    (vaccination) =>
                                        _buildVaccinationCard(vaccination),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedBaby != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddVaccination,
              backgroundColor: const Color(0xFF4FC3A1),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Vaccination'),
            )
          : null,
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> vaccination) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with vaccination type and child name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF4FC3A1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.vaccines,
                      color: Color(0xFF4FC3A1),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination['vaccinationType'] ?? 'Unknown Vaccine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SpotifyCircular',
                            color: Color(0xFF2E7D5A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                        SizedBox(height: 4),
                        if (vaccination['childName']?.isNotEmpty == true)
                          Text(
                            'Child: ${vaccination['childName']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontFamily: 'SpotifyCircular',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Details Grid
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vaccination['ageToGive']?.isNotEmpty == true)
                      _buildDetailRow(
                        Icons.child_care,
                        'Recommended Age',
                        vaccination['ageToGive'],
                      ),

                    if (vaccination['vaccinationDate'] != null)
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date Given',
                        vaccination['vaccinationDate'].toString().split(' ')[0],
                      ),

                    if (vaccination['batchNumber']?.isNotEmpty == true)
                      _buildDetailRow(
                        Icons.inventory,
                        'Batch Number',
                        vaccination['batchNumber'],
                      ),

                    if (vaccination['effectsFollowingImmunization']
                            ?.isNotEmpty ==
                        true)
                      _buildDetailRow(
                        Icons.medical_information,
                        'Effects/Notes',
                        vaccination['effectsFollowingImmunization'],
                        isLast: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Color(0xFF4FC3A1)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'SpotifyCircular',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SpotifyCircular',
                    color: Color(0xFF2E7D5A),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
