package com.example.maternalcare.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import com.example.maternalcare.services.EmailVerificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Web Controller for handling HTML template responses
 * Separate from RestController to properly serve Thymeleaf templates
 */
@Controller
public class WebController {
    
    private static final Logger logger = LoggerFactory.getLogger(WebController.class);
    
    @Autowired
    private EmailVerificationService emailVerificationService;

    /**
     * Handle email verification with HTML template response
     * This endpoint serves the beautiful verification success/error pages
     */
    @GetMapping("/api/registration/verify")
    public String verifyEmailWeb(@RequestParam String token, Model model) {
        logger.info("=== EMAIL VERIFICATION WEB ENDPOINT HIT ===");
        logger.info("Token received: {}", token);
        
        try {
            boolean success = emailVerificationService.verifyEmail(token);
            
            if (success) {
                logger.info("Email verification successful for token: {}", token);
                // Add any data needed by the template
                model.addAttribute("message", "Your email has been verified successfully!");
                model.addAttribute("appName", "Maternal Health App");
                return "email-verification-success";
            } else {
                logger.warn("Email verification failed for token: {}", token);
                model.addAttribute("errorMessage", "Verification failed. The token may be invalid or expired.");
                return "email-verification-error";
            }
            
        } catch (Exception e) {
            logger.error("Error during email verification: {}", e.getMessage(), e);
            model.addAttribute("errorMessage", "An error occurred during verification: " + e.getMessage());
            return "email-verification-error";
        }
    }
    
    /**
     * Test endpoint to verify Thymeleaf is working
     */
    @GetMapping("/test-template")
    public String testTemplate(Model model) {
        model.addAttribute("message", "Thymeleaf is working correctly!");
        model.addAttribute("appName", "Maternal Health App");
        return "email-verification-success";
    }
    
    /**
     * Direct test for email verification template
     */
    @GetMapping("/verify-test")
    public String verifyTest(Model model) {
        model.addAttribute("message", "Test verification successful!");
        model.addAttribute("appName", "Maternal Health App");
        return "email-verification-success";
    }
}
