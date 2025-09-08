class Baby {
  final int id;
  final String name;
  final String motherNic;
  final String motherName; // Added for display purposes
  final String dateOfBirth;
  final String gender;
  final double? birthWeight;
  final double? birthHeight;
  final int babyOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Baby({
    required this.id,
    required this.name,
    required this.motherNic,
    required this.motherName,
    required this.dateOfBirth,
    required this.gender,
    this.birthWeight,
    this.birthHeight,
    required this.babyOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'],
      name: json['name'],
      motherNic: json['motherNic'],
      motherName: json['motherName'] ?? 'Unknown',
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      birthWeight: json['birthWeight']?.toDouble(),
      birthHeight: json['birthHeight']?.toDouble(),
      babyOrder: json['babyOrder'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'motherNic': motherNic,
      'motherName': motherName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'birthWeight': birthWeight,
      'birthHeight': birthHeight,
      'babyOrder': babyOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get formatted birth date
  String get formattedBirthDate {
    try {
      final date = DateTime.parse(dateOfBirth);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateOfBirth;
    }
  }

  // Helper method to get age in months
  int get ageInMonths {
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      return ((now.year - birthDate.year) * 12) + (now.month - birthDate.month);
    } catch (e) {
      return 0;
    }
  }

  // Helper method to get age in days
  int get ageInDays {
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      return now.difference(birthDate).inDays;
    } catch (e) {
      return 0;
    }
  }
}
