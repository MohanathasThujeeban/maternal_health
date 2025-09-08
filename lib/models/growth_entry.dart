class GrowthEntry {
  final int id;
  final String motherNic;
  final int? babyId; // References Baby.id for specific baby
  final double height;
  final double weight;
  final DateTime date;

  GrowthEntry({
    required this.id,
    required this.motherNic,
    this.babyId, // Optional for backward compatibility
    required this.height,
    required this.weight,
    required this.date,
  });

  factory GrowthEntry.fromJson(Map<String, dynamic> json) {
    return GrowthEntry(
      id: json['id'],
      motherNic: json['motherNic'],
      babyId: json['babyId'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motherNic': motherNic,
      'babyId': babyId,
      'height': height,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }
}
