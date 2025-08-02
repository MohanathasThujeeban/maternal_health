package com.example.maternalcare.controller;

import com.example.maternalcare.dto.ForgotPasswordRequest;
import com.example.maternalcare.dto.ResetPasswordRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.services.PasswordResetService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/api/auth")
public class PasswordResetController {
    
    @Autowired
    private PasswordResetService passwordResetService;
    
    @PostMapping("/forgot-password")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = passwordResetService.initiatePasswordReset(request.getEmail());
            
            if (success) {
                response.put("success", true);
                response.put("message", "Password reset email sent successfully");
            } else {
                response.put("success", false);
                response.put("message", "No account found with this email address");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to send password reset email: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/reset-password-form")
    public String showResetPasswordForm(@RequestParam("token") String token, Model model) {
        boolean isValidToken = passwordResetService.validateResetToken(token);
        
        if (!isValidToken) {
            model.addAttribute("error", "Invalid or expired reset token");
            return "reset-password-error";
        }
        
        Optional<Registration> userOpt = passwordResetService.getUserByResetToken(token);
        if (userOpt.isPresent()) {
            model.addAttribute("token", token);
            model.addAttribute("userEmail", userOpt.get().getEmail());
            return "reset-password-form";
        } else {
            model.addAttribute("error", "Invalid reset token");
            return "reset-password-error";
        }
    }
    
    @PostMapping("/reset-password")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Validate password confirmation
            if (!request.getNewPassword().equals(request.getConfirmPassword())) {
                response.put("success", false);
                response.put("message", "Passwords do not match");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean success = passwordResetService.resetPassword(request.getToken(), request.getNewPassword());
            
            if (success) {
                response.put("success", true);
                response.put("message", "Password reset successfully");
            } else {
                response.put("success", false);
                response.put("message", "Invalid or expired reset token");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to reset password: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/validate-token")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> validateToken(@RequestParam("token") String token) {
        Map<String, Object> response = new HashMap<>();
        
        boolean isValid = passwordResetService.validateResetToken(token);
        response.put("valid", isValid);
        
        if (isValid) {
            Optional<Registration> userOpt = passwordResetService.getUserByResetToken(token);
            if (userOpt.isPresent()) {
                response.put("email", userOpt.get().getEmail());
            }
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/login-redirect")
    public String redirectToLogin() {
        // This could redirect to your Flutter app's deep link or a simple page
        return "redirect:/api/auth/login-page";
    }
    
    @GetMapping("/login-page")
    @ResponseBody
    public String loginPage() {
        return "<html><head><title>Redirecting...</title></head><body>" +
               "<script>window.location.href='maternal://login';</script>" +
               "<p>Redirecting to app... If this doesn't work, please open the Maternal Health app manually.</p>" +
               "</body></html>";
    }
}
