import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../../config/api_config.dart';
import '../../../../services/user_service.dart';
import '../../../../widgets/custom_loading.dart';

class MyPregnancyRecordsScreen extends StatefulWidget {
  const MyPregnancyRecordsScreen({super.key});

  @override
  State<MyPregnancyRecordsScreen> createState() =>
      _MyPregnancyRecordsScreenState();
}

class _MyPregnancyRecordsScreenState extends State<MyPregnancyRecordsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  String? _motherNic;
  late TabController _tabController;

  // Pregnancy-specific records
  Map<String, dynamic>? _maternalProfile;
  List<Map<String, dynamic>> _pregnancyWeightRecords = [];
  List<Map<String, dynamic>> _vaccinationRecords = [];
  List<Map<String, dynamic>> _appointmentRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserDataAndRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user NIC
      _motherNic = await UserService.getUserNic();

      if (_motherNic == null || _motherNic!.isEmpty) {
        throw Exception(
          'Unable to get user identification. Please log in again.',
        );
      }

      // Load all pregnancy-related records
      await Future.wait([
        _loadMaternalProfile(),
        _loadPregnancyWeightRecords(),
        _loadVaccinationRecords(),
        _loadAppointmentRecords(),
      ]);
    } catch (e) {
      print('Error loading pregnancy records: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMaternalProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/api/maternal-profile/$_motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _maternalProfile = data;
        });
      } else if (response.statusCode != 404) {
        print('Failed to load maternal profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading maternal profile: $e');
    }
  }

  Future<void> _loadPregnancyWeightRecords() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/pregnancy-weight-records/mother/$_motherNic',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _pregnancyWeightRecords = data.cast<Map<String, dynamic>>();
          // Sort by date descending (latest first)
          _pregnancyWeightRecords.sort((a, b) {
            final dateA = DateTime.parse(a['measurementDate'] ?? '1970-01-01');
            final dateB = DateTime.parse(b['measurementDate'] ?? '1970-01-01');
            return dateB.compareTo(dateA);
          });
        });
      }
    } catch (e) {
      print('Error loading pregnancy weight records: $e');
    }
  }

  Future<void> _loadVaccinationRecords() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/vaccinations/mother/$_motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _vaccinationRecords = data.cast<Map<String, dynamic>>();
          // Sort by date descending (latest first)
          _vaccinationRecords.sort((a, b) {
            final dateA = DateTime.parse(a['vaccinationDate'] ?? '1970-01-01');
            final dateB = DateTime.parse(b['vaccinationDate'] ?? '1970-01-01');
            return dateB.compareTo(dateA);
          });
        });
      }
    } catch (e) {
      print('Error loading vaccination records: $e');
    }
  }

  Future<void> _loadAppointmentRecords() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/appointments/mother/$_motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _appointmentRecords = data.cast<Map<String, dynamic>>();
          // Sort by date descending (latest first)
          _appointmentRecords.sort((a, b) {
            final dateA = DateTime.parse(a['appointmentDate'] ?? '1970-01-01');
            final dateB = DateTime.parse(b['appointmentDate'] ?? '1970-01-01');
            return dateB.compareTo(dateA);
          });
        });
      }
    } catch (e) {
      print('Error loading appointment records: $e');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Not specified';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getPregnancyStatus() {
    if (_maternalProfile == null) return 'Unknown';
    final status = _maternalProfile!['pregnancyStatus'] ?? 'PREGNANT';
    switch (status) {
      case 'PREGNANT':
        return 'Currently Pregnant';
      case 'NOT_PREGNANT':
        return 'Not Pregnant';
      case 'DELIVERED':
        return 'Delivered';
      case 'POST_PARTUM':
        return 'Post-Partum Care';
      default:
        return status.toString().replaceAll('_', ' ');
    }
  }

  int _getCurrentPregnancyWeek() {
    if (_maternalProfile == null) return 0;
    return _maternalProfile!['currentPregnancyWeek'] ?? 0;
  }

  String? _getExpectedDeliveryDate() {
    if (_maternalProfile == null) return null;
    return _maternalProfile!['expectedDeliveryDate'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: AppBar(
        title: const Text(
          'My Pregnancy Records',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpotifyCircular',
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDataAndRecords,
            tooltip: 'Refresh Records',
          ),
        ],
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Profile', icon: Icon(Icons.person)),
                  Tab(text: 'Weight', icon: Icon(Icons.monitor_weight)),
                  Tab(text: 'Vaccines', icon: Icon(Icons.vaccines)),
                  Tab(text: 'Appointments', icon: Icon(Icons.calendar_today)),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(child: CustomLoading())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading records',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserDataAndRecords,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildWeightTab(),
                _buildVaccinationTab(),
                _buildAppointmentTab(),
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
          // Pregnancy Status Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.pregnant_woman,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPregnancyStatus(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_getCurrentPregnancyWeek() > 0)
                              Text(
                                'Week ${_getCurrentPregnancyWeek()}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_getExpectedDeliveryDate() != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EDD: ${_formatDate(_getExpectedDeliveryDate())}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Maternal Profile Details
          if (_maternalProfile != null) ...[
            _buildSectionCard('Medical Information', Icons.medical_services, [
              _buildInfoTile(
                'Blood Type',
                _maternalProfile!['bloodType'] ?? 'Not specified',
              ),
              _buildInfoTile(
                'Medical History',
                _maternalProfile!['medicalHistory'] ?? 'None recorded',
              ),
              _buildInfoTile(
                'Allergies',
                _maternalProfile!['allergies'] ?? 'None recorded',
              ),
              _buildInfoTile(
                'Current Medications',
                _maternalProfile!['currentMedications'] ?? 'None',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard('Emergency Contact', Icons.emergency, [
              _buildInfoTile(
                'Emergency Contact Name',
                _maternalProfile!['emergencyContactName'] ?? 'Not specified',
              ),
              _buildInfoTile(
                'Emergency Contact Phone',
                _maternalProfile!['emergencyContactPhone'] ?? 'Not specified',
              ),
              _buildInfoTile(
                'Healthcare Provider',
                _maternalProfile!['healthcareProvider'] ?? 'Not assigned',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard('Additional Notes', Icons.note_alt, [
              _buildInfoTile(
                'Notes',
                _maternalProfile!['notes'] ?? 'No notes recorded',
              ),
            ]),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No maternal profile found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your maternal profile will appear here once it\'s created by your healthcare provider.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightTab() {
    return _pregnancyWeightRecords.isEmpty
        ? _buildEmptyState(
            'No weight records found',
            Icons.monitor_weight,
            'Your pregnancy weight tracking records will appear here.',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pregnancyWeightRecords.length,
            itemBuilder: (context, index) {
              final record = _pregnancyWeightRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4FC3A1),
                    child: Text(
                      '${record['pregnancyWeek'] ?? '?'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    'Week ${record['pregnancyWeek'] ?? 'N/A'}: ${record['currentWeight'] ?? 'N/A'} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${_formatDate(record['measurementDate'])}'),
                      if (record['bloodPressure'] != null)
                        Text('BP: ${record['bloodPressure']}'),
                      if (record['notes'] != null &&
                          record['notes'].toString().isNotEmpty)
                        Text('Notes: ${record['notes']}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3A1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(record['measurementDate']),
                      style: const TextStyle(
                        color: Color(0xFF4FC3A1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildVaccinationTab() {
    return _vaccinationRecords.isEmpty
        ? _buildEmptyState(
            'No vaccination records found',
            Icons.vaccines,
            'Your vaccination records will appear here.',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _vaccinationRecords.length,
            itemBuilder: (context, index) {
              final record = _vaccinationRecords[index];
              final status = record['status'] ?? 'PENDING';
              final isCompleted = status == 'COMPLETED';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green : Colors.orange,
                    child: Icon(
                      isCompleted ? Icons.check : Icons.schedule,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    record['vaccinationType'] ?? 'Vaccination',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${_formatDate(record['vaccinationDate'])}'),
                      if (record['childName'] != null)
                        Text('For: ${record['childName']}'),
                      if (record['ageToGive'] != null)
                        Text('Age: ${record['ageToGive']}'),
                      Text('Status: $status'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAppointmentTab() {
    return _appointmentRecords.isEmpty
        ? _buildEmptyState(
            'No appointment records found',
            Icons.calendar_today,
            'Your appointment history will appear here.',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _appointmentRecords.length,
            itemBuilder: (context, index) {
              final record = _appointmentRecords[index];
              final status = record['status'] ?? 'PENDING';
              final isCompleted = status == 'COMPLETED';
              final isPending = status == 'PENDING';

              Color statusColor = Colors.grey;
              if (isCompleted) statusColor = Colors.green;
              if (isPending) statusColor = Colors.blue;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isPending
                          ? Icons.schedule
                          : Icons.event,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    record['appointmentType'] ?? 'Medical Appointment',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${_formatDate(record['appointmentDate'])}'),
                      if (record['timeSlot'] != null)
                        Text('Time: ${record['timeSlot']}'),
                      if (record['provider'] != null)
                        Text('Provider: ${record['provider']}'),
                      if (record['location'] != null)
                        Text('Location: ${record['location']}'),
                      Text('Status: $status'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4FC3A1)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D5A),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D5A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String description) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
