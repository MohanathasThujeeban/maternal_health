package com.example.maternalhealth.repository;

import com.example.maternalhealth.model.GrowthEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface GrowthEntryRepository extends JpaRepository<GrowthEntry, Long> {
    List<GrowthEntry> findByMotherNicOrderByDateAsc(String motherNic);
}
