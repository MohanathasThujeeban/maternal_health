package com.example.maternalcare.service;

import com.example.maternalcare.model.PatientNote;
import com.example.maternalcare.repository.PatientNoteRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PatientNoteService {
    
    private final PatientNoteRepository patientNoteRepository;
    
    public PatientNoteService(PatientNoteRepository patientNoteRepository) {
        this.patientNoteRepository = patientNoteRepository;
    }
    
    // Save or update a patient note
    public PatientNote savePatientNote(PatientNote patientNote) {
        return patientNoteRepository.save(patientNote);
    }
    
    // Get all notes for a specific mother
    public List<PatientNote> getNotesByMotherNic(String motherNic) {
        return patientNoteRepository.findByMotherNicOrderByCreatedAtDesc(motherNic);
    }
    
    // Get all notes by a specific doctor
    public List<PatientNote> getNotesByDoctorLicense(String doctorLicense) {
        return patientNoteRepository.findByDoctorLicenseOrderByCreatedAtDesc(doctorLicense);
    }
    
    // Get notes for a specific mother by a specific doctor
    public List<PatientNote> getNotesByMotherAndDoctor(String motherNic, String doctorLicense) {
        return patientNoteRepository.findByMotherNicAndDoctorLicenseOrderByCreatedAtDesc(motherNic, doctorLicense);
    }
    
    // Get a specific note by ID
    public Optional<PatientNote> getNoteById(Long id) {
        return patientNoteRepository.findById(id);
    }
    
    // Get the latest note for a mother
    public PatientNote getLatestNoteByMotherNic(String motherNic) {
        return patientNoteRepository.findLatestNoteByMotherNic(motherNic);
    }
    
    // Check if a doctor has any notes for a mother
    public boolean hasNotesForMother(String motherNic, String doctorLicense) {
        return patientNoteRepository.existsByMotherNicAndDoctorLicense(motherNic, doctorLicense);
    }
    
    // Delete a note
    public void deleteNote(Long id) {
        patientNoteRepository.deleteById(id);
    }
    
    // Get all notes
    public List<PatientNote> getAllNotes() {
        return patientNoteRepository.findAll();
    }
    
    // Get recent notes by doctor license with limit
    public List<PatientNote> getRecentNotesByDoctorLicense(String doctorLicense, int limit) {
        return patientNoteRepository.findTopByDoctorLicenseOrderByCreatedAtDesc(doctorLicense, limit);
    }
}
