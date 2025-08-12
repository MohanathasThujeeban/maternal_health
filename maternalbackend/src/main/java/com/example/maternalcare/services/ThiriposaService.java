package com.example.maternalcare.services;

import com.example.maternalcare.dto.ThiriposaRecordDTO;
import com.example.maternalcare.model.ThiriposaRecord;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.service.ThiriposaEmailService;
import com.example.maternalcare.repository.ThiriposaRecordRepository;
import com.example.maternalcare.repository.RegistrationRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;
import java.util.Optional;
import java.util.logging.Logger;
import java.util.logging.Level;

@Service
@Transactional
public class ThiriposaService {

    private static final Logger logger = Logger.getLogger(ThiriposaService.class.getName());

    @Autowired
    private ThiriposaRecordRepository repository;

    @Autowired
    private RegistrationRepository registrationRepository;

    @Autowired
    private ThiriposaEmailService thiriposaEmailService;

    public ThiriposaRecordDTO addRecord(ThiriposaRecordDTO recordDTO) {
        // Validate mother exists
        if (!registrationRepository.findByNicNumber(recordDTO.getMotherNic()).isPresent()) {
            throw new EntityNotFoundException("Mother with NIC " + recordDTO.getMotherNic() + " not found");
        }

        ThiriposaRecord record = new ThiriposaRecord();
        record.setMotherNic(recordDTO.getMotherNic());
        record.setDate(recordDTO.getDate());
        record.setQuantity(recordDTO.getQuantity());

        record = repository.save(record);
        return convertToDTO(record);
    }

    public List<ThiriposaRecordDTO> getRecordsByNic(String motherNic) {
        return repository.findByMotherNicOrderByDateDesc(motherNic)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<ThiriposaRecordDTO> getAllRecords() {
        return repository.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private ThiriposaRecordDTO convertToDTO(ThiriposaRecord record) {
        return new ThiriposaRecordDTO(
            record.getId(),
            record.getMotherNic(),
            record.getDate(),
            record.getQuantity(),
            record.getCreatedAt()
        );
    }

    public void sendThiriposaConfirmationEmail(ThiriposaRecordDTO recordDTO, String midwifeName) {
        try {
            // Find the mother's registration details
            Optional<Registration> motherOptional = registrationRepository.findByNicNumber(recordDTO.getMotherNic());
            
            if (motherOptional.isPresent()) {
                Registration mother = motherOptional.get();
                
                // Find the actual record to get complete details
                Optional<ThiriposaRecord> recordOptional = repository.findById(recordDTO.getId());
                if (recordOptional.isPresent()) {
                    ThiriposaRecord record = recordOptional.get();
                    thiriposaEmailService.sendThiriposaConfirmationEmail(mother, record, midwifeName);
                    logger.info("Email sent successfully for Thiriposa record ID: " + recordDTO.getId());
                } else {
                    logger.warning("Thiriposa record not found for ID: " + recordDTO.getId());
                }
            } else {
                logger.warning("Mother not found for NIC: " + recordDTO.getMotherNic());
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to send email for Thiriposa record: " + recordDTO.getId(), e);
            throw new RuntimeException("Email sending failed", e);
        }
    }
}
