class ThiriposaRecord {
  final int id;
  final String motherNic;
  final DateTime date;
  final int quantity;
  final DateTime createdAt;

  ThiriposaRecord({
    required this.id,
    required this.motherNic,
    required this.date,
    required this.quantity,
    required this.createdAt,
  });

  factory ThiriposaRecord.fromJson(Map<String, dynamic> json) {
    return ThiriposaRecord(
      id: json['id'],
      motherNic: json['motherNic'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motherNic': motherNic,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
