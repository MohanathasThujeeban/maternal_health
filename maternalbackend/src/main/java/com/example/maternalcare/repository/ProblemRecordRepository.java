
package com.example.maternalcare.repository;

import com.example.maternalcare.model.ProblemRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ProblemRecordRepository extends JpaRepository<ProblemRecord, Long> {
    
    // Find records by patient name (case insensitive)
    List<ProblemRecord> findByPatientNameContainingIgnoreCase(String patientName);
    
    // Find records by mother NIC
    List<ProblemRecord> findByMotherNicOrderByDateOfDiagnosisDesc(String motherNic);
    
    // Find records by baby ID
    List<ProblemRecord> findByBabyIdOrderByDateOfDiagnosisDesc(Long babyId);
    
    // Find records by date range
    List<ProblemRecord> findByDateOfDiagnosisBetween(LocalDate startDate, LocalDate endDate);
    
    // Find records with eye problems only
    @Query("SELECT p FROM ProblemRecord p WHERE p.eyeProblem != 'None' AND p.eyeProblem IS NOT NULL AND p.eyeProblem != ''")
    List<ProblemRecord> findRecordsWithEyeProblems();
    
    // Find records with ear problems only
    @Query("SELECT p FROM ProblemRecord p WHERE p.earProblem != 'None' AND p.earProblem IS NOT NULL AND p.earProblem != ''")
    List<ProblemRecord> findRecordsWithEarProblems();
    
    // Find recent records (last 30 days)
    @Query("SELECT p FROM ProblemRecord p WHERE p.dateOfDiagnosis >= :thirtyDaysAgo ORDER BY p.dateOfDiagnosis DESC")
    List<ProblemRecord> findRecentRecords(@Param("thirtyDaysAgo") LocalDate thirtyDaysAgo);
    
    // Find all records ordered by date (most recent first)
    List<ProblemRecord> findAllByOrderByDateOfDiagnosisDesc();
}
