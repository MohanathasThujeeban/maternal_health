package com.example.maternalcare.controller;

import com.example.maternalcare.dto.BabyRequest;
import com.example.maternalcare.dto.BabyResponse;
import com.example.maternalcare.service.BabyService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/babies")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class BabyController {
    
    @Autowired
    private BabyService babyService;
    
    /**
     * Create a new baby for a mother
     */
    @PostMapping
    public ResponseEntity<?> createBaby(@Valid @RequestBody BabyRequest request) {
        System.out.println("=== BABY CREATION REQUEST ===");
        System.out.println("Mother NIC: " + request.getMotherNic());
        System.out.println("Baby Name: " + request.getBabyName());
        System.out.println("Birth Date: " + request.getBirthDate());
        System.out.println("Gender: " + request.getGender());
        
        try {
            BabyResponse baby = babyService.createBaby(request);
            System.out.println("=== BABY CREATED SUCCESSFULLY ===");
            System.out.println("Baby ID: " + baby.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Baby created successfully");
            response.put("baby", baby);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            System.err.println("=== BABY CREATION RUNTIME ERROR ===");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            System.err.println("=== BABY CREATION GENERAL ERROR ===");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to create baby: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
    /**
     * Get all babies for a mother by NIC
     */
    @GetMapping("/mother/{motherNic}")
    public ResponseEntity<?> getBabiesByMotherNic(@PathVariable String motherNic) {
        try {
            List<BabyResponse> babies = babyService.getBabiesByMotherNic(motherNic);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("babies", babies);
            response.put("count", babies.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to fetch babies: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
    /**
     * Get a specific baby by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getBabyById(@PathVariable Long id) {
        try {
            Optional<BabyResponse> baby = babyService.getBabyById(id);
            if (baby.isPresent()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("baby", baby.get());
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "Baby not found");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to fetch baby: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
    /**
     * Get a specific baby by mother NIC and baby order
     */
    @GetMapping("/mother/{motherNic}/order/{babyOrder}")
    public ResponseEntity<?> getBabyByMotherNicAndOrder(@PathVariable String motherNic, @PathVariable Integer babyOrder) {
        try {
            Optional<BabyResponse> baby = babyService.getBabyByMotherNicAndOrder(motherNic, babyOrder);
            if (baby.isPresent()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("baby", baby.get());
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "Baby not found");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to fetch baby: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
    /**
     * Get a specific baby by mother NIC and baby name
     */
    @GetMapping("/mother/{motherNic}/name/{babyName}")
    public ResponseEntity<?> getBabyByMotherNicAndName(@PathVariable String motherNic, @PathVariable String babyName) {
        try {
            Optional<BabyResponse> baby = babyService.getBabyByMotherNicAndName(motherNic, babyName);
            if (baby.isPresent()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("baby", baby.get());
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "Baby not found");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to fetch baby: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
    /**
     * Update baby information
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateBaby(@PathVariable Long id, @Valid @RequestBody BabyRequest request) {
        try {
            BabyResponse baby = babyService.updateBaby(id, request);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Baby updated successfully");
            response.put("baby", baby);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to update baby: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
    /**
     * Delete (soft delete) a baby
     */
    @DeleteMapping("/{id}/mother/{motherNic}")
    public ResponseEntity<?> deleteBaby(@PathVariable Long id, @PathVariable String motherNic) {
        try {
            babyService.deleteBaby(id, motherNic);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Baby deleted successfully");
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to delete baby: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
    /**
     * Get count of babies for a mother
     */
    @GetMapping("/mother/{motherNic}/count")
    public ResponseEntity<?> getBabyCount(@PathVariable String motherNic) {
        try {
            Long count = babyService.getBabyCount(motherNic);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("count", count);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Failed to get baby count: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
