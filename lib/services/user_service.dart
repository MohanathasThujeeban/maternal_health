import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';

class UserService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNicKey = 'user_nic';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userMedicalLicenseKey = 'user_medical_license';
  static const String _userInstitutionKey = 'user_institution';

  // Dynamic base URL from ApiConfig (supports ngrok)
  static String get baseUrl => ApiConfig.baseApiUrl;

  // Save user data after login
  // Save user data including medical license and institution for healthcare providers
  static Future<void> saveUserData({
    required String nic,
    required String name,
    required String email,
    String? medicalLicense,
    String? institution,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNicKey, nic);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
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
    return {
      'nic': await getUserNic(),
      'name': await getUserName(),
      'email': await getUserEmail(),
      'medicalLicense': await getUserMedicalLicense(),
      'institution': await getUserInstitution(),
    };
  }

  // Force fix for specific user (TEMPORARY)
  // Save healthcare provider specific data
  static Future<void> saveHealthcareProviderData({
    required String licenseNumber,
    required String name,
    required String email,
    String? institution,
  }) async {
    await saveUserData(
      nic: licenseNumber, // Use license number as NIC for healthcare providers
      name: name,
      email: email,
      medicalLicense: licenseNumber,
      institution: institution,
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

  // Get all registered mothers
  static Future<List<Map<String, dynamic>>> getAllMothers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/mothers'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Get all mothers response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData['mothers'] != null) {
          final List<dynamic> mothersData = responseData['mothers'];
          return mothersData.cast<Map<String, dynamic>>();
        } else {
          print('API returned success=false or no mothers data');
          return [];
        }
      } else {
        print('Failed to get mothers: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting mothers: $e');
      return [];
    }
  }
}
