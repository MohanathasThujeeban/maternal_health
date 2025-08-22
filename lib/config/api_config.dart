class ApiConfig {
  // Base URL for all API endpoints
  static const String serverIp =
      '10.11.17.8'; // Updated to current ITUM WiFi IP
  static const int serverPort = 8080;

  // Base URLs for different services
  static const String baseApiUrl = 'http://$serverIp:$serverPort/api';
  static const String appointmentsUrl = '$baseApiUrl/appointments';
  static const String authUrl = baseApiUrl;

  // Other configuration constants can be added here
}
