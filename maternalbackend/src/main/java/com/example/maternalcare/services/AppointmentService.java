package com.example.maternalcare.services;

import com.example.maternalcare.dto.AppointmentDTO;
import com.example.maternalcare.model.Appointment;
import com.example.maternalcare.model.Appointment.AppointmentStatus;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.UserRole;
import com.example.maternalcare.repository.AppointmentRepository;
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
    
    // Create a new appointment
    public AppointmentDTO createAppointment(AppointmentDTO appointmentDTO) {
        System.out.println("Creating appointment for: " + appointmentDTO.getMotherNic());
        System.out.println("Provider: " + appointmentDTO.getProviderName());
        System.out.println("Date: " + appointmentDTO.getAppointmentDate());
        System.out.println("Time: " + appointmentDTO.getTimeSlot());
        
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
            if ("Dr. Prasad Wickramasinghe".equals(appointment.getProviderName())) {
                appointment.setProviderId("DOC001");
                System.out.println("Set provider ID to DOC001");
            } else if ("Mrs. Kamali Jayasinghe".equals(appointment.getProviderName())) {
                appointment.setProviderId("MID001");
                System.out.println("Set provider ID to MID001");
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
        String subject = "Appointment Confirmation - " + appointment.getAppointmentType().toString().toLowerCase() + " Consultation";
        String body = buildConfirmationEmailBody(appointment);
        emailService.sendEmail(appointment.getMotherEmail(), subject, body);
    }
    
    private void sendAppointmentStatusUpdateEmail(Appointment appointment) {
        if (appointment.getStatus() == AppointmentStatus.COMPLETED) {
            // Send simple completion notification
            String subject = "Appointment Completed - Thank You!";
            String body = buildCompletionEmailBody(appointment);
            emailService.sendEmail(appointment.getMotherEmail(), subject, body);
        } else {
            // Send regular status update email
            String subject = "Appointment Status Update - " + appointment.getStatus().toString();
            String body = buildStatusUpdateEmailBody(appointment);
            emailService.sendEmail(appointment.getMotherEmail(), subject, body);
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
        return String.format(
            "Dear %s,\n\n" +
            "Your appointment has been successfully scheduled!\n\n" +
            "Appointment Details:\n" +
            "- Type: %s Consultation\n" +
            "- Provider: %s\n" +
            "- Date: %s\n" +
            "- Time: %s\n" +
            "- Status: %s\n\n" +
            "%s" +
            "Please arrive 15 minutes before your scheduled time.\n\n" +
            "If you need to cancel or reschedule, please contact us as soon as possible.\n\n" +
            "Best regards,\n" +
            "Maternal Health Care Team",
            appointment.getMotherName(),
            appointment.getAppointmentType().toString().toLowerCase(),
            appointment.getProviderName(),
            appointment.getAppointmentDate().toLocalDate(),
            appointment.getTimeSlot(),
            appointment.getStatus().toString().toLowerCase(),
            appointment.getAdditionalProblems() != null && !appointment.getAdditionalProblems().isEmpty() 
                ? "Additional Notes: " + appointment.getAdditionalProblems() + "\n\n" 
                : ""
        );
    }
    
    private String buildStatusUpdateEmailBody(Appointment appointment) {
        return String.format(
            "Dear %s,\n\n" +
            "Your appointment status has been updated.\n\n" +
            "Appointment Details:\n" +
            "- Type: %s Consultation\n" +
            "- Provider: %s\n" +
            "- Date: %s\n" +
            "- Time: %s\n" +
            "- Status: %s\n\n" +
            "%s" +
            "Thank you for choosing our maternal health care services.\n\n" +
            "Best regards,\n" +
            "Maternal Health Care Team",
            appointment.getMotherName(),
            appointment.getAppointmentType().toString().toLowerCase(),
            appointment.getProviderName(),
            appointment.getAppointmentDate().toLocalDate(),
            appointment.getTimeSlot(),
            appointment.getStatus().toString().toLowerCase(),
            appointment.getNotes() != null && !appointment.getNotes().isEmpty() 
                ? "Provider Notes: " + appointment.getNotes() + "\n\n" 
                : ""
        );
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
        return String.format(
            "Dear %s,\n\n" +
            "Your appointment has been completed successfully!\n\n" +
            "Appointment Details:\n" +
            "- Provider: %s\n" +
            "- Date: %s\n" +
            "- Time: %s\n" +
            "- Type: %s Consultation\n\n" +
            "%s" +
            "Thank you for visiting us today. We hope you had a positive experience with our healthcare services.\n\n" +
            "If you have any questions or concerns about your visit, please don't hesitate to contact us.\n\n" +
            "Best regards,\n" +
            "Maternal Health Care Team",
            appointment.getMotherName(),
            appointment.getProviderName(),
            appointment.getAppointmentDate().toLocalDate(),
            appointment.getTimeSlot(),
            appointment.getAppointmentType().toString().toLowerCase(),
            appointment.getNotes() != null && !appointment.getNotes().isEmpty() 
                ? "Provider Notes: " + appointment.getNotes() + "\n\n" 
                : ""
        );
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
