package com.example.maternalcare.repository;

import com.example.maternalcare.model.PregnancyWeightRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PregnancyWeightRecordRepository extends JpaRepository<PregnancyWeightRecord, Long> {
    
    // Find all weight records for a specific mother ordered by measurement date
    List<PregnancyWeightRecord> findByMotherNicOrderByMeasurementDateDesc(String motherNic);
    
    // Find weight records by mother NIC within a date range
    List<PregnancyWeightRecord> findByMotherNicAndMeasurementDateBetweenOrderByMeasurementDateDesc(
            String motherNic, LocalDate startDate, LocalDate endDate);
    
    // Find the most recent weight record for a mother
    Optional<PregnancyWeightRecord> findFirstByMotherNicOrderByMeasurementDateDescCreatedAtDesc(String motherNic);
    
    // Find records by midwife (recorded by)
    List<PregnancyWeightRecord> findByRecordedByOrderByCreatedAtDesc(String recordedBy);
    
    // Find records by pregnancy week
    List<PregnancyWeightRecord> findByMotherNicAndPregnancyWeek(String motherNic, Integer pregnancyWeek);
    
    // Find high-risk indicators
    List<PregnancyWeightRecord> findByIsHighRiskIndicatorTrueOrderByCreatedAtDesc();
    
    // Find high-risk indicators by mother
    List<PregnancyWeightRecord> findByMotherNicAndIsHighRiskIndicatorTrueOrderByMeasurementDateDesc(String motherNic);
    
    // Count total records for a mother
    Long countByMotherNic(String motherNic);
    
    // Get latest weight record before a specific date
    @Query("SELECT pr FROM PregnancyWeightRecord pr WHERE pr.motherNic = :motherNic " +
           "AND pr.measurementDate < :beforeDate ORDER BY pr.measurementDate DESC")
    List<PregnancyWeightRecord> findLatestWeightRecordBefore(@Param("motherNic") String motherNic, 
                                                            @Param("beforeDate") LocalDate beforeDate);
    
    // Find records within specific pregnancy week range
    @Query("SELECT pr FROM PregnancyWeightRecord pr WHERE pr.motherNic = :motherNic " +
           "AND pr.pregnancyWeek BETWEEN :startWeek AND :endWeek ORDER BY pr.pregnancyWeek ASC")
    List<PregnancyWeightRecord> findByMotherNicAndPregnancyWeekBetween(@Param("motherNic") String motherNic,
                                                                       @Param("startWeek") Integer startWeek,
                                                                       @Param("endWeek") Integer endWeek);
    
    // Check if mother has any records
    boolean existsByMotherNic(String motherNic);
    
    // Get average weight gain per trimester
    @Query("SELECT AVG(pr.weightGainFromPrevious) FROM PregnancyWeightRecord pr WHERE pr.motherNic = :motherNic " +
           "AND pr.pregnancyWeek BETWEEN :startWeek AND :endWeek AND pr.weightGainFromPrevious IS NOT NULL")
    Double getAverageWeightGainForPeriod(@Param("motherNic") String motherNic,
                                        @Param("startWeek") Integer startWeek,
                                        @Param("endWeek") Integer endWeek);
}