import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import './privacy_security_screen.dart';
import './comprehensive_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'CircularStd',
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                  : [const Color(0xFF4FC3A1), const Color(0xFF3A9B7A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Accessibility Section
          _buildSectionHeader(
            context,
            icon: Icons.accessibility_new,
            title: 'Accessibility',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildThemeCard(context, themeProvider, isDark),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader(
            context,
            icon: Icons.person,
            title: 'Account',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.account_circle,
            title: 'Profile',
            subtitle: 'View and edit your profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComprehensiveProfileScreen(),
                ),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Manage your privacy settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySecurityScreen(),
                ),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // App Info Section
          _buildSectionHeader(
            context,
            icon: Icons.info,
            title: 'About',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.article,
            title: 'Terms & Conditions',
            subtitle: 'Read our terms of service',
            onTap: () {
              // TODO: Navigate to terms screen
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // TODO: Navigate to privacy policy screen
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'CircularStd',
            color: isDark ? const Color(0xFF4FC3A1) : const Color(0xFF2E7D5A),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
              : [Colors.white, const Color(0xFFFAFCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF4FC3A1).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3A1), Color(0xFF3A9B7A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'CircularStd',
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2E7D5A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDark ? 'Dark mode enabled' : 'Light mode enabled',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: const Color(0xFF4FC3A1),
                    activeTrackColor: const Color(0xFF4FC3A1).withOpacity(0.5),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : const Color(0xFF4FC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF4FC3A1)
                        : const Color(0xFF3A9B7A),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose between light and dark theme for better viewing experience',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontFamily: 'CircularStd',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
              : [Colors.white, const Color(0xFFFAFCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF4FC3A1).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF4FC3A1).withOpacity(0.2)
                        : const Color(0xFF4FC3A1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF4FC3A1), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CircularStd',
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2E7D5A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[400] : Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
