class ApiConfig {
  // Base URL for all API endpoints
  static const String serverIp =
      '10.11.8.134'; // Updated to ITUM WiFi IP address
  static const int serverPort = 8080;

  // Base URLs for different services
  static const String baseApiUrl = 'http://$serverIp:$serverPort/api';
  static const String appointmentsUrl = '$baseApiUrl/appointments';
  static const String authUrl = baseApiUrl;

  // Other configuration constants can be added here
}
