class ApiConfig {
  // Local network configuration
  static const String serverIp = '10.11.6.125'; // Current WiFi IP address
  static const int serverPort = 8080;
  static const String localUrl = 'http://$serverIp:$serverPort';

  // Base URL - using local ITUM WiFi IP
  static String get baseUrl => localUrl;
  static String get baseApiUrl => '$baseUrl/api';
  static String get appointmentsUrl => '$baseApiUrl/appointments';
  static String get authUrl => baseApiUrl;

  // Get current mode as string for display
  static String get currentMode => 'Local Network (ITUM WiFi)';
}
