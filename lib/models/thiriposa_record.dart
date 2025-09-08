class ThiriposaRecord {
  final int id;
  final String motherNic;
  final int? babyId; // References Baby.id for specific baby
  final DateTime date;
  final int quantity;
  final DateTime createdAt;

  ThiriposaRecord({
    required this.id,
    required this.motherNic,
    this.babyId, // Optional for backward compatibility
    required this.date,
    required this.quantity,
    required this.createdAt,
  });

  factory ThiriposaRecord.fromJson(Map<String, dynamic> json) {
    return ThiriposaRecord(
      id: json['id'],
      motherNic: json['motherNic'],
      babyId: json['babyId'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motherNic': motherNic,
      'babyId': babyId,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
