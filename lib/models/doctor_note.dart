class DoctorNote {
  final int id;
  final String motherNic;
  final int? babyId;
  final String babyName;
  final String doctorName;
  final String doctorId;
  final String noteTitle;
  final String noteContent;
  final String noteType; // 'general', 'medical', 'follow_up', 'urgent'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // 'active', 'resolved', 'archived'

  DoctorNote({
    required this.id,
    required this.motherNic,
    this.babyId,
    required this.babyName,
    required this.doctorName,
    required this.doctorId,
    required this.noteTitle,
    required this.noteContent,
    required this.noteType,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    required this.status,
  });

  factory DoctorNote.fromJson(Map<String, dynamic> json) {
    return DoctorNote(
      id: json['id'] ?? 0,
      motherNic: json['motherNic'] ?? '',
      babyId: json['babyId'],
      babyName: json['babyName'] ?? '',
      doctorName: json['doctorName'] ?? '',
      doctorId: json['doctorId'] ?? '',
      noteTitle: json['noteTitle'] ?? '',
      noteContent: json['noteContent'] ?? '',
      noteType: json['noteType'] ?? 'general',
      priority: json['priority'] ?? 'medium',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motherNic': motherNic,
      'babyId': babyId,
      'babyName': babyName,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'noteTitle': noteTitle,
      'noteContent': noteContent,
      'noteType': noteType,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
    };
  }

  String get priorityIcon {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return '🚨';
      case 'high':
        return '🔴';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '📋';
    }
  }

  String get typeIcon {
    switch (noteType.toLowerCase()) {
      case 'medical':
        return '⚕️';
      case 'follow_up':
        return '🔄';
      case 'urgent':
        return '🚨';
      case 'general':
        return '📝';
      default:
        return '📋';
    }
  }
}
