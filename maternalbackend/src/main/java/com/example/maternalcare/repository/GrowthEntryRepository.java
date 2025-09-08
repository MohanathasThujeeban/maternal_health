package com.example.maternalcare.repository;

import com.example.maternalcare.model.GrowthEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface GrowthEntryRepository extends JpaRepository<GrowthEntry, Long> {
    List<GrowthEntry> findByMotherNicOrderByDateAsc(String motherNic);
    
    // Baby-specific queries
    List<GrowthEntry> findByBabyIdOrderByDateAsc(Long babyId);
    List<GrowthEntry> findByMotherNicAndBabyIdOrderByDateAsc(String motherNic, Long babyId);
}
