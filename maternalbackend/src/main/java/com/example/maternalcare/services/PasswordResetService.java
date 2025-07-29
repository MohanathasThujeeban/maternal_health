package com.example.maternalcare.services;

import com.example.maternalcare.model.PasswordResetToken;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.PasswordResetTokenRepository;
import com.example.maternalcare.repository.RegistrationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class PasswordResetService {
    
    @Autowired
    private PasswordResetTokenRepository tokenRepository;
    
    @Autowired
    private RegistrationRepository registrationRepository;
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Transactional
    public boolean initiatePasswordReset(String email) {
        Optional<Registration> userOpt = registrationRepository.findByEmail(email);
        
        if (userOpt.isEmpty()) {
            return false; // User not found
        }
        
        Registration user = userOpt.get();
        
        // Delete any existing tokens for this user
        tokenRepository.deleteByUser(user);
        
        // Generate new token
        String token = UUID.randomUUID().toString();
        LocalDateTime expiryDate = LocalDateTime.now().plusHours(1); // 1 hour expiry
        
        PasswordResetToken resetToken = new PasswordResetToken(token, user, expiryDate);
        tokenRepository.save(resetToken);
        
        // Send email
        try {
            emailService.sendPasswordResetEmail(user.getEmail(), token);
            return true;
        } catch (Exception e) {
            // If email fails, delete the token
            tokenRepository.delete(resetToken);
            throw new RuntimeException("Failed to send password reset email", e);
        }
    }
    
    public boolean validateResetToken(String token) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByTokenAndUsedFalse(token);
        
        if (tokenOpt.isEmpty()) {
            return false;
        }
        
        PasswordResetToken resetToken = tokenOpt.get();
        return !resetToken.isExpired();
    }
    
    @Transactional
    public boolean resetPassword(String token, String newPassword) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByTokenAndUsedFalse(token);
        
        if (tokenOpt.isEmpty()) {
            return false;
        }
        
        PasswordResetToken resetToken = tokenOpt.get();
        
        if (resetToken.isExpired()) {
            return false;
        }
        
        // Update user password
        Registration user = resetToken.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        registrationRepository.save(user);
        
        // Mark token as used
        resetToken.setUsed(true);
        tokenRepository.save(resetToken);
        
        return true;
    }
    
    public Optional<Registration> getUserByResetToken(String token) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByTokenAndUsedFalse(token);
        
        if (tokenOpt.isPresent() && !tokenOpt.get().isExpired()) {
            return Optional.of(tokenOpt.get().getUser());
        }
        
        return Optional.empty();
    }
    
    @Transactional
    public void cleanupExpiredTokens() {
        tokenRepository.deleteExpiredTokens(LocalDateTime.now());
    }
}
