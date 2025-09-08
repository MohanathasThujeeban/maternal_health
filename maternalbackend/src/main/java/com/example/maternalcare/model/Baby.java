package com.example.maternalcare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "babies")
public class Baby {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mother_nic", nullable = false, length = 15)
    private String motherNic;
    
    @Column(name = "baby_name", nullable = false, length = 100)
    @NotBlank(message = "Baby name is required")
    @Size(min = 1, max = 100, message = "Baby name must be between 1 and 100 characters")
    private String babyName;
    
    @Column(name = "birth_date")
    private LocalDate birthDate;
    
    @Column(name = "gender", length = 10)
    private String gender; // MALE, FEMALE, OTHER
    
    @Column(name = "birth_weight")
    private Double birthWeight; // in grams
    
    @Column(name = "birth_height")
    private Double birthHeight; // in cm
    
    @Column(name = "baby_order", nullable = false)
    private Integer babyOrder; // 1st child, 2nd child, etc.
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    // Constructors
    public Baby() {}
    
    public Baby(String motherNic, String babyName, LocalDate birthDate, 
                String gender, Double birthWeight, Double birthHeight, Integer babyOrder) {
        this.motherNic = motherNic;
        this.babyName = babyName;
        this.birthDate = birthDate;
        this.gender = gender;
        this.birthWeight = birthWeight;
        this.birthHeight = birthHeight;
        this.babyOrder = babyOrder;
    }
    
    // JPA lifecycle callbacks
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
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
    
    public String getBabyName() {
        return babyName;
    }
    
    public void setBabyName(String babyName) {
        this.babyName = babyName;
    }
    
    public LocalDate getBirthDate() {
        return birthDate;
    }
    
    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public Double getBirthWeight() {
        return birthWeight;
    }
    
    public void setBirthWeight(Double birthWeight) {
        this.birthWeight = birthWeight;
    }
    
    public Double getBirthHeight() {
        return birthHeight;
    }
    
    public void setBirthHeight(Double birthHeight) {
        this.birthHeight = birthHeight;
    }
    
    public Integer getBabyOrder() {
        return babyOrder;
    }
    
    public void setBabyOrder(Integer babyOrder) {
        this.babyOrder = babyOrder;
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
    
    @Override
    public String toString() {
        return "Baby{" +
                "id=" + id +
                ", motherNic='" + motherNic + '\'' +
                ", babyName='" + babyName + '\'' +
                ", birthDate=" + birthDate +
                ", gender='" + gender + '\'' +
                ", babyOrder=" + babyOrder +
                ", isActive=" + isActive +
                '}';
    }
}
