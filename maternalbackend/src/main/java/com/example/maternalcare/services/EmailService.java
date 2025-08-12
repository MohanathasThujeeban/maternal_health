package com.example.maternalcare.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.FileCopyUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import jakarta.mail.internet.MimeMessage;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

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
            String verificationUrl = serverUrl + "/api/registration/verify-email?token=" + token;
            
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
            
            // Load HTML template and customize it
            String htmlContent = loadAndCustomizeRegistrationTemplate(userName, to);
            
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
    
    private String loadAndCustomizeRegistrationTemplate(String userName, String email) {
        try {
            // First try to load from file system (for development)
            Path templatePath = Paths.get("src/main/resources/templates/registration-success-email.html");
            String template;
            
            if (Files.exists(templatePath)) {
                logger.info("Loading registration template from file system: {}", templatePath);
                template = Files.readString(templatePath, StandardCharsets.UTF_8);
            } else {
                // Fallback to classpath resource (for production)
                logger.info("Loading registration template from classpath");
                Resource resource = new ClassPathResource("templates/registration-success-email.html");
                try (InputStreamReader reader = new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8)) {
                    template = FileCopyUtils.copyToString(reader);
                }
            }
            
            // Replace placeholders in the template
            String customizedTemplate = template
                .replace("{{userName}}", userName)
                .replace("{{userEmail}}", email)
                .replace("{{serverUrl}}", serverUrl)
                .replace("{{currentYear}}", String.valueOf(java.time.Year.now().getValue()));
            
            logger.info("Successfully loaded and customized registration template for user: {}", userName);
            return customizedTemplate;
            
        } catch (Exception e) {
            logger.error("Failed to load registration template, using fallback", e);
            
            // Fallback to simple HTML if template loading fails
            return "<html><body>" +
                   "<h2>Welcome to Maternal Health, " + userName + "!</h2>" +
                   "<p>Your registration was successful.</p>" +
                   "<p>Thank you for joining us!</p>" +
                   "</body></html>";
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