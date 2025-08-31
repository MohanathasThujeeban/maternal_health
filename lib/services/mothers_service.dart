import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MothersService {
  static const String _endpoint = '/registration/all';

  /// Fetch all registered mothers
  static Future<List<Map<String, dynamic>>> getAllMothers() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseApiUrl}$_endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> allUsers = json.decode(response.body);
        // Convert to List<Map<String, dynamic>> and return all users
        // (we can filter for mothers on frontend if needed)
        return List<Map<String, dynamic>>.from(allUsers);
      }

      if (response.statusCode == 404) {
        throw Exception('Registration endpoint not found');
      }

      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch mothers data: $e');
    }
  }

  /// Search mothers by name or NIC
  static Future<List<Map<String, dynamic>>> searchMothers(
    String searchTerm,
  ) async {
    try {
      final allMothers = await getAllMothers();

      if (searchTerm.isEmpty) {
        return allMothers;
      }

      return allMothers.where((mother) {
        final fullName = (mother['fullName'] ?? '').toLowerCase();
        final nicNumber = (mother['nicNumber'] ?? '').toLowerCase();
        final email = (mother['email'] ?? '').toLowerCase();
        final searchLower = searchTerm.toLowerCase();

        return fullName.contains(searchLower) ||
            nicNumber.contains(searchLower) ||
            email.contains(searchLower);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search mothers: $e');
    }
  }

  /// Get total count of registered mothers
  static Future<int> getMothersCount() async {
    try {
      final mothers = await getAllMothers();
      return mothers.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get active mothers count
  static Future<int> getActiveMothersCount() async {
    try {
      final mothers = await getAllMothers();
      return mothers.where((mother) => mother['isActive'] != false).length;
    } catch (e) {
      return 0;
    }
  }
}
