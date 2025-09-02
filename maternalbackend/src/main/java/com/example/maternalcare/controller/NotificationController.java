package com.example.maternalcare.controller;

import com.example.maternalcare.services.FirebaseMessagingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {
    
    private static final Logger logger = LoggerFactory.getLogger(NotificationController.class);
    
    @Autowired
    private FirebaseMessagingService firebaseMessagingService;
    
    /**
     * Register FCM token for push notifications
     */
    @PostMapping("/register-token")
    public ResponseEntity<Map<String, Object>> registerFCMToken(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userNic = request.get("userNic");
            String userName = request.get("userName");
            String userRole = request.get("userRole");
            String fcmToken = request.get("fcmToken");
            String deviceType = request.get("deviceType");
            
            // Validate required fields
            if (userNic == null || userNic.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "User NIC is required");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (fcmToken == null || fcmToken.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "FCM token is required");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Register FCM token
            firebaseMessagingService.registerFCMToken(
                userNic.trim(), 
                userName != null ? userName.trim() : "Unknown", 
                userRole != null ? userRole.trim() : "USER", 
                fcmToken.trim(), 
                deviceType != null ? deviceType.trim() : "Android"
            );
            
            response.put("success", true);
            response.put("message", "FCM token registered successfully");
            
            logger.info("✅ FCM token registered for user: {}", userNic);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("❌ Error registering FCM token: {}", e.getMessage());
            response.put("success", false);
            response.put("message", "Failed to register FCM token: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * Send test push notification
     */
    @PostMapping("/send-test")
    public ResponseEntity<Map<String, Object>> sendTestNotification(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userNic = request.get("userNic");
            String title = request.getOrDefault("title", "Test Notification");
            String body = request.getOrDefault("body", "This is a test notification from Maternal Health App");
            
            if (userNic == null || userNic.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "User NIC is required");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Send test notification
            Map<String, String> additionalData = Map.of(
                "type", "TEST_NOTIFICATION",
                "timestamp", String.valueOf(System.currentTimeMillis())
            );
            
            firebaseMessagingService.sendNotificationToUser(
                userNic.trim(), 
                title, 
                body, 
                "TEST", 
                "test-" + System.currentTimeMillis(), 
                additionalData
            );
            
            response.put("success", true);
            response.put("message", "Test notification sent successfully");
            
            logger.info("✅ Test notification sent to user: {}", userNic);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("❌ Error sending test notification: {}", e.getMessage());
            response.put("success", false);
            response.put("message", "Failed to send test notification: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * Health check endpoint for notification service
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "Notification Controller");
        response.put("status", "OK");
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }
}
