class ApiConfig {
  // Base URL for all API endpoints
  static const String serverIp =
      'localhost'; // Changed to localhost for local testing
  static const int serverPort = 8080;

  // Base URLs for different services
  static const String baseApiUrl = 'http://$serverIp:$serverPort/api';
  static const String appointmentsUrl = '$baseApiUrl/appointments';
  static const String authUrl = baseApiUrl;

  // Other configuration constants can be added here
}
