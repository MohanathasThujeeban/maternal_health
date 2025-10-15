package com.example.maternalcare.services;

import com.example.maternalcare.dto.AppointmentDTO;
import com.example.maternalcare.model.Appointment;
import com.example.maternalcare.model.Appointment.AppointmentStatus;
import com.example.maternalcare.model.HealthcareProvider;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.UserRole;
import com.example.maternalcare.repository.AppointmentRepository;
import com.example.maternalcare.repository.HealthcareProviderRepository;
import com.example.maternalcare.repository.RegistrationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class AppointmentService {
    
    @Autowired
    private AppointmentRepository appointmentRepository;
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private RegistrationRepository registrationRepository;
    
    @Autowired
    private HealthcareProviderRepository healthcareProviderRepository;
    
    // Create a new appointment
    public AppointmentDTO createAppointment(AppointmentDTO appointmentDTO) {
        System.out.println("Creating appointment for: " + appointmentDTO.getMotherNic());
        System.out.println("Provider: " + appointmentDTO.getProviderName());
        System.out.println("Date: " + appointmentDTO.getAppointmentDate());
        System.out.println("Time: " + appointmentDTO.getTimeSlot());
        
        // Check if the mother already has a pending or confirmed appointment
        boolean hasPendingAppointment = appointmentRepository.existsByMotherNicAndStatusIn(
            appointmentDTO.getMotherNic(), 
            List.of(AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED)
        );
        
        if (hasPendingAppointment) {
            System.out.println("Mother already has a pending or confirmed appointment");
            throw new RuntimeException("You already have an active appointment. Please complete or cancel your existing appointment before booking a new one.");
        }
        
        // Check if the mother already has an appointment at the same time
        boolean hasConflict = appointmentRepository.existsByMotherNicAndAppointmentDateAndTimeSlotAndStatusNot(
            appointmentDTO.getMotherNic(), 
            appointmentDTO.getAppointmentDate(), 
            appointmentDTO.getTimeSlot(), 
            AppointmentStatus.CANCELLED
        );
        
        if (hasConflict) {
            System.out.println("Conflict detected for same time slot");
            throw new RuntimeException("You already have an appointment scheduled at this time");
        }

        // Check if the mother already has an appointment with this provider on the same date
        boolean hasProviderDateConflict = appointmentRepository.existsByMotherNicAndProviderAndDateAndStatusNot(
            appointmentDTO.getMotherNic(),
            appointmentDTO.getProviderName(),
            appointmentDTO.getAppointmentDate()
        );
        
        if (hasProviderDateConflict) {
            System.out.println("Mother already has an appointment with this provider on the same date");
            throw new RuntimeException("You already have an appointment with " + appointmentDTO.getProviderName() + " on this date. Only one appointment per day per provider is allowed.");
        }
        
        // Check if the provider slot is available
        Long conflictCount = appointmentRepository.countByProviderAndDateTimeSlot(
            appointmentDTO.getProviderName(), 
            appointmentDTO.getAppointmentDate(), 
            appointmentDTO.getTimeSlot()
        );
        
        if (conflictCount > 0) {
            System.out.println("Provider slot conflict detected");
            throw new RuntimeException("This time slot is already booked with the selected provider");
        }
        
        Appointment appointment = convertToEntity(appointmentDTO);
        appointment.setStatus(AppointmentStatus.PENDING);
        
        // Set providerId based on providerName if not already set
        if (appointment.getProviderId() == null || appointment.getProviderId().isEmpty()) {
            // Look up provider by name from the database
            List<HealthcareProvider> allProviders = healthcareProviderRepository.findByIsApprovedTrueAndIsActiveTrue();
            Optional<HealthcareProvider> provider = allProviders.stream()
                    .filter(p -> p.getFullName().equals(appointment.getProviderName()))
                    .findFirst();
            
            if (provider.isPresent()) {
                appointment.setProviderId(provider.get().getMedicalLicenseNumber());
                System.out.println("Set provider ID to " + provider.get().getMedicalLicenseNumber() + " for " + provider.get().getFullName());
            } else {
                // Fallback for backward compatibility or if provider not found
                System.out.println("Provider not found in database, using default IDs");
                if (appointment.getProviderName().startsWith("Dr.")) {
                    appointment.setProviderId("DOC001");
                } else if (appointment.getProviderName().startsWith("Mrs.")) {
                    appointment.setProviderId("MID001");
                }
            }
        }
        
        // Ensure timestamp fields are set
        if (appointment.getCreatedAt() == null) {
            appointment.setCreatedAt(LocalDateTime.now());
        }
        
        System.out.println("Saving appointment to database...");
        Appointment savedAppointment = appointmentRepository.save(appointment);
        System.out.println("Appointment saved with ID: " + savedAppointment.getId());
        
        // Send confirmation email - don't let email failure affect appointment creation
        try {
            sendAppointmentConfirmationEmail(savedAppointment);
            System.out.println("Confirmation email sent successfully to: " + savedAppointment.getMotherEmail());
        } catch (Exception e) {
            System.err.println("Failed to send confirmation email to " + savedAppointment.getMotherEmail() + ": " + e.getMessage());
            // Don't rethrow - appointment should still be created even if email fails
        }
        
        // Send notification email to healthcare provider
        try {
            sendProviderNotificationEmail(savedAppointment);
            System.out.println("Provider notification email sent successfully");
        } catch (Exception e) {
            System.err.println("Error sending notification email to provider: " + e.getMessage());
        }
        
        return convertToDTO(savedAppointment);
    }
    
    // Get all appointments
    public List<AppointmentDTO> getAllAppointments() {
        try {
            List<Appointment> appointments = appointmentRepository.findAll();
            return appointments.stream().map(this::convertToDTO).collect(Collectors.toList());
        } catch (Exception e) {
            System.err.println("Error getting all appointments: " + e.getMessage());
            throw new RuntimeException("Failed to get all appointments", e);
        }
    }
    
    // Get appointments by mother NIC
    public List<AppointmentDTO> getAppointmentsByMotherNic(String motherNic) {
        try {
            System.out.println("Service: Querying appointments for NIC: " + motherNic);
            List<Appointment> appointments = appointmentRepository.findByMotherNicOrderByAppointmentDateDesc(motherNic);
            System.out.println("Service: Found " + appointments.size() + " appointments in database");
            
            List<AppointmentDTO> result = appointments.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
            
            System.out.println("Service: Converted to " + result.size() + " DTOs");
            return result;
        } catch (Exception e) {
            System.err.println("Service error for NIC " + motherNic + ": " + e.getMessage());
            e.printStackTrace();
            throw e; // Re-throw to let controller handle it
        }
    }
    
    // Get appointments by mother NIC and status
    public List<AppointmentDTO> getAppointmentsByMotherNicAndStatus(String motherNic, AppointmentStatus status) {
        List<Appointment> appointments = appointmentRepository.findByMotherNicAndStatusOrderByAppointmentDateDesc(motherNic, status);
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    // Get appointments by provider
    public List<AppointmentDTO> getAppointmentsByProvider(String providerName) {
        List<Appointment> appointments = appointmentRepository.findByProviderNameOrderByAppointmentDateAsc(providerName);
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    // Get appointment by ID
    public Optional<AppointmentDTO> getAppointmentById(Long id) {
        Optional<Appointment> appointment = appointmentRepository.findById(id);
        return appointment.map(this::convertToDTO);
    }
    
    // Update appointment status
    public AppointmentDTO updateAppointmentStatus(Long id, AppointmentStatus status) {
        Optional<Appointment> appointmentOpt = appointmentRepository.findById(id);
        if (appointmentOpt.isEmpty()) {
            throw new RuntimeException("Appointment not found");
        }
        
        Appointment appointment = appointmentOpt.get();
        appointment.setStatus(status);
        
        Appointment updatedAppointment = appointmentRepository.save(appointment);
        
        // Send status update email
        try {
            sendAppointmentStatusUpdateEmail(updatedAppointment);
        } catch (Exception e) {
            System.err.println("Failed to send status update email: " + e.getMessage());
        }
        
        // Send status update notification to healthcare provider
        try {
            sendProviderStatusUpdateEmail(updatedAppointment);
        } catch (Exception e) {
            System.err.println("Failed to send provider status update email: " + e.getMessage());
        }
        
        return convertToDTO(updatedAppointment);
    }
    
    // Update appointment notes (for providers)
    public AppointmentDTO updateAppointmentNotes(Long id, String notes) {
        Optional<Appointment> appointmentOpt = appointmentRepository.findById(id);
        if (appointmentOpt.isEmpty()) {
            throw new RuntimeException("Appointment not found");
        }
        
        Appointment appointment = appointmentOpt.get();
        appointment.setNotes(notes);
        
        Appointment updatedAppointment = appointmentRepository.save(appointment);
        return convertToDTO(updatedAppointment);
    }
    
    // Cancel appointment
    public AppointmentDTO cancelAppointment(Long id) {
        // First get the appointment details before cancelling
        Optional<Appointment> appointmentOpt = appointmentRepository.findById(id);
        if (appointmentOpt.isEmpty()) {
            throw new RuntimeException("Appointment not found");
        }
        
        Appointment appointment = appointmentOpt.get();
        
        // Store appointment details for notification
        String providerName = appointment.getProviderName();
        String appointmentType = appointment.getAppointmentType().toString();
        LocalDateTime appointmentDate = appointment.getAppointmentDate();
        String timeSlot = appointment.getTimeSlot();
        String cancellingMotherNic = appointment.getMotherNic();
        
        // Cancel the appointment using the existing method
        AppointmentDTO cancelledAppointment = updateAppointmentStatus(id, AppointmentStatus.CANCELLED);
        
        // Send slot availability notifications to all other mothers
        try {
            notifyMothersOfAvailableSlot(providerName, appointmentType, appointmentDate, timeSlot, cancellingMotherNic);
        } catch (Exception e) {
            System.err.println("Failed to send slot availability notifications: " + e.getMessage());
            // Don't fail the cancellation if notification fails
        }
        
        return cancelledAppointment;
    }
    
    // Complete appointment
    public AppointmentDTO completeAppointment(Long id) {
        return updateAppointmentStatus(id, AppointmentStatus.COMPLETED);
    }
    
    // Get appointments for date range
    public List<AppointmentDTO> getAppointmentsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        List<Appointment> appointments = appointmentRepository.findByAppointmentDateBetweenOrderByAppointmentDateAsc(startDate, endDate);
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    // Get appointments by provider and date range
    public List<AppointmentDTO> getAppointmentsByProviderAndDateRange(String providerName, LocalDateTime startDate, LocalDateTime endDate) {
        List<Appointment> appointments = appointmentRepository.findByProviderAndDateRange(providerName, startDate, endDate);
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    // Private helper methods
    private Appointment convertToEntity(AppointmentDTO dto) {
        Appointment appointment = new Appointment();
        appointment.setId(dto.getId());
        appointment.setMotherNic(dto.getMotherNic());
        appointment.setMotherName(dto.getMotherName());
        appointment.setMotherEmail(dto.getMotherEmail());
        appointment.setAppointmentType(dto.getAppointmentType());
        appointment.setProviderName(dto.getProviderName());
        appointment.setProviderId(dto.getProviderId());
        appointment.setAppointmentDate(dto.getAppointmentDate());
        appointment.setTimeSlot(dto.getTimeSlot());
        appointment.setStatus(dto.getStatus());
        appointment.setNotes(dto.getNotes());
        appointment.setAdditionalProblems(dto.getAdditionalProblems());
        appointment.setCreatedAt(dto.getCreatedAt());
        appointment.setUpdatedAt(dto.getUpdatedAt());
        return appointment;
    }
    
    private AppointmentDTO convertToDTO(Appointment appointment) {
        AppointmentDTO dto = new AppointmentDTO();
        dto.setId(appointment.getId());
        dto.setMotherNic(appointment.getMotherNic());
        dto.setMotherName(appointment.getMotherName());
        dto.setMotherEmail(appointment.getMotherEmail());
        dto.setAppointmentType(appointment.getAppointmentType());
        dto.setProviderName(appointment.getProviderName());
        dto.setProviderId(appointment.getProviderId());
        dto.setAppointmentDate(appointment.getAppointmentDate());
        dto.setTimeSlot(appointment.getTimeSlot());
        dto.setStatus(appointment.getStatus());
        dto.setNotes(appointment.getNotes());
        dto.setAdditionalProblems(appointment.getAdditionalProblems());
        dto.setCreatedAt(appointment.getCreatedAt());
        dto.setUpdatedAt(appointment.getUpdatedAt());
        return dto;
    }
    
    private void sendAppointmentConfirmationEmail(Appointment appointment) {
        String appointmentType = appointment.getAppointmentType().toString().toLowerCase();
        appointmentType = appointmentType.substring(0, 1).toUpperCase() + appointmentType.substring(1);
        String subject = "✅ Appointment Confirmed! " + appointmentType + " Consultation with " + appointment.getProviderName();
        String body = buildConfirmationEmailBody(appointment);
        emailService.sendEmail(appointment.getMotherEmail(), subject, body);
    }
    
    private void sendAppointmentStatusUpdateEmail(Appointment appointment) {
        if (appointment.getStatus() == AppointmentStatus.COMPLETED) {
            // Send simple completion notification
            String subject = "🎉 Appointment Completed - Thank You for Visiting Us!";
            String body = buildCompletionEmailBody(appointment);
            emailService.sendEmail(appointment.getMotherEmail(), subject, body);
        } else {
            // Send regular status update email
            String statusEmoji = getStatusEmoji(appointment.getStatus().toString());
            String statusDisplay = appointment.getStatus().toString().toLowerCase();
            statusDisplay = statusDisplay.substring(0, 1).toUpperCase() + statusDisplay.substring(1);
            String subject = statusEmoji + " Appointment Update - Status Changed to " + statusDisplay;
            String body = buildStatusUpdateEmailBody(appointment);
            emailService.sendEmail(appointment.getMotherEmail(), subject, body);
        }
    }
    
    private String getStatusEmoji(String status) {
        switch (status.toLowerCase()) {
            case "confirmed": return "✅";
            case "completed": return "🎉";
            case "cancelled": return "❌";
            case "rescheduled": return "📅";
            case "pending": return "⏳";
            default: return "📋";
        }
    }
    
    // Send notification email to healthcare provider
    private void sendProviderNotificationEmail(Appointment appointment) {
        // Get provider email from the database
        String providerEmail = getProviderEmail(appointment.getProviderName(), appointment.getProviderId());
        
        if (providerEmail != null && !providerEmail.isEmpty()) {
            String appointmentType = appointment.getAppointmentType().toString().toLowerCase();
            appointmentType = appointmentType.substring(0, 1).toUpperCase() + appointmentType.substring(1);
            String subject = "🔔 New Appointment Scheduled - " + appointmentType + " Consultation";
            String body = buildProviderNotificationEmailBody(appointment);
            emailService.sendEmail(providerEmail, subject, body);
        } else {
            System.err.println("Provider email not found for: " + appointment.getProviderName());
        }
    }
    
    // Get provider email by name or ID
    private String getProviderEmail(String providerName, String providerId) {
        try {
            // First try to find by provider ID (medical license number)
            if (providerId != null && !providerId.isEmpty()) {
                Optional<HealthcareProvider> providerById = healthcareProviderRepository.findByMedicalLicenseNumber(providerId);
                if (providerById.isPresent()) {
                    return providerById.get().getEmail();
                }
            }
            
            // Fallback: search by name
            if (providerName != null && !providerName.isEmpty()) {
                List<HealthcareProvider> allProviders = healthcareProviderRepository.findByIsApprovedTrueAndIsActiveTrue();
                Optional<HealthcareProvider> providerByName = allProviders.stream()
                        .filter(p -> p.getFullName().equals(providerName))
                        .findFirst();
                if (providerByName.isPresent()) {
                    return providerByName.get().getEmail();
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching provider email: " + e.getMessage());
        }
        return null;
    }
    
    // Send status update notification to healthcare provider
    private void sendProviderStatusUpdateEmail(Appointment appointment) {
        // Get provider email from the database
        String providerEmail = getProviderEmail(appointment.getProviderName(), appointment.getProviderId());
        
        if (providerEmail != null && !providerEmail.isEmpty()) {
            String statusEmoji = getStatusEmoji(appointment.getStatus().toString());
            String statusDisplay = appointment.getStatus().toString().toLowerCase();
            statusDisplay = statusDisplay.substring(0, 1).toUpperCase() + statusDisplay.substring(1);
            String subject = statusEmoji + " Appointment Status Update - " + statusDisplay;
            String body = buildProviderStatusUpdateEmailBody(appointment);
            emailService.sendEmail(providerEmail, subject, body);
        } else {
            System.err.println("Provider email not found for status update: " + appointment.getProviderName());
        }
    }

    // Get today's appointments by provider ID
    public List<AppointmentDTO> getTodayAppointmentsByProvider(String providerId) {
        LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
        
        List<Appointment> appointments = appointmentRepository.findByProviderIdAndAppointmentDateBetweenOrderByAppointmentDateAsc(
            providerId, startOfDay, endOfDay);
        
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Get today's appointments by appointment type (doctor/midwife)
    public List<AppointmentDTO> getTodayAppointmentsByType(String appointmentType) {
        LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
        
        List<Appointment> appointments = appointmentRepository.findByAppointmentTypeAndAppointmentDateBetweenOrderByAppointmentDateAsc(
            appointmentType.toUpperCase(), startOfDay, endOfDay);
        
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Search appointments by NIC and provider
    public List<AppointmentDTO> searchAppointmentsByNicAndProvider(String providerId, String nic, String date) {
        List<Appointment> appointments;
        
        if (date != null && !date.isEmpty()) {
            // Search for specific date
            LocalDateTime startOfDay = LocalDateTime.parse(date + "T00:00:00");
            LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
            
            appointments = appointmentRepository.findByProviderIdAndMotherNicContainingAndAppointmentDateBetweenOrderByAppointmentDateAsc(
                providerId, nic, startOfDay, endOfDay);
        } else {
            // Search for today only
            LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
            LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
            
            appointments = appointmentRepository.findByProviderIdAndMotherNicContainingAndAppointmentDateBetweenOrderByAppointmentDateAsc(
                providerId, nic, startOfDay, endOfDay);
        }
        
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Get upcoming appointments by appointment type (after today)
    public List<AppointmentDTO> getUpcomingAppointmentsByType(String appointmentType) {
        LocalDateTime endOfToday = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59).withNano(999999999);
        
        List<Appointment> appointments = appointmentRepository.findByAppointmentTypeAndAppointmentDateAfterOrderByAppointmentDateAsc(
            appointmentType.toUpperCase(), endOfToday);
        
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Get upcoming appointments by provider (after today)
    public List<AppointmentDTO> getUpcomingAppointmentsByProvider(String providerId) {
        LocalDateTime endOfToday = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59).withNano(999999999);
        
        List<Appointment> appointments = appointmentRepository.findByProviderIdAndAppointmentDateAfterOrderByAppointmentDateAsc(
            providerId, endOfToday);
        
        return appointments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    private String buildConfirmationEmailBody(Appointment appointment) {
        String appointmentTypeDisplay = appointment.getAppointmentType().toString().toLowerCase();
        appointmentTypeDisplay = appointmentTypeDisplay.substring(0, 1).toUpperCase() + appointmentTypeDisplay.substring(1);
        
        String statusDisplay = appointment.getStatus().toString().toLowerCase();
        statusDisplay = statusDisplay.substring(0, 1).toUpperCase() + statusDisplay.substring(1);
        
        // Format date nicely
        String formattedDate = appointment.getAppointmentDate().toLocalDate().toString();
        
        return String.format("""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Appointment Confirmation</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                        padding: 20px;
                        min-height: 100vh;
                    }
                    .email-container {
                        max-width: 600px;
                        margin: 0 auto;
                        background: #ffffff;
                        border-radius: 20px;
                        box-shadow: 0 20px 40px rgba(0,0,0,0.15);
                        overflow: hidden;
                    }
                    .header {
                        background: linear-gradient(135deg, #4FC3A1 0%%, #3A9B7A 100%%);
                        color: white;
                        text-align: center;
                        padding: 40px 30px;
                        position: relative;
                    }
                    .header::before {
                        content: '';
                        position: absolute;
                        top: 0;
                        left: 0;
                        right: 0;
                        bottom: 0;
                        background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="20" cy="20" r="2" fill="rgba(255,255,255,0.1)"/><circle cx="80" cy="40" r="1.5" fill="rgba(255,255,255,0.1)"/><circle cx="40" cy="80" r="1" fill="rgba(255,255,255,0.1)"/></svg>');
                        opacity: 0.3;
                    }
                    .header-icon {
                        font-size: 3em;
                        margin-bottom: 15px;
                        display: block;
                    }
                    .header h1 {
                        font-size: 28px;
                        margin-bottom: 10px;
                        font-weight: 600;
                        position: relative;
                        z-index: 1;
                    }
                    .header p {
                        font-size: 16px;
                        opacity: 0.9;
                        position: relative;
                        z-index: 1;
                    }
                    .content {
                        padding: 40px 30px;
                    }
                    .greeting {
                        font-size: 20px;
                        color: #2c3e50;
                        margin-bottom: 25px;
                        font-weight: 600;
                    }
                    .success-message {
                        background: linear-gradient(135deg, #e8f5f2, #f0f9f6);
                        border: 2px solid #4FC3A1;
                        border-radius: 15px;
                        padding: 25px;
                        margin-bottom: 30px;
                        text-align: center;
                    }
                    .success-icon {
                        font-size: 2.5em;
                        color: #4FC3A1;
                        margin-bottom: 15px;
                        display: block;
                    }
                    .success-text {
                        font-size: 18px;
                        color: #2c5530;
                        font-weight: 600;
                        margin-bottom: 8px;
                    }
                    .success-subtext {
                        color: #5a6c57;
                        font-size: 14px;
                    }
                    .appointment-card {
                        background: linear-gradient(135deg, #f8f9ff, #fff);
                        border: 1px solid #e3e6f0;
                        border-radius: 15px;
                        padding: 30px;
                        margin: 25px 0;
                        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
                    }
                    .card-title {
                        font-size: 22px;
                        color: #2c3e50;
                        margin-bottom: 25px;
                        text-align: center;
                        font-weight: 600;
                        border-bottom: 2px solid #4FC3A1;
                        padding-bottom: 15px;
                    }
                    .details-grid {
                        display: grid;
                        gap: 20px;
                    }
                    .detail-item {
                        display: flex;
                        align-items: center;
                        padding: 15px;
                        background: #f8f9fa;
                        border-radius: 10px;
                        border-left: 4px solid #4FC3A1;
                    }
                    .detail-icon {
                        font-size: 1.5em;
                        margin-right: 15px;
                        color: #4FC3A1;
                        width: 30px;
                    }
                    .detail-content {
                        flex: 1;
                    }
                    .detail-label {
                        font-size: 12px;
                        color: #6c757d;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                        margin-bottom: 5px;
                        font-weight: 600;
                    }
                    .detail-value {
                        font-size: 16px;
                        color: #2c3e50;
                        font-weight: 600;
                    }
                    .status-badge {
                        display: inline-block;
                        padding: 8px 16px;
                        background: #e7f6f3;
                        color: #2c5530;
                        border-radius: 20px;
                        font-size: 14px;
                        font-weight: 600;
                        text-transform: capitalize;
                    }
                    .important-note {
                        background: linear-gradient(135deg, #fff5e6, #fef9f3);
                        border: 1px solid #f0b429;
                        border-radius: 12px;
                        padding: 20px;
                        margin: 25px 0;
                    }
                    .note-icon {
                        font-size: 1.5em;
                        color: #f0b429;
                        margin-bottom: 10px;
                        display: block;
                    }
                    .note-title {
                        font-size: 16px;
                        font-weight: 600;
                        color: #8b5a00;
                        margin-bottom: 10px;
                    }
                    .note-text {
                        color: #8b5a00;
                        line-height: 1.6;
                    }
                    .additional-notes {
                        background: #f8f9ff;
                        border: 1px solid #d6d9e5;
                        border-radius: 12px;
                        padding: 20px;
                        margin: 20px 0;
                    }
                    .footer {
                        background: #2c3e50;
                        color: #ecf0f1;
                        text-align: center;
                        padding: 30px;
                    }
                    .footer-title {
                        font-size: 18px;
                        font-weight: 600;
                        margin-bottom: 10px;
                    }
                    .footer-text {
                        font-size: 14px;
                        opacity: 0.8;
                        line-height: 1.6;
                    }
                    .heart-icon {
                        color: #e74c3c;
                        font-size: 1.2em;
                        margin: 0 5px;
                    }
                    @media (max-width: 600px) {
                        body { padding: 10px; }
                        .content, .header { padding: 30px 20px; }
                        .appointment-card { padding: 20px; }
                        .header h1 { font-size: 24px; }
                        .greeting { font-size: 18px; }
                    }
                </style>
            </head>
            <body>
                <div class="email-container">
                    <!-- Header -->
                    <div class="header">
                        <span class="header-icon">🏥</span>
                        <h1>Appointment Confirmed!</h1>
                        <p>Your healthcare journey continues with us</p>
                    </div>
            
                    <!-- Content -->
                    <div class="content">
                        <div class="greeting">Dear %s! 👋</div>
                        
                        <!-- Success Message -->
                        <div class="success-message">
                            <span class="success-icon">✅</span>
                            <div class="success-text">Appointment Successfully Scheduled!</div>
                            <div class="success-subtext">We're excited to see you and provide the best care for you and your baby</div>
                        </div>
            
                        <!-- Appointment Details Card -->
                        <div class="appointment-card">
                            <div class="card-title">📋 Appointment Details</div>
                            <div class="details-grid">
                                <div class="detail-item">
                                    <span class="detail-icon">👩‍⚕️</span>
                                    <div class="detail-content">
                                        <div class="detail-label">Healthcare Provider</div>
                                        <div class="detail-value">%s</div>
                                    </div>
                                </div>
                                
                                <div class="detail-item">
                                    <span class="detail-icon">🩺</span>
                                    <div class="detail-content">
                                        <div class="detail-label">Appointment Type</div>
                                        <div class="detail-value">%s Consultation</div>
                                    </div>
                                </div>
                                
                                <div class="detail-item">
                                    <span class="detail-icon">📅</span>
                                    <div class="detail-content">
                                        <div class="detail-label">Date</div>
                                        <div class="detail-value">%s</div>
                                    </div>
                                </div>
                                
                                <div class="detail-item">
                                    <span class="detail-icon">⏰</span>
                                    <div class="detail-content">
                                        <div class="detail-label">Time Slot</div>
                                        <div class="detail-value">%s</div>
                                    </div>
                                </div>
                                
                                <div class="detail-item">
                                    <span class="detail-icon">📊</span>
                                    <div class="detail-content">
                                        <div class="detail-label">Status</div>
                                        <div class="detail-value">
                                            <span class="status-badge">%s</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
            
                        %s
            
                        <!-- Important Note -->
                        <div class="important-note">
                            <span class="note-icon">⚠️</span>
                            <div class="note-title">Important Reminders</div>
                            <div class="note-text">
                                • Please arrive <strong>15 minutes before</strong> your scheduled time<br>
                                • Bring your medical records and any previous reports<br>
                                • If you need to cancel or reschedule, please contact us at least 24 hours in advance<br>
                                • Don't forget to bring your National ID and any insurance cards
                            </div>
                        </div>
                        
                        <div style="text-align: center; margin: 30px 0; padding: 25px; background: linear-gradient(135deg, #f0f8ff, #e6f3ff); border-radius: 15px; border: 1px solid #b3d9ff;">
                            <p style="font-size: 16px; color: #2c5aa0; margin-bottom: 10px; font-weight: 600;">
                                💙 Need Help or Have Questions? 💙
                            </p>
                            <p style="font-size: 14px; color: #4a69bd; line-height: 1.6;">
                                Our friendly support team is here to help!<br>
                                Open the Maternal Health app or contact your healthcare provider directly.
                            </p>
                        </div>
                    </div>
            
                    <!-- Footer -->
                    <div class="footer">
                        <div class="footer-title">
                            Maternal Health Care Team <span class="heart-icon">❤️</span>
                        </div>
                        <div class="footer-text">
                            Caring for you and your baby every step of the way.<br>
                            Your health and wellness are our top priority.
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """,
            appointment.getMotherName(),
            appointment.getProviderName(),
            appointmentTypeDisplay,
            formattedDate,
            appointment.getTimeSlot(),
            statusDisplay,
            appointment.getAdditionalProblems() != null && !appointment.getAdditionalProblems().isEmpty() 
                ? String.format("""
                    <div class="additional-notes">
                        <div style="font-weight: 600; color: #2c3e50; margin-bottom: 10px; font-size: 16px;">
                            📝 Additional Notes:
                        </div>
                        <div style="color: #5a6c68; line-height: 1.6; font-size: 14px;">
                            %s
                        </div>
                    </div>
                    """, appointment.getAdditionalProblems())
                : ""
        );
    }
    
    // Build email body for healthcare provider notification
    private String buildProviderNotificationEmailBody(Appointment appointment) {
        String appointmentTypeDisplay = appointment.getAppointmentType().toString().toLowerCase();
        appointmentTypeDisplay = appointmentTypeDisplay.substring(0, 1).toUpperCase() + appointmentTypeDisplay.substring(1);
        
        String statusDisplay = appointment.getStatus().toString().toLowerCase();
        statusDisplay = statusDisplay.substring(0, 1).toUpperCase() + statusDisplay.substring(1);
        
        // Format date nicely with better formatting
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, MMMM dd, yyyy");
        String formattedDate = appointment.getAppointmentDate().format(formatter);
        
        // Get provider type for personalized greeting
        String providerType = appointment.getProviderName().startsWith("Dr.") ? "Doctor" : "Midwife";
        String providerIcon = appointment.getProviderName().startsWith("Dr.") ? "👨‍⚕️" : "👩‍⚕️";
        
        return String.format("""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>New Appointment Alert - Maternal Health Care</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        line-height: 1.6;
                        color: #2c3e50;
                        background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                        padding: 20px;
                        min-height: 100vh;
                    }
                    .container {
                        max-width: 650px;
                        margin: 0 auto;
                        background: white;
                        border-radius: 20px;
                        box-shadow: 0 25px 50px rgba(0,0,0,0.15);
                        overflow: hidden;
                        position: relative;
                    }
                    .container::before {
                        content: '';
                        position: absolute;
                        top: 0;
                        left: 0;
                        right: 0;
                        height: 4px;
                        background: linear-gradient(90deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);
                    }
                    .header {
                        background: linear-gradient(135deg, #2c3e50 0%%, #3498db 100%%);
                        color: white;
                        text-align: center;
                        padding: 40px 30px;
                    }
                    .header-icon {
                        font-size: 3em;
                        margin-bottom: 15px;
                        text-shadow: 0 2px 4px rgba(0,0,0,0.3);
                    }
                    .header-title {
                        font-size: 28px;
                        font-weight: 700;
                        margin-bottom: 10px;
                        text-shadow: 0 2px 4px rgba(0,0,0,0.3);
                    }
                    .header-subtitle {
                        font-size: 16px;
                        opacity: 0.9;
                        font-weight: 300;
                    }
                    .content {
                        padding: 40px 30px;
                    }
                    .greeting {
                        font-size: 18px;
                        margin-bottom: 25px;
                        color: #2c3e50;
                    }
                    .appointment-details {
                        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
                        border: 1px solid #dee2e6;
                        border-radius: 15px;
                        padding: 25px;
                        margin: 25px 0;
                    }
                    .appointment-title {
                        font-size: 20px;
                        font-weight: 600;
                        color: #2c3e50;
                        margin-bottom: 20px;
                        text-align: center;
                    }
                    .appointment-row {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 12px 0;
                        border-bottom: 1px solid #e9ecef;
                    }
                    .appointment-row:last-child {
                        border-bottom: none;
                    }
                    .appointment-label {
                        font-weight: 600;
                        color: #495057;
                        font-size: 14px;
                    }
                    .appointment-value {
                        font-weight: 500;
                        color: #2c3e50;
                        text-align: right;
                        font-size: 14px;
                    }
                    .status-badge {
                        background: #28a745;
                        color: white;
                        padding: 6px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 600;
                        text-transform: uppercase;
                    }
                    .patient-info {
                        background: #e8f4fd;
                        border: 1px solid #bee5eb;
                        border-radius: 12px;
                        padding: 20px;
                        margin: 20px 0;
                    }
                    .patient-info-title {
                        font-size: 16px;
                        font-weight: 600;
                        color: #0c5460;
                        margin-bottom: 15px;
                        display: flex;
                        align-items: center;
                    }
                    .patient-info-title::before {
                        content: '👩‍⚕️';
                        margin-right: 10px;
                        font-size: 20px;
                    }
                    .important-note {
                        background: #fff3cd;
                        border: 1px solid #ffeaa7;
                        border-radius: 12px;
                        padding: 20px;
                        margin: 20px 0;
                    }
                    .note-icon {
                        font-size: 24px;
                        margin-right: 10px;
                    }
                    .note-title {
                        font-size: 16px;
                        font-weight: 600;
                        color: #856404;
                        margin-bottom: 10px;
                    }
                    .note-text {
                        color: #856404;
                        line-height: 1.6;
                        font-size: 14px;
                    }
                    .footer {
                        background: #2c3e50;
                        color: #ecf0f1;
                        text-align: center;
                        padding: 30px;
                    }
                    .footer-title {
                        font-size: 18px;
                        font-weight: 600;
                        margin-bottom: 10px;
                    }
                    .footer-text {
                        font-size: 14px;
                        opacity: 0.8;
                        line-height: 1.6;
                    }
                    .heart-icon {
                        color: #e74c3c;
                        font-size: 1.2em;
                        margin: 0 5px;
                    }
                    @media (max-width: 600px) {
                        body { padding: 10px; }
                        .content, .header { padding: 30px 20px; }
                        .appointment-row { flex-direction: column; align-items: flex-start; }
                        .appointment-value { margin-top: 5px; text-align: left; }
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <!-- Header -->
                    <div class="header">
                        <div class="header-icon">%s</div>
                        <div class="header-title">New Appointment Alert</div>
                        <div class="header-subtitle">A maternal health appointment has been scheduled with you</div>
                    </div>
            
                    <!-- Content -->
                    <div class="content">
                        <div class="greeting">
                            Dear %s,
                        </div>
                        <p style="margin-bottom: 20px; font-size: 16px; line-height: 1.6;">
                            🌟 You have a new <strong>%s</strong> appointment scheduled with a expectant mother. Please review the details below and prepare for the consultation:
                        </p>
                        
                        <div style="background: linear-gradient(135deg, #e3f2fd, #bbdefb); border: 1px solid #90caf9; border-radius: 12px; padding: 20px; margin: 20px 0; text-align: center;">
                            <div style="font-size: 18px; font-weight: 600; color: #1565c0; margin-bottom: 8px;">
                                🩺 %s Consultation Required
                            </div>
                            <div style="font-size: 14px; color: #1976d2;">
                                Please ensure you have all necessary medical equipment ready
                            </div>
                        </div>
            
                        <!-- Appointment Details -->
                        <div class="appointment-details">
                            <div class="appointment-title">📅 Appointment Information</div>
                            <div class="appointment-row">
                                <span class="appointment-label">📋 Type:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                            <div class="appointment-row">
                                <span class="appointment-label">📅 Date:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                            <div class="appointment-row">
                                <span class="appointment-label">⏰ Time:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                            <div class="appointment-row">
                                <span class="appointment-label">📊 Status:</span>
                                <span class="appointment-value"><span class="status-badge">%s</span></span>
                            </div>
                        </div>
            
                        <!-- Patient Information -->
                        <div class="patient-info">
                            <div class="patient-info-title">Patient Details</div>
                            <div class="appointment-row">
                                <span class="appointment-label">👤 Patient Name:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                        </div>
            
                        %s
            
                        <!-- Important Note -->
                        <div class="important-note">
                            <span class="note-icon">⚠️</span>
                            <div class="note-title">Provider Reminders</div>
                            <div class="note-text">
                                • Please prepare for the scheduled consultation<br>
                                • Review any previous patient records if available<br>
                                • The appointment is currently in <strong>%s</strong> status<br>
                                • Contact the clinic if you need to reschedule or have any questions
                            </div>
                        </div>
                        
                        <div style="text-align: center; margin: 30px 0; padding: 25px; background: linear-gradient(135deg, #e8f5e8, #d4edda); border-radius: 15px; border: 1px solid #c3e6cb;">
                            <p style="font-size: 16px; color: #155724; margin-bottom: 10px; font-weight: 600;">
                                💼 Healthcare Provider Portal 💼
                            </p>
                            <p style="font-size: 14px; color: #155724; line-height: 1.6;">
                                Access your provider dashboard for more appointment details<br>
                                and patient management tools.
                            </p>
                        </div>
                    </div>
            
                    <!-- Footer -->
                    <div class="footer">
                        <div class="footer-title">
                            Maternal Health Care System <span class="heart-icon">❤️</span>
                        </div>
                        <div class="footer-text">
                            Supporting healthcare providers in delivering excellent care.<br>
                            Your dedication makes a difference in every patient's journey.
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """,
            providerIcon,  // Header icon
            appointment.getProviderName(),  // Greeting
            appointmentTypeDisplay,  // First mention of appointment type
            providerType,  // Provider type in consultation required
            appointmentTypeDisplay,  // Appointment type in details
            formattedDate,
            appointment.getTimeSlot(),
            statusDisplay,
            appointment.getMotherName(),
            appointment.getAdditionalProblems() != null && !appointment.getAdditionalProblems().isEmpty() 
                ? String.format("""
                    <div class="patient-info">
                        <div class="patient-info-title">📝 Additional Notes from Patient</div>
                        <div style="color: #0c5460; line-height: 1.6; font-size: 14px; margin-top: 10px;">
                            %s
                        </div>
                    </div>
                    """, appointment.getAdditionalProblems())
                : "",
            statusDisplay
        );
    }
    
    // Build email body for provider status update notification
    private String buildProviderStatusUpdateEmailBody(Appointment appointment) {
        String appointmentTypeDisplay = appointment.getAppointmentType().toString().toLowerCase();
        appointmentTypeDisplay = appointmentTypeDisplay.substring(0, 1).toUpperCase() + appointmentTypeDisplay.substring(1);
        
        String statusDisplay = appointment.getStatus().toString().toLowerCase();
        statusDisplay = statusDisplay.substring(0, 1).toUpperCase() + statusDisplay.substring(1);
        
        String statusIcon = getStatusIcon(appointment.getStatus().toString());
        String statusColor = getStatusColor(appointment.getStatus().toString());
        
        // Format date nicely with better formatting
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, MMMM dd, yyyy");
        String formattedDate = appointment.getAppointmentDate().format(formatter);
        
        // Get provider type for personalized content
        String providerIcon = appointment.getProviderName().startsWith("Dr.") ? "👨‍⚕️" : "👩‍⚕️";
        
        return String.format("""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Appointment Status Update</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        line-height: 1.6;
                        color: #2c3e50;
                        background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                        padding: 20px;
                    }
                    .container {
                        max-width: 600px;
                        margin: 0 auto;
                        background: white;
                        border-radius: 20px;
                        box-shadow: 0 20px 40px rgba(0,0,0,0.1);
                        overflow: hidden;
                    }
                    .header {
                        background: %s;
                        color: white;
                        text-align: center;
                        padding: 40px 30px;
                    }
                    .header-icon {
                        font-size: 3em;
                        margin-bottom: 15px;
                        text-shadow: 0 2px 4px rgba(0,0,0,0.3);
                    }
                    .header-title {
                        font-size: 28px;
                        font-weight: 700;
                        margin-bottom: 10px;
                        text-shadow: 0 2px 4px rgba(0,0,0,0.3);
                    }
                    .header-subtitle {
                        font-size: 16px;
                        opacity: 0.9;
                        font-weight: 300;
                    }
                    .content {
                        padding: 40px 30px;
                    }
                    .greeting {
                        font-size: 18px;
                        margin-bottom: 25px;
                        color: #2c3e50;
                    }
                    .status-highlight {
                        background: %s;
                        color: white;
                        text-align: center;
                        padding: 20px;
                        border-radius: 15px;
                        margin: 20px 0;
                        font-size: 18px;
                        font-weight: 600;
                    }
                    .appointment-details {
                        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
                        border: 1px solid #dee2e6;
                        border-radius: 15px;
                        padding: 25px;
                        margin: 25px 0;
                    }
                    .appointment-title {
                        font-size: 20px;
                        font-weight: 600;
                        color: #2c3e50;
                        margin-bottom: 20px;
                        text-align: center;
                    }
                    .appointment-row {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 12px 0;
                        border-bottom: 1px solid #e9ecef;
                    }
                    .appointment-row:last-child {
                        border-bottom: none;
                    }
                    .appointment-label {
                        font-weight: 600;
                        color: #495057;
                        font-size: 14px;
                    }
                    .appointment-value {
                        font-weight: 500;
                        color: #2c3e50;
                        text-align: right;
                        font-size: 14px;
                    }
                    .footer {
                        background: #2c3e50;
                        color: #ecf0f1;
                        text-align: center;
                        padding: 30px;
                    }
                    .footer-title {
                        font-size: 18px;
                        font-weight: 600;
                        margin-bottom: 10px;
                    }
                    .footer-text {
                        font-size: 14px;
                        opacity: 0.8;
                        line-height: 1.6;
                    }
                    .heart-icon {
                        color: #e74c3c;
                        font-size: 1.2em;
                        margin: 0 5px;
                    }
                    @media (max-width: 600px) {
                        body { padding: 10px; }
                        .content, .header { padding: 30px 20px; }
                        .appointment-row { flex-direction: column; align-items: flex-start; }
                        .appointment-value { margin-top: 5px; text-align: left; }
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <!-- Header -->
                    <div class="header">
                        <div class="header-icon">%s %s</div>
                        <div class="header-title">Appointment Status Update</div>
                        <div class="header-subtitle">Status has been updated for your maternal care appointment</div>
                    </div>
            
                    <!-- Content -->
                    <div class="content">
                        <div class="greeting">
                            Dear %s,
                        </div>
                        
                        <div class="status-highlight">
                            %s Appointment Status: %s
                        </div>
                        
                        <p style="margin-bottom: 20px; font-size: 16px; line-height: 1.6;">
                            The status of your appointment with <strong>%s</strong> has been updated.
                        </p>
            
                        <!-- Appointment Details -->
                        <div class="appointment-details">
                            <div class="appointment-title">📅 Appointment Information</div>
                            <div class="appointment-row">
                                <span class="appointment-label">📋 Type:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                            <div class="appointment-row">
                                <span class="appointment-label">📅 Date:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                            <div class="appointment-row">
                                <span class="appointment-label">⏰ Time:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                            <div class="appointment-row">
                                <span class="appointment-label">👤 Patient:</span>
                                <span class="appointment-value"><strong>%s</strong></span>
                            </div>
                        </div>
                        
                        <div style="text-align: center; margin: 30px 0; padding: 25px; background: linear-gradient(135deg, #e8f5e8, #d4edda); border-radius: 15px; border: 1px solid #c3e6cb;">
                            <p style="font-size: 16px; color: #155724; margin-bottom: 10px; font-weight: 600;">
                                💼 Provider Dashboard 💼
                            </p>
                            <p style="font-size: 14px; color: #155724; line-height: 1.6;">
                                Access your dashboard to manage appointments<br>
                                and view patient information.
                            </p>
                        </div>
                    </div>
            
                    <!-- Footer -->
                    <div class="footer">
                        <div class="footer-title">
                            Maternal Health Care System <span class="heart-icon">❤️</span>
                        </div>
                        <div class="footer-text">
                            Keeping healthcare providers informed and connected.<br>
                            Your dedication to patient care is appreciated.
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """,
            statusColor,  // Header background color
            statusColor,  // Status highlight background color
            providerIcon,  // Provider icon in header
            statusIcon,  // Status icon in header
            appointment.getProviderName(),  // Greeting
            statusIcon,  // Status icon in highlight
            statusDisplay,  // Status display in highlight
            appointment.getMotherName(),  // Patient name in text
            appointmentTypeDisplay,  // Appointment type in details
            formattedDate,  // Formatted date
            appointment.getTimeSlot(),  // Time slot
            appointment.getMotherName()  // Patient name in details
        );
    }
    
    private String buildStatusUpdateEmailBody(Appointment appointment) {
        String appointmentTypeDisplay = appointment.getAppointmentType().toString().toLowerCase();
        appointmentTypeDisplay = appointmentTypeDisplay.substring(0, 1).toUpperCase() + appointmentTypeDisplay.substring(1);
        
        String statusDisplay = appointment.getStatus().toString().toLowerCase();
        statusDisplay = statusDisplay.substring(0, 1).toUpperCase() + statusDisplay.substring(1);
        
        String statusIcon = getStatusIcon(appointment.getStatus().toString());
        String statusColor = getStatusColor(appointment.getStatus().toString());
        
        return String.format("""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Appointment Status Update</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                        padding: 20px;
                        min-height: 100vh;
                    }
                    .email-container {
                        max-width: 600px;
                        margin: 0 auto;
                        background: #ffffff;
                        border-radius: 20px;
                        box-shadow: 0 20px 40px rgba(0,0,0,0.15);
                        overflow: hidden;
                    }
                    .header {
                        background: linear-gradient(135deg, %s 0%%, %s 100%%);
                        color: white;
                        text-align: center;
                        padding: 40px 30px;
                    }
                    .header-icon {
                        font-size: 3em;
                        margin-bottom: 15px;
                        display: block;
                    }
                    .header h1 {
                        font-size: 28px;
                        margin-bottom: 10px;
                        font-weight: 600;
                    }
                    .content {
                        padding: 40px 30px;
                    }
                    .greeting {
                        font-size: 20px;
                        color: #2c3e50;
                        margin-bottom: 25px;
                        font-weight: 600;
                    }
                    .status-update {
                        background: linear-gradient(135deg, #f8f9ff, #fff);
                        border: 2px solid %s;
                        border-radius: 15px;
                        padding: 25px;
                        margin-bottom: 30px;
                        text-align: center;
                    }
                    .status-icon {
                        font-size: 2.5em;
                        color: %s;
                        margin-bottom: 15px;
                        display: block;
                    }
                    .appointment-card {
                        background: #f8f9fa;
                        border: 1px solid #e9ecef;
                        border-radius: 15px;
                        padding: 30px;
                        margin: 25px 0;
                    }
                    .card-title {
                        font-size: 22px;
                        color: #2c3e50;
                        margin-bottom: 25px;
                        text-align: center;
                        font-weight: 600;
                        border-bottom: 2px solid %s;
                        padding-bottom: 15px;
                    }
                    .detail-item {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 12px 0;
                        border-bottom: 1px solid #e9ecef;
                    }
                    .detail-label {
                        font-weight: 600;
                        color: #495057;
                    }
                    .detail-value {
                        color: #2c3e50;
                        font-weight: 500;
                    }
                    .status-badge {
                        background: %s;
                        color: white;
                        padding: 8px 16px;
                        border-radius: 20px;
                        font-size: 14px;
                        font-weight: 600;
                    }
                    .provider-notes {
                        background: #e8f4fd;
                        border: 1px solid #bee5eb;
                        border-radius: 12px;
                        padding: 20px;
                        margin: 20px 0;
                    }
                    .footer {
                        background: #2c3e50;
                        color: #ecf0f1;
                        text-align: center;
                        padding: 30px;
                    }
                </style>
            </head>
            <body>
                <div class="email-container">
                    <div class="header">
                        <span class="header-icon">%s</span>
                        <h1>Appointment Update</h1>
                        <p>Your appointment status has been updated</p>
                    </div>
            
                    <div class="content">
                        <div class="greeting">Dear %s,</div>
                        
                        <div class="status-update">
                            <span class="status-icon">%s</span>
                            <div style="font-size: 18px; font-weight: 600; color: #2c3e50; margin-bottom: 8px;">
                                Appointment Status Updated
                            </div>
                            <div style="color: #6c757d;">
                                Your appointment status is now: <span class="status-badge">%s</span>
                            </div>
                        </div>
            
                        <div class="appointment-card">
                            <div class="card-title">📋 Appointment Details</div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Healthcare Provider:</span>
                                <span class="detail-value">%s</span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Appointment Type:</span>
                                <span class="detail-value">%s Consultation</span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Date:</span>
                                <span class="detail-value">%s</span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Time:</span>
                                <span class="detail-value">%s</span>
                            </div>
                            
                            <div class="detail-item" style="border-bottom: none;">
                                <span class="detail-label">Status:</span>
                                <span class="status-badge">%s</span>
                            </div>
                        </div>
            
                        %s
                        
                        <div style="text-align: center; margin: 30px 0; padding: 20px; background: #f8f9fa; border-radius: 10px;">
                            <p style="color: #495057; font-size: 16px; line-height: 1.6;">
                                Thank you for choosing our maternal health care services.<br>
                                We're committed to providing you and your baby the best care possible.
                            </p>
                        </div>
                    </div>
            
                    <div class="footer">
                        <div style="font-size: 18px; font-weight: 600; margin-bottom: 10px;">
                            Maternal Health Care Team ❤️
                        </div>
                        <div style="font-size: 14px; opacity: 0.8;">
                            Your health and wellness are our priority
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """,
            statusColor, statusColor, // header gradient colors
            statusColor, statusColor, // status update colors
            statusColor, statusColor, // card and badge colors
            statusIcon, // header icon
            appointment.getMotherName(),
            statusIcon, // status icon
            statusDisplay, // status text
            appointment.getProviderName(),
            appointmentTypeDisplay,
            appointment.getAppointmentDate().toLocalDate(),
            appointment.getTimeSlot(),
            statusDisplay,
            appointment.getNotes() != null && !appointment.getNotes().isEmpty() 
                ? String.format("""
                    <div class="provider-notes">
                        <div style="font-weight: 600; color: #2c3e50; margin-bottom: 10px; font-size: 16px;">
                            💬 Provider Notes:
                        </div>
                        <div style="color: #495057; line-height: 1.6;">
                            %s
                        </div>
                    </div>
                    """, appointment.getNotes())
                : ""
        );
    }
    
    private String getStatusIcon(String status) {
        switch (status.toLowerCase()) {
            case "confirmed": return "✅";
            case "completed": return "🎉";
            case "cancelled": return "❌";
            case "rescheduled": return "📅";
            case "pending": return "⏳";
            default: return "📋";
        }
    }
    
    private String getStatusColor(String status) {
        switch (status.toLowerCase()) {
            case "confirmed": return "#28a745";
            case "completed": return "#4FC3A1";
            case "cancelled": return "#dc3545";
            case "rescheduled": return "#ffc107";
            case "pending": return "#6c757d";
            default: return "#4FC3A1";
        }
    }
    
    // Get provider statistics
    public Map<String, Object> getProviderStatistics(String providerId) {
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // Get current date and time boundaries
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime startOfMonth = now.withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
            LocalDateTime endOfMonth = startOfMonth.plusMonths(1).minusSeconds(1);
            LocalDateTime startOfToday = now.withHour(0).withMinute(0).withSecond(0);
            LocalDateTime endOfToday = now.withHour(23).withMinute(59).withSecond(59);
            
            // Count pending review (upcoming appointments)
            long pendingReviewCount = appointmentRepository.findByProviderIdAndAppointmentDateAfterOrderByAppointmentDateAsc(
                providerId, endOfToday).size();
            
            // Count this month appointments (all appointments scheduled this month)
            long thisMonthCount = appointmentRepository.countByProviderIdAndAppointmentDateBetween(
                providerId, startOfMonth, endOfMonth);
            
            // Count today's patients (appointments scheduled for today)
            long todaysPatientsCount = appointmentRepository.countByProviderIdAndAppointmentDateBetween(
                providerId, startOfToday, endOfToday);
            
            // Count emergency cases (for now, set to a simple calculation - can be enhanced later)
            // This could be appointments that were created today (same-day bookings) as emergency cases
            long emergencyCasesCount = Math.min(todaysPatientsCount / 6, 3); // Simple calculation for demo
            
            stats.put("pendingReview", pendingReviewCount);
            stats.put("thisMonth", thisMonthCount);
            stats.put("todaysPatients", todaysPatientsCount);
            stats.put("emergencyCases", emergencyCasesCount);
            stats.put("success", true);
            
        } catch (Exception e) {
            stats.put("pendingReview", 0);
            stats.put("thisMonth", 0);
            stats.put("todaysPatients", 0);
            stats.put("emergencyCases", 0);
            stats.put("success", false);
            stats.put("error", e.getMessage());
        }
        
        return stats;
    }
    
    private String buildCompletionEmailBody(Appointment appointment) {
        String appointmentTypeDisplay = appointment.getAppointmentType().toString().toLowerCase();
        appointmentTypeDisplay = appointmentTypeDisplay.substring(0, 1).toUpperCase() + appointmentTypeDisplay.substring(1);
        
        return String.format("""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Appointment Completed</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
                        padding: 20px;
                        min-height: 100vh;
                    }
                    .email-container {
                        max-width: 600px;
                        margin: 0 auto;
                        background: #ffffff;
                        border-radius: 20px;
                        box-shadow: 0 20px 40px rgba(0,0,0,0.15);
                        overflow: hidden;
                    }
                    .header {
                        background: linear-gradient(135deg, #4FC3A1 0%%, #3A9B7A 100%%);
                        color: white;
                        text-align: center;
                        padding: 40px 30px;
                        position: relative;
                    }
                    .header::before {
                        content: '';
                        position: absolute;
                        top: 0;
                        left: 0;
                        right: 0;
                        bottom: 0;
                        background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="20" cy="20" r="2" fill="rgba(255,255,255,0.1)"/><circle cx="80" cy="40" r="1.5" fill="rgba(255,255,255,0.1)"/><circle cx="40" cy="80" r="1" fill="rgba(255,255,255,0.1)"/></svg>');
                        opacity: 0.3;
                    }
                    .header-icon {
                        font-size: 3em;
                        margin-bottom: 15px;
                        display: block;
                        animation: bounce 2s infinite;
                    }
                    @keyframes bounce {
                        0%%, 20%%, 50%%, 80%%, 100%% { transform: translateY(0); }
                        40%% { transform: translateY(-10px); }
                        60%% { transform: translateY(-5px); }
                    }
                    .header h1 {
                        font-size: 28px;
                        margin-bottom: 10px;
                        font-weight: 600;
                        position: relative;
                        z-index: 1;
                    }
                    .header p {
                        font-size: 16px;
                        opacity: 0.9;
                        position: relative;
                        z-index: 1;
                    }
                    .content {
                        padding: 40px 30px;
                    }
                    .greeting {
                        font-size: 20px;
                        color: #2c3e50;
                        margin-bottom: 25px;
                        font-weight: 600;
                    }
                    .completion-message {
                        background: linear-gradient(135deg, #e8f5f2, #f0f9f6);
                        border: 2px solid #4FC3A1;
                        border-radius: 15px;
                        padding: 30px;
                        margin-bottom: 30px;
                        text-align: center;
                    }
                    .completion-icon {
                        font-size: 3em;
                        color: #4FC3A1;
                        margin-bottom: 15px;
                        display: block;
                        animation: pulse 2s infinite;
                    }
                    @keyframes pulse {
                        0%% { transform: scale(1); }
                        50%% { transform: scale(1.1); }
                        100%% { transform: scale(1); }
                    }
                    .completion-text {
                        font-size: 22px;
                        color: #2c5530;
                        font-weight: 600;
                        margin-bottom: 10px;
                    }
                    .completion-subtext {
                        color: #5a6c57;
                        font-size: 16px;
                        line-height: 1.6;
                    }
                    .appointment-summary {
                        background: linear-gradient(135deg, #f8f9ff, #fff);
                        border: 1px solid #e3e6f0;
                        border-radius: 15px;
                        padding: 30px;
                        margin: 25px 0;
                        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
                    }
                    .summary-title {
                        font-size: 20px;
                        color: #2c3e50;
                        margin-bottom: 20px;
                        text-align: center;
                        font-weight: 600;
                        border-bottom: 2px solid #4FC3A1;
                        padding-bottom: 10px;
                    }
                    .summary-item {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 12px 0;
                        border-bottom: 1px solid #f1f3f4;
                    }
                    .summary-item:last-child {
                        border-bottom: none;
                    }
                    .summary-label {
                        font-weight: 600;
                        color: #495057;
                    }
                    .summary-value {
                        color: #2c3e50;
                        font-weight: 500;
                    }
                    .provider-notes {
                        background: linear-gradient(135deg, #fff5e6, #fef9f3);
                        border: 1px solid #f0b429;
                        border-radius: 12px;
                        padding: 25px;
                        margin: 25px 0;
                    }
                    .notes-title {
                        font-size: 18px;
                        font-weight: 600;
                        color: #8b5a00;
                        margin-bottom: 15px;
                        display: flex;
                        align-items: center;
                    }
                    .notes-icon {
                        font-size: 1.5em;
                        margin-right: 10px;
                    }
                    .notes-content {
                        color: #8b5a00;
                        line-height: 1.8;
                        font-size: 15px;
                    }
                    .thank-you {
                        background: linear-gradient(135deg, #f0f8ff, #e6f3ff);
                        border: 1px solid #b3d9ff;
                        border-radius: 15px;
                        padding: 30px;
                        margin: 30px 0;
                        text-align: center;
                    }
                    .thank-you-icon {
                        font-size: 2.5em;
                        color: #4a69bd;
                        margin-bottom: 15px;
                        display: block;
                    }
                    .thank-you-text {
                        font-size: 18px;
                        color: #2c5aa0;
                        font-weight: 600;
                        margin-bottom: 10px;
                    }
                    .thank-you-subtext {
                        color: #4a69bd;
                        line-height: 1.6;
                        font-size: 15px;
                    }
                    .next-steps {
                        background: #f8f9fa;
                        border: 1px solid #dee2e6;
                        border-radius: 12px;
                        padding: 25px;
                        margin: 25px 0;
                    }
                    .next-steps-title {
                        font-size: 18px;
                        font-weight: 600;
                        color: #2c3e50;
                        margin-bottom: 15px;
                    }
                    .next-steps-list {
                        list-style: none;
                        padding: 0;
                    }
                    .next-steps-list li {
                        color: #495057;
                        margin-bottom: 10px;
                        padding-left: 25px;
                        position: relative;
                        line-height: 1.6;
                    }
                    .next-steps-list li::before {
                        content: '✓';
                        position: absolute;
                        left: 0;
                        color: #4FC3A1;
                        font-weight: bold;
                    }
                    .footer {
                        background: linear-gradient(135deg, #2c3e50, #34495e);
                        color: #ecf0f1;
                        text-align: center;
                        padding: 35px 30px;
                    }
                    .footer-title {
                        font-size: 20px;
                        font-weight: 600;
                        margin-bottom: 15px;
                    }
                    .footer-text {
                        font-size: 15px;
                        opacity: 0.9;
                        line-height: 1.8;
                    }
                    .heart-icon {
                        color: #e74c3c;
                        font-size: 1.2em;
                        margin: 0 5px;
                        animation: heartbeat 1.5s ease-in-out infinite;
                    }
                    @keyframes heartbeat {
                        0%% { transform: scale(1); }
                        14%% { transform: scale(1.1); }
                        28%% { transform: scale(1); }
                        42%% { transform: scale(1.1); }
                        70%% { transform: scale(1); }
                    }
                    @media (max-width: 600px) {
                        body { padding: 10px; }
                        .content, .header { padding: 30px 20px; }
                        .appointment-summary, .completion-message { padding: 20px; }
                        .header h1 { font-size: 24px; }
                        .greeting { font-size: 18px; }
                    }
                </style>
            </head>
            <body>
                <div class="email-container">
                    <!-- Header -->
                    <div class="header">
                        <span class="header-icon">🎉</span>
                        <h1>Appointment Completed!</h1>
                        <p>Thank you for visiting us today</p>
                    </div>
            
                    <!-- Content -->
                    <div class="content">
                        <div class="greeting">Dear %s! 👋</div>
                        
                        <!-- Completion Message -->
                        <div class="completion-message">
                            <span class="completion-icon">✨</span>
                            <div class="completion-text">Your appointment has been completed successfully!</div>
                            <div class="completion-subtext">
                                We hope you had a positive and informative experience with our healthcare team today.
                            </div>
                        </div>
            
                        <!-- Appointment Summary -->
                        <div class="appointment-summary">
                            <div class="summary-title">📋 Appointment Summary</div>
                            
                            <div class="summary-item">
                                <span class="summary-label">Healthcare Provider:</span>
                                <span class="summary-value">%s</span>
                            </div>
                            
                            <div class="summary-item">
                                <span class="summary-label">Consultation Type:</span>
                                <span class="summary-value">%s Consultation</span>
                            </div>
                            
                            <div class="summary-item">
                                <span class="summary-label">Date:</span>
                                <span class="summary-value">%s</span>
                            </div>
                            
                            <div class="summary-item">
                                <span class="summary-label">Time:</span>
                                <span class="summary-value">%s</span>
                            </div>
                        </div>
            
                        %s
            
                        <!-- Thank You Message -->
                        <div class="thank-you">
                            <span class="thank-you-icon">💙</span>
                            <div class="thank-you-text">Thank You for Choosing Us!</div>
                            <div class="thank-you-subtext">
                                Your trust in our maternal healthcare services means everything to us.<br>
                                We're honored to be part of your healthcare journey.
                            </div>
                        </div>
            
                        <!-- Next Steps -->
                        <div class="next-steps">
                            <div class="next-steps-title">🚀 What's Next?</div>
                            <ul class="next-steps-list">
                                <li>Keep track of your health using our mobile app</li>
                                <li>Follow any specific instructions provided by your healthcare provider</li>
                                <li>Schedule your next appointment if recommended</li>
                                <li>Contact us if you have any questions or concerns</li>
                                <li>Continue monitoring your and your baby's health regularly</li>
                            </ul>
                        </div>
                        
                        <div style="text-align: center; margin: 30px 0; padding: 25px; background: linear-gradient(135deg, #f0f8ff, #e6f3ff); border-radius: 15px; border: 1px solid #b3d9ff;">
                            <p style="font-size: 16px; color: #2c5aa0; margin-bottom: 10px; font-weight: 600;">
                                💬 Need Support or Have Questions? 💬
                            </p>
                            <p style="font-size: 14px; color: #4a69bd; line-height: 1.6;">
                                Our care team is always here to help you!<br>
                                Don't hesitate to reach out through our app or contact your provider directly.
                            </p>
                        </div>
                    </div>
            
                    <!-- Footer -->
                    <div class="footer">
                        <div class="footer-title">
                            Maternal Health Care Team <span class="heart-icon">❤️</span>
                        </div>
                        <div class="footer-text">
                            Dedicated to your health and happiness every step of the way.<br>
                            Thank you for allowing us to care for you and your precious baby.
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """,
            appointment.getMotherName(),
            appointment.getProviderName(),
            appointmentTypeDisplay,
            appointment.getAppointmentDate().toLocalDate(),
            appointment.getTimeSlot(),
            appointment.getNotes() != null && !appointment.getNotes().isEmpty() 
                ? String.format("""
                    <div class="provider-notes">
                        <div class="notes-title">
                            <span class="notes-icon">💬</span>
                            Provider Notes & Recommendations:
                        </div>
                        <div class="notes-content">
                            %s
                        </div>
                    </div>
                    """, appointment.getNotes())
                : ""
        );
    }
    
    // Check if mother has any pending appointments
    public Map<String, Object> checkPendingAppointments(String motherNic) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            boolean hasPendingAppointment = appointmentRepository.existsByMotherNicAndStatusIn(
                motherNic, 
                List.of(AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED)
            );
            
            result.put("success", true);
            result.put("hasPendingAppointment", hasPendingAppointment);
            
            if (hasPendingAppointment) {
                // Get the pending appointment details
                List<Appointment> pendingAppointments = appointmentRepository.findByMotherNicAndStatusOrderByAppointmentDateDesc(
                    motherNic, AppointmentStatus.PENDING
                );
                
                if (pendingAppointments.isEmpty()) {
                    // Check for confirmed appointments
                    pendingAppointments = appointmentRepository.findByMotherNicAndStatusOrderByAppointmentDateDesc(
                        motherNic, AppointmentStatus.CONFIRMED
                    );
                }
                
                if (!pendingAppointments.isEmpty()) {
                    Appointment pendingAppointment = pendingAppointments.get(0);
                    AppointmentDTO pendingDto = convertToDTO(pendingAppointment);
                    result.put("pendingAppointment", pendingDto);
                    result.put("message", "You have an active appointment on " + 
                        pendingAppointment.getAppointmentDate().toLocalDate() + 
                        " at " + pendingAppointment.getTimeSlot() + 
                        " with " + pendingAppointment.getProviderName());
                } else {
                    result.put("message", "You have an active appointment. Please complete or cancel it before booking a new one.");
                }
            } else {
                result.put("message", "No pending appointments found. You can book a new appointment.");
            }
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Error checking pending appointments: " + e.getMessage());
            result.put("hasPendingAppointment", false);
        }
        
        return result;
    }

    /**
     * Notify all mothers (except the one who cancelled) about an available appointment slot
     */
    private void notifyMothersOfAvailableSlot(String providerName, String appointmentType, 
                                            LocalDateTime appointmentDate, String timeSlot, 
                                            String excludeMotherNic) {
        try {
            // Get all active mothers from registration
            List<Registration> allMothers = registrationRepository.findByUserRole(UserRole.MOTHER);
            
            // Filter active mothers (excluding the one who cancelled)
            List<Registration> activeMothers = allMothers.stream()
                .filter(mother -> mother.getIsActive() != null && mother.getIsActive())
                .filter(mother -> !mother.getNicNumber().equals(excludeMotherNic))
                .collect(Collectors.toList());
            
            if (activeMothers.isEmpty()) {
                System.out.println("No active mothers found to notify about available slot");
                return;
            }
            
            // Format the appointment date for display
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMMM dd, yyyy");
            String formattedDate = appointmentDate.format(dateFormatter);
            
            System.out.printf("Notifying %d mothers about available slot: %s with %s on %s at %s%n", 
                            activeMothers.size(), appointmentType, providerName, formattedDate, timeSlot);
            
            // Send notifications to all mothers (in a separate thread to avoid blocking)
            new Thread(() -> {
                int successCount = 0;
                int failureCount = 0;
                
                for (Registration mother : activeMothers) {
                    try {
                        if (mother.getEmail() != null && !mother.getEmail().isEmpty()) {
                            emailService.sendSlotAvailabilityNotification(
                                mother.getEmail(),
                                mother.getFullName(),
                                providerName,
                                appointmentType,
                                formattedDate,
                                timeSlot
                            );
                            successCount++;
                            
                            // Small delay to avoid overwhelming the email server
                            Thread.sleep(100);
                        }
                    } catch (Exception e) {
                        failureCount++;
                        System.err.printf("Failed to send notification to %s (%s): %s%n", 
                                        mother.getFullName(), mother.getEmail(), e.getMessage());
                    }
                }
                
                System.out.printf("Slot availability notifications sent: %d successful, %d failed%n", 
                                successCount, failureCount);
            }).start();
            
        } catch (Exception e) {
            System.err.println("Error in notifyMothersOfAvailableSlot: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
