package com.example.maternalcare.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.RegistrationRepository;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/user")
public class UserController {
    
    private final RegistrationRepository registrationRepository;

    public UserController(RegistrationRepository registrationRepository) {
        this.registrationRepository = registrationRepository;
    }

    // Get user profile by NIC or Medical License Number
    @GetMapping("/profile/{identifier}")
    public ResponseEntity<?> getUserProfile(@PathVariable String identifier) {
        try {
            Optional<Registration> userOptional = registrationRepository.findByNicNumber(identifier);
            
            // If not found by NIC, try to find by medical license number (for healthcare providers)
            if (userOptional.isEmpty()) {
                userOptional = registrationRepository.findByMedicalLicenseNumber(identifier);
            }
            
            if (userOptional.isEmpty()) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "User not found");
                errorResponse.put("timestamp", LocalDateTime.now());
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
            }

            Registration user = userOptional.get();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("fullName", user.getFullName());
            response.put("email", user.getEmail());
            response.put("nicNumber", user.getNicNumber());
            response.put("phoneNumber", user.getPhoneNumber3());
            response.put("userRole", user.getUserRole().getDisplayName());
            response.put("medicalLicenseNumber", user.getMedicalLicenseNumber());
            response.put("institution", user.getInstitution());
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to get user profile: " + e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
