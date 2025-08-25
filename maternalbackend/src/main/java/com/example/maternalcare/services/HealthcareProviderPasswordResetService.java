package com.example.maternalcare.services;

import com.example.maternalcare.model.PasswordResetToken;
import com.example.maternalcare.model.HealthcareProvider;
import com.example.maternalcare.repository.PasswordResetTokenRepository;
import com.example.maternalcare.repository.HealthcareProviderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class HealthcareProviderPasswordResetService {
    
    @Autowired
    private PasswordResetTokenRepository tokenRepository;
    
    @Autowired
    private HealthcareProviderRepository healthcareProviderRepository;
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Transactional
    public boolean initiatePasswordReset(String email) {
        Optional<HealthcareProvider> providerOpt = healthcareProviderRepository.findByEmail(email);
        
        if (providerOpt.isEmpty()) {
            return false; // Provider not found
        }
        
        HealthcareProvider provider = providerOpt.get();
        
        // Delete any existing tokens for this provider
        // Use a custom query to delete tokens by provider email
        try {
            tokenRepository.deleteAll(
                tokenRepository.findAll().stream()
                    .filter(token -> provider.getEmail().equals(token.getProviderEmail()))
                    .toList()
            );
        } catch (Exception e) {
            // Continue if deletion fails - not critical
            System.out.println("Warning: Could not delete existing tokens: " + e.getMessage());
        }
        
        // Generate new token
        String token = UUID.randomUUID().toString();
        LocalDateTime expiryDate = LocalDateTime.now().plusHours(1); // 1 hour expiry
        
        PasswordResetToken resetToken = new PasswordResetToken();
        resetToken.setToken(token);
        resetToken.setProviderEmail(provider.getEmail());
        resetToken.setProviderType("HEALTHCARE_PROVIDER");
        resetToken.setExpiryDate(expiryDate);
        resetToken.setUsed(false);
        resetToken.setCreatedAt(LocalDateTime.now());
        
        tokenRepository.save(resetToken);
        
        // Send email
        try {
            System.out.println("Attempting to send password reset email to: " + provider.getEmail());
            emailService.sendHealthcareProviderPasswordResetEmail(
                provider.getEmail(), 
                provider.getFullName(),
                provider.getProviderType().toString(),
                token
            );
            System.out.println("Password reset email sent successfully to: " + provider.getEmail());
            return true;
        } catch (Exception e) {
            System.err.println("Failed to send password reset email: " + e.getMessage());
            e.printStackTrace();
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
        return !resetToken.isExpired() && 
               resetToken.getProviderType() != null && 
               "HEALTHCARE_PROVIDER".equals(resetToken.getProviderType());
    }
    
    @Transactional
    public boolean resetPassword(String token, String newPassword) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByTokenAndUsedFalse(token);
        
        if (tokenOpt.isEmpty()) {
            return false;
        }
        
        PasswordResetToken resetToken = tokenOpt.get();
        
        if (resetToken.isExpired() || 
            resetToken.getProviderType() == null || 
            !"HEALTHCARE_PROVIDER".equals(resetToken.getProviderType())) {
            return false;
        }
        
        // Find healthcare provider by email
        Optional<HealthcareProvider> providerOpt = healthcareProviderRepository.findByEmail(resetToken.getProviderEmail());
        
        if (providerOpt.isEmpty()) {
            return false;
        }
        
        // Update provider password
        HealthcareProvider provider = providerOpt.get();
        provider.setPassword(passwordEncoder.encode(newPassword));
        provider.setUpdatedAt(LocalDateTime.now());
        healthcareProviderRepository.save(provider);
        
        // Mark token as used
        resetToken.setUsed(true);
        tokenRepository.save(resetToken);
        
        return true;
    }
    
    public Optional<HealthcareProvider> getProviderByResetToken(String token) {
        Optional<PasswordResetToken> tokenOpt = tokenRepository.findByTokenAndUsedFalse(token);
        
        if (tokenOpt.isPresent() && 
            !tokenOpt.get().isExpired() && 
            tokenOpt.get().getProviderType() != null &&
            "HEALTHCARE_PROVIDER".equals(tokenOpt.get().getProviderType())) {
            return healthcareProviderRepository.findByEmail(tokenOpt.get().getProviderEmail());
        }
        
        return Optional.empty();
    }
    
    @Transactional
    public void cleanupExpiredTokens() {
        tokenRepository.deleteExpiredTokens(LocalDateTime.now());
    }
}
