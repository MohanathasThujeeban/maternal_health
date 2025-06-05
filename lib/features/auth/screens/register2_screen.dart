import 'package:flutter/material.dart';
import 'register3_screen.dart'; // Import the Register3Screen

class Register2Screen extends StatelessWidget {
  const Register2Screen({super.key});

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
              const Text(
                'Gravida / Para [G/P]',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_circle_right_outlined),
                    onPressed: () {},
                  ),
                  const Text(
                    'G',
                    style: TextStyle(fontFamily: 'SpotifyCircular', fontSize: 16),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.arrow_circle_right_outlined),
                    onPressed: () {},
                  ),
                  const Text(
                    'P',
                    style: TextStyle(fontFamily: 'SpotifyCircular', fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Date of Last Menstrual Period [LMP]',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(hint: ''),
              const SizedBox(height: 12),
              const Text(
                'Expected Date of Delivery [EDD]',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(hint: ''),
              const SizedBox(height: 12),
              const Text(
                'Previous Pregnancies [G1 to G6]',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular', // Use SpotifyCircular font
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _RoundedTextField(hint: ''),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _RoundedTextField(hint: 'Year')),
                  const SizedBox(width: 12),
                  Expanded(child: _RoundedTextField(hint: 'Duration[wks]')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _RoundedTextField(hint: 'Mode of delivery')),
                  const SizedBox(width: 12),
                  Expanded(child: _RoundedTextField(hint: 'Birth weight')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _RoundedTextField(hint: 'Sex')),
                  const SizedBox(width: 12),
                  Expanded(child: _RoundedTextField(hint: 'Status[Alive/Death]')),
                ],
              ),
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
                      // Navigate to Register3Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Register3Screen(),
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