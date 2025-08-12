import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/thiriposa_record.dart';

class ThiriposaService {
  static final String baseUrl = '${ApiConfig.baseApiUrl}/thiriposa';

  static Future<List<ThiriposaRecord>> getMyRecords() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my-records'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ThiriposaRecord.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      throw Exception('Failed to load records: $e');
    }
  }

  static Future<List<ThiriposaRecord>> getRecordsByNic(String nic) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/records/$nic'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ThiriposaRecord.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load records for NIC: $nic');
      }
    } catch (e) {
      throw Exception('Failed to load records: $e');
    }
  }

  static Future<void> addRecord({
    required String motherNic,
    required DateTime date,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'motherNic': motherNic,
          'date': date.toIso8601String(),
          'quantity': quantity,
        }),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to add record');
      }
    } catch (e) {
      throw Exception('Failed to add record: $e');
    }
  }
}
