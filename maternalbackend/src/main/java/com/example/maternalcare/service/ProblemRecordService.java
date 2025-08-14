
package com.example.maternalcare.service;

import com.example.maternalcare.dto.ProblemRecordDTO;
import com.example.maternalcare.model.ProblemRecord;
import com.example.maternalcare.repository.ProblemRecordRepository;
import com.example.maternalcare.util.ProblemRecordMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProblemRecordService {
    
    @Autowired
    private ProblemRecordRepository problemRecordRepository;
    
    @Autowired
    private ProblemRecordMapper problemRecordMapper;
    
    // Save a new problem record
    public ProblemRecordDTO saveRecord(ProblemRecordDTO problemRecordDTO) {
        // Set default values for 'None' problems
        if (problemRecordDTO.getEyeProblem() == null || problemRecordDTO.getEyeProblem().isEmpty()) {
            problemRecordDTO.setEyeProblem("None");
        }
        if (problemRecordDTO.getEarProblem() == null || problemRecordDTO.getEarProblem().isEmpty()) {
            problemRecordDTO.setEarProblem("None");
        }
        
        ProblemRecord problemRecord = problemRecordMapper.toEntity(problemRecordDTO);
        ProblemRecord savedRecord = problemRecordRepository.save(problemRecord);
        return problemRecordMapper.toDTO(savedRecord);
    }
    
    // Get all records (for history view)
    public List<ProblemRecordDTO> getAllRecords() {
        List<ProblemRecord> records = problemRecordRepository.findAllByOrderByDateOfDiagnosisDesc();
        return records.stream()
                .map(problemRecordMapper::toDTO)
                .collect(Collectors.toList());
    }
    
    // Get record by ID
    public ProblemRecordDTO getRecordById(Long id) {
        ProblemRecord record = problemRecordRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Problem record not found with id: " + id));
        return problemRecordMapper.toDTO(record);
    }
    
    // Update existing record
    public ProblemRecordDTO updateRecord(Long id, ProblemRecordDTO updatedRecordDTO) {
        ProblemRecord existingRecord = problemRecordRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Problem record not found with id: " + id));
        
        existingRecord.setPatientName(updatedRecordDTO.getPatientName());
        existingRecord.setEyeProblem(updatedRecordDTO.getEyeProblem());
        existingRecord.setEarProblem(updatedRecordDTO.getEarProblem());
        existingRecord.setSymptomsDuration(updatedRecordDTO.getSymptomsDuration());
        existingRecord.setRemarks(updatedRecordDTO.getRemarks());
        existingRecord.setDateOfDiagnosis(updatedRecordDTO.getDateOfDiagnosis());
        
        ProblemRecord savedRecord = problemRecordRepository.save(existingRecord);
        return problemRecordMapper.toDTO(savedRecord);
    }
    
    // Delete record
    public void deleteRecord(Long id) {
        ProblemRecord record = problemRecordRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Problem record not found with id: " + id));
        problemRecordRepository.delete(record);
    }
    
    // Search records by patient name
    public List<ProblemRecordDTO> searchByPatientName(String patientName) {
        List<ProblemRecord> records = problemRecordRepository.findByPatientNameContainingIgnoreCase(patientName);
        return records.stream()
                .map(problemRecordMapper::toDTO)
                .collect(Collectors.toList());
    }
    
    // Get records by date range
    public List<ProblemRecordDTO> getRecordsByDateRange(LocalDate startDate, LocalDate endDate) {
        List<ProblemRecord> records = problemRecordRepository.findByDateOfDiagnosisBetween(startDate, endDate);
        return records.stream()
                .map(problemRecordMapper::toDTO)
                .collect(Collectors.toList());
    }
    
    // Get recent records (last 30 days)
    public List<ProblemRecordDTO> getRecentRecords() {
        LocalDate thirtyDaysAgo = LocalDate.now().minusDays(30);
        List<ProblemRecord> records = problemRecordRepository.findRecentRecords(thirtyDaysAgo);
        return records.stream()
                .map(problemRecordMapper::toDTO)
                .collect(Collectors.toList());
    }
    
    // Get records with eye problems
    public List<ProblemRecordDTO> getRecordsWithEyeProblems() {
        List<ProblemRecord> records = problemRecordRepository.findRecordsWithEyeProblems();
        return records.stream()
                .map(problemRecordMapper::toDTO)
                .collect(Collectors.toList());
    }
    
    // Get records with ear problems
    public List<ProblemRecordDTO> getRecordsWithEarProblems() {
        List<ProblemRecord> records = problemRecordRepository.findRecordsWithEarProblems();
        return records.stream()
                .map(problemRecordMapper::toDTO)
                .collect(Collectors.toList());
    }
}
