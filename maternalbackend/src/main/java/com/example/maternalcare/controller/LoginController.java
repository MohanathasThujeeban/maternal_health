package com.example.maternalcare.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.dto.LoginRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.RegistrationRepository;
import com.example.maternalcare.services.EmailService;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class LoginController {
    
    private final RegistrationRepository registrationRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EmailService emailService;

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

            // Add user role information
            Map<String, Object> loginData = new HashMap<>();
            loginData.put("success", true);
            loginData.put("message", "Login successful");
            loginData.put("userId", user.getId());
            loginData.put("fullName", user.getFullName());
            loginData.put("email", user.getEmail());
            loginData.put("nicNumber", user.getNicNumber());
            loginData.put("phoneNumber", user.getPhoneNumber3());
            loginData.put("userRole", user.getUserRole().toString());
            loginData.put("medicalLicenseNumber", user.getMedicalLicenseNumber());
            loginData.put("institution", user.getInstitution());
            loginData.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(loginData);

        } catch (Exception e) {
            System.err.println("Login error: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            e.printStackTrace();
            
            return createErrorResponse("Login failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/auth/change-password/{nicNumber}")
    public ResponseEntity<?> changePassword(@PathVariable String nicNumber, @RequestBody Map<String, String> passwordRequest) {
        System.out.println("=== CHANGE PASSWORD ENDPOINT HIT ===");
        System.out.println("NIC: " + nicNumber);
        
        try {
            // Validate request
            if (passwordRequest == null) {
                return createErrorResponse("Invalid request body", HttpStatus.BAD_REQUEST);
            }

            String currentPassword = passwordRequest.get("currentPassword");
            String newPassword = passwordRequest.get("newPassword");

            if (currentPassword == null || currentPassword.trim().isEmpty()) {
                return createErrorResponse("Current password is required", HttpStatus.BAD_REQUEST);
            }

            if (newPassword == null || newPassword.trim().isEmpty()) {
                return createErrorResponse("New password is required", HttpStatus.BAD_REQUEST);
            }

            if (newPassword.length() < 6) {
                return createErrorResponse("New password must be at least 6 characters long", HttpStatus.BAD_REQUEST);
            }

            // Find user by NIC number
            Optional<Registration> userOptional = registrationRepository.findByNicNumber(nicNumber.trim());
            
            if (userOptional.isEmpty()) {
                System.out.println("User not found with NIC: " + nicNumber);
                return createErrorResponse("User not found", HttpStatus.NOT_FOUND);
            }

            Registration user = userOptional.get();
            
            // Verify current password
            boolean currentPasswordMatches = false;
            String storedPassword = user.getPassword();
            
            // First, try password encoder (for encrypted passwords)
            try {
                currentPasswordMatches = passwordEncoder.matches(currentPassword, storedPassword);
            } catch (Exception e) {
                // If password encoder fails, it might be a plain text password
                currentPasswordMatches = false;
            }
            
            // If encoder doesn't match, try direct comparison (for plain text passwords)
            if (!currentPasswordMatches) {
                currentPasswordMatches = storedPassword.equals(currentPassword);
            }
            
            if (!currentPasswordMatches) {
                System.out.println("Invalid current password for user: " + nicNumber);
                return createErrorResponse("Current password is incorrect", HttpStatus.BAD_REQUEST);
            }

            // Check if new password is different from current password
            if (currentPassword.equals(newPassword)) {
                return createErrorResponse("New password must be different from current password", HttpStatus.BAD_REQUEST);
            }

            // Encrypt the new password
            String encryptedNewPassword = passwordEncoder.encode(newPassword);
            
            // Update password
            user.setPassword(encryptedNewPassword);
            registrationRepository.save(user);

            System.out.println("Password changed successfully for user: " + user.getEmail());

            // Send email confirmation
            try {
                String changeDateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("MMM dd, yyyy 'at' HH:mm"));
                String deviceInfo = "Mobile App"; // Can be enhanced to get actual device info
                emailService.sendPasswordChangeConfirmationEmail(
                    user.getEmail(), 
                    user.getFullName(), 
                    changeDateTime, 
                    deviceInfo
                );
                System.out.println("Password change confirmation email sent to: " + user.getEmail());
            } catch (Exception emailError) {
                System.err.println("Failed to send password change confirmation email: " + emailError.getMessage());
                // Don't fail the entire operation if email fails
            }

            // Create success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Password changed successfully. A confirmation email has been sent.");
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            System.err.println("Password change error: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            e.printStackTrace();
            
            return createErrorResponse("Password change failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
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
