package com.example.maternalcare.dto;

import com.example.maternalcare.model.Appointment.AppointmentType;
import com.example.maternalcare.model.Appointment.AppointmentStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Email;

import java.time.LocalDateTime;

public class AppointmentDTO {
    
    private Long id;
    
    @NotBlank(message = "Mother NIC is required")
    private String motherNic;
    
    @NotBlank(message = "Mother name is required")
    private String motherName;
    
    @Email(message = "Valid email is required")
    @NotBlank(message = "Mother email is required")
    private String motherEmail;
    
    @NotNull(message = "Appointment type is required")
    private AppointmentType appointmentType;
    
    @NotBlank(message = "Provider name is required")
    private String providerName;
    
    private String providerId;
    
    @NotNull(message = "Appointment date is required")
    private LocalDateTime appointmentDate;
    
    @NotBlank(message = "Time slot is required")
    private String timeSlot;
    
    private AppointmentStatus status;
    private String notes;
    private String additionalProblems;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public AppointmentDTO() {}
    
    public AppointmentDTO(String motherNic, String motherName, String motherEmail, 
                         AppointmentType appointmentType, String providerName, 
                         LocalDateTime appointmentDate, String timeSlot) {
        this.motherNic = motherNic;
        this.motherName = motherName;
        this.motherEmail = motherEmail;
        this.appointmentType = appointmentType;
        this.providerName = providerName;
        this.appointmentDate = appointmentDate;
        this.timeSlot = timeSlot;
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
    
    public String getMotherEmail() {
        return motherEmail;
    }
    
    public void setMotherEmail(String motherEmail) {
        this.motherEmail = motherEmail;
    }
    
    public AppointmentType getAppointmentType() {
        return appointmentType;
    }
    
    public void setAppointmentType(AppointmentType appointmentType) {
        this.appointmentType = appointmentType;
    }
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public String getProviderId() {
        return providerId;
    }
    
    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }
    
    public LocalDateTime getAppointmentDate() {
        return appointmentDate;
    }
    
    public void setAppointmentDate(LocalDateTime appointmentDate) {
        this.appointmentDate = appointmentDate;
    }
    
    public String getTimeSlot() {
        return timeSlot;
    }
    
    public void setTimeSlot(String timeSlot) {
        this.timeSlot = timeSlot;
    }
    
    public AppointmentStatus getStatus() {
        return status;
    }
    
    public void setStatus(AppointmentStatus status) {
        this.status = status;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public String getAdditionalProblems() {
        return additionalProblems;
    }
    
    public void setAdditionalProblems(String additionalProblems) {
        this.additionalProblems = additionalProblems;
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
