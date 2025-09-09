package com.example.maternalcare.controller;

import com.example.maternalcare.model.GrowthRecord;
import com.example.maternalcare.repository.GrowthRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/growth-records")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class GrowthRecordController {

    @Autowired
    private GrowthRecordRepository growthRecordRepository;

    @GetMapping("/get/{motherNic}")
    public ResponseEntity<List<GrowthRecord>> getGrowthRecords(@PathVariable String motherNic) {
        List<GrowthRecord> records = growthRecordRepository.findByMotherNicOrderByDateDesc(motherNic);
        return ResponseEntity.ok(records);
    }

    @GetMapping("/all")
    public ResponseEntity<List<GrowthRecord>> getAllGrowthRecords() {
        List<GrowthRecord> records = growthRecordRepository.findAll();
        return ResponseEntity.ok(records);
    }

    // Baby-specific endpoints for mother dashboard
    @GetMapping("/baby/{babyId}")
    public ResponseEntity<List<GrowthRecord>> getGrowthRecordsByBaby(@PathVariable Long babyId) {
        try {
            List<GrowthRecord> records = growthRecordRepository.findByBabyIdOrderByDateDesc(babyId);
            return ResponseEntity.ok(records);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }

    @GetMapping("/mother/{motherNic}/baby/{babyId}")
    public ResponseEntity<List<GrowthRecord>> getGrowthRecordsByMotherAndBaby(
            @PathVariable String motherNic, 
            @PathVariable Long babyId) {
        try {
            List<GrowthRecord> records = growthRecordRepository.findByMotherNicAndBabyIdOrderByDateDesc(motherNic, babyId);
            return ResponseEntity.ok(records);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
}
