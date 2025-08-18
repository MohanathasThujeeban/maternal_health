package com.example.maternalcare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "registration")
public class Registration {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    @NotBlank(message = "Full name is required")
    @Size(min = 2, max = 100, message = "Full name must be between 2 and 100 characters")
    private String fullName;
    
    @Column(nullable = false, unique = true, length = 12)
    @NotBlank(message = "NIC number is required")
    @Pattern(regexp = "^[0-9]{9}[vVxX]$|^[0-9]{12}$", 
             message = "Invalid NIC format. Use old format (9 digits + V/X) or new format (12 digits)")
    private String nicNumber;
    
    @Column(nullable = false, length = 15)
    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^0[0-9]{9}$", message = "Invalid phone number format")
    private String phoneNumber3;
    
    @Column(nullable = false)
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters long")
    private String password;
    
    @Column(nullable = false, unique = true, length = 100)
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false, columnDefinition = "TIMESTAMP")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", columnDefinition = "TIMESTAMP")
    private LocalDateTime updatedAt;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "user_role", nullable = false)
    private UserRole userRole = UserRole.MOTHER;
    
    @Column(name = "medical_license_number")
    private String medicalLicenseNumber;
    
    @Column(name = "institution")
    private String institution;
    
    // Default constructor
    public Registration() {}
    
    // Constructor with essential fields
    public Registration(String fullName, String nicNumber, String phoneNumber3, String password, String email) {
        this.fullName = fullName;
        this.nicNumber = nicNumber;
        this.phoneNumber3 = phoneNumber3;
        this.password = password;
        this.email = email;
    }
    
    // Getters and setters for all fields
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
    
    public String getPhoneNumber3() {
        return phoneNumber3;
    }
    
    public void setPhoneNumber3(String phoneNumber3) {
        this.phoneNumber3 = phoneNumber3;
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
    
    public Boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    
    public UserRole getUserRole() {
        return userRole;
    }
    
    public void setUserRole(UserRole userRole) {
        this.userRole = userRole;
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
    
    @Override
    public String toString() {
        return "Registration{" +
                "id=" + id +
                ", nicNumber='" + nicNumber + '\'' +
                ", phoneNumber3='" + phoneNumber3 + '\'' +
                ", email='" + email + '\'' +
                ", isActive=" + isActive +
                ", userRole=" + userRole +
                ", medicalLicenseNumber='" + medicalLicenseNumber + '\'' +
                ", institution='" + institution + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}