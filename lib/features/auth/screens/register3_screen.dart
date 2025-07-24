import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'registration_data.dart';
import '../services/api_service.dart';
import 'dart:async';

class Register3Screen extends StatefulWidget {
  final RegistrationData registrationData;
  const Register3Screen({super.key, required this.registrationData});

  @override
  State<Register3Screen> createState() => _Register3ScreenState();
}

class _Register3ScreenState extends State<Register3Screen> {
  final nicController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  bool emailVerified = false;
  bool verifying = false;
  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    // Only use data if it was provided from previous screens
    nicController.text = widget.registrationData.nicNumber;
    phoneController.text = widget.registrationData.phoneNumber3;
    passwordController.text = widget.registrationData.password;
    emailController.text = widget.registrationData.email;
  }

  @override
  void dispose() {
    nicController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool validateForm() {
    if (nicController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return false;
    }

    // Validate NIC number format (12 digits)
    if (nicController.text.length != 12 ||
        !RegExp(r'^\d{12}$').hasMatch(nicController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIC number must be exactly 12 digits')),
      );
      return false;
    }

    // Validate phone number format
    if (phoneController.text.length < 10 ||
        !RegExp(r'^\d+$').hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return false;
    }

    // Validate password length
    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return false;
    }

    return true;
  }

  Future<void> verifyEmail() async {
    setState(() {
      verifying = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    final email = emailController.text.trim();
    if (email.contains('@') && email.contains('.')) {
      setState(() {
        emailVerified = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email verified!')));
    } else {
      setState(() {
        emailVerified = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid email address')));
    }
    setState(() {
      verifying = false;
    });
  }

  Future<void> submitRegistration() async {
    try {
      if (!validateForm()) return;

      setState(() {
        isLoading = true;
      });

      widget.registrationData.nicNumber = nicController.text;
      widget.registrationData.phoneNumber3 = phoneController.text;
      widget.registrationData.password = passwordController.text;
      widget.registrationData.email = emailController.text;

      print('Sending registration data: ${widget.registrationData.toJson()}');

      final result = await ApiService.register(
        widget.registrationData.toJson(),
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      } else {
        throw Exception('Registration failed: ${result['message']}');
      }
    } catch (e) {
      print('Error during registration: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration error: $e')));
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: Colors.black54,
              ),
              const SizedBox(height: 8),

              // Add "Fill Demo Data" button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      nicController.text = '200201901851';
                      phoneController.text = '0777777777';
                      emailController.text = 'demo@example.com';
                      passwordController.text = 'Demo123';
                      emailVerified = true; // Auto-verify for demo
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo data filled!')),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Fill Demo Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3A1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'NIC Number',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(
                hint: 'Enter 12-digit NIC Number (e.g., 200201901851)',
                controller: nicController,
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),
              const SizedBox(height: 12),
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(
                hint: 'Enter Phone Number (e.g., 0777777777)',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              const Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Enter Email',
                      controller: emailController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: verifying ? null : verifyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emailVerified
                          ? Colors.green
                          : const Color(0xFF4FC3A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: verifying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(emailVerified ? 'Verified' : 'Verify'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Password',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      hint: 'Enter Password (min 6 characters)',
                      controller: passwordController,
                      obscureText: !showPassword,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emailVerified && !isLoading
                          ? const Color(0xFF4FC3A1)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontFamily: 'SpotifyCircular',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: emailVerified && !isLoading
                        ? submitRegistration
                        : null,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;

  const _RoundedTextField({
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          counterText: maxLength != null ? '' : null, // Hide character counter
          hintStyle: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        style: const TextStyle(fontFamily: 'SpotifyCircular', fontSize: 16),
      ),
    );
  }
}
