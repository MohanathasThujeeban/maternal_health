import 'package:logging/logging.dart';

class LoggingService {
  static final Logger _logger = Logger('MaternalHealth');

  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // In development, print to console
      print('${record.level.name}: ${record.time}: ${record.message}');

      // TODO: In production, you might want to send logs to a service like Firebase Crashlytics
      // or write to a file
    });
  }

  static void info(String message) {
    _logger.info(message);
  }

  static void warning(String message) {
    _logger.warning(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  static void debug(String message) {
    _logger.fine(message);
  }
}
