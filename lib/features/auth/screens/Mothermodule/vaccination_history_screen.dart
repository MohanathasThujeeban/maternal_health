import 'package:flutter/material.dart';
import '../../../../services/vaccination_service.dart';
import '../../../../services/user_service.dart';

class VaccinationHistoryScreen extends StatefulWidget {
  const VaccinationHistoryScreen({super.key});

  @override
  State<VaccinationHistoryScreen> createState() =>
      _VaccinationHistoryScreenState();
}

class _VaccinationHistoryScreenState extends State<VaccinationHistoryScreen> {
  List<Map<String, dynamic>> _vaccinations = [];
  bool _isLoading = true;
  String? _motherNic;

  @override
  void initState() {
    super.initState();
    _loadVaccinationHistory();
  }

  Future<void> _loadVaccinationHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user's NIC
      _motherNic = await UserService.getUserNic();

      if (_motherNic != null && _motherNic!.isNotEmpty) {
        // Fetch real vaccinations from backend
        final vaccinations =
            await VaccinationService.getVaccinationsByMotherNic(_motherNic!);
        setState(() {
          _vaccinations = vaccinations;
          _isLoading = false;
        });
      } else {
        // No user NIC found - show empty state
        setState(() {
          _vaccinations = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading vaccination history: $e');
      // Show empty state on error instead of mock data
      setState(() {
        _vaccinations = [];
        _isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load vaccination records. Please check your internet connection.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final completedVaccinations = _vaccinations
        .where((v) => v['status'] == 'COMPLETED')
        .toList();
    final pendingVaccinations = _vaccinations
        .where((v) => v['status'] == 'PENDING')
        .toList();
    final missedVaccinations = _vaccinations
        .where((v) => v['status'] == 'MISSED')
        .toList();
    final completionPercentage = _vaccinations.isNotEmpty
        ? completedVaccinations.length / _vaccinations.length
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vaccination History',
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _loadVaccinationHistory,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4FC3A1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          '${_vaccinations.length}',
                          Icons.vaccines,
                          const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Completed',
                          '${completedVaccinations.length}',
                          Icons.check_circle,
                          const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          '${pendingVaccinations.length}',
                          Icons.schedule,
                          const Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Missed',
                          '${missedVaccinations.length}',
                          Icons.warning,
                          const Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Progress Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4FC3A1), Color(0xFF2E7D5A)],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vaccination Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(completionPercentage * 100).round()}% Complete',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                              Text(
                                '${completedVaccinations.length}/${_vaccinations.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: completionPercentage,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Vaccination Timeline
                  const Text(
                    'Vaccination Timeline',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D5A),
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vaccinations List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _vaccinations.length,
                    itemBuilder: (context, index) {
                      final vaccination = _vaccinations[index];
                      return _buildVaccinationTimelineCard(
                        vaccination,
                        index == _vaccinations.length - 1,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationTimelineCard(
    Map<String, dynamic> vaccination,
    bool isLast,
  ) {
    final status = vaccination['status'];
    final isCompleted = status == 'COMPLETED';
    final isPending = status == 'PENDING';

    Color statusColor = isCompleted
        ? Colors.green
        : isPending
        ? Colors.orange
        : Colors.red;
    IconData statusIcon = isCompleted
        ? Icons.check_circle
        : isPending
        ? Icons.schedule
        : Icons.cancel;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: Colors.white, size: 14),
              ),
              if (!isLast)
                Container(width: 2, height: 60, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 16),

          // Content card
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            vaccination['vaccinationType'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D5A),
                              fontFamily: 'SpotifyCircular',
                            ),
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
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.child_care,
                      'Child:',
                      vaccination['childName'],
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Age to Give:',
                      vaccination['ageToGive'],
                    ),
                    if (vaccination['vaccinationDate'] != null)
                      _buildInfoRow(
                        Icons.event,
                        'Date Given:',
                        vaccination['vaccinationDate'].toString().split(' ')[0],
                      ),
                    if (vaccination['batchNumber'] != null &&
                        vaccination['batchNumber'].toString().isNotEmpty)
                      _buildInfoRow(
                        Icons.inventory,
                        'Batch Number:',
                        vaccination['batchNumber'],
                      ),
                    if (vaccination['effectsFollowingImmunization'] != null &&
                        vaccination['effectsFollowingImmunization']
                            .toString()
                            .isNotEmpty)
                      _buildInfoRow(
                        Icons.info_outline,
                        'Effects:',
                        vaccination['effectsFollowingImmunization'],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4FC3A1)),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontFamily: 'SpotifyCircular',
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Color(0xFF2E2E2E),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
