package com.bloomcare.maternalbackend.model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "growth_entries")
public class GrowthRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "mother_nic", nullable = false)
    private String motherNic;

    @Column(nullable = false)
    private Double height;

    @Column(nullable = false)
    private Double weight;

    @Column(nullable = false)
    @Temporal(TemporalType.DATE)
    private Date date;

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

    public Double getHeight() {
        return height;
    }

    public void setHeight(Double height) {
        this.height = height;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
