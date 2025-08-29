package com.example.maternalcare.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "patient_notes")
public class PatientNote {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mother_nic", nullable = false)
    private String motherNic;
    
    @Column(name = "doctor_license", nullable = false)
    private String doctorLicense;
    
    @Column(name = "doctor_name", nullable = false)
    private String doctorName;
    
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;
    
    @Column(name = "diagnosis")
    private String diagnosis;
    
    @Column(name = "treatment_plan", columnDefinition = "TEXT")
    private String treatmentPlan;
    
    @Column(name = "next_visit_date")
    private LocalDateTime nextVisitDate;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    // Default constructor
    public PatientNote() {}
    
    // Constructor
    public PatientNote(String motherNic, String doctorLicense, String doctorName, 
                      String notes, String diagnosis, String treatmentPlan) {
        this.motherNic = motherNic;
        this.doctorLicense = doctorLicense;
        this.doctorName = doctorName;
        this.notes = notes;
        this.diagnosis = diagnosis;
        this.treatmentPlan = treatmentPlan;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getMotherNic() {
        return motherNic;
    }
    
    public void setMotherNic(String motherNic) {
        this.motherNic = motherNic;
    }
    
    public String getDoctorLicense() {
        return doctorLicense;
    }
    
    public void setDoctorLicense(String doctorLicense) {
        this.doctorLicense = doctorLicense;
    }
    
    public String getDoctorName() {
        return doctorName;
    }
    
    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public String getDiagnosis() {
        return diagnosis;
    }
    
    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }
    
    public String getTreatmentPlan() {
        return treatmentPlan;
    }
    
    public void setTreatmentPlan(String treatmentPlan) {
        this.treatmentPlan = treatmentPlan;
    }
    
    public LocalDateTime getNextVisitDate() {
        return nextVisitDate;
    }
    
    public void setNextVisitDate(LocalDateTime nextVisitDate) {
        this.nextVisitDate = nextVisitDate;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
