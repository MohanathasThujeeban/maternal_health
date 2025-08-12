package com.example.maternalcare.services;

import com.example.maternalcare.dto.ThiriposaRecordDTO;
import com.example.maternalcare.model.ThiriposaRecord;
import com.example.maternalcare.repository.ThiriposaRecordRepository;
import com.example.maternalcare.repository.RegistrationRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ThiriposaService {

    @Autowired
    private ThiriposaRecordRepository repository;

    @Autowired
    private RegistrationRepository registrationRepository;

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
}
