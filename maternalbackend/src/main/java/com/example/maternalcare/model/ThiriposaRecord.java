package com.example.maternalcare.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "thiriposa_records")
public class ThiriposaRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mother_nic", nullable = false)
    private String motherNic;
    
    @Column(name = "baby_id")
    private Long babyId; // References Baby.id - Optional for backward compatibility
    
    @Column(name = "supply_date", nullable = false)
    private LocalDateTime date;
    
    @Column(nullable = false)
    private Integer quantity;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
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

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
