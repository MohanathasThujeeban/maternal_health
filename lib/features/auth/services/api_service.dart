import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for web/desktop
  static const String baseUrl = 'http://10.0.2.2:8080/api';

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
            'email': responseData['email'],
            'nicNumber': responseData['nicNumber'],
            'phoneNumber': responseData['phoneNumber'],
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
}
