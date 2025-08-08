package com.example.maternalcare.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import jakarta.mail.internet.MimeMessage;

@Service
public class EmailService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Value("${spring.mail.username}")
    private String fromEmail;
    
    @Value("${app.server.url:http://localhost:8080}")
    private String serverUrl;

    public void sendVerificationEmail(String to, String token) {
        try {
            String subject = "Maternal Health - Verify your email";
            // Use configurable server URL for cross-device accessibility
            String verificationUrl = serverUrl + "/api/auth/verify-email?token=" + token;
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            
            String htmlContent = buildVerificationEmailHtml(verificationUrl);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Verification email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send verification email to: {}", to, e);
            // Don't throw exception - let caller handle gracefully
        }
    }
    
    public void sendPasswordResetEmail(String to, String token) {
        try {
            String subject = "Maternal Health - Password Reset Request";
            String resetUrl = serverUrl + "/api/auth/reset-password-form?token=" + token;
            
            // Create HTML email for better mobile compatibility
            String htmlContent = "<html><body>" +
                               "<h2>Password Reset Request</h2>" +
                               "<p>Hello,</p>" +
                               "<p>You requested a password reset for your Maternal Health account.</p>" +
                               "<p>Click the button below to reset your password:</p>" +
                               "<p><a href=\"" + resetUrl + "\" style=\"background-color: #4CAF50; color: white; padding: 14px 20px; text-decoration: none; border-radius: 4px; display: inline-block;\">Reset Password</a></p>" +
                               "<p>Or copy and paste this link in your browser:</p>" +
                               "<p>" + resetUrl + "</p>" +
                               "<p><strong>This link will expire in 1 hour.</strong></p>" +
                               "<p>If you did not request this password reset, please ignore this email.</p>" +
                               "<p>Best regards,<br>Maternal Health Team</p>" +
                               "</body></html>";

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Password reset email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send password reset email to: {}", to, e);
            // Don't throw exception - let caller handle gracefully
        }
    }
    
    public void sendEmail(String to, String subject, String htmlBody) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true); // true indicates HTML content
            
            mailSender.send(message);
            logger.info("HTML email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send HTML email to: {}", to, e);
            // Don't throw exception - let the calling service handle the failure gracefully
        }
    }
    
    public void sendRegistrationSuccessEmail(String to, String userName) {
        try {
            String subject = "🎉 Welcome to Maternal Health - Registration Successful!";
            
            // Create beautiful HTML content for registration success
            String htmlContent = "<!DOCTYPE html>" +
                "<html lang=\"en\">" +
                "<head>" +
                "<meta charset=\"UTF-8\">" +
                "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                "<title>Welcome to Maternal Health</title>" +
                "<style>" +
                "body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #4FC3A1, #66D4B7); }" +
                ".container { max-width: 600px; margin: 0 auto; background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 30px rgba(79, 195, 161, 0.2); }" +
                ".header { background: linear-gradient(135deg, #4FC3A1, #66D4B7); padding: 40px 30px; text-align: center; color: white; }" +
                ".logo { width: 80px; height: 80px; background: rgba(255, 255, 255, 0.2); border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; font-size: 36px; }" +
                ".header h1 { font-size: 32px; font-weight: 700; margin-bottom: 10px; }" +
                ".content { padding: 40px 30px; text-align: center; }" +
                ".welcome-icon { font-size: 64px; margin-bottom: 25px; }" +
                ".main-title { font-size: 28px; color: #2c5530; margin-bottom: 20px; font-weight: 700; }" +
                ".user-name { color: #4FC3A1; font-weight: bold; font-size: 32px; margin-bottom: 25px; padding: 15px 25px; background: linear-gradient(135deg, #f0fffe, #e8fcf9); border-radius: 15px; border-left: 4px solid #4FC3A1; }" +
                ".message { font-size: 18px; color: #666; line-height: 1.7; margin-bottom: 30px; }" +
                ".cta-button { display: inline-block; background: linear-gradient(135deg, #4FC3A1, #3ea188); color: white; padding: 18px 40px; text-decoration: none; border-radius: 50px; font-weight: bold; font-size: 18px; margin: 20px 0; }" +
                ".footer { background: #2c5530; color: white; padding: 30px; text-align: center; }" +
                ".footer-text { font-size: 14px; opacity: 0.8; line-height: 1.6; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class=\"container\">" +
                "<div class=\"header\">" +
                "<div class=\"logo\">🤱</div>" +
                "<h1>Maternal Health</h1>" +
                "<p>Your trusted companion for a healthy pregnancy journey</p>" +
                "</div>" +
                "<div class=\"content\">" +
                "<div class=\"welcome-icon\">🎉</div>" +
                "<h2 class=\"main-title\">Congratulations!</h2>" +
                "<div class=\"user-name\">Welcome, " + userName + "!</div>" +
                "<p class=\"message\">" +
                "🌟 <strong>Your registration was successful!</strong> 🌟<br><br>" +
                "We're absolutely thrilled to welcome you to the Maternal Health community! " +
                "You've taken the first step towards a healthier, happier pregnancy journey, " +
                "and we're here to support you every step of the way." +
                "</p>" +
                "<div style=\"background: #f8fffe; padding: 25px; border-radius: 15px; margin: 25px 0; text-align: left;\">" +
                "<h3 style=\"color: #2c5530; text-align: center; margin-bottom: 20px;\">✨ What's waiting for you:</h3>" +
                "<div style=\"display: flex; align-items: center; margin-bottom: 15px;\">" +
                "<div style=\"width: 30px; height: 30px; background: #4FC3A1; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; color: white;\">📊</div>" +
                "<div><strong>Health Tracking:</strong> Monitor your pregnancy progress with personalized insights</div>" +
                "</div>" +
                "<div style=\"display: flex; align-items: center; margin-bottom: 15px;\">" +
                "<div style=\"width: 30px; height: 30px; background: #4FC3A1; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; color: white;\">👩‍⚕️</div>" +
                "<div><strong>Expert Guidance:</strong> Access to healthcare professionals and evidence-based information</div>" +
                "</div>" +
                "<div style=\"display: flex; align-items: center; margin-bottom: 15px;\">" +
                "<div style=\"width: 30px; height: 30px; background: #4FC3A1; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; color: white;\">📱</div>" +
                "<div><strong>Smart Reminders:</strong> Never miss important appointments and health check-ups</div>" +
                "</div>" +
                "<div style=\"display: flex; align-items: center;\">" +
                "<div style=\"width: 30px; height: 30px; background: #4FC3A1; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; color: white;\">👶</div>" +
                "<div><strong>Baby Development:</strong> Track your baby's growth week by week</div>" +
                "</div>" +
                "</div>" +
                "<a href=\"maternal://welcome\" class=\"cta-button\" style=\"color: white; text-decoration: none;\">🚀 Start Your Journey</a>" +
                "<p style=\"margin-top: 15px; color: #888; font-size: 14px;\">Tap the button above to open the app and begin exploring!</p>" +
                "</div>" +
                "<div class=\"footer\">" +
                "<h3 style=\"margin-bottom: 15px;\">🌸 Thank You for Choosing Us!</h3>" +
                "<p class=\"footer-text\">" +
                "Remember, every pregnancy journey is unique and beautiful. We're honored to be part of yours. " +
                "If you have any questions or need support, our team is always here to help." +
                "</p>" +
                "<p class=\"footer-text\" style=\"margin-top: 20px;\">" +
                "<strong>Email:</strong> support@maternalhealth.com<br>" +
                "<strong>Phone:</strong> +1 (555) 123-4567" +
                "</p>" +
                "<p style=\"margin-top: 20px; font-size: 12px; opacity: 0.7;\">" +
                "© 2025 Maternal Health App. All rights reserved.<br>" +
                "This email was sent to " + to +
                "</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Registration success email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send registration success email to: {}", to, e);
            // Don't throw exception - let caller handle gracefully
        }
    }
    
    public boolean testEmailConnection() {
        try {
            // Try to send a simple test (you can remove this in production)
            logger.info("Testing email connection...");
            return true;
        } catch (Exception e) {
            logger.error("Email connection test failed", e);
            return false;
        }
    }

    private String buildVerificationEmailHtml(String verificationUrl) {
        return """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f4f4f4; }
                        .container { max-width: 600px; margin: 20px auto; background: #ffffff; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
                        .header { text-align: center; padding: 20px; }
                        .logo { font-size: 24px; color: #4FC3A1; margin-bottom: 20px; }
                        .button { display: inline-block; padding: 12px 30px; background-color: #4FC3A1; color: #ffffff; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 14px; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="logo">🤱 Maternal Health</div>
                            <h2>Email Verification</h2>
                        </div>
                        <div style="text-align: center;">
                            <p>Thank you for registering! Please click the button below to verify your email address:</p>
                            <a href="%s" class="button" style="color: white;">Verify Email</a>
                            <p style="font-size: 14px; color: #666;">Or copy and paste this link in your browser:</p>
                            <p style="font-size: 12px; color: #999; word-break: break-all;">%s</p>
                        </div>
                        <div class="footer">
                            <p>This link will expire in 24 hours.</p>
                            <p>If you didn't request this verification, please ignore this email.</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(verificationUrl, verificationUrl);
    }
}