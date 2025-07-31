class Appointment {
  final String id;
  final String motherNic;
  final String motherName;
  final String motherEmail;
  final String appointmentType; // 'midwife' or 'doctor'
  final String providerName;
  final String providerId;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // 'pending', 'completed', 'cancelled'
  final String? notes;
  final String? additionalProblems;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.motherNic,
    required this.motherName,
    required this.motherEmail,
    required this.appointmentType,
    required this.providerName,
    required this.providerId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.notes,
    this.additionalProblems,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      // Don't send id for new appointments
      if (id.isNotEmpty) 'id': int.tryParse(id) ?? 0,
      'motherNic': motherNic,
      'motherName': motherName,
      'motherEmail': motherEmail,
      'appointmentType': appointmentType
          .toUpperCase(), // Convert to uppercase for backend
      'providerName': providerName,
      'providerId': providerId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status.toUpperCase(), // Convert to uppercase for backend
      'notes': notes,
      'additionalProblems': additionalProblems,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      motherNic: json['motherNic'] ?? '',
      motherName: json['motherName'] ?? '',
      motherEmail: json['motherEmail'] ?? '',
      appointmentType: (json['appointmentType']?.toString() ?? '')
          .toLowerCase(), // Convert from backend uppercase
      providerName: json['providerName'] ?? '',
      providerId: json['providerId'] ?? '',
      appointmentDate: DateTime.parse(json['appointmentDate']),
      timeSlot: json['timeSlot'] ?? '',
      status: (json['status']?.toString() ?? 'pending')
          .toLowerCase(), // Convert from backend uppercase
      notes: json['notes'],
      additionalProblems: json['additionalProblems'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Appointment copyWith({
    String? id,
    String? motherNic,
    String? motherName,
    String? motherEmail,
    String? appointmentType,
    String? providerName,
    String? providerId,
    DateTime? appointmentDate,
    String? timeSlot,
    String? status,
    String? notes,
    String? additionalProblems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      motherNic: motherNic ?? this.motherNic,
      motherName: motherName ?? this.motherName,
      motherEmail: motherEmail ?? this.motherEmail,
      appointmentType: appointmentType ?? this.appointmentType,
      providerName: providerName ?? this.providerName,
      providerId: providerId ?? this.providerId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      additionalProblems: additionalProblems ?? this.additionalProblems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
