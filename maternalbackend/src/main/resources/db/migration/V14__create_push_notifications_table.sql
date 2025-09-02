-- Create push notifications table for tracking sent notifications
CREATE TABLE push_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recipient_nic VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    notification_type VARCHAR(50),
    reference_id VARCHAR(100),
    data TEXT,
    sent_at TIMESTAMP NULL,
    delivery_status VARCHAR(20) DEFAULT 'PENDING',
    firebase_message_id VARCHAR(255),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_recipient_nic (recipient_nic),
    INDEX idx_notification_type (notification_type),
    INDEX idx_delivery_status (delivery_status),
    INDEX idx_created_at (created_at),
    INDEX idx_reference_id (reference_id, notification_type)
);
