package com.example.maternalcare.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public class BabyRequest {
    
    @NotBlank(message = "Mother NIC is required")
    private String motherNic;
    
    @NotBlank(message = "Baby name is required")
    @Size(min = 1, max = 100, message = "Baby name must be between 1 and 100 characters")
    private String babyName;
    
    private LocalDate birthDate;
    
    private String gender; // MALE, FEMALE, OTHER
    
    @Positive(message = "Birth weight must be positive")
    private Double birthWeight; // in grams
    
    @Positive(message = "Birth height must be positive")
    private Double birthHeight; // in cm
    
    // Constructors
    public BabyRequest() {}
    
    public BabyRequest(String motherNic, String babyName, LocalDate birthDate, 
                      String gender, Double birthWeight, Double birthHeight) {
        this.motherNic = motherNic;
        this.babyName = babyName;
        this.birthDate = birthDate;
        this.gender = gender;
        this.birthWeight = birthWeight;
        this.birthHeight = birthHeight;
    }
    
    // Getters and Setters
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
}
