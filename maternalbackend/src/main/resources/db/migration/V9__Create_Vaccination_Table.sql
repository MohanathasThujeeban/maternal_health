CREATE TABLE IF NOT EXISTS vaccinations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    mother_nic VARCHAR(15) NOT NULL,
    child_name VARCHAR(100) NOT NULL,
    vaccination_type VARCHAR(100) NOT NULL,
    age_to_give VARCHAR(50) NOT NULL,
    vaccination_date DATE,
    batch_number VARCHAR(50),
    effects_following_immunization TEXT,
    status ENUM('PENDING', 'COMPLETED', 'MISSED') NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_mother_nic (mother_nic),
    INDEX idx_vaccination_date (vaccination_date),
    INDEX idx_status (status)
);
