
package com.example.maternalcare.util;

import com.example.maternalcare.dto.ProblemRecordDTO;
import com.example.maternalcare.model.ProblemRecord;
import org.springframework.stereotype.Component;

@Component
public class ProblemRecordMapper {
    
    public ProblemRecordDTO toDTO(ProblemRecord problemRecord) {
        if (problemRecord == null) {
            return null;
        }
        
        ProblemRecordDTO dto = new ProblemRecordDTO();
        dto.setId(problemRecord.getId());
        dto.setPatientName(problemRecord.getPatientName());
        dto.setBabyId(problemRecord.getBabyId());
        dto.setMotherNic(problemRecord.getMotherNic());
        dto.setEyeProblem(problemRecord.getEyeProblem());
        dto.setEarProblem(problemRecord.getEarProblem());
        dto.setSymptomsDuration(problemRecord.getSymptomsDuration());
        dto.setRemarks(problemRecord.getRemarks());
        dto.setDateOfDiagnosis(problemRecord.getDateOfDiagnosis());
        dto.setCreatedAt(problemRecord.getCreatedAt());
        dto.setUpdatedAt(problemRecord.getUpdatedAt());
        
        return dto;
    }
    
    public ProblemRecord toEntity(ProblemRecordDTO problemRecordDTO) {
        if (problemRecordDTO == null) {
            return null;
        }
        
        ProblemRecord entity = new ProblemRecord();
        entity.setId(problemRecordDTO.getId());
        entity.setPatientName(problemRecordDTO.getPatientName());
        entity.setBabyId(problemRecordDTO.getBabyId());
        entity.setMotherNic(problemRecordDTO.getMotherNic());
        entity.setEyeProblem(problemRecordDTO.getEyeProblem());
        entity.setEarProblem(problemRecordDTO.getEarProblem());
        entity.setSymptomsDuration(problemRecordDTO.getSymptomsDuration());
        entity.setRemarks(problemRecordDTO.getRemarks());
        entity.setDateOfDiagnosis(problemRecordDTO.getDateOfDiagnosis());
        
        return entity;
    }
}
