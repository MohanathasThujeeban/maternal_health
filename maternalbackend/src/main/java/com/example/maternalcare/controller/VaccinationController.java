package com.example.maternalcare.controller;

import com.example.maternalcare.dto.VaccinationRequest;
import com.example.maternalcare.dto.VaccinationResponse;
import com.example.maternalcare.services.VaccinationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/vaccinations")
@CrossOrigin(origins = "*")
public class VaccinationController {
    
    @Autowired
    private VaccinationService vaccinationService;
    
    /**
     * Create a new vaccination record
     */
    @PostMapping
    public ResponseEntity<?> createVaccination(@Valid @RequestBody VaccinationRequest request) {
        try {
            VaccinationResponse response = vaccinationService.createVaccination(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to create vaccination record");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
    
    /**
     * Get all vaccination records
     */
    @GetMapping
    public ResponseEntity<?> getAllVaccinations() {
        try {
            List<VaccinationResponse> vaccinations = vaccinationService.getAllVaccinations();
            return ResponseEntity.ok(vaccinations);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to retrieve vaccination records");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Get vaccination record by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getVaccinationById(@PathVariable Long id) {
        try {
            VaccinationResponse vaccination = vaccinationService.getVaccinationById(id);
            return ResponseEntity.ok(vaccination);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Vaccination record not found");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }
    
    /**
     * Get vaccination records by mother NIC
     */
    @GetMapping("/mother/{motherNic}")
    public ResponseEntity<?> getVaccinationsByMotherNic(@PathVariable String motherNic) {
        try {
            List<VaccinationResponse> vaccinations = vaccinationService.getVaccinationsByMotherNic(motherNic);
            return ResponseEntity.ok(vaccinations);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to retrieve vaccination records");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Get vaccination records by status
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<?> getVaccinationsByStatus(@PathVariable String status) {
        try {
            List<VaccinationResponse> vaccinations = vaccinationService.getVaccinationsByStatus(status);
            return ResponseEntity.ok(vaccinations);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to retrieve vaccination records");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
    
    /**
     * Update vaccination record
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateVaccination(@PathVariable Long id, @Valid @RequestBody VaccinationRequest request) {
        try {
            VaccinationResponse response = vaccinationService.updateVaccination(id, request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to update vaccination record");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
    
    /**
     * Update vaccination status only
     */
    @PatchMapping("/{id}/status")
    public ResponseEntity<?> updateVaccinationStatus(@PathVariable Long id, @RequestBody Map<String, String> statusRequest) {
        try {
            String status = statusRequest.get("status");
            if (status == null || status.trim().isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Status is required");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
            }
            
            VaccinationResponse response = vaccinationService.updateVaccinationStatus(id, status);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to update vaccination status");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
    
    /**
     * Delete vaccination record
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteVaccination(@PathVariable Long id) {
        try {
            vaccinationService.deleteVaccination(id);
            Map<String, String> response = new HashMap<>();
            response.put("message", "Vaccination record deleted successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to delete vaccination record");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
    
    /**
     * Get overdue vaccinations
     */
    @GetMapping("/overdue")
    public ResponseEntity<?> getOverdueVaccinations() {
        try {
            List<VaccinationResponse> overdueVaccinations = vaccinationService.getOverdueVaccinations();
            return ResponseEntity.ok(overdueVaccinations);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to retrieve overdue vaccinations");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Get vaccination statistics
     */
    @GetMapping("/stats")
    public ResponseEntity<?> getVaccinationStats() {
        try {
            VaccinationService.VaccinationStats stats = vaccinationService.getVaccinationStats();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to retrieve vaccination statistics");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Get vaccination statistics for a specific mother
     */
    @GetMapping("/stats/mother/{motherNic}")
    public ResponseEntity<?> getVaccinationStatsByMotherNic(@PathVariable String motherNic) {
        try {
            VaccinationService.VaccinationStats stats = vaccinationService.getVaccinationStatsByMotherNic(motherNic);
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to retrieve vaccination statistics");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}