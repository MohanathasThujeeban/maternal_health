import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'vaccination_service.dart';
import 'thiriposa_service.dart';
import 'appointment_service.dart';
import 'eye_ear_record_service.dart';

class ComprehensiveRecordsService {
  /// Fetch all records for a mother by NIC
  static Future<Map<String, dynamic>> getAllRecords(String motherNic) async {
    try {
      // Fetch all types of records concurrently
      final futures = await Future.wait([
        _getVaccinationRecords(motherNic),
        _getThiriposaRecords(motherNic),
        _getAppointmentRecords(motherNic),
        _getGrowthRecords(motherNic),
        _getEyeEarRecords(motherNic),
      ]);

      return {
        'vaccinationRecords': futures[0],
        'thiriposaRecords': futures[1],
        'appointmentRecords': futures[2],
        'growthRecords': futures[3],
        'eyeEarRecords': futures[4],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to fetch comprehensive records: $e');
    }
  }

  /// Get vaccination records for a mother
  static Future<List<Map<String, dynamic>>> _getVaccinationRecords(
    String motherNic,
  ) async {
    try {
      final records = await VaccinationService.getVaccinationsByMotherNic(
        motherNic,
      );
      return records;
    } catch (e) {
      print('Error fetching vaccination records: $e');
      return [];
    }
  }

  /// Get thiriposa records for a mother
  static Future<List<Map<String, dynamic>>> _getThiriposaRecords(
    String motherNic,
  ) async {
    try {
      final records = await ThiriposaService.getRecordsByNic(motherNic);
      // Convert ThiriposaRecord objects to Maps
      return records.map((record) => record.toJson()).toList();
    } catch (e) {
      print('Error fetching thiriposa records: $e');
      return [];
    }
  }

  /// Get appointment records for a mother
  static Future<List<Map<String, dynamic>>> _getAppointmentRecords(
    String motherNic,
  ) async {
    try {
      final appointmentData = await AppointmentService.getAppointmentsByNic(
        motherNic,
      );
      // Extract the appointments list from the response
      if (appointmentData['appointments'] != null) {
        final List<dynamic> appointments = appointmentData['appointments'];
        return appointments.map((apt) => apt as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching appointment records: $e');
      return [];
    }
  }

  /// Get growth records for a mother
  static Future<List<Map<String, dynamic>>> _getGrowthRecords(
    String motherNic,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseApiUrl}/growth/get/$motherNic'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
          'Failed to load growth records: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching growth records: $e');
      return [];
    }
  }

  /// Get eye and ear records for a mother
  static Future<List<Map<String, dynamic>>> _getEyeEarRecords(
    String motherNic,
  ) async {
    try {
      final records = await EyeEarRecordService.getRecordsByMotherNic(
        motherNic,
      );
      return records;
    } catch (e) {
      print('Error fetching eye/ear records: $e');
      return [];
    }
  }

  /// Get mother details for the report
  static Future<Map<String, dynamic>?> getMotherDetails(
    String motherNic,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseApiUrl}/registration/mother/$motherNic'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching mother details: $e');
      return null;
    }
  }
}
