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
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("hh:mm a");

    public void sendThiriposaConfirmationEmail(Registration mother, ThiriposaRecord record, String midwifeName) {
        try {
            logger.info("Preparing to send Thiriposa confirmation email to: " + mother.getEmail());
            
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
            attachInlineImages(helper);

            // Send the email
            mailSender.send(message);
            logger.info("Thiriposa confirmation email sent successfully to: " + mother.getEmail());

        } catch (Exception e) {
            logger.log(Level.WARNING, "Failed to send Thiriposa confirmation email to: " + mother.getEmail() + ". Error: " + e.getMessage());
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
                helper.addInline("logo", logoResource);
                logger.info("Logo image attached successfully");
            } else {
                logger.warning("Logo image not found at: static/images/logo.png");
            }

            // Attach thiriposa image
            ClassPathResource thiriposaResource = new ClassPathResource("static/images/thiriposha.png");
            if (thiriposaResource.exists()) {
                helper.addInline("thiriposa", thiriposaResource);
                logger.info("Thiriposa image attached successfully");
            } else {
                logger.warning("Thiriposa image not found at: static/images/thiriposha.png");
            }

        } catch (Exception e) {
            logger.log(Level.WARNING, "Failed to attach one or more inline images", e);
            // Continue without images rather than failing completely
        }
    }

    // Method to validate email configuration
    public boolean isEmailConfigurationValid() {
        try {
            MimeMessage testMessage = mailSender.createMimeMessage();
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
}
