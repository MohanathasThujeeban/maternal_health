package com.example.maternalcare.controller;

import com.example.maternalcare.model.PatientNote;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.service.PatientNoteService;
import com.example.maternalcare.services.EmailService;
import com.example.maternalcare.repository.RegistrationRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/patient-notes")
@CrossOrigin(origins = "*", allowCredentials = "false")
public class PatientNoteController {
    
    private final PatientNoteService patientNoteService;
    private final EmailService emailService;
    private final RegistrationRepository registrationRepository;
    
    public PatientNoteController(PatientNoteService patientNoteService, 
                                EmailService emailService,
                                RegistrationRepository registrationRepository) {
        this.patientNoteService = patientNoteService;
        this.emailService = emailService;
        this.registrationRepository = registrationRepository;
    }
    
    // Create or update a patient note
    @PostMapping
    public ResponseEntity<?> createOrUpdateNote(@RequestBody Map<String, Object> noteData) {
        try {
            // Extract data from request
            String motherNic = (String) noteData.get("motherNic");
            String doctorLicense = (String) noteData.get("doctorLicense");
            String doctorName = (String) noteData.get("doctorName");
            String notes = (String) noteData.get("notes");
            String diagnosis = (String) noteData.get("diagnosis");
            String treatmentPlan = (String) noteData.get("treatmentPlan");
            String nextVisitDateStr = (String) noteData.get("nextVisitDate");
            
            // Validate required fields
            if (motherNic == null || motherNic.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("Mother NIC is required"));
            }
            if (doctorLicense == null || doctorLicense.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("Doctor license is required"));
            }
            if (doctorName == null || doctorName.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("Doctor name is required"));
            }
            
            PatientNote patientNote;
            
            // Check if this is an update (if ID is provided)
            if (noteData.containsKey("id") && noteData.get("id") != null) {
                Long id = Long.valueOf(noteData.get("id").toString());
                Optional<PatientNote> existingNote = patientNoteService.getNoteById(id);
                
                if (existingNote.isPresent()) {
                    patientNote = existingNote.get();
                } else {
                    return ResponseEntity.notFound().build();
                }
            } else {
                // Create new note
                patientNote = new PatientNote();
                patientNote.setMotherNic(motherNic.trim());
                patientNote.setDoctorLicense(doctorLicense.trim());
                patientNote.setDoctorName(doctorName.trim());
            }
            
            // Update fields
            patientNote.setNotes(notes != null ? notes.trim() : "");
            patientNote.setDiagnosis(diagnosis != null ? diagnosis.trim() : "");
            patientNote.setTreatmentPlan(treatmentPlan != null ? treatmentPlan.trim() : "");
            
            // Parse next visit date if provided
            if (nextVisitDateStr != null && !nextVisitDateStr.trim().isEmpty()) {
                try {
                    patientNote.setNextVisitDate(LocalDateTime.parse(nextVisitDateStr));
                } catch (Exception e) {
                    return ResponseEntity.badRequest().body(createErrorResponse("Invalid next visit date format"));
                }
            }
            
            PatientNote savedNote = patientNoteService.savePatientNote(patientNote);
            
            // Send confirmation email to the mother
            try {
                Optional<Registration> motherOptional = registrationRepository.findByNicNumber(motherNic);
                if (motherOptional.isPresent()) {
                    Registration mother = motherOptional.get();
                    
                    // Format the visit date for email
                    String visitDateFormatted = savedNote.getCreatedAt().toString().substring(0, 16).replaceAll("T", " ");
                    
                    // Send confirmation email
                    emailService.sendDoctorNoteConfirmationEmail(
                        mother.getEmail(),
                        mother.getFullName(),
                        doctorName,
                        notes,
                        diagnosis,
                        treatmentPlan,
                        visitDateFormatted
                    );
                    
                    System.out.println("Confirmation email sent to: " + mother.getEmail());
                } else {
                    System.out.println("Warning: Mother not found for NIC: " + motherNic + ", email not sent");
                }
            } catch (Exception e) {
                System.err.println("Failed to send confirmation email: " + e.getMessage());
                // Don't fail the request if email fails
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Patient note saved successfully");
            response.put("patientNote", savedNote);
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Error saving patient note: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to save patient note: " + e.getMessage()));
        }
    }
    
    // Get all notes for a specific mother
    @GetMapping("/mother/{motherNic}")
    public ResponseEntity<?> getNotesByMother(@PathVariable String motherNic) {
        try {
            List<PatientNote> notes = patientNoteService.getNotesByMotherNic(motherNic);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("notes", notes);
            response.put("count", notes.size());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Error fetching notes for mother: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to fetch patient notes"));
        }
    }
    
    // Get all notes by a specific doctor
    @GetMapping("/doctor/{doctorLicense}")
    public ResponseEntity<?> getNotesByDoctor(@PathVariable String doctorLicense) {
        try {
            List<PatientNote> notes = patientNoteService.getNotesByDoctorLicense(doctorLicense);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("notes", notes);
            response.put("count", notes.size());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Error fetching notes by doctor: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to fetch patient notes"));
        }
    }
    
    // Get notes for a specific mother by a specific doctor
    @GetMapping("/mother/{motherNic}/doctor/{doctorLicense}")
    public ResponseEntity<?> getNotesByMotherAndDoctor(@PathVariable String motherNic, @PathVariable String doctorLicense) {
        try {
            List<PatientNote> notes = patientNoteService.getNotesByMotherAndDoctor(motherNic, doctorLicense);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("notes", notes);
            response.put("count", notes.size());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Error fetching notes by mother and doctor: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to fetch patient notes"));
        }
    }
    
    // Get a specific note by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getNoteById(@PathVariable Long id) {
        try {
            Optional<PatientNote> note = patientNoteService.getNoteById(id);
            
            if (note.isPresent()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("patientNote", note.get());
                response.put("timestamp", LocalDateTime.now());
                
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.notFound().build();
            }
            
        } catch (Exception e) {
            System.err.println("Error fetching note by ID: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to fetch patient note"));
        }
    }
    
    // Delete a patient note
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteNote(@PathVariable Long id) {
        try {
            Optional<PatientNote> note = patientNoteService.getNoteById(id);
            
            if (note.isPresent()) {
                patientNoteService.deleteNote(id);
                
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Patient note deleted successfully");
                response.put("timestamp", LocalDateTime.now());
                
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.notFound().build();
            }
            
        } catch (Exception e) {
            System.err.println("Error deleting patient note: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to delete patient note"));
        }
    }
    
    // Get latest note for a mother
    @GetMapping("/mother/{motherNic}/latest")
    public ResponseEntity<?> getLatestNoteByMother(@PathVariable String motherNic) {
        try {
            PatientNote latestNote = patientNoteService.getLatestNoteByMotherNic(motherNic);
            
            if (latestNote != null) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("latestNote", latestNote);
                response.put("timestamp", LocalDateTime.now());
                
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("latestNote", null);
                response.put("message", "No notes found for this mother");
                response.put("timestamp", LocalDateTime.now());
                
                return ResponseEntity.ok(response);
            }
            
        } catch (Exception e) {
            System.err.println("Error fetching latest note: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to fetch latest note"));
        }
    }
    
    // Get recent notes by doctor license (for dashboard activities)
    @GetMapping("/doctor/{doctorLicense}/recent")
    public ResponseEntity<?> getRecentNotesByDoctor(@PathVariable String doctorLicense) {
        try {
            List<PatientNote> recentNotes = patientNoteService.getRecentNotesByDoctorLicense(doctorLicense, 5); // Get last 5 notes
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("notes", recentNotes);
            response.put("count", recentNotes.size());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Error fetching recent notes by doctor: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Failed to fetch recent notes"));
        }
    }
    
    // Helper method to create error response
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("error", message);
        errorResponse.put("timestamp", LocalDateTime.now());
        return errorResponse;
    }
}
