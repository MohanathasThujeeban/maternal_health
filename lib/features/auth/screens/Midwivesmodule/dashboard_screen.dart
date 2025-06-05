import 'package:flutter/material.dart';
import '../login_screen.dart'; // Correct relative path to LoginScreen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Align header and buttons to center
          children: [
            // Header with logo, title, and logout button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between logo/title and logout button
                children: [
                  Row(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/logo.png', // Replace with the path to your logo
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 16),
                      // Dashboard title
                      const Text(
                        'Midwife Dash',
                        style: TextStyle(
                          fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4FC3A1), // Match theme color
                        ),
                        textAlign: TextAlign.center, // Center-align text
                      ),
                    ],
                  ),
                  // Logout button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      textStyle: const TextStyle(
                        fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                        fontSize: 16,
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
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Buttons
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Scheduling Button
                    _BigButton(
                      text: 'Scheduling',
                      onPressed: () {
                        // Add navigation or functionality for Scheduling
                     
                      },
                    ),
                    const SizedBox(height: 24),
                    // View and Update Reports Button
                    _BigButton(
                      text: 'View and Update Reports',
                      onPressed: () {
                        // Add navigation or functionality for View and Update Reports
                      },
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

class _BigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _BigButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3A1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          textStyle: const TextStyle(
            fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: onPressed,
        child: Center( // Center-align button text
          child: Text(
            text,
            textAlign: TextAlign.center, // Center-align text
          ),
        ),
      ),
    );
  }
}