import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'registration_data.dart';
import '../services/api_service.dart';
import 'dart:async';
import '../../../widgets/custom_loading.dart';

class Register3Screen extends StatefulWidget {
  final RegistrationData registrationData;
  const Register3Screen({super.key, required this.registrationData});

  @override
  State<Register3Screen> createState() => _Register3ScreenState();
}

class _Register3ScreenState extends State<Register3Screen> {
  final fullNameController = TextEditingController();
  final nicController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool isEmailVerified = false;
  bool isVerifying = false;
  bool isCheckingVerification = false;
  bool hasShownVerificationMessage = false;

  @override
  void initState() {
    super.initState();
    // Only use data if it was provided from previous screens
    fullNameController.text = widget.registrationData.fullName;
    nicController.text = widget.registrationData.nicNumber;
    phoneController.text = widget.registrationData.phoneNumber3;
    passwordController.text = widget.registrationData.password;
    emailController.text = widget.registrationData.email;

    // Add listener to email field to check verification status
    emailController.addListener(() {
      // Reset verification message flag when email changes
      hasShownVerificationMessage = false;

      // Only check verification if email is valid and not empty and not already checking
      final email = emailController.text.trim();
      if (email.isNotEmpty &&
          email.contains('@') &&
          email.contains('.') &&
          !isCheckingVerification) {
        checkEmailVerificationStatus();
      } else if (email.isEmpty ||
          !email.contains('@') ||
          !email.contains('.')) {
        setState(() {
          isEmailVerified = false;
        });
      }
    });
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
    if (fullNameController.text.isEmpty ||
        nicController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return false;
    }

    // Validate full name (at least 2 characters, only letters and spaces)
    if (fullNameController.text.length < 2 ||
        !RegExp(r'^[a-zA-Z\s]+$').hasMatch(fullNameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid full name')),
      );
      return false;
    }

    // Validate NIC number format (12 digits)
    if (nicController.text.length != 12 ||
        !RegExp(r'^\d{12}$').hasMatch(nicController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIC number must be 12 digits')),
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
    if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return false;
    }

    // Validate email
    if (!validateEmail(showErrors: true)) {
      return false;
    }

    return true;
  }

  bool validateEmail({bool showErrors = true}) {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      if (showErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an email address')),
        );
      }
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      if (showErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address')),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> submitRegistration() async {
    try {
      if (!validateForm()) return;

      // Check if email is verified before proceeding
      if (!isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email before registering'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      widget.registrationData.fullName = fullNameController.text;
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
        // Registration successful - redirect to welcome screen
        // Removed SnackBar popup as requested
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

  Future<void> sendVerificationEmail() async {
    if (!validateEmail(showErrors: true)) return;

    setState(() {
      isVerifying = true;
    });

    try {
      final response = await ApiService.sendVerificationEmail(
        emailController.text.trim(),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: const Color(0xFF4FC3A1),
          ),
        );

        // Start checking verification status
        _startVerificationPolling();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  void _startVerificationPolling() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        final response = await ApiService.checkEmailVerification(
          emailController.text.trim(),
        );

        if (response['success'] && response['verified']) {
          setState(() {
            isEmailVerified = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email verified successfully! You can now complete registration.',
              ),
              backgroundColor: Color(0xFF4FC3A1),
            ),
          );

          timer.cancel();
        }
      } catch (e) {
        print('Error checking verification status: $e');
      }
    });
  }

  Future<void> checkEmailVerificationStatus() async {
    if (emailController.text.trim().isEmpty) return;

    setState(() {
      isCheckingVerification = true;
    });

    try {
      final response = await ApiService.checkEmailVerification(
        emailController.text.trim(),
      );

      if (response['success']) {
        setState(() {
          isEmailVerified = response['verified'];
        });

        if (isEmailVerified && !hasShownVerificationMessage) {
          setState(() {
            hasShownVerificationMessage = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email is already verified!'),
              backgroundColor: Color(0xFF4FC3A1),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking verification status: $e');
    } finally {
      setState(() {
        isCheckingVerification = false;
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
        child: SafeArea(
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

                const SizedBox(height: 16),
                const Text(
                  'Full Name',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _RoundedTextField(
                  hint: 'Enter your full name (e.g., Sarah Johnson)',
                  controller: fullNameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 12),
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
                  hint: 'Enter 12-digit NIC (e.g., 200201901851)',
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
                  hint: 'Phone Number (e.g., 0777777777)',
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
                        hint: 'Email (e.g., user@example.com)',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Email verification button
                    ElevatedButton.icon(
                      onPressed: isVerifying ? null : sendVerificationEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEmailVerified
                            ? Colors.green
                            : (isVerifying
                                  ? Colors.grey
                                  : const Color(0xFF4FC3A1)),
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
                      icon: isVerifying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: MiniLoading(size: 16, color: Colors.white),
                            )
                          : Icon(
                              isEmailVerified
                                  ? Icons.check_circle
                                  : Icons.email,
                              size: 18,
                            ),
                      label: Text(
                        isEmailVerified
                            ? 'Verified'
                            : (isVerifying ? 'Sending...' : 'Verify'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (isEmailVerified)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Email verified successfully!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isEmailVerified && emailController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please verify your email to continue with registration',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        hint: 'Enter Password (min 8 characters)',
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
                        backgroundColor: !isLoading
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
                      onPressed: !isLoading ? submitRegistration : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: MiniLoading(size: 20, color: Colors.white),
                            )
                          : const Text('Sign Up'),
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
      width: 300,
      decoration: BoxDecoration(
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
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
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
