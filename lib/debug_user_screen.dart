import 'package:flutter/material.dart';
import '../../../services/user_service.dart';

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
          ],
        ),
      ),
    );
  }
}
