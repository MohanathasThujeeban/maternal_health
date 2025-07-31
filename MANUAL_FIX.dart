// MANUAL FIX FOR MISSING NAME ISSUE
// Copy this code and run it once in your Flutter app

import 'package:shared_preferences/shared_preferences.dart';

// Run this once to manually set your name
Future<void> fixMissingName() async {
  final prefs = await SharedPreferences.getInstance();

  // Check if NIC matches yours
  final nic = prefs.getString('user_nic');
  if (nic == '200201901851') {
    // Set your registered name
    await prefs.setString('user_name', 'Mohanathas Thujeeban');
    print('Name fixed! Please restart the app.');
  }
}

// Or simply log out and log in again - the backend now returns fullName properly
