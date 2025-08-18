package com.example.maternalcare.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "vaccinations")
public class Vaccination {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mother_nic", nullable = false, length = 15)
    private String motherNic;
    
    @Column(name = "child_name", nullable = false, length = 100)
    private String childName;
    
    @Column(name = "vaccination_type", nullable = false, length = 100)
    private String vaccinationType;
    
    @Column(name = "age_to_give", nullable = false, length = 50)
    private String ageToGive;
    
    @Column(name = "vaccination_date")
    private LocalDate vaccinationDate;
    
    @Column(name = "batch_number", length = 50)
    private String batchNumber;
    
    @Column(name = "effects_following_immunization", columnDefinition = "TEXT")
    private String effectsFollowingImmunization;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private VaccinationStatus status = VaccinationStatus.PENDING;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    // Enum for vaccination status
    public enum VaccinationStatus {
        PENDING, COMPLETED, MISSED
    }
    
    // Constructors
    public Vaccination() {}
    
    public Vaccination(String motherNic, String childName, String vaccinationType, 
                      String ageToGive, LocalDate vaccinationDate, String batchNumber, 
                      String effectsFollowingImmunization, VaccinationStatus status) {
        this.motherNic = motherNic;
        this.childName = childName;
        this.vaccinationType = vaccinationType;
        this.ageToGive = ageToGive;
        this.vaccinationDate = vaccinationDate;
        this.batchNumber = batchNumber;
        this.effectsFollowingImmunization = effectsFollowingImmunization;
        this.status = status;
    }
    
    // JPA lifecycle callbacks
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and setters
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
    
    public String getChildName() {
        return childName;
    }
    
    public void setChildName(String childName) {
        this.childName = childName;
    }
    
    public String getVaccinationType() {
        return vaccinationType;
    }
    
    public void setVaccinationType(String vaccinationType) {
        this.vaccinationType = vaccinationType;
    }
    
    public String getAgeToGive() {
        return ageToGive;
    }
    
    public void setAgeToGive(String ageToGive) {
        this.ageToGive = ageToGive;
    }
    
    public LocalDate getVaccinationDate() {
        return vaccinationDate;
    }
    
    public void setVaccinationDate(LocalDate vaccinationDate) {
        this.vaccinationDate = vaccinationDate;
    }
    
    public String getBatchNumber() {
        return batchNumber;
    }
    
    public void setBatchNumber(String batchNumber) {
        this.batchNumber = batchNumber;
    }
    
    public String getEffectsFollowingImmunization() {
        return effectsFollowingImmunization;
    }
    
    public void setEffectsFollowingImmunization(String effectsFollowingImmunization) {
        this.effectsFollowingImmunization = effectsFollowingImmunization;
    }
    
    public VaccinationStatus getStatus() {
        return status;
    }
    
    public void setStatus(VaccinationStatus status) {
        this.status = status;
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
