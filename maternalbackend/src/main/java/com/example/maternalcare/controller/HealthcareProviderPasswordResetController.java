package com.example.maternalcare.controller;

import com.example.maternalcare.services.HealthcareProviderPasswordResetService;
import com.example.maternalcare.model.HealthcareProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/healthcare")
public class HealthcareProviderPasswordResetController {
    
    @Autowired
    private HealthcareProviderPasswordResetService passwordResetService;
    
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Email is required"));
            }
            
            boolean success = passwordResetService.initiatePasswordReset(email.trim());
            
            if (success) {
                return ResponseEntity.ok()
                    .body(Map.of(
                        "message", "If an account with that email exists, you will receive a password reset email shortly.",
                        "success", true
                    ));
            } else {
                // Return success message even if not found for security
                return ResponseEntity.ok()
                    .body(Map.of(
                        "message", "If an account with that email exists, you will receive a password reset email shortly.",
                        "success", true
                    ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to process password reset request: " + e.getMessage()));
        }
    }
    
    @GetMapping("/reset-password-form")
    public ModelAndView showResetPasswordForm(@RequestParam String token) {
        ModelAndView mav = new ModelAndView();
        
        if (passwordResetService.validateResetToken(token)) {
            Optional<HealthcareProvider> provider = passwordResetService.getProviderByResetToken(token);
            
            if (provider.isPresent()) {
                mav.setViewName("healthcare-reset-password");
                mav.addObject("token", token);
                mav.addObject("providerName", provider.get().getFullName());
                mav.addObject("providerType", provider.get().getProviderType().toString());
                mav.addObject("email", provider.get().getEmail());
                return mav;
            }
        }
        
        // Invalid or expired token
        mav.setViewName("healthcare-reset-password-error");
        mav.addObject("error", "Invalid or expired password reset link");
        return mav;
    }
    
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        try {
            String token = request.get("token");
            String newPassword = request.get("newPassword");
            String confirmPassword = request.get("confirmPassword");
            
            if (token == null || token.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Reset token is required"));
            }
            
            if (newPassword == null || newPassword.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "New password is required"));
            }
            
            if (newPassword.length() < 8) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Password must be at least 8 characters long"));
            }
            
            if (!newPassword.equals(confirmPassword)) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Passwords do not match"));
            }
            
            boolean success = passwordResetService.resetPassword(token, newPassword);
            
            if (success) {
                return ResponseEntity.ok()
                    .body(Map.of(
                        "message", "Password has been reset successfully. You can now log in with your new password.",
                        "success", true
                    ));
            } else {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Invalid or expired reset token"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to reset password: " + e.getMessage()));
        }
    }
    
    @GetMapping("/validate-reset-token")
    public ResponseEntity<?> validateResetToken(@RequestParam String token) {
        try {
            boolean isValid = passwordResetService.validateResetToken(token);
            
            if (isValid) {
                Optional<HealthcareProvider> provider = passwordResetService.getProviderByResetToken(token);
                
                if (provider.isPresent()) {
                    return ResponseEntity.ok()
                        .body(Map.of(
                            "valid", true,
                            "providerName", provider.get().getFullName(),
                            "providerType", provider.get().getProviderType().toString(),
                            "email", provider.get().getEmail()
                        ));
                }
            }
            
            return ResponseEntity.ok()
                .body(Map.of("valid", false));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to validate token: " + e.getMessage()));
        }
    }
}
