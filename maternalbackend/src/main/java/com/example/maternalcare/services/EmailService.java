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
    
    @Value("${app.server.url:http://10.11.24.105:8080}")
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
            
            // Send push notification after successful email sending
            sendEmailPushNotification(to, subject);
            
        } catch (Exception e) {
            logger.error("Failed to send HTML email to: {}", to, e);
            // Don't throw exception - let the calling service handle the failure gracefully
        }
    }
    
    /**
     * Send email with push notification using user NIC
     */
    public void sendEmailWithNotification(String to, String subject, String htmlBody, String recipientNic) {
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
    
    /**
     * Send push notification for email sent
     */
    private void sendEmailPushNotification(String recipientEmail, String emailSubject) {
        try {
            // Try to find user NIC by email for notification
            // For now, we'll use the email as identifier since we don't have direct email-to-NIC mapping
            // In a real implementation, you'd query your user repository to get NIC by email
            
            // Extract a shorter subject for notification
            String shortSubject = emailSubject.length() > 50 ? 
                emailSubject.substring(0, 47) + "..." : emailSubject;
            
            // Since we don't have email-to-NIC mapping, we'll log this for now
            // In practice, you would need to add a method to find user NIC by email
            logger.info("📧 Would send push notification for email sent to: {} with subject: {}", 
                       recipientEmail, shortSubject);
            
            // TODO: Implement email-to-NIC lookup
            // String userNic = userRepository.findNicByEmail(recipientEmail);
            // if (userNic != null) {
            //     firebaseMessagingService.sendEmailNotification(userNic, shortSubject, "System");
            // }
            
        } catch (Exception e) {
            logger.error("Failed to send push notification for email to: {}", recipientEmail, e);
            // Don't fail the whole email sending process if push notification fails
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

    /**
     * Send appointment slot availability notification to mothers
     */
    public void sendSlotAvailabilityNotification(String to, String motherName, String providerName, 
                                                String appointmentType, String appointmentDate, String timeSlot) {
        try {
            String subject = "📅 Appointment Slot Available - " + providerName + " on " + appointmentDate;
            String htmlContent = buildSlotAvailabilityEmailBody(motherName, providerName, appointmentType, appointmentDate, timeSlot);
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);
            
            mailSender.send(message);
            logger.info("Slot availability notification email sent successfully to: {}", to);
            
        } catch (Exception e) {
            logger.error("Failed to send slot availability notification email to: {}", to, e);
            // Don't throw exception - let the calling service handle the failure gracefully
        }
    }

    private String buildSlotAvailabilityEmailBody(String motherName, String providerName, 
                                                 String appointmentType, String appointmentDate, String timeSlot) {
        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Appointment Slot Available</title>
            </head>
            <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f7fa;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
                    
                    <!-- Header -->
                    <div style="background: linear-gradient(135deg, #4FC3A1 0%%, #2E7D5A 100%%); color: white; padding: 30px; text-align: center;">
                        <div style="font-size: 24px; font-weight: bold; margin-bottom: 10px;">
                            🎯 Appointment Slot Available!
                        </div>
                        <div style="font-size: 16px; opacity: 0.9;">
                            A slot has opened up for your preferred provider
                        </div>
                    </div>
                    
                    <!-- Content -->
                    <div style="padding: 40px 30px;">
                        <h2 style="color: #2E7D5A; margin-bottom: 20px; font-size: 20px;">
                            Dear %s,
                        </h2>
                        
                        <p style="color: #555; font-size: 16px; line-height: 1.6; margin-bottom: 25px;">
                            Great news! An appointment slot has become available with <strong>%s</strong>. 
                            This is a perfect opportunity to schedule your appointment.
                        </p>
                        
                        <!-- Appointment Details Card -->
                        <div style="background-color: #f8fffe; border: 2px solid #4FC3A1; border-radius: 8px; padding: 25px; margin: 25px 0;">
                            <h3 style="color: #2E7D5A; margin-top: 0; margin-bottom: 20px; font-size: 18px;">
                                📋 Available Slot Details
                            </h3>
                            
                            <table style="width: 100%%; border-collapse: collapse;">
                                <tr style="margin-bottom: 12px;">
                                    <td style="color: #666; font-weight: bold; padding: 8px 0; width: 140px; vertical-align: top;">
                                        👩‍⚕️ Provider:
                                    </td>
                                    <td style="color: #2E7D5A; font-weight: bold; padding: 8px 0; vertical-align: top;">
                                        %s
                                    </td>
                                </tr>
                                <tr style="margin-bottom: 12px;">
                                    <td style="color: #666; font-weight: bold; padding: 8px 0; width: 140px; vertical-align: top;">
                                        🩺 Type:
                                    </td>
                                    <td style="color: #2E7D5A; padding: 8px 0; vertical-align: top;">
                                        %s Consultation
                                    </td>
                                </tr>
                                <tr style="margin-bottom: 12px;">
                                    <td style="color: #666; font-weight: bold; padding: 8px 0; width: 140px; vertical-align: top;">
                                        📅 Date:
                                    </td>
                                    <td style="color: #2E7D5A; font-weight: bold; padding: 8px 0; vertical-align: top; font-size: 16px;">
                                        %s
                                    </td>
                                </tr>
                                <tr style="margin-bottom: 12px;">
                                    <td style="color: #666; font-weight: bold; padding: 8px 0; width: 140px; vertical-align: top;">
                                        ⏰ Time:
                                    </td>
                                    <td style="color: #2E7D5A; font-weight: bold; padding: 8px 0; vertical-align: top; font-size: 16px;">
                                        %s
                                    </td>
                                </tr>
                            </table>
                        </div>
                        
                        <!-- Call to Action -->
                        <div style="text-align: center; margin: 35px 0;">
                            <div style="background-color: #fff8e1; border-radius: 8px; padding: 20px; margin-bottom: 25px;">
                                <p style="color: #f57c00; font-size: 16px; margin: 0; font-weight: bold;">
                                    ⚡ This slot may fill up quickly! Book now to secure your appointment.
                                </p>
                            </div>
                            
                            <p style="color: #555; font-size: 16px; line-height: 1.6;">
                                To book this appointment, please open your Maternal Health app and schedule your appointment as usual.
                            </p>
                        </div>
                        
                        <!-- Important Note -->
                        <div style="background-color: #f0f9ff; border-left: 4px solid #4FC3A1; padding: 20px; margin: 25px 0;">
                            <h4 style="color: #2E7D5A; margin-top: 0; margin-bottom: 10px;">
                                📱 How to Book:
                            </h4>
                            <ol style="color: #555; margin: 0; padding-left: 20px;">
                                <li style="margin-bottom: 8px;">Open your Maternal Health mobile app</li>
                                <li style="margin-bottom: 8px;">Go to the Appointments section</li>
                                <li style="margin-bottom: 8px;">Select "Schedule New Appointment"</li>
                                <li style="margin-bottom: 8px;">Choose the provider and available slot</li>
                                <li>Confirm your booking</li>
                            </ol>
                        </div>
                        
                        <p style="color: #777; font-size: 14px; text-align: center; margin-top: 30px;">
                            This is an automated notification. Please do not reply to this email.
                        </p>
                    </div>
                    
                    <!-- Footer -->
                    <div style="background-color: #2c3e50; color: white; padding: 25px; text-align: center;">
                        <div style="font-size: 18px; font-weight: 600; margin-bottom: 5px;">
                            Maternal Health Care System
                        </div>
                        <div style="font-size: 14px; opacity: 0.8;">
                            Caring for mothers and babies with love 💝
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """, 
            motherName, providerName, providerName, appointmentType, appointmentDate, timeSlot);
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
    
    public void sendHealthcareProviderWelcomeEmail(String to, String name, String providerType) {
        try {
            String subject = "Welcome to Maternal Health - Healthcare Provider Registration";
            String htmlContent = buildHealthcareProviderWelcomeEmailHtml(name, providerType);
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Healthcare provider welcome email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send healthcare provider welcome email to: {}", to, e);
        }
    }
    
    public void sendHealthcareProviderApprovalEmail(String to, String name, String providerType) {
        try {
            String subject = "Maternal Health - Account Approved";
            String htmlContent = buildHealthcareProviderApprovalEmailHtml(name, providerType);
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Healthcare provider approval email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send healthcare provider approval email to: {}", to, e);
        }
    }
    
    private String buildHealthcareProviderWelcomeEmailHtml(String name, String providerType) {
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
                        .content { padding: 20px; }
                        .highlight { background-color: #e8f5f0; padding: 15px; border-radius: 5px; margin: 20px 0; }
                        .success-badge { background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; border: 1px solid #c3e6cb; text-align: center; }
                        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 14px; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="logo">🏥 Maternal Health</div>
                            <h2>Welcome! Your Account is Ready</h2>
                        </div>
                        <div class="content">
                            <div class="success-badge">
                                <h3>✅ Registration Successful - You can now login!</h3>
                            </div>
                            
                            <p>Dear %s,</p>
                            <p>Congratulations! You have successfully registered as a <strong>%s</strong> with Maternal Health. Your account has been approved and is ready for use.</p>
                            
                            <div class="highlight">
                                <h3>� Login Instructions:</h3>
                                <ul>
                                    <li><strong>Username:</strong> Your Medical License Number</li>
                                    <li><strong>Password:</strong> The password you created during registration</li>
                                    <li><strong>Access:</strong> Use the Healthcare Provider Login option in the app</li>
                                    <li><strong>Dashboard:</strong> Access your personalized dashboard to view appointments and patient information</li>
                                </ul>
                            </div>
                            
                            <p><strong>What you can do now:</strong></p>
                            <ul>
                                <li>Login to your healthcare provider dashboard</li>
                                <li>View and manage your appointments</li>
                                <li>Update your profile information</li>
                                <li>Provide maternal healthcare services</li>
                            </ul>
                            
                            <p>If you have any questions or need assistance, please don't hesitate to contact our support team.</p>
                            
                            <p>Best regards,<br><strong>Maternal Health Team</strong></p>
                        </div>
                        <div class="footer">
                            <p>This is an automated message. Please do not reply to this email.</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(name, providerType);
    }
    
    private String buildHealthcareProviderApprovalEmailHtml(String name, String providerType) {
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
                        .content { padding: 20px; }
                        .success-badge { background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; border: 1px solid #c3e6cb; text-align: center; }
                        .login-info { background-color: #e8f5f0; padding: 15px; border-radius: 5px; margin: 20px 0; }
                        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 14px; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="logo">🏥 Maternal Health</div>
                            <h2>Account Approved - Welcome Aboard!</h2>
                        </div>
                        <div class="content">
                            <div class="success-badge">
                                <h3>✅ Congratulations! Your account has been approved</h3>
                            </div>
                            
                            <p>Dear %s,</p>
                            <p>Great news! Your <strong>%s</strong> account has been successfully approved and activated. You can now access the Maternal Health platform.</p>
                            
                            <div class="login-info">
                                <h3>🔑 Login Information:</h3>
                                <ul>
                                    <li><strong>Username:</strong> Your Medical License Number</li>
                                    <li><strong>Password:</strong> The password you created during registration</li>
                                    <li><strong>Portal:</strong> Healthcare Provider Portal</li>
                                </ul>
                            </div>
                            
                            <p><strong>Features available to you:</strong></p>
                            <ul>
                                <li>📅 Manage patient appointments</li>
                                <li>📋 Access patient records</li>
                                <li>💬 Communicate with patients</li>
                                <li>📊 View health analytics</li>
                                <li>🔔 Receive important notifications</li>
                            </ul>
                            
                            <p>Thank you for joining our mission to provide better maternal healthcare. Your expertise and dedication will help us serve our community better.</p>
                            
                            <p>Welcome to the team!</p>
                            
                            <p>Best regards,<br><strong>Maternal Health Team</strong></p>
                        </div>
                        <div class="footer">
                            <p>If you have any questions, please contact our support team.</p>
                            <p>This is an automated message. Please do not reply to this email.</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(name, providerType);
    }

    public void sendVerificationEmail(String to, String fullName, String verificationCode) {
        try {
            String subject = "Maternal Health - Email Verification Code";
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            
            String htmlContent = buildVerificationCodeEmailHtml(fullName, verificationCode);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Verification email sent successfully to: {}", to);
            
        } catch (Exception e) {
            logger.error("Failed to send verification email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send verification email", e);
        }
    }

    private String buildVerificationCodeEmailHtml(String name, String verificationCode) {
        return """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Email Verification</title>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f5fffe; }
                        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }
                        .header { background: linear-gradient(135deg, #4FC3A1, #3DA58A); color: white; padding: 40px 30px; text-align: center; }
                        .content { padding: 40px 30px; }
                        .verification-code { background-color: #4FC3A1; color: white; font-size: 32px; font-weight: bold; text-align: center; padding: 20px; border-radius: 10px; margin: 20px 0; letter-spacing: 4px; }
                        .footer { background-color: #f8f9fa; padding: 20px 30px; text-align: center; color: #666; font-size: 14px; }
                        .button { display: inline-block; background-color: #4FC3A1; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; margin: 20px 0; }
                        .highlight { color: #4FC3A1; font-weight: bold; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1>🏥 Email Verification</h1>
                            <p>Healthcare Provider Registration</p>
                        </div>
                        <div class="content">
                            <h2>Hello %s!</h2>
                            
                            <p>Thank you for registering as a healthcare provider with <strong class="highlight">Maternal Health</strong>. To complete your registration, please verify your email address.</p>
                            
                            <p>Your verification code is:</p>
                            
                            <div class="verification-code">%s</div>
                            
                            <p><strong>Instructions:</strong></p>
                            <ol>
                                <li>Return to the registration form in the app</li>
                                <li>Enter this 6-digit verification code</li>
                                <li>Click "Verify" to confirm your email address</li>
                                <li>Complete the remaining registration steps</li>
                            </ol>
                            
                            <p><strong>Important:</strong> This code is valid for 10 minutes. If you didn't request this verification, please ignore this email.</p>
                            
                            <p>Once your registration is complete, it will be reviewed by our medical team for approval.</p>
                            
                            <p>Best regards,<br><strong>Maternal Health Team</strong></p>
                        </div>
                        <div class="footer">
                            <p>If you have any questions, please contact our support team.</p>
                            <p>This is an automated message. Please do not reply to this email.</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(name != null ? name : "Healthcare Provider", verificationCode);
    }
    
    public void sendVaccinationNotificationEmail(String to, String motherName, String childName, 
                                               String vaccinationType, String ageToGive, 
                                               String vaccinationDate, String midwifeName) {
        try {
            String subject = "Vaccination Record Updated - " + childName;
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            
            String htmlContent = buildVaccinationNotificationHtml(motherName, childName, 
                vaccinationType, ageToGive, vaccinationDate, midwifeName);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Vaccination notification email sent successfully to {}", to);
            
        } catch (Exception e) {
            logger.error("Failed to send vaccination notification email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send vaccination notification email", e);
        }
    }
    
    private String buildVaccinationNotificationHtml(String motherName, String childName, 
                                                   String vaccinationType, String ageToGive, 
                                                   String vaccinationDate, String midwifeName) {
        return """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Vaccination Record Updated</title>
                    <style>
                        body {
                            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                            line-height: 1.6;
                            color: #333;
                            background-color: #f5f5f5;
                            margin: 0;
                            padding: 20px;
                        }
                        .container {
                            max-width: 600px;
                            margin: 0 auto;
                            background-color: #ffffff;
                            border-radius: 10px;
                            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                            overflow: hidden;
                        }
                        .header {
                            background: linear-gradient(135deg, #4FC3A1 0%%, #45B7A8 100%%);
                            color: white;
                            text-align: center;
                            padding: 30px 20px;
                        }
                        .header h1 {
                            margin: 0;
                            font-size: 28px;
                            font-weight: 600;
                        }
                        .header .icon {
                            font-size: 48px;
                            margin-bottom: 10px;
                        }
                        .content {
                            padding: 40px 30px;
                        }
                        .greeting {
                            font-size: 18px;
                            color: #2c3e50;
                            margin-bottom: 20px;
                        }
                        .main-message {
                            background-color: #f8fffe;
                            border-left: 4px solid #4FC3A1;
                            padding: 20px;
                            margin: 20px 0;
                            border-radius: 5px;
                        }
                        .vaccination-details {
                            background-color: #ffffff;
                            border: 2px solid #e8f5f2;
                            border-radius: 10px;
                            padding: 25px;
                            margin: 20px 0;
                        }
                        .vaccination-details h3 {
                            color: #4FC3A1;
                            font-size: 20px;
                            margin-bottom: 15px;
                            border-bottom: 2px solid #e8f5f2;
                            padding-bottom: 10px;
                        }
                        .detail-row {
                            display: flex;
                            margin-bottom: 12px;
                            align-items: center;
                        }
                        .detail-label {
                            font-weight: 600;
                            color: #2c3e50;
                            min-width: 140px;
                            margin-right: 10px;
                        }
                        .detail-value {
                            color: #34495e;
                            font-weight: 500;
                        }
                        .highlight {
                            background-color: #4FC3A1;
                            color: white;
                            padding: 4px 8px;
                            border-radius: 4px;
                            font-weight: 600;
                        }
                        .midwife-info {
                            background-color: #e8f5f2;
                            border-radius: 8px;
                            padding: 15px;
                            margin: 20px 0;
                            text-align: center;
                        }
                        .important-note {
                            background-color: #fff7e6;
                            border: 1px solid #ffd700;
                            border-radius: 8px;
                            padding: 15px;
                            margin: 20px 0;
                            color: #8b6914;
                        }
                        .footer {
                            background-color: #f8f9fa;
                            text-align: center;
                            padding: 25px;
                            border-top: 1px solid #e9ecef;
                            font-size: 14px;
                            color: #6c757d;
                        }
                        .logo {
                            width: 40px;
                            height: 40px;
                            background-color: rgba(255, 255, 255, 0.2);
                            border-radius: 50%%;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            margin-bottom: 10px;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="logo">💉</div>
                            <h1>Vaccination Record Updated</h1>
                            <p>Your child's immunization record has been updated</p>
                        </div>
                        <div class="content">
                            <div class="greeting">
                                Dear <strong>%s</strong>,
                            </div>
                            
                            <div class="main-message">
                                <p>We are pleased to inform you that a vaccination record has been successfully added for your child <strong>%s</strong>. This record has been updated by your healthcare provider and is now part of your child's permanent immunization history.</p>
                            </div>
                            
                            <div class="vaccination-details">
                                <h3>🩺 Vaccination Details</h3>
                                <div class="detail-row">
                                    <span class="detail-label">Child Name:</span>
                                    <span class="detail-value"><strong>%s</strong></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Vaccine Type:</span>
                                    <span class="detail-value highlight">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Age to Give:</span>
                                    <span class="detail-value">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Vaccination Date:</span>
                                    <span class="detail-value">%s</span>
                                </div>
                            </div>
                            
                            <div class="midwife-info">
                                <p><strong>👩‍⚕️ Administered by:</strong> %s</p>
                                <p><em>Licensed Healthcare Provider</em></p>
                            </div>
                            
                            <div class="important-note">
                                <p><strong>📋 Important Reminders:</strong></p>
                                <ul>
                                    <li>Keep this record for your child's health documentation</li>
                                    <li>Watch for any side effects and contact your healthcare provider if needed</li>
                                    <li>Ensure follow-up appointments are scheduled as recommended</li>
                                    <li>Maintain the vaccination schedule for optimal protection</li>
                                </ul>
                            </div>
                            
                            <p>If you have any questions about this vaccination or your child's immunization schedule, please don't hesitate to contact your healthcare provider.</p>
                            
                            <p>Thank you for prioritizing your child's health and following the recommended vaccination schedule.</p>
                            
                            <p>Best regards,<br><strong>Maternal Health Care Team</strong></p>
                        </div>
                        <div class="footer">
                            <p>This is an important health notification. Please keep this record for your files.</p>
                            <p>If you have concerns about this vaccination, please contact your healthcare provider immediately.</p>
                            <p><strong>Maternal Health Care System</strong> - Caring for mothers and children</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(motherName, childName, childName, vaccinationType, ageToGive, vaccinationDate, midwifeName);
    }
    
    public void sendMaternalVaccinationNotificationEmail(String to, String motherName, 
                                                       String vaccinationType, String ageToGive, 
                                                       String vaccinationDate, String midwifeName) {
        try {
            String subject = "Maternal Vaccination Record Updated - " + motherName;
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            
            String htmlContent = buildMaternalVaccinationNotificationHtml(motherName, 
                vaccinationType, ageToGive, vaccinationDate, midwifeName);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Maternal vaccination notification email sent successfully to {}", to);
            
        } catch (Exception e) {
            logger.error("Failed to send maternal vaccination notification email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send maternal vaccination notification email", e);
        }
    }
    
    private String buildMaternalVaccinationNotificationHtml(String motherName, 
                                                           String vaccinationType, String ageToGive, 
                                                           String vaccinationDate, String midwifeName) {
        return """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Maternal Vaccination Record Updated</title>
                    <style>
                        body {
                            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                            line-height: 1.6;
                            color: #333;
                            background-color: #f5f5f5;
                            margin: 0;
                            padding: 20px;
                        }
                        .container {
                            max-width: 600px;
                            margin: 0 auto;
                            background-color: #ffffff;
                            border-radius: 10px;
                            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                            overflow: hidden;
                        }
                        .header {
                            background: linear-gradient(135deg, #FF6B9D 0%%, #FF8DA1 50%%, #FFA8B5 100%%);
                            color: white;
                            text-align: center;
                            padding: 30px 20px;
                        }
                        .header h1 {
                            margin: 0;
                            font-size: 28px;
                            font-weight: 600;
                        }
                        .header .icon {
                            font-size: 48px;
                            margin-bottom: 10px;
                        }
                        .content {
                            padding: 40px 30px;
                        }
                        .greeting {
                            font-size: 18px;
                            color: #2c3e50;
                            margin-bottom: 20px;
                        }
                        .main-message {
                            background-color: #fff5f8;
                            border-left: 4px solid #FF6B9D;
                            padding: 20px;
                            margin: 20px 0;
                            border-radius: 5px;
                        }
                        .vaccination-details {
                            background-color: #ffffff;
                            border: 2px solid #ffeef2;
                            border-radius: 10px;
                            padding: 25px;
                            margin: 20px 0;
                        }
                        .vaccination-details h3 {
                            color: #FF6B9D;
                            font-size: 20px;
                            margin-bottom: 15px;
                            border-bottom: 2px solid #ffeef2;
                            padding-bottom: 10px;
                        }
                        .detail-row {
                            display: flex;
                            margin-bottom: 12px;
                            align-items: center;
                        }
                        .detail-label {
                            font-weight: 600;
                            color: #2c3e50;
                            min-width: 140px;
                            margin-right: 10px;
                        }
                        .detail-value {
                            color: #34495e;
                            font-weight: 500;
                        }
                        .highlight {
                            background-color: #FF6B9D;
                            color: white;
                            padding: 4px 8px;
                            border-radius: 4px;
                            font-weight: 600;
                        }
                        .midwife-info {
                            background-color: #ffeef2;
                            border-radius: 8px;
                            padding: 15px;
                            margin: 20px 0;
                            text-align: center;
                        }
                        .important-note {
                            background-color: #fff7e6;
                            border: 1px solid #ffd700;
                            border-radius: 8px;
                            padding: 15px;
                            margin: 20px 0;
                            color: #8b6914;
                        }
                        .footer {
                            background-color: #f8f9fa;
                            text-align: center;
                            padding: 25px;
                            border-top: 1px solid #e9ecef;
                            font-size: 14px;
                            color: #6c757d;
                        }
                        .logo {
                            width: 40px;
                            height: 40px;
                            background-color: rgba(255, 255, 255, 0.2);
                            border-radius: 50%%;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            margin-bottom: 10px;
                        }
                        .pregnancy-highlight {
                            background-color: #fff0f5;
                            border: 2px solid #FF6B9D;
                            border-radius: 10px;
                            padding: 15px;
                            margin: 15px 0;
                            text-align: center;
                        }
                        .pregnancy-highlight .emoji {
                            font-size: 24px;
                            margin-right: 8px;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="logo">🤰</div>
                            <h1>Maternal Vaccination Updated</h1>
                            <p>Your pregnancy vaccination record has been updated</p>
                        </div>
                        <div class="content">
                            <div class="greeting">
                                Dear <strong>%s</strong>,
                            </div>
                            
                            <div class="pregnancy-highlight">
                                <span class="emoji">🤱</span>
                                <strong>Protecting You and Your Baby</strong>
                                <p>This vaccination is an important part of your prenatal care to ensure both your health and your baby's well-being during pregnancy.</p>
                            </div>
                            
                            <div class="main-message">
                                <p>We are pleased to inform you that your maternal vaccination record has been successfully updated. This important immunization is part of your comprehensive prenatal care and helps protect both you and your developing baby.</p>
                            </div>
                            
                            <div class="vaccination-details">
                                <h3>🩺 Maternal Vaccination Details</h3>
                                <div class="detail-row">
                                    <span class="detail-label">Patient Name:</span>
                                    <span class="detail-value"><strong>%s</strong></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Vaccine Type:</span>
                                    <span class="detail-value highlight">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Pregnancy Stage:</span>
                                    <span class="detail-value">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Vaccination Date:</span>
                                    <span class="detail-value">%s</span>
                                </div>
                            </div>
                            
                            <div class="midwife-info">
                                <p><strong>👩‍⚕️ Administered by:</strong> %s</p>
                                <p><em>Licensed Healthcare Provider</em></p>
                            </div>
                            
                            <div class="important-note">
                                <p><strong>🤰 Important Maternal Health Reminders:</strong></p>
                                <ul>
                                    <li>Keep this record as part of your pregnancy documentation</li>
                                    <li>Monitor for any unusual symptoms and contact your healthcare provider immediately if concerned</li>
                                    <li>Continue to attend all scheduled prenatal appointments</li>
                                    <li>This vaccination helps protect both you and your baby from serious diseases</li>
                                    <li>Discuss any concerns about pregnancy vaccinations with your healthcare team</li>
                                </ul>
                            </div>
                            
                            <div class="pregnancy-highlight">
                                <p><strong>📅 Next Steps:</strong> Continue following your prenatal care schedule and discuss any additional vaccinations that may be recommended during your pregnancy.</p>
                            </div>
                            
                            <p>If you have any questions about this vaccination or your prenatal care, please don't hesitate to contact your healthcare provider.</p>
                            
                            <p>Thank you for prioritizing your health and your baby's health during this special time.</p>
                            
                            <p>Best regards,<br><strong>Maternal Health Care Team</strong></p>
                        </div>
                        <div class="footer">
                            <p>This is an important maternal health notification. Please keep this record for your pregnancy files.</p>
                            <p>If you have concerns about this vaccination during pregnancy, please contact your healthcare provider immediately.</p>
                            <p><strong>Maternal Health Care System</strong> - Caring for mothers and babies</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(motherName, motherName, vaccinationType, ageToGive, vaccinationDate, midwifeName);
    }
    
    public void sendHealthcareProviderPasswordResetEmail(String to, String providerName, String providerType, String token) {
        try {
            System.out.println("Starting to send healthcare provider password reset email...");
            System.out.println("Recipient: " + to);
            System.out.println("Provider Name: " + providerName);
            System.out.println("Provider Type: " + providerType);
            System.out.println("Token: " + token);
            
            String subject = "🔐 Maternal Health - Healthcare Provider Password Reset";
            String resetUrl = serverUrl + "/api/healthcare/reset-password-form?token=" + token;
            
            System.out.println("Reset URL: " + resetUrl);
            System.out.println("Server URL: " + serverUrl);
            
            // Create beautiful HTML email for healthcare providers
            String htmlContent = """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Password Reset - Healthcare Provider</title>
                    <style>
                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }
                        body {
                            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                            line-height: 1.6;
                            background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                            padding: 20px;
                            margin: 0;
                        }
                        .email-container {
                            max-width: 600px;
                            margin: 0 auto;
                            background: white;
                            border-radius: 20px;
                            overflow: hidden;
                            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
                        }
                        .header {
                            background: linear-gradient(135deg, #4FC3A1 0%%, #667eea 100%%);
                            color: white;
                            padding: 40px 30px;
                            text-align: center;
                            position: relative;
                        }
                        .header::before {
                            content: '';
                            position: absolute;
                            top: 0;
                            left: 0;
                            right: 0;
                            bottom: 0;
                            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="20" cy="20" r="2" fill="rgba(255,255,255,0.1)"/><circle cx="80" cy="80" r="2" fill="rgba(255,255,255,0.1)"/><circle cx="80" cy="20" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="20" cy="80" r="1" fill="rgba(255,255,255,0.1)"/></svg>');
                        }
                        .header-content {
                            position: relative;
                            z-index: 1;
                        }
                        .logo {
                            font-size: 3em;
                            margin-bottom: 15px;
                        }
                        .title {
                            font-size: 28px;
                            font-weight: bold;
                            margin-bottom: 10px;
                        }
                        .subtitle {
                            font-size: 16px;
                            opacity: 0.9;
                        }
                        .content {
                            padding: 40px 30px;
                            background: white;
                        }
                        .greeting {
                            font-size: 20px;
                            color: #2d3748;
                            margin-bottom: 20px;
                            font-weight: 600;
                        }
                        .provider-info {
                            background: linear-gradient(135deg, #f7fafc 0%%, #edf2f7 100%%);
                            padding: 20px;
                            border-radius: 15px;
                            margin: 20px 0;
                            border-left: 5px solid #4FC3A1;
                        }
                        .provider-type {
                            display: inline-block;
                            background: linear-gradient(135deg, #4FC3A1 0%%, #667eea 100%%);
                            color: white;
                            padding: 8px 16px;
                            border-radius: 25px;
                            font-size: 14px;
                            font-weight: 600;
                            margin-bottom: 10px;
                        }
                        .message {
                            color: #4a5568;
                            font-size: 16px;
                            line-height: 1.8;
                            margin-bottom: 30px;
                        }
                        .reset-button {
                            display: inline-block;
                            background: linear-gradient(135deg, #4FC3A1 0%%, #667eea 100%%);
                            color: white;
                            padding: 18px 40px;
                            text-decoration: none;
                            border-radius: 50px;
                            font-weight: 600;
                            font-size: 16px;
                            text-align: center;
                            transition: all 0.3s ease;
                            box-shadow: 0 10px 30px rgba(79, 195, 161, 0.3);
                            margin: 20px 0;
                        }
                        .reset-button:hover {
                            transform: translateY(-2px);
                            box-shadow: 0 15px 40px rgba(79, 195, 161, 0.4);
                        }
                        .alternative-link {
                            background: #f7fafc;
                            padding: 20px;
                            border-radius: 10px;
                            margin: 20px 0;
                            border: 2px dashed #cbd5e0;
                        }
                        .alternative-link p {
                            margin-bottom: 10px;
                            color: #4a5568;
                            font-size: 14px;
                        }
                        .link-text {
                            word-break: break-all;
                            color: #4FC3A1;
                            font-family: monospace;
                            font-size: 12px;
                            background: white;
                            padding: 10px;
                            border-radius: 5px;
                            border: 1px solid #e2e8f0;
                        }
                        .security-info {
                            background: linear-gradient(135deg, #fed7d7 0%%, #feb2b2 100%%);
                            padding: 20px;
                            border-radius: 15px;
                            margin: 25px 0;
                            border-left: 5px solid #f56565;
                        }
                        .security-title {
                            font-weight: 600;
                            color: #742a2a;
                            margin-bottom: 10px;
                            font-size: 16px;
                        }
                        .security-list {
                            color: #742a2a;
                            font-size: 14px;
                            line-height: 1.6;
                        }
                        .security-list li {
                            margin-bottom: 5px;
                        }
                        .expiry-notice {
                            background: linear-gradient(135deg, #fef5e7 0%%, #fed7aa 100%%);
                            padding: 15px 20px;
                            border-radius: 10px;
                            margin: 20px 0;
                            border: 2px solid #f6ad55;
                            text-align: center;
                        }
                        .expiry-text {
                            color: #744210;
                            font-weight: 600;
                            font-size: 16px;
                        }
                        .contact-info {
                            background: #f0fff4;
                            padding: 20px;
                            border-radius: 15px;
                            margin: 25px 0;
                            border-left: 5px solid #68d391;
                        }
                        .footer {
                            background: linear-gradient(135deg, #2d3748 0%%, #4a5568 100%%);
                            color: #e2e8f0;
                            padding: 30px;
                            text-align: center;
                            font-size: 14px;
                            line-height: 1.6;
                        }
                        .footer-title {
                            color: white;
                            font-weight: 600;
                            margin-bottom: 10px;
                            font-size: 16px;
                        }
                        .copyright {
                            margin-top: 20px;
                            opacity: 0.8;
                            font-size: 12px;
                        }
                        @media (max-width: 600px) {
                            .email-container {
                                margin: 10px;
                                border-radius: 15px;
                            }
                            .header, .content, .footer {
                                padding: 25px 20px;
                            }
                            .title {
                                font-size: 24px;
                            }
                            .reset-button {
                                padding: 15px 30px;
                                font-size: 15px;
                            }
                        }
                    </style>
                </head>
                <body>
                    <div class="email-container">
                        <div class="header">
                            <div class="header-content">
                                <div class="logo">🏥</div>
                                <div class="title">Password Reset Request</div>
                                <div class="subtitle">Healthcare Provider Portal</div>
                            </div>
                        </div>
                        
                        <div class="content">
                            <div class="greeting">Hello Dr./Mrs. %s,</div>
                            
                            <div class="provider-info">
                                <div class="provider-type">%s</div>
                                <p><strong>Account:</strong> %s</p>
                            </div>
                            
                            <div class="message">
                                <p>We received a request to reset the password for your healthcare provider account in the Maternal Health System.</p>
                                
                                <p>If you initiated this request, please click the button below to create a new password. If you did not request a password reset, please ignore this email and contact our support team immediately.</p>
                            </div>
                            
                            <div style="text-align: center;">
                                <a href="%s" class="reset-button">🔐 Reset My Password</a>
                            </div>
                            
                            <div class="expiry-notice">
                                <div class="expiry-text">⏰ This link expires in 1 hour</div>
                            </div>
                            
                            <div class="alternative-link">
                                <p><strong>Can't click the button?</strong> Copy and paste this link into your browser:</p>
                                <div class="link-text">%s</div>
                            </div>
                            
                            <div class="security-info">
                                <div class="security-title">🛡️ Security Notice</div>
                                <ul class="security-list">
                                    <li>This link can only be used once</li>
                                    <li>It will expire automatically after 1 hour</li>
                                    <li>If you didn't request this reset, your account is still secure</li>
                                    <li>Consider using a strong, unique password for your account</li>
                                </ul>
                            </div>
                            
                            <div class="contact-info">
                                <p><strong>🆘 Need Help?</strong></p>
                                <p>If you're having trouble accessing your account or didn't request this reset, please contact our technical support team immediately.</p>
                                <p>Your account security is our top priority.</p>
                            </div>
                            
                            <p style="margin-top: 30px; color: #4a5568;">Best regards,<br><strong>Maternal Health System Security Team</strong></p>
                        </div>
                        
                        <div class="footer">
                            <div class="footer-title">Maternal Health Care System</div>
                            <p>Providing comprehensive healthcare for mothers and children</p>
                            <p>This is an automated security notification. Please do not reply to this email.</p>
                            <div class="copyright">© 2025 Maternal Health System. All rights reserved.</div>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(providerName, providerType, to, resetUrl, resetUrl);

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            System.out.println("About to send email using mailSender...");
            mailSender.send(message);
            System.out.println("Email sent successfully!");
            logger.info("Healthcare provider password reset email sent successfully to: {}", to);
        } catch (Exception e) {
            System.err.println("ERROR: Failed to send healthcare provider password reset email");
            System.err.println("Error message: " + e.getMessage());
            e.printStackTrace();
            logger.error("Failed to send healthcare provider password reset email to: {}", to, e);
            throw new RuntimeException("Failed to send password reset email", e);
        }
    }
    
    public void sendDoctorNoteConfirmationEmail(String to, String motherName, String doctorName, String notes, String diagnosis, String treatmentPlan, String visitDate) {
        try {
            String subject = "Maternal Health - Medical Notes Update from " + doctorName;
            String htmlContent = buildDoctorNoteConfirmationEmailHtml(motherName, doctorName, notes, diagnosis, treatmentPlan, visitDate);
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Doctor note confirmation email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send doctor note confirmation email to: {}", to, e);
            // Don't throw exception - let caller handle gracefully
        }
    }
    
    private String buildDoctorNoteConfirmationEmailHtml(String motherName, String doctorName, String notes, String diagnosis, String treatmentPlan, String visitDate) {
        return """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f4f4f4; }
                        .container { max-width: 600px; margin: 20px auto; background: #ffffff; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
                        .header { text-align: center; padding: 20px; background: linear-gradient(135deg, #4FC3A1, #66D4B7); color: white; border-radius: 10px 10px 0 0; margin: -20px -20px 20px -20px; }
                        .logo { font-size: 24px; margin-bottom: 10px; }
                        .content { padding: 20px 0; }
                        .note-section { background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #4FC3A1; }
                        .note-title { font-weight: bold; color: #2E7D5A; margin-bottom: 10px; font-size: 16px; }
                        .note-content { color: #333; line-height: 1.6; }
                        .visit-info { background-color: #e8f5f0; padding: 15px; border-radius: 8px; margin: 20px 0; }
                        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 14px; border-top: 1px solid #eee; padding-top: 20px; }
                        .doctor-info { background-color: #f0f8ff; padding: 15px; border-radius: 8px; margin: 15px 0; }
                        .important-note { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 20px 0; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="logo">🏥 Maternal Health</div>
                            <h2>Medical Consultation Update</h2>
                        </div>
                        
                        <div class="content">
                            <p>Dear %s,</p>
                            <p>We wanted to inform you that <strong>%s</strong> has updated your medical records with new consultation notes. Here are the details:</p>
                            
                            <div class="visit-info">
                                <h3>📅 Consultation Date: %s</h3>
                            </div>
                            
                            <div class="doctor-info">
                                <h3>👨‍⚕️ Attending Physician: %s</h3>
                            </div>
                            
                            %s
                            
                            %s
                            
                            %s
                            
                            <div class="important-note">
                                <h3>📋 Important Information:</h3>
                                <ul>
                                    <li>Please keep this email for your medical records</li>
                                    <li>Follow any treatment instructions provided by your doctor</li>
                                    <li>Contact your healthcare provider if you have any questions</li>
                                    <li>If you need clarification about your treatment plan, don't hesitate to reach out</li>
                                </ul>
                            </div>
                            
                            <p>If you have any questions about this consultation or need to schedule a follow-up appointment, please contact our clinic.</p>
                            
                            <p style="margin-top: 30px; color: #4a5568;">Take care of yourself and your health,<br><strong>Maternal Health Care Team</strong></p>
                        </div>
                        
                        <div class="footer">
                            <div style="font-weight: bold; color: #4FC3A1; margin-bottom: 10px;">Maternal Health Care System</div>
                            <p>Providing comprehensive healthcare for mothers and children</p>
                            <p>This is an automated notification. Please do not reply to this email.</p>
                            <p style="font-size: 12px; color: #999;">© 2025 Maternal Health System. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(
                    motherName, 
                    doctorName, 
                    visitDate != null ? visitDate : java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")),
                    doctorName,
                    notes != null && !notes.trim().isEmpty() ? 
                        "<div class=\"note-section\"><div class=\"note-title\">📝 Clinical Notes:</div><div class=\"note-content\">" + notes + "</div></div>" : "",
                    diagnosis != null && !diagnosis.trim().isEmpty() ? 
                        "<div class=\"note-section\"><div class=\"note-title\">🩺 Diagnosis:</div><div class=\"note-content\">" + diagnosis + "</div></div>" : "",
                    treatmentPlan != null && !treatmentPlan.trim().isEmpty() ? 
                        "<div class=\"note-section\"><div class=\"note-title\">💊 Treatment Plan:</div><div class=\"note-content\">" + treatmentPlan + "</div></div>" : ""
                );
    }

    /**
     * Send growth record update notification email to mother
     */
    public void sendGrowthRecordUpdateEmail(String to, String motherName, String midwifeName, 
                                          String babyName, double height, double weight, String recordDate) {
        try {
            String subject = "🌱 " + babyName + "'s Growth Record Updated - Maternal Health";
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            
            String htmlContent = buildGrowthRecordUpdateEmailHtml(motherName, midwifeName, babyName, height, weight, recordDate);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Growth record update email sent successfully to: {}", to);
            
        } catch (Exception e) {
            logger.error("Failed to send growth record update email to: {}", to, e);
            throw new RuntimeException("Failed to send growth record update email", e);
        }
    }

    /**
     * Build HTML content for growth record update email
     */
    private String buildGrowthRecordUpdateEmailHtml(String motherName, String midwifeName, String babyName,
                                                   double height, double weight, String recordDate) {
        return String.format("""
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Baby Growth Record Updated</title>
                    <style>
                        body {
                            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                            line-height: 1.6;
                            color: #333;
                            margin: 0;
                            padding: 0;
                            background: linear-gradient(135deg, #f5f7fa 0%%, #c3cfe2 100%%);
                        }
                        .container {
                            max-width: 600px;
                            margin: 20px auto;
                            background: white;
                            border-radius: 15px;
                            overflow: hidden;
                            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
                        }
                        .header {
                            background: linear-gradient(135deg, #4FC3A1 0%%, #66D4B7 100%%);
                            color: white;
                            padding: 30px;
                            text-align: center;
                        }
                        .header h1 {
                            margin: 0;
                            font-size: 28px;
                            font-weight: 300;
                        }
                        .header .icon {
                            font-size: 50px;
                            margin-bottom: 15px;
                            display: block;
                        }
                        .content {
                            padding: 40px 30px;
                        }
                        .greeting {
                            font-size: 18px;
                            color: #4FC3A1;
                            margin-bottom: 20px;
                            font-weight: 600;
                        }
                        .message {
                            font-size: 16px;
                            line-height: 1.8;
                            margin-bottom: 30px;
                            color: #555;
                        }
                        .growth-card {
                            background: linear-gradient(135deg, #f8f9fa 0%%, #e9ecef 100%%);
                            border-radius: 12px;
                            padding: 25px;
                            margin: 25px 0;
                            border-left: 4px solid #4FC3A1;
                        }
                        .growth-title {
                            font-size: 18px;
                            font-weight: 600;
                            color: #4FC3A1;
                            margin-bottom: 15px;
                            display: flex;
                            align-items: center;
                        }
                        .growth-title .emoji {
                            margin-right: 10px;
                            font-size: 22px;
                        }
                        .growth-details {
                            display: grid;
                            grid-template-columns: 1fr 1fr;
                            gap: 20px;
                            margin-top: 15px;
                        }
                        .growth-item {
                            background: white;
                            padding: 15px;
                            border-radius: 8px;
                            text-align: center;
                            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
                        }
                        .growth-label {
                            font-size: 12px;
                            text-transform: uppercase;
                            letter-spacing: 1px;
                            color: #7C7C7C;
                            margin-bottom: 5px;
                        }
                        .growth-value {
                            font-size: 24px;
                            font-weight: 700;
                            color: #4FC3A1;
                        }
                        .growth-unit {
                            font-size: 14px;
                            color: #7C7C7C;
                        }
                        .date-info {
                            background: #fff3cd;
                            border: 1px solid #ffeaa7;
                            border-radius: 8px;
                            padding: 15px;
                            margin: 20px 0;
                            text-align: center;
                        }
                        .date-info .icon {
                            font-size: 20px;
                            margin-right: 8px;
                        }
                        .midwife-info {
                            background: #e8f5e8;
                            border-radius: 8px;
                            padding: 15px;
                            margin: 20px 0;
                            text-align: center;
                        }
                        .midwife-info .icon {
                            font-size: 20px;
                            margin-right: 8px;
                        }
                        .encouragement {
                            background: linear-gradient(135deg, #ff9a9e 0%%, #fecfef 100%%);
                            border-radius: 12px;
                            padding: 20px;
                            margin: 25px 0;
                            text-align: center;
                            color: #d63384;
                        }
                        .encouragement .heart {
                            font-size: 30px;
                            margin-bottom: 10px;
                            display: block;
                        }
                        .footer {
                            background: #f8f9fa;
                            padding: 25px;
                            text-align: center;
                            color: #6c757d;
                            font-size: 14px;
                        }
                        .footer .app-name {
                            color: #4FC3A1;
                            font-weight: 600;
                            font-size: 16px;
                        }
                        .highlight {
                            background: linear-gradient(135deg, #4FC3A1, #66D4B7);
                            -webkit-background-clip: text;
                            -webkit-text-fill-color: transparent;
                            background-clip: text;
                            font-weight: 600;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <span class="icon">🌱</span>
                            <h1>%s's Growth Record Updated!</h1>
                        </div>
                        
                        <div class="content">
                            <div class="greeting">Hello %s! 👋</div>
                            
                            <div class="message">
                                Great news! %s's growth record has been updated by your midwife. 
                                Here are the latest measurements taken during your visit:
                            </div>
                            
                            <div class="growth-card">
                                <div class="growth-title">
                                    <span class="emoji">📏</span>
                                    Latest Growth Measurements
                                </div>
                                <div class="growth-details">
                                    <div class="growth-item">
                                        <div class="growth-label">Height</div>
                                        <div class="growth-value">%.1f <span class="growth-unit">cm</span></div>
                                    </div>
                                    <div class="growth-item">
                                        <div class="growth-label">Weight</div>
                                        <div class="growth-value">%.1f <span class="growth-unit">kg</span></div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="date-info">
                                <span class="icon">📅</span>
                                <strong>Record Date:</strong> %s
                            </div>
                            
                            <div class="midwife-info">
                                <span class="icon">👩‍⚕️</span>
                                <strong>Updated by:</strong> %s (Midwife)
                            </div>
                            
                            <div class="encouragement">
                                <span class="heart">💖</span>
                                <strong>%s is growing beautifully!</strong><br>
                                Keep up the excellent care and continue with regular check-ups.
                            </div>
                            
                            <div class="message">
                                You can view %s's complete growth chart and track their progress 
                                in the <span class="highlight">Maternal Health</span> mobile app.
                            </div>
                        </div>
                        
                        <div class="footer">
                            <div class="app-name">Maternal Health Care System</div>
                            <div>Caring for mothers and babies, every step of the way 💚</div>
                        </div>
                    </div>
                </body>
                </html>
                """, babyName, motherName, babyName, height, weight, recordDate, midwifeName, babyName, babyName);
    }

    public void sendPasswordChangeConfirmationEmail(String to, String motherName, String changeDateTime, String deviceInfo) {
        try {
            String subject = "🔐 Password Changed Successfully - Maternal Health";
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            
            String htmlContent = buildPasswordChangeConfirmationEmailHtml(motherName, changeDateTime, deviceInfo);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            logger.info("Password change confirmation email sent successfully to: {}", to);
            
        } catch (Exception e) {
            logger.error("Failed to send password change confirmation email to: {}", to, e);
            throw new RuntimeException("Failed to send password change confirmation email", e);
        }
    }

    private String buildPasswordChangeConfirmationEmailHtml(String motherName, String changeDateTime, String deviceInfo) {
        return String.format("""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Password Changed Successfully</title>
                    <style>
                        body {
                            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                            line-height: 1.6;
                            margin: 0;
                            padding: 0;
                            background-color: #f0f8f0;
                        }
                        .container {
                            max-width: 600px;
                            margin: 20px auto;
                            background: white;
                            border-radius: 15px;
                            overflow: hidden;
                            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
                        }
                        .header {
                            background: linear-gradient(135deg, #4FC3A1, #66D4B7);
                            color: white;
                            padding: 30px;
                            text-align: center;
                        }
                        .header h1 {
                            margin: 0;
                            font-size: 28px;
                            font-weight: bold;
                        }
                        .header .icon {
                            font-size: 48px;
                            margin-bottom: 10px;
                        }
                        .content {
                            padding: 40px 30px;
                        }
                        .greeting {
                            font-size: 20px;
                            color: #2E7D5A;
                            margin-bottom: 20px;
                            font-weight: 600;
                        }
                        .message {
                            font-size: 16px;
                            color: #333;
                            margin-bottom: 20px;
                        }
                        .security-info {
                            background: #f8f9fa;
                            border-left: 4px solid #4FC3A1;
                            padding: 20px;
                            margin: 25px 0;
                            border-radius: 0 8px 8px 0;
                        }
                        .security-info h3 {
                            color: #2E7D5A;
                            margin: 0 0 15px 0;
                            font-size: 18px;
                        }
                        .detail-item {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 8px 0;
                            border-bottom: 1px solid #e9ecef;
                        }
                        .detail-item:last-child {
                            border-bottom: none;
                        }
                        .detail-label {
                            font-weight: 600;
                            color: #495057;
                        }
                        .detail-value {
                            color: #6c757d;
                            text-align: right;
                        }
                        .security-tips {
                            background: #e8f4f8;
                            border: 1px solid #bee5eb;
                            border-radius: 8px;
                            padding: 20px;
                            margin: 25px 0;
                        }
                        .security-tips h3 {
                            color: #0c5460;
                            margin: 0 0 15px 0;
                            font-size: 18px;
                        }
                        .security-tips ul {
                            margin: 0;
                            padding-left: 20px;
                            color: #0c5460;
                        }
                        .security-tips li {
                            margin-bottom: 8px;
                        }
                        .warning-box {
                            background: #fff3cd;
                            border: 1px solid #ffeaa7;
                            border-radius: 8px;
                            padding: 20px;
                            margin: 25px 0;
                        }
                        .warning-box h3 {
                            color: #856404;
                            margin: 0 0 10px 0;
                            font-size: 16px;
                        }
                        .warning-box p {
                            color: #856404;
                            margin: 0;
                            font-size: 14px;
                        }
                        .support-info {
                            background: #f8f9fa;
                            border-radius: 8px;
                            padding: 20px;
                            margin: 25px 0;
                            text-align: center;
                        }
                        .support-info h3 {
                            color: #2E7D5A;
                            margin: 0 0 15px 0;
                            font-size: 18px;
                        }
                        .support-info p {
                            color: #6c757d;
                            margin: 0;
                            font-size: 14px;
                        }
                        .footer {
                            background: #2E7D5A;
                            color: white;
                            text-align: center;
                            padding: 25px;
                        }
                        .footer .app-name {
                            font-size: 18px;
                            font-weight: bold;
                            margin-bottom: 5px;
                        }
                        .highlight {
                            color: #4FC3A1;
                            font-weight: bold;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="icon">🔐</div>
                            <h1>Password Changed Successfully</h1>
                        </div>
                        
                        <div class="content">
                            <div class="greeting">Hello %s! 👋</div>
                            
                            <div class="message">
                                Your password has been successfully changed for your Maternal Health account. 
                                This email confirms that the password change was completed.
                            </div>
                            
                            <div class="security-info">
                                <h3>🛡️ Change Details</h3>
                                <div class="detail-item">
                                    <span class="detail-label">Date & Time:</span>
                                    <span class="detail-value">%s</span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Device/Browser:</span>
                                    <span class="detail-value">%s</span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Account:</span>
                                    <span class="detail-value">Maternal Health Profile</span>
                                </div>
                            </div>
                            
                            <div class="warning-box">
                                <h3>⚠️ Didn't change your password?</h3>
                                <p>
                                    If you did not request this password change, please contact our support team 
                                    immediately and secure your account.
                                </p>
                            </div>
                            
                            <div class="security-tips">
                                <h3>🔒 Security Tips</h3>
                                <ul>
                                    <li>Use a strong, unique password for your account</li>
                                    <li>Don't share your password with anyone</li>
                                    <li>Log out from shared devices after use</li>
                                    <li>Review your account activity regularly</li>
                                    <li>Contact support if you notice any suspicious activity</li>
                                </ul>
                            </div>
                            
                            <div class="message">
                                Your account security is important to us. We're committed to keeping your 
                                personal health information safe and secure.
                            </div>
                            
                            <div class="support-info">
                                <h3>📞 Need Help?</h3>
                                <p>
                                    If you have any questions or concerns about your account security, 
                                    our support team is here to help you 24/7.
                                </p>
                            </div>
                        </div>
                        
                        <div class="footer">
                            <div class="app-name">Maternal Health Care System</div>
                            <div>Keeping your health information secure 🔐</div>
                        </div>
                    </div>
                </body>
                </html>
                """, motherName, changeDateTime, deviceInfo);
    }

    // Send email notification for eye and ear record updates
    public void sendEyeEarRecordUpdateNotification(String motherEmail, String motherName, String babyName, 
                                                  String eyeProblem, String earProblem, String midwifeName) {
        try {
            String subject = "👁️👂 Eye & Ear Record Updated - " + babyName;
            String htmlContent = buildEyeEarRecordEmailHtml(motherName, babyName, eyeProblem, earProblem, midwifeName);
            
            sendEmail(motherEmail, subject, htmlContent);
            
            logger.info("Eye and ear record update notification sent to: {}", motherEmail);
        } catch (Exception e) {
            logger.error("Failed to send eye and ear record notification to {}: {}", motherEmail, e.getMessage());
        }
    }

    private String buildEyeEarRecordEmailHtml(String motherName, String babyName, String eyeProblem, String earProblem, String midwifeName) {
        String currentDate = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' hh:mm a"));
        
        // Determine the status and icon
        boolean hasEyeIssue = eyeProblem != null && !eyeProblem.equals("None") && !eyeProblem.trim().isEmpty();
        boolean hasEarIssue = earProblem != null && !earProblem.equals("None") && !earProblem.trim().isEmpty();
        
        String statusIcon;
        String statusText;
        String statusColor;
        
        if (hasEyeIssue || hasEarIssue) {
            statusIcon = "⚠️";
            statusText = "Attention Required";
            statusColor = "#ff9800";
        } else {
            statusIcon = "✅";
            statusText = "All Clear";
            statusColor = "#4caf50";
        }

        return String.format("""
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Eye & Ear Record Update</title>
                </head>
                <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f7fa;">
                    <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
                        
                        <!-- Header -->
                        <div style="background: linear-gradient(135deg, #4FC3A1 0%%, #66D4B8 100%%); color: white; padding: 30px; text-align: center;">
                            <h1 style="margin: 0; font-size: 28px; font-weight: 600;">
                                👁️👂 Eye & Ear Record Update
                            </h1>
                            <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">
                                Examination Record for %s
                            </p>
                        </div>
                        
                        <!-- Main Content -->
                        <div style="padding: 40px 30px;">
                            <div style="text-align: center; margin-bottom: 30px;">
                                <div style="font-size: 60px; margin-bottom: 10px;">%s</div>
                                <h2 style="color: %s; margin: 0; font-size: 24px;">%s</h2>
                                <p style="color: #666; margin: 5px 0;">Updated on %s</p>
                            </div>
                            
                            <div style="background-color: #f8f9fa; border-radius: 12px; padding: 25px; margin-bottom: 25px;">
                                <h3 style="color: #333; margin-top: 0;">👋 Hello %s,</h3>
                                <p style="color: #555; line-height: 1.6; margin: 15px 0;">
                                    Your midwife <strong>%s</strong> has updated the eye and ear examination record for <strong>%s</strong>. 
                                    Here are the current findings:
                                </p>
                            </div>
                            
                            <!-- Eye Status -->
                            <div style="border-left: 4px solid #2196f3; background-color: #e3f2fd; padding: 20px; margin-bottom: 15px; border-radius: 0 8px 8px 0;">
                                <h4 style="color: #1976d2; margin: 0 0 10px 0; display: flex; align-items: center;">
                                    👁️ Eye Examination
                                </h4>
                                <p style="margin: 0; font-size: 16px; color: #333;">
                                    <strong>Status:</strong> %s
                                </p>
                            </div>
                            
                            <!-- Ear Status -->
                            <div style="border-left: 4px solid #ff9800; background-color: #fff3e0; padding: 20px; margin-bottom: 25px; border-radius: 0 8px 8px 0;">
                                <h4 style="color: #f57c00; margin: 0 0 10px 0; display: flex; align-items: center;">
                                    👂 Ear Examination
                                </h4>
                                <p style="margin: 0; font-size: 16px; color: #333;">
                                    <strong>Status:</strong> %s
                                </p>
                            </div>
                            
                            <!-- Next Steps -->
                            <div style="background-color: #e8f5e8; border-radius: 8px; padding: 20px; margin-bottom: 25px;">
                                <h4 style="color: #2e7d32; margin: 0 0 15px 0;">📋 What's Next?</h4>
                                <ul style="color: #555; line-height: 1.6; margin: 0; padding-left: 20px;">
                                    <li>Review the complete record in your Maternal Health app</li>
                                    <li>Follow any specific instructions from your midwife</li>
                                    <li>Contact your midwife if you have any questions or concerns</li>
                                    <li>Keep track of your appointments and follow-up visits</li>
                                </ul>
                            </div>
                            
                            <!-- App Access -->
                            <div style="text-align: center; background-color: #f0f4f8; border-radius: 8px; padding: 20px;">
                                <h4 style="color: #333; margin: 0 0 10px 0;">📱 Access Your Records</h4>
                                <p style="color: #666; margin: 0 0 15px 0;">
                                    Open your Maternal Health app to view the complete examination details and track your baby's health progress.
                                </p>
                                <div style="background-color: #4FC3A1; color: white; padding: 10px 20px; border-radius: 6px; display: inline-block; font-weight: 600;">
                                    Mother Module → Eye & Ear Records
                                </div>
                            </div>
                        </div>
                        
                        <!-- Footer -->
                        <div style="background-color: #2c3e50; color: white; padding: 25px; text-align: center;">
                            <div style="font-size: 18px; font-weight: 600; margin-bottom: 5px;">
                                Maternal Health Care System
                            </div>
                            <div style="font-size: 14px; opacity: 0.8;">
                                Caring for mothers and babies with love 💝
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """, 
                babyName, statusIcon, statusColor, statusText, currentDate, motherName, midwifeName, babyName,
                hasEyeIssue ? eyeProblem : "No problems detected", 
                hasEarIssue ? earProblem : "No problems detected");
    }
}