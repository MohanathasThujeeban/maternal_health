import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'user_service.dart';

class BabyService {
  static final String baseUrl = '${ApiConfig.baseApiUrl}/babies';

  /// Create a new baby for the current mother
  static Future<Map<String, dynamic>> createBaby({
    required String babyName,
    DateTime? birthDate,
    String? gender,
    double? birthWeight,
    double? birthHeight,
  }) async {
    try {
      final userData = await UserService.getUserData();
      final motherNic = userData['nic'];

      if (motherNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'motherNic': motherNic,
          'babyName': babyName,
          'birthDate': birthDate?.toIso8601String().split(
            'T',
          )[0], // YYYY-MM-DD format
          'gender': gender,
          'birthWeight': birthWeight,
          'birthHeight': birthHeight,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return responseData['baby'];
      } else {
        throw Exception(responseData['error'] ?? 'Failed to create baby');
      }
    } catch (e) {
      throw Exception('Failed to create baby: $e');
    }
  }

  /// Get all babies for the current mother
  static Future<List<Map<String, dynamic>>> getMyBabies() async {
    try {
      final userData = await UserService.getUserData();
      final motherNic = userData['nic'];

      if (motherNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/mother/$motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return List<Map<String, dynamic>>.from(responseData['babies']);
      } else {
        throw Exception(responseData['error'] ?? 'Failed to fetch babies');
      }
    } catch (e) {
      throw Exception('Failed to fetch babies: $e');
    }
  }

  /// Get babies for a specific mother by NIC (for midwife/doctor use)
  static Future<List<Map<String, dynamic>>> getBabiesByMotherNic(
    String motherNic,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mother/$motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return List<Map<String, dynamic>>.from(responseData['babies']);
      } else {
        throw Exception(responseData['error'] ?? 'Failed to fetch babies');
      }
    } catch (e) {
      throw Exception('Failed to fetch babies: $e');
    }
  }

  /// Get a specific baby by ID
  static Future<Map<String, dynamic>> getBabyById(int babyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$babyId'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['baby'];
      } else {
        throw Exception(responseData['error'] ?? 'Failed to fetch baby');
      }
    } catch (e) {
      throw Exception('Failed to fetch baby: $e');
    }
  }

  /// Update baby information
  static Future<Map<String, dynamic>> updateBaby({
    required int babyId,
    required String babyName,
    DateTime? birthDate,
    String? gender,
    double? birthWeight,
    double? birthHeight,
  }) async {
    try {
      final userData = await UserService.getUserData();
      final motherNic = userData['nic'];

      if (motherNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$babyId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'motherNic': motherNic,
          'babyName': babyName,
          'birthDate': birthDate?.toIso8601String().split(
            'T',
          )[0], // YYYY-MM-DD format
          'gender': gender,
          'birthWeight': birthWeight,
          'birthHeight': birthHeight,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['baby'];
      } else {
        throw Exception(responseData['error'] ?? 'Failed to update baby');
      }
    } catch (e) {
      throw Exception('Failed to update baby: $e');
    }
  }

  /// Delete a baby (soft delete)
  static Future<void> deleteBaby(int babyId) async {
    try {
      final userData = await UserService.getUserData();
      final motherNic = userData['nic'];

      if (motherNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$babyId/mother/$motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 || responseData['success'] != true) {
        throw Exception(responseData['error'] ?? 'Failed to delete baby');
      }
    } catch (e) {
      throw Exception('Failed to delete baby: $e');
    }
  }

  /// Get count of babies for current mother
  static Future<int> getMyBabyCount() async {
    try {
      final userData = await UserService.getUserData();
      final motherNic = userData['nic'];

      if (motherNic == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/mother/$motherNic/count'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['count'];
      } else {
        throw Exception(responseData['error'] ?? 'Failed to get baby count');
      }
    } catch (e) {
      throw Exception('Failed to get baby count: $e');
    }
  }

  /// Format baby age for display
  static String formatBabyAge(DateTime? birthDate) {
    if (birthDate == null) return 'Age unknown';

    final now = DateTime.now();
    final difference = now.difference(birthDate);

    if (difference.inDays < 30) {
      return '${difference.inDays} days old';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} old';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingMonths = ((difference.inDays % 365) / 30).floor();
      if (remainingMonths > 0) {
        return '$years year${years > 1 ? 's' : ''}, $remainingMonths month${remainingMonths > 1 ? 's' : ''} old';
      } else {
        return '$years year${years > 1 ? 's' : ''} old';
      }
    }
  }

  /// Get baby display name (e.g., "1st Child (Baby Name)")
  static String getBabyDisplayName(Map<String, dynamic> baby) {
    final displayName = baby['displayName'];
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final babyOrder = baby['babyOrder'];
    final babyName = baby['babyName'];

    if (babyOrder != null && babyName != null) {
      final suffix = _getOrdinalSuffix(babyOrder);
      return '$babyOrder$suffix Child ($babyName)';
    } else if (babyName != null) {
      return babyName;
    } else {
      return 'Baby';
    }
  }

  static String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
