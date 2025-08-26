import 'package:flutter/material.dart';

// Data Models
class HealthCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  HealthCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class PredefinedQuestion {
  final String question;
  final String answer;

  PredefinedQuestion({
    required this.question,
    required this.answer,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
