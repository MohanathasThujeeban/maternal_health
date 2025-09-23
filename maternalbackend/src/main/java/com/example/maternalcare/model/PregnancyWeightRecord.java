package com.example.maternalcare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "pregnancy_weight_records")
public class PregnancyWeightRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mother_nic", nullable = false, length = 12)
    @NotBlank(message = "Mother NIC is required")
    private String motherNic;
    
    @Column(name = "current_weight", nullable = false)
    @NotNull(message = "Current weight is required")
    private Double currentWeight; // in kg
    
    @Column(name = "current_height")
    private Double currentHeight; // in cm
    
    @Column(name = "blood_pressure", length = 20)
    private String bloodPressure; // e.g., "120/80"
    
    @Column(name = "pregnancy_week")
    private Integer pregnancyWeek;
    
    @Column(name = "measurement_date", nullable = false)
    @NotNull(message = "Measurement date is required")
    private LocalDate measurementDate;
    
    @Column(name = "midwife_notes", columnDefinition = "TEXT")
    private String midwifeNotes;
    
    @Column(name = "recorded_by", length = 12)
    private String recordedBy; // NIC of the midwife who recorded this
    
    @Column(name = "bmi_calculated")
    private Double bmiCalculated;
    
    @Column(name = "weight_gain_from_previous")
    private Double weightGainFromPrevious; // calculated field
    
    @Column(name = "is_high_risk_indicator")
    private Boolean isHighRiskIndicator = false;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false, columnDefinition = "DATETIME")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", columnDefinition = "DATETIME")
    private LocalDateTime updatedAt;
    
    // Default constructor
    public PregnancyWeightRecord() {}
    
    // Constructor with essential fields
    public PregnancyWeightRecord(String motherNic, Double currentWeight, LocalDate measurementDate, String recordedBy) {
        this.motherNic = motherNic;
        this.currentWeight = currentWeight;
        this.measurementDate = measurementDate;
        this.recordedBy = recordedBy;
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
    
    public Double getCurrentWeight() {
        return currentWeight;
    }
    
    public void setCurrentWeight(Double currentWeight) {
        this.currentWeight = currentWeight;
    }
    
    public Double getCurrentHeight() {
        return currentHeight;
    }
    
    public void setCurrentHeight(Double currentHeight) {
        this.currentHeight = currentHeight;
    }
    
    public String getBloodPressure() {
        return bloodPressure;
    }
    
    public void setBloodPressure(String bloodPressure) {
        this.bloodPressure = bloodPressure;
    }
    
    public Integer getPregnancyWeek() {
        return pregnancyWeek;
    }
    
    public void setPregnancyWeek(Integer pregnancyWeek) {
        this.pregnancyWeek = pregnancyWeek;
    }
    
    public LocalDate getMeasurementDate() {
        return measurementDate;
    }
    
    public void setMeasurementDate(LocalDate measurementDate) {
        this.measurementDate = measurementDate;
    }
    
    public String getMidwifeNotes() {
        return midwifeNotes;
    }
    
    public void setMidwifeNotes(String midwifeNotes) {
        this.midwifeNotes = midwifeNotes;
    }
    
    public String getRecordedBy() {
        return recordedBy;
    }
    
    public void setRecordedBy(String recordedBy) {
        this.recordedBy = recordedBy;
    }
    
    public Double getBmiCalculated() {
        return bmiCalculated;
    }
    
    public void setBmiCalculated(Double bmiCalculated) {
        this.bmiCalculated = bmiCalculated;
    }
    
    public Double getWeightGainFromPrevious() {
        return weightGainFromPrevious;
    }
    
    public void setWeightGainFromPrevious(Double weightGainFromPrevious) {
        this.weightGainFromPrevious = weightGainFromPrevious;
    }
    
    public Boolean getIsHighRiskIndicator() {
        return isHighRiskIndicator;
    }
    
    public void setIsHighRiskIndicator(Boolean isHighRiskIndicator) {
        this.isHighRiskIndicator = isHighRiskIndicator;
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
}