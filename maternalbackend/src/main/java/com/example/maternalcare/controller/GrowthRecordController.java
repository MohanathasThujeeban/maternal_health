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
}
