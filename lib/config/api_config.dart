class ApiConfig {
  // Railway Production URL
  static const String productionUrl =
      'https://maternalhealth-production.up.railway.app';

  // Local network configuration (for development)
  static const String serverIp = '10.11.24.105'; // Current WiFi IP address
  static const int serverPort = 8080;
  static const String localUrl = 'http://$serverIp:$serverPort';

  // Base URL - using local laptop server
  static String get baseUrl => localUrl;
  static String get baseApiUrl => '$baseUrl/api';
  static String get appointmentsUrl => '$baseApiUrl/appointments';
  static String get authUrl => baseApiUrl;

  // Get current mode as string for display
  static String get currentMode => 'Local Server ($serverIp:$serverPort)';
}
