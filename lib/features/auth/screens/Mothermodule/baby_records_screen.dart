import 'package:flutter/material.dart';

class BabyRecordsScreen extends StatelessWidget {
  const BabyRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Records'),
        backgroundColor: const Color(0xFF4FC3A1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRecordCard(
            context,
            icon: Icons.child_care,
            title: 'Growth Records',
            onTap: () {
              // Navigate to growth records
            },
          ),
          _buildRecordCard(
            context,
            icon: Icons.medical_services,
            title: 'Health Check-ups',
            onTap: () {
              // Navigate to health check-ups
            },
          ),
          _buildRecordCard(
            context,
            icon: Icons.notes,
            title: 'Development Milestones',
            onTap: () {
              // Navigate to milestones
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4FC3A1), size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
