import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/growth_entry.dart';

class GrowthEntryService {
  static final String baseUrl = '${ApiConfig.baseApiUrl}/growth';

  static Future<List<GrowthEntry>> getEntriesByNic(String nic) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/$nic'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => GrowthEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load growth entries');
      }
    } catch (e) {
      throw Exception('Failed to load growth entries: $e');
    }
  }

  static Future<GrowthEntry> addEntry({
    required String motherNic,
    int? babyId, // Optional baby ID for specific baby
    required double height,
    required double weight,
    required DateTime date,
    String? midwifeLicense, // Optional midwife license
  }) async {
    try {
      final requestBody = {
        'motherNic': motherNic,
        'height': height,
        'weight': weight,
        'date': date.toIso8601String(),
      };

      // Add optional fields if provided
      if (babyId != null) {
        requestBody['babyId'] = babyId;
      }
      if (midwifeLicense != null) {
        requestBody['midwifeLicense'] = midwifeLicense;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return GrowthEntry.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add growth entry');
      }
    } catch (e) {
      throw Exception('Failed to add growth entry: $e');
    }
  }

  // Baby-specific methods for midwife use
  static Future<List<GrowthEntry>> getEntriesByBaby(int babyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/baby/$babyId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => GrowthEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load baby growth entries');
      }
    } catch (e) {
      throw Exception('Failed to load baby growth entries: $e');
    }
  }

  static Future<List<GrowthEntry>> getEntriesByMotherAndBaby(
    String motherNic,
    int babyId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mother/$motherNic/baby/$babyId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => GrowthEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load mother-baby growth entries');
      }
    } catch (e) {
      throw Exception('Failed to load mother-baby growth entries: $e');
    }
  }
}
