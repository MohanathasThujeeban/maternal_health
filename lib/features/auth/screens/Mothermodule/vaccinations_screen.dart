import 'package:flutter/material.dart';

class VaccinationsScreen extends StatelessWidget {
  const VaccinationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccinations'),
        backgroundColor: const Color(0xFF4FC3A1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildVaccinationCard(
            context,
            title: 'BCG',
            date: '2025-01-15',
            status: 'Completed',
            dueDate: '2025-01-15',
          ),
          _buildVaccinationCard(
            context,
            title: 'Polio',
            date: '2025-02-15',
            status: 'Scheduled',
            dueDate: '2025-02-15',
          ),
          _buildVaccinationCard(
            context,
            title: 'MMR',
            date: 'Not Scheduled',
            status: 'Pending',
            dueDate: '2025-03-15',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new vaccination record
        },
        backgroundColor: const Color(0xFF4FC3A1),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVaccinationCard(
    BuildContext context, {
    required String title,
    required String date,
    required String status,
    required String dueDate,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        statusIcon = Icons.event;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(statusIcon, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text('Date: $date'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text('Due Date: $dueDate'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
