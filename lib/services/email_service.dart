import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EmailService {
  static String get _emailEndpoint => '${ApiConfig.baseApiUrl}/email';

  /// Send a baby registration confirmation email to the mother
  static Future<bool> sendBabyRegistrationConfirmation({
    required String babyName,
    required String motherEmail,
    required String motherName,
    String? birthDate,
    String? gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_emailEndpoint/baby-registration-confirmation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': motherEmail,
          'motherName': motherName,
          'babyName': babyName,
          'birthDate': birthDate,
          'gender': gender,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending baby registration confirmation email: $e');
      return false;
    }
  }

  /// Send a welcome email to a new mother
  static Future<bool> sendWelcomeEmail({
    required String motherEmail,
    required String motherName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_emailEndpoint/welcome'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': motherEmail,
          'motherName': motherName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending welcome email: $e');
      return false;
    }
  }

  /// Send appointment reminder email
  static Future<bool> sendAppointmentReminder({
    required String motherEmail,
    required String motherName,
    required String appointmentDate,
    required String appointmentTime,
    required String doctorName,
    String? clinicLocation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_emailEndpoint/appointment-reminder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': motherEmail,
          'motherName': motherName,
          'appointmentDate': appointmentDate,
          'appointmentTime': appointmentTime,
          'doctorName': doctorName,
          'clinicLocation': clinicLocation,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending appointment reminder email: $e');
      return false;
    }
  }

  /// Send vaccination reminder email
  static Future<bool> sendVaccinationReminder({
    required String motherEmail,
    required String motherName,
    required String babyName,
    required String vaccineName,
    required String dueDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_emailEndpoint/vaccination-reminder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': motherEmail,
          'motherName': motherName,
          'babyName': babyName,
          'vaccineName': vaccineName,
          'dueDate': dueDate,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending vaccination reminder email: $e');
      return false;
    }
  }

  /// Send general notification email
  static Future<bool> sendNotificationEmail({
    required String motherEmail,
    required String motherName,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_emailEndpoint/notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': motherEmail,
          'motherName': motherName,
          'subject': subject,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending notification email: $e');
      return false;
    }
  }
}
