-- Create FCM tokens table for storing Firebase Cloud Messaging tokens
CREATE TABLE fcm_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_nic VARCHAR(20) NOT NULL,
    user_name VARCHAR(255),
    user_role VARCHAR(50),
    fcm_token VARCHAR(500) NOT NULL,
    device_type VARCHAR(20) DEFAULT 'ANDROID',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_nic (user_nic),
    INDEX idx_fcm_token (fcm_token(255)),
    INDEX idx_active_tokens (user_nic, is_active),
    UNIQUE KEY unique_user_token (user_nic, fcm_token(255))
);
