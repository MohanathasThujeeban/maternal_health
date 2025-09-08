package com.example.maternalcare.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class BabyResponse {
    
    private Long id;
    private String motherNic;
    private String motherName; // Added for Flutter compatibility
    private String babyName;
    private LocalDate birthDate;
    private String gender;
    private Double birthWeight; // in grams
    private Double birthHeight; // in cm
    private Integer babyOrder;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Additional computed fields
    private Integer ageInDays;
    private Integer ageInMonths;
    private String displayName; // e.g., "Baby A", "1st Child", etc.
    
    // Constructors
    public BabyResponse() {}
    
    public BabyResponse(Long id, String motherNic, String motherName, String babyName, LocalDate birthDate, 
                       String gender, Double birthWeight, Double birthHeight, 
                       Integer babyOrder, Boolean isActive, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.motherNic = motherNic;
        this.motherName = motherName;
        this.babyName = babyName;
        this.birthDate = birthDate;
        this.gender = gender;
        this.birthWeight = birthWeight;
        this.birthHeight = birthHeight;
        this.babyOrder = babyOrder;
        this.isActive = isActive;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        
        // Calculate computed fields
        calculateAge();
        generateDisplayName();
    }
    
    private void calculateAge() {
        if (birthDate != null) {
            LocalDate now = LocalDate.now();
            this.ageInDays = (int) java.time.temporal.ChronoUnit.DAYS.between(birthDate, now);
            this.ageInMonths = (int) java.time.temporal.ChronoUnit.MONTHS.between(birthDate, now);
        }
    }
    
    private void generateDisplayName() {
        if (babyOrder != null) {
            String suffix = getOrdinalSuffix(babyOrder);
            this.displayName = babyOrder + suffix + " Child";
            if (babyName != null && !babyName.trim().isEmpty()) {
                this.displayName += " (" + babyName + ")";
            }
        } else if (babyName != null && !babyName.trim().isEmpty()) {
            this.displayName = babyName;
        } else {
            this.displayName = "Baby";
        }
    }
    
    private String getOrdinalSuffix(int number) {
        if (number >= 11 && number <= 13) {
            return "th";
        }
        switch (number % 10) {
            case 1: return "st";
            case 2: return "nd";
            case 3: return "rd";
            default: return "th";
        }
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
    
    public String getMotherName() {
        return motherName;
    }
    
    public void setMotherName(String motherName) {
        this.motherName = motherName;
    }
    
    public String getBabyName() {
        return babyName;
    }
    
    public void setBabyName(String babyName) {
        this.babyName = babyName;
        generateDisplayName(); // Regenerate display name when baby name changes
    }
    
    public LocalDate getBirthDate() {
        return birthDate;
    }
    
    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
        calculateAge(); // Recalculate age when birth date changes
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
        generateDisplayName(); // Regenerate display name when order changes
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
    
    public Integer getAgeInDays() {
        return ageInDays;
    }
    
    public void setAgeInDays(Integer ageInDays) {
        this.ageInDays = ageInDays;
    }
    
    public Integer getAgeInMonths() {
        return ageInMonths;
    }
    
    public void setAgeInMonths(Integer ageInMonths) {
        this.ageInMonths = ageInMonths;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }
}
