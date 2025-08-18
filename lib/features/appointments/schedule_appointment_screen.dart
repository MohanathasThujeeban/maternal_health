import 'package:flutter/material.dart';
import '../../../services/appointment_service.dart';
import '../../../services/user_service.dart';
import '../../../widgets/custom_loading.dart';
import './appointments_list_screen.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _additionalProblemsController = TextEditingController();

  String _appointmentType = 'doctor';
  String? _selectedProvider;
  String? _selectedProviderId;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;

  // User data
  String? motherNic;
  String? motherName;
  String? motherEmail;

  // Dynamic providers
  Map<String, List<Map<String, String>>> _availableProviders = {};
  bool _providersLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvailableProviders();
  }

  Future<void> _loadAvailableProviders() async {
    print('=== Loading providers for appointment scheduling ===');
    setState(() {
      _providersLoading = true;
    });

    try {
      final providers = await AppointmentService.getAvailableProviders();
      print('Loaded providers in appointment screen: $providers');
      setState(() {
        _availableProviders = providers;
        _providersLoading = false;
      });
    } catch (e) {
      print('Error loading providers: $e');
      // Fallback to static providers
      print('Using fallback static providers');
      setState(() {
        _availableProviders = AppointmentService.providers;
        _providersLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    print('Loading user data...');

    // Force fix user data first
    await UserService.forceFixUserData();

    final userData = await UserService.getUserData();
    print('User data from service: $userData');

    setState(() {
      motherNic = userData['nic'];
      motherName = userData['name'];
      motherEmail = userData['email'];
      _emailController.text = motherEmail ?? '';
    });

    print(
      'Final user data: NIC=$motherNic, Name=$motherName, Email=$motherEmail',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _additionalProblemsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
        _selectedTimeSlot = null;
        _availableTimeSlots = [];
      });

      if (_selectedProviderId != null) {
        await _loadAvailableTimeSlots();
      }
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null || _selectedProviderId == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await AppointmentService.getAvailableTimeSlots(
      _selectedDate!,
      _selectedProviderId!,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _availableTimeSlots = List<String>.from(result['availableSlots']);
      } else {
        _availableTimeSlots = AppointmentService.timeSlots;
      }
    });
  }

  Future<void> _scheduleAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate user data is loaded
    if (motherName == null || motherName!.trim().isEmpty) {
      _showErrorDialog(
        'Unable to load your profile information. Please logout and login again.',
      );
      return;
    }

    if (motherNic == null || motherNic!.trim().isEmpty) {
      _showErrorDialog(
        'Unable to load your NIC information. Please logout and login again.',
      );
      return;
    }

    if (_selectedDate == null ||
        _selectedTimeSlot == null ||
        _selectedProvider == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AppointmentService.scheduleAppointment(
      motherNic: motherNic!,
      motherName: motherName!,
      motherEmail: _emailController.text.trim(),
      appointmentType: _appointmentType,
      providerName: _selectedProvider!,
      providerId: _selectedProviderId!,
      appointmentDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      additionalProblems: _additionalProblemsController.text.trim().isEmpty
          ? null
          : _additionalProblemsController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(result['message']);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4FC3A1), size: 28),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: const Text(
          'Your appointment has been scheduled successfully! You will receive an email confirmation and a reminder before your appointment.',
          style: TextStyle(fontFamily: 'SpotifyCircular'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to appointments tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3A1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'SpotifyCircular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'SpotifyCircular',
                color: Color(0xFF4FC3A1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule Appointment',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentsListScreen(),
                ),
              );
            },
            tooltip: 'My Appointments',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F2), Color(0xFFFFFFFF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // NIC Display (Read-only)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patient Information',
                          style: TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Color(0xFF4FC3A1)),
                            const SizedBox(width: 8),
                            Text(
                              'NIC: ${motherNic ?? 'Loading...'}',
                              style: const TextStyle(
                                fontFamily: 'SpotifyCircular',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.badge, color: Color(0xFF4FC3A1)),
                            const SizedBox(width: 8),
                            Text(
                              'Name: ${motherName ?? 'Loading...'}',
                              style: const TextStyle(
                                fontFamily: 'SpotifyCircular',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'Enter your email for notifications',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF4FC3A1),
                    ),
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
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Appointment Type
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Appointment Type *',
                          style: TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D5A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Doctor',
                                  style: TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                  ),
                                ),
                                value: 'doctor',
                                groupValue: _appointmentType,
                                activeColor: const Color(0xFF4FC3A1),
                                onChanged: (value) {
                                  setState(() {
                                    _appointmentType = value!;
                                    _selectedProvider = null;
                                    _selectedProviderId = null;
                                    _availableTimeSlots = [];
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Midwife',
                                  style: TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                  ),
                                ),
                                value: 'midwife',
                                groupValue: _appointmentType,
                                activeColor: const Color(0xFF4FC3A1),
                                onChanged: (value) {
                                  setState(() {
                                    _appointmentType = value!;
                                    _selectedProvider = null;
                                    _selectedProviderId = null;
                                    _availableTimeSlots = [];
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Provider Selection
                _providersLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF4FC3A1),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText:
                              'Select ${_appointmentType == 'doctor' ? 'Doctor' : 'Midwife'} *',
                          prefixIcon: Icon(
                            _appointmentType == 'doctor'
                                ? Icons.local_hospital
                                : Icons.pregnant_woman,
                            color: const Color(0xFF4FC3A1),
                          ),
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
                        value: _selectedProvider,
                        items: (_availableProviders[_appointmentType] ?? []).map((
                          provider,
                        ) {
                          return DropdownMenuItem<String>(
                            value: '${provider['name']} - ${provider['title']}',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${provider['name']}',
                                  style: const TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${provider['title']}',
                                  style: const TextStyle(
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (provider['institution']?.isNotEmpty == true)
                                  Text(
                                    '${provider['institution']} • ${provider['yearsOfExperience']} years',
                                    style: const TextStyle(
                                      fontFamily: 'SpotifyCircular',
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          final provider =
                              (_availableProviders[_appointmentType] ?? [])
                                  .firstWhere(
                                    (p) =>
                                        '${p['name']} - ${p['title']}' == value,
                                  );

                          setState(() {
                            _selectedProvider = value;
                            _selectedProviderId = provider['id'];
                            _selectedTimeSlot = null;
                            _availableTimeSlots = [];
                          });

                          if (_selectedDate != null) {
                            await _loadAvailableTimeSlots();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a ${_appointmentType == 'doctor' ? 'doctor' : 'midwife'}';
                          }
                          return null;
                        },
                      ),

                const SizedBox(height: 16),

                // Date Selection
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF4FC3A1),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Select Date *'
                              : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            fontFamily: 'SpotifyCircular',
                            fontSize: 16,
                            color: _selectedDate == null
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Time Slot Selection
                if (_availableTimeSlots.isNotEmpty) ...[
                  const Text(
                    'Available Time Slots *',
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D5A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTimeSlots.map((slot) {
                      final isSelected = _selectedTimeSlot == slot;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4FC3A1)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4FC3A1)
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontFamily: 'SpotifyCircular',
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Additional Problems
                TextFormField(
                  controller: _additionalProblemsController,
                  decoration: InputDecoration(
                    labelText: 'Additional Health Problems (Optional)',
                    hintText: 'Describe any specific concerns or symptoms',
                    prefixIcon: const Icon(
                      Icons.medical_information,
                      color: Color(0xFF4FC3A1),
                    ),
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
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                // Schedule Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _scheduleAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: MiniLoading(size: 20, color: Colors.white),
                          )
                        : const Text(
                            'Schedule Appointment',
                            style: TextStyle(
                              fontFamily: 'SpotifyCircular',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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
