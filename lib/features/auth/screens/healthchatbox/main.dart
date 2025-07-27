// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(MaternalHealthApp());
}

class MaternalHealthApp extends StatelessWidget {
  const MaternalHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maternal Health Assistant',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: ChatbotScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}