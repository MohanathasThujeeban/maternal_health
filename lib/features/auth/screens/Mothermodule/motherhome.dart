import 'package:flutter/material.dart';

class MotherHomeScreen extends StatefulWidget {
  const MotherHomeScreen({super.key});

  @override
  State<MotherHomeScreen> createState() => _MotherHomeScreenState();
}

class _MotherHomeScreenState extends State<MotherHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MotherDashboardTab(),
    const BabyGrowthTab(),
    const HealthRecordsTab(),
    const AppointmentsTab(),
    const ChatTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mother Dashboard',
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Baby Growth',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Health Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to health chatbox
          Navigator.pushNamed(context, '/health-chatbox');
        },
        backgroundColor: const Color(0xFF4FC3A1),
        child: const Icon(Icons.question_answer, color: Colors.white),
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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
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

class MotherDashboardTab extends StatelessWidget {
  const MotherDashboardTab({super.key});

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
              'Welcome, Mom! 💕',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Baby\'s Age',
                    value: '8 months',
                    icon: Icons.child_care,
                    color: const Color(0xFF4FC3A1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Next Checkup',
                    value: '3 days',
                    icon: Icons.calendar_today,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Weight Today',
                    value: '8.2 kg',
                    icon: Icons.monitor_weight,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Vaccinations',
                    value: '6/8',
                    icon: Icons.vaccines,
                    color: const Color(0xFF4CAF50),
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
                    title: 'Weight Recorded',
                    subtitle: 'Baby\'s weight: 8.2kg (healthy growth)',
                    time: '2 hours ago',
                    icon: Icons.trending_up,
                    color: const Color(0xFF4CAF50),
                  ),
                  _ActivityCard(
                    title: 'Vaccination Reminder',
                    subtitle: 'MMR vaccine due in 3 days',
                    time: '1 day ago',
                    icon: Icons.vaccines,
                    color: const Color(0xFFFF9800),
                  ),
                  _ActivityCard(
                    title: 'Appointment Scheduled',
                    subtitle: 'Pediatric checkup with Dr. Smith',
                    time: '2 days ago',
                    icon: Icons.event,
                    color: const Color(0xFF4FC3A1),
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

class BabyGrowthTab extends StatelessWidget {
  const BabyGrowthTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Baby\'s Growth Chart',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          const SizedBox(height: 20),

          // Current Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _GrowthStat(
                      label: 'Weight',
                      value: '8.2 kg',
                      change: '+0.3kg',
                      isPositive: true,
                    ),
                    _GrowthStat(
                      label: 'Height',
                      value: '70 cm',
                      change: '+2cm',
                      isPositive: true,
                    ),
                    _GrowthStat(
                      label: 'Head Circumference',
                      value: '44 cm',
                      change: '+1cm',
                      isPositive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Growth Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 48, color: Color(0xFF4FC3A1)),
                  SizedBox(height: 8),
                  Text(
                    'Growth Chart',
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                      color: Color(0xFF2E7D5A),
                    ),
                  ),
                  Text(
                    'Interactive chart will be displayed here',
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recent Measurements
          const Text(
            'Recent Measurements',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFAD1457),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              children: [
                _MeasurementCard(
                  date: 'July 30, 2025',
                  weight: '8.2 kg',
                  height: '70 cm',
                  note: 'Healthy growth, on track',
                ),
                _MeasurementCard(
                  date: 'July 15, 2025',
                  weight: '7.9 kg',
                  height: '68 cm',
                  note: 'Good progress',
                ),
                _MeasurementCard(
                  date: 'July 1, 2025',
                  weight: '7.6 kg',
                  height: '67 cm',
                  note: 'Normal development',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HealthRecordsTab extends StatelessWidget {
  const HealthRecordsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Records & Vaccinations',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          const SizedBox(height: 20),

          // Vaccination Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vaccination Progress',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '6 of 8 vaccinations completed',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                _VaccinationCard(
                  name: 'BCG',
                  date: 'Jan 15, 2025',
                  status: 'Completed',
                  isCompleted: true,
                ),
                _VaccinationCard(
                  name: 'Hepatitis B',
                  date: 'Feb 15, 2025',
                  status: 'Completed',
                  isCompleted: true,
                ),
                _VaccinationCard(
                  name: 'DPT (1st dose)',
                  date: 'Mar 15, 2025',
                  status: 'Completed',
                  isCompleted: true,
                ),
                _VaccinationCard(
                  name: 'Polio (1st dose)',
                  date: 'Mar 15, 2025',
                  status: 'Completed',
                  isCompleted: true,
                ),
                _VaccinationCard(
                  name: 'DPT (2nd dose)',
                  date: 'Apr 15, 2025',
                  status: 'Completed',
                  isCompleted: true,
                ),
                _VaccinationCard(
                  name: 'Polio (2nd dose)',
                  date: 'Apr 15, 2025',
                  status: 'Completed',
                  isCompleted: true,
                ),
                _VaccinationCard(
                  name: 'MMR',
                  date: 'Aug 3, 2025',
                  status: 'Due Soon',
                  isCompleted: false,
                ),
                _VaccinationCard(
                  name: 'Varicella',
                  date: 'Sep 15, 2025',
                  status: 'Scheduled',
                  isCompleted: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Appointments',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Schedule new appointment
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Schedule',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                _AppointmentCard(
                  doctorName: 'Dr. Sarah Smith',
                  specialty: 'Pediatrician',
                  date: 'August 3, 2025',
                  time: '10:00 AM',
                  type: 'Vaccination',
                  status: 'Upcoming',
                ),
                _AppointmentCard(
                  doctorName: 'Dr. Michael Johnson',
                  specialty: 'General Practitioner',
                  date: 'August 15, 2025',
                  time: '2:30 PM',
                  type: 'Check-up',
                  status: 'Scheduled',
                ),
                _AppointmentCard(
                  doctorName: 'Dr. Emily Davis',
                  specialty: 'Nutritionist',
                  date: 'July 25, 2025',
                  time: '11:00 AM',
                  type: 'Consultation',
                  status: 'Completed',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Assistant',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Color(0xFF4FC3A1),
                ),
                SizedBox(height: 12),
                Text(
                  'Ask me anything about your baby\'s health!',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                    color: Color(0xFF2E7D5A),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'I can help with feeding, sleep, development, and general health questions.',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Questions
          const Text(
            'Quick Questions',
            style: TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D5A),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              children: [
                _QuickQuestionCard(
                  question: 'Is my baby\'s weight normal?',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health-chatbox',
                      arguments: 'weight',
                    );
                  },
                ),
                _QuickQuestionCard(
                  question: 'When should I introduce solid foods?',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health-chatbox',
                      arguments: 'feeding',
                    );
                  },
                ),
                _QuickQuestionCard(
                  question: 'How much sleep does my baby need?',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health-chatbox',
                      arguments: 'sleep',
                    );
                  },
                ),
                _QuickQuestionCard(
                  question: 'What vaccines are due next?',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health-chatbox',
                      arguments: 'vaccines',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D5A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 11,
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
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
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

class _GrowthStat extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const _GrowthStat({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFAD1457),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          change,
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 12,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final String date;
  final String weight;
  final String height;
  final String note;

  const _MeasurementCard({
    required this.date,
    required this.weight,
    required this.height,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weight: $weight | Height: $height',
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.trending_up, color: Colors.green),
        ],
      ),
    );
  }
}

class _VaccinationCard extends StatelessWidget {
  final String name;
  final String date;
  final String status;
  final bool isCompleted;

  const _VaccinationCard({
    required this.name,
    required this.date,
    required this.status,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            color: isCompleted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 12,
                color: isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String type;
  final String status;

  const _AppointmentCard({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Completed'
        ? Colors.green
        : status == 'Upcoming'
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doctorName,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            specialty,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 12,
                color: Color(0xFF4FC3A1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickQuestionCard extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _QuickQuestionCard({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF4FC3A1)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
