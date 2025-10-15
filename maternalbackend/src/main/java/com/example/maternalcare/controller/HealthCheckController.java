package com.example.maternalcare.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthCheckController {
    
    @GetMapping("/health")
    public Map<String, Object> healthCheck() {
        return Map.of(
            "status", "OK",
            "message", "Maternal Health Backend is running",
            "timestamp", LocalDateTime.now(),
            "server", "10.11.6.107:8080"
        );
    }
}
