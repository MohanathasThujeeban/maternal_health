import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import LoginScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png', // Replace with the path to your logo
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              // Welcome Text
              const Text(
                '🎉 Welcome Mother! 🎉',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4FC3A1), // Match theme color
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Registration Successful!\nCheck your email for a special welcome message 📧',
                  style: TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 18,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Back to Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  // Navigate to LoginScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
