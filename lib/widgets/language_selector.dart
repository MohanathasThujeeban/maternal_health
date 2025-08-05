import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopupMenuButton<String>(
      onSelected: (String languageCode) {
        languageProvider.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return languageProvider.supportedLanguages.map((language) {
          return PopupMenuItem<String>(
            value: language['code'],
            child: Row(
              children: [
                Icon(
                  languageProvider.currentLocale.languageCode ==
                          language['code']
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: const Color(0xFF4FC3A1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  language['nativeName']!,
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4FC3A1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              _getCurrentLanguageNativeName(
                languageProvider.currentLocale.languageCode,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'SpotifyCircular',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'ta':
        return 'தமிழ்';
      case 'si':
        return 'සිංහල';
      default:
        return 'English';
    }
  }
}
