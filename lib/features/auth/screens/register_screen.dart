import 'package:flutter/material.dart';
import 'register2_screen.dart'; // Import Register2Screen

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: Colors.black54,
              ),
              const SizedBox(height: 8),
              _RoundedTextField(hint: 'Full Name of mother'),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Full Name of father'),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Address'),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Phone number'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _RoundedTextField(hint: 'Age')),
                  const SizedBox(width: 12),
                  Expanded(child: _RoundedTextField(hint: 'Occupation')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _RoundedTextField(hint: 'Ethnicity')),
                  const SizedBox(width: 12),
                  Expanded(child: _RoundedTextField(hint: 'Religion')),
                ],
              ),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Educational level'),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Register2Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Register2Screen()),
                      );
                    },
                    child: const Text('Next'),
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
  const _RoundedTextField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        style: const TextStyle(
          fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
          fontSize: 16,
        ),
      ),
    );
  }
}