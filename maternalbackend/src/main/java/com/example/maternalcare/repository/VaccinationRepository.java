package com.example.maternalcare.repository;

import com.example.maternalcare.model.Vaccination;
import com.example.maternalcare.enums.VaccinationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface VaccinationRepository extends JpaRepository<Vaccination, Long> {
    
    /**
     * Find all vaccinations for a specific mother by NIC
     */
    List<Vaccination> findByMotherNicOrderByCreatedAtDesc(String motherNic);
    
    /**
     * Find all vaccinations for a specific baby by baby ID
     */
    List<Vaccination> findByBabyIdOrderByCreatedAtDesc(Long babyId);
    
    /**
     * Find vaccinations by mother NIC and status
     */
    List<Vaccination> findByMotherNicAndStatusOrderByCreatedAtDesc(String motherNic, VaccinationStatus status);
    
    /**
     * Find all vaccinations by status
     */
    List<Vaccination> findByStatusOrderByCreatedAtDesc(VaccinationStatus status);
    
    /**
     * Find vaccinations due within a date range
     */
    @Query("SELECT v FROM Vaccination v WHERE v.vaccinationDate BETWEEN :startDate AND :endDate ORDER BY v.vaccinationDate")
    List<Vaccination> findVaccinationsBetweenDates(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    /**
     * Find overdue vaccinations (pending and past due date)
     */
    @Query("SELECT v FROM Vaccination v WHERE v.status = 'PENDING' AND v.vaccinationDate < :currentDate ORDER BY v.vaccinationDate")
    List<Vaccination> findOverdueVaccinations(@Param("currentDate") LocalDate currentDate);
    
    /**
     * Count vaccinations by status
     */
    long countByStatus(VaccinationStatus status);
    
    /**
     * Count vaccinations by mother NIC and status
     */
    long countByMotherNicAndStatus(String motherNic, VaccinationStatus status);
    
    /**
     * Find vaccinations by vaccination type
     */
    List<Vaccination> findByVaccinationTypeOrderByCreatedAtDesc(String vaccinationType);
    
    /**
     * Get vaccination statistics for a mother
     */
    @Query("SELECT v.status, COUNT(v) FROM Vaccination v WHERE v.motherNic = :motherNic GROUP BY v.status")
    List<Object[]> getVaccinationStatsByMotherNic(@Param("motherNic") String motherNic);
    
    /**
     * Get overall vaccination statistics
     */
    @Query("SELECT v.status, COUNT(v) FROM Vaccination v GROUP BY v.status")
    List<Object[]> getOverallVaccinationStats();
}
