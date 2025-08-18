import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:maternal_health/features/auth/screens/Babymodule/EarProblemTracker.dart';
import 'package:maternal_health/features/auth/screens/Babymodule/ProblemUpdate.dart';
import 'package:maternal_health/features/auth/screens/Babymodule/view_updateRecords.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/thiriposa_management_screen.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/reportConfirmaion.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/midwife_vaccination_screen.dart';
import 'package:flutter/rendering.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? providerData;

  const DashboardScreen({super.key, this.providerData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MidwifeDashboardTab(providerData: widget.providerData),
      const PatientsTab(),
      const AppointmentsTab(),
      const AnalyticsTab(),
      ProfileTab(providerData: widget.providerData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Maternal Care',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Midwife Portal',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4FC3A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Records'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class MidwifeDashboardTab extends StatefulWidget {
  final Map<String, dynamic>? providerData;

  const MidwifeDashboardTab({super.key, this.providerData});

  @override
  State<MidwifeDashboardTab> createState() => _MidwifeDashboardTabState();
}

class _MidwifeDashboardTabState extends State<MidwifeDashboardTab> {
  String pendingReviewCount = '...';
  String thisMonthCount = '...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      // Get provider ID from provider data, fallback to default
      String providerId = 'MID001'; // Default fallback
      if (widget.providerData != null && widget.providerData!['id'] != null) {
        providerId = widget.providerData!['id'].toString();
      }

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/appointments/provider/$providerId/stats',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendingReviewCount = data['pendingReview'].toString();
          thisMonthCount = data['thisMonth'].toString();
          isLoading = false;
        });
      } else {
        setState(() {
          pendingReviewCount = '0';
          thisMonthCount = '0';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      setState(() {
        pendingReviewCount = '0';
        thisMonthCount = '0';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.providerData != null ? (widget.providerData!['providerType'] == 'MIDWIFE' ? 'Mrs. ' : '') + (widget.providerData!['fullName'] ?? 'Midwife') : 'Mrs. Midwife'}!',
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Today\'s Patients',
                    value: '8',
                    icon: Icons.people,
                    color: const Color(0xFF4FC3A1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Pending Review',
                    value: pendingReviewCount,
                    icon: Icons.health_and_safety,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'This Month',
                    value: thisMonthCount,
                    icon: Icons.calendar_month,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'High Priority',
                    value: '1',
                    icon: Icons.priority_high,
                    color: const Color(0xFFF44336),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent Activities
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: const [
                  _ActivityCard(
                    title: 'Prenatal Checkup',
                    subtitle:
                        'Jane Smith - 32 weeks, routine checkup completed',
                    time: '11:00 AM',
                    icon: Icons.medical_services,
                  ),
                  _ActivityCard(
                    title: 'Birth Plan Review',
                    subtitle: 'Maria Garcia - Birth plan discussion scheduled',
                    time: '10:15 AM',
                    icon: Icons.event_note,
                  ),
                  _ActivityCard(
                    title: 'New Patient',
                    subtitle: 'Emma Wilson - First trimester consultation',
                    time: '9:30 AM',
                    icon: Icons.person_add,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D5A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4FC3A1), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class PatientsTab extends StatelessWidget {
  const PatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Records Management',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage patient records and health data',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    context,
                    title: 'Thiriposa Records',
                    subtitle: 'Manage nutrition supplements',
                    icon: Icons.inventory_2,
                    color: const Color(0xFF4FC3A1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ThiriposaManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Ear Problems',
                    subtitle: 'Track baby ear issues',
                    icon: Icons.hearing,
                    color: const Color(0xFF4FC3A1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BabyProblemsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Problem Updates',
                    subtitle: 'Update health issues',
                    icon: Icons.medical_services,
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProblemsManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'View Records',
                    subtitle: 'Browse all records',
                    icon: Icons.folder_open,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewUpdateRecordsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Reports',
                    subtitle: 'Generate reports',
                    icon: Icons.assessment,
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportConfirmationScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Vaccinations',
                    subtitle: 'Manage vaccination records',
                    icon: Icons.vaccines,
                    color: const Color(0xFF8BC34A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MidwifeVaccinationScreen(),
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

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 12,
                  color: Colors.grey[600],
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

// Placeholder classes for AnalyticsTab and ProfileTab to avoid errors
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Growth Chart feature coming soon!'),
              backgroundColor: Color(0xFF4FC3A1),
            ),
          );
        },
        child: const Text(
          'Analytics Tab - Growth Chart (Coming Soon)',
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final Map<String, dynamic>? providerData;

  const ProfileTab({super.key, this.providerData});

  @override
  Widget build(BuildContext context) {
    if (providerData == null) {
      return const Center(
        child: Text(
          'No provider data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'SpotifyCircular',
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3A1), Color(0xFF3DA58A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    providerData!['providerType'] == 'DOCTOR'
                        ? Icons.medical_services
                        : Icons.child_care,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  providerData!['fullName'] ?? 'Healthcare Provider',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  providerData!['providerType'] ?? 'Healthcare Provider',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Professional Information
          _buildInfoSection('Professional Information', [
            _buildInfoRow(
              'Medical License',
              providerData!['medicalLicenseNumber'] ?? 'N/A',
            ),
            _buildInfoRow('Institution', providerData!['institution'] ?? 'N/A'),
            _buildInfoRow(
              'Specialization',
              providerData!['specialization'] ?? 'General',
            ),
            _buildInfoRow(
              'Years of Experience',
              '${providerData!['yearsOfExperience'] ?? 0} years',
            ),
          ]),

          const SizedBox(height: 24),

          // Contact Information
          _buildInfoSection('Contact Information', [
            _buildInfoRow('Email', providerData!['email'] ?? 'N/A'),
            _buildInfoRow('Phone', providerData!['phoneNumber'] ?? 'N/A'),
            _buildInfoRow('NIC Number', providerData!['nicNumber'] ?? 'N/A'),
          ]),

          const SizedBox(height: 24),

          // Account Status
          _buildInfoSection('Account Status', [
            _buildStatusRow(
              'Approval Status',
              providerData!['isApproved'] == true ? 'Approved' : 'Pending',
            ),
            _buildStatusRow(
              'Account Type',
              providerData!['providerType'] ?? 'N/A',
            ),
          ]),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile feature coming soon'),
                        backgroundColor: Color(0xFF4FC3A1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3A1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Implement logout functionality
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4FC3A1),
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(fontFamily: 'SpotifyCircular'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'SpotifyCircular',
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate back to login screen and clear the navigation stack
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'SpotifyCircular',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF4FC3A1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Color(0xFF4FC3A1)),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFF4FC3A1),
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    Color statusColor = value == 'Approved' ? Colors.green : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Your existing AppointmentsTab code here...

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> todayAppointments = [];
  List<Map<String, dynamic>> upcomingAppointments = [];
  List<Map<String, dynamic>> completedAppointments = [];
  List<Map<String, dynamic>> filteredTodayAppointments = [];
  List<Map<String, dynamic>> filteredUpcomingAppointments = [];
  List<Map<String, dynamic>> filteredCompletedAppointments = [];
  bool isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _loadAppointments();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Search functionality
  void _filterAppointments(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTodayAppointments = todayAppointments;
        filteredUpcomingAppointments = upcomingAppointments;
        filteredCompletedAppointments = completedAppointments;
      } else {
        filteredTodayAppointments = todayAppointments
            .where(
              (apt) => apt['motherNic'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
        filteredUpcomingAppointments = upcomingAppointments
            .where(
              (apt) => apt['motherNic'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
        filteredCompletedAppointments = completedAppointments
            .where(
              (apt) => apt['motherNic'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  // Mark appointment as complete
  Future<void> _markAsComplete(Map<String, dynamic> appointment) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://10.0.2.2:8080/api/appointments/${appointment['id']}/complete',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAppointments(); // Refresh the list
      } else {
        throw Exception('Failed to complete appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load today's appointments for midwife
      final todayResponse = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/appointments/provider/MID001/today',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      // Load upcoming appointments (future dates)
      final upcomingResponse = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/appointments/provider/MID001/upcoming',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (todayResponse.statusCode == 200) {
        final List<dynamic> todayData = jsonDecode(todayResponse.body);

        setState(() {
          // Process today's appointments
          todayAppointments = todayData.map((e) {
            final appointment = Map<String, dynamic>.from(e);

            // Debug: Print raw appointment data
            print('Raw today appointment: $appointment');

            // Add priority and type fields for UI enhancement
            appointment['priority'] = appointment['status'] == 'PENDING'
                ? 'high'
                : 'normal';
            appointment['type'] =
                appointment['appointmentType'] ?? 'Routine Checkup';

            // Parse and format the date and time for display
            try {
              if (appointment['appointmentDate'] != null) {
                final DateTime appointmentDateTime = DateTime.parse(
                  appointment['appointmentDate'],
                );
                appointment['date'] =
                    '${appointmentDateTime.day}/${appointmentDateTime.month}/${appointmentDateTime.year}';
                appointment['time'] =
                    appointment['timeSlot'] ??
                    '${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}';
              }
            } catch (e) {
              print('Error parsing appointment date: $e');
              appointment['date'] = 'Unknown Date';
              appointment['time'] = appointment['timeSlot'] ?? 'Unknown Time';
            }

            print('Processed today appointment: $appointment');
            return appointment;
          }).toList();

          // Separate completed appointments
          completedAppointments = todayAppointments
              .where(
                (apt) => apt['status'].toString().toLowerCase() == 'completed',
              )
              .toList();

          // Load upcoming appointments from backend or use mock data
          if (upcomingResponse.statusCode == 200) {
            final List<dynamic> upcomingData = jsonDecode(
              upcomingResponse.body,
            );
            upcomingAppointments = upcomingData.map((e) {
              final appointment = Map<String, dynamic>.from(e);

              // Debug: Print raw appointment data
              print('Raw upcoming appointment: $appointment');

              appointment['priority'] = appointment['status'] == 'PENDING'
                  ? 'high'
                  : 'normal';
              appointment['type'] =
                  appointment['appointmentType'] ?? 'Routine Checkup';

              // Parse and format the date and time for display
              try {
                if (appointment['appointmentDate'] != null) {
                  final DateTime appointmentDateTime = DateTime.parse(
                    appointment['appointmentDate'],
                  );
                  appointment['date'] =
                      '${appointmentDateTime.day}/${appointmentDateTime.month}/${appointmentDateTime.year}';
                  appointment['time'] =
                      appointment['timeSlot'] ??
                      '${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}';
                }
              } catch (e) {
                print('Error parsing appointment date: $e');
                appointment['date'] = 'Unknown Date';
                appointment['time'] = appointment['timeSlot'] ?? 'Unknown Time';
              }

              print('Processed upcoming appointment: $appointment');
              return appointment;
            }).toList();
          } else {
            // No upcoming appointments from backend
            upcomingAppointments = [];
            print(
              'Failed to load upcoming appointments: ${upcomingResponse.statusCode}',
            );
          }

          // Initialize filtered lists
          _filterAppointments(_searchController.text);
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading appointments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FFFE), Color(0xFFE8F5F2), Color(0xFFF0F9F7)],
        ),
      ),
      child: Column(
        children: [
          // Header with stats
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3A1).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointments Overview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'SpotifyCircular',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Manage your patient appointments',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today',
                          '${todayAppointments.length}',
                          Icons.today,
                          Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Upcoming',
                          '${upcomingAppointments.length}',
                          Icons.schedule,
                          Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Completed',
                          '${completedAppointments.length}',
                          Icons.check_circle,
                          Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterAppointments,
              decoration: InputDecoration(
                hintText: 'Search by NIC number...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4FC3A1)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterAppointments('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tab Bar
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              height: 75, // Increased height for better touch experience
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF4FC3A1),
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorPadding: const EdgeInsets.all(
                  4,
                ), // Reduced padding so indicator is bigger
                labelStyle: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                isScrollable: false, // Allow tabs to take equal width
                tabs: [
                  Container(
                    height: 75,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 7,
                    ), // Added padding for content
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.today, size: 20), // Slightly smaller icon
                        SizedBox(height: 4),
                        Text(
                          'Today',
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 75,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 7,
                    ), // Added padding for content
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 20), // Slightly smaller icon
                        SizedBox(height: 4),
                        Text(
                          'Coming',
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 75,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 7,
                    ), // Added padding for content
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                        ), // Slightly smaller icon
                        SizedBox(height: 4),
                        Text(
                          'Done',
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4FC3A1),
                        ),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTodayAppointments(),
                        _buildUpcomingAppointments(),
                        _buildCompletedAppointments(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'SpotifyCircular',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments() {
    if (filteredTodayAppointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No appointments today',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enjoy your free day!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: const Color(0xFF4FC3A1),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTodayAppointments.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildTodayAppointmentCard(
                    filteredTodayAppointments[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTodayAppointmentCard(Map<String, dynamic> appointment) {
    final isPriority = appointment['priority'] == 'high';
    final isCompleted = appointment['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [Colors.green.shade50, Colors.green.shade100]
              : isPriority
              ? [Colors.red.shade50, Colors.red.shade100]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isPriority
            ? Border.all(color: Colors.red.shade200, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [Colors.green, Colors.green.shade600]
                          : isPriority
                          ? [Colors.red, Colors.red.shade600]
                          : [const Color(0xFF4FC3A1), const Color(0xFF66D4B7)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : isPriority
                        ? Icons.priority_high
                        : Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['motherName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SpotifyCircular',
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIC: ${appointment['motherNic']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'HIGH PRIORITY',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment['time'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SpotifyCircular',
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.medical_services,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment['type'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsComplete(appointment),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'Mark Complete',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _rescheduleAppointment(appointment['id']),
                      icon: const Icon(Icons.schedule, size: 18),
                      label: const Text(
                        'Reschedule',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4FC3A1),
                        side: const BorderSide(color: Color(0xFF4FC3A1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    if (filteredUpcomingAppointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No upcoming appointments',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUpcomingAppointments.length,
      itemBuilder: (context, index) {
        return _buildUpcomingAppointmentCard(
          filteredUpcomingAppointments[index],
        );
      },
    );
  }

  Widget _buildUpcomingAppointmentCard(Map<String, dynamic> appointment) {
    final isPending =
        appointment['status']?.toString().toLowerCase() == 'pending';

    // Debug: Print appointment data to see what fields are available
    print('Upcoming appointment data: $appointment');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FFFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['motherName'] ?? 'Unknown Patient',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SpotifyCircular',
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment['date'] ?? 'Unknown Date'} • ${appointment['time'] ?? appointment['timeSlot'] ?? 'Unknown Time'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['type'] ??
                            appointment['appointmentType'] ??
                            'Consultation',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4FC3A1),
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsComplete(appointment),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text(
                        'Mark Complete',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedAppointments() {
    if (filteredCompletedAppointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No completed appointments',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCompletedAppointments.length,
      itemBuilder: (context, index) {
        return _buildCompletedAppointmentCard(
          filteredCompletedAppointments[index],
        );
      },
    );
  }

  Widget _buildCompletedAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['motherName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SpotifyCircular',
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment['date']} • ${appointment['time']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['type'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w500,
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
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ),
              ],
            ),
            if (appointment['notes'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['notes'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _rescheduleAppointment(String appointmentId) {
    // Handle reschedule logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reschedule functionality will be implemented',
          style: TextStyle(fontFamily: 'SpotifyCircular'),
        ),
        backgroundColor: Color(0xFF4FC3A1),
      ),
    );
  }
}
