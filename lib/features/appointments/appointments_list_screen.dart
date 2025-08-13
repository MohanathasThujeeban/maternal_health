import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../services/user_service.dart';
import './schedule_appointment_screen.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  List<Appointment> appointments = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await UserService.getUserData();
      final nic = userData['nic'];

      if (nic != null && nic.isNotEmpty) {
        final result = await AppointmentService.getAppointmentsByNic(nic);

        if (result['success']) {
          setState(() {
            appointments = result['appointments'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            appointments = [];
            isLoading = false;
          });
          _showMessage('Failed to load appointments');
        }
      } else {
        setState(() {
          appointments = [];
          isLoading = false;
        });
        _showMessage('User data not found. Please login again.');
      }
    } catch (e) {
      setState(() {
        appointments = [];
        isLoading = false;
      });
      _showMessage('Error loading appointments: ${e.toString()}');
    }
  }

  List<Appointment> _getAppointmentsByStatus(String status) {
    return appointments
        .where(
          (appointment) =>
              appointment.status.toLowerCase() == status.toLowerCase(),
        )
        .toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    // Show confirmation dialog
    final confirmed = await _showCancelConfirmDialog(appointment);
    if (!confirmed) return;

    try {
      final result = await AppointmentService.cancelAppointment(appointment.id);

      if (result['success']) {
        _showMessage('Appointment cancelled successfully', isError: false);
        _loadAppointments(); // Refresh the list
      } else {
        _showMessage(result['message'] ?? 'Failed to cancel appointment');
      }
    } catch (e) {
      _showMessage('Error cancelling appointment: ${e.toString()}');
    }
  }

  Future<bool> _showCancelConfirmDialog(Appointment appointment) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Cancel Appointment',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to cancel this appointment?',
                  style: TextStyle(fontFamily: 'SpotifyCircular'),
                ),
                const SizedBox(height: 16),
                _buildAppointmentDetails(appointment),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone.',
                          style: TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Keep Appointment',
                  style: TextStyle(
                    color: Color(0xFF4FC3A1),
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Yes, Cancel',
                  style: TextStyle(fontFamily: 'SpotifyCircular'),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildAppointmentDetails(Appointment appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provider: ${appointment.providerName}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          'Date: ${DateFormat('MMM dd, yyyy').format(appointment.appointmentDate)}',
        ),
        Text('Time: ${appointment.timeSlot}'),
        Text('Type: ${appointment.appointmentType}'),
      ],
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4FC3A1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'Cancelled', icon: Icon(Icons.cancel_outlined)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadAppointments,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3A1)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList('pending'),
                _buildAppointmentsList('completed'),
                _buildAppointmentsList('cancelled'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScheduleAppointmentScreen(),
            ),
          ).then((_) {
            // Refresh appointments when returning from schedule screen
            _loadAppointments();
          });
        },
        backgroundColor: const Color(0xFF4FC3A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Schedule Appointment',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(String status) {
    final filteredAppointments = _getAppointmentsByStatus(status);

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending'
                  ? Icons.schedule
                  : status == 'completed'
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'pending'
                  ? 'No upcoming appointments'
                  : status == 'completed'
                  ? 'No completed appointments'
                  : 'No cancelled appointments',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontFamily: 'SpotifyCircular',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == 'pending'
                  ? 'Schedule your first appointment'
                  : 'Your appointment history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
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
        itemCount: filteredAppointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(filteredAppointments[index], status);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, String status) {
    final isUpcoming = status == 'pending';
    final isPastDue =
        isUpcoming && appointment.appointmentDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(appointment.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(appointment.status),
                    size: 18,
                    color: _getStatusColor(appointment.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(appointment.status),
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status),
                      fontSize: 13,
                    ),
                  ),
                  if (isPastDue) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'OVERDUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3A1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          appointment.appointmentType.toLowerCase() == 'doctor'
                              ? Icons.local_hospital
                              : Icons.pregnant_woman,
                          color: const Color(0xFF4FC3A1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.providerName,
                              style: const TextStyle(
                                fontFamily: 'SpotifyCircular',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),
                            Text(
                              appointment.appointmentType.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'SpotifyCircular',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date and time
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.calendar_today,
                          'Date',
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(appointment.appointmentDate),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.access_time,
                          'Time',
                          appointment.timeSlot,
                        ),
                      ),
                    ],
                  ),

                  if (appointment.additionalProblems != null &&
                      appointment.additionalProblems!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      Icons.note,
                      'Additional Notes',
                      appointment.additionalProblems!,
                    ),
                  ],

                  if (appointment.notes != null &&
                      appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      Icons.medical_services,
                      'Doctor\'s Notes',
                      appointment.notes!,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action buttons
                  if (isUpcoming) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelAppointment(appointment),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement reschedule functionality
                              _showMessage('Reschedule feature coming soon!');
                            },
                            icon: const Icon(Icons.schedule, size: 18),
                            label: const Text('Reschedule'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 14,
                  color: Color(0xFF2E2E2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF4FC3A1);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'UPCOMING';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }
}
