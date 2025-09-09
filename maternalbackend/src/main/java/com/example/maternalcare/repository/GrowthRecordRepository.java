package com.example.maternalcare.repository;

import com.example.maternalcare.model.GrowthRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GrowthRecordRepository extends JpaRepository<GrowthRecord, Long> {
    List<GrowthRecord> findByMotherNicOrderByDateDesc(String motherNic);
    
    // Baby-specific methods
    List<GrowthRecord> findByBabyIdOrderByDateDesc(Long babyId);
    
    List<GrowthRecord> findByMotherNicAndBabyIdOrderByDateDesc(String motherNic, Long babyId);
}
