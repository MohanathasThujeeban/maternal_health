package com.example.maternalcare.repository;

import com.example.maternalcare.model.PatientNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PatientNoteRepository extends JpaRepository<PatientNote, Long> {
    
    // Find all notes for a specific mother
    List<PatientNote> findByMotherNicOrderByCreatedAtDesc(String motherNic);
    
    // Find all notes by a specific doctor
    List<PatientNote> findByDoctorLicenseOrderByCreatedAtDesc(String doctorLicense);
    
    // Find notes for a specific mother by a specific doctor
    List<PatientNote> findByMotherNicAndDoctorLicenseOrderByCreatedAtDesc(String motherNic, String doctorLicense);
    
    // Get the latest note for a mother
    @Query("SELECT p FROM PatientNote p WHERE p.motherNic = :motherNic ORDER BY p.createdAt DESC LIMIT 1")
    PatientNote findLatestNoteByMotherNic(@Param("motherNic") String motherNic);
    
    // Check if a doctor has any notes for a mother
    boolean existsByMotherNicAndDoctorLicense(String motherNic, String doctorLicense);
    
    // Get recent notes by doctor license with limit
    @Query("SELECT p FROM PatientNote p WHERE p.doctorLicense = :doctorLicense ORDER BY p.createdAt DESC LIMIT :limit")
    List<PatientNote> findTopByDoctorLicenseOrderByCreatedAtDesc(@Param("doctorLicense") String doctorLicense, @Param("limit") int limit);
}
