import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'welcome_screen.dart';
import '../services/api_service.dart';
import '../../../widgets/custom_loading.dart';

class HealthcareProviderRegistrationScreen extends StatefulWidget {
  const HealthcareProviderRegistrationScreen({super.key});

  @override
  State<HealthcareProviderRegistrationScreen> createState() =>
      _HealthcareProviderRegistrationScreenState();
}

class _HealthcareProviderRegistrationScreenState
    extends State<HealthcareProviderRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _fullNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _medicalLicenseController = TextEditingController();
  final _institutionController = TextEditingController();
  final _specializationController = TextEditingController();
  final _yearsExperienceController = TextEditingController();

  String _selectedRole = 'MIDWIFE';
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const CustomLoading()
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressIndicator(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentStep = index;
                            });
                          },
                          children: [
                            _buildPersonalInfoStep(),
                            _buildProfessionalInfoStep(),
                            _buildCredentialsStep(),
                            _buildReviewStep(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step ${_currentStep + 1} of 4',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Join Our Medical Team',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'SpotifyCircular',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'SpotifyCircular',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? const Color(0xFF6366F1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Personal Information',
              'Tell us about yourself',
              Icons.person_outline,
            ),
            const SizedBox(height: 24),
            _buildGlassTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _nicController,
              label: 'NIC Number',
              icon: Icons.credit_card,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your NIC number';
                }
                if (value.length != 10 && value.length != 12) {
                  return 'Please enter a valid NIC number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Professional Role',
            'Select your medical specialization',
            Icons.work_outline,
          ),
          const SizedBox(height: 24),
          _buildRoleSelector(),
          const SizedBox(height: 20),
          _buildGlassTextField(
            controller: _specializationController,
            label: 'Specialization (Optional)',
            icon: Icons.psychology_outlined,
            hint: 'e.g., Obstetrics, Pediatrics',
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _yearsExperienceController,
            label: 'Years of Experience',
            icon: Icons.timeline,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final years = int.tryParse(value);
                if (years == null || years < 0 || years > 50) {
                  return 'Please enter valid years of experience (0-50)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCredentialsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Medical Credentials',
            'Verify your professional qualifications',
            Icons.verified_user_outlined,
          ),
          const SizedBox(height: 24),
          _buildGlassTextField(
            controller: _medicalLicenseController,
            label: 'Medical License Number',
            icon: Icons.card_membership,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your medical license number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _institutionController,
            label: 'Hospital/Institution Name',
            icon: Icons.local_hospital_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your institution name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildGlassPasswordField(
            controller: _passwordController,
            label: 'Create Password',
            showPassword: _showPassword,
            onToggleVisibility: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildGlassPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            showPassword: _showConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Review Information',
            'Please review your details before submitting',
            Icons.checklist_outlined,
          ),
          const SizedBox(height: 24),
          _buildReviewCard('Personal Information', [
            {'label': 'Name', 'value': _fullNameController.text},
            {'label': 'NIC', 'value': _nicController.text},
            {'label': 'Phone', 'value': _phoneController.text},
            {'label': 'Email', 'value': _emailController.text},
          ]),
          const SizedBox(height: 16),
          _buildReviewCard('Professional Information', [
            {'label': 'Role', 'value': _selectedRole},
            {
              'label': 'Specialization',
              'value': _specializationController.text.isEmpty
                  ? 'Not specified'
                  : _specializationController.text,
            },
            {
              'label': 'Experience',
              'value': _yearsExperienceController.text.isEmpty
                  ? 'Not specified'
                  : '${_yearsExperienceController.text} years',
            },
            {'label': 'Institution', 'value': _institutionController.text},
            {
              'label': 'License Number',
              'value': _medicalLicenseController.text,
            },
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your registration will be reviewed by our medical team. You will receive an email notification once approved.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontFamily: 'SpotifyCircular',
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !showPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF6366F1),
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontFamily: 'SpotifyCircular',
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRoleOption(
            'MIDWIFE',
            'Midwife',
            'Specialized in maternal and newborn care',
            Icons.child_care,
          ),
          const Divider(height: 1),
          _buildRoleOption(
            'DOCTOR',
            'Doctor',
            'Medical doctor specializing in maternal health',
            Icons.medical_services,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedRole == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6366F1),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1F2937),
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              activeColor: isSelected ? Colors.white : const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(String title, List<Map<String, String>> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                fontFamily: 'SpotifyCircular',
              ),
            ),
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      item['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['value']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                        fontFamily: 'SpotifyCircular',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _currentStep == 3 ? _handleRegistration : _nextStep,
              style:
                  ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    _currentStep == 3 ? 'Register' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Let\'s start with your basic information';
      case 1:
        return 'Tell us about your medical expertise';
      case 2:
        return 'Verify your professional credentials';
      case 3:
        return 'Ready to join our medical team?';
      default:
        return 'Complete your registration';
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _fullNameController.text.isNotEmpty &&
            _nicController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _emailController.text.contains('@');
      case 1:
        return true; // Role is always selected, other fields are optional
      case 2:
        return _medicalLicenseController.text.isNotEmpty &&
            _institutionController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text;
      default:
        return true;
    }
  }

  Future<void> _handleRegistration() async {
    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/healthcare/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': _fullNameController.text.trim(),
          'nicNumber': _nicController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'password': _passwordController.text,
          'providerType': _selectedRole,
          'medicalLicenseNumber': _medicalLicenseController.text.trim(),
          'institution': _institutionController.text.trim(),
          'specialization': _specializationController.text.trim().isEmpty
              ? null
              : _specializationController.text.trim(),
          'yearsOfExperience': _yearsExperienceController.text.trim().isEmpty
              ? null
              : int.tryParse(_yearsExperienceController.text.trim()),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['error'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
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
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _fullNameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _medicalLicenseController.dispose();
    _institutionController.dispose();
    _specializationController.dispose();
    _yearsExperienceController.dispose();
    super.dispose();
  }
}
