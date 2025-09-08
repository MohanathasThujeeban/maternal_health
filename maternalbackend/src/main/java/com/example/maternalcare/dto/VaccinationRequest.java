package com.example.maternalcare.dto;

import java.time.LocalDate;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class VaccinationRequest {
    @NotBlank(message = "Mother NIC is required")
    private String motherNic;
    
    private String motherName;
    
    private Long babyId; // Optional for backward compatibility
    
    @NotBlank(message = "Child name is required")
    private String childName;
    
    @NotBlank(message = "Vaccination type is required")
    private String vaccinationType;
    
    private String ageToGive;
    
    @NotNull(message = "Vaccination date is required")
    private LocalDate vaccinationDate;
    
    private String batchNumber;
    private String effectsFollowingImmunization;
    
    // Default constructor
    public VaccinationRequest() {}
    
    // Constructor with required fields
    public VaccinationRequest(String motherNic, String childName, String vaccinationType, LocalDate vaccinationDate) {
        this.motherNic = motherNic;
        this.childName = childName;
        this.vaccinationType = vaccinationType;
        this.vaccinationDate = vaccinationDate;
    }
    
    // Getters and setters
    public String getMotherNic() {
        return motherNic;
    }
    
    public void setMotherNic(String motherNic) {
        this.motherNic = motherNic;
    }
    
    public String getMotherName() {
        return motherName;
    }
    
    public void setMotherName(String motherName) {
        this.motherName = motherName;
    }
    
    public Long getBabyId() {
        return babyId;
    }
    
    public void setBabyId(Long babyId) {
        this.babyId = babyId;
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
}
