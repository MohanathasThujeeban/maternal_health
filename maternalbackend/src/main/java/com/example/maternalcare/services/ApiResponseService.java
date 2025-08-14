
package com.example.maternalcare.services;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
public class ApiResponseService {
    
    public Map<String, Object> createSuccessResponse(String message, Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", message);
        response.put("data", data);
        response.put("timestamp", LocalDateTime.now());
        return response;
    }
    
    public Map<String, Object> createSuccessResponse(String message, Object data, int count) {
        Map<String, Object> response = createSuccessResponse(message, data);
        response.put("count", count);
        return response;
    }
    
    public Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        response.put("timestamp", LocalDateTime.now());
        return response;
    }
    
    public Map<String, Object> createErrorResponse(String message, Object errors) {
        Map<String, Object> response = createErrorResponse(message);
        response.put("errors", errors);
        return response;
    }
}

