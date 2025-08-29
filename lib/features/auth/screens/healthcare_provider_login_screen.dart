import 'package:flutter/material.dart';
import 'Midwivesmodule/dashboard_screen.dart';
import 'Doctormodule/doctor_dashboard.dart';
import '../services/api_service.dart';
import '../../../services/user_service.dart';
import '../../../widgets/custom_loading.dart';
import 'healthcare_provider_forgot_password_screen.dart';

class HealthcareProviderLoginScreen extends StatefulWidget {
  const HealthcareProviderLoginScreen({super.key});

  @override
  State<HealthcareProviderLoginScreen> createState() =>
      _HealthcareProviderLoginScreenState();
}

class _HealthcareProviderLoginScreenState
    extends State<HealthcareProviderLoginScreen> {
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _showPassword = false;

  Future<void> _handleLogin() async {
    // Validate input
    if (licenseController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter both medical license number and password',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.healthcareLogin(
        licenseController.text.trim(),
        passwordController.text.trim(),
      );

      if (result['success']) {
        // Save healthcare provider data to local storage
        await UserService.saveHealthcareProviderData(
          licenseNumber: result['medicalLicenseNumber'] ?? '',
          name: result['fullName'] ?? '',
          email: result['email'] ?? '',
<<<<<<< HEAD
          medicalLicense: result['medicalLicenseNumber'],
          institution: result['institution'],
=======
          role: result['userRole'] ?? 'MIDWIFE',
          clinic: result['clinic'],
>>>>>>> 08691a4c837f02bf3c5f1494dda36e95f9aac753
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${result['fullName']}!'),
            backgroundColor: const Color(0xFF4FC3A1),
          ),
        );

        // Route based on provider type
        final String providerType = result['userRole'] ?? 'MIDWIFE';

        if (providerType == 'MIDWIFE') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else if (providerType == 'DOCTOR') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(providerData: result),
            ),
          );
        }
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF4FC3A1),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Healthcare Provider Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4FC3A1),
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Healthcare Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4FC3A1), Color(0xFF3DA58A)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          'Sign in to your healthcare provider account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Medical License Number field
                        _RoundedTextField(
                          hint: 'Medical License Number',
                          controller: licenseController,
                          icon: Icons.card_membership,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _RoundedPasswordField(
                          hint: 'Password',
                          controller: passwordController,
                          showPassword: _showPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 32),

                        // Login button
                        _RoundedButton(
                          text: 'Sign In',
                          onPressed: isLoading ? () {} : _handleLogin,
                          color: const Color(0xFF4FC3A1),
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HealthcareProviderForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_reset,
                                  color: const Color(0xFF4FC3A1),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: const Color(0xFF4FC3A1),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'SpotifyCircular',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3A1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4FC3A1).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF4FC3A1),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Use your medical license number and password to sign in. Your account must be approved by admin.',
                                  style: TextStyle(
                                    color: const Color(0xFF4FC3A1),
                                    fontSize: 14,
                                    fontFamily: 'SpotifyCircular',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
  final TextEditingController controller;
  final IconData icon;

  const _RoundedTextField({
    required this.hint,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF4FC3A1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF4FC3A1)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 24,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        style: const TextStyle(fontFamily: 'SpotifyCircular', fontSize: 15),
      ),
    );
  }
}

class _RoundedPasswordField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool showPassword;
  final VoidCallback onToggleVisibility;

  const _RoundedPasswordField({
    required this.hint,
    required this.controller,
    required this.showPassword,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF4FC3A1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4FC3A1)),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF4FC3A1),
            ),
            onPressed: onToggleVisibility,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 24,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
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
    this.color = const Color(0xFF4FC3A1),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
