package com.example.maternalcare.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.dto.RegistrationRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.EmailVerificationToken;
import com.example.maternalcare.repository.RegistrationRepository;
import com.example.maternalcare.repository.EmailVerificationTokenRepository;
import com.example.maternalcare.services.EmailService;
import com.example.maternalcare.services.EmailVerificationService;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/") // Changed back to root to handle /api/api paths from Flutter
public class RegistrationController {
    
    private final RegistrationRepository repository;
    private final EmailService emailService;
    private final EmailVerificationTokenRepository tokenRepository;
    private final EmailVerificationService emailVerificationService;

    public RegistrationController(
            RegistrationRepository repository,
            EmailService emailService,
            EmailVerificationTokenRepository tokenRepository,
            EmailVerificationService emailVerificationService) {
        this.repository = repository;
        this.emailService = emailService;
        this.tokenRepository = tokenRepository;
        this.emailVerificationService = emailVerificationService;
    }

    // Add a test endpoint to verify the controller is working
    @GetMapping("/test")
    public ResponseEntity<?> test() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "API is working!");
        response.put("timestamp", LocalDateTime.now());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/registration")
    public ResponseEntity<?> register(@RequestBody RegistrationRequest request) {
        System.out.println("=== REGISTRATION ENDPOINT HIT ===");
        System.out.println("Request body: " + request);
        
        try {
            // Validate request
            if (request == null) {
                System.err.println("Registration request is null");
                return createErrorResponse("Invalid request body", HttpStatus.BAD_REQUEST);
            }

            if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
                System.err.println("Email is null or empty");
                return createErrorResponse("Email is required", HttpStatus.BAD_REQUEST);
            }

            if (request.getNicNumber() == null || request.getNicNumber().trim().isEmpty()) {
                System.err.println("NIC number is null or empty");
                return createErrorResponse("NIC number is required", HttpStatus.BAD_REQUEST);
            }

            if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
                System.err.println("Password is null or empty");
                return createErrorResponse("Password is required", HttpStatus.BAD_REQUEST);
            }

            if (request.getPhoneNumber3() == null || request.getPhoneNumber3().trim().isEmpty()) {
                System.err.println("Phone number is null or empty");
                return createErrorResponse("Phone number is required", HttpStatus.BAD_REQUEST);
            }

            if (request.getFullName() == null || request.getFullName().trim().isEmpty()) {
                System.err.println("Full name is null or empty");
                return createErrorResponse("Full name is required", HttpStatus.BAD_REQUEST);
            }

            System.out.println("Received registration request for email: " + request.getEmail());
            
            // Check for duplicate email
            if (repository.findByEmail(request.getEmail()).isPresent()) {
                System.out.println("Email already exists: " + request.getEmail());
                return createErrorResponse("Email already registered", HttpStatus.CONFLICT);
            }

            // Check for duplicate NIC
            if (repository.findByNicNumber(request.getNicNumber()).isPresent()) {
                System.out.println("NIC already exists: " + request.getNicNumber());
                return createErrorResponse("NIC number already registered", HttpStatus.CONFLICT);
            }

            // Check if email is verified
            if (!emailVerificationService.isEmailVerified(request.getEmail().trim().toLowerCase())) {
                System.out.println("Email not verified: " + request.getEmail());
                return createErrorResponse("Email not verified. Please verify your email before registering.", HttpStatus.BAD_REQUEST);
            }

            // Create new registration
            Registration reg = new Registration();
            reg.setFullName(request.getFullName().trim());
            reg.setNicNumber(request.getNicNumber().trim());
            reg.setPhoneNumber3(request.getPhoneNumber3().trim());
            reg.setPassword(request.getPassword()); // Consider hashing the password
            reg.setEmail(request.getEmail().trim().toLowerCase());

            System.out.println("Attempting to save registration...");
            Registration saved = repository.save(reg);
            System.out.println("Registration saved successfully with ID: " + saved.getId());

            // Create success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Registration successful");
            response.put("id", saved.getId());
            response.put("email", saved.getEmail());
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            System.err.println("Registration error: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            e.printStackTrace();
            
            return createErrorResponse("Registration failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/registration/send-verification")
    public ResponseEntity<?> sendVerification(@RequestBody Map<String, String> body) {
        System.out.println("=== SEND VERIFICATION ENDPOINT HIT ===");
        
        try {
            String email = body.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                return createErrorResponse("Email is required", HttpStatus.BAD_REQUEST);
            }
            
            if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                return createErrorResponse("Invalid email format", HttpStatus.BAD_REQUEST);
            }
            
            if (repository.findByEmail(email).isPresent()) {
                return createErrorResponse("Email already registered", HttpStatus.CONFLICT);
            }
            
            boolean success = emailVerificationService.sendVerificationEmail(email);
            
            Map<String, Object> response = new HashMap<>();
            if (success) {
                response.put("success", true);
                response.put("message", "Verification email sent successfully");
            } else {
                response.put("success", false);
                response.put("message", "Failed to send verification email");
            }
            response.put("timestamp", LocalDateTime.now());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Send verification error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to send verification email: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/registration/verify")
    public ResponseEntity<?> verifyEmail(@RequestParam String token) {
        System.out.println("=== VERIFY EMAIL ENDPOINT HIT ===");
        
        try {
            boolean success = emailVerificationService.verifyEmail(token);
            
            Map<String, Object> response = new HashMap<>();
            if (success) {
                response.put("success", true);
                response.put("message", "Email verified successfully!");
            } else {
                response.put("success", false);
                response.put("message", "Invalid or expired verification token");
            }
            response.put("timestamp", LocalDateTime.now());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Verify email error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to verify email: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/registration/check-verification")
    public ResponseEntity<?> checkVerificationStatus(@RequestParam String email) {
        System.out.println("=== CHECK VERIFICATION STATUS ENDPOINT HIT ===");
        
        try {
            boolean isVerified = emailVerificationService.isEmailVerified(email);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("verified", isVerified);
            response.put("message", isVerified ? "Email is verified" : "Email is not verified");
            response.put("timestamp", LocalDateTime.now());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Check verification status error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to check verification status: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/registration/verify-email")
    public ResponseEntity<?> verifyEmailAvailability(@RequestBody Map<String, String> body) {
        System.out.println("=== VERIFY EMAIL AVAILABILITY ENDPOINT HIT ===");
        
        try {
            String email = body.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                return createErrorResponse("Email is required", HttpStatus.BAD_REQUEST);
            }
            
            if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                return createErrorResponse("Invalid email format", HttpStatus.BAD_REQUEST);
            }
            
            if (repository.findByEmail(email).isPresent()) {
                return createErrorResponse("Email already registered", HttpStatus.CONFLICT);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Email is valid and available");
            response.put("timestamp", LocalDateTime.now());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Email validation error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Email validation failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Helper method to create consistent error responses
    private ResponseEntity<?> createErrorResponse(String message, HttpStatus status) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("error", message);
        errorResponse.put("timestamp", LocalDateTime.now());
        errorResponse.put("status", status.value());
        return ResponseEntity.status(status).body(errorResponse);
    }
}