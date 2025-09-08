package com.example.maternalcare.controller;

import com.example.maternalcare.dto.VaccinationRequest;
import com.example.maternalcare.dto.VaccinationResponse;
import com.example.maternalcare.service.VaccinationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/vaccinations")
@CrossOrigin(origins = {"http://localhost:3000", "http://10.11.20.8:3000"}, allowCredentials = "false")
public class VaccinationController {

    @Autowired
    private VaccinationService vaccinationService;

    @GetMapping
    public ResponseEntity<List<VaccinationResponse>> getAllVaccinations() {
        try {
            List<VaccinationResponse> vaccinations = vaccinationService.getAllVaccinations();
            return ResponseEntity.ok(vaccinations);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping
    public ResponseEntity<VaccinationResponse> createVaccination(@Valid @RequestBody VaccinationRequest request) {
        try {
            VaccinationResponse vaccination = vaccinationService.createVaccination(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(vaccination);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<VaccinationResponse> getVaccinationById(@PathVariable Long id) {
        try {
            VaccinationResponse vaccination = vaccinationService.getVaccinationById(id);
            return ResponseEntity.ok(vaccination);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/mother/{motherNic}")
    public ResponseEntity<List<VaccinationResponse>> getVaccinationsByMotherNic(@PathVariable String motherNic) {
        try {
            List<VaccinationResponse> vaccinations = vaccinationService.getVaccinationsByMotherNic(motherNic);
            return ResponseEntity.ok(vaccinations);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/baby/{babyId}")
    public ResponseEntity<List<VaccinationResponse>> getVaccinationsByBabyId(@PathVariable Long babyId) {
        try {
            List<VaccinationResponse> vaccinations = vaccinationService.getVaccinationsByBabyId(babyId);
            return ResponseEntity.ok(vaccinations);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<VaccinationResponse> updateVaccination(
            @PathVariable Long id, 
            @Valid @RequestBody VaccinationRequest request) {
        try {
            VaccinationResponse vaccination = vaccinationService.updateVaccination(id, request);
            return ResponseEntity.ok(vaccination);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<VaccinationResponse> updateVaccinationStatus(
            @PathVariable Long id, 
            @RequestParam String status) {
        try {
            VaccinationResponse vaccination = vaccinationService.updateVaccinationStatus(id, status);
            return ResponseEntity.ok(vaccination);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVaccination(@PathVariable Long id) {
        try {
            vaccinationService.deleteVaccination(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/statistics")
    public ResponseEntity<?> getVaccinationStatistics() {
        try {
            Object stats = vaccinationService.getVaccinationStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/overdue")
    public ResponseEntity<List<VaccinationResponse>> getOverdueVaccinations() {
        try {
            List<VaccinationResponse> vaccinations = vaccinationService.getOverdueVaccinations();
            return ResponseEntity.ok(vaccinations);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}