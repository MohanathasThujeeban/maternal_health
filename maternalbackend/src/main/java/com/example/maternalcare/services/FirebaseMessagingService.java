package com.example.maternalcare.services;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class FirebaseMessagingService {
    
    private static final Logger logger = LoggerFactory.getLogger(FirebaseMessagingService.class);
    
    // In-memory storage for FCM tokens (in production, use a database)
    private final Map<String, String> userTokens = new ConcurrentHashMap<>();
    
    @Autowired
    private FirebaseInitializationService firebaseInitializationService;
    
    /**
     * Send push notification to a specific user
     */
    public void sendNotificationToUser(String userNic, String title, String body, 
                                      String notificationType, String referenceId, 
                                      Map<String, String> additionalData) {
        try {
            String fcmToken = userTokens.get(userNic);
            
            if (fcmToken == null || fcmToken.trim().isEmpty()) {
                logger.warn("⚠️ No FCM token found for user: {}", userNic);
                return;
            }
            
            // Check if Firebase is initialized
            if (!firebaseInitializationService.isFirebaseInitialized()) {
                logger.warn("⚠️ Firebase is not initialized. Running in MOCK mode.");
                sendMockNotification(userNic, title, body, notificationType, additionalData);
                return;
            }
            
            // Prepare notification data
            Map<String, String> data = new HashMap<>();
            data.put("notificationType", notificationType);
            data.put("userNic", userNic);
            data.put("timestamp", String.valueOf(System.currentTimeMillis()));
            
            if (referenceId != null) {
                data.put("referenceId", referenceId);
            }
            
            if (additionalData != null) {
                data.putAll(additionalData);
            }
            
            // Build the notification
            Notification notification = Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build();
            
            // Build the message
            Message message = Message.builder()
                    .setNotification(notification)
                    .putAllData(data)
                    .setToken(fcmToken)
                    .build();
            
            // Send the message
            String response = FirebaseMessaging.getInstance().send(message);
            logger.info("✅ Successfully sent notification to user {}: {}", userNic, response);
            
        } catch (Exception e) {
            logger.error("❌ Failed to send notification to user {}: {}", userNic, e.getMessage());
            // Fallback to mock mode on any error
            sendMockNotification(userNic, title, body, notificationType, additionalData);
        }
    }
    
    /**
     * Send mock notification for development/testing
     */
    private void sendMockNotification(String userNic, String title, String body, 
                                    String notificationType, Map<String, String> additionalData) {
        logger.info("📱 [MOCK] Would send push notification to user: {}", userNic);
        logger.info("📧 [MOCK] Title: {}", title);
        logger.info("📧 [MOCK] Body: {}", body);
        logger.info("📧 [MOCK] Type: {}", notificationType);
        if (additionalData != null && !additionalData.isEmpty()) {
            logger.info("📊 [MOCK] Additional data: {}", additionalData);
        }
        logger.info("✅ [MOCK] Notification 'sent' successfully!");
    }
    
    /**
     * Send notification for email sent events
     */
    public void sendEmailNotification(String recipientNic, String emailSubject, String senderName) {
        String title = "📧 New Email Received";
        String body = String.format("You have received an email from %s: %s", senderName, emailSubject);
        
        Map<String, String> data = Map.of(
            "type", "EMAIL_SENT",
            "sender", senderName,
            "subject", emailSubject
        );
        
        sendNotificationToUser(recipientNic, title, body, "EMAIL_SENT", null, data);
    }
    
    /**
     * Register FCM token for a user
     */
    public void registerFCMToken(String userNic, String userName, String userRole, 
                                String fcmToken, String deviceType) {
        try {
            if (userNic == null || userNic.trim().isEmpty() || 
                fcmToken == null || fcmToken.trim().isEmpty()) {
                logger.warn("⚠️ Invalid user NIC or FCM token provided");
                return;
            }
            
            // Store the token (in production, save to database)
            userTokens.put(userNic.trim(), fcmToken.trim());
            
            logger.info("✅ FCM token registered for user: {} ({})", userNic, userName);
            logger.info("🔑 Token: {}...", fcmToken.substring(0, Math.min(20, fcmToken.length())));
            logger.info("📱 Device: {} | Role: {}", deviceType, userRole);
            
        } catch (Exception e) {
            logger.error("❌ Failed to register FCM token for user {}: {}", userNic, e.getMessage());
        }
    }
    
    /**
     * Get FCM token for a user
     */
    public String getFCMTokenForUser(String userNic) {
        return userTokens.get(userNic);
    }
    
    /**
     * Remove FCM token for a user
     */
    public void removeFCMToken(String userNic) {
        userTokens.remove(userNic);
        logger.info("🗑️ FCM token removed for user: {}", userNic);
    }
    
    /**
     * Send appointment reminder notification
     */
    public void sendAppointmentReminder(String userNic, String doctorName, String appointmentDate, String appointmentTime) {
        String title = "🩺 Appointment Reminder";
        String body = String.format("You have an appointment with Dr. %s on %s at %s", doctorName, appointmentDate, appointmentTime);
        
        Map<String, String> data = Map.of(
            "type", "APPOINTMENT_REMINDER",
            "doctorName", doctorName,
            "appointmentDate", appointmentDate,
            "appointmentTime", appointmentTime
        );
        
        sendNotificationToUser(userNic, title, body, "APPOINTMENT_REMINDER", null, data);
    }
    
    /**
     * Send health report notification
     */
    public void sendHealthReportNotification(String userNic, String reportType) {
        String title = "📊 Health Report Available";
        String body = String.format("Your %s report is now available to view", reportType);
        
        Map<String, String> data = Map.of(
            "type", "HEALTH_REPORT",
            "reportType", reportType
        );
        
        sendNotificationToUser(userNic, title, body, "HEALTH_REPORT", null, data);
    }
}
