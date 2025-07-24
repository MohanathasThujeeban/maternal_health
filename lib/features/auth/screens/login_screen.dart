import 'package:flutter/material.dart';
import 'register3_screen.dart';
import 'registration_data.dart';
import 'Midwivesmodule/dashboard_screen.dart';
import '../services/api_service.dart';

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back! ${result['message']}'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to dashboard or home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DashboardScreen(), // You can create a user dashboard
          ),
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
      backgroundColor: Colors.white,
      body: Stack(
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
                  ),
                  const SizedBox(height: 12),
                  // Create account text
                  const Text(
                    "If you don't have an account",
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 13,
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
      width: 250,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF4FC3A1)),
          ),
          filled: true,
          fillColor: Colors.grey[200],
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
      width: 250,
      height: 48,
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
