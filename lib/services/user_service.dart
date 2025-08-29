import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

class UserService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNicKey = 'user_nic';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
<<<<<<< HEAD
  static const String _userMedicalLicenseKey = 'user_medical_license';
  static const String _userInstitutionKey = 'user_institution';
=======
  static const String _userRoleKey = 'user_role';
  static const String _medicalLicenseKey = 'medical_license';
  static const String _clinicKey = 'clinic';
>>>>>>> 08691a4c837f02bf3c5f1494dda36e95f9aac753

  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // For web (Chrome, Firefox, etc.)
      return 'http://localhost:8080/api';
    } else if (Platform.isAndroid) {
      // For Android emulator (10.0.2.2 maps to host localhost)
      return 'http://10.0.2.2:8080/api';
    } else {
      // For iOS simulator and other platforms
      return 'http://localhost:8080/api';
    }
  }

  // Save user data after login
  static Future<void> saveUserData({
    required String nic,
    required String name,
    required String email,
<<<<<<< HEAD
    String? medicalLicense,
    String? institution,
=======
    String? role,
    String? medicalLicenseNumber,
    String? clinic,
>>>>>>> 08691a4c837f02bf3c5f1494dda36e95f9aac753
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNicKey, nic);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    if (role != null) await prefs.setString(_userRoleKey, role);
    if (medicalLicenseNumber != null)
      await prefs.setString(_medicalLicenseKey, medicalLicenseNumber);
    if (clinic != null) await prefs.setString(_clinicKey, clinic);
    await prefs.setBool(_isLoggedInKey, true);

    // Save medical license and institution if provided
    if (medicalLicense != null) {
      await prefs.setString(_userMedicalLicenseKey, medicalLicense);
    }
    if (institution != null) {
      await prefs.setString(_userInstitutionKey, institution);
    }
  }

  // Get user NIC
  static Future<String?> getUserNic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNicKey);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Get user medical license
  static Future<String?> getUserMedicalLicense() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userMedicalLicenseKey);
  }

  // Get user institution
  static Future<String?> getUserInstitution() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userInstitutionKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNicKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userMedicalLicenseKey);
    await prefs.remove(_userInstitutionKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Get all user data
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nic': await getUserNic(),
      'name': await getUserName(),
      'email': await getUserEmail(),
<<<<<<< HEAD
      'medicalLicense': await getUserMedicalLicense(),
      'institution': await getUserInstitution(),
=======
      'role': prefs.getString(_userRoleKey),
      'medicalLicenseNumber': prefs.getString(_medicalLicenseKey),
      'clinic': prefs.getString(_clinicKey),
>>>>>>> 08691a4c837f02bf3c5f1494dda36e95f9aac753
    };
  }

  // Force fix for specific user (TEMPORARY)
  // Save healthcare provider specific data
  static Future<void> saveHealthcareProviderData({
    required String licenseNumber,
    required String name,
    required String email,
    required String role,
    String? clinic,
  }) async {
    await saveUserData(
      nic: licenseNumber, // Use license number as NIC for healthcare providers
      name: name,
      email: email,
      role: role,
      medicalLicenseNumber: licenseNumber,
      clinic: clinic,
    );
  }

  static Future<void> forceFixUserData() async {
    final currentNic = await getUserNic();
    if (currentNic == '200201901851') {
      await saveUserData(
        nic: '200201901851',
        name: 'Mohanathas Thujeeban',
        email: 'thujee44@gmail.com',
      );
      print('User data force-fixed for NIC: $currentNic');
    }
  }

  // Refresh user data from backend
  static Future<bool> refreshUserDataFromBackend() async {
    try {
      final nic = await getUserNic();
      if (nic == null || nic.isEmpty) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile/$nic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          await saveUserData(
            nic: data['nicNumber'] ?? nic,
            name: data['fullName'] ?? '',
            email: data['email'] ?? '',
            medicalLicense: data['medicalLicenseNumber'],
            institution: data['institution'],
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error refreshing user data: $e');
      return false;
    }
  }
}
