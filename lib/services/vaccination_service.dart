import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class VaccinationService {
  static const String _endpoint = '/vaccinations';

  // Create a new vaccination record
  static Future<Map<String, dynamic>> createVaccination(
    Map<String, dynamic> vaccinationData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vaccinationData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to create vaccination record',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all vaccination records
  static Future<List<Map<String, dynamic>>> getAllVaccinations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get vaccination records',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get vaccination record by ID
  static Future<Map<String, dynamic>> getVaccinationById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Vaccination record not found');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get vaccination records by mother NIC
  static Future<List<Map<String, dynamic>>> getVaccinationsByMotherNic(
    String motherNic,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/mother/$motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get vaccination records',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get vaccination records by status
  static Future<List<Map<String, dynamic>>> getVaccinationsByStatus(
    String status,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/status/$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get vaccination records',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update vaccination record
  static Future<Map<String, dynamic>> updateVaccination(
    int id,
    Map<String, dynamic> vaccinationData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vaccinationData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to update vaccination record',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update vaccination status only
  static Future<Map<String, dynamic>> updateVaccinationStatus(
    int id,
    String status,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to update vaccination status',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete vaccination record
  static Future<void> deleteVaccination(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to delete vaccination record',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get overdue vaccinations
  static Future<List<Map<String, dynamic>>> getOverdueVaccinations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/overdue'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get overdue vaccinations',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get vaccination statistics
  static Future<Map<String, dynamic>> getVaccinationStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get vaccination statistics',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get vaccination statistics for a specific mother
  static Future<Map<String, dynamic>> getVaccinationStatsByMotherNic(
    String motherNic,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/stats/mother/$motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get vaccination statistics',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method to format vaccination data for API
  static Map<String, dynamic> formatVaccinationData({
    required String motherNic,
    required String childName,
    required String vaccinationType,
    required String ageToGive,
    DateTime? vaccinationDate,
    String? batchNumber,
    String? effectsFollowingImmunization,
    required String status,
  }) {
    return {
      'motherNic': motherNic,
      'childName': childName,
      'vaccinationType': vaccinationType,
      'ageToGive': ageToGive,
      'vaccinationDate': vaccinationDate?.toIso8601String().split('T')[0],
      'batchNumber': batchNumber ?? '',
      'effectsFollowingImmunization': effectsFollowingImmunization ?? '',
      'status': status,
    };
  }

  // Helper method to parse date string
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get all registered mothers with vaccination summary
  static Future<List<Map<String, dynamic>>>
  getAllMothersWithVaccinationSummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/mothers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get mothers with vaccination summary',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search mothers by NIC or name
  static Future<List<Map<String, dynamic>>> searchMothers(
    String searchTerm,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/mothers/search');
      final finalUri = searchTerm.isNotEmpty
          ? uri.replace(queryParameters: {'q': searchTerm})
          : uri;

      final response = await http.get(
        finalUri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to search mothers');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create vaccination with email notification
  static Future<Map<String, dynamic>> createVaccinationWithNotification(
    Map<String, dynamic> vaccinationData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/notify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vaccinationData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ??
              'Failed to create vaccination record with notification',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update vaccination with email notification
  static Future<Map<String, dynamic>> updateVaccinationWithNotification(
    int vaccinationId,
    Map<String, dynamic> vaccinationData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseApiUrl}$_endpoint/$vaccinationId/notify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vaccinationData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ??
              'Failed to update vaccination record with notification',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update vaccination status with email notification
  static Future<Map<String, dynamic>> updateVaccinationStatusWithNotification(
    int vaccinationId,
    String status,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '${ApiConfig.baseApiUrl}$_endpoint/$vaccinationId/status/notify',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status.toUpperCase()}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ??
              'Failed to update vaccination status with notification',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
