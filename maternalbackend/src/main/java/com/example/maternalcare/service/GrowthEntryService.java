package com.example.maternalhealth.service;

import com.example.maternalhealth.model.GrowthEntry;
import com.example.maternalhealth.repository.GrowthEntryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GrowthEntryService {

    private final GrowthEntryRepository repository;

    public GrowthEntryService(GrowthEntryRepository repository) {
        this.repository = repository;
    }

    public GrowthEntry saveEntry(GrowthEntry entry) {
        return repository.save(entry);
    }

    public List<GrowthEntry> getEntriesByNic(String nic) {
        return repository.findByMotherNicOrderByDateAsc(nic);
    }
}
