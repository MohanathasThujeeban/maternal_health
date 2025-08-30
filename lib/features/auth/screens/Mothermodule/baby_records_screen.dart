import 'package:flutter/material.dart';
import 'package:maternal_health/features/auth/screens/Mothermodule/vaccination_history_screen.dart';
import 'package:maternal_health/features/thiriposa/thiriposa_records_screen.dart';
import 'package:maternal_health/features/auth/screens/Mothermodule/comprehensive_records_screen.dart';

class BabyRecordsScreen extends StatelessWidget {
  const BabyRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Baby Records',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          flexibleSpace: ClipPath(
            clipper: AppBarClipper(),
            child: Container(color: const Color(0xFF4FC3A1)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Comprehensive Records Button - Featured
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComprehensiveRecordsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.description, size: 28),
                label: const Text(
                  'View All Records & Generate PDF',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
              ),
            ),

            // Section Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Individual Record Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grid for individual record types
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildRecordCard(
                    context,
                    icon: Icons.vaccines,
                    title: 'Vaccination Records',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VaccinationHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildRecordCard(
                    context,
                    icon: Icons.child_care,
                    title: 'Growth Records',
                    onTap: () {
                      // Navigate to growth records (individual view)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Use "View All Records" for complete data',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildRecordCard(
                    context,
                    icon: Icons.visibility,
                    title: 'Eye & Ear Records',
                    onTap: () {
                      // Navigate to eye/ear records (individual view)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Use "View All Records" for complete data',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildRecordCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Thiriposa Records',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThiriposaRecordsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildRecordCard(
                    context,
                    icon: Icons.note_alt,
                    title: 'Doctor Notes',
                    onTap: () {
                      // Navigate to doctor notes (individual view)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Use "View All Records" for complete data',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildRecordCard(
                    context,
                    icon: Icons.medical_services,
                    title: 'Health Check-ups',
                    onTap: () {
                      // Navigate to health check-ups
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Use "View All Records" for complete data',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Box type card widget for each record type
  Widget _buildRecordCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final Color baseColor;
    switch (title) {
      case 'Growth Records':
        baseColor = const Color(0xFFFF9800);
        break;
      case 'Health Check-ups':
        baseColor = const Color(0xFF2196F3);
        break;
      case 'Development Milestones':
        baseColor = const Color(0xFF9C27B0);
        break;
      default:
        baseColor = const Color(0xFF4FC3A1);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // PatientsTab-like soft gradient fill
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withOpacity(0.10),
                baseColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Colored icon chip (like PatientsTab)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: baseColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Unique curved AppBar shape
class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
