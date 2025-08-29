package com.example.maternalcare.controller;

import com.example.maternalcare.dto.ProfileUpdateRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.service.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/profile")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class UserProfileController {

    @Autowired
    private UserProfileService userProfileService;

    // Get user profile by NIC
    @GetMapping("/{nicNumber}")
    public ResponseEntity<?> getUserProfile(@PathVariable String nicNumber) {
        try {
            Registration user = userProfileService.getUserByNic(nicNumber);
            if (user == null) {
                return ResponseEntity.notFound().build();
            }
            
            // Create response without sensitive information
            Map<String, Object> profile = Map.of(
                "id", user.getId(),
                "fullName", user.getFullName(),
                "nicNumber", user.getNicNumber(),
                "phoneNumber", user.getPhoneNumber3(),
                "email", user.getEmail(),
                "userRole", user.getUserRole(),
                "isActive", user.getIsActive(),
                "createdAt", user.getCreatedAt(),
                "updatedAt", user.getUpdatedAt()
            );
            
            return ResponseEntity.ok(profile);
        } catch (Exception e) {
            System.err.println("Error fetching user profile: " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("error", "Failed to fetch profile"));
        }
    }

    // Update user profile
    @PutMapping("/{nicNumber}")
    public ResponseEntity<?> updateUserProfile(
            @PathVariable String nicNumber,
            @Valid @RequestBody ProfileUpdateRequest request) {
        try {
            System.out.println("Updating profile for NIC: " + nicNumber);
            System.out.println("Update request: " + request.getFullName() + ", " + 
                             request.getPhoneNumber() + ", " + request.getEmail());
            
            Registration updatedUser = userProfileService.updateUserProfile(nicNumber, request);
            
            if (updatedUser == null) {
                return ResponseEntity.notFound().build();
            }
            
            // Create response without sensitive information
            Map<String, Object> response = Map.of(
                "message", "Profile updated successfully",
                "success", true,
                "user", Map.of(
                    "id", updatedUser.getId(),
                    "fullName", updatedUser.getFullName(),
                    "nicNumber", updatedUser.getNicNumber(),
                    "phoneNumber", updatedUser.getPhoneNumber3(),
                    "email", updatedUser.getEmail(),
                    "updatedAt", updatedUser.getUpdatedAt()
                )
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error updating user profile: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of(
                "error", "Failed to update profile", 
                "message", e.getMessage(),
                "success", false
            ));
        }
    }
}
