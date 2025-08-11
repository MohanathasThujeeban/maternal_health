import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MidwifeDashboardTab(),
    const PatientsTab(),
    const AppointmentsTab(),
    const AnalyticsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Midwife Dashboard',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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

class MidwifeDashboardTab extends StatelessWidget {
  const MidwifeDashboardTab({super.key});

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
              'Welcome, Mrs. Kamali Jayasinghe!',
              style: TextStyle(
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
                    title: 'Pending Checkups',
                    value: '3',
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
                    value: '95',
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
                children: [
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
    return const Center(
      child: Text(
        'Patients Management',
        style: TextStyle(
          fontFamily: 'SpotifyCircular',
          fontSize: 18,
          color: Color(0xFF2E7D5A),
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

class _AppointmentsTabState extends State<AppointmentsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> filteredAppointments = [];
  bool isLoading = false;
  String selectedFilter = 'all'; // all, pending, completed

  @override
  void initState() {
    super.initState();
    _loadTodayAppointments();
  }

  Future<void> _loadTodayAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/appointments/provider/MID001/today',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          appointments = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _applyFilter();
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

  void _applyFilter() {
    setState(() {
      if (selectedFilter == 'all') {
        filteredAppointments = appointments;
      } else {
        filteredAppointments = appointments
            .where(
              (apt) => apt['status'].toString().toLowerCase() == selectedFilter,
            )
            .toList();
      }
    });
  }

  void _searchByNic(String nic) {
    if (nic.isEmpty) {
      _loadTodayAppointments();
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Search in today's appointments for the midwife
    http
        .get(
          Uri.parse(
            'http://10.0.2.2:8080/api/appointments/provider/MID001/search?nic=$nic',
          ),
          headers: {'Content-Type': 'application/json'},
        )
        .then((response) {
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            setState(() {
              appointments = data
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
              _applyFilter();
            });
          }
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching appointments: $e')),
          );
        })
        .whenComplete(() {
          setState(() {
            isLoading = false;
          });
        });
  }

  Future<void> _updateAppointmentStatus(
    int appointmentId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://10.0.2.2:8080/api/appointments/$appointmentId/status',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        _loadTodayAppointments(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment marked as $status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating appointment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search and Filter Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by NIC number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _searchByNic,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedFilter,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                      _applyFilter();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Appointments List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAppointments.isEmpty
                ? const Center(
                    child: Text(
                      'No appointments found for today',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = filteredAppointments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            appointment['motherName'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NIC: ${appointment['motherNic']}'),
                              Text('Time: ${appointment['timeSlot']}'),
                              if (appointment['additionalProblems'] != null)
                                Text(
                                  'Notes: ${appointment['additionalProblems']}',
                                ),
                            ],
                          ),
                          trailing:
                              appointment['status'].toString().toLowerCase() ==
                                  'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => _updateAppointmentStatus(
                                        appointment['id'],
                                        'COMPLETED',
                                      ),
                                    ),
                                  ],
                                )
                              : Chip(
                                  label: Text(
                                    appointment['status']
                                        .toString()
                                        .toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      appointment['status']
                                              .toString()
                                              .toLowerCase() ==
                                          'completed'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Midwife Profile',
        style: TextStyle(
          fontFamily: 'SpotifyCircular',
          fontSize: 18,
          color: Color(0xFF2E7D5A),
        ),
      ),
    );
  }
}
