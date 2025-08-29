package com.example.maternalcare.controller;

import com.example.maternalcare.dto.MaternalProfileDTO;
import com.example.maternalcare.model.MaternalProfile;
import com.example.maternalcare.service.MaternalProfileService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/maternal-profile")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class MaternalProfileController {
    
    @Autowired
    private MaternalProfileService maternalProfileService;
    
    /**
     * Get maternal profile by mother NIC
     */
    @GetMapping("/{motherNic}")
    public ResponseEntity<Map<String, Object>> getProfile(@PathVariable String motherNic) {
        try {
            Optional<MaternalProfile> profile = maternalProfileService.getProfileByMotherNic(motherNic);
            
            Map<String, Object> response = new HashMap<>();
            if (profile.isPresent()) {
                response.put("success", true);
                response.put("profile", profile.get());
                response.put("message", "Profile retrieved successfully");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("profile", null);
                response.put("message", "Profile not found");
                return ResponseEntity.ok(response);
            }
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error retrieving profile: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * Create or update maternal profile
     */
    @PostMapping("/{motherNic}")
    public ResponseEntity<Map<String, Object>> createOrUpdateProfile(
            @PathVariable String motherNic,
            @Valid @RequestBody MaternalProfileDTO profileDTO) {
        
        try {
            System.out.println("Received profile update request for mother NIC: " + motherNic);
            
            MaternalProfile savedProfile = maternalProfileService.createOrUpdateProfile(motherNic, profileDTO);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("profile", savedProfile);
            response.put("message", "Profile saved successfully");
            
            System.out.println("Profile saved successfully for mother NIC: " + motherNic);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Error saving profile for mother NIC " + motherNic + ": " + e.getMessage());
            e.printStackTrace();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error saving profile: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * Update specific fields of maternal profile
     */
    @PutMapping("/{motherNic}")
    public ResponseEntity<Map<String, Object>> updateProfile(
            @PathVariable String motherNic,
            @Valid @RequestBody MaternalProfileDTO profileDTO) {
        
        try {
            if (!maternalProfileService.profileExists(motherNic)) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "Profile not found for mother NIC: " + motherNic);
                return ResponseEntity.status(404).body(response);
            }
            
            MaternalProfile updatedProfile = maternalProfileService.createOrUpdateProfile(motherNic, profileDTO);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("profile", updatedProfile);
            response.put("message", "Profile updated successfully");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error updating profile: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * Check if profile exists
     */
    @GetMapping("/{motherNic}/exists")
    public ResponseEntity<Map<String, Object>> checkProfileExists(@PathVariable String motherNic) {
        try {
            boolean exists = maternalProfileService.profileExists(motherNic);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("exists", exists);
            response.put("message", exists ? "Profile exists" : "Profile does not exist");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error checking profile existence: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * Delete maternal profile
     */
    @DeleteMapping("/{motherNic}")
    public ResponseEntity<Map<String, Object>> deleteProfile(@PathVariable String motherNic) {
        try {
            boolean deleted = maternalProfileService.deleteProfile(motherNic);
            
            Map<String, Object> response = new HashMap<>();
            if (deleted) {
                response.put("success", true);
                response.put("message", "Profile deleted successfully");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Profile not found");
                return ResponseEntity.status(404).body(response);
            }
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error deleting profile: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
}
