package com.example.maternalcare.controller;

import com.example.maternalcare.model.GrowthEntry;
import com.example.maternalcare.service.GrowthEntryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/growth")
@CrossOrigin(origins = "*") // allow Flutter app requests
public class GrowthEntryController {

    private final GrowthEntryService service;

    public GrowthEntryController(GrowthEntryService service) {
        this.service = service;
    }

    // Save growth entry
    @PostMapping("/add")
    public ResponseEntity<GrowthEntry> addEntry(@RequestBody GrowthEntry entry) {
        GrowthEntry savedEntry = service.saveEntry(entry);
        return ResponseEntity.ok(savedEntry);
    }

    // Get growth entries by NIC
    @GetMapping("/get/{nic}")
    public ResponseEntity<List<GrowthEntry>> getEntriesByNic(@PathVariable String nic) {
        List<GrowthEntry> entries = service.getEntriesByNic(nic);
        return ResponseEntity.ok(entries);
    }
}
