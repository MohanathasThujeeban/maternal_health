import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

class AdminService {
  static final String baseUrl = ApiConfig.baseUrl;

  // Admin login
  static Future<Map<String, dynamic>> adminLogin(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Login successful'};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get all users
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Suspend user
  static Future<void> suspendUser(String nicNumber) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$nicNumber/suspend'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to suspend user');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Delete user
  static Future<void> deleteUser(String nicNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$nicNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
