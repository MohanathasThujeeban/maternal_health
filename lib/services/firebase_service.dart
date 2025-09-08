import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';
import '../config/api_config.dart';

class FirebaseService {
  static FirebaseMessaging? _messaging;
  static String? _fcmToken;

  // Initialize Firebase and messaging service
  static Future<void> initialize() async {
    try {
      // Initialize Firebase with options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      await _requestPermission();

      // Setup message handlers
      _setupMessageHandlers();

      // Get FCM token
      await getFCMToken();

      print('FirebaseService initialized successfully');
    } catch (e) {
      print('Error initializing FirebaseService: $e');
    }
  }

  // Request notification permissions
  static Future<void> _requestPermission() async {
    if (_messaging == null) return;

    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  // Setup message handlers for different app states
  static void _setupMessageHandlers() {
    if (_messaging == null) return;

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showNotification(message);
      }
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message);
    });

    // Handle notification tap when app is terminated
    _messaging!.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App launched from notification!');
        _handleNotificationTap(message);
      }
    });
  }

  // Get FCM token for this device
  static Future<String?> getFCMToken() async {
    if (_messaging == null) return null;

    try {
      _fcmToken = await _messaging!.getToken();
      print('FCM Token: $_fcmToken');

      // Register token with backend
      if (_fcmToken != null) {
        await registerFCMToken(_fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Register FCM token with backend server
  static Future<void> registerFCMToken(String token) async {
    try {
      // Get current user ID (you might need to implement this based on your auth system)
      String? userId = getCurrentUserId();

      if (userId == null) {
        print('No user ID available, skipping token registration');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseApiUrl}/notifications/register-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token registered successfully');
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  // Show notification in foreground (simple approach without flutter_local_notifications)
  static void _showNotification(RemoteMessage message) {
    // Since we removed flutter_local_notifications, we'll handle this differently
    // You could show an in-app banner, dialog, or use the app's notification system
    print('Showing notification: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    // For now, just print to console. In a real app, you might:
    // - Show a banner at the top of the screen
    // - Add to an in-app notification list
    // - Update the app badge
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');

    // Navigate to appropriate screen based on notification data
    // Example: if (message.data['type'] == 'appointment') { navigateToAppointments(); }
  }

  // Get current user ID (implement based on your auth system)
  static String? getCurrentUserId() {
    // This should be implemented based on your authentication system
    // For example, you might get it from SharedPreferences, a provider, etc.
    // For now, returning a placeholder
    return 'user123'; // Replace with actual implementation
  }

  // Send test notification (for development)
  static Future<void> sendTestNotification() async {
    if (_fcmToken == null) {
      print('No FCM token available');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseApiUrl}/notifications/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fcmToken': _fcmToken,
          'title': 'Test Notification',
          'body': 'This is a test notification from the app',
          'data': {
            'type': 'test',
            'timestamp': DateTime.now().toIso8601String(),
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Test notification sent successfully');
      } else {
        print('Failed to send test notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  // Get the current FCM token
  static String? get currentToken => _fcmToken;

  // Refresh FCM token
  static Future<String?> refreshToken() async {
    return await getFCMToken();
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background message handling
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Handling a background message: ${message.messageId}");
  print("Message data: ${message.data}");

  if (message.notification != null) {
    print("Background notification: ${message.notification!.title}");
  }
}
