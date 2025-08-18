-- Healthcare Provider Migration Script
-- This script adds the healthcare_providers table and related structures
-- Run this after the main database setup

USE maternaldb;

-- Create the healthcare_providers table
CREATE TABLE IF NOT EXISTS healthcare_providers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    medical_license_number VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    provider_type ENUM('MIDWIFE', 'DOCTOR', 'NURSE', 'SPECIALIST') NOT NULL,
    specialization VARCHAR(200),
    hospital_affiliation VARCHAR(200),
    years_of_experience INT,
    education_background TEXT,
    languages_spoken VARCHAR(500),
    
    -- Professional details
    license_expiry_date DATE,
    registration_number VARCHAR(50),
    professional_body VARCHAR(200),
    
    -- Contact and location
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Sri Lanka',
    postal_code VARCHAR(20),
    
    -- Account status and verification
    is_approved BOOLEAN DEFAULT FALSE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    approval_date DATETIME NULL,
    approved_by BIGINT NULL, -- Reference to admin user who approved
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    INDEX idx_medical_license (medical_license_number),
    INDEX idx_email (email),
    INDEX idx_provider_type (provider_type),
    INDEX idx_approved (is_approved),
    INDEX idx_email_verified (is_email_verified)
);

-- Create a table for healthcare provider verification tokens (for email verification)
CREATE TABLE IF NOT EXISTS healthcare_provider_verification_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    provider_id BIGINT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (provider_id) REFERENCES healthcare_providers(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_provider_id (provider_id),
    INDEX idx_expires_at (expires_at)
);

-- Create a table for healthcare provider sessions/login tracking (optional)
CREATE TABLE IF NOT EXISTS healthcare_provider_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    provider_id BIGINT NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (provider_id) REFERENCES healthcare_providers(id) ON DELETE CASCADE,
    INDEX idx_session_token (session_token),
    INDEX idx_provider_id (provider_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_active (is_active)
);

-- Create a view for approved healthcare providers (for easy querying)
CREATE OR REPLACE VIEW approved_healthcare_providers AS
SELECT 
    id,
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) as full_name,
    email,
    phone,
    medical_license_number,
    provider_type,
    specialization,
    hospital_affiliation,
    years_of_experience,
    languages_spoken,
    city,
    state,
    country,
    approval_date,
    created_at
FROM healthcare_providers 
WHERE is_approved = TRUE AND is_email_verified = TRUE;

-- Insert some test data for development (uncomment if needed for testing)
/*
INSERT INTO healthcare_providers (
    first_name, last_name, email, phone, medical_license_number, 
    password, provider_type, specialization, hospital_affiliation, 
    years_of_experience, is_approved, is_email_verified
) VALUES 
(
    'Dr. Sarah', 'Johnson', 'dr.sarah@hospital.lk', '+94712345678', 'ML001234', 
    '$2a$10$example.hash.here', 'DOCTOR', 'Obstetrics & Gynecology', 
    'National Hospital of Sri Lanka', 15, TRUE, TRUE
),
(
    'Midwife Mary', 'Fernando', 'mary.midwife@clinic.lk', '+94787654321', 'MW005678', 
    '$2a$10$example.hash.here', 'MIDWIFE', 'Maternal Care', 
    'Colombo Maternity Hospital', 8, TRUE, TRUE
);
*/

-- Show the created tables
SHOW TABLES LIKE '%healthcare_provider%';

-- Display table structure
DESCRIBE healthcare_providers;

-- Show grants for the application user
SHOW GRANTS FOR 'maternal_user'@'%';

COMMIT;
