package com.example.maternalcare.controller;

import com.example.maternalcare.dto.AppointmentDTO;
import com.example.maternalcare.model.Appointment.AppointmentStatus;
import com.example.maternalcare.services.AppointmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {
    
    @Autowired
    private AppointmentService appointmentService;
    
    // Create a new appointment
    @PostMapping
    public ResponseEntity<?> createAppointment(@Valid @RequestBody AppointmentDTO appointmentDTO) {
        try {
            AppointmentDTO createdAppointment = appointmentService.createAppointment(appointmentDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdAppointment);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to create appointment: " + e.getMessage()));
        }
    }

    // Schedule a new appointment (alias for create)
    @PostMapping("/schedule")
    public ResponseEntity<?> scheduleAppointment(@Valid @RequestBody AppointmentDTO appointmentDTO) {
        return createAppointment(appointmentDTO);
    }

    // Get available time slots for a provider on a specific date
    @GetMapping("/available-slots")
    public ResponseEntity<?> getAvailableTimeSlots(
            @RequestParam String date,
            @RequestParam String providerId) {
        try {
            // For now, return all available time slots - you can implement actual logic later
            List<String> availableSlots = List.of(
                "08:00 AM", "08:30 AM", "09:00 AM", "09:30 AM", "10:00 AM",
                "10:30 AM", "11:00 AM", "11:30 AM", "02:00 PM", "02:30 PM",
                "03:00 PM", "03:30 PM", "04:00 PM", "04:30 PM", "05:00 PM"
            );
            return ResponseEntity.ok(Map.of("availableSlots", availableSlots));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to get available slots: " + e.getMessage()));
        }
    }
    
    // Get all appointments for a mother by NIC
    @GetMapping("/mother/{motherNic}")
    public ResponseEntity<?> getAppointmentsByMotherNic(@PathVariable String motherNic) {
        try {
            System.out.println("Fetching appointments for NIC: " + motherNic);
            List<AppointmentDTO> appointments = appointmentService.getAppointmentsByMotherNic(motherNic);
            System.out.println("Found " + appointments.size() + " appointments for NIC: " + motherNic);
            return ResponseEntity.ok(appointments);
        } catch (Exception e) {
            System.err.println("Error fetching appointments for NIC " + motherNic + ": " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch appointments: " + e.getMessage()));
        }
    }
    
    // Get appointments for a mother by NIC and status
    @GetMapping("/mother/{motherNic}/status/{status}")
    public ResponseEntity<List<AppointmentDTO>> getAppointmentsByMotherNicAndStatus(
            @PathVariable String motherNic, 
            @PathVariable String status) {
        try {
            AppointmentStatus appointmentStatus = AppointmentStatus.valueOf(status.toUpperCase());
            List<AppointmentDTO> appointments = appointmentService.getAppointmentsByMotherNicAndStatus(motherNic, appointmentStatus);
            return ResponseEntity.ok(appointments);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    // Get appointments by provider
    @GetMapping("/provider/{providerName}")
    public ResponseEntity<List<AppointmentDTO>> getAppointmentsByProvider(@PathVariable String providerName) {
        try {
            List<AppointmentDTO> appointments = appointmentService.getAppointmentsByProvider(providerName);
            return ResponseEntity.ok(appointments);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Get today's appointments by provider ID
    @GetMapping("/provider/{providerId}/today")
    public ResponseEntity<List<AppointmentDTO>> getTodayAppointmentsByProvider(@PathVariable String providerId) {
        try {
            List<AppointmentDTO> appointments = appointmentService.getTodayAppointmentsByProvider(providerId);
            return ResponseEntity.ok(appointments);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Search appointments by NIC for a specific provider on a specific date
    @GetMapping("/provider/{providerId}/search")
    public ResponseEntity<List<AppointmentDTO>> searchAppointmentsByNic(
            @PathVariable String providerId,
            @RequestParam String nic,
            @RequestParam(required = false) String date) {
        try {
            List<AppointmentDTO> appointments = appointmentService.searchAppointmentsByNicAndProvider(providerId, nic, date);
            return ResponseEntity.ok(appointments);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Get all appointments for a provider by appointment type (doctor/midwife)
    @GetMapping("/type/{appointmentType}/today")
    public ResponseEntity<List<AppointmentDTO>> getTodayAppointmentsByType(@PathVariable String appointmentType) {
        try {
            List<AppointmentDTO> appointments = appointmentService.getTodayAppointmentsByType(appointmentType);
            return ResponseEntity.ok(appointments);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    // Get appointment by ID
    @GetMapping("/{id}")
    public ResponseEntity<AppointmentDTO> getAppointmentById(@PathVariable Long id) {
        try {
            Optional<AppointmentDTO> appointment = appointmentService.getAppointmentById(id);
            return appointment.map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    // Update appointment status
    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateAppointmentStatus(@PathVariable Long id, @RequestBody Map<String, String> request) {
        try {
            String statusStr = request.get("status");
            if (statusStr == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "Status is required"));
            }
            
            AppointmentStatus status = AppointmentStatus.valueOf(statusStr.toUpperCase());
            AppointmentDTO updatedAppointment = appointmentService.updateAppointmentStatus(id, status);
            return ResponseEntity.ok(updatedAppointment);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid status value"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to update appointment status"));
        }
    }
    
    // Update appointment notes
    @PutMapping("/{id}/notes")
    public ResponseEntity<?> updateAppointmentNotes(@PathVariable Long id, @RequestBody Map<String, String> request) {
        try {
            String notes = request.get("notes");
            if (notes == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "Notes are required"));
            }
            
            AppointmentDTO updatedAppointment = appointmentService.updateAppointmentNotes(id, notes);
            return ResponseEntity.ok(updatedAppointment);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to update appointment notes"));
        }
    }
    
    // Cancel appointment
    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancelAppointment(@PathVariable Long id) {
        try {
            AppointmentDTO cancelledAppointment = appointmentService.cancelAppointment(id);
            return ResponseEntity.ok(cancelledAppointment);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to cancel appointment"));
        }
    }
    
    // Complete appointment
    @PutMapping("/{id}/complete")
    public ResponseEntity<?> completeAppointment(@PathVariable Long id) {
        try {
            AppointmentDTO completedAppointment = appointmentService.completeAppointment(id);
            return ResponseEntity.ok(completedAppointment);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to complete appointment"));
        }
    }
    
    // Get appointments by date range
    @GetMapping("/date-range")
    public ResponseEntity<List<AppointmentDTO>> getAppointmentsByDateRange(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
            LocalDateTime start = LocalDateTime.parse(startDate, formatter);
            LocalDateTime end = LocalDateTime.parse(endDate, formatter);
            
            List<AppointmentDTO> appointments = appointmentService.getAppointmentsByDateRange(start, end);
            return ResponseEntity.ok(appointments);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    // Get appointments by provider and date range
    @GetMapping("/provider/{providerName}/date-range")
    public ResponseEntity<List<AppointmentDTO>> getAppointmentsByProviderAndDateRange(
            @PathVariable String providerName,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
            LocalDateTime start = LocalDateTime.parse(startDate, formatter);
            LocalDateTime end = LocalDateTime.parse(endDate, formatter);
            
            List<AppointmentDTO> appointments = appointmentService.getAppointmentsByProviderAndDateRange(providerName, start, end);
            return ResponseEntity.ok(appointments);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    // Health check endpoint
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        return ResponseEntity.ok(Map.of("status", "Appointment service is running"));
    }
}
