import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/language_selector.dart';
import '../../../../models/appointment.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/user_service.dart';
import '../../../appointments/schedule_appointment_screen.dart';
import '../../../appointments/appointments_list_screen.dart';
import '../../../../widgets/custom_loading.dart';
import '../../../thiriposa/thiriposa_records_screen.dart';
import './baby_records_screen.dart';
import './vaccinations_screen.dart';
import './mother_growth_chart_screen.dart';
import './comprehensive_profile_screen.dart';
import './privacy_security_screen.dart';
import './eye_ear_records_screen.dart';

class MotherHomeScreen extends StatefulWidget {
  const MotherHomeScreen({super.key});

  @override
  State<MotherHomeScreen> createState() => _MotherHomeScreenState();
}

class _MotherHomeScreenState extends State<MotherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.maternalCare,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    localizations.motherPortal,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        actions: [
          const LanguageSelector(),
          const SizedBox(width: 8),
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
      body: const MotherDashboardScreen(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            localizations.logout,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          content: Text(
            localizations.logoutConfirm,
            style: const TextStyle(fontFamily: 'SpotifyCircular', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                localizations.cancel,
                style: const TextStyle(
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
              child: Text(
                localizations.logout,
                style: const TextStyle(
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

// New comprehensive dashboard screen
class MotherDashboardScreen extends StatelessWidget {
  const MotherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.welcomeBack,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'SpotifyCircular',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.howAreYouFeeling,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontFamily: 'SpotifyCircular',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Baby Care Section
          _buildCategorySection(
            context,
            title: localizations.babyCare,
            subtitle: localizations.trackBabyGrowth,
            cards: [
              _CategoryCard(
                icon: Icons.insights,
                title: localizations.babyGrowthChart,
                description: localizations.trackWeightHeight,
                color: const Color(0xFF4FC3A1),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MotherGrowthChartScreen(),
                  ),
                ),
              ),
              _CategoryCard(
                icon: Icons.vaccines,
                title: localizations.vaccinations,
                description: localizations.vaccinationSchedule,
                color: const Color(0xFF42A5F5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VaccinationsScreen(),
                  ),
                ),
              ),
              _CategoryCard(
                icon: Icons.remove_red_eye,
                title: 'Eye & Ear Records',
                description:
                    'View your baby\'s eye and ear examination records',
                color: const Color(0xFF9C27B0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EyeEarRecordsScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Health & Medical Section
          _buildCategorySection(
            context,
            title: localizations.healthMedical,
            subtitle: localizations.manageHealthRecords,
            cards: [
              _CategoryCard(
                icon: Icons.baby_changing_station,
                title: localizations.babyRecords,
                description: localizations.babyRecordsDescription,
                color: const Color(0xFF4FC3A1),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BabyRecordsScreen(),
                  ),
                ),
              ),
              _CategoryCard(
                icon: Icons.calendar_today,
                title: localizations.appointments,
                description: localizations.scheduleManageAppointments,
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsListScreen(),
                  ),
                ),
              ),
              _CategoryCard(
                icon: Icons.inventory_2,
                title: localizations.thiriposaRecords,
                description: localizations.trackNutritionSupplements,
                color: const Color(0xFF9C27B0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThiriposaRecordsScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions Section
          _buildCategorySection(
            context,
            title: localizations.quickActions,
            subtitle: localizations.frequentlyUsed,
            cards: [
              _CategoryCard(
                icon: Icons.question_answer,
                title: localizations.healthChat,
                description: localizations.askHealthQuestions,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  // Navigate to health chatbox
                  Navigator.pushNamed(context, '/health-chatbox');
                },
              ),
              _CategoryCard(
                icon: Icons.account_circle,
                title: 'Complete Profile',
                description: 'Complete your comprehensive maternal profile',
                color: const Color(0xFF673AB7),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComprehensiveProfileScreen(),
                    ),
                  );
                },
              ),
              _CategoryCard(
                icon: Icons.phone,
                title: localizations.emergencyContact,
                description: localizations.quickEmergencyAccess,
                color: const Color(0xFFF44336),
                onTap: () {
                  _showEmergencyDialog(context);
                },
              ),
              _CategoryCard(
                icon: Icons.security,
                title: 'Privacy & Security',
                description: 'Manage password and privacy settings',
                color: const Color(0xFF795548),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacySecurityScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<_CategoryCard> cards,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpotifyCircular',
            color: Color(0xFF2E7D5A),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontFamily: 'SpotifyCircular',
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        cards.length == 3
            ? Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: cards.take(2).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: cards[2]),
                      const Expanded(
                        child: SizedBox(),
                      ), // Empty space to center the third card
                    ],
                  ),
                ],
              )
            : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: cards,
              ),
      ],
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.emergencyContacts,
            style: const TextStyle(
              fontFamily: 'SpotifyCircular',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D5A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.red),
                title: Text(localizations.emergencyServices),
                subtitle: const Text('110 / 119'),
                onTap: () {
                  // Call emergency services
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.blue),
                title: Text(localizations.hospital),
                subtitle: Text(localizations.yourRegisteredHospital),
                onTap: () {
                  // Call hospital
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: Text(localizations.yourDoctor),
                subtitle: const Text('Dr. Smith'),
                onTap: () {
                  // Call doctor
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                localizations.close,
                style: const TextStyle(
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

// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SpotifyCircular',
                    color: Color(0xFF2E2E2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'SpotifyCircular',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MotherDashboardTab extends StatelessWidget {
  const MotherDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
              localizations.welcomeMom,
              style: const TextStyle(
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
                    title: localizations.babyAge,
                    value: '8 ${localizations.months}',
                    icon: Icons.child_care,
                    color: const Color(0xFF4FC3A1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: localizations.nextCheckup,
                    value: '3 ${localizations.days}',
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
                    title: localizations.weightToday,
                    value: '8.2 ${localizations.kg}',
                    icon: Icons.monitor_weight,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: localizations.vaccinations,
                    value: '6/8',
                    icon: Icons.vaccines,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent Activities
            Text(
              localizations.recentActivity,
              style: const TextStyle(
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
                    subtitle: 'Medical checkup with Dr. Prasad Wickramasinghe',
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
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.babyGrowthChartTitle,
            style: const TextStyle(
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
                      label: localizations.weight,
                      value: '8.2 ${localizations.kg}',
                      change: '+0.3${localizations.kg}',
                      isPositive: true,
                    ),
                    _GrowthStat(
                      label: localizations.height,
                      value: '70 ${localizations.cm}',
                      change: '+2${localizations.cm}',
                      isPositive: true,
                    ),
                    _GrowthStat(
                      label: localizations.headCircumference,
                      value: '44 ${localizations.cm}',
                      change: '+1${localizations.cm}',
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.show_chart,
                    size: 48,
                    color: Color(0xFF4FC3A1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.growthChartTitle,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                      color: Color(0xFF2E7D5A),
                    ),
                  ),
                  Text(
                    localizations.interactiveChart,
                    style: const TextStyle(
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
          Text(
            localizations.recentMeasurements,
            style: const TextStyle(
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
                  weight: '8.2 ${localizations.kg}',
                  height: '70 ${localizations.cm}',
                  note: localizations.healthyGrowth,
                ),
                _MeasurementCard(
                  date: 'July 15, 2025',
                  weight: '7.9 ${localizations.kg}',
                  height: '68 ${localizations.cm}',
                  note: localizations.goodProgress,
                ),
                _MeasurementCard(
                  date: 'July 1, 2025',
                  weight: '7.6 ${localizations.kg}',
                  height: '67 ${localizations.cm}',
                  note: localizations.normalDevelopment,
                ),
              ],
            ),
          ),
        ],
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
  List<Appointment> appointments = [];
  bool isLoading = true;
  String? motherNic;
  String? motherName;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true;
    });

    // Get current user data from UserService
    final userData = await UserService.getUserData();
    motherNic = userData['nic'];
    motherName = userData['name'];

    if (motherNic == null || motherNic!.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final result = await AppointmentService.getAppointmentsByNic(motherNic!);

    setState(() {
      isLoading = false;
      if (result['success']) {
        appointments = result['appointments'];
      }
    });
  }

  List<Appointment> get pendingAppointments =>
      appointments.where((a) => a.status == 'pending').toList();

  List<Appointment> get completedAppointments =>
      appointments.where((a) => a.status == 'completed').toList();

  Future<void> _cancelAppointment(String appointmentId) async {
    final result = await AppointmentService.cancelAppointment(appointmentId);
    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Color(0xFF4FC3A1),
        ),
      );
      _loadAppointments(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.appointments,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D5A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleAppointmentScreen(),
                    ),
                  ).then((_) => _loadAppointments());
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  localizations.schedule,
                  style: const TextStyle(
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

          // Appointment Categories
          DefaultTabController(
            length: 3,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    labelColor: const Color(0xFF4FC3A1),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF4FC3A1),
                    labelStyle: const TextStyle(fontFamily: 'SpotifyCircular'),
                    tabs: [
                      Tab(
                        text: '${localizations.all} (${appointments.length})',
                      ),
                      Tab(
                        text:
                            '${localizations.pending} (${pendingAppointments.length})',
                      ),
                      Tab(
                        text:
                            '${localizations.completed} (${completedAppointments.length})',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CustomLoading(
                              message: 'Loading appointments...',
                              size: 100,
                              backgroundColor: Colors.transparent,
                            ),
                          )
                        : TabBarView(
                            children: [
                              _buildAppointmentsList(appointments),
                              _buildAppointmentsList(pendingAppointments),
                              _buildAppointmentsList(completedAppointments),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointmentList) {
    final localizations = AppLocalizations.of(context)!;

    if (appointmentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noAppointmentsFound,
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.tapScheduleButton,
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: const Color(0xFF4FC3A1),
      child: ListView.builder(
        itemCount: appointmentList.length,
        itemBuilder: (context, index) {
          final appointment = appointmentList[index];
          return _RealAppointmentCard(
            appointment: appointment,
            onCancel: appointment.status == 'pending'
                ? () => _showCancelDialog(appointment.id)
                : null,
          );
        },
      ),
    );
  }

  void _showCancelDialog(String appointmentId) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          localizations.cancelAppointment,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D5A),
          ),
        ),
        content: Text(
          localizations.cancelConfirmation,
          style: const TextStyle(fontFamily: 'SpotifyCircular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.no,
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointmentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              localizations.yesCancelAppointment,
              style: const TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Colors.white,
              ),
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
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.healthAssistant,
            style: const TextStyle(
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
            child: Column(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Color(0xFF4FC3A1),
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.askAnythingBaby,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                    color: Color(0xFF2E7D5A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.helpWithFeeding,
                  style: const TextStyle(
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
          Text(
            localizations.quickQuestions,
            style: const TextStyle(
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
                  question: localizations.isWeightNormal,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health-chatbox',
                      arguments: 'weight',
                    );
                  },
                ),
                _QuickQuestionCard(
                  question: localizations.introduceSolidFoods,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health-chatbox',
                      arguments: 'feeding',
                    );
                  },
                ),
                _QuickQuestionCard(
                  question: localizations.howMuchSleep,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health-chatbox',
                      arguments: 'sleep',
                    );
                  },
                ),
                _QuickQuestionCard(
                  question: localizations.whatVaccinesDue,
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
            color: Colors.grey.withValues(alpha: 0.1),
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
              color: color.withValues(alpha: 0.1),
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
            color: Colors.grey.withValues(alpha: 0.1),
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
              color: color.withValues(alpha: 0.1),
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

class _RealAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;

  const _RealAppointmentCard({required this.appointment, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    Color statusColor = appointment.status == 'completed'
        ? Colors.green
        : appointment.status == 'pending'
        ? Colors.orange
        : appointment.status == 'cancelled'
        ? Colors.red
        : Colors.blue;

    String statusText = appointment.status == 'completed'
        ? localizations.completed
        : appointment.status == 'pending'
        ? localizations.pending
        : appointment.status == 'cancelled'
        ? 'Cancelled'
        : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              Expanded(
                child: Text(
                  appointment.providerName,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
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
            appointment.appointmentType == 'doctor'
                ? localizations.doctorConsultation
                : localizations.midwifeConsultation,
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
                _formatDate(appointment.appointmentDate),
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
                appointment.timeSlot,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (appointment.additionalProblems != null &&
              appointment.additionalProblems!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.additionalNotes,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 12,
                      color: Color(0xFF2E7D5A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.additionalProblems!,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 12,
                      color: Color(0xFF4FC3A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.doctorNotes,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.notes!,
                    style: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onCancel != null && appointment.status == 'pending') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: Text(localizations.cancelAppointmentButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
