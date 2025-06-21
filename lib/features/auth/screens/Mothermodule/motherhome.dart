import 'package:flutter/material.dart';

class MotherHomeScreen extends StatelessWidget {
  const MotherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mother Home',
          style: TextStyle(
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF4FC3A1),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HomeButton(
                text: 'Schedule',
                icon: Icons.calendar_today,
                onTap: () {
                  // TODO: Navigate to schedule screen
                },
              ),
              const SizedBox(height: 24),
              _HomeButton(
                text: 'View Records',
                icon: Icons.folder_open,
                onTap: () {
                  // TODO: Navigate to view records screen
                },
              ),
              const SizedBox(height: 24),
              _HomeButton(
                text: 'Baby',
                icon: Icons.child_care,
                onTap: () {
                  // TODO: Navigate to baby screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: 'SpotifyCircular',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3A1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: onTap,
      ),
    );
  }
}