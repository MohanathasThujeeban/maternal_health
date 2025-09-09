package com.example.maternalcare.service;

import com.example.maternalcare.model.Baby;
import com.example.maternalcare.model.GrowthEntry;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.BabyRepository;
import com.example.maternalcare.repository.GrowthEntryRepository;
import com.example.maternalcare.repository.RegistrationRepository;
import com.example.maternalcare.services.EmailService;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

@Service
public class GrowthEntryService {

    private static final Logger logger = LoggerFactory.getLogger(GrowthEntryService.class);
    
    private final GrowthEntryRepository repository;
    private final RegistrationRepository registrationRepository;
    private final BabyRepository babyRepository;
    private final EmailService emailService;

    public GrowthEntryService(GrowthEntryRepository repository, 
                             RegistrationRepository registrationRepository,
                             BabyRepository babyRepository,
                             EmailService emailService) {
        this.repository = repository;
        this.registrationRepository = registrationRepository;
        this.babyRepository = babyRepository;
        this.emailService = emailService;
    }

    public GrowthEntry saveEntry(GrowthEntry entry) {
        // Save the growth entry
        GrowthEntry savedEntry = repository.save(entry);
        
        // Send email notification to mother
        try {
            sendGrowthUpdateEmailToMother(savedEntry);
        } catch (Exception e) {
            logger.error("Failed to send growth update email for entry: {}", savedEntry.getId(), e);
            // Don't fail the save operation if email fails
        }
        
        return savedEntry;
    }

    public List<GrowthEntry> getEntriesByNic(String nic) {
        return repository.findByMotherNicOrderByDateAsc(nic);
    }
    
    // Baby-specific methods for midwife use
    public List<GrowthEntry> getEntriesByBaby(Long babyId) {
        return repository.findByBabyIdOrderByDateAsc(babyId);
    }
    
    public List<GrowthEntry> getEntriesByMotherAndBaby(String motherNic, Long babyId) {
        return repository.findByMotherNicAndBabyIdOrderByDateAsc(motherNic, babyId);
    }

    /**
     * Save growth entry with midwife information for better email notification
     */
    public GrowthEntry saveEntryWithMidwife(GrowthEntry entry, String midwifeLicense) {
        // Save the growth entry
        GrowthEntry savedEntry = repository.save(entry);
        
        // Send email notification to mother with midwife information
        try {
            sendGrowthUpdateEmailToMotherWithMidwife(savedEntry, midwifeLicense);
        } catch (Exception e) {
            logger.error("Failed to send growth update email for entry: {}", savedEntry.getId(), e);
            // Don't fail the save operation if email fails
        }
        
        return savedEntry;
    }

    /**
     * Send growth record update email to mother (original method)
     */
    private void sendGrowthUpdateEmailToMother(GrowthEntry entry) {
        sendGrowthUpdateEmailToMotherWithMidwife(entry, null);
    }

    /**
     * Send growth record update email to mother with midwife information
     */
    private void sendGrowthUpdateEmailToMotherWithMidwife(GrowthEntry entry, String midwifeLicense) {
        try {
            // Find mother by NIC
            Optional<Registration> motherOpt = registrationRepository.findByNicNumber(entry.getMotherNic());
            
            if (motherOpt.isPresent()) {
                Registration mother = motherOpt.get();
                
                // Get midwife name if license provided
                String midwifeName = "Your Midwife";
                if (midwifeLicense != null && !midwifeLicense.trim().isEmpty()) {
                    Optional<Registration> midwifeOpt = registrationRepository.findByMedicalLicenseNumber(midwifeLicense);
                    if (midwifeOpt.isPresent()) {
                        midwifeName = midwifeOpt.get().getFullName();
                    }
                }
                
                // Format the date for display
                String formattedDate = entry.getDate().format(DateTimeFormatter.ofPattern("MMMM dd, yyyy"));
                
                // Get baby name if baby ID is provided
                String babyName = "Your baby";
                if (entry.getBabyId() != null) {
                    Optional<Baby> babyOpt = babyRepository.findById(entry.getBabyId());
                    if (babyOpt.isPresent()) {
                        babyName = babyOpt.get().getBabyName();
                    }
                }
                
                // Send email notification
                emailService.sendGrowthRecordUpdateEmail(
                    mother.getEmail(),
                    mother.getFullName(),
                    midwifeName,
                    babyName,
                    entry.getHeight(),
                    entry.getWeight(),
                    formattedDate
                );
                
                logger.info("Growth update email sent successfully to mother: {} ({}) by midwife: {}", 
                           mother.getFullName(), mother.getEmail(), midwifeName);
            } else {
                logger.warn("Mother not found for NIC: {}", entry.getMotherNic());
            }
        } catch (Exception e) {
            logger.error("Error sending growth update email for NIC: {}", entry.getMotherNic(), e);
            throw e;
        }
    }
}
