import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:maternal_health/features/auth/screens/Babymodule/ProblemUpdate.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/thiriposa_management_screen.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/reportConfirmaion.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/growth_data_input_screen.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/vaccination_management_screen.dart';
import 'package:maternal_health/features/auth/screens/Midwivesmodule/view_mothers_records_screen.dart';
import 'package:maternal_health/features/midwife/screens/all_mothers_records_screen.dart';
import 'package:maternal_health/services/user_service.dart';
import 'package:maternal_health/config/api_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

//I am BATMAN
//dashboard screen
class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MidwifeDashboardTab(),
    const PatientsTab(), // Updated PatientsTab with buttons
    const AppointmentsTab(),
    const AnalyticsTab(),
    const ProfileTab(),
  ];

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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontFamily: 'SpotifyCircular', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
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
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                ); // Navigate to login and clear stack
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
        );
      },
    );
  }
}

class MidwifeDashboardTab extends StatefulWidget {
  const MidwifeDashboardTab({super.key});

  @override
  State<MidwifeDashboardTab> createState() => _MidwifeDashboardTabState();
}

class _MidwifeDashboardTabState extends State<MidwifeDashboardTab> {
  String pendingReviewCount = '...';
  String thisMonthCount = '...';
  String todayPatientsCount = '...';
  String highPriorityCount = '...';
  bool isLoading = true;
  Map<String, dynamic>? midwifeProfile;
  List<Map<String, dynamic>> recentActivities = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMidwifeData();
  }

  Future<void> _loadMidwifeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await Future.wait([
      _fetchMidwifeProfile(),
      _fetchStatistics(),
      _fetchRecentActivities(),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchMidwifeProfile() async {
    try {
      final userData = await UserService.getUserData();
      final currentIdentifier = userData['nic'];

      if (currentIdentifier == null || currentIdentifier.isEmpty) {
        print('No user identifier found');
        return;
      }

      final profileUrl =
          '${ApiConfig.baseApiUrl}/healthcare/profile/$currentIdentifier';
      print('Fetching midwife profile from: $profileUrl');

      final response = await http
          .get(Uri.parse(profileUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Debug: Profile response data structure: $data'); // Debug log
        if (data['success'] == true) {
          setState(() {
            midwifeProfile = data;
          });
          print('Midwife profile loaded successfully');
          print('Debug: Stored midwife profile: $midwifeProfile'); // Debug log
        }
      }
    } catch (e) {
      print('Error fetching midwife profile: $e');
    }
  }

  Future<void> _fetchStatistics() async {
    if (!mounted) return;

    try {
      // Get current midwife's identifier
      final userData = await UserService.getUserData();
      final currentIdentifier = userData['nic'];

      if (currentIdentifier == null || currentIdentifier.isEmpty) {
        throw Exception('No midwife identifier found');
      }

      // Use the correct API endpoint with updated IP
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseApiUrl}/appointments/provider/$currentIdentifier/stats',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;

        setState(() {
          pendingReviewCount = (data['pendingReview'] ?? 0).toString();
          thisMonthCount = (data['thisMonth'] ?? 0).toString();
          todayPatientsCount = (data['todayPatients'] ?? 0).toString();
          highPriorityCount = (data['highPriority'] ?? 0).toString();
        });
      } else {
        if (!mounted) return;

        setState(() {
          pendingReviewCount = '0';
          thisMonthCount = '0';
          todayPatientsCount = '0';
          highPriorityCount = '0';
        });
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      if (!mounted) return;

      setState(() {
        pendingReviewCount = '0';
        thisMonthCount = '0';
        todayPatientsCount = '0';
        highPriorityCount = '0';
      });
    }
  }

  Future<void> _fetchRecentActivities() async {
    if (!mounted) return;

    try {
      // Get current midwife's identifier
      final userData = await UserService.getUserData();
      final currentIdentifier =
          userData['medicalLicenseNumber'] ?? userData['nic'];

      if (currentIdentifier == null || currentIdentifier.isEmpty) {
        return;
      }

      // Get today's appointments as recent activities
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseApiUrl}/appointments/provider/$currentIdentifier/recent',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            recentActivities = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      print('Error fetching recent activities: $e');
      // Keep empty list if API fails
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
            // Dynamic welcome message based on actual midwife profile
            Text(
              _getWelcomeMessage(),
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 20),

            // Show loading indicator while fetching data
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4FC3A1),
                    ),
                  ),
                ),
              )
            else if (errorMessage?.isNotEmpty == true)
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load dashboard data',
                      style: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadMidwifeData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3A1),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Debug Information'),
                            content: Text(errorMessage ?? 'Unknown error'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Show Details'),
                    ),
                  ],
                ),
              )
            else ...[
              // Statistics Cards with real data
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Today\'s Patients',
                      value: todayPatientsCount,
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
                      value: highPriorityCount,
                      icon: Icons.priority_high,
                      color: const Color(0xFFF44336),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Recent Activities with real data
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

              Expanded(child: _buildRecentActivitiesList()),
            ],
          ],
        ),
      ),
    );
  }

  // Get personalized welcome message
  String _getWelcomeMessage() {
    // Try to get name from midwife profile first
    if (midwifeProfile != null) {
      // Try different possible structures for the name
      String? fullName;

      // Check if there's a direct fullName field
      if (midwifeProfile!['fullName'] != null) {
        fullName = midwifeProfile!['fullName'];
      }
      // Check if there's a user object with name fields
      else if (midwifeProfile!['user'] != null) {
        String firstName = midwifeProfile!['user']['firstName'] ?? '';
        String lastName = midwifeProfile!['user']['lastName'] ?? '';
        fullName = '$firstName $lastName'.trim();
      }
      // Check if there are direct firstName/lastName fields
      else if (midwifeProfile!['firstName'] != null ||
          midwifeProfile!['lastName'] != null) {
        String firstName = midwifeProfile!['firstName'] ?? '';
        String lastName = midwifeProfile!['lastName'] ?? '';
        fullName = '$firstName $lastName'.trim();
      }

      if (fullName != null && fullName.isNotEmpty) {
        return 'Welcome, $fullName!';
      }
    }

    // If no profile data available, return a generic welcome
    return 'Welcome, Midwife!';
  }

  // Build recent activities list with real data
  Widget _buildRecentActivitiesList() {
    if (recentActivities.isEmpty) {
      return const Center(
        child: Text(
          'No recent activities',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: recentActivities.length,
      itemBuilder: (context, index) {
        final activity = recentActivities[index];
        return _ActivityCard(
          title: activity['title'] ?? 'Activity',
          subtitle: activity['description'] ?? 'No description',
          time: activity['time'] ?? '',
          icon: _getActivityIcon(activity['type']),
        );
      },
    );
  }

  // Get appropriate icon for activity type
  IconData _getActivityIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'checkup':
      case 'consultation':
        return Icons.medical_services;
      case 'appointment':
        return Icons.event_note;
      case 'patient':
      case 'registration':
        return Icons.person_add;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.health_and_safety;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final dynamic value; // Changed to dynamic to accept both String and int
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
            value.toString(), // Convert value to string
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
                    title: 'Eye and Ear Records',
                    subtitle: 'Track baby eye and ear issues',
                    icon: Icons.visibility,
                    color: const Color(0xFF4FC3A1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllMothersRecordsScreen(),
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
                    subtitle: 'Browse all mothers records',
                    icon: Icons.folder_open,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewMothersRecordsScreen(),
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
                    title: 'Vaccination Management',
                    subtitle: 'Manage baby vaccinations',
                    icon: Icons.vaccines,
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VaccinationManagementScreen(),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 11,
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
class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  List<Map<String, dynamic>> mothers = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMothers();
  }

  Future<void> _loadMothers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseApiUrl}/user/mothers'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Debug: Mothers API response status: ${response.statusCode}');
      print('Debug: Mothers API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            mothers = List<Map<String, dynamic>>.from(data['mothers']);
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load mothers');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading mothers: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredMothers {
    if (searchQuery.isEmpty) return mothers;
    return mothers.where((mother) {
      final name = mother['fullName']?.toString().toLowerCase() ?? '';
      final nic = mother['nicNumber']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || nic.contains(query);
    }).toList();
  }

  void _openGrowthDataInput(Map<String, dynamic> mother) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GrowthDataInputScreen(
          motherName: mother['fullName'],
          motherNic: mother['nicNumber'],
        ),
      ),
    );
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
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
                          Icons.analytics,
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
                              'Growth Analytics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'SpotifyCircular',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Track baby growth and generate charts',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.people,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${mothers.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                              const Text(
                                'Registered',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.show_chart,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${filteredMothers.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                              const Text(
                                'Filtered',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
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
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search mothers by name or NIC...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF4FC3A1),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => searchQuery = ''),
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

            // Content area
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4FC3A1),
                        ),
                      ),
                    )
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading mothers',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontFamily: 'SpotifyCircular',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'SpotifyCircular',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadMothers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : filteredMothers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No mothers found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontFamily: 'SpotifyCircular',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your search criteria',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMothers,
                      color: const Color(0xFF4FC3A1),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredMothers.length,
                        itemBuilder: (context, index) {
                          final mother = filteredMothers[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4FC3A1),
                                      Color(0xFF66D4B7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                mother['fullName'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontFamily: 'SpotifyCircular',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D5A),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'NIC: ${mother['nicNumber'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontFamily: 'SpotifyCircular',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (mother['email'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      mother['email'],
                                      style: TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: () => _openGrowthDataInput(mother),
                                icon: const Icon(Icons.add_chart, size: 18),
                                label: const Text(
                                  'Add Growth',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4FC3A1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Get current user's identifier from local storage
      final userData = await UserService.getUserData();
      final currentIdentifier =
          userData['nic']; // This might be NIC or medical license number for healthcare providers

      print('Debug: Current user identifier: $currentIdentifier'); // Debug log
      print('Debug: User data: $userData'); // Debug all user data

      if (currentIdentifier == null || currentIdentifier.isEmpty) {
        throw Exception('User not logged in or no identifier found');
      }

      // Try to load profile with the stored identifier
      final profileLoaded = await _attemptProfileLoad(currentIdentifier);

      if (!profileLoaded) {
        // If profile loading failed, it might be because we need to use medical license number
        // For now, show a more helpful error message
        throw Exception(
          'Unable to load profile. Please log out and log in again to refresh your session.',
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<bool> _attemptProfileLoad(String identifier) async {
    try {
      // Use the centralized API configuration for consistent IP address
      final profileUrl =
          '${ApiConfig.baseApiUrl}/healthcare/profile/$identifier';
      print(
        'Debug: Fetching healthcare provider profile from: $profileUrl',
      ); // Debug log

      final response = await http
          .get(
            Uri.parse(profileUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15)); // Add timeout

      print('Debug: Response status: ${response.statusCode}'); // Debug log
      print('Debug: Response headers: ${response.headers}'); // Debug headers
      print('Debug: Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Debug: Parsed response data: $data'); // Debug parsed data

          if (data is Map<String, dynamic>) {
            if (data['success'] == true) {
              setState(() {
                userProfile = data;
                isLoading = false;
              });
              print('Debug: Profile loaded successfully'); // Debug success
              return true;
            } else {
              final errorMsg =
                  data['error'] ?? data['message'] ?? 'Failed to load profile';
              throw Exception(errorMsg);
            }
          } else {
            throw Exception('Invalid response format: Expected JSON object');
          }
        } catch (jsonError) {
          print('Debug: JSON parsing error: $jsonError');
          throw Exception(
            'Failed to parse server response: ${jsonError.toString()}',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception(
          'Profile not found. Please check your account details or contact support.',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      } else {
        throw Exception(
          'Failed to load profile. Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } on TimeoutException {
      print('Debug: Request timed out');
      setState(() {
        isLoading = false;
        errorMessage =
            'Request timed out. Please check your internet connection and try again.';
      });
      return false;
    } on SocketException catch (e) {
      print('Debug: Socket exception: $e');
      setState(() {
        isLoading = false;
        errorMessage =
            'No internet connection. Please check your network and try again.';
      });
      return false;
    } on FormatException catch (e) {
      print('Debug: Format exception: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Invalid response from server. Please try again.';
      });
      return false;
    } catch (e) {
      print('Debug: Profile load attempt failed: $e');
      rethrow; // Re-throw the exception to be handled by the calling method
    }
  }

  // Show debug information to help troubleshoot profile loading issues
  Future<void> _showDebugInfo() async {
    final userData = await UserService.getUserData();
    final profileUrl =
        '${ApiConfig.baseApiUrl}/healthcare/profile/${userData['nic']}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Debug Information',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'User Data:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('NIC/ID: ${userData['nic'] ?? 'Not found'}'),
                Text('Name: ${userData['name'] ?? 'Not found'}'),
                Text('Email: ${userData['email'] ?? 'Not found'}'),
                const SizedBox(height: 16),
                Text(
                  'API Configuration:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Server IP: ${ApiConfig.serverIp}'),
                Text('Server Port: ${ApiConfig.serverPort}'),
                Text('Base URL: ${ApiConfig.baseApiUrl}'),
                const SizedBox(height: 16),
                Text(
                  'Profile URL:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SelectableText(
                  profileUrl,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Troubleshooting Tips:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Check if you are connected to the correct network\n'
                  '• Verify server is running on the specified IP\n'
                  '• Try logging out and logging in again\n'
                  '• Contact support if issue persists',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadCurrentUserProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3A1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
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
            const Text(
              'My Profile',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your professional information and account details',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4FC3A1),
                    ),
                  ),
                ),
              )
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load profile',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'SpotifyCircular',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _loadCurrentUserProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: _showDebugInfo,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4FC3A1),
                              side: const BorderSide(color: Color(0xFF4FC3A1)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Debug Info'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else if (userProfile != null)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadCurrentUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 16),
                        _buildAccountSettingsCard(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3A1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF4FC3A1),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile!['fullName'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D5A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3A1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userProfile!['userRole'] ?? 'Healthcare Provider',
                          style: const TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4FC3A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact Information
            _buildSectionTitle('Contact Information'),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.email,
              'Email',
              userProfile!['email'] ?? 'Not provided',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.phone,
              'Phone',
              userProfile!['phoneNumber'] ?? 'Not provided',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.credit_card,
              'NIC Number',
              userProfile!['nicNumber'] ?? 'Not provided',
            ),

            // Professional Information (for healthcare providers)
            if (userProfile!['medicalLicenseNumber'] != null &&
                userProfile!['medicalLicenseNumber'].toString().isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionTitle('Professional Information'),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.badge,
                'Medical License',
                userProfile!['medicalLicenseNumber'],
              ),
              if (userProfile!['institution'] != null &&
                  userProfile!['institution'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.business,
                  'Institution',
                  userProfile!['institution'],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Account Settings'),
            const SizedBox(height: 16),

            _buildSettingsOption(
              Icons.edit,
              'Edit Profile',
              'Update your personal information',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile feature coming soon!'),
                    backgroundColor: Color(0xFF4FC3A1),
                  ),
                );
              },
            ),

            const Divider(height: 24),

            _buildSettingsOption(
              Icons.lock,
              'Change Password',
              'Update your account password',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password feature coming soon!'),
                    backgroundColor: Color(0xFF4FC3A1),
                  ),
                );
              },
            ),

            const Divider(height: 24),

            _buildSettingsOption(
              Icons.notifications,
              'Notifications',
              'Manage notification preferences',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings coming soon!'),
                    backgroundColor: Color(0xFF4FC3A1),
                  ),
                );
              },
            ),

            const Divider(height: 24),

            _buildSettingsOption(
              Icons.logout,
              'Logout',
              'Sign out of your account',
              () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'SpotifyCircular',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E7D5A),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  color: Color(0xFF2E7D5A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF4FC3A1)),
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
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D5A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontFamily: 'SpotifyCircular'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear user data
                await UserService.clearUserData();
                // Navigate to login screen
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontFamily: 'SpotifyCircular'),
              ),
            ),
          ],
        );
      },
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
      final appointmentId = appointment['id'];
      if (appointmentId == null) {
        throw Exception('Appointment ID not found');
      }

      print('Debug: Marking appointment as complete: $appointmentId');

      // Use centralized API configuration
      final completeUrl =
          '${ApiConfig.baseApiUrl}/appointments/$appointmentId/complete';
      print('Debug: Complete appointment URL: $completeUrl');

      final response = await http
          .put(
            Uri.parse(completeUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print(
        'Debug: Complete appointment response status: ${response.statusCode}',
      );
      print('Debug: Complete appointment response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the appointments list
        await _loadAppointments();
      } else {
        final errorMessage = response.statusCode == 404
            ? 'Appointment not found'
            : 'Failed to complete appointment (${response.statusCode})';
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      print('Debug: Mark complete request timed out');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request timed out. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    } on SocketException {
      print('Debug: No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please check your network.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error completing appointment: $e');
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
      // Get current midwife's identifier from local storage
      final userData = await UserService.getUserData();
      final currentIdentifier =
          userData['nic']; // This is the midwife's identifier

      print('Debug: Loading appointments for midwife: $currentIdentifier');

      if (currentIdentifier == null || currentIdentifier.isEmpty) {
        throw Exception('Midwife identifier not found. Please log in again.');
      }

      // Use centralized API configuration and proper endpoints
      final todayUrl =
          '${ApiConfig.baseApiUrl}/appointments/provider/$currentIdentifier/today';
      final upcomingUrl =
          '${ApiConfig.baseApiUrl}/appointments/provider/$currentIdentifier/upcoming';

      print('Debug: Today appointments URL: $todayUrl');
      print('Debug: Upcoming appointments URL: $upcomingUrl');

      // Load today's appointments for midwife with timeout
      final todayResponse = await http
          .get(
            Uri.parse(todayUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Debug: Today response status: ${todayResponse.statusCode}');
      print('Debug: Today response body: ${todayResponse.body}');

      // Initialize lists
      List<Map<String, dynamic>> allTodayAppointments = [];
      List<Map<String, dynamic>> allUpcomingAppointments = [];

      // Process today's appointments
      if (todayResponse.statusCode == 200) {
        try {
          final responseData = jsonDecode(todayResponse.body);
          List<dynamic> todayData;

          // Handle different response formats
          if (responseData is Map && responseData['appointments'] != null) {
            todayData = responseData['appointments'];
          } else if (responseData is Map && responseData['data'] != null) {
            todayData = responseData['data'];
          } else if (responseData is List) {
            todayData = responseData;
          } else {
            todayData = [];
            print('Debug: Unexpected today response format: $responseData');
          }

          allTodayAppointments = todayData.map((e) {
            final appointment = Map<String, dynamic>.from(e);
            return _processAppointmentData(appointment);
          }).toList();

          print(
            'Debug: Processed ${allTodayAppointments.length} today appointments',
          );
        } catch (e) {
          print('Debug: Error parsing today appointments: $e');
          allTodayAppointments = [];
        }
      } else if (todayResponse.statusCode == 404) {
        print('Debug: No today appointments found (404)');
        allTodayAppointments = [];
      } else {
        print(
          'Debug: Today appointments request failed: ${todayResponse.statusCode}',
        );
        allTodayAppointments = [];
      }

      // Load upcoming appointments with timeout
      try {
        final upcomingResponse = await http
            .get(
              Uri.parse(upcomingUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));

        print(
          'Debug: Upcoming response status: ${upcomingResponse.statusCode}',
        );
        print('Debug: Upcoming response body: ${upcomingResponse.body}');

        if (upcomingResponse.statusCode == 200) {
          try {
            final responseData = jsonDecode(upcomingResponse.body);
            List<dynamic> upcomingData;

            // Handle different response formats
            if (responseData is Map && responseData['appointments'] != null) {
              upcomingData = responseData['appointments'];
            } else if (responseData is Map && responseData['data'] != null) {
              upcomingData = responseData['data'];
            } else if (responseData is List) {
              upcomingData = responseData;
            } else {
              upcomingData = [];
              print(
                'Debug: Unexpected upcoming response format: $responseData',
              );
            }

            allUpcomingAppointments = upcomingData.map((e) {
              final appointment = Map<String, dynamic>.from(e);
              return _processAppointmentData(appointment);
            }).toList();

            print(
              'Debug: Processed ${allUpcomingAppointments.length} upcoming appointments',
            );
          } catch (e) {
            print('Debug: Error parsing upcoming appointments: $e');
            allUpcomingAppointments = [];
          }
        } else if (upcomingResponse.statusCode == 404) {
          print('Debug: No upcoming appointments found (404)');
          allUpcomingAppointments = [];
        } else {
          print(
            'Debug: Upcoming appointments request failed: ${upcomingResponse.statusCode}',
          );
          allUpcomingAppointments = [];
        }
      } catch (e) {
        print('Debug: Error loading upcoming appointments: $e');
        allUpcomingAppointments = [];
      }

      // Update state with loaded data
      setState(() {
        todayAppointments = allTodayAppointments;
        upcomingAppointments = allUpcomingAppointments;

        // Separate completed appointments from today's appointments
        completedAppointments = todayAppointments
            .where(
              (apt) => apt['status'].toString().toLowerCase() == 'completed',
            )
            .toList();

        // Initialize filtered lists
        _filterAppointments(_searchController.text);
      });

      print(
        'Debug: Final counts - Today: ${todayAppointments.length}, Upcoming: ${upcomingAppointments.length}, Completed: ${completedAppointments.length}',
      );
    } on TimeoutException {
      print('Debug: Appointments request timed out');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request timed out. Please check your connection and try again.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } on SocketException {
      print('Debug: No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please check your network.'),
          backgroundColor: Colors.red,
        ),
      );
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

  // Helper method to process appointment data consistently
  Map<String, dynamic> _processAppointmentData(
    Map<String, dynamic> appointment,
  ) {
    // Debug: Print raw appointment data
    print('Processing appointment: $appointment');

    // Add priority and type fields for UI enhancement
    appointment['priority'] = appointment['status'] == 'PENDING'
        ? 'high'
        : 'normal';
    appointment['type'] = appointment['appointmentType'] ?? 'Routine Checkup';

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

    print('Processed appointment: $appointment');
    return appointment;
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
