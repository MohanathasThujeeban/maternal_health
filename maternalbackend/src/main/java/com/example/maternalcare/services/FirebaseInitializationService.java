package com.example.maternalcare.services;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;

@Service
public class FirebaseInitializationService {
    
    private static final Logger logger = LoggerFactory.getLogger(FirebaseInitializationService.class);
    
    @Value("${firebase.service-account-key-path:}")
    private String serviceAccountKeyPath;
    
    private boolean firebaseInitialized = false;
    
    @PostConstruct
    public void initializeFirebase() {
        try {
            // Check if Firebase is already initialized
            if (!FirebaseApp.getApps().isEmpty()) {
                logger.info("✅ Firebase already initialized");
                firebaseInitialized = true;
                return;
            }
            
            // Try to initialize Firebase with service account key
            if (serviceAccountKeyPath != null && !serviceAccountKeyPath.trim().isEmpty()) {
                try {
                    FileInputStream serviceAccount = new FileInputStream(serviceAccountKeyPath);
                    
                    FirebaseOptions options = FirebaseOptions.builder()
                            .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                            .build();
                    
                    FirebaseApp.initializeApp(options);
                    firebaseInitialized = true;
                    logger.info("✅ Firebase initialized successfully with service account key");
                    
                } catch (IOException e) {
                    logger.error("❌ Failed to initialize Firebase with service account key: {}", e.getMessage());
                    initializeFirebaseWithoutServiceAccount();
                }
            } else {
                logger.warn("⚠️ No Firebase service account key path configured");
                initializeFirebaseWithoutServiceAccount();
            }
            
        } catch (Exception e) {
            logger.error("❌ Failed to initialize Firebase: {}", e.getMessage());
            firebaseInitialized = false;
        }
    }
    
    private void initializeFirebaseWithoutServiceAccount() {
        try {
            // Try to initialize with default credentials (for development)
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.getApplicationDefault())
                    .build();
            
            FirebaseApp.initializeApp(options);
            firebaseInitialized = true;
            logger.info("✅ Firebase initialized with default credentials");
            
        } catch (Exception e) {
            logger.warn("⚠️ Firebase not initialized - push notifications will not work: {}", e.getMessage());
            logger.info("💡 To enable push notifications:");
            logger.info("   1. Download Firebase service account key JSON file");
            logger.info("   2. Place it in src/main/resources/");
            logger.info("   3. Set firebase.service-account-key-path in application.properties");
            firebaseInitialized = false;
        }
    }
    
    public boolean isFirebaseInitialized() {
        return firebaseInitialized;
    }
    
    public void refreshFirebaseInitialization() {
        logger.info("🔄 Refreshing Firebase initialization...");
        initializeFirebase();
    }
}
