package com.example.maternalcare.controller;

import com.example.maternalcare.dto.GrowthEntryRequest;
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

    // Save growth entry with midwife information
    @PostMapping("/add")
    public ResponseEntity<GrowthEntry> addEntry(@RequestBody GrowthEntryRequest request) {
        System.out.println("Received growth entry request: " + request.getMotherNic() + 
                         ", Height: " + request.getHeight() + 
                         ", Weight: " + request.getWeight() + 
                         ", Date: " + request.getDate() +
                         ", Midwife License: " + request.getMidwifeLicense());
        
        try {
            // Convert DTO to Entity
            GrowthEntry entry = new GrowthEntry(
                request.getMotherNic(),
                request.getHeight(),
                request.getWeight(),
                request.getDate()
            );
            
            GrowthEntry savedEntry = service.saveEntryWithMidwife(entry, request.getMidwifeLicense());
            System.out.println("Successfully saved growth entry with ID: " + savedEntry.getId());
            return ResponseEntity.ok(savedEntry);
        } catch (Exception e) {
            System.err.println("Error saving growth entry: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }

    // Fallback method for backward compatibility (without midwife info)
    @PostMapping("/add-simple") 
    public ResponseEntity<GrowthEntry> addEntrySimple(@RequestBody GrowthEntry entry) {
        System.out.println("Received simple growth entry request: " + entry.getMotherNic() + 
                         ", Height: " + entry.getHeight() + 
                         ", Weight: " + entry.getWeight() + 
                         ", Date: " + entry.getDate());
        
        try {
            GrowthEntry savedEntry = service.saveEntry(entry);
            System.out.println("Successfully saved growth entry with ID: " + savedEntry.getId());
            return ResponseEntity.ok(savedEntry);
        } catch (Exception e) {
            System.err.println("Error saving growth entry: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }

    // Get growth entries by NIC
    @GetMapping("/get/{nic}")
    public ResponseEntity<List<GrowthEntry>> getEntriesByNic(@PathVariable String nic) {
        List<GrowthEntry> entries = service.getEntriesByNic(nic);
        return ResponseEntity.ok(entries);
    }
}
