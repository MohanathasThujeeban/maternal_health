import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_service.dart';

class EyeEarRecordService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/baby-problems';

  // Get eye and ear records for the current mother
  static Future<List<Map<String, dynamic>>> getMyBabyRecords() async {
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

      print('Eye and Ear records API response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching eye and ear records: $e');
      throw Exception('Failed to load eye and ear records: $e');
    }
  }

  // Get all eye and ear records (for midwives)
  static Future<List<Map<String, dynamic>>> getAllRecords() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all eye and ear records: $e');
      throw Exception('Failed to load eye and ear records: $e');
    }
  }

  // Get records by specific mother NIC (for midwives)
  static Future<List<Map<String, dynamic>>> getRecordsByMotherNic(
    String motherNic,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mother/$motherNic'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching records for mother $motherNic: $e');
      throw Exception('Failed to load eye and ear records: $e');
    }
  }

  // Create a new eye and ear record (for midwives)
  static Future<Map<String, dynamic>> createRecord({
    required String patientName,
    required String motherNic,
    String? eyeProblem,
    String? earProblem,
    String? symptomsDuration,
    String? remarks,
    required String dateOfDiagnosis,
  }) async {
    try {
      final recordData = {
        'patientName': patientName,
        'motherNic': motherNic,
        'eyeProblem': eyeProblem ?? 'None',
        'earProblem': earProblem ?? 'None',
        'symptomsDuration': symptomsDuration ?? 'Less than 1 day',
        'remarks': remarks ?? '',
        'dateOfDiagnosis': dateOfDiagnosis,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recordData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            'Failed to create record: ${responseData['message']}',
          );
        }
      } else {
        throw Exception('Failed to create record: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating eye and ear record: $e');
      throw Exception('Failed to create eye and ear record: $e');
    }
  }
}
