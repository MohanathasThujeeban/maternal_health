package com.example.maternalcare.controller;

import com.example.maternalcare.dto.AdminLoginRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.HealthcareProvider;
import com.example.maternalcare.repository.RegistrationRepository;
import com.example.maternalcare.repository.HealthcareProviderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private RegistrationRepository registrationRepository;
    
    @Autowired
    private HealthcareProviderRepository healthcareProviderRepository;

    // Admin login endpoint with default credentials
    @PostMapping("/login")
    public ResponseEntity<?> adminLogin(@RequestBody AdminLoginRequest request) {
        System.out.println("Admin login attempt: " + request.getEmail());

        // Default admin credentials
        String defaultEmail = "admin@bloomcare";
        String defaultPassword = "Admin@123";

        Map<String, Object> response = new HashMap<>();

        if (defaultEmail.equals(request.getEmail()) && 
            defaultPassword.equals(request.getPassword())) {
            response.put("success", true);
            response.put("message", "Admin login successful");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Invalid admin credentials");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }

    // Get all users (from both registration and healthcare_provider tables)
    @GetMapping("/users")
    public ResponseEntity<List<Map<String, Object>>> getAllUsers() {
        try {
            List<Map<String, Object>> allUsers = new ArrayList<>();
            
            // Get only MOTHER users from registration table
            List<Registration> registrations = registrationRepository.findAll();
            for (Registration reg : registrations) {
                // Only include if role is MOTHER or null (default is MOTHER)
                String role = reg.getUserRole() != null ? reg.getUserRole().toString() : "MOTHER";
                if (role.equals("MOTHER")) {
                    Map<String, Object> userMap = new HashMap<>();
                    userMap.put("nicNumber", reg.getNicNumber());
                    userMap.put("fullName", reg.getFullName());
                    userMap.put("email", reg.getEmail());
                    userMap.put("phoneNumber3", reg.getPhoneNumber3());
                    userMap.put("userRole", "MOTHER");
                    userMap.put("isActive", reg.getIsActive());
                    allUsers.add(userMap);
                    
                    System.out.println("Added mother: " + reg.getFullName());
                }
            }
            
            // Get all healthcare providers (midwives and doctors) from healthcare_providers table
            List<HealthcareProvider> providers = healthcareProviderRepository.findAll();
            for (HealthcareProvider provider : providers) {
                Map<String, Object> userMap = new HashMap<>();
                userMap.put("nicNumber", provider.getNicNumber());
                userMap.put("fullName", provider.getFullName());
                userMap.put("email", provider.getEmail());
                userMap.put("phoneNumber3", provider.getPhoneNumber());
                userMap.put("userRole", provider.getProviderType() != null ? provider.getProviderType().toString() : "HEALTHCARE_PROVIDER");
                userMap.put("isActive", provider.getIsActive());
                userMap.put("medicalLicenseNumber", provider.getMedicalLicenseNumber());
                userMap.put("institution", provider.getInstitution());
                allUsers.add(userMap);
                
                System.out.println("Added healthcare provider: " + provider.getFullName() + " - Type: " + 
                    (provider.getProviderType() != null ? provider.getProviderType().toString() : "UNKNOWN"));
            }
            
            System.out.println("Total users returned: " + allUsers.size());
            return ResponseEntity.ok(allUsers);
        } catch (Exception e) {
            System.err.println("Error fetching users: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Suspend user (works for both registration and healthcare_provider tables)
    @PutMapping("/users/{nicNumber}/suspend")
    public ResponseEntity<?> suspendUser(@PathVariable String nicNumber) {
        try {
            // Try to find in registration table first
            var userOptional = registrationRepository.findByNicNumber(nicNumber);
            if (userOptional.isPresent()) {
                Registration user = userOptional.get();
                user.setIsActive(false);
                registrationRepository.save(user);

                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "User suspended successfully");
                return ResponseEntity.ok(response);
            }
            
            // Try to find in healthcare_provider table
            var providerOptional = healthcareProviderRepository.findByNicNumber(nicNumber);
            if (providerOptional.isPresent()) {
                HealthcareProvider provider = providerOptional.get();
                provider.setIsActive(false);
                healthcareProviderRepository.save(provider);

                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "User suspended successfully");
                return ResponseEntity.ok(response);
            }
            
            // User not found in either table
            Map<String, String> error = new HashMap<>();
            error.put("message", "User not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
            
        } catch (Exception e) {
            System.err.println("Error suspending user: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("message", "Error suspending user: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    // Delete user (works for both registration and healthcare_provider tables)
    @DeleteMapping("/users/{nicNumber}")
    public ResponseEntity<?> deleteUser(@PathVariable String nicNumber) {
        try {
            // Try to find in registration table first
            var userOptional = registrationRepository.findByNicNumber(nicNumber);
            if (userOptional.isPresent()) {
                Registration user = userOptional.get();
                registrationRepository.delete(user);

                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "User deleted successfully");
                return ResponseEntity.ok(response);
            }
            
            // Try to find in healthcare_provider table
            var providerOptional = healthcareProviderRepository.findByNicNumber(nicNumber);
            if (providerOptional.isPresent()) {
                HealthcareProvider provider = providerOptional.get();
                healthcareProviderRepository.delete(provider);

                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "User deleted successfully");
                return ResponseEntity.ok(response);
            }
            
            // User not found in either table
            Map<String, String> error = new HashMap<>();
            error.put("message", "User not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
            
        } catch (Exception e) {
            System.err.println("Error deleting user: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("message", "Error deleting user: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}
