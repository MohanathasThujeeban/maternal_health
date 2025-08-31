import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'user_service.dart';

class ActivityService {
  static const String _endpoint = '/activities';

  /// Log a new activity when a record is updated
  static Future<bool> logActivity({
    required String activityType,
    required String title,
    required String description,
    String? motherNic,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get current midwife's identifier
      final userData = await UserService.getUserData();
      final midwifeId = userData['medicalLicenseNumber'] ?? userData['nic'];
      final midwifeName = userData['name'] ?? 'Unknown Midwife';

      if (midwifeId == null || midwifeId.isEmpty) {
        return false;
      }

      final activityData = {
        'midwifeId': midwifeId,
        'midwifeName': midwifeName,
        'activityType': activityType,
        'title': title,
        'description': description,
        'motherNic': motherNic,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseApiUrl}$_endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(activityData),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error logging activity: $e');
      return false;
    }
  }

  /// Get recent activities for a specific midwife
  static Future<List<Map<String, dynamic>>> getRecentActivities({
    String? midwifeId,
    int limit = 20,
  }) async {
    try {
      // Get current midwife's identifier if not provided
      String? currentMidwifeId = midwifeId;
      if (currentMidwifeId == null) {
        final userData = await UserService.getUserData();
        currentMidwifeId = userData['medicalLicenseNumber'] ?? userData['nic'];
      }

      if (currentMidwifeId == null || currentMidwifeId.isEmpty) {
        return [];
      }

      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseApiUrl}$_endpoint/midwife/$currentMidwifeId?limit=$limit',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['activities'] is List) {
          return List<Map<String, dynamic>>.from(data['activities']);
        }
      }

      return [];
    } catch (e) {
      print('Error fetching recent activities: $e');
      return [];
    }
  }

  /// Log vaccination record activity
  static Future<bool> logVaccinationActivity({
    required String motherNic,
    required String motherName,
    required String vaccineName,
    required String action, // 'added', 'updated', 'deleted'
  }) async {
    return await logActivity(
      activityType: 'vaccination',
      title: 'Vaccination $action',
      description: '$action vaccination record for $motherName - $vaccineName',
      motherNic: motherNic,
      metadata: {'vaccineName': vaccineName, 'action': action},
    );
  }

  /// Log thiriposa record activity
  static Future<bool> logThiriposaActivity({
    required String motherNic,
    required String motherName,
    required String thiriposaType,
    required String action, // 'added', 'updated', 'deleted'
  }) async {
    return await logActivity(
      activityType: 'thiriposa',
      title: 'Thiriposa $action',
      description: '$action thiriposa record for $motherName - $thiriposaType',
      motherNic: motherNic,
      metadata: {'thiriposaType': thiriposaType, 'action': action},
    );
  }

  /// Log growth record activity
  static Future<bool> logGrowthActivity({
    required String motherNic,
    required String motherName,
    required String action, // 'added', 'updated', 'deleted'
    double? height,
    double? weight,
  }) async {
    return await logActivity(
      activityType: 'growth',
      title: 'Growth Data $action',
      description:
          '$action growth record for $motherName${height != null && weight != null ? ' (${height}cm, ${weight}kg)' : ''}',
      motherNic: motherNic,
      metadata: {'action': action, 'height': height, 'weight': weight},
    );
  }

  /// Log appointment activity
  static Future<bool> logAppointmentActivity({
    required String motherNic,
    required String motherName,
    required String action, // 'scheduled', 'updated', 'cancelled', 'completed'
    String? appointmentType,
    DateTime? appointmentDate,
  }) async {
    return await logActivity(
      activityType: 'appointment',
      title: 'Appointment $action',
      description:
          '$action appointment for $motherName${appointmentType != null ? ' - $appointmentType' : ''}',
      motherNic: motherNic,
      metadata: {
        'action': action,
        'appointmentType': appointmentType,
        'appointmentDate': appointmentDate?.toIso8601String(),
      },
    );
  }

  /// Log eye/ear examination activity
  static Future<bool> logEyeEarActivity({
    required String motherNic,
    required String motherName,
    required String examinationType,
    required String action, // 'added', 'updated', 'deleted'
  }) async {
    return await logActivity(
      activityType: 'eye_ear',
      title: 'Eye/Ear Exam $action',
      description: '$action $examinationType examination for $motherName',
      motherNic: motherNic,
      metadata: {'examinationType': examinationType, 'action': action},
    );
  }

  /// Format activity time for display
  static String formatActivityTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  /// Get activity icon based on type
  static String getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'vaccination':
        return 'vaccines';
      case 'thiriposa':
        return 'local_dining';
      case 'growth':
        return 'trending_up';
      case 'appointment':
        return 'event_note';
      case 'eye_ear':
        return 'visibility';
      default:
        return 'health_and_safety';
    }
  }
}
