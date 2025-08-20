package com.example.maternalcare.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class VaccinationResponse {
    private Long id;
    private String motherNic;
    private String motherName;
    private String childName;
    private String vaccinationType;
    private String ageToGive;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate vaccinationDate;
    
    private String batchNumber;
    private String effectsFollowingImmunization;
    private String status;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;

    // Default constructor
    public VaccinationResponse() {}

    // Full constructor
    public VaccinationResponse(Long id, String motherNic, String motherName, String childName, 
                              String vaccinationType, String ageToGive, LocalDate vaccinationDate, 
                              String batchNumber, String effectsFollowingImmunization, String status,
                              LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.motherNic = motherNic;
        this.motherName = motherName;
        this.childName = childName;
        this.vaccinationType = vaccinationType;
        this.ageToGive = ageToGive;
        this.vaccinationDate = vaccinationDate;
        this.batchNumber = batchNumber;
        this.effectsFollowingImmunization = effectsFollowingImmunization;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
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

    public String getMotherName() {
        return motherName;
    }

    public void setMotherName(String motherName) {
        this.motherName = motherName;
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

    @Override
    public String toString() {
        return "VaccinationResponse{" +
                "id=" + id +
                ", motherNic='" + motherNic + '\'' +
                ", motherName='" + motherName + '\'' +
                ", childName='" + childName + '\'' +
                ", vaccinationType='" + vaccinationType + '\'' +
                ", ageToGive='" + ageToGive + '\'' +
                ", vaccinationDate=" + vaccinationDate +
                ", batchNumber='" + batchNumber + '\'' +
                ", effectsFollowingImmunization='" + effectsFollowingImmunization + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }

    // Utility method to convert from Entity to Response DTO
    public static VaccinationResponse fromEntity(com.example.maternalcare.model.Vaccination vaccination, String motherName) {
        VaccinationResponse response = new VaccinationResponse();
        response.setId(vaccination.getId());
        response.setMotherNic(vaccination.getMotherNic());
        response.setMotherName(motherName);
        response.setChildName(vaccination.getChildName());
        response.setVaccinationType(vaccination.getVaccinationType());
        response.setAgeToGive(vaccination.getAgeToGive());
        response.setVaccinationDate(vaccination.getVaccinationDate());
        response.setBatchNumber(vaccination.getBatchNumber());
        response.setEffectsFollowingImmunization(vaccination.getEffectsFollowingImmunization());
        response.setStatus(vaccination.getStatus() != null ? vaccination.getStatus().toString() : null);
        response.setCreatedAt(vaccination.getCreatedAt());
        response.setUpdatedAt(vaccination.getUpdatedAt());
        return response;
    }

    // Utility method to convert from Entity to Response DTO without mother name
    public static VaccinationResponse fromEntity(com.example.maternalcare.model.Vaccination vaccination) {
        return fromEntity(vaccination, null);
    }
}
