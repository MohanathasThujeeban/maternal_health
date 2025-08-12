import 'package:flutter/material.dart';

class VaccinationsScreen extends StatelessWidget {
  const VaccinationsScreen({Key? key}) : super(key: key);

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
      body: Column(
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
                        children: const [
                          Text(
                            '75% Complete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'SpotifyCircular',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '6 of 8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 0.75,
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
                _buildSectionHeader('Completed Vaccinations'),
                _buildVaccinationCard(
                  context,
                  title: 'BCG (Tuberculosis)',
                  description: 'Protection against tuberculosis',
                  date: '2025-01-15',
                  status: 'Completed',
                  dueDate: '2025-01-15',
                  ageGiven: 'At birth',
                ),
                _buildVaccinationCard(
                  context,
                  title: 'Hepatitis B',
                  description: 'Protection against hepatitis B virus',
                  date: '2025-01-15',
                  status: 'Completed',
                  dueDate: '2025-01-15',
                  ageGiven: 'At birth',
                ),
                _buildVaccinationCard(
                  context,
                  title: 'DPT (1st dose)',
                  description: 'Diphtheria, Pertussis, Tetanus',
                  date: '2025-03-15',
                  status: 'Completed',
                  dueDate: '2025-03-15',
                  ageGiven: '2 months',
                ),
                _buildVaccinationCard(
                  context,
                  title: 'Polio (1st dose)',
                  description: 'Oral Polio Vaccine',
                  date: '2025-03-15',
                  status: 'Completed',
                  dueDate: '2025-03-15',
                  ageGiven: '2 months',
                ),
                _buildVaccinationCard(
                  context,
                  title: 'DPT (2nd dose)',
                  description: 'Diphtheria, Pertussis, Tetanus',
                  date: '2025-04-15',
                  status: 'Completed',
                  dueDate: '2025-04-15',
                  ageGiven: '4 months',
                ),
                _buildVaccinationCard(
                  context,
                  title: 'Polio (2nd dose)',
                  description: 'Oral Polio Vaccine',
                  date: '2025-04-15',
                  status: 'Completed',
                  dueDate: '2025-04-15',
                  ageGiven: '4 months',
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('Upcoming Vaccinations'),
                _buildVaccinationCard(
                  context,
                  title: 'MMR',
                  description: 'Measles, Mumps, Rubella',
                  date: 'Not given',
                  status: 'Due Soon',
                  dueDate: '2025-08-15',
                  ageGiven: '12 months',
                ),
                _buildVaccinationCard(
                  context,
                  title: 'Varicella',
                  description: 'Chickenpox vaccine',
                  date: 'Not scheduled',
                  status: 'Scheduled',
                  dueDate: '2025-09-15',
                  ageGiven: '15 months',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddVaccinationDialog(context);
        },
        backgroundColor: const Color(0xFF4FC3A1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Record',
          style: TextStyle(color: Colors.white, fontFamily: 'SpotifyCircular'),
        ),
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
    BuildContext context, {
    required String title,
    required String description,
    required String date,
    required String status,
    required String dueDate,
    required String ageGiven,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        break;
      case 'due soon':
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.schedule;
        break;
      case 'scheduled':
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.event;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
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
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SpotifyCircular',
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
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
                          status,
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
                    child: _buildInfoRow(Icons.child_care, 'Age', ageGiven),
                  ),
                  Expanded(
                    child: _buildInfoRow(Icons.calendar_today, 'Given', date),
                  ),
                ],
              ),
              if (status.toLowerCase() != 'completed') ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, 'Due Date', dueDate),
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

  void _showAddVaccinationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Vaccination Record',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'This feature will allow you to add new vaccination records. Coming soon!',
            style: TextStyle(fontFamily: 'SpotifyCircular'),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF4FC3A1),
                  fontFamily: 'SpotifyCircular',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
