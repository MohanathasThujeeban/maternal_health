package com.example.maternalcare.dto;

import com.example.maternalcare.model.ProviderType;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

public class HealthcareProviderRegistrationRequest {
    
    @NotBlank(message = "Full name is required")
    private String fullName;
    
    @NotBlank(message = "NIC number is required")
    private String nicNumber;
    
    @NotBlank(message = "Phone number is required")
    private String phoneNumber;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters long")
    private String password;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @NotNull(message = "Provider type is required")
    private ProviderType providerType;
    
    @NotBlank(message = "Medical license number is required")
    private String medicalLicenseNumber;
    
    @NotBlank(message = "Institution/Hospital name is required")
    private String institution;
    
    private String specialization;
    
    @Min(value = 0, message = "Years of experience cannot be negative")
    @Max(value = 50, message = "Years of experience seems too high")
    private Integer yearsOfExperience;
    
    private LocalDateTime licenseExpiryDate;

    // Default constructor
    public HealthcareProviderRegistrationRequest() {}

    // Constructor
    public HealthcareProviderRegistrationRequest(String fullName, String nicNumber, 
                                               String phoneNumber, String password, 
                                               String email, ProviderType providerType,
                                               String medicalLicenseNumber, String institution) {
        this.fullName = fullName;
        this.nicNumber = nicNumber;
        this.phoneNumber = phoneNumber;
        this.password = password;
        this.email = email;
        this.providerType = providerType;
        this.medicalLicenseNumber = medicalLicenseNumber;
        this.institution = institution;
    }

    // Getters and setters
    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getNicNumber() {
        return nicNumber;
    }

    public void setNicNumber(String nicNumber) {
        this.nicNumber = nicNumber;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public ProviderType getProviderType() {
        return providerType;
    }

    public void setProviderType(ProviderType providerType) {
        this.providerType = providerType;
    }

    public String getMedicalLicenseNumber() {
        return medicalLicenseNumber;
    }

    public void setMedicalLicenseNumber(String medicalLicenseNumber) {
        this.medicalLicenseNumber = medicalLicenseNumber;
    }

    public String getInstitution() {
        return institution;
    }

    public void setInstitution(String institution) {
        this.institution = institution;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public Integer getYearsOfExperience() {
        return yearsOfExperience;
    }

    public void setYearsOfExperience(Integer yearsOfExperience) {
        this.yearsOfExperience = yearsOfExperience;
    }

    public LocalDateTime getLicenseExpiryDate() {
        return licenseExpiryDate;
    }

    public void setLicenseExpiryDate(LocalDateTime licenseExpiryDate) {
        this.licenseExpiryDate = licenseExpiryDate;
    }

    @Override
    public String toString() {
        return "HealthcareProviderRegistrationRequest{" +
                "fullName='" + fullName + '\'' +
                ", nicNumber='" + nicNumber + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", email='" + email + '\'' +
                ", providerType=" + providerType +
                ", medicalLicenseNumber='" + medicalLicenseNumber + '\'' +
                ", institution='" + institution + '\'' +
                ", specialization='" + specialization + '\'' +
                ", yearsOfExperience=" + yearsOfExperience +
                '}';
    }
}
