import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/api_config.dart';
import '../../../../services/user_service.dart';
import '../../../../services/mothers_service.dart';
import '../shared/healthcare_provider_privacy_screen.dart';
import '../Midwivesmodule/comprehensive_records_screen.dart';

class DoctorDashboard extends StatefulWidget {
  final Map<String, dynamic>? providerData;

  const DoctorDashboard({super.key, this.providerData});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardTab(providerData: widget.providerData),
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_hospital,
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
                  'Doctor Portal',
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
        backgroundColor: const Color(0xFF2E7D5A),
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
        selectedItemColor: const Color(0xFF2E7D5A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
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

class DashboardTab extends StatefulWidget {
  final Map<String, dynamic>? providerData;

  const DashboardTab({super.key, this.providerData});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String pendingReviewCount = '...';
  String thisMonthCount = '...';
  String todaysPatientsCount = '...';
  String emergencyCasesCount = '...';
  List<Map<String, dynamic>> recentActivities = [];
  bool isLoading = true;
  String? doctorLicense;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    try {
      // Get doctor's medical license from UserService
      final medicalLicense = await UserService.getUserMedicalLicense();
      setState(() {
        doctorLicense = medicalLicense;
      });

      // Fetch statistics after getting doctor license
      await _fetchStatistics();
      await _fetchRecentActivities();
    } catch (e) {
      print('Error loading doctor data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchStatistics() async {
    try {
      // Use real doctor license, fallback to default for testing
      String providerId = doctorLicense ?? 'DOC001';

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/appointments/provider/$providerId/stats',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendingReviewCount = data['pendingReview']?.toString() ?? '0';
          thisMonthCount = data['thisMonth']?.toString() ?? '0';
          todaysPatientsCount = data['todaysPatients']?.toString() ?? '0';
          emergencyCasesCount = data['emergencyCases']?.toString() ?? '0';
          isLoading = false;
        });
      } else {
        setState(() {
          pendingReviewCount = '0';
          thisMonthCount = '0';
          todaysPatientsCount = '0';
          emergencyCasesCount = '0';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      setState(() {
        pendingReviewCount = '0';
        thisMonthCount = '0';
        todaysPatientsCount = '0';
        emergencyCasesCount = '0';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchRecentActivities() async {
    try {
      // Use real doctor license for recent patient notes
      String doctorLicenseId = doctorLicense ?? 'DOC001';

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/patient-notes/doctor/$doctorLicenseId/recent',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            recentActivities = List<Map<String, dynamic>>.from(
              data['notes'] ?? [],
            );
          });
        }
      } else {
        // Fallback to empty list
        setState(() {
          recentActivities = [];
        });
      }
    } catch (e) {
      print('Error fetching recent activities: $e');
      setState(() {
        recentActivities = [];
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
              'Welcome, ${widget.providerData != null ? (widget.providerData!['providerType'] == 'DOCTOR' ? 'Dr. ' : '') + (widget.providerData!['fullName'] ?? 'Doctor') : 'Dr. Doctor'}!',
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
                    value: todaysPatientsCount,
                    icon: Icons.people,
                    color: const Color(0xFF4FC3A1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Pending Review',
                    value: pendingReviewCount,
                    icon: Icons.pending_actions,
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
                    title: 'Emergency Cases',
                    value: emergencyCasesCount,
                    icon: Icons.emergency,
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
              child: recentActivities.isEmpty
                  ? Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFF4FC3A1),
                            )
                          : const Text(
                              'No recent activities',
                              style: TextStyle(
                                fontFamily: 'SpotifyCircular',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                    )
                  : ListView.builder(
                      itemCount: recentActivities.length,
                      itemBuilder: (context, index) {
                        final activity = recentActivities[index];
                        final DateTime createdAt = DateTime.parse(
                          activity['createdAt'],
                        );
                        final String timeAgo = _formatTimeAgo(createdAt);

                        return _ActivityCard(
                          title: 'Patient Note Added',
                          subtitle:
                              'Note for ${_getMothersName(activity['motherNic'])} - ${activity['diagnosis'] ?? 'General consultation'}',
                          time: timeAgo,
                          icon: Icons.medical_services,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getMothersName(String motherNic) {
    // For now, just return the NIC. In a full implementation,
    // you would cache mother names or make an API call
    return 'Patient ${motherNic.substring(0, 4)}***';
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
              color: const Color(0xFF2E7D5A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D5A), size: 24),
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

class PatientsTab extends StatefulWidget {
  const PatientsTab({super.key});

  @override
  State<PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<PatientsTab> {
  List<Map<String, dynamic>> mothers = [];
  List<Map<String, dynamic>> filteredMothers = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMothers();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
        _filterMothers();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMothers() {
    if (searchQuery.isEmpty) {
      filteredMothers = List.from(mothers);
    } else {
      filteredMothers = mothers.where((mother) {
        final name = mother['fullName']?.toString().toLowerCase() ?? '';
        final nic = mother['nicNumber']?.toString().toLowerCase() ?? '';
        final email = mother['email']?.toString().toLowerCase() ?? '';
        return name.contains(searchQuery) ||
            nic.contains(searchQuery) ||
            email.contains(searchQuery);
      }).toList();
    }
  }

  Future<void> _loadMothers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final mothersData = await MothersService.getAllMothers();

      setState(() {
        mothers = mothersData;
        filteredMothers = List.from(mothers);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading mothers: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _openPatientDetails(Map<String, dynamic> mother) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(motherData: mother),
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
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          Icons.people,
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
                              'Patient Management',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            Text(
                              'View and manage patient records',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontFamily: 'CircularStd',
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
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                              Text(
                                'Total Patients',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                Icons.search,
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
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                              Text(
                                'Search Results',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'CircularStd',
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search patients by name, NIC, or email...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF4FC3A1)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: 'CircularStd',
                      color: Colors.grey,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'CircularStd',
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4FC3A1),
                      ),
                    )
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error Loading Patients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadMothers,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredMothers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No Patients Found'
                                : 'No Matching Patients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.isEmpty
                                ? 'No patients are registered yet.'
                                : 'Try adjusting your search terms.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredMothers.length,
                      itemBuilder: (context, index) {
                        final mother = filteredMothers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'CircularStd',
                                color: Color(0xFF2E7D5A),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'NIC: ${mother['nicNumber'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'CircularStd',
                                    color: Colors.grey,
                                  ),
                                ),
                                if (mother['email'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    mother['email'],
                                    style: TextStyle(
                                      fontFamily: 'CircularStd',
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (mother['isActive'] ?? true) == true
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (mother['isActive'] ?? true) == true
                                        ? 'Active'
                                        : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          (mother['isActive'] ?? true) == true
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontFamily: 'CircularStd',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () => _openPatientDetails(mother),
                              icon: const Icon(
                                Icons.medical_information,
                                size: 18,
                              ),
                              label: const Text(
                                'View Details',
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
          ],
        ),
      ),
    );
  }
}

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
          '${ApiConfig.baseApiUrl}/appointments/${appointment['id']}/complete',
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
      // Load today's appointments
      final todayResponse = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/appointments/provider/DOC001/today'),
        headers: {'Content-Type': 'application/json'},
      );

      // Load upcoming appointments (future dates)
      final upcomingResponse = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/appointments/provider/DOC001/upcoming',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (todayResponse.statusCode == 200) {
        final List<dynamic> todayData = jsonDecode(todayResponse.body);

        setState(() {
          // Process today's appointments
          todayAppointments = todayData
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          // Separate by status
          final allToday = todayData
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          completedAppointments = allToday
              .where(
                (apt) => apt['status'].toString().toLowerCase() == 'completed',
              )
              .toList();

          // Load upcoming appointments from backend or use mock data
          if (upcomingResponse.statusCode == 200) {
            final List<dynamic> allAppointments = jsonDecode(
              upcomingResponse.body,
            );

            // Filter for upcoming appointments (future dates, not today)
            final DateTime now = DateTime.now();
            final DateTime today = DateTime(now.year, now.month, now.day);

            upcomingAppointments = allAppointments
                .map((e) => Map<String, dynamic>.from(e))
                .where((appointment) {
                  // Parse appointment date
                  try {
                    final appointmentDate = DateTime.parse(
                      appointment['appointmentDate'],
                    );
                    final appointmentDay = DateTime(
                      appointmentDate.year,
                      appointmentDate.month,
                      appointmentDate.day,
                    );
                    // Return appointments that are after today
                    return appointmentDay.isAfter(today);
                  } catch (e) {
                    return false; // Skip appointments with invalid dates
                  }
                })
                .map((e) {
                  final appointment = Map<String, dynamic>.from(e);
                  appointment['priority'] = appointment['status'] == 'PENDING'
                      ? 'high'
                      : 'normal';
                  // Format date for display
                  try {
                    final appointmentDate = DateTime.parse(
                      appointment['appointmentDate'],
                    );
                    appointment['date'] =
                        '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
                    appointment['time'] =
                        appointment['timeSlot'] ?? 'Time not specified';
                  } catch (e) {
                    appointment['date'] = 'Date not available';
                    appointment['time'] = 'Time not available';
                  }
                  return appointment;
                })
                .toList();
          } else {
            // If API fails, show empty list instead of mock data
            upcomingAppointments = [];
          }

          // Initialize filtered lists
          _filterAppointments(_searchController.text);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading appointments: $e')));
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
                  colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
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
                          Icons.local_hospital,
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
                              'Doctor Appointments',
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
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
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
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                unselectedLabelColor: const Color(0xFF2196F3),
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
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
                          Color(0xFF2196F3),
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
      color: const Color(0xFF2196F3),
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
    final isCompleted =
        appointment['status']?.toString().toLowerCase() == 'completed';
    final isPending =
        appointment['status']?.toString().toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [Colors.green.shade50, Colors.green.shade100]
              : isPending
              ? [Colors.blue.shade50, Colors.blue.shade100]
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
                          : [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.person,
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
                        appointment['motherName'] ?? 'Unknown Patient',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SpotifyCircular',
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIC: ${appointment['motherNic'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
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
                    appointment['timeSlot'] ?? 'Time not specified',
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
                      appointment['appointmentType'] ?? 'General Consultation',
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
            if (appointment['additionalProblems'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Notes:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2196F3),
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['additionalProblems'],
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
            if (isPending) ...[
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
                      onPressed: () => _addNotes(appointment['id']),
                      icon: const Icon(Icons.note_add, size: 18),
                      label: const Text(
                        'Add Notes',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3),
                        side: const BorderSide(color: Color(0xFF2196F3)),
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
    final isPriority = appointment['priority'] == 'high';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPriority
              ? [Colors.orange.shade50, Colors.orange.shade100]
              : [Colors.white, const Color(0xFFF8FFFE)],
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
        border: isPriority
            ? Border.all(color: Colors.orange.shade300, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPriority
                      ? [Colors.orange, Colors.orange.shade600]
                      : [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPriority ? Icons.priority_high : Icons.person_outline,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment['motherName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SpotifyCircular',
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                      ),
                      if (isPriority)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PRIORITY',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ),
                    ],
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
                    appointment['appointmentType'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2196F3),
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
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
                        appointment['timeSlot'] ?? 'Time not specified',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
            if (appointment['additionalProblems'] != null) ...[
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
                      'Treatment Notes:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['additionalProblems'],
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

  void _addNotes(dynamic appointmentId) {
    // Handle add notes functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Add notes functionality will be implemented',
          style: TextStyle(fontFamily: 'SpotifyCircular'),
        ),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }
}

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Analytics & Reports',
        style: TextStyle(
          fontFamily: 'SpotifyCircular',
          fontSize: 18,
          color: Color(0xFF2E7D5A),
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
                colors: [Color(0xFF2E7D5A), Color(0xFF1E5D3F)],
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
                  child: const Icon(
                    Icons.medical_services,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  providerData!['fullName'] ?? 'Doctor',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Doctor - ${providerData!['specialization'] ?? 'General Medicine'}',
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
              providerData!['specialization'] ?? 'General Medicine',
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
          ]),

          const SizedBox(height: 32),

          // Action Buttons
          Column(
            children: [
              // First row - Privacy & Security
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HealthcareProviderPrivacyScreen(
                              userRole: 'DOCTOR',
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D5A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.security, color: Colors.white),
                  label: const Text(
                    'Privacy & Security',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Second row - Edit Profile and Logout
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement edit profile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit profile feature coming soon'),
                            backgroundColor: Color(0xFF2E7D5A),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2E7D5A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit, color: Color(0xFF2E7D5A)),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Color(0xFF2E7D5A),
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
                                color: Color(0xFF2E7D5A),
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
                                  backgroundColor: const Color(0xFF2E7D5A),
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
                        side: const BorderSide(color: Color(0xFF2E7D5A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Color(0xFF2E7D5A)),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFF2E7D5A),
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
}

class PatientDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> motherData;

  const PatientDetailsScreen({super.key, required this.motherData});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for note form
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();

  List<Map<String, dynamic>> patientNotes = [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  // Doctor data from session
  String? doctorName;
  String? doctorLicense;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDoctorData();
    _loadPatientNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientNotes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final motherNic = widget.motherData['nicNumber'];
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseApiUrl}/patient-notes/mother/$motherNic',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            patientNotes = List<Map<String, dynamic>>.from(data['notes'] ?? []);
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load patient notes');
        }
      } else {
        throw Exception('Failed to load patient notes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadDoctorData() async {
    try {
      // Get doctor data from UserService
      final userData = await UserService.getUserData();
      setState(() {
        doctorName = userData['name'] ?? 'Unknown Doctor';
        doctorLicense = userData['medicalLicense'] ?? 'UNKNOWN';
      });
    } catch (e) {
      print('Error loading doctor data: $e');
      // Fallback to default values
      setState(() {
        doctorName = 'Unknown Doctor';
        doctorLicense = 'UNKNOWN';
      });
    }
  }

  Future<void> _savePatientNote() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some notes before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final noteData = {
        'motherNic': widget.motherData['nicNumber'],
        'doctorLicense': doctorLicense ?? 'UNKNOWN',
        'doctorName': doctorName ?? 'Unknown Doctor',
        'notes': _notesController.text.trim(),
        'diagnosis': _diagnosisController.text.trim(),
        'treatmentPlan': _treatmentController.text.trim(),
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseApiUrl}/patient-notes'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(noteData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient note saved successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear form
          _notesController.clear();
          _diagnosisController.clear();
          _treatmentController.clear();

          // Reload notes
          _loadPatientNotes();
        } else {
          throw Exception(data['error'] ?? 'Failed to save patient note');
        }
      } else {
        throw Exception('Failed to save patient note: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.motherData['fullName'] ?? 'Patient Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.folder_open), text: 'View Records'),
            Tab(icon: Icon(Icons.note_add), text: 'Add Note'),
            Tab(icon: Icon(Icons.history), text: 'Notes History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildViewRecordsTab(),
          _buildAddNoteTab(),
          _buildNotesHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FC3A1), Color(0xFF66D4B7)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.motherData['fullName'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D5A),
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.motherData['isActive'] ?? true) ==
                                      true
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (widget.motherData['isActive'] ?? true) == true
                                  ? 'Active Patient'
                                  : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    (widget.motherData['isActive'] ?? true) ==
                                        true
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Patient Details
                _buildInfoRow(
                  'NIC Number',
                  widget.motherData['nicNumber'] ?? 'N/A',
                ),
                _buildInfoRow('Email', widget.motherData['email'] ?? 'N/A'),
                _buildInfoRow(
                  'Phone',
                  widget.motherData['phoneNumber'] ?? 'N/A',
                ),
                _buildInfoRow(
                  'Registration Date',
                  widget.motherData['registrationDate'] != null
                      ? widget.motherData['registrationDate']
                            .toString()
                            .substring(0, 10)
                      : 'N/A',
                ),
                _buildInfoRow(
                  'Last Updated',
                  widget.motherData['lastUpdated'] != null
                      ? widget.motherData['lastUpdated'].toString().substring(
                          0,
                          10,
                        )
                      : 'N/A',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D5A),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _tabController.animateTo(1);
                        },
                        icon: const Icon(Icons.note_add),
                        label: const Text('Add Note'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _tabController.animateTo(2);
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('View History'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildViewRecordsTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F2), Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
        ),
      ),
      child: ComprehensiveRecordsScreen(mother: widget.motherData),
    );
  }

  Widget _buildAddNoteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Patient Note for ${widget.motherData['fullName']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D5A),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 20),

                // Notes field
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Clinical Notes *',
                    hintText: 'Enter your clinical observations and notes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4FC3A1),
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'CircularStd'),
                ),

                const SizedBox(height: 16),

                // Diagnosis field
                TextField(
                  controller: _diagnosisController,
                  decoration: InputDecoration(
                    labelText: 'Diagnosis',
                    hintText: 'Enter diagnosis if any...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4FC3A1),
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'CircularStd'),
                ),

                const SizedBox(height: 16),

                // Treatment plan field
                TextField(
                  controller: _treatmentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Treatment Plan',
                    hintText: 'Enter treatment recommendations...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4FC3A1),
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'CircularStd'),
                ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : _savePatientNote,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(isSaving ? 'Saving...' : 'Save Patient Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildNotesHistoryTab() {
    return Column(
      children: [
        // Header with refresh button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient Notes History (${patientNotes.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D5A),
                  fontFamily: 'CircularStd',
                ),
              ),
              IconButton(
                onPressed: _loadPatientNotes,
                icon: const Icon(Icons.refresh, color: Color(0xFF4FC3A1)),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4FC3A1)),
                )
              : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadPatientNotes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3A1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : patientNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Notes Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No clinical notes have been added for this patient yet.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: patientNotes.length,
                  itemBuilder: (context, index) {
                    final note = patientNotes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4FC3A1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.medical_information,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note['doctorName'] ?? 'Unknown Doctor',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF2E7D5A),
                                        fontFamily: 'CircularStd',
                                      ),
                                    ),
                                    Text(
                                      note['createdAt'] != null
                                          ? note['createdAt']
                                                .toString()
                                                .substring(0, 16)
                                                .replaceAll('T', ' ')
                                          : 'Unknown date',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontFamily: 'CircularStd',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Notes
                          if (note['notes'] != null &&
                              note['notes'].toString().isNotEmpty) ...[
                            Text(
                              'Clinical Notes:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF2E7D5A),
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note['notes'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Diagnosis
                          if (note['diagnosis'] != null &&
                              note['diagnosis'].toString().isNotEmpty) ...[
                            Text(
                              'Diagnosis:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF2E7D5A),
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note['diagnosis'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Treatment Plan
                          if (note['treatmentPlan'] != null &&
                              note['treatmentPlan'].toString().isNotEmpty) ...[
                            Text(
                              'Treatment Plan:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF2E7D5A),
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note['treatmentPlan'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontFamily: 'CircularStd',
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'CircularStd',
                fontSize: 14,
                color: Color(0xFF2E7D5A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
