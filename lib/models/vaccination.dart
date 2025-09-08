class Vaccination {
  final int id;
  final String motherNic;
  final String? motherName;
  final int? babyId;
  final String childName;
  final String vaccinationType;
  final String ageToGive;
  final String vaccinationDate;
  final String? batchNumber;
  final String? effectsFollowingImmunization;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vaccination({
    required this.id,
    required this.motherNic,
    this.motherName,
    this.babyId,
    required this.childName,
    required this.vaccinationType,
    required this.ageToGive,
    required this.vaccinationDate,
    this.batchNumber,
    this.effectsFollowingImmunization,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'],
      motherNic: json['motherNic'],
      motherName: json['motherName'],
      babyId: json['babyId'],
      childName: json['childName'],
      vaccinationType: json['vaccinationType'],
      ageToGive: json['ageToGive'],
      vaccinationDate: json['vaccinationDate'],
      batchNumber: json['batchNumber'],
      effectsFollowingImmunization: json['effectsFollowingImmunization'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motherNic': motherNic,
      'motherName': motherName,
      'babyId': babyId,
      'childName': childName,
      'vaccinationType': vaccinationType,
      'ageToGive': ageToGive,
      'vaccinationDate': vaccinationDate,
      'batchNumber': batchNumber,
      'effectsFollowingImmunization': effectsFollowingImmunization,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get formatted vaccination date
  String get formattedVaccinationDate {
    try {
      final date = DateTime.parse(vaccinationDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return vaccinationDate;
    }
  }

  // Helper method to check if vaccination is completed
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  // Helper method to check if vaccination is pending
  bool get isPending => status.toUpperCase() == 'PENDING';

  // Helper method to check if vaccination is overdue
  bool get isOverdue => status.toUpperCase() == 'OVERDUE';
}
