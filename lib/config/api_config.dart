class ApiConfig {
  // Railway Production URL
  static const String productionUrl = 'https://maternalhealth-production.up.railway.app';
  
  // Local network configuration (for development)
  static const String serverIp = '10.11.19.220'; // Current WiFi IP address
  static const int serverPort = 8080;
  static const String localUrl = 'http://$serverIp:$serverPort';

  // Base URL - using Railway production server
  static String get baseUrl => productionUrl;
  static String get baseApiUrl => '$baseUrl/api';
  static String get appointmentsUrl => '$baseApiUrl/appointments';
  static String get authUrl => baseApiUrl;

  // Get current mode as string for display
  static String get currentMode => 'Railway Cloud (Production)';
}
