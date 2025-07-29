package com.example.maternalcare.controller;

import com.example.maternalcare.services.EmailVerificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/auth")
public class EmailVerificationController {
    
    @Autowired
    private EmailVerificationService emailVerificationService;
    
    @PostMapping("/send-verification")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sendVerificationEmail(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = request.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "Email is required");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean success = emailVerificationService.sendVerificationEmail(email);
            
            if (success) {
                response.put("success", true);
                response.put("message", "Verification email sent successfully");
            } else {
                response.put("success", false);
                response.put("message", "Failed to send verification email");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error sending verification email: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/verify-email")
    public String verifyEmail(@RequestParam("token") String token) {
        try {
            boolean success = emailVerificationService.verifyEmail(token);
            
            if (success) {
                // Return success page
                return "email-verification-success";
            } else {
                // Return error page
                return "email-verification-error";
            }
        } catch (Exception e) {
            return "email-verification-error";
        }
    }
    
    @GetMapping("/check-verification")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkVerificationStatus(@RequestParam("email") String email) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean isVerified = emailVerificationService.isEmailVerified(email);
            
            response.put("success", true);
            response.put("verified", isVerified);
            
            if (isVerified) {
                response.put("message", "Email is verified");
            } else {
                response.put("message", "Email is not verified");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error checking verification status: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}
