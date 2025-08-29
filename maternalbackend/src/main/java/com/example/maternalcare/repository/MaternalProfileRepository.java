package com.example.maternalcare.repository;

import com.example.maternalcare.model.MaternalProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface MaternalProfileRepository extends JpaRepository<MaternalProfile, Long> {
    
    // Find profile by mother NIC
    Optional<MaternalProfile> findByMotherNic(String motherNic);
    
    // Check if profile exists for mother NIC
    boolean existsByMotherNic(String motherNic);
    
    // Find all completed profiles
    List<MaternalProfile> findByProfileCompletedTrue();
    
    // Find all incomplete profiles
    List<MaternalProfile> findByProfileCompletedFalse();
    
    // Find high-risk pregnancies
    List<MaternalProfile> findByIsHighRiskPregnancyTrue();
    
    // Find profiles by district
    List<MaternalProfile> findByDistrict(String district);
    
    // Find profiles by GS Division
    List<MaternalProfile> findByGsDivision(String gsDivision);
    
    // Find profiles by MOH area
    List<MaternalProfile> findByMohArea(String mohArea);
    
    // Find profiles by PHM area
    List<MaternalProfile> findByPhmArea(String phmArea);
    
    // Find profiles by current pregnancy status
    List<MaternalProfile> findByCurrentPregnancyStatus(String status);
    
    // Find profiles by pregnancy week range
    @Query("SELECT mp FROM MaternalProfile mp WHERE mp.currentPregnancyWeek BETWEEN :startWeek AND :endWeek")
    List<MaternalProfile> findByPregnancyWeekRange(@Param("startWeek") Integer startWeek, @Param("endWeek") Integer endWeek);
    
    // Find profiles with blood type
    List<MaternalProfile> findByBloodType(String bloodType);
    
    // Count profiles by district
    @Query("SELECT COUNT(mp) FROM MaternalProfile mp WHERE mp.district = :district")
    Long countByDistrict(@Param("district") String district);
    
    // Find mothers due within a date range
    @Query("SELECT mp FROM MaternalProfile mp WHERE mp.expectedDeliveryDate BETWEEN :startDate AND :endDate")
    List<MaternalProfile> findByExpectedDeliveryDateBetween(@Param("startDate") java.time.LocalDate startDate, @Param("endDate") java.time.LocalDate endDate);
}
