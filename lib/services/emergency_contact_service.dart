import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EmergencyContactService {
  static Future<List<Map<String, dynamic>>> getHealthcareProviders() async {
    try {
      print('=== FETCHING HEALTHCARE PROVIDERS ===');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseApiUrl}/healthcare/providers/active'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Successfully fetched ${data.length} healthcare providers');

        List<Map<String, dynamic>> providers = [];

        for (var provider in data) {
          providers.add({
            'id': provider['id'],
            'fullName': provider['fullName'] ?? 'Unknown',
            'phoneNumber': provider['phoneNumber'] ?? 'N/A',
            'providerType': provider['providerType'] ?? 'UNKNOWN',
            'specialization': provider['specialization'] ?? 'General',
            'institution': provider['institution'] ?? 'Unknown Institution',
            'yearsOfExperience': provider['yearsOfExperience'] ?? 0,
            'email': provider['email'] ?? '',
          });
        }

        return providers;
      } else {
        print('Failed to fetch healthcare providers: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load healthcare providers');
      }
    } catch (e) {
      print('Error fetching healthcare providers: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>>
  getGroupedProviders() async {
    try {
      final providers = await getHealthcareProviders();

      Map<String, List<Map<String, dynamic>>> grouped = {
        'doctors': [],
        'midwives': [],
      };

      for (var provider in providers) {
        if (provider['providerType'] == 'DOCTOR') {
          grouped['doctors']!.add(provider);
        } else if (provider['providerType'] == 'MIDWIFE') {
          grouped['midwives']!.add(provider);
        }
      }

      print(
        'Grouped providers: ${grouped['doctors']!.length} doctors, ${grouped['midwives']!.length} midwives',
      );

      return grouped;
    } catch (e) {
      print('Error grouping healthcare providers: $e');
      throw Exception('Error: $e');
    }
  }
}
