package com.example.maternalcare.repository;

import com.example.maternalcare.model.Baby;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BabyRepository extends JpaRepository<Baby, Long> {
    
    // Find all babies for a specific mother
    List<Baby> findByMotherNicAndIsActiveTrueOrderByBabyOrder(String motherNic);
    
    // Find all babies for a mother (including inactive)
    List<Baby> findByMotherNicOrderByBabyOrder(String motherNic);
    
    // Find a specific baby by mother NIC and baby order
    Optional<Baby> findByMotherNicAndBabyOrderAndIsActiveTrue(String motherNic, Integer babyOrder);
    
    // Find a specific baby by mother NIC and baby name
    Optional<Baby> findByMotherNicAndBabyNameAndIsActiveTrue(String motherNic, String babyName);
    
    // Count active babies for a mother
    @Query("SELECT COUNT(b) FROM Baby b WHERE b.motherNic = :motherNic AND b.isActive = true")
    Long countActiveBabiesByMotherNic(@Param("motherNic") String motherNic);
    
    // Get the next baby order for a mother
    @Query("SELECT COALESCE(MAX(b.babyOrder), 0) + 1 FROM Baby b WHERE b.motherNic = :motherNic")
    Integer getNextBabyOrder(@Param("motherNic") String motherNic);
    
    // Find baby by ID and mother NIC (for security)
    Optional<Baby> findByIdAndMotherNic(Long id, String motherNic);
    
    // Check if baby name already exists for the mother
    @Query("SELECT COUNT(b) > 0 FROM Baby b WHERE b.motherNic = :motherNic AND b.babyName = :babyName AND b.isActive = true AND (:excludeId IS NULL OR b.id != :excludeId)")
    Boolean existsByMotherNicAndBabyNameExcludingId(@Param("motherNic") String motherNic, 
                                                   @Param("babyName") String babyName, 
                                                   @Param("excludeId") Long excludeId);
}
