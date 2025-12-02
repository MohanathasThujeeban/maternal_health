class UserModel {
  final String nicNumber;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userRole;
  final bool? isActive;

  UserModel({
    required this.nicNumber,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userRole,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nicNumber: json['nicNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber3'] ?? json['phoneNumber'] ?? '',
      userRole: json['userRole'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nicNumber': nicNumber,
      'fullName': fullName,
      'email': email,
      'phoneNumber3': phoneNumber,
      'userRole': userRole,
      'isActive': isActive,
    };
  }
}
