import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PatientNoteService {
  // Get patient notes for a specific mother
  static Future<List<Map<String, dynamic>>> getNotesByMotherNic(
    String motherNic,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/patient-notes/mother/$motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return List<Map<String, dynamic>>.from(responseData['notes'] ?? []);
        } else {
          throw Exception(
            responseData['error'] ?? 'Failed to load patient notes',
          );
        }
      } else {
        throw Exception('Failed to load patient notes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patient notes: $e');
      throw Exception('Failed to load patient notes: $e');
    }
  }

  // Get all patient notes (for admin/overview)
  static Future<List<Map<String, dynamic>>> getAllPatientNotes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/patient-notes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return List<Map<String, dynamic>>.from(responseData['notes'] ?? []);
        } else {
          throw Exception(
            responseData['error'] ?? 'Failed to load patient notes',
          );
        }
      } else {
        throw Exception('Failed to load patient notes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all patient notes: $e');
      throw Exception('Failed to load patient notes: $e');
    }
  }

  // Get recent notes by doctor
  static Future<List<Map<String, dynamic>>> getRecentNotesByDoctor(
    String doctorLicense,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/patient-notes/doctor/$doctorLicense/recent',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return List<Map<String, dynamic>>.from(responseData['notes'] ?? []);
        } else {
          throw Exception(
            responseData['error'] ?? 'Failed to load doctor notes',
          );
        }
      } else {
        throw Exception('Failed to load doctor notes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching doctor notes: $e');
      throw Exception('Failed to load doctor notes: $e');
    }
  }
}
