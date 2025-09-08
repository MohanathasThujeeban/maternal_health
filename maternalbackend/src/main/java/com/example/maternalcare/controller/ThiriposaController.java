package com.example.maternalcare.controller;

import com.example.maternalcare.dto.ThiriposaRecordDTO;
import com.example.maternalcare.services.ThiriposaService;
import com.example.maternalcare.service.ThiriposaEmailService;
import com.example.maternalcare.util.JwtTokenUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

@RestController
@RequestMapping("/api/thiriposa")
public class ThiriposaController {

    private static final Logger logger = Logger.getLogger(ThiriposaController.class.getName());

    @Autowired
    private ThiriposaService thiriposaService;

    @Autowired
    private ThiriposaEmailService thiriposaEmailService;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @PostMapping("/add")
    public ResponseEntity<ThiriposaRecordDTO> addRecord(
            @RequestBody ThiriposaRecordDTO recordDTO,
            @RequestParam(value = "midwifeName", defaultValue = "Healthcare Provider") String midwifeName,
            @RequestParam(value = "sendEmail", defaultValue = "true") boolean sendEmail) {
        try {
            ThiriposaRecordDTO savedRecord = thiriposaService.addRecord(recordDTO);
            
            // Send confirmation email if requested
            if (sendEmail) {
                try {
                    thiriposaService.sendThiriposaConfirmationEmail(savedRecord, midwifeName);
                    logger.info("Email notification sent for Thiriposa record: " + savedRecord.getId());
                } catch (Exception emailException) {
                    logger.log(Level.WARNING, "Failed to send email notification for record: " + savedRecord.getId(), emailException);
                    // Don't fail the entire request if email fails
                }
            }
            
            return new ResponseEntity<>(savedRecord, HttpStatus.CREATED);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to add Thiriposa record", e);
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
    
    // Baby-specific endpoints for midwife use
    @GetMapping("/baby/{babyId}")
    public ResponseEntity<List<ThiriposaRecordDTO>> getRecordsByBaby(@PathVariable Long babyId) {
        try {
            List<ThiriposaRecordDTO> records = thiriposaService.getRecordsByBaby(babyId);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/mother/{motherNic}/baby/{babyId}")
    public ResponseEntity<List<ThiriposaRecordDTO>> getRecordsByMotherAndBaby(
            @PathVariable String motherNic, 
            @PathVariable Long babyId) {
        try {
            List<ThiriposaRecordDTO> records = thiriposaService.getRecordsByMotherAndBaby(motherNic, babyId);
            return new ResponseEntity<>(records, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Thiriposa API is working!");
    }

    // Test email endpoint
    @PostMapping("/test-email")
    public ResponseEntity<String> testEmail(@RequestParam String email) {
        try {
            thiriposaEmailService.sendTestEmail(email);
            return ResponseEntity.ok("Test email sent successfully to: " + email);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to send test email", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to send test email: " + e.getMessage());
        }
    }

    // Email configuration check endpoint
    @GetMapping("/email-status")
    public ResponseEntity<String> checkEmailConfiguration() {
        try {
            boolean isValid = thiriposaEmailService.isEmailConfigurationValid();
            if (isValid) {
                return ResponseEntity.ok("Email configuration is valid and ready");
            } else {
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .body("Email configuration has issues");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to check email configuration: " + e.getMessage());
        }
    }
}
