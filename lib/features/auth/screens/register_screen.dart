import 'package:flutter/material.dart';
import 'register2_screen.dart';
import 'registration_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final motherNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final occupationController = TextEditingController();
  final ethnicityController = TextEditingController();
  final religionController = TextEditingController();
  final educationController = TextEditingController();

  @override
  void dispose() {
    motherNameController.dispose();
    fatherNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    ageController.dispose();
    occupationController.dispose();
    ethnicityController.dispose();
    religionController.dispose();
    educationController.dispose();
    super.dispose();
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
              _RoundedTextField(hint: 'Full Name of mother', controller: motherNameController),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Full Name of father', controller: fatherNameController),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Address', controller: addressController),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Phone number', controller: phoneController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _RoundedTextField(hint: 'Age', controller: ageController)),
                  const SizedBox(width: 12),
                  Expanded(child: _RoundedTextField(hint: 'Occupation', controller: occupationController)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _RoundedTextField(hint: 'Ethnicity', controller: ethnicityController)),
                  const SizedBox(width: 12),
                  Expanded(child: _RoundedTextField(hint: 'Religion', controller: religionController)),
                ],
              ),
              const SizedBox(height: 12),
              _RoundedTextField(hint: 'Educational level', controller: educationController),
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
                    onPressed: () {
                      final registrationData = RegistrationData();
                      registrationData.motherFullName = motherNameController.text;
                      registrationData.fatherFullName = fatherNameController.text;
                      registrationData.address = addressController.text;
                      registrationData.phoneNumber = phoneController.text;
                      registrationData.age = ageController.text;
                      registrationData.occupation = occupationController.text;
                      registrationData.ethnicity = ethnicityController.text;
                      registrationData.religion = religionController.text;
                      registrationData.educationLevel = educationController.text;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register2Screen(registrationData: registrationData),
                        ),
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
  final TextEditingController? controller;
  const _RoundedTextField({required this.hint, this.controller});

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