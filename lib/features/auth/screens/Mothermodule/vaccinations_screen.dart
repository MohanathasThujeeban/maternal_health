import 'package:flutter/material.dart';

class VaccinationsScreen extends StatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  State<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  List<Map<String, dynamic>> _vaccinations = [];
  bool _isLoading = true;

  // Mock data for now - will be replaced with API calls later
  final List<Map<String, dynamic>> _mockVaccinations = [
    {
      'id': 1,
      'childName': 'Baby John',
      'vaccinationType': 'BCG',
      'description': 'Protection against tuberculosis',
      'ageToGive': 'At birth',
      'vaccinationDate': DateTime(2025, 1, 15),
      'batchNumber': 'BCG2025001',
      'effectsFollowingImmunization': 'None',
      'status': 'COMPLETED'
    },
    {
      'id': 2,
      'childName': 'Baby John',
      'vaccinationType': 'Hepatitis B',
      'description': 'Protection against hepatitis B virus',
      'ageToGive': 'At birth',
      'vaccinationDate': DateTime(2025, 1, 15),
      'batchNumber': 'HEP2025001',
      'effectsFollowingImmunization': 'None',
      'status': 'COMPLETED'
    },
    {
      'id': 3,
      'childName': 'Baby John',
      'vaccinationType': 'DPT (1st dose)',
      'description': 'Diphtheria, Pertussis, Tetanus',
      'ageToGive': '2 months',
      'vaccinationDate': DateTime(2025, 3, 15),
      'batchNumber': 'DPT2025001',
      'effectsFollowingImmunization': 'Mild fever',
      'status': 'COMPLETED'
    },
    {
      'id': 4,
      'childName': 'Baby John',
      'vaccinationType': 'OPV (1st dose)',
      'description': 'Oral Polio Vaccine',
      'ageToGive': '2 months',
      'vaccinationDate': DateTime(2025, 3, 15),
      'batchNumber': 'OPV2025001',
      'effectsFollowingImmunization': 'None',
      'status': 'COMPLETED'
    },
    {
      'id': 5,
      'childName': 'Baby John',
      'vaccinationType': 'MMR',
      'description': 'Measles, Mumps, Rubella',
      'ageToGive': '12 months',
      'vaccinationDate': null,
      'batchNumber': '',
      'effectsFollowingImmunization': '',
      'status': 'PENDING'
    },
    {
      'id': 6,
      'childName': 'Baby John',
      'vaccinationType': 'Varicella',
      'description': 'Chickenpox vaccine',
      'ageToGive': '15 months',
      'vaccinationDate': null,
      'batchNumber': '',
      'effectsFollowingImmunization': '',
      'status': 'PENDING'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  void _loadVaccinations() {
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _vaccinations = _mockVaccinations;
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> get completedVaccinations => 
      _vaccinations.where((v) => v['status'] == 'COMPLETED').toList();

  List<Map<String, dynamic>> get pendingVaccinations => 
      _vaccinations.where((v) => v['status'] == 'PENDING').toList();

  double get completionPercentage => _vaccinations.isEmpty 
      ? 0.0 
      : completedVaccinations.length / _vaccinations.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vaccination Records',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Vaccination Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(completionPercentage * 100).round()}% Complete',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'SpotifyCircular',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${completedVaccinations.length} of ${_vaccinations.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'SpotifyCircular',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: completionPercentage,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Vaccination List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (completedVaccinations.isNotEmpty) ...[
                        _buildSectionHeader('Completed Vaccinations'),
                        ...completedVaccinations.map((vaccination) =>
                            _buildVaccinationCard(context, vaccination)),
                        const SizedBox(height: 20),
                      ],
                      if (pendingVaccinations.isNotEmpty) ...[
                        _buildSectionHeader('Pending Vaccinations'),
                        ...pendingVaccinations.map((vaccination) =>
                            _buildVaccinationCard(context, vaccination)),
                      ],
                      if (_vaccinations.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No vaccination records found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'SpotifyCircular',
          color: Color(0xFF2E7D5A),
        ),
      ),
    );
  }

  Widget _buildVaccinationCard(
    BuildContext context, 
    Map<String, dynamic> vaccination,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (vaccination['status']) {
      case 'COMPLETED':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'PENDING':
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.schedule;
        statusText = 'Pending';
        break;
      case 'MISSED':
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.error;
        statusText = 'Missed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
        statusText = vaccination['status'];
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination['vaccinationType'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SpotifyCircular',
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vaccination['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.child_care, 
                      'Age', 
                      vaccination['ageToGive'],
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.calendar_today, 
                      'Date', 
                      vaccination['vaccinationDate'] != null
                          ? vaccination['vaccinationDate'].toString().split(' ')[0]
                          : 'Not given',
                    ),
                  ),
                ],
              ),
              if (vaccination['batchNumber'].isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.inventory, 
                  'Batch', 
                  vaccination['batchNumber'],
                ),
              ],
              if (vaccination['effectsFollowingImmunization'].isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.medical_information, 
                  'Effects', 
                  vaccination['effectsFollowingImmunization'],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'SpotifyCircular',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'SpotifyCircular',
            ),
          ),
        ),
      ],
    );
  }
}
