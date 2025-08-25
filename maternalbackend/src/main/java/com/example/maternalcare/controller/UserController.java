package com.example.maternalcare.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.UserRole;
import com.example.maternalcare.repository.RegistrationRepository;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

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

    // Get all registered mothers
    @GetMapping("/mothers")
    public ResponseEntity<?> getAllMothers() {
        try {
            List<Registration> mothers = registrationRepository.findByUserRole(UserRole.MOTHER);
            
            List<Map<String, Object>> mothersList = mothers.stream().map(mother -> {
                Map<String, Object> motherData = new HashMap<>();
                motherData.put("fullName", mother.getFullName());
                motherData.put("nicNumber", mother.getNicNumber());
                motherData.put("email", mother.getEmail());
                motherData.put("phoneNumber", mother.getPhoneNumber3());
                motherData.put("registrationDate", mother.getCreatedAt());
                motherData.put("isActive", mother.getIsActive());
                return motherData;
            }).collect(Collectors.toList());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("mothers", mothersList);
            response.put("count", mothersList.size());
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to get mothers list: " + e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    // Update user roles for users who should be mothers (exclude medical professionals)
    @PostMapping("/update-mother-roles")
    public ResponseEntity<?> updateMotherRoles() {
        try {
            List<Registration> allUsers = registrationRepository.findAll();
            int updatedCount = 0;
            int medicalProfessionalCount = 0;
            
            for (Registration user : allUsers) {
                // Check if user is a medical professional
                boolean isMedicalProfessional = user.getMedicalLicenseNumber() != null || 
                                               user.getInstitution() != null ||
                                               user.getFullName().toLowerCase().contains("dr.") ||
                                               user.getEmail().contains("midwife") ||
                                               user.getEmail().contains("doctor");
                
                if (isMedicalProfessional) {
                    // Set appropriate medical role
                    if (user.getEmail().contains("midwife") || user.getFullName().toLowerCase().contains("midwife")) {
                        user.setUserRole(UserRole.MIDWIFE);
                    } else if (user.getEmail().contains("doctor") || user.getFullName().toLowerCase().contains("dr.")) {
                        user.setUserRole(UserRole.DOCTOR);
                    }
                    registrationRepository.save(user);
                    medicalProfessionalCount++;
                } else if (user.getUserRole() == null || user.getUserRole() == UserRole.DOCTOR || user.getUserRole() == UserRole.MIDWIFE) {
                    // Set as MOTHER for non-medical users
                    user.setUserRole(UserRole.MOTHER);
                    registrationRepository.save(user);
                    updatedCount++;
                }
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "User roles updated successfully");
            response.put("mothersUpdated", updatedCount);
            response.put("medicalProfessionalsUpdated", medicalProfessionalCount);
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to update user roles: " + e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
