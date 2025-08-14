
package com.example.maternalcare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "problem_records")
public class ProblemRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Patient name is required")
    @Column(name = "patient_name", nullable = false)
    private String patientName;
    
    @Column(name = "eye_problem")
    private String eyeProblem;
    
    @Column(name = "ear_problem")
    private String earProblem;
    
    @Column(name = "symptoms_duration")
    private String symptomsDuration;
    
    @Column(name = "remarks", columnDefinition = "TEXT")
    private String remarks;
    
    @NotNull(message = "Date of diagnosis is required")
    @Column(name = "date_of_diagnosis", nullable = false)
    private LocalDate dateOfDiagnosis;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public ProblemRecord() {}
    
    public ProblemRecord(String patientName, String eyeProblem, String earProblem, 
                        String symptomsDuration, String remarks, LocalDate dateOfDiagnosis) {
        this.patientName = patientName;
        this.eyeProblem = eyeProblem;
        this.earProblem = earProblem;
        this.symptomsDuration = symptomsDuration;
        this.remarks = remarks;
        this.dateOfDiagnosis = dateOfDiagnosis;
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    
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
