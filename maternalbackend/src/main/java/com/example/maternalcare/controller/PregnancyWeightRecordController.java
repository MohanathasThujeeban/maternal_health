package com.example.maternalcare.controller;

import com.example.maternalcare.model.PregnancyWeightRecord;
import com.example.maternalcare.service.PregnancyWeightRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/pregnancy-weight-records")
@CrossOrigin(origins = "*")
public class PregnancyWeightRecordController {
    
    @Autowired
    private PregnancyWeightRecordService pregnancyWeightRecordService;
    
    /**
     * Create a new pregnancy weight record
     */
    @PostMapping
    public ResponseEntity<PregnancyWeightRecord> createWeightRecord(@RequestBody PregnancyWeightRecord record) {
        try {
            PregnancyWeightRecord savedRecord = pregnancyWeightRecordService.saveWeightRecord(record);
            return new ResponseEntity<>(savedRecord, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get all weight records for a specific mother
     */
    @GetMapping("/mother/{motherNic}")
    public ResponseEntity<List<PregnancyWeightRecord>> getWeightRecordsByMother(@PathVariable String motherNic) {
        try {
            List<PregnancyWeightRecord> records = pregnancyWeightRecordService.getWeightRecordsByMotherNic(motherNic);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get the latest weight record for a mother
     */
    @GetMapping("/mother/{motherNic}/latest")
    public ResponseEntity<PregnancyWeightRecord> getLatestWeightRecord(@PathVariable String motherNic) {
        try {
            Optional<PregnancyWeightRecord> record = pregnancyWeightRecordService.getLatestWeightRecord(motherNic);
            if (record.isPresent()) {
                return new ResponseEntity<>(record.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get weight records within a date range
     */
    @GetMapping("/mother/{motherNic}/date-range")
    public ResponseEntity<List<PregnancyWeightRecord>> getWeightRecordsInDateRange(
            @PathVariable String motherNic,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);
            
            List<PregnancyWeightRecord> records = pregnancyWeightRecordService.getWeightRecordsInDateRange(motherNic, start, end);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get weight records by pregnancy week range
     */
    @GetMapping("/mother/{motherNic}/weeks")
    public ResponseEntity<List<PregnancyWeightRecord>> getWeightRecordsByWeekRange(
            @PathVariable String motherNic,
            @RequestParam Integer startWeek,
            @RequestParam Integer endWeek) {
        try {
            List<PregnancyWeightRecord> records = pregnancyWeightRecordService.getWeightRecordsByWeekRange(motherNic, startWeek, endWeek);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get all high-risk weight records
     */
    @GetMapping("/high-risk")
    public ResponseEntity<List<PregnancyWeightRecord>> getHighRiskRecords() {
        try {
            List<PregnancyWeightRecord> records = pregnancyWeightRecordService.getHighRiskRecords();
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get high-risk weight records for a specific mother
     */
    @GetMapping("/mother/{motherNic}/high-risk")
    public ResponseEntity<List<PregnancyWeightRecord>> getHighRiskRecordsByMother(@PathVariable String motherNic) {
        try {
            List<PregnancyWeightRecord> records = pregnancyWeightRecordService.getHighRiskRecordsByMother(motherNic);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get weight records by midwife
     */
    @GetMapping("/midwife/{midwifeNic}")
    public ResponseEntity<List<PregnancyWeightRecord>> getRecordsByMidwife(@PathVariable String midwifeNic) {
        try {
            List<PregnancyWeightRecord> records = pregnancyWeightRecordService.getRecordsByMidwife(midwifeNic);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Update an existing weight record
     */
    @PutMapping("/{recordId}")
    public ResponseEntity<PregnancyWeightRecord> updateWeightRecord(
            @PathVariable Long recordId,
            @RequestBody PregnancyWeightRecord updatedRecord) {
        try {
            PregnancyWeightRecord record = pregnancyWeightRecordService.updateWeightRecord(recordId, updatedRecord);
            return new ResponseEntity<>(record, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Delete a weight record
     */
    @DeleteMapping("/{recordId}")
    public ResponseEntity<HttpStatus> deleteWeightRecord(@PathVariable Long recordId) {
        try {
            pregnancyWeightRecordService.deleteWeightRecord(recordId);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get weight gain statistics for a mother by trimester
     */
    @GetMapping("/mother/{motherNic}/statistics/trimester/{trimester}")
    public ResponseEntity<Map<String, Object>> getWeightGainStatistics(
            @PathVariable String motherNic,
            @PathVariable int trimester) {
        try {
            Double averageWeightGain = pregnancyWeightRecordService.getAverageWeightGainForTrimester(motherNic, trimester);
            Long recordCount = pregnancyWeightRecordService.getRecordCount(motherNic);
            boolean hasRecords = pregnancyWeightRecordService.hasWeightRecords(motherNic);
            
            Map<String, Object> statistics = Map.of(
                "averageWeightGainForTrimester", averageWeightGain != null ? averageWeightGain : 0.0,
                "totalRecordCount", recordCount,
                "hasRecords", hasRecords,
                "trimester", trimester
            );
            
            return new ResponseEntity<>(statistics, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Get overall statistics for a mother
     */
    @GetMapping("/mother/{motherNic}/statistics")
    public ResponseEntity<Map<String, Object>> getMotherStatistics(@PathVariable String motherNic) {
        try {
            Long recordCount = pregnancyWeightRecordService.getRecordCount(motherNic);
            boolean hasRecords = pregnancyWeightRecordService.hasWeightRecords(motherNic);
            Optional<PregnancyWeightRecord> latestRecord = pregnancyWeightRecordService.getLatestWeightRecord(motherNic);
            List<PregnancyWeightRecord> highRiskRecords = pregnancyWeightRecordService.getHighRiskRecordsByMother(motherNic);
            
            Map<String, Object> statistics = Map.of(
                "totalRecordCount", recordCount,
                "hasRecords", hasRecords,
                "hasLatestRecord", latestRecord.isPresent(),
                "highRiskRecordCount", highRiskRecords.size(),
                "hasHighRiskRecords", !highRiskRecords.isEmpty()
            );
            
            return new ResponseEntity<>(statistics, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Check if mother has weight records
     */
    @GetMapping("/mother/{motherNic}/exists")
    public ResponseEntity<Map<String, Boolean>> checkMotherHasRecords(@PathVariable String motherNic) {
        try {
            boolean hasRecords = pregnancyWeightRecordService.hasWeightRecords(motherNic);
            Map<String, Boolean> response = Map.of("hasRecords", hasRecords);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}