class RegistrationData {

  String nicNumber = '';
  String phoneNumber3 = '';
  String password = '';
  String email = '';

  Map<String, dynamic> toJson() => {
    
    "nicNumber": nicNumber,
    "phoneNumber3": phoneNumber3,
    "password": password,
    "email": email,
  };
}