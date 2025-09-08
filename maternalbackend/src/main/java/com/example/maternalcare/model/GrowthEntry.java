package com.example.maternalcare.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import com.fasterxml.jackson.annotation.JsonFormat;

@Entity
@Table(name = "growth_records")
public class GrowthEntry {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mother_nic", nullable = false)
    private String motherNic;
    
    @Column(name = "baby_id")
    private Long babyId; // References Baby.id - Optional for backward compatibility
    
    @Column(nullable = false)
    private double height;
    
    @Column(nullable = false)
    private double weight;
    
    @Column(nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;

    // Default constructor
    public GrowthEntry() {}

    // Constructor with fields
    public GrowthEntry(String motherNic, double height, double weight, LocalDate date) {
        this.motherNic = motherNic;
        this.height = height;
        this.weight = weight;
        this.date = date;
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
}
