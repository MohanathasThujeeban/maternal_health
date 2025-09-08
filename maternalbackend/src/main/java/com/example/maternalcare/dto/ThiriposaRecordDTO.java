package com.example.maternalcare.dto;

import java.time.LocalDateTime;

public class ThiriposaRecordDTO {
    private Long id;
    private String motherNic;
    private Long babyId; // References Baby.id for specific baby
    private LocalDateTime date;
    private Integer quantity;
    private LocalDateTime createdAt;

    // Constructors
    public ThiriposaRecordDTO() {}

    public ThiriposaRecordDTO(Long id, String motherNic, Long babyId, LocalDateTime date, Integer quantity, LocalDateTime createdAt) {
        this.id = id;
        this.motherNic = motherNic;
        this.babyId = babyId;
        this.date = date;
        this.quantity = quantity;
        this.createdAt = createdAt;
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
