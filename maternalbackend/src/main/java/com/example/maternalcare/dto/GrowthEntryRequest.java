package com.example.maternalcare.dto;

import java.time.LocalDate;

public class GrowthEntryRequest {
    private String motherNic;
    private Long babyId; // References Baby.id for specific baby
    private double height;
    private double weight;
    private LocalDate date;
    private String midwifeLicense; // Optional: medical license of the midwife who recorded this
    
    // Default constructor
    public GrowthEntryRequest() {}
    
    // Constructor
    public GrowthEntryRequest(String motherNic, Long babyId, double height, double weight, LocalDate date, String midwifeLicense) {
        this.motherNic = motherNic;
        this.babyId = babyId;
        this.height = height;
        this.weight = weight;
        this.date = date;
        this.midwifeLicense = midwifeLicense;
    }
    
    // Getters and Setters
    public String getMotherNic() {
        return motherNic;
    }
    
    public void setMotherNic(String motherNic) {
        this.motherNic = motherNic;
    }
    
    public Long getBabyId() {
        return babyId;
    }
    
    public void setBabyId(Long babyId) {
        this.babyId = babyId;
    }
    
    public double getHeight() {
        return height;
    }
    
    public void setHeight(double height) {
        this.height = height;
    }
    
    public double getWeight() {
        return weight;
    }
    
    public void setWeight(double weight) {
        this.weight = weight;
    }
    
    public LocalDate getDate() {
        return date;
    }
    
    public void setDate(LocalDate date) {
        this.date = date;
    }
    
    public String getMidwifeLicense() {
        return midwifeLicense;
    }
    
    public void setMidwifeLicense(String midwifeLicense) {
        this.midwifeLicense = midwifeLicense;
    }
}
