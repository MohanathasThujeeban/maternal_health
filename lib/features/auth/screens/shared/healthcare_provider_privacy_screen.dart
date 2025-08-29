import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/api_config.dart';
import '../../../../services/user_service.dart';
import '../../../../widgets/custom_loading.dart';

class HealthcareProviderPrivacyScreen extends StatefulWidget {
  final String userRole; // "MIDWIFE" or "DOCTOR"

  const HealthcareProviderPrivacyScreen({super.key, required this.userRole});

  @override
  State<HealthcareProviderPrivacyScreen> createState() =>
      _HealthcareProviderPrivacyScreenState();
}

class _HealthcareProviderPrivacyScreenState
    extends State<HealthcareProviderPrivacyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _currentUserIdentifier;
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    try {
      _currentUserData = await UserService.getUserData();
      _currentUserIdentifier =
          _currentUserData?['nic']; // For healthcare providers, this might be medical license number

      print('Debug: Current user data: $_currentUserData');
      print('Debug: Current user identifier: $_currentUserIdentifier');
    } catch (e) {
      print('Error loading user info: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isChangingPassword = true);

    try {
      if (_currentUserIdentifier == null) {
        throw Exception('User session not found. Please login again.');
      }

      final requestData = {
        'currentPassword': _currentPasswordController.text.trim(),
        'newPassword': _newPasswordController.text.trim(),
      };

      print(
        'Debug: Changing password for healthcare provider: $_currentUserIdentifier',
      );

      // Use the healthcare provider specific endpoint
      final response = await http.put(
        Uri.parse(
          '${ApiConfig.baseApiUrl}/healthcare/change-password/$_currentUserIdentifier',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Debug: Password change response status: ${response.statusCode}');
      print('Debug: Password change response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // Clear form
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password changed successfully! ✅',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A confirmation email has been sent to your registered email address.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to change password',
          );
        }
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Invalid current password');
      } else {
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CustomLoading(
            message: 'Loading...',
            size: 100,
            backgroundColor: Colors.transparent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpotifyCircular',
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D5A), Color(0xFF1E5D3F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(Icons.security, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.userRole.toLowerCase().capitalize()} Security',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your professional account security',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontFamily: 'SpotifyCircular',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security Options
            _buildSecuritySection(),

            const SizedBox(height: 24),

            // Change Password Section
            _buildChangePasswordSection(),

            const SizedBox(height: 24),

            // Privacy Information
            _buildPrivacyInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: const Color(0xFF2E7D5A),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Security Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D5A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFF2E7D5A),
                size: 20,
              ),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            subtitle: const Text(
              'Update your professional account password',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF2E7D5A),
            ),
            onTap: () {
              // Scroll to password change section
            },
          ),

          const Divider(),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SpotifyCircular',
              ),
            ),
            subtitle: const Text(
              'Healthcare privacy guidelines',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: const Icon(
              Icons.open_in_new,
              color: Colors.blue,
              size: 20,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy will be available soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_reset,
                  color: const Color(0xFF2E7D5A),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Password
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Current Password',
              obscureText: _obscureCurrentPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Current password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // New Password
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: _obscureNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'New password is required';
                }
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                if (value == _currentPasswordController.text) {
                  return 'New password must be different from current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Password Requirements
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• At least 6 characters long\n'
                    '• Different from your current password\n'
                    '• Use a combination of letters and numbers for better security\n'
                    '• Avoid using personal information',
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isChangingPassword ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isChangingPassword
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SpotifyCircular',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip, color: const Color(0xFF2E7D5A), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Healthcare Privacy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpotifyCircular',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoItem(
            icon: Icons.security,
            title: 'Data Security',
            description:
                'Your professional credentials and patient data are encrypted and stored securely.',
          ),

          _buildInfoItem(
            icon: Icons.shield,
            title: 'HIPAA Compliance',
            description:
                'We maintain strict healthcare privacy standards and compliance protocols.',
          ),

          _buildInfoItem(
            icon: Icons.lock,
            title: 'Access Control',
            description:
                'Role-based access ensures you only see information relevant to your practice.',
          ),

          _buildInfoItem(
            icon: Icons.contact_support,
            title: 'Professional Support',
            description:
                'Dedicated support for healthcare providers available 24/7.',
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D5A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D5A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D5A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
