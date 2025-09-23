import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/health_chatbox/health_chatbox_screen.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/logging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging service
  LoggingService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: languageProvider.currentLocale,
          theme: ThemeData(fontFamily: 'CircularStd'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ta'), Locale('si')],
          initialRoute: '/',
          routes: {
            '/': (context) => LoginScreen(),
            '/health-chatbox': (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments as String?;
              return HealthChatboxScreen(initialTopic: args);
            },
          },
        );
      },
    );
  }
}
