class ApiConfig {
  // Your actual ngrok URL from the terminal
  static const String ngrokUrl = 'https://216324cb3b27.ngrok-free.app';

  // Local network configuration
  static const String serverIp = '10.11.8.134'; // ITUM WiFi IP address
  static const int serverPort = 8080;
  static const String localUrl = 'http://$serverIp:$serverPort';

  // Toggle between ngrok and local - set to true for global access
  static const bool useNgrok = true;

  // Dynamic base URL based on mode
  static String get baseUrl => useNgrok ? ngrokUrl : localUrl;

  // Base URLs for different services (using dynamic baseUrl)
  static String get baseApiUrl => '$baseUrl/api';
  static String get appointmentsUrl => '$baseApiUrl/appointments';
  static String get authUrl => baseApiUrl;

  // Get current mode as string for display
  static String get currentMode =>
      useNgrok ? 'Ngrok (Global Access)' : 'Local Network';
}
