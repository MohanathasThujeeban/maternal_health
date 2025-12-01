import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Screen for handling password reset requests
/// Allows users to request a password reset link via email
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller for managing email input field
  final TextEditingController emailController = TextEditingController();

  
  bool isLoading = false; 

  @override
  void dispose() {
    // Clean up controller when widget is disposed to prevent memory leaks
    emailController.dispose();
    super.dispose();
  }
  
  bool validateEmail() {
    final email = emailController.text.trim();

    // Check if email field is empty
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Basic email format validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  /// Handles the password reset request
  /// Validates email and calls API to send reset link
  Future<void> _handleForgotPassword() async {
    // Validate email before proceeding
    if (!validateEmail()) return;

    // Show loading state
    setState(() {
      isLoading = true;
    });

    try {
      // Call API service to send password reset email
      final result = await ApiService.forgotPassword(
        emailController.text.trim(),
      );

      // Check if widget is still mounted before updating UI
      if (!mounted) return;

      // Handle successful response
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );

        // Display success dialog with instructions
        _showSuccessDialog();
      } else {
        // Handle failed response (e.g., email not found)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle any errors during API call
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state regardless of success or failure
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Shows a dialog informing user that reset email was sent
  /// Dialog is non-dismissible and includes back navigation on OK
  /// Shows a dialog informing user that reset email was sent
  /// Dialog is non-dismissible and includes back navigation on OK
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must press OK button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.email, color: Color(0xFF4FC3A1)),
              SizedBox(width: 10),
              Text('Email Sent!'),
            ],
          ),
          content: const Text(
            'We\'ve sent a password reset link to your email address. Please check your email and follow the instructions to reset your password.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Navigate back to login screen
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF4FC3A1)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'SpotifyCircular',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Decorative icon at the top of the screen
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3A1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Color(0xFF4FC3A1),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Screen title
              const Center(
                child: Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Instructional text explaining the process
              const Center(
                child: Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontFamily: 'SpotifyCircular',
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Email input field label
              const Text(
                'Email Address',
                style: TextStyle(
                  fontFamily: 'SpotifyCircular',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Styled container for email input field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress, // Show email keyboard
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Color(0xFF4FC3A1),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'SpotifyCircular',
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Button to submit password reset request
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3A1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontFamily: 'SpotifyCircular',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : _handleForgotPassword, // Disable button while loading
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Send Reset Link'),
                ),
              ),

              const SizedBox(height: 20),

              // Link to navigate back to login screen
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFF4FC3A1),
                      fontFamily: 'SpotifyCircular',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
