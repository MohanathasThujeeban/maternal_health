package com.example.maternalcare.repository;

import com.example.maternalcare.model.ThiriposaRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ThiriposaRecordRepository extends JpaRepository<ThiriposaRecord, Long> {
    List<ThiriposaRecord> findByMotherNicOrderByDateDesc(String motherNic);
    
    // Baby-specific queries
    List<ThiriposaRecord> findByBabyIdOrderByDateDesc(Long babyId);
    List<ThiriposaRecord> findByMotherNicAndBabyIdOrderByDateDesc(String motherNic, Long babyId);
}
