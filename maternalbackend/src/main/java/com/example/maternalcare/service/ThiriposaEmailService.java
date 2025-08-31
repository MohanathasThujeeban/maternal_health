package com.example.maternalcare.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.ThiriposaRecord;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.format.DateTimeFormatter;
import java.util.logging.Logger;
import java.util.logging.Level;

@Service
public class ThiriposaEmailService {

    private static final Logger logger = Logger.getLogger(ThiriposaEmailService.class.getName());
    
    @Autowired
    private JavaMailSender mailSender;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("MMMM dd, yyyy");

    public void sendThiriposaConfirmationEmail(Registration mother, ThiriposaRecord record, String midwifeName) {
        try {
            logger.info("Preparing to send Thiriposa confirmation email to: " + mother.getEmail());
            
            // Debug image availability
            debugImageAvailability();
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());

            // Set email properties
            helper.setFrom("thujeeforearn@gmail.com", "Maternal Health Care System");
            helper.setTo(mother.getEmail());
            helper.setSubject("🌟 Thiriposa Record Confirmation - " + mother.getFullName());

            // Load and customize HTML template
            String htmlContent = loadAndCustomizeTemplate(mother, record, midwifeName);
            helper.setText(htmlContent, true);

            // Attach images as inline resources
            logger.info("Attaching inline images for email to: " + mother.getEmail());
            attachInlineImages(helper);

            // Send the email
            mailSender.send(message);
            logger.info("Thiriposa confirmation email sent successfully to: " + mother.getEmail());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to send Thiriposa confirmation email to: " + mother.getEmail() + ". Error: " + e.getMessage(), e);
            // Don't throw exception - log error and continue
            // This prevents email failures from breaking the core functionality
        }
    }

    private String loadAndCustomizeTemplate(Registration mother, ThiriposaRecord record, String midwifeName) 
            throws IOException {
        
        String template;
        
        try {
            // In development, try loading from file system first for live updates
            String templatePath = "src/main/resources/templates/thiriposa-confirmation-email.html";
            java.io.File templateFile = new java.io.File(templatePath);
            
            if (templateFile.exists()) {
                template = Files.readString(templateFile.toPath(), StandardCharsets.UTF_8);
                logger.info("Template loaded from file system (development mode) - changes will be reflected immediately");
            } else {
                // Fallback to classpath for production
                ClassPathResource templateResource = new ClassPathResource("templates/thiriposa-confirmation-email.html");
                if (templateResource.exists()) {
                    template = Files.readString(Paths.get(templateResource.getURI()), StandardCharsets.UTF_8);
                    logger.info("Template loaded from classpath (production mode)");
                } else {
                    throw new IOException("Template not found in both file system and classpath");
                }
            }
        } catch (Exception e) {
            logger.warning("Failed to load template: " + e.getMessage());
            throw new IOException("Cannot load email template", e);
        }

        // Format dates and times
        String supplyDate = record.getDate().format(DATE_FORMATTER);
        String recordTime = record.getCreatedAt().format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' hh:mm a"));

        // Replace template placeholders with actual data
        String customizedContent = template
                .replace("{{motherName}}", mother.getFullName())
                .replace("{{supplyDate}}", supplyDate)
                .replace("{{quantity}}", String.valueOf(record.getQuantity()))
                .replace("{{midwifeName}}", midwifeName != null ? midwifeName : "Healthcare Provider")
                .replace("{{recordTime}}", recordTime);

        // Handle optional notes (if you plan to add notes field later)
        if (customizedContent.contains("{{#notes}}")) {
            // For now, remove the notes section as it's not in the current model
            customizedContent = customizedContent.replaceAll("\\{\\{#notes\\}\\}.*?\\{\\{/notes\\}\\}", "");
        }

        logger.info("Template customized for mother: " + mother.getFullName());
        return customizedContent;
    }

    private void attachInlineImages(MimeMessageHelper helper) throws MessagingException, IOException {
        try {
            // Attach logo image
            ClassPathResource logoResource = new ClassPathResource("static/images/logo.png");
            if (logoResource.exists()) {
                helper.addInline("logo", logoResource, "image/png");
                logger.info("Logo image attached successfully (size: " + logoResource.contentLength() + " bytes)");
            } else {
                logger.warning("Logo image not found at: static/images/logo.png");
                // Try fallback path
                ClassPathResource fallbackLogo = new ClassPathResource("images/logo.png");
                if (fallbackLogo.exists()) {
                    helper.addInline("logo", fallbackLogo, "image/png");
                    logger.info("Logo image attached from fallback path: images/logo.png (size: " + fallbackLogo.contentLength() + " bytes)");
                } else {
                    logger.warning("Logo image not found in fallback path either");
                }
            }

            // Attach thiriposa image
            ClassPathResource thiriposaResource = new ClassPathResource("static/images/thiriposha.png");
            if (thiriposaResource.exists()) {
                helper.addInline("thiriposa", thiriposaResource, "image/png");
                logger.info("Thiriposa image attached successfully (size: " + thiriposaResource.contentLength() + " bytes)");
            } else {
                logger.warning("Thiriposa image not found at: static/images/thiriposha.png");
                // Try fallback path
                ClassPathResource fallbackThiriposa = new ClassPathResource("images/thiriposha.png");
                if (fallbackThiriposa.exists()) {
                    helper.addInline("thiriposa", fallbackThiriposa, "image/png");
                    logger.info("Thiriposa image attached from fallback path: images/thiriposha.png (size: " + fallbackThiriposa.contentLength() + " bytes)");
                } else {
                    logger.warning("Thiriposa image not found in fallback path either");
                }
            }

        } catch (Exception e) {
            logger.log(Level.WARNING, "Failed to attach one or more inline images: " + e.getMessage(), e);
            // Continue without images rather than failing completely
        }
    }

    // Method to validate email configuration
    public boolean isEmailConfigurationValid() {
        try {
            mailSender.createMimeMessage();
            logger.info("Email configuration appears to be valid");
            return true;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Email configuration is invalid", e);
            return false;
        }
    }

    // Method to send test email (useful for debugging)
    public void sendTestEmail(String toEmail) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());

            helper.setFrom("thujeeforearn@gmail.com", "Maternal Health Care System");
            helper.setTo(toEmail);
            helper.setSubject("Test Email - Maternal Health Care System");
            helper.setText("<h2>Email Configuration Test</h2><p>If you receive this email, the email configuration is working correctly.</p>", true);

            mailSender.send(message);
            logger.info("Test email sent successfully to: " + toEmail);

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to send test email to: " + toEmail, e);
            throw new RuntimeException("Test email failed: " + e.getMessage(), e);
        }
    }

    // Method to debug image availability
    public void debugImageAvailability() {
        logger.info("=== IMAGE AVAILABILITY DEBUG ===");
        
        // Check logo
        ClassPathResource logoResource = new ClassPathResource("static/images/logo.png");
        try {
            if (logoResource.exists()) {
                logger.info("✅ Logo found at: static/images/logo.png (size: " + logoResource.contentLength() + " bytes)");
            } else {
                logger.warning("❌ Logo NOT found at: static/images/logo.png");
            }
        } catch (Exception e) {
            logger.warning("❌ Error checking logo: " + e.getMessage());
        }
        
        // Check thiriposa
        ClassPathResource thiriposaResource = new ClassPathResource("static/images/thiriposha.png");
        try {
            if (thiriposaResource.exists()) {
                logger.info("✅ Thiriposa found at: static/images/thiriposha.png (size: " + thiriposaResource.contentLength() + " bytes)");
            } else {
                logger.warning("❌ Thiriposa NOT found at: static/images/thiriposha.png");
            }
        } catch (Exception e) {
            logger.warning("❌ Error checking thiriposa: " + e.getMessage());
        }
        
        // Check fallback paths
        ClassPathResource fallbackLogo = new ClassPathResource("images/logo.png");
        try {
            if (fallbackLogo.exists()) {
                logger.info("✅ Logo fallback found at: images/logo.png (size: " + fallbackLogo.contentLength() + " bytes)");
            } else {
                logger.info("ℹ️ Logo fallback NOT found at: images/logo.png");
            }
        } catch (Exception e) {
            logger.warning("❌ Error checking logo fallback: " + e.getMessage());
        }
        
        ClassPathResource fallbackThiriposa = new ClassPathResource("images/thiriposha.png");
        try {
            if (fallbackThiriposa.exists()) {
                logger.info("✅ Thiriposa fallback found at: images/thiriposha.png (size: " + fallbackThiriposa.contentLength() + " bytes)");
            } else {
                logger.info("ℹ️ Thiriposa fallback NOT found at: images/thiriposha.png");
            }
        } catch (Exception e) {
            logger.warning("❌ Error checking thiriposa fallback: " + e.getMessage());
        }
        
        logger.info("=== END IMAGE DEBUG ===");
    }
}
