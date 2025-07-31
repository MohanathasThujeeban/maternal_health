import 'package:flutter/material.dart';
import 'register3_screen.dart';
import 'registration_data.dart';
import 'forgot_password_screen.dart';
import 'Midwivesmodule/dashboard_screen.dart';
import 'Mothermodule/motherhome.dart';
import 'Doctormodule/doctor_dashboard.dart';
import '../services/api_service.dart';
import '../../../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nicController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleLogin() async {
    // Check for hardcoded midwife credentials first
    if (nicController.text == 'Mid_wife' &&
        passwordController.text == 'Mid123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      return;
    }

    // Check for hardcoded doctor credentials
    if (nicController.text == 'Doctor' && passwordController.text == 'Doc123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DoctorDashboard()),
      );
      return;
    }

    // Validate input
    if (nicController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both NIC number and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.login(
        nicController.text.trim(),
        passwordController.text.trim(),
      );

      if (result['success']) {
        // Save user data to local storage
        await UserService.saveUserData(
          nic: result['nicNumber'] ?? '',
          name: result['fullName'] ?? '',
          email: result['email'] ?? '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back! ${result['message']}'),
            backgroundColor: const Color(0xFF4FC3A1),
          ),
        );

        // Navigate to mother home for regular users (NIC + password)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MotherHomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Image.asset('assets/logo.png', width: 250, height: 250),
                    const SizedBox(height: 32),
                    // NIC Number field
                    _RoundedTextField(
                      hint: 'NIC Number',
                      controller: nicController,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    _RoundedTextField(
                      hint: 'Password',
                      obscure: true,
                      controller: passwordController,
                    ),
                    const SizedBox(height: 24),
                    // Login button
                    _RoundedButton(
                      text: isLoading ? 'Logging in...' : 'Login',
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
                        final registrationData = RegistrationData();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register3Screen(
                              registrationData: registrationData,
                            ),
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

class _RoundedTextField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController controller;

  const _RoundedTextField({
    required this.hint,
    this.obscure = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
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
