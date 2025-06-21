import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'registration_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    nicController.text = widget.registrationData.nicNumber;
    phoneController.text = widget.registrationData.phoneNumber3;
    passwordController.text = widget.registrationData.password;
  }

  @override
  void dispose() {
    nicController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submitRegistration() async {
    widget.registrationData.nicNumber = nicController.text;
    widget.registrationData.phoneNumber3 = phoneController.text;
    widget.registrationData.password = passwordController.text;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/registration'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(widget.registrationData.toJson()),
    );

    // Debug prints to help you see what happens
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.body}')),
      );
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
              const Text(
                'NIC Number',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(hint: 'Enter NIC Number', controller: nicController),
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
              _RoundedTextField(hint: 'Enter Phone Number', controller: phoneController),
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
              _RoundedTextField(hint: 'Enter Password', controller: passwordController, obscureText: true),
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
                        fontFamily: 'SpotifyCircular',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: submitRegistration,
                    child: const Text('Sign Up'),
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
  const _RoundedTextField({required this.hint, this.controller, this.obscureText = false});

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
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        style: const TextStyle(
          fontFamily: 'SpotifyCircular',
          fontSize: 16,
        ),
      ),
    );
  }
}