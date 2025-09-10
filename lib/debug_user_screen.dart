import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/user_service.dart';
import 'services/firebase_service.dart';

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

  Future<void> _testNotification() async {
    try {
      await FirebaseService.sendTestNotification();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test notification sent!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _refreshFCMToken() async {
    try {
      String? token = await FirebaseService.refreshToken();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FCM Token: ${token?.substring(0, 20)}...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendDailyTip() async {
    try {
      final userData = await UserService.getUserData();
      String? userNic = userData['nic'];

      if (userNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('http://10.11.8.134:8080/api/notifications/send-daily-tip'),
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
        Uri.parse('http://10.11.8.134:8080/api/notifications/send-motivation'),
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
        Uri.parse('http://10.11.8.134:8080/api/notifications/send-health-tip'),
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
        Uri.parse(
          'http://10.11.8.134:8080/api/notifications/send-baby-care-tip',
        ),
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
      appBar: AppBar(title: const Text('Debug User Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              'Push Notifications:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testNotification,
              child: const Text('Send Test Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshFCMToken,
              child: const Text('Refresh FCM Token'),
            ),
            const SizedBox(height: 16),
            Text(
              'FCM Token: ${FirebaseService.currentToken?.substring(0, 20) ?? 'Not available'}...',
              style: const TextStyle(fontSize: 12),
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
