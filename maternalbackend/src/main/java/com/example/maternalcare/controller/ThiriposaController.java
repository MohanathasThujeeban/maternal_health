package com.example.maternalcare.controller;

import com.example.maternalcare.dto.ThiriposaRecordDTO;
import com.example.maternalcare.services.ThiriposaService;
import com.example.maternalcare.util.JwtTokenUtil;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/thiriposa")
public class ThiriposaController {

    @Autowired
    private ThiriposaService thiriposaService;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @PostMapping("/add")
    public ResponseEntity<ThiriposaRecordDTO> addRecord(@RequestBody ThiriposaRecordDTO recordDTO) {
        try {
            ThiriposaRecordDTO savedRecord = thiriposaService.addRecord(recordDTO);
            return new ResponseEntity<>(savedRecord, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/records/{nic}")
    public ResponseEntity<List<ThiriposaRecordDTO>> getRecordsByNic(@PathVariable String nic) {
        try {
            List<ThiriposaRecordDTO> records = thiriposaService.getRecordsByNic(nic);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/my-records")
    public ResponseEntity<List<ThiriposaRecordDTO>> getMyRecords(@RequestHeader("Authorization") String token) {
        try {
            // Extract token from "Bearer <token>"
            String jwtToken = token.substring(7);
            String motherNic = jwtTokenUtil.extractNicFromToken(jwtToken);
            List<ThiriposaRecordDTO> records = thiriposaService.getRecordsByNic(motherNic);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/all")
    public ResponseEntity<List<ThiriposaRecordDTO>> getAllRecords() {
        try {
            List<ThiriposaRecordDTO> records = thiriposaService.getAllRecords();
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Thiriposa API is working!");
    }
}
