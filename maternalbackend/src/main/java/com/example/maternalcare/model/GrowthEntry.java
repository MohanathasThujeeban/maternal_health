package com.example.maternalcare.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "growth_entries")
public class GrowthEntry {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String motherNic;
    private double height;
    private double weight;
    private LocalDateTime date;

    // Default constructor
    public GrowthEntry() {}

    // Constructor with fields
    public GrowthEntry(String motherNic, double height, double weight, LocalDateTime date) {
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

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }
}
