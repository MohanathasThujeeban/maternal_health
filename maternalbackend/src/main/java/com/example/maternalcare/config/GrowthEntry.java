package com.example.maternalhealth.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "growth_entries")
public class GrowthEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String motherNic;

    @Column(nullable = false)
    private Double height;

    @Column(nullable = false)
    private Double weight;

    @Column(nullable = false)
    private LocalDate date;

    // Constructors
    public GrowthEntry() {}

    public GrowthEntry(String motherNic, Double height, Double weight, LocalDate date) {
        this.motherNic = motherNic;
        this.height = height;
        this.weight = weight;
        this.date = date;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public String getMotherNic() { return motherNic; }
    public void setMotherNic(String motherNic) { this.motherNic = motherNic; }
    public Double getHeight() { return height; }
    public void setHeight(Double height) { this.height = height; }
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
}
