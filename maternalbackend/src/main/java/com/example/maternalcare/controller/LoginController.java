package com.example.maternalcare.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.dto.LoginRequest;
import com.example.maternalcare.dto.LoginResponse;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.RegistrationRepository;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class LoginController {
    
    private final RegistrationRepository registrationRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;

    public LoginController(RegistrationRepository registrationRepository) {
        this.registrationRepository = registrationRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        System.out.println("=== LOGIN ENDPOINT HIT ===");
        System.out.println("Login request: " + loginRequest);
        
        try {
            // Validate request
            if (loginRequest == null) {
                return createErrorResponse("Invalid request body", HttpStatus.BAD_REQUEST);
            }

            if (loginRequest.getNicNumber() == null || loginRequest.getNicNumber().trim().isEmpty()) {
                return createErrorResponse("NIC number is required", HttpStatus.BAD_REQUEST);
            }

            if (loginRequest.getPassword() == null || loginRequest.getPassword().trim().isEmpty()) {
                return createErrorResponse("Password is required", HttpStatus.BAD_REQUEST);
            }

            // Find user by NIC number
            Optional<Registration> userOptional = registrationRepository.findByNicNumber(loginRequest.getNicNumber().trim());
            
            if (userOptional.isEmpty()) {
                System.out.println("User not found with NIC: " + loginRequest.getNicNumber());
                return createErrorResponse("Invalid NIC number or password", HttpStatus.UNAUTHORIZED);
            }

            Registration user = userOptional.get();
            
            // Check password - handle both encrypted and plain text passwords
            boolean passwordMatches = false;
            String storedPassword = user.getPassword();
            String inputPassword = loginRequest.getPassword();
            
            // First, try password encoder (for encrypted passwords)
            try {
                passwordMatches = passwordEncoder.matches(inputPassword, storedPassword);
            } catch (Exception e) {
                // If password encoder fails, it might be a plain text password
                passwordMatches = false;
            }
            
            // If encoder doesn't match, try direct comparison (for plain text passwords)
            if (!passwordMatches) {
                passwordMatches = storedPassword.equals(inputPassword);
            }
            
            if (!passwordMatches) {
                System.out.println("Invalid password for user: " + loginRequest.getNicNumber());
                return createErrorResponse("Invalid NIC number or password", HttpStatus.UNAUTHORIZED);
            }

            System.out.println("Login successful for user: " + user.getEmail());

            // Create success response
            LoginResponse response = new LoginResponse(
                true,
                "Login successful",
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getNicNumber(),
                user.getPhoneNumber3()
            );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            System.err.println("Login error: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            e.printStackTrace();
            
            return createErrorResponse("Login failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
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
