
package com.example.maternalcare.controller;

import com.example.maternalcare.dto.ProblemRecordDTO;
import com.example.maternalcare.service.ProblemRecordService;
import com.example.maternalcare.services.ApiResponseService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/baby-problems")
@CrossOrigin(origins = {"http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:8080"})
public class ProblemRecordController {
    
    @Autowired
    private ProblemRecordService problemRecordService;
    
    @Autowired
    private ApiResponseService apiResponseService;
    
    // Save new problem record
    @PostMapping
    public ResponseEntity<Map<String, Object>> createRecord(@Valid @RequestBody ProblemRecordDTO problemRecordDTO) {
        try {
            ProblemRecordDTO savedRecord = problemRecordService.saveRecord(problemRecordDTO);
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Record saved successfully", savedRecord);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to save record: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Get all records (for history)
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllRecords() {
        try {
            List<ProblemRecordDTO> records = problemRecordService.getAllRecords();
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Records retrieved successfully", records, records.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to retrieve records: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Get record by ID
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getRecordById(@PathVariable Long id) {
        try {
            ProblemRecordDTO record = problemRecordService.getRecordById(id);
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Record found", record);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to retrieve record: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Update record
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateRecord(@PathVariable Long id, 
                                                           @Valid @RequestBody ProblemRecordDTO problemRecordDTO) {
        try {
            ProblemRecordDTO updatedRecord = problemRecordService.updateRecord(id, problemRecordDTO);
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Record updated successfully", updatedRecord);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to update record: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Delete record
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteRecord(@PathVariable Long id) {
        try {
            problemRecordService.deleteRecord(id);
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Record deleted successfully", null);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to delete record: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Search records by patient name
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchByPatientName(@RequestParam String patientName) {
        try {
            List<ProblemRecordDTO> records = problemRecordService.searchByPatientName(patientName);
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Search completed", records, records.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Search failed: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Get records by date range
    @GetMapping("/date-range")
    public ResponseEntity<Map<String, Object>> getRecordsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        try {
            List<ProblemRecordDTO> records = problemRecordService.getRecordsByDateRange(startDate, endDate);
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Records retrieved for date range", records, records.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to retrieve records by date range: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Get recent records (last 30 days)
    @GetMapping("/recent")
    public ResponseEntity<Map<String, Object>> getRecentRecords() {
        try {
            List<ProblemRecordDTO> records = problemRecordService.getRecentRecords();
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Recent records retrieved", records, records.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to retrieve recent records: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Get records with eye problems
    @GetMapping("/eye-problems")
    public ResponseEntity<Map<String, Object>> getRecordsWithEyeProblems() {
        try {
            List<ProblemRecordDTO> records = problemRecordService.getRecordsWithEyeProblems();
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Eye problem records retrieved", records, records.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to retrieve eye problem records: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Get records with ear problems
    @GetMapping("/ear-problems")
    public ResponseEntity<Map<String, Object>> getRecordsWithEarProblems() {
        try {
            List<ProblemRecordDTO> records = problemRecordService.getRecordsWithEarProblems();
            Map<String, Object> response = apiResponseService.createSuccessResponse(
                "Ear problem records retrieved", records, records.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = apiResponseService.createErrorResponse(
                "Failed to retrieve ear problem records: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
