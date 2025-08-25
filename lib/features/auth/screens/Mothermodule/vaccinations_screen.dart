import 'package:flutter/material.dart';
import '../../../../services/vaccination_service.dart';
import '../../../../services/user_service.dart';

class VaccinationsScreen extends StatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  State<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  List<Map<String, dynamic>> _vaccinations = [];
  bool _isLoading = true;
  String? _motherNic;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  void _loadVaccinations() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user's NIC
      _motherNic = await UserService.getUserNic();
      print('DEBUG: Mother NIC from UserService: $_motherNic');

      if (_motherNic != null) {
        print('DEBUG: Attempting to fetch vaccinations for NIC: $_motherNic');
        // Fetch vaccinations from backend using mother's NIC
        final vaccinations =
            await VaccinationService.getVaccinationsByMotherNic(_motherNic!);
        print('DEBUG: Fetched ${vaccinations.length} vaccination records');
        print('DEBUG: Vaccination data: $vaccinations');

        // Check if we got real data or empty array
        if (vaccinations.isNotEmpty) {
          print('DEBUG: Using real vaccination data from backend');
          setState(() {
            _vaccinations = vaccinations;
            _isLoading = false;
          });
        } else {
          print('DEBUG: No vaccination records found for this mother');
          setState(() {
            _vaccinations = []; // Show empty state instead of mock data
            _isLoading = false;
          });
        }
      } else {
        print('DEBUG: No user NIC found');
        // Show empty state instead of mock data
        setState(() {
          _vaccinations = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading vaccinations: $e');
      // Show empty state instead of mock data on error
      setState(() {
        _vaccinations = [];
        _isLoading = false;
      });
    }
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
          : SafeArea(
              child: Column(
                children: [
                  // Header
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
                          'Vaccination Records',
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.vaccines,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  '${_vaccinations.length} Vaccination${_vaccinations.length != 1 ? 's' : ''} Recorded',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'SpotifyCircular',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vaccination List
                  Expanded(
                    child: _vaccinations.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.vaccines_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No vaccination records found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontFamily: 'SpotifyCircular',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _vaccinations.length,
                            itemBuilder: (context, index) {
                              return _buildVaccinationCard(
                                context,
                                _vaccinations[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVaccinationCard(
    BuildContext context,
    Map<String, dynamic> vaccination,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with vaccination type and child name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3A1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.vaccines,
                      color: Color(0xFF4FC3A1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination['vaccinationType'] ?? 'Unknown Vaccine',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SpotifyCircular',
                            color: Color(0xFF2E7D5A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                        const SizedBox(height: 4),
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

              const SizedBox(height: 20),

              // Details Grid
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
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
          Icon(icon, size: 18, color: const Color(0xFF4FC3A1)),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
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
