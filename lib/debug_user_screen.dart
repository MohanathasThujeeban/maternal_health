import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/user_service.dart';
import 'config/api_config.dart';

class DebugUserScreen extends StatefulWidget {
  const DebugUserScreen({super.key});

  @override
  State<DebugUserScreen> createState() => _DebugUserScreenState();
}

class _DebugUserScreenState extends State<DebugUserScreen> {
  String? nic;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    setState(() {
      nic = userData['nic'];
      name = userData['name'];
      email = userData['email'];
    });
  }

  Future<void> _fixUserData() async {
    await UserService.saveUserData(
      nic: '200201901851',
      name: 'Mohanathas Thujeeban',
      email: 'thujee44@gmail.com',
    );
    await _loadUserData();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User data fixed!')));
  }

  Future<void> _sendDailyTip() async {
    try {
      final userData = await UserService.getUserData();
      String? userNic = userData['nic'];

      if (userNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/send-daily-tip'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userNic': userNic}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('📚 Daily tip sent!')));
      } else {
        throw Exception('Failed to send daily tip');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendMotivation() async {
    try {
      final userData = await UserService.getUserData();
      String? userNic = userData['nic'];

      if (userNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/send-motivation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userNic': userNic}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('💝 Motivational quote sent!')),
        );
      } else {
        throw Exception('Failed to send motivation');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendHealthTip() async {
    try {
      final userData = await UserService.getUserData();
      String? userNic = userData['nic'];

      if (userNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/send-health-tip'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userNic': userNic}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('💊 Health tip sent!')));
      } else {
        throw Exception('Failed to send health tip');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendBabyCareTip() async {
    try {
      final userData = await UserService.getUserData();
      String? userNic = userData['nic'];

      if (userNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/send-baby-care-tip'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userNic': userNic}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('👶 Baby care tip sent!')));
      } else {
        throw Exception('Failed to send baby care tip');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug User Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Using: ${ApiConfig.baseUrl}')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Status Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'API Mode: ${ApiConfig.currentMode}',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current User Data:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('NIC: ${nic ?? 'Not set'}'),
            Text('Name: ${name ?? 'Not set'}'),
            Text('Email: ${email ?? 'Not set'}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fixUserData,
              child: const Text('Fix My User Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Refresh Data'),
            ),
            const SizedBox(height: 32),
            Text(
              'Maternal Care Notifications:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendDailyTip,
                    child: const Text('📚 Daily Tip'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendMotivation,
                    child: const Text('💝 Motivation'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendHealthTip,
                    child: const Text('💊 Health Tip'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendBabyCareTip,
                    child: const Text('👶 Baby Care'),
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
