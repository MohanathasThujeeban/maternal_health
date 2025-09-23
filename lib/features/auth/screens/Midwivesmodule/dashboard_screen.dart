import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:maternal_health/features/midwife/screens/midwife_thiriposa_records_screen.dart';
import 'package:maternal_health/features/midwife/screens/midwife_vaccinations_screen.dart';
import 'package:maternal_health/features/midwife/screens/all_mothers_records_screen.dart';
import 'package:maternal_health/features/midwife/screens/midwife_mother_selection_screen.dart';
import 'package:maternal_health/services/user_service.dart';
import 'package:maternal_health/services/activity_service.dart';
import 'package:maternal_health/services/mothers_service.dart';
import 'package:maternal_health/config/api_config.dart';
import '../shared/healthcare_provider_privacy_screen.dart';
import 'pregnant_mothers_list_screen.dart';

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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
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
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Midwife Portal',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 8,
        shadowColor: const Color(0xFF4FC3A1).withOpacity(0.3),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4FC3A1), Color(0xFF3BA889), Color(0xFF2E8B71)],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // Handle notifications
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4FC3A1),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          iconSize: 24,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? const Color(0xFF4FC3A1).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 0
                      ? Icons.dashboard
                      : Icons.dashboard_outlined,
                  color: _selectedIndex == 0
                      ? const Color(0xFF4FC3A1)
                      : Colors.grey[600],
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? const Color(0xFF4FC3A1).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 1 ? Icons.people : Icons.people_outline,
                  color: _selectedIndex == 1
                      ? const Color(0xFF4FC3A1)
                      : Colors.grey[600],
                ),
              ),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? const Color(0xFF4FC3A1).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 2
                      ? Icons.calendar_today
                      : Icons.calendar_today_outlined,
                  color: _selectedIndex == 2
                      ? const Color(0xFF4FC3A1)
                      : Colors.grey[600],
                ),
              ),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 3
                      ? const Color(0xFF4FC3A1).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 3
                      ? Icons.analytics
                      : Icons.analytics_outlined,
                  color: _selectedIndex == 3
                      ? const Color(0xFF4FC3A1)
                      : Colors.grey[600],
                ),
              ),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 4
                      ? const Color(0xFF4FC3A1).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 4 ? Icons.person : Icons.person_outline,
                  color: _selectedIndex == 4
                      ? const Color(0xFF4FC3A1)
                      : Colors.grey[600],
                ),
              ),
              label: 'Profile',
            ),
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
      // Use the new ActivityService to get recent activities
      final activities = await ActivityService.getRecentActivities(limit: 15);

      if (mounted) {
        setState(() {
          recentActivities = activities;
        });
      }
    } catch (e) {
      print('Error fetching recent activities: $e');
      // Keep empty list if API fails
      if (mounted) {
        setState(() {
          recentActivities = [];
        });
      }
    }
  }

  // Method to refresh activities - can be called from other screens
  void refreshActivities() {
    _fetchRecentActivities();
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
          time: ActivityService.formatActivityTime(
            activity['timestamp'] ?? activity['time'] ?? '',
          ),
          icon: _getActivityIcon(activity['activityType'] ?? activity['type']),
        );
      },
    );
  }

  // Get appropriate icon for activity type
  IconData _getActivityIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines;
      case 'thiriposa':
        return Icons.local_dining;
      case 'growth':
        return Icons.trending_up;
      case 'appointment':
        return Icons.event_note;
      case 'eye_ear':
        return Icons.visibility;
      case 'checkup':
      case 'consultation':
        return Icons.medical_services;
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
                padding: const EdgeInsets.only(bottom: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Slightly taller tiles to reduce chance of overflow on small devices
                childAspectRatio: 1.0,
                children: [
                  _buildActionCard(
                    context,
                    title: 'Growth Records',
                    subtitle: 'Track baby growth and generate charts',
                    icon: Icons.trending_up,
                    color: const Color(0xFF4FC3A1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GrowthRecordsManagementScreen(),
                        ),
                      );
                    },
                  ),
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
                          builder: (_) => const MidwifeThiriposaRecordsScreen(),
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
                    title: 'View Records',
                    subtitle:
                        'Select mother to view baby health records & export PDF',
                    icon: Icons.folder_open,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MidwifeMotherSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Vaccination Records',
                    subtitle: 'View baby vaccination records',
                    icon: Icons.vaccines,
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MidwifeVaccinationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Pregnant Mother\'s Records',
                    subtitle: 'Manage pregnancy records, weight, and health',
                    icon: Icons.pregnant_woman,
                    color: const Color(0xFF4FC3A1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PregnantMothersListScreen(),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxHeight < 140;
              final titleSize = isTight ? 12.0 : 13.0;
              final subtitleSize = isTight ? 10.0 : 11.0;
              final topGap = isTight ? 8.0 : 12.0;
              final midGap = isTight ? 2.0 : 4.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  SizedBox(height: topGap),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D5A),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: midGap),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: subtitleSize,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// RecordsTab - The new records management tab with Growth Records functionality
