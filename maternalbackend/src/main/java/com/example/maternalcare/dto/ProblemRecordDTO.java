
package com.example.maternalcare.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class ProblemRecordDTO {
    
    private Long id;
    
    @NotBlank(message = "Patient name is required")
    private String patientName;
    
    private Long babyId;
    private String motherNic;
    private String eyeProblem;
    private String earProblem;
    private String symptomsDuration;
    private String remarks;
    
    @NotNull(message = "Date of diagnosis is required")
    private LocalDate dateOfDiagnosis;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public ProblemRecordDTO() {}
    
    public ProblemRecordDTO(String patientName, Long babyId, String motherNic, String eyeProblem, String earProblem, 
                           String symptomsDuration, String remarks, LocalDate dateOfDiagnosis) {
        this.patientName = patientName;
        this.babyId = babyId;
        this.motherNic = motherNic;
        this.eyeProblem = eyeProblem;
        this.earProblem = earProblem;
        this.symptomsDuration = symptomsDuration;
        this.remarks = remarks;
        this.dateOfDiagnosis = dateOfDiagnosis;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    
    public String getMotherNic() { return motherNic; }
    public void setMotherNic(String motherNic) { this.motherNic = motherNic; }
    
    public String getEyeProblem() { return eyeProblem; }
    public void setEyeProblem(String eyeProblem) { this.eyeProblem = eyeProblem; }
    
    public String getEarProblem() { return earProblem; }
    public void setEarProblem(String earProblem) { this.earProblem = earProblem; }
    
    public String getSymptomsDuration() { return symptomsDuration; }
    public void setSymptomsDuration(String symptomsDuration) { this.symptomsDuration = symptomsDuration; }
    
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    
    public LocalDate getDateOfDiagnosis() { return dateOfDiagnosis; }
    public void setDateOfDiagnosis(LocalDate dateOfDiagnosis) { this.dateOfDiagnosis = dateOfDiagnosis; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
