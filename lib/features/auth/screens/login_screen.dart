import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import 'role_selection_screen.dart';
import 'Midwivesmodule/dashboard_screen.dart';
import 'Mothermodule/motherhome.dart';
import 'Doctormodule/doctor_dashboard.dart';
import 'healthcare_provider_login_screen.dart';
import '../services/api_service.dart';
import '../../../services/user_service.dart';
import '../../../widgets/custom_loading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nicController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      print('🔗 Testing backend connection to: ${ApiService.baseUrl}');
    } catch (e) {
      print('⚠️ Connection test failed: $e');
    }
  }

  Future<void> _handleLogin() async {
    // Validate input
    if (nicController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter NIC Number and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('🔑 Starting login process...');
      final result = await ApiService.login(
        nicController.text.trim(),
        passwordController.text.trim(),
      );

      print('📊 Login result: $result');

      if (!mounted) return;

      if (result['success']) {
        // Save user data to local storage with role-specific fields
        await UserService.saveUserData(
          nic: result['nicNumber'] ?? '',
          email: result['email'] ?? '',
          medicalLicense: result['medicalLicenseNumber'],
          institution: result['institution'],
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back! ${result['message']}'),
            backgroundColor: const Color(0xFF4FC3A1),
          ),
        );

        // Route based on user role
        final String userRole = result['userRole'] ?? 'MOTHER';
        print('👤 User role: $userRole');

        if (userRole == 'MIDWIFE') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else if (userRole == 'DOCTOR') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDashboard()),
          );
        } else {
          // Default to mother home for MOTHER role or any other case
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MotherHomeScreen()),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      String errorMessage = 'Login failed';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'Cannot connect to server. Please check:\n'
            '1. Backend server is running\n'
            '2. You are on ITUM WiFi (10.11.6.107)\n'
            '3. Server is at port 8080';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Server may be down.';
      } else {
        errorMessage = 'Login failed: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 7),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show full-screen loading when logging in
    if (isLoading) {
      return Scaffold(
        body: CustomLoading(
          message: 'Logging you in...',
          backgroundColor: const Color(0xFFF0F9F7),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5F2), // Light mint
              Color(0xFFF0F9F7), // Very light mint
              Color(0xFFFFFFFF), // White
              Color(0xFFF5FFFE), // Almost white with hint of mint
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Logo
                    Image.asset('assets/logo.png', width: 240, height: 240),
                    const SizedBox(height: 32),
                    // NIC Number field
                    _RoundedTextField(
                      hint: 'NIC Number',
                      controller: nicController,
                      obscure: false,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    _RoundedTextField(
                      hint: 'Password',
                      obscure: true,
                      controller: passwordController,
                    ),
                    const SizedBox(height: 16),
                    // Login button
                    _RoundedButton(
                      text: 'Login',
                      onPressed: isLoading ? () {} : _handleLogin,
                      color: const Color(0xFF4FC3A1),
                    ),
                    const SizedBox(height: 13),

                    // Forgot Password button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontSize: 17,
                          color: Color(0xFF4FC3A1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Divider with text
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or',
                            style: TextStyle(
                              fontFamily: 'SpotifyCircular',
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Healthcare Provider Login button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HealthcareProviderLoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF2E7D5A),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                      icon: const Icon(
                        Icons.medical_services,
                        color: Color(0xFF2E7D5A),
                        size: 20,
                      ),
                      label: const Text(
                        'Healthcare Provider Login',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular',
                          fontSize: 16,
                          color: Color(0xFF2E7D5A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    // Create account text
                    const Text(
                      "If you don't have an account",
                      style: TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Create account button
                    _RoundedButton(
                      text: 'Create account',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen(),
                          ),
                        );
                      },
                      color: const Color(0xFF4FC3A1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatefulWidget {
  final String hint;
  final bool obscure;
  final TextEditingController controller;

  const _RoundedTextField({
    required this.hint,
    this.obscure = false,
    required this.controller,
  });

  @override
  State<_RoundedTextField> createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<_RoundedTextField> {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        decoration: InputDecoration(
          hintText: widget.hint,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF4FC3A1), width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF4FC3A1),
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
        style: const TextStyle(fontFamily: 'SpotifyCircular', fontSize: 15),
      ),
    );
  }
}

class _RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const _RoundedButton({
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF1DB954),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