class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
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
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, size: 64, color: Color(0xFF4FC3A1)),
              SizedBox(height: 16),
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D5A),
                  fontFamily: 'SpotifyCircular',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Analytics features coming soon',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
            ],
          ),
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
            _buildSectionTitle('Professional Information'),
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

            // Professional Information (for healthcare providers)
            if (userProfile!['medicalLicenseNumber'] != null &&
                userProfile!['medicalLicenseNumber'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
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
              Icons.lock,
              'Privacy & Security',
              'Change password and security settings',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthcareProviderPrivacyScreen(
                      userRole: 'MIDWIFE',
                    ),
                  ),
                );
              },
            ),

            const Divider(height: 24),

            _buildSettingsOption(
              Icons.edit,
              'Edit Profile',
              'Update your professional information',
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

class GrowthRecordsManagementScreen extends StatefulWidget {
  const GrowthRecordsManagementScreen({super.key});

  @override
  State<GrowthRecordsManagementScreen> createState() =>
      _GrowthRecordsManagementScreenState();
}

class _GrowthRecordsManagementScreenState
    extends State<GrowthRecordsManagementScreen> {
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
      // Use MothersService to fetch all registered mothers
      final mothersData = await MothersService.getAllMothers();

      setState(() {
        mothers = mothersData;
        isLoading = false;
      });

      print('Successfully loaded ${mothers.length} mothers');
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

  void _viewGrowthRecords(Map<String, dynamic> mother) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BabyGrowthRecordsScreen(motherData: mother),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Growth Records Management',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
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
                          Icons.trending_up,
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
                              'Growth Records',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'SpotifyCircular',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Select a mother to view and manage baby growth records',
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
                                'Registered Mothers',
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
                                'Filtered Results',
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
                          const Text(
                            'Error loading mothers',
                            style: TextStyle(
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
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
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
                                    style: const TextStyle(
                                      fontFamily: 'SpotifyCircular',
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (mother['email'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      mother['email'],
                                      style: const TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4FC3A1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'View Growth',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'SpotifyCircular',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: () {
                                _viewGrowthRecords(mother);
                              },
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

// Baby Growth Records Screen
class BabyGrowthRecordsScreen extends StatefulWidget {
  final Map<String, dynamic> motherData;

  const BabyGrowthRecordsScreen({super.key, required this.motherData});

  @override
  State<BabyGrowthRecordsScreen> createState() =>
      _BabyGrowthRecordsScreenState();
}

class _BabyGrowthRecordsScreenState extends State<BabyGrowthRecordsScreen> {
  List<Map<String, dynamic>> babies = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMothersBabies();
  }

  Future<void> _loadMothersBabies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch babies for this mother
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseApiUrl}/babies/mother/${widget.motherData['nicNumber']}',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            babies = data
                .map((baby) => Map<String, dynamic>.from(baby))
                .toList();
            isLoading = false;
          });
        } else if (data is Map && data['babies'] != null) {
          setState(() {
            babies = (data['babies'] as List)
                .map((baby) => Map<String, dynamic>.from(baby))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        // No babies found for this mother
        setState(() {
          babies = [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load babies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading babies: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _addGrowthRecord(Map<String, dynamic> baby) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGrowthRecordScreen(
          motherData: widget.motherData,
          babyData: baby,
        ),
      ),
    ).then((_) {
      // Refresh the babies list when returning from add growth record screen
      _loadMothersBabies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.motherData['fullName']} - Baby Growth Records',
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
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
                          Icons.child_care,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mother: ${widget.motherData['fullName']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'SpotifyCircular',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'NIC: ${widget.motherData['nicNumber']}',
                              style: const TextStyle(
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
                                Icons.child_friendly,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${babies.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                              const Text(
                                'Babies',
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
                          const Text(
                            'Error loading babies',
                            style: TextStyle(
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
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'SpotifyCircular',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadMothersBabies,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : babies.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.child_care, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No babies found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontFamily: 'SpotifyCircular',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This mother has no registered babies yet',
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
                      onRefresh: _loadMothersBabies,
                      color: const Color(0xFF4FC3A1),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: babies.length,
                        itemBuilder: (context, index) {
                          final baby = babies[index];
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
                                  Icons.child_care,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                baby['name'] ??
                                    baby['babyName'] ??
                                    baby['fullName'] ??
                                    'Baby ${index + 1}',
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
                                  if (baby['dateOfBirth'] != null)
                                    Text(
                                      'DOB: ${baby['dateOfBirth']}',
                                      style: const TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (baby['gender'] != null)
                                    Text(
                                      'Gender: ${baby['gender']}',
                                      style: const TextStyle(
                                        fontFamily: 'SpotifyCircular',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4FC3A1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Add Growth Record',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'SpotifyCircular',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: () {
                                _addGrowthRecord(baby);
                              },
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

// Add Growth Record Screen
class AddGrowthRecordScreen extends StatefulWidget {
  final Map<String, dynamic> motherData;
  final Map<String, dynamic> babyData;

  const AddGrowthRecordScreen({
    super.key,
    required this.motherData,
    required this.babyData,
  });

  @override
  State<AddGrowthRecordScreen> createState() => _AddGrowthRecordScreenState();
}

class _AddGrowthRecordScreenState extends State<AddGrowthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4FC3A1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveGrowthRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final growthData = {
        'babyId': widget.babyData['id'] ?? widget.babyData['babyId'],
        'motherNic': widget.motherData['nicNumber'],
        'height': double.parse(_heightController.text),
        'weight': double.parse(_weightController.text),
        'date': _selectedDate.toIso8601String().split(
          'T',
        )[0], // YYYY-MM-DD format
        'midwifeLicense':
            'MW001', // You can get this from UserService if needed
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseApiUrl}/growth/add'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(growthData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Growth record saved successfully for ${widget.babyData['name'] ?? widget.babyData['babyName'] ?? widget.babyData['fullName'] ?? 'Baby'}!',
              style: const TextStyle(fontFamily: 'SpotifyCircular'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to babies list
      } else {
        throw Exception('Failed to save growth record: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving growth record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving growth record: $e',
            style: const TextStyle(fontFamily: 'SpotifyCircular'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Growth Record - ${widget.babyData['name'] ?? widget.babyData['babyName'] ?? widget.babyData['fullName'] ?? 'Baby'}',
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baby Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4FC3A1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.child_care,
                              color: Color(0xFF4FC3A1),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.babyData['name'] ??
                                      widget.babyData['babyName'] ??
                                      widget.babyData['fullName'] ??
                                      'Baby',
                                  style: const TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D5A),
                                  ),
                                ),
                                Text(
                                  'Mother: ${widget.motherData['fullName']}',
                                  style: const TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (widget.babyData['dateOfBirth'] != null)
                                  Text(
                                    'DOB: ${widget.babyData['dateOfBirth']}',
                                    style: const TextStyle(
                                      fontFamily: 'SpotifyCircular',
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Growth Record Form
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Growth Measurements',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D5A),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Height Field
                      TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Height (cm)',
                          hintText: 'Enter height in centimeters',
                          prefixIcon: const Icon(
                            Icons.height,
                            color: Color(0xFF4FC3A1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4FC3A1),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter height';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final height = double.parse(value);
                          if (height <= 0 || height > 200) {
                            return 'Please enter a valid height (1-200 cm)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Weight Field
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          hintText: 'Enter weight in kilograms',
                          prefixIcon: const Icon(
                            Icons.monitor_weight,
                            color: Color(0xFF4FC3A1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4FC3A1),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final weight = double.parse(value);
                          if (weight <= 0 || weight > 50) {
                            return 'Please enter a valid weight (0.1-50 kg)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Date Field
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF4FC3A1),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Record Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontFamily: 'SpotifyCircular',
                                      ),
                                    ),
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'SpotifyCircular',
                                        color: Color(0xFF2E7D5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // View Growth Chart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BabyGrowthChartScreen(
                                  motherData: widget.motherData,
                                  babyData: widget.babyData,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4FC3A1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFF4FC3A1),
                                width: 2,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.show_chart, size: 20),
                          label: const Text(
                            'View Growth Chart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveGrowthRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Growth Record',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }
}

// Baby Growth Chart Screen
class BabyGrowthChartScreen extends StatefulWidget {
  final Map<String, dynamic> motherData;
  final Map<String, dynamic> babyData;

  const BabyGrowthChartScreen({
    super.key,
    required this.motherData,
    required this.babyData,
  });

  @override
  State<BabyGrowthChartScreen> createState() => _BabyGrowthChartScreenState();
}

class _BabyGrowthChartScreenState extends State<BabyGrowthChartScreen> {
  List<Map<String, dynamic>> growthData = [];
  bool isLoading = true;
  bool isDownloading = false;
  String? errorMessage;
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadGrowthData();
  }

  Future<void> _loadGrowthData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final babyId = widget.babyData['id'] ?? widget.babyData['babyId'];
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseApiUrl}/growth/baby/$babyId'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            growthData = data
                .map((record) => Map<String, dynamic>.from(record))
                .toList();
            // Sort by date
            growthData.sort(
              (a, b) => DateTime.parse(
                a['date'],
              ).compareTo(DateTime.parse(b['date'])),
            );
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        setState(() {
          growthData = [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load growth data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _downloadChart() async {
    if (isDownloading) return; // Prevent multiple downloads

    setState(() {
      isDownloading = true;
    });

    try {
      // Check if the chart context is available
      if (_chartKey.currentContext == null) {
        throw Exception('Chart not ready for capture. Please try again.');
      }

      // Wait a moment to ensure the chart is fully rendered
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the RenderRepaintBoundary
      final RenderObject? renderObject = _chartKey.currentContext!
          .findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        throw Exception('Unable to capture chart. Please try again.');
      }

      final RenderRepaintBoundary boundary = renderObject;

      // Check if the boundary needs painting
      if (boundary.debugNeedsPaint) {
        throw Exception('Chart is still rendering. Please wait and try again.');
      }

      // Capture the chart as image
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to generate chart image.');
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final babyName =
          widget.babyData['name'] ??
          widget.babyData['babyName'] ??
          widget.babyData['fullName'] ??
          'Baby';
      final fileName =
          '${babyName}_growth_chart_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '$babyName\'s Growth Chart',
        subject: 'Baby Growth Chart',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chart downloaded and shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading chart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyName =
        widget.babyData['name'] ??
        widget.babyData['babyName'] ??
        widget.babyData['fullName'] ??
        'Baby';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$babyName\'s Growth Chart',
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (growthData.isNotEmpty)
            IconButton(
              onPressed: isDownloading ? null : _downloadChart,
              icon: isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              tooltip: isDownloading ? 'Downloading...' : 'Download Chart',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4FC3A1)),
              )
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading growth data',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadGrowthData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : growthData.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.show_chart, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No Growth Data',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No growth records found for $babyName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Baby Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4FC3A1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.child_care,
                              color: Color(0xFF4FC3A1),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  babyName,
                                  style: const TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D5A),
                                  ),
                                ),
                                Text(
                                  'Mother: ${widget.motherData['fullName']}',
                                  style: const TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${growthData.length} growth records',
                                  style: const TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Growth Chart
                    RepaintBoundary(
                      key: _chartKey,
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.show_chart,
                                  color: Color(0xFF4FC3A1),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Growth Chart',
                                  style: TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D5A),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: isDownloading
                                      ? null
                                      : _downloadChart,
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
                                  icon: isDownloading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.download, size: 16),
                                  label: Text(
                                    isDownloading
                                        ? 'Downloading...'
                                        : 'Download',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'SpotifyCircular',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 300,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: 1,
                                    verticalInterval: 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.withOpacity(0.2),
                                        strokeWidth: 1,
                                      );
                                    },
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.withOpacity(0.2),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                              if (value.toInt() <
                                                  growthData.length) {
                                                final record =
                                                    growthData[value.toInt()];
                                                final date = DateTime.parse(
                                                  record['date'],
                                                );
                                                return Transform.rotate(
                                                  angle: -0.5,
                                                  child: Text(
                                                    '${date.day}/${date.month}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 5,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                        reservedSize: 42,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  minX: 0,
                                  maxX: (growthData.length - 1).toDouble(),
                                  minY: 0,
                                  maxY: _getMaxY(),
                                  lineBarsData: [
                                    // Weight line
                                    LineChartBarData(
                                      spots: _getWeightSpots(),
                                      isCurved: true,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4FC3A1),
                                          Color(0xFF66D4B7),
                                        ],
                                      ),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFF4FC3A1,
                                            ).withOpacity(0.3),
                                            const Color(
                                              0xFF4FC3A1,
                                            ).withOpacity(0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    // Height line
                                    LineChartBarData(
                                      spots: _getHeightSpots(),
                                      isCurved: true,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B6B),
                                          Color(0xFFFF8E8E),
                                        ],
                                      ),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(
                                  const Color(0xFF4FC3A1),
                                  'Weight (kg)',
                                ),
                                const SizedBox(width: 20),
                                _buildLegendItem(
                                  const Color(0xFFFF6B6B),
                                  'Height (cm)',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Growth Records List
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.list_alt,
                                color: Color(0xFF4FC3A1),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Growth Records',
                                style: TextStyle(
                                  fontFamily: 'SpotifyCircular',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D5A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...growthData.reversed.map(
                            (record) => _buildRecordTile(record),
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

  List<FlSpot> _getWeightSpots() {
    return growthData.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;
      return FlSpot(index.toDouble(), (record['weight'] as num).toDouble());
    }).toList();
  }

  List<FlSpot> _getHeightSpots() {
    return growthData.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;
      return FlSpot(index.toDouble(), (record['height'] as num).toDouble());
    }).toList();
  }

  double _getMaxY() {
    if (growthData.isEmpty) return 100;

    double maxWeight = growthData
        .map((r) => (r['weight'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    double maxHeight = growthData
        .map((r) => (r['height'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return (maxWeight > maxHeight ? maxWeight : maxHeight) * 1.1;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTile(Map<String, dynamic> record) {
    final date = DateTime.parse(record['date']);
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.timeline,
              color: Color(0xFF4FC3A1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Weight: ${record['weight']} kg',
                      style: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Height: ${record['height']} cm',
                      style: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ViewAllRecordsScreen - Comprehensive view of all record types with mother & baby information
class ViewAllRecordsScreen extends StatefulWidget {
  const ViewAllRecordsScreen({super.key});

  @override
  State<ViewAllRecordsScreen> createState() => _ViewAllRecordsScreenState();
}

class _ViewAllRecordsScreenState extends State<ViewAllRecordsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _selectedRecordType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadAllRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRecords() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Map<String, dynamic>> allRecords = [];
      print('=== STARTING TO LOAD ALL RECORDS ===');

      // First load all registered mothers for reference
      await _loadAllMothers(allRecords);
      print('After loading mothers: ${allRecords.length} records');

      // Load Growth Records
      await _loadGrowthRecords(allRecords);
      print('After loading growth records: ${allRecords.length} records');

      // Load Thiriposa Records
      await _loadThiriposaRecords(allRecords);
      print('After loading thiriposa records: ${allRecords.length} records');

      // Load Vaccination Records
      await _loadVaccinationRecords(allRecords);
      print('After loading vaccination records: ${allRecords.length} records');

      // Load Eye and Ear Records
      await _loadEyeEarRecords(allRecords);
      print('After loading eye & ear records: ${allRecords.length} records');

      // Load Appointments
      await _loadAppointments(allRecords);
      print('After loading appointments: ${allRecords.length} records');

      // Show breakdown by record type
      Map<String, int> recordTypeCount = {};
      for (var record in allRecords) {
        String type = record['recordType'] ?? 'Unknown';
        recordTypeCount[type] = (recordTypeCount[type] ?? 0) + 1;
      }
      print('=== RECORD TYPE BREAKDOWN ===');
      recordTypeCount.forEach((type, count) {
        print('$type: $count records');
      });
      print('=== TOTAL: ${allRecords.length} RECORDS ===');

      if (mounted) {
        setState(() {
          _allRecords = allRecords;
          _filteredRecords = allRecords;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading records: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load records: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAllMothers(List<Map<String, dynamic>> allRecords) async {
    try {
      final mothers = await MothersService.getAllMothers();

      for (var mother in mothers) {
        // Debug log to see what fields are available
        print('Mother data: $mother');
        print('Mother keys: ${mother.keys.toList()}');
        print('nicNumber field value: ${mother['nicNumber']}');
        print('phoneNumber3 field value: ${mother['phoneNumber3']}');
        print('fullName field value: ${mother['fullName']}');

        // Handle different possible field names for NIC - try all variations
        String? nicValue =
            mother['nicNumber'] ?? // This is the correct field name from Registration model
            mother['nic'] ??
            mother['NIC'] ??
            mother['nationalId'] ??
            mother['id_number'] ??
            mother['identification'] ??
            mother['idNumber'];

        // Handle different possible field names for phone
        String? phoneValue =
            mother['phoneNumber3'] ?? // This is the correct field name from Registration model
            mother['phoneNumber'] ??
            mother['phone'] ??
            mother['contactNumber'] ??
            mother['mobile'] ??
            mother['mobileNumber'] ??
            mother['cellphone'];

        print(
          'Extracted - NIC: $nicValue, Phone: $phoneValue, Name: ${mother['fullName']}',
        );

        // Find babies for this mother
        String babiesDisplay = await _findBabiesForMother(nicValue ?? '');

        // Add mother registration as a record type
        allRecords.add({
          'id': mother['id'] ?? nicValue ?? 'unknown',
          'recordType': 'Mother Registration',
          'motherName':
              mother['fullName'] ??
              mother['name'] ??
              mother['firstName'] ??
              'Unknown Mother',
          'babyName': babiesDisplay,
          'date':
              mother['createdAt'] ?? // This is the correct field name from Registration model
              mother['registrationDate'] ??
              mother['created_at'] ??
              DateTime.now().toString(),
          'nic': nicValue ?? 'Not provided',
          'phone': phoneValue ?? 'Not provided',
          'address':
              mother['institution'] ??
              mother['address'] ??
              mother['location'] ??
              'Not provided',
          'details':
              'Mother registered - NIC: ${nicValue ?? 'Not provided'}, Phone: ${phoneValue ?? 'Not provided'}',
          'icon': Icons.person_add,
          'color': const Color(0xFF6B73FF),
          'motherId':
              mother['id'], // Store mother ID for fetching related records
        });
      }
    } catch (e) {
      print('Error loading mothers: $e');
    }
  }

  Future<String> _findBabiesForMother(String motherNic) async {
    List<String> babyNames = [];

    try {
      // Check vaccination records for babies
      final vaccResponse = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/vaccinations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (vaccResponse.statusCode == 200) {
        final List<dynamic> vaccData = json.decode(vaccResponse.body);
        for (var vacc in vaccData) {
          if (vacc['motherNic'] == motherNic && vacc['childName'] != null) {
            String babyName = vacc['childName'];
            if (!babyNames.contains(babyName)) {
              babyNames.add(babyName);
            }
          }
        }
      }
    } catch (e) {
      print('Error finding babies for mother $motherNic: $e');
    }

    return babyNames.isEmpty
        ? 'No babies registered yet'
        : babyNames.join(', ');
  }

  Future<String> _findMotherNameByNic(String motherNic) async {
    try {
      // Check mother registration records using the correct endpoint
      final motherResponse = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/registration/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (motherResponse.statusCode == 200) {
        final List<dynamic> motherData = json.decode(motherResponse.body);
        for (var mother in motherData) {
          // Use the correct field name 'nicNumber' instead of 'nic'
          if (mother['nicNumber'] == motherNic && mother['fullName'] != null) {
            return mother['fullName'];
          }
        }
      }

      // If not found in mothers, check vaccination records as fallback
      final vaccResponse = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/vaccinations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (vaccResponse.statusCode == 200) {
        final List<dynamic> vaccData = json.decode(vaccResponse.body);
        for (var vacc in vaccData) {
          if (vacc['motherNic'] == motherNic && vacc['motherName'] != null) {
            return vacc['motherName'];
          }
        }
      }
    } catch (e) {
      print('Error finding mother name for NIC $motherNic: $e');
    }

    return 'Unknown Mother';
  }

  void _showMotherRecordOptions(Map<String, dynamic> motherRecord) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Records for ${motherRecord['motherName']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'NIC: ${motherRecord['nic']}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportMotherRecords(
                    motherRecord['motherName'],
                    motherRecord['nic'],
                  );
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Download All Records PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3A1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportMotherRecords(
                    motherRecord['motherName'],
                    motherRecord['nic'],
                  );
                },
                icon: const Icon(Icons.child_care, color: Colors.white),
                label: const Text(
                  'Download Baby Records Only',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B73FF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadGrowthRecords(List<Map<String, dynamic>> allRecords) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/growth-records/all'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Growth API Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Growth API returned: ${data.length} records');
        print('Growth data sample: $data');

        for (var record in data) {
          // Get actual mother name using helper method
          String motherName = 'Unknown Mother';
          if (record['motherNic'] != null) {
            motherName = await _findMotherNameByNic(record['motherNic']);
          }

          // Get baby name from vaccination records
          String babyName = 'Unknown Baby';
          if (record['motherNic'] != null) {
            String babies = await _findBabiesForMother(record['motherNic']);
            if (babies != 'No babies registered yet') {
              babyName = babies.split(', ').first; // Get first baby name
            }
          }

          allRecords.add({
            'id': record['id'],
            'recordType': 'Growth',
            'motherName': motherName,
            'babyName': babyName,
            'date':
                record['date'] ??
                record['measurementDate'] ??
                record['createdAt'],
            'weight': record['weight'],
            'height': record['height'],
            'nic': record['motherNic'],
            'phone': record['motherPhone'],
            'details':
                'Weight: ${record['weight']}kg, Height: ${record['height']}cm',
            'icon': Icons.trending_up,
            'color': const Color(0xFF4FC3A1),
          });
        }
      } else {
        print(
          'Growth records API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error loading growth records: $e');
    }
  }

  Future<void> _loadThiriposaRecords(
    List<Map<String, dynamic>> allRecords,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/thiriposa/all'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Thiriposa API Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Thiriposa API returned: ${data.length} records');
        print('Thiriposa data sample: $data');

        for (var record in data) {
          // Get actual mother and baby names using helper methods
          String motherName = 'Unknown Mother';
          String babyName = 'Unknown Baby';

          if (record['motherNic'] != null) {
            motherName = await _findMotherNameByNic(record['motherNic']);
          }

          if (record['motherNic'] != null) {
            String babies = await _findBabiesForMother(record['motherNic']);
            if (babies != 'No babies registered yet') {
              babyName = babies.split(', ').first; // Get first baby name
            }
          }

          allRecords.add({
            'id': record['id'],
            'recordType': 'Thiriposa',
            'motherName': motherName,
            'babyName': babyName,
            'date':
                record['distributionDate'] ??
                record['date'] ??
                record['createdAt'],
            'nic': record['motherNic'],
            'phone': record['motherPhone'],
            'details': 'Thiriposa nutrition supplement distributed',
            'icon': Icons.local_dining,
            'color': const Color(0xFF2E7D5A),
          });
        }
      } else {
        print(
          'Thiriposa records API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error loading thiriposa records: $e');
    }
  }

  Future<void> _loadVaccinationRecords(
    List<Map<String, dynamic>> allRecords,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/vaccinations'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Vaccination API Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Vaccination API returned: ${data.length} records');
        print('Vaccination data sample: $data');

        for (var record in data) {
          // Get actual mother name using helper method
          String motherName = 'Unknown Mother';
          if (record['motherNic'] != null) {
            motherName = await _findMotherNameByNic(record['motherNic']);
          }

          allRecords.add({
            'id': record['id'],
            'recordType': 'Vaccination',
            'motherName': motherName,
            'babyName':
                record['childName'] ?? record['babyName'] ?? 'Unknown Baby',
            'date':
                record['vaccinationDate'] ??
                record['date'] ??
                record['createdAt'],
            'vaccine': record['vaccineName'] ?? record['vaccine'],
            'nic': record['motherNic'],
            'phone': record['motherPhone'],
            'details':
                'Vaccine: ${record['vaccineName'] ?? record['vaccine'] ?? 'N/A'}',
            'icon': Icons.vaccines,
            'color': const Color(0xFF9C27B0),
          });
        }
      } else {
        print(
          'Vaccination records API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error loading vaccination records: $e');
    }
  }

  Future<void> _loadEyeEarRecords(List<Map<String, dynamic>> allRecords) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/baby-problems'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Eye & Ear API Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        print('Eye & Ear API returned: ${data.length} records');
        print('Eye & Ear data sample: $data');

        for (var record in data) {
          // Filter for eye and ear problems only
          String problemType = record['problemType'] ?? '';
          if (problemType.toLowerCase().contains('eye') ||
              problemType.toLowerCase().contains('ear')) {
            // Get actual mother name using helper method
            String motherName = 'Unknown Mother';
            if (record['motherNic'] != null) {
              motherName = await _findMotherNameByNic(record['motherNic']);
            }

            allRecords.add({
              'id': record['id'],
              'recordType': 'Eye & Ear',
              'motherName': motherName,
              'babyName':
                  record['patientName'] ?? record['babyName'] ?? 'Unknown Baby',
              'date':
                  record['recordDate'] ?? record['date'] ?? record['createdAt'],
              'problemType': record['problemType'],
              'description': record['description'],
              'nic': record['motherNic'],
              'phone': record['motherPhone'],
              'details':
                  '${record['problemType'] ?? 'Problem'}: ${record['description'] ?? 'No description'}',
              'icon': Icons.visibility,
              'color': const Color(0xFF00BCD4),
            });
          }
        }
      } else {
        print(
          'Eye & Ear records API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error loading eye and ear records: $e');
    }
  }

  Future<void> _loadAppointments(List<Map<String, dynamic>> allRecords) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/appointments/all'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Appointments API Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Appointments API returned: ${data.length} records');
        print('Appointments data sample: $data');

        for (var record in data) {
          // Get actual mother name using helper method
          String motherName = 'Unknown Mother';
          if (record['motherNic'] != null) {
            motherName = await _findMotherNameByNic(record['motherNic']);
          }

          // Get baby name from vaccination records if available
          String babyName = 'General appointment';
          if (record['motherNic'] != null) {
            String babies = await _findBabiesForMother(record['motherNic']);
            if (babies != 'No babies registered yet') {
              babyName = babies.split(', ').first; // Get first baby name
            }
          }

          allRecords.add({
            'id': record['id'],
            'recordType': 'Appointment',
            'motherName': motherName,
            'babyName': babyName,
            'date':
                record['appointmentDate'] ??
                record['date'] ??
                record['createdAt'],
            'time': record['appointmentTime'] ?? record['timeSlot'],
            'nic': record['motherNic'],
            'phone': record['motherPhone'],
            'details':
                'Appointment: ${record['purpose'] ?? record['appointmentType'] ?? 'General checkup'}',
            'icon': Icons.event,
            'color': const Color(0xFFFF9800),
          });
        }
      } else {
        print(
          'Appointments API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _allRecords;
      } else {
        _filteredRecords = _allRecords.where((record) {
          return record['motherName'].toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              record['babyName'].toLowerCase().contains(query.toLowerCase()) ||
              record['recordType'].toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              record['details'].toLowerCase().contains(query.toLowerCase()) ||
              (record['nic'] != null &&
                  record['nic'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  )) ||
              (record['phone'] != null &&
                  record['phone'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ));
        }).toList();
      }
    });
  }

  void _filterByRecordType(String recordType) {
    setState(() {
      _selectedRecordType = recordType;
      if (recordType == 'All') {
        _filteredRecords = _allRecords;
      } else {
        _filteredRecords = _allRecords.where((record) {
          return record['recordType'] == recordType;
        }).toList();
      }
    });
  }

  Future<void> _exportAllRecordsToPDF() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_filteredRecords.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No records to export'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      print('=== EXPORTING ${_filteredRecords.length} RECORDS ===');
      Map<String, int> exportRecordTypeCount = {};
      for (var record in _filteredRecords) {
        String type = record['recordType'] ?? 'Unknown';
        exportRecordTypeCount[type] = (exportRecordTypeCount[type] ?? 0) + 1;
      }
      print('Export breakdown:');
      exportRecordTypeCount.forEach((type, count) {
        print('$type: $count records');
      });

      // Create PDF document
      final pdf = pw.Document();

      // Group records by type for better organization
      Map<String, List<Map<String, dynamic>>> recordsByType = {};
      for (var record in _filteredRecords) {
        String type = record['recordType'];
        if (!recordsByType.containsKey(type)) {
          recordsByType[type] = [];
        }
        recordsByType[type]!.add(record);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Center(
                child: pw.Text(
                  'ALL MATERNAL HEALTH RECORDS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary Box
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  border: pw.Border.all(color: PdfColors.teal200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('Total Records: ${_filteredRecords.length}'),
                    pw.SizedBox(height: 5),
                    ...recordsByType.entries.map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 1),
                        child: pw.Text(
                          '${entry.key}: ${entry.value.length} records',
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              // Records by type
              ...recordsByType.entries.map((entry) {
                String recordType = entry.key;
                List<Map<String, dynamic>> records = entry.value;

                // Sort records by date (most recent first)
                records.sort((a, b) {
                  try {
                    DateTime dateA = DateTime.parse(a['date']);
                    DateTime dateB = DateTime.parse(b['date']);
                    return dateB.compareTo(dateA);
                  } catch (e) {
                    return 0;
                  }
                });

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        '$recordType RECORDS (${records.length})',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    // Records Table
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(80),
                        1: const pw.FlexColumnWidth(1.2),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        // Header Row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Date',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Mother Name',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Baby Name',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Details',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Data Rows
                        ...records.map((record) {
                          String details = record['details'] ?? '';

                          // Add specific fields based on record type
                          if (record['weight'] != null &&
                              record['height'] != null) {
                            details +=
                                '\nWeight: ${record['weight']}kg, Height: ${record['height']}cm';
                          }
                          if (record['vaccine'] != null) {
                            details += '\nVaccine: ${record['vaccine']}';
                          }
                          if (record['time'] != null) {
                            details += '\nTime: ${record['time']}';
                          }

                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  _formatDate(record['date']),
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  record['motherName'] ?? 'N/A',
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  record['babyName'] ?? 'General',
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  details,
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                  ],
                );
              }).toList(),

              // Footer
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'End of Report - Total ${_filteredRecords.length} Records',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save and share PDF
      final output = await getExternalStorageDirectory();
      if (output != null) {
        final file = File(
          '${output.path}/all_maternal_records_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(await pdf.save());

        // Share the PDF file
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'All Maternal Health Records - ${DateTime.now().toString().substring(0, 10)}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF Records exported successfully!'),
              backgroundColor: Color(0xFF4FC3A1),
            ),
          );
        }
      }
    } catch (e) {
      print('Error exporting records: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportMotherRecords(
    String motherName,
    String? motherNic,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Filter records for this specific mother
      final motherRecords = _allRecords.where((record) {
        return record['motherName'] == motherName ||
            (motherNic != null && record['nic'] == motherNic);
      }).toList();

      if (motherRecords.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No records found for this mother'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Group records by baby
      Map<String, List<Map<String, dynamic>>> recordsByBaby = {};

      for (var record in motherRecords) {
        String babyKey = record['babyName'] ?? 'General Records';
        if (!recordsByBaby.containsKey(babyKey)) {
          recordsByBaby[babyKey] = [];
        }
        recordsByBaby[babyKey]!.add(record);
      }

      // Create PDF document
      final pdf = pw.Document();
      final motherInfo = motherRecords.first;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Center(
                child: pw.Text(
                  'MATERNAL HEALTH RECORDS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Mother Information Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MOTHER INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Name: ${motherInfo['motherName'] ?? 'N/A'}',
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text('NIC: ${motherInfo['nic'] ?? 'N/A'}'),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Phone: ${motherInfo['phone'] ?? 'N/A'}'),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Date: ${_formatDate(motherInfo['date'])}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Records for each baby
              ...recordsByBaby.entries.map((entry) {
                String babyName = entry.key;
                List<Map<String, dynamic>> babyRecords = entry.value;

                // Sort records by date
                babyRecords.sort((a, b) {
                  try {
                    DateTime dateA = DateTime.parse(a['date']);
                    DateTime dateB = DateTime.parse(b['date']);
                    return dateB.compareTo(dateA); // Most recent first
                  } catch (e) {
                    return 0;
                  }
                });

                // Group by record type
                Map<String, List<Map<String, dynamic>>> recordsByType = {};
                for (var record in babyRecords) {
                  String type = record['recordType'];
                  if (!recordsByType.containsKey(type)) {
                    recordsByType[type] = [];
                  }
                  recordsByType[type]!.add(record);
                }

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.teal50,
                        border: pw.Border.all(color: PdfColors.teal200),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        'RECORDS FOR: $babyName',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal800,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 15),

                    // Record type sections
                    ...recordsByType.entries.map((typeEntry) {
                      String recordType = typeEntry.key;
                      List<Map<String, dynamic>> typeRecords = typeEntry.value;

                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '$recordType Records',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.SizedBox(height: 8),

                          // Table for this record type
                          pw.Table(
                            border: pw.TableBorder.all(
                              color: PdfColors.grey300,
                            ),
                            columnWidths: {
                              0: const pw.FixedColumnWidth(80),
                              1: const pw.FlexColumnWidth(2),
                              2: const pw.FlexColumnWidth(1),
                            },
                            children: [
                              // Header row
                              pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey100,
                                ),
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      'Date',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      'Details',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      'Time',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Data rows
                              ...typeRecords.map((record) {
                                String details = record['details'] ?? '';

                                // Add specific fields based on record type
                                if (record['weight'] != null &&
                                    record['height'] != null) {
                                  details +=
                                      '\nWeight: ${record['weight']}kg\nHeight: ${record['height']}cm';
                                }
                                if (record['vaccine'] != null) {
                                  details += '\nVaccine: ${record['vaccine']}';
                                }

                                return pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        _formatDate(record['date']),
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(details),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(record['time'] ?? 'N/A'),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                          pw.SizedBox(height: 15),
                        ],
                      );
                    }).toList(),
                    pw.SizedBox(height: 20),
                  ],
                );
              }).toList(),

              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    ...() {
                      Map<String, int> recordTypeCount = {};
                      for (var record in motherRecords) {
                        String type = record['recordType'];
                        recordTypeCount[type] =
                            (recordTypeCount[type] ?? 0) + 1;
                      }
                      return recordTypeCount.entries.map((entry) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Text(
                            '${entry.key}: ${entry.value} records',
                          ),
                        );
                      }).toList();
                    }(),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Total Records: ${motherRecords.length}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Footer
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  'Generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save and share PDF
      final output = await getExternalStorageDirectory();
      if (output != null) {
        final sanitizedName = motherName
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .replaceAll(' ', '_');
        final file = File(
          '${output.path}/${sanitizedName}_complete_records_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(await pdf.save());

        // Share the PDF file
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Complete Records for $motherName - ${DateTime.now().toString().substring(0, 10)}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PDF Records for $motherName exported successfully!',
              ),
              backgroundColor: const Color(0xFF4FC3A1),
            ),
          );
        }
      }
    } catch (e) {
      print('Error exporting mother records: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Records',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _exportAllRecordsToPDF,
            tooltip: 'Export Records',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            switch (index) {
              case 0:
                _filterByRecordType('All');
                break;
              case 1:
                _filterByRecordType('Mother Registration');
                break;
              case 2:
                _filterByRecordType('Growth');
                break;
              case 3:
                _filterByRecordType('Thiriposa');
                break;
              case 4:
                _filterByRecordType('Vaccination');
                break;
              case 5:
                _filterByRecordType('Eye & Ear');
                break;
              case 6:
                _filterByRecordType('Appointment');
                break;
            }
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Mothers'),
            Tab(text: 'Growth'),
            Tab(text: 'Thiriposa'),
            Tab(text: 'Vaccination'),
            Tab(text: 'Eye & Ear'),
            Tab(text: 'Appointments'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterRecords,
                decoration: InputDecoration(
                  hintText:
                      'Search by mother name, baby name, NIC, phone, or record type...',
                  hintStyle: const TextStyle(fontFamily: 'SpotifyCircular'),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF4FC3A1),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterRecords('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4FC3A1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4FC3A1),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // Records Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Records: ${_filteredRecords.length}',
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D5A),
                    ),
                  ),
                  Text(
                    'Filter: $_selectedRecordType',
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      color: Color(0xFF4FC3A1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Records List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4FC3A1),
                        ),
                      ),
                    )
                  : _errorMessage.isNotEmpty
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
                            _errorMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontFamily: 'SpotifyCircular',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAllRecords,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredRecords.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No records found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = _filteredRecords[index];
                        return _buildRecordCard(record);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle record tap for mother registration - show download option
          if (record['recordType'] == 'Mother Registration') {
            _showMotherRecordOptions(record);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (record['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      record['icon'] as IconData,
                      color: record['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: record['color'] as Color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record['recordType'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SpotifyCircular',
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(record['date']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: 'SpotifyCircular',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mother: ${record['motherName']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2E7D5A),
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Baby: ${record['babyName']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF4FC3A1),
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record['details'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Special fields for Mother Registration records
              if (record['recordType'] == 'Mother Registration') ...[
                const SizedBox(height: 8),
                if (record['nic'] != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.credit_card,
                        size: 16,
                        color: Color(0xFF6B73FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NIC: ${record['nic']}',
                        style: const TextStyle(
                          color: Color(0xFF6B73FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (record['phone'] != null && record['phone'] != 'N/A') ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 16,
                        color: Color(0xFF6B73FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phone: ${record['phone']}',
                        style: const TextStyle(
                          color: Color(0xFF6B73FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (record['address'] != null &&
                    record['address'].toString().isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF6B73FF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Address: ${record['address']}',
                          style: const TextStyle(
                            color: Color(0xFF6B73FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Download button for mother records
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showMotherRecordOptions(record),
                    icon: const Icon(
                      Icons.download,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Download Records',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B73FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
              if (record['time'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF4FC3A1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time: ${record['time']}',
                      style: const TextStyle(
                        color: Color(0xFF4FC3A1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No date';

    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
