package com.example.maternalcare.controller;

import com.example.maternalcare.services.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class EmailTestController {
    
    @Autowired
    private EmailService emailService;
    
    @PostMapping("/email")
    public ResponseEntity<Map<String, Object>> testEmail(@RequestParam String email) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            emailService.sendVerificationEmail(email, "test-token-123");
            response.put("success", true);
            response.put("message", "Test email sent successfully to " + email);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to send email: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/email-config")
    public ResponseEntity<Map<String, Object>> checkEmailConfig() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean isConnected = emailService.testEmailConnection();
            response.put("success", isConnected);
            response.put("message", isConnected ? "Email configuration is working" : "Email configuration failed");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Email configuration error: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}
