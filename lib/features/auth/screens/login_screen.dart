import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [                
                  const SizedBox(height: 16),
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    width: 250,
                    height: 250,
                  ),
                  const SizedBox(height: 32),
                  // Username field
                  _RoundedTextField(hint: 'user name'),
                  const SizedBox(height: 16),
                  // Password field
                  _RoundedTextField(hint: 'password', obscure: true),
                  const SizedBox(height: 24),
                  // Login button
                  _RoundedButton(
                    text: 'Login',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "if you don't have an account",
                    style: TextStyle(
                      fontFamily: 'SpotifyCircular', // Use Spotify Circular font
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RoundedButton(
                    text: 'Create account',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
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
  const _RoundedTextField({required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
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
        obscureText: obscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        style: const TextStyle(
          fontFamily: 'SpotifyCircular', // Use Spotify Circular font
          fontSize: 16,
        ),
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
    this.color = const Color(0xFF4DD0E1),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'SpotifyCircular', // Use Spotify Circular font
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}