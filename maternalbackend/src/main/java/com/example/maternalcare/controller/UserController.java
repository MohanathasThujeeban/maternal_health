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
@CrossOrigin(origins = "*", allowCredentials = "false")
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
                motherData.put("id", mother.getId());
                motherData.put("fullName", mother.getFullName());
                motherData.put("nicNumber", mother.getNicNumber());
                motherData.put("email", mother.getEmail());
                motherData.put("phoneNumber", mother.getPhoneNumber3());
                motherData.put("registrationDate", mother.getCreatedAt());
                motherData.put("lastUpdated", mother.getUpdatedAt());
                motherData.put("isActive", mother.getIsActive());
                motherData.put("userRole", mother.getUserRole().toString());
                // Add address and dateOfBirth as null for now - can be added to model later if needed
                motherData.put("address", null);
                motherData.put("dateOfBirth", null);
                motherData.put("emergencyContact", null);
                return motherData;
            }).collect(Collectors.toList());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("mothers", mothersList);
            response.put("count", mothersList.size());
            response.put("totalRegistered", mothersList.size());
            response.put("activeMothers", mothersList.stream().mapToInt(m -> (Boolean) m.get("isActive") ? 1 : 0).sum());
            response.put("inactiveMothers", mothersList.stream().mapToInt(m -> (Boolean) m.get("isActive") ? 0 : 1).sum());
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
                } else {
                    // Set as MOTHER for ALL non-medical users (regardless of current role)
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

    // Search mothers by name, NIC, or email
    @GetMapping("/mothers/search")
    public ResponseEntity<?> searchMothers(@RequestParam(name = "q", required = false) String searchTerm) {
        try {
            List<Registration> allMothers = registrationRepository.findByUserRole(UserRole.MOTHER);
            
            List<Registration> filteredMothers;
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                filteredMothers = allMothers;
            } else {
                String searchLower = searchTerm.toLowerCase().trim();
                filteredMothers = allMothers.stream()
                    .filter(mother -> 
                        mother.getFullName().toLowerCase().contains(searchLower) ||
                        mother.getNicNumber().toLowerCase().contains(searchLower) ||
                        mother.getEmail().toLowerCase().contains(searchLower)
                    )
                    .collect(Collectors.toList());
            }
            
            List<Map<String, Object>> mothersList = filteredMothers.stream().map(mother -> {
                Map<String, Object> motherData = new HashMap<>();
                motherData.put("id", mother.getId());
                motherData.put("fullName", mother.getFullName());
                motherData.put("nicNumber", mother.getNicNumber());
                motherData.put("email", mother.getEmail());
                motherData.put("phoneNumber", mother.getPhoneNumber3());
                motherData.put("registrationDate", mother.getCreatedAt());
                motherData.put("lastUpdated", mother.getUpdatedAt());
                motherData.put("isActive", mother.getIsActive());
                motherData.put("userRole", mother.getUserRole().toString());
                return motherData;
            }).collect(Collectors.toList());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("mothers", mothersList);
            response.put("count", mothersList.size());
            response.put("searchTerm", searchTerm);
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to search mothers: " + e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    // Get specific mother details by NIC
    @GetMapping("/mothers/{nicNumber}")
    public ResponseEntity<?> getMotherByNic(@PathVariable String nicNumber) {
        try {
            Optional<Registration> motherOptional = registrationRepository.findByNicNumber(nicNumber);
            
            if (motherOptional.isEmpty() || motherOptional.get().getUserRole() != UserRole.MOTHER) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "Mother not found with NIC: " + nicNumber);
                errorResponse.put("timestamp", LocalDateTime.now());
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
            }

            Registration mother = motherOptional.get();
            
            Map<String, Object> motherData = new HashMap<>();
            motherData.put("id", mother.getId());
            motherData.put("fullName", mother.getFullName());
            motherData.put("nicNumber", mother.getNicNumber());
            motherData.put("email", mother.getEmail());
            motherData.put("phoneNumber", mother.getPhoneNumber3());
            motherData.put("registrationDate", mother.getCreatedAt());
            motherData.put("lastUpdated", mother.getUpdatedAt());
            motherData.put("isActive", mother.getIsActive());
            motherData.put("userRole", mother.getUserRole().toString());
            // Future enhancement: add baby information, medical history, etc.
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("mother", motherData);
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to get mother details: " + e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    // Get mothers statistics
    @GetMapping("/mothers/stats")
    public ResponseEntity<?> getMothersStatistics() {
        try {
            List<Registration> mothers = registrationRepository.findByUserRole(UserRole.MOTHER);
            
            long totalMothers = mothers.size();
            long activeMothers = mothers.stream().mapToLong(m -> m.getIsActive() ? 1 : 0).sum();
            long inactiveMothers = totalMothers - activeMothers;
            
            // Calculate recent registrations (last 30 days)
            LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
            long recentRegistrations = mothers.stream()
                .mapToLong(m -> m.getCreatedAt().isAfter(thirtyDaysAgo) ? 1 : 0).sum();
            
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalMothers", totalMothers);
            stats.put("activeMothers", activeMothers);
            stats.put("inactiveMothers", inactiveMothers);
            stats.put("recentRegistrations", recentRegistrations);
            stats.put("registrationRate", totalMothers > 0 ? (double) recentRegistrations / totalMothers * 100 : 0);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("statistics", stats);
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to get mothers statistics: " + e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
