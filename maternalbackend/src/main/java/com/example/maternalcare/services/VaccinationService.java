package com.example.maternalcare.services;

import com.example.maternalcare.dto.VaccinationRequest;
import com.example.maternalcare.dto.VaccinationResponse;
import com.example.maternalcare.model.Vaccination;
import com.example.maternalcare.model.Vaccination.VaccinationStatus;
import com.example.maternalcare.repository.VaccinationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class VaccinationService {
    
    @Autowired
    private VaccinationRepository vaccinationRepository;
    
    /**
     * Create a new vaccination record
     */
    public VaccinationResponse createVaccination(VaccinationRequest request) {
        // Validate request
        validateVaccinationRequest(request);
        
        // Create new vaccination entity
        Vaccination vaccination = new Vaccination();
        vaccination.setMotherNic(request.getMotherNic());
        vaccination.setChildName(request.getChildName());
        vaccination.setVaccinationType(request.getVaccinationType());
        vaccination.setAgeToGive(request.getAgeToGive());
        vaccination.setVaccinationDate(request.getVaccinationDate());
        vaccination.setBatchNumber(request.getBatchNumber());
        vaccination.setEffectsFollowingImmunization(request.getEffectsFollowingImmunization());
        
        // Parse and set status
        try {
            vaccination.setStatus(VaccinationStatus.valueOf(request.getStatus().toUpperCase()));
        } catch (IllegalArgumentException e) {
            vaccination.setStatus(VaccinationStatus.PENDING);
        }
        
        // Save and return response
        Vaccination savedVaccination = vaccinationRepository.save(vaccination);
        return VaccinationResponse.fromEntity(savedVaccination);
    }
    
    /**
     * Update an existing vaccination record
     */
    public VaccinationResponse updateVaccination(Long id, VaccinationRequest request) {
        // Find existing vaccination
        Optional<Vaccination> existingVaccination = vaccinationRepository.findById(id);
        if (existingVaccination.isEmpty()) {
            throw new RuntimeException("Vaccination record not found with id: " + id);
        }
        
        // Validate request
        validateVaccinationRequest(request);
        
        // Update vaccination entity
        Vaccination vaccination = existingVaccination.get();
        vaccination.setMotherNic(request.getMotherNic());
        vaccination.setChildName(request.getChildName());
        vaccination.setVaccinationType(request.getVaccinationType());
        vaccination.setAgeToGive(request.getAgeToGive());
        vaccination.setVaccinationDate(request.getVaccinationDate());
        vaccination.setBatchNumber(request.getBatchNumber());
        vaccination.setEffectsFollowingImmunization(request.getEffectsFollowingImmunization());
        
        // Parse and set status
        try {
            vaccination.setStatus(VaccinationStatus.valueOf(request.getStatus().toUpperCase()));
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status: " + request.getStatus());
        }
        
        // Save and return response
        Vaccination updatedVaccination = vaccinationRepository.save(vaccination);
        return VaccinationResponse.fromEntity(updatedVaccination);
    }
    
    /**
     * Get vaccination by ID
     */
    @Transactional(readOnly = true)
    public VaccinationResponse getVaccinationById(Long id) {
        Optional<Vaccination> vaccination = vaccinationRepository.findById(id);
        if (vaccination.isEmpty()) {
            throw new RuntimeException("Vaccination record not found with id: " + id);
        }
        return VaccinationResponse.fromEntity(vaccination.get());
    }
    
    /**
     * Get all vaccinations for a mother by NIC
     */
    @Transactional(readOnly = true)
    public List<VaccinationResponse> getVaccinationsByMotherNic(String motherNic) {
        List<Vaccination> vaccinations = vaccinationRepository.findByMotherNicOrderByCreatedAtDesc(motherNic);
        return vaccinations.stream()
                .map(VaccinationResponse::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * Get all vaccinations
     */
    @Transactional(readOnly = true)
    public List<VaccinationResponse> getAllVaccinations() {
        List<Vaccination> vaccinations = vaccinationRepository.findAll();
        return vaccinations.stream()
                .map(VaccinationResponse::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * Get vaccinations by status
     */
    @Transactional(readOnly = true)
    public List<VaccinationResponse> getVaccinationsByStatus(String status) {
        try {
            VaccinationStatus vaccinationStatus = VaccinationStatus.valueOf(status.toUpperCase());
            List<Vaccination> vaccinations = vaccinationRepository.findByStatusOrderByCreatedAtDesc(vaccinationStatus);
            return vaccinations.stream()
                    .map(VaccinationResponse::fromEntity)
                    .collect(Collectors.toList());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status: " + status);
        }
    }
    
    /**
     * Update vaccination status only
     */
    public VaccinationResponse updateVaccinationStatus(Long id, String status) {
        Optional<Vaccination> existingVaccination = vaccinationRepository.findById(id);
        if (existingVaccination.isEmpty()) {
            throw new RuntimeException("Vaccination record not found with id: " + id);
        }
        
        try {
            VaccinationStatus vaccinationStatus = VaccinationStatus.valueOf(status.toUpperCase());
            Vaccination vaccination = existingVaccination.get();
            vaccination.setStatus(vaccinationStatus);
            
            // If marking as completed, set vaccination date to today if not already set
            if (vaccinationStatus == VaccinationStatus.COMPLETED && vaccination.getVaccinationDate() == null) {
                vaccination.setVaccinationDate(LocalDate.now());
            }
            
            Vaccination updatedVaccination = vaccinationRepository.save(vaccination);
            return VaccinationResponse.fromEntity(updatedVaccination);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status: " + status);
        }
    }
    
    /**
     * Delete vaccination record
     */
    public void deleteVaccination(Long id) {
        if (!vaccinationRepository.existsById(id)) {
            throw new RuntimeException("Vaccination record not found with id: " + id);
        }
        vaccinationRepository.deleteById(id);
    }
    
    /**
     * Get overdue vaccinations
     */
    @Transactional(readOnly = true)
    public List<VaccinationResponse> getOverdueVaccinations() {
        List<Vaccination> overdueVaccinations = vaccinationRepository.findOverdueVaccinations(LocalDate.now());
        return overdueVaccinations.stream()
                .map(VaccinationResponse::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * Get vaccination statistics
     */
    @Transactional(readOnly = true)
    public VaccinationStats getVaccinationStats() {
        long totalVaccinations = vaccinationRepository.count();
        long completedVaccinations = vaccinationRepository.countByStatus(VaccinationStatus.COMPLETED);
        long pendingVaccinations = vaccinationRepository.countByStatus(VaccinationStatus.PENDING);
        long missedVaccinations = vaccinationRepository.countByStatus(VaccinationStatus.MISSED);
        
        return new VaccinationStats(totalVaccinations, completedVaccinations, pendingVaccinations, missedVaccinations);
    }
    
    /**
     * Get vaccination statistics for a specific mother
     */
    @Transactional(readOnly = true)
    public VaccinationStats getVaccinationStatsByMotherNic(String motherNic) {
        List<Vaccination> motherVaccinations = vaccinationRepository.findByMotherNicOrderByCreatedAtDesc(motherNic);
        
        long totalVaccinations = motherVaccinations.size();
        long completedVaccinations = motherVaccinations.stream()
                .mapToLong(v -> v.getStatus() == VaccinationStatus.COMPLETED ? 1 : 0)
                .sum();
        long pendingVaccinations = motherVaccinations.stream()
                .mapToLong(v -> v.getStatus() == VaccinationStatus.PENDING ? 1 : 0)
                .sum();
        long missedVaccinations = motherVaccinations.stream()
                .mapToLong(v -> v.getStatus() == VaccinationStatus.MISSED ? 1 : 0)
                .sum();
        
        return new VaccinationStats(totalVaccinations, completedVaccinations, pendingVaccinations, missedVaccinations);
    }
    
    /**
     * Validate vaccination request
     */
    private void validateVaccinationRequest(VaccinationRequest request) {
        if (request.getMotherNic() == null || request.getMotherNic().trim().isEmpty()) {
            throw new RuntimeException("Mother NIC is required");
        }
        if (request.getChildName() == null || request.getChildName().trim().isEmpty()) {
            throw new RuntimeException("Child name is required");
        }
        if (request.getVaccinationType() == null || request.getVaccinationType().trim().isEmpty()) {
            throw new RuntimeException("Vaccination type is required");
        }
        if (request.getAgeToGive() == null || request.getAgeToGive().trim().isEmpty()) {
            throw new RuntimeException("Age to give is required");
        }
        if (request.getStatus() == null || request.getStatus().trim().isEmpty()) {
            throw new RuntimeException("Status is required");
        }
        
        // Validate status enum
        try {
            VaccinationStatus.valueOf(request.getStatus().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status. Must be one of: PENDING, COMPLETED, MISSED");
        }
    }
    
    /**
     * Inner class for vaccination statistics
     */
    public static class VaccinationStats {
        private long totalVaccinations;
        private long completedVaccinations;
        private long pendingVaccinations;
        private long missedVaccinations;
        
        public VaccinationStats(long totalVaccinations, long completedVaccinations, 
                               long pendingVaccinations, long missedVaccinations) {
            this.totalVaccinations = totalVaccinations;
            this.completedVaccinations = completedVaccinations;
            this.pendingVaccinations = pendingVaccinations;
            this.missedVaccinations = missedVaccinations;
        }
        
        // Getters
        public long getTotalVaccinations() { return totalVaccinations; }
        public long getCompletedVaccinations() { return completedVaccinations; }
        public long getPendingVaccinations() { return pendingVaccinations; }
        public long getMissedVaccinations() { return missedVaccinations; }
        
        public double getCompletionRate() {
            return totalVaccinations > 0 ? (double) completedVaccinations / totalVaccinations * 100 : 0;
        }
    }
}