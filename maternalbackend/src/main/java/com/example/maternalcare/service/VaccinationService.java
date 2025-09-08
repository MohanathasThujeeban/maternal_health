package com.example.maternalcare.service;

import com.example.maternalcare.dto.VaccinationRequest;
import com.example.maternalcare.dto.VaccinationResponse;
import com.example.maternalcare.model.Vaccination;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.enums.VaccinationStatus;
import com.example.maternalcare.repository.VaccinationRepository;
import com.example.maternalcare.repository.RegistrationRepository;
import com.example.maternalcare.services.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.stream.Collectors;
import java.util.Map;
import java.util.HashMap;
import java.util.Optional;
import java.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
@Transactional
public class VaccinationService {

    private static final Logger logger = LoggerFactory.getLogger(VaccinationService.class);

    @Autowired
    private VaccinationRepository vaccinationRepository;
    
    @Autowired
    private RegistrationRepository registrationRepository;
    
    @Autowired
    private EmailService emailService;

    public List<VaccinationResponse> getAllVaccinations() {
        return vaccinationRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public VaccinationResponse createVaccination(VaccinationRequest request) {
        Vaccination vaccination = new Vaccination();
        vaccination.setMotherNic(request.getMotherNic());
        vaccination.setBabyId(request.getBabyId()); // Set baby ID
        vaccination.setChildName(request.getChildName());
        vaccination.setVaccinationType(request.getVaccinationType());
        vaccination.setAgeToGive(request.getAgeToGive());
        vaccination.setVaccinationDate(request.getVaccinationDate());
        vaccination.setBatchNumber(request.getBatchNumber());
        vaccination.setEffectsFollowingImmunization(request.getEffectsFollowingImmunization());
        vaccination.setStatus(VaccinationStatus.PENDING);

        Vaccination saved = vaccinationRepository.save(vaccination);
        
        // Send email notification to the mother
        try {
            Optional<Registration> motherRegistration = registrationRepository.findByNicNumber(request.getMotherNic());
            if (motherRegistration.isPresent()) {
                Registration mother = motherRegistration.get();
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                String formattedDate = request.getVaccinationDate().format(formatter);
                
                emailService.sendVaccinationNotificationEmail(
                    mother.getEmail(),
                    mother.getFullName(),
                    request.getChildName(),
                    request.getVaccinationType(),
                    request.getAgeToGive(),
                    formattedDate,
                    "Healthcare Provider" // You can pass midwife name from frontend if needed
                );
                
                logger.info("Vaccination notification email sent to mother: {}", mother.getEmail());
            } else {
                logger.warn("Mother not found with NIC: {} - Cannot send email notification", request.getMotherNic());
            }
        } catch (Exception e) {
            logger.error("Failed to send vaccination notification email for mother NIC {}: {}", 
                request.getMotherNic(), e.getMessage());
            // Continue execution even if email fails - vaccination record is still saved
        }
        
        return convertToResponse(saved);
    }

    public VaccinationResponse getVaccinationById(Long id) {
        Vaccination vaccination = vaccinationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vaccination not found with id: " + id));
        return convertToResponse(vaccination);
    }

    public List<VaccinationResponse> getVaccinationsByMotherNic(String motherNic) {
        return vaccinationRepository.findByMotherNicOrderByCreatedAtDesc(motherNic)
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<VaccinationResponse> getVaccinationsByBabyId(Long babyId) {
        return vaccinationRepository.findByBabyIdOrderByCreatedAtDesc(babyId)
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public VaccinationResponse updateVaccination(Long id, VaccinationRequest request) {
        Vaccination vaccination = vaccinationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vaccination not found with id: " + id));

        vaccination.setMotherNic(request.getMotherNic());
        vaccination.setChildName(request.getChildName());
        vaccination.setVaccinationType(request.getVaccinationType());
        vaccination.setAgeToGive(request.getAgeToGive());
        vaccination.setVaccinationDate(request.getVaccinationDate());
        vaccination.setBatchNumber(request.getBatchNumber());
        vaccination.setEffectsFollowingImmunization(request.getEffectsFollowingImmunization());

        Vaccination updated = vaccinationRepository.save(vaccination);
        
        // Send email notification to the mother about the update
        try {
            Optional<Registration> motherRegistration = registrationRepository.findByNicNumber(request.getMotherNic());
            if (motherRegistration.isPresent()) {
                Registration mother = motherRegistration.get();
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                String formattedDate = request.getVaccinationDate().format(formatter);
                
                emailService.sendVaccinationNotificationEmail(
                    mother.getEmail(),
                    mother.getFullName(),
                    request.getChildName(),
                    request.getVaccinationType(),
                    request.getAgeToGive(),
                    formattedDate,
                    "Healthcare Provider" // You can pass midwife name from frontend if needed
                );
                
                logger.info("Vaccination update notification email sent to mother: {}", mother.getEmail());
            } else {
                logger.warn("Mother not found with NIC: {} - Cannot send email notification", request.getMotherNic());
            }
        } catch (Exception e) {
            logger.error("Failed to send vaccination update notification email for mother NIC {}: {}", 
                request.getMotherNic(), e.getMessage());
            // Continue execution even if email fails - vaccination record is still updated
        }
        
        return convertToResponse(updated);
    }

    public VaccinationResponse updateVaccinationStatus(Long id, String status) {
        Vaccination vaccination = vaccinationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vaccination not found with id: " + id));

        try {
            VaccinationStatus vaccinationStatus = VaccinationStatus.valueOf(status.toUpperCase());
            vaccination.setStatus(vaccinationStatus);
            Vaccination updated = vaccinationRepository.save(vaccination);
            return convertToResponse(updated);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid vaccination status: " + status);
        }
    }

    public void deleteVaccination(Long id) {
        if (!vaccinationRepository.existsById(id)) {
            throw new RuntimeException("Vaccination not found with id: " + id);
        }
        vaccinationRepository.deleteById(id);
    }

    public Map<String, Object> getVaccinationStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalVaccinations", vaccinationRepository.count());
        stats.put("completedVaccinations", vaccinationRepository.countByStatus(VaccinationStatus.COMPLETED));
        stats.put("pendingVaccinations", vaccinationRepository.countByStatus(VaccinationStatus.PENDING));
        return stats;
    }

    public List<VaccinationResponse> getOverdueVaccinations() {
        return vaccinationRepository.findByStatusOrderByCreatedAtDesc(VaccinationStatus.OVERDUE)
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    private VaccinationResponse convertToResponse(Vaccination vaccination) {
        return new VaccinationResponse(
                vaccination.getId(),
                vaccination.getMotherNic(),
                null, // motherName not available in entity
                vaccination.getBabyId(), // Include baby ID
                vaccination.getChildName(),
                vaccination.getVaccinationType(),
                vaccination.getAgeToGive(),
                vaccination.getVaccinationDate(),
                vaccination.getBatchNumber(),
                vaccination.getEffectsFollowingImmunization(),
                vaccination.getStatus().toString(),
                vaccination.getCreatedAt(),
                vaccination.getUpdatedAt()
        );
    }
}
