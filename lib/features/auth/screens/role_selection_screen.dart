import 'package:flutter/material.dart';
import 'register3_screen.dart';
import 'healthcare_provider_registration_screen.dart';
import 'registration_data.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4FC3A1), Color(0xFF2E8B77)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3A1).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome to Maternal Health',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E8B77),
                  fontFamily: 'SpotifyCircular',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please select your role to continue with registration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
              const SizedBox(height: 50),

              // Role Selection Cards
              Expanded(
                child: Column(
                  children: [
                    // Mother Registration Card
                    _buildRoleCard(
                      context: context,
                      title: 'I am a Mother',
                      subtitle: 'Register as a pregnant mother or new mother',
                      icon: Icons.favorite_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FC3A1), Color(0xFF2E8B77)],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register3Screen(
                              registrationData: RegistrationData(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Healthcare Provider Registration Card
                    _buildRoleCard(
                      context: context,
                      title: 'I am a Healthcare Provider',
                      subtitle:
                          'Register as a midwife, doctor, or medical professional',
                      icon: Icons.medical_services_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HealthcareProviderRegistrationScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'SpotifyCircular',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Go back to login
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF4FC3A1),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpotifyCircular',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E8B77),
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  const SizedBox(height: 5),
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
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF4FC3A1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
