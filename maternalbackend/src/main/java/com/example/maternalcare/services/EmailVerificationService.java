package com.example.maternalcare.services;

import com.example.maternalcare.model.EmailVerificationToken;
import com.example.maternalcare.repository.EmailVerificationTokenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class EmailVerificationService {
    
    @Autowired
    private EmailVerificationTokenRepository tokenRepository;
    
    @Autowired
    private EmailService emailService;
    
    @Value("${app.server.url:http://localhost:8080}")
    private String serverUrl;
    
    public boolean sendVerificationEmail(String email) {
        try {
            // Delete any existing tokens for this email
            tokenRepository.deleteByEmail(email);
            
            // Generate new verification token
            String token = UUID.randomUUID().toString();
            
            // Create and save verification token
            EmailVerificationToken verificationToken = new EmailVerificationToken(token, email);
            tokenRepository.save(verificationToken);
            
            // Send verification email - Use configurable server URL for cross-device access
            String verificationUrl = serverUrl + "/api/registration/verify?token=" + token;
            
            String subject = "Verify Your Email - Maternal Health App";
            String body = buildVerificationEmailBody(verificationUrl);
            
            emailService.sendEmail(email, subject, body);
            
            return true;
        } catch (Exception e) {
            System.err.println("Error sending verification email: " + e.getMessage());
            return false;
        }
    }
    
    public boolean verifyEmail(String token) {
        try {
            Optional<EmailVerificationToken> tokenOpt = tokenRepository.findByToken(token);
            
            if (tokenOpt.isEmpty()) {
                return false;
            }
            
            EmailVerificationToken verificationToken = tokenOpt.get();
            
            // Check if token is expired
            if (verificationToken.isExpired()) {
                tokenRepository.delete(verificationToken);
                return false;
            }
            
            // Mark as verified
            verificationToken.setVerified(true);
            tokenRepository.save(verificationToken);
            
            return true;
        } catch (Exception e) {
            System.err.println("Error verifying email: " + e.getMessage());
            return false;
        }
    }
    
    public boolean isEmailVerified(String email) {
        return tokenRepository.existsByEmailAndVerified(email, true);
    }
    
    public Optional<EmailVerificationToken> getVerificationToken(String token) {
        return tokenRepository.findByToken(token);
    }
    
    public void cleanupExpiredTokens() {
        tokenRepository.deleteExpiredTokens(LocalDateTime.now());
    }
    
    private String buildVerificationEmailBody(String verificationUrl) {
        return """
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
                        .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                        .header { text-align: center; margin-bottom: 30px; }
                        .logo { font-size: 24px; font-weight: bold; color: #4FC3A1; margin-bottom: 10px; }
                        .title { font-size: 20px; color: #333; margin-bottom: 20px; }
                        .message { font-size: 16px; line-height: 1.6; color: #666; margin-bottom: 30px; }
                        .button { display: inline-block; background-color: #4FC3A1; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; margin: 20px 0; }
                        .button:hover { background-color: #3ea188; }
                        .footer { font-size: 14px; color: #999; text-align: center; margin-top: 30px; border-top: 1px solid #eee; padding-top: 20px; }
                        .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; color: #856404; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <div class="logo">🤱 Maternal Health App</div>
                            <h2 class="title">Verify Your Email Address</h2>
                        </div>
                        
                        <div class="message">
                            <p>Thank you for registering with the Maternal Health App!</p>
                            <p>To complete your registration and ensure the security of your account, please verify your email address by clicking the button below:</p>
                        </div>
                        
                        <div style="text-align: center;">
                            <a href="%s" class="button">Verify Email Address</a>
                        </div>
                        
                        <div class="warning">
                            <strong>Important:</strong> This verification link will expire in 24 hours for security reasons.
                        </div>
                        
                        <div class="message">
                            <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
                            <p style="word-break: break-all; background-color: #f8f9fa; padding: 10px; border-radius: 5px; font-family: monospace;">%s</p>
                        </div>
                        
                        <div class="footer">
                            <p>If you didn't create an account with Maternal Health App, please ignore this email.</p>
                            <p>This is an automated message, please do not reply to this email.</p>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(verificationUrl, verificationUrl);
    }
}
