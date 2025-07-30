import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/health_chatbox/health_chatbox_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/health-chatbox': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return HealthChatboxScreen(initialTopic: args);
        },
      },
    );
  }
}
