package com.example.maternalcare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "healthcare_providers")
public class HealthcareProvider {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "full_name", nullable = false, length = 100)
    @NotBlank(message = "Full name is required")
    private String fullName;
    
    @Column(name = "nic_number", nullable = false, unique = true, length = 15)
    @NotBlank(message = "NIC number is required")
    private String nicNumber;
    
    @Column(name = "phone_number", nullable = false, length = 15)
    @NotBlank(message = "Phone number is required")
    private String phoneNumber;
    
    @Column(nullable = false, unique = true, length = 100)
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @Column(nullable = false)
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters long")
    private String password;
    
    @Column(name = "medical_license_number", nullable = false, unique = true, length = 50)
    @NotBlank(message = "Medical license number is required")
    private String medicalLicenseNumber;
    
    @Column(nullable = false, length = 100)
    @NotBlank(message = "Institution is required")
    private String institution;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "provider_type", nullable = false)
    private ProviderType providerType;
    
    @Column(name = "specialization", length = 100)
    private String specialization;
    
    @Column(name = "years_of_experience")
    private Integer yearsOfExperience;
    
    @Column(name = "license_expiry_date")
    private LocalDateTime licenseExpiryDate;
    
    @Column(name = "is_email_verified", nullable = false)
    private Boolean isEmailVerified = false;
    
    @Column(name = "is_approved", nullable = false)
    private Boolean isApproved = false;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false, columnDefinition = "TIMESTAMP")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", columnDefinition = "TIMESTAMP")
    private LocalDateTime updatedAt;
    
    @Column(name = "approved_by")
    private Long approvedBy;
    
    @Column(name = "approved_at")
    private LocalDateTime approvedAt;
    
    // Default constructor
    public HealthcareProvider() {}
    
    // Constructor with essential fields
    public HealthcareProvider(String fullName, String nicNumber, String phoneNumber, 
                            String email, String password, String medicalLicenseNumber, 
                            String institution, ProviderType providerType) {
        this.fullName = fullName;
        this.nicNumber = nicNumber;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.password = password;
        this.medicalLicenseNumber = medicalLicenseNumber;
        this.institution = institution;
        this.providerType = providerType;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
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
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
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
    
    public ProviderType getProviderType() {
        return providerType;
    }
    
    public void setProviderType(ProviderType providerType) {
        this.providerType = providerType;
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
    
    public Boolean getIsEmailVerified() {
        return isEmailVerified;
    }
    
    public void setIsEmailVerified(Boolean isEmailVerified) {
        this.isEmailVerified = isEmailVerified;
    }
    
    public Boolean getIsApproved() {
        return isApproved;
    }
    
    public void setIsApproved(Boolean isApproved) {
        this.isApproved = isApproved;
    }
    
    public Boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
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
    
    public Long getApprovedBy() {
        return approvedBy;
    }
    
    public void setApprovedBy(Long approvedBy) {
        this.approvedBy = approvedBy;
    }
    
    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }
    
    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }
    
    @Override
    public String toString() {
        return "HealthcareProvider{" +
                "id=" + id +
                ", fullName='" + fullName + '\'' +
                ", nicNumber='" + nicNumber + '\'' +
                ", email='" + email + '\'' +
                ", medicalLicenseNumber='" + medicalLicenseNumber + '\'' +
                ", institution='" + institution + '\'' +
                ", providerType=" + providerType +
                ", isEmailVerified=" + isEmailVerified +
                ", isApproved=" + isApproved +
                ", isActive=" + isActive +
                ", createdAt=" + createdAt +
                '}';
    }
}
