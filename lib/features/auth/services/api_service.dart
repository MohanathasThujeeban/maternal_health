import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../config/api_config.dart';

class ApiService {
  // Dynamic base URL based on platform - enhanced with centralized config
  static String get baseUrl {
    if (kIsWeb) {
      // For web (Chrome, Firefox, etc.) - use localhost
      return 'http://localhost:${ApiConfig.serverPort}/api';
    } else if (Platform.isAndroid) {
      // For Android emulator (10.0.2.2 maps to host localhost)
      return 'http://10.0.2.2:${ApiConfig.serverPort}/api';
    } else {
      // For iOS simulator and other platforms - use WiFi IP from config
      return ApiConfig.baseApiUrl;
    }
  }

  // Login method
  static Future<Map<String, dynamic>> login(
    String nicNumber,
    String password,
  ) async {
    try {
      print('Attempting login with NIC: $nicNumber');

      final Map<String, dynamic> loginData = {
        'nicNumber': nicNumber,
        'password': password,
      };

      print('Sending login data: ${jsonEncode(loginData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(loginData),
          )
          .timeout(const Duration(seconds: 10));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'],
            'userId': responseData['userId'],
            'fullName': responseData['fullName'],
            'email': responseData['email'],
            'nicNumber': responseData['nicNumber'],
            'phoneNumber': responseData['phoneNumber'],
            'userRole': responseData['userRole'] ?? 'MOTHER',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login failed',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Login failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Failed to connect to server. Please try again.',
      };
    } catch (e) {
      print('Error during login: $e');
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Registration method (keeping existing functionality)
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> registrationData,
  ) async {
    try {
      print('Sending registration data: ${jsonEncode(registrationData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/registration'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(registrationData),
          )
          .timeout(const Duration(seconds: 10));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
          'id': responseData['id'],
          'email': responseData['email'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Registration failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Failed to connect to server. Please try again.',
      };
    } catch (e) {
      print('Error during registration: $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Forgot Password method
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('Attempting forgot password for email: $email');

      final Map<String, dynamic> forgotPasswordData = {'email': email};

      print('Sending forgot password data: ${jsonEncode(forgotPasswordData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(forgotPasswordData),
          )
          .timeout(const Duration(seconds: 10));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'],
          'message': responseData['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to send reset email',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Failed to connect to server. Please try again.',
      };
    } catch (e) {
      print('Error during forgot password: $e');
      return {
        'success': false,
        'message': 'Forgot password failed: ${e.toString()}',
      };
    }
  }

  // Send email verification
  static Future<Map<String, dynamic>> sendVerificationEmail(
    String email,
  ) async {
    try {
      print('Sending verification email to: $email');

      final Map<String, dynamic> requestData = {'email': email};

      print('Sending verification data: ${jsonEncode(requestData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/registration/send-verification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(const Duration(seconds: 10));

      print('Verification Response Status: ${response.statusCode}');
      print('Verification Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? 'Verification email sent',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to send verification email. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error sending verification email: $e');
      return {
        'success': false,
        'message': 'Error sending verification email: ${e.toString()}',
      };
    }
  }

  // Check email verification status
  static Future<Map<String, dynamic>> checkEmailVerification(
    String email,
  ) async {
    try {
      print('Checking verification status for: $email');

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/registration/check-verification?email=${Uri.encodeComponent(email)}',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('Check Verification Response Status: ${response.statusCode}');
      print('Check Verification Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'verified': responseData['verified'] ?? false,
          'message': responseData['message'] ?? 'Verification status checked',
        };
      } else {
        return {
          'success': false,
          'verified': false,
          'message':
              'Failed to check verification status. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error checking verification status: $e');
      return {
        'success': false,
        'verified': false,
        'message': 'Error checking verification status: ${e.toString()}',
      };
    }
  }

  // Healthcare Provider Login method
  static Future<Map<String, dynamic>> healthcareLogin(
    String medicalLicenseNumber,
    String password,
  ) async {
    try {
      print(
        'Attempting healthcare provider login with License: $medicalLicenseNumber',
      );

      final Map<String, dynamic> loginData = {
        'medicalLicenseNumber': medicalLicenseNumber,
        'password': password,
      };

      print('Sending healthcare login data: ${jsonEncode(loginData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/healthcare/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(loginData),
          )
          .timeout(const Duration(seconds: 10));

      print('Healthcare Login Response Status: ${response.statusCode}');
      print('Healthcare Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'],
            'providerId': responseData['providerId'],
            'fullName': responseData['fullName'],
            'email': responseData['email'],
            'nicNumber': responseData['nicNumber'],
            'phoneNumber': responseData['phoneNumber'],
            'medicalLicenseNumber': responseData['medicalLicenseNumber'],
            'institution': responseData['institution'],
            'specialization': responseData['specialization'],
            'yearsOfExperience': responseData['yearsOfExperience'],
            'userRole': responseData['providerType'], // MIDWIFE or DOCTOR
            'isApproved': responseData['isApproved'],
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'Healthcare provider login failed',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Healthcare provider login failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Failed to connect to server. Please try again.',
      };
    } catch (e) {
      print('Error during healthcare provider login: $e');
      return {
        'success': false,
        'message': 'Healthcare login failed: ${e.toString()}',
      };
    }
  }

  // Get available healthcare providers for appointments
  static Future<Map<String, dynamic>> getAvailableHealthcareProviders() async {
    try {
      print('Fetching available healthcare providers');

      final response = await http
          .get(
            Uri.parse('$baseUrl/healthcare/available'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('Get Providers Response Status: ${response.statusCode}');
      print('Get Providers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'providers': responseData['providers'] ?? [],
          'message':
              responseData['message'] ?? 'Providers fetched successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'providers': [],
          'message':
              errorData['error'] ?? 'Failed to fetch healthcare providers',
        };
      }
    } catch (e) {
      print('Error fetching healthcare providers: $e');
      return {
        'success': false,
        'providers': [],
        'message': 'Error fetching healthcare providers: ${e.toString()}',
      };
    }
  }
}
