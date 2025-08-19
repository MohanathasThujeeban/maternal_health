import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ThiriposaApiService {
  static String get baseUrl => ApiConfig.baseApiUrl;

  // Get all registered users
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/registration/all'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        return {'success': true, 'users': users};
      } else {
        return {'success': false, 'message': 'Failed to fetch users'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Add Thiriposa record
  static Future<Map<String, dynamic>> addThiriposaRecord({
    required String motherNic,
    required DateTime supplyDate,
    required int quantity,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'motherNic': motherNic,
        'date': supplyDate.toIso8601String(),
        'quantity': quantity,
        'notes': notes ?? '',
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/thiriposa/add'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Thiriposa record added successfully',
          'data': jsonDecode(response.body),
        };
      } else {
        return {'success': false, 'message': 'Failed to add Thiriposa record'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get Thiriposa records by NIC
  static Future<Map<String, dynamic>> getRecordsByNic(String nic) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/thiriposa/records/$nic'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        return {'success': true, 'records': records};
      } else {
        return {'success': false, 'message': 'Failed to fetch records'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
