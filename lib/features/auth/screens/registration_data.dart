class RegistrationData {
  String motherFullName = '';
  String fatherFullName = '';
  String address = '';
  String phoneNumber = '';
  String age = '';
  String occupation = '';
  String ethnicity = '';
  String religion = '';
  String educationLevel = '';
  String gravida = '';
  String para = '';
  String lmp = '';
  String edd = '';
  String previousPregnancies = '';
  String year = '';
  String duration = '';
  String modeOfDelivery = '';
  String birthWeight = '';
  String sex = '';
  String status = '';
  String nicNumber = '';
  String phoneNumber3 = '';
  String password = '';

  Map<String, dynamic> toJson() => {
    "motherFullName": motherFullName,
    "fatherFullName": fatherFullName,
    "address": address,
    "phoneNumber": phoneNumber,
    "age": age,
    "occupation": occupation,
    "ethnicity": ethnicity,
    "religion": religion,
    "educationLevel": educationLevel,
    "gravida": gravida,
    "para": para,
    "lmp": lmp,
    "edd": edd,
    "previousPregnancies": previousPregnancies,
    "year": year,
    "duration": duration,
    "modeOfDelivery": modeOfDelivery,
    "birthWeight": birthWeight,
    "sex": sex,
    "status": status,
    "nicNumber": nicNumber,
    "phoneNumber3": phoneNumber3,
    "password": password,
  };
}