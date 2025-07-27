import 'package:flutter/material.dart';

class HealthCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  HealthCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}