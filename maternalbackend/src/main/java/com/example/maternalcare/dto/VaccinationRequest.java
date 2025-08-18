package com.example.maternalcare.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public class VaccinationRequest {
    
    @NotBlank(message = "Mother NIC is required")
    @Size(max = 15, message = "Mother NIC must be at most 15 characters")
    private String motherNic;
    
    @NotBlank(message = "Child name is required")
    @Size(max = 100, message = "Child name must be at most 100 characters")
    private String childName;
    
    @NotBlank(message = "Vaccination type is required")
    @Size(max = 100, message = "Vaccination type must be at most 100 characters")
    private String vaccinationType;
    
    @NotBlank(message = "Age to give is required")
    @Size(max = 50, message = "Age to give must be at most 50 characters")
    private String ageToGive;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate vaccinationDate;
    
    @Size(max = 50, message = "Batch number must be at most 50 characters")
    private String batchNumber;
    
    private String effectsFollowingImmunization;
    
    @NotNull(message = "Status is required")
    private String status; // Will be converted to enum
    
    // Constructors
    public VaccinationRequest() {}
    
    public VaccinationRequest(String motherNic, String childName, String vaccinationType, 
                             String ageToGive, LocalDate vaccinationDate, String batchNumber, 
                             String effectsFollowingImmunization, String status) {
        this.motherNic = motherNic;
        this.childName = childName;
        this.vaccinationType = vaccinationType;
        this.ageToGive = ageToGive;
        this.vaccinationDate = vaccinationDate;
        this.batchNumber = batchNumber;
        this.effectsFollowingImmunization = effectsFollowingImmunization;
        this.status = status;
    }
    
    // Getters and setters
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
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
}
