import 'package:flutter/material.dart';
import 'features/auth/screens/Mothermodule/vaccination_history_screen.dart';
import 'features/auth/screens/Midwivesmodule/midwife_vaccination_screen.dart';

class VaccinationTestScreen extends StatelessWidget {
  const VaccinationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vaccination System Test',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test the complete vaccination management system',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D5A),
                fontFamily: 'SpotifyCircular',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mother View Card
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
                    const Row(
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Mother View',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'View vaccination history and progress with detailed timeline, statistics, and status tracking.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const VaccinationHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.visibility,
                        color: Color(0xFF2E7D5A),
                      ),
                      label: const Text(
                        'View Vaccination History',
                        style: TextStyle(
                          color: Color(0xFF2E7D5A),
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Midwife View Card
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
                    colors: [Color(0xFF6B73FF), Color(0xFF3F47CC)],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Midwife Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Manage all registered mothers, update vaccination records, send email notifications.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MidwifeVaccinationScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.dashboard,
                        color: Color(0xFF3F47CC),
                      ),
                      label: const Text(
                        'Open Midwife Dashboard',
                        style: TextStyle(
                          color: Color(0xFF3F47CC),
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Features List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Features:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D5A),
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('✅ View all registered mothers'),
                  _buildFeatureItem('✅ Search mothers by name/NIC'),
                  _buildFeatureItem('✅ Update vaccination status'),
                  _buildFeatureItem('✅ Email notifications'),
                  _buildFeatureItem('✅ Vaccination progress tracking'),
                  _buildFeatureItem('✅ Timeline view for mothers'),
                  _buildFeatureItem('✅ Statistics and completion rates'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        feature,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF2E2E2E),
          fontFamily: 'SpotifyCircular',
        ),
      ),
    );
  }
}
