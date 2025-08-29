-- V11__create_maternal_profiles_table.sql

START TRANSACTION;

DROP TABLE IF EXISTS maternal_profiles;

CREATE TABLE maternal_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Mother Information
    mother_nic VARCHAR(12) NOT NULL UNIQUE,
    
    -- Personal Information
    date_of_birth DATE,
    age INT,
    religion VARCHAR(50),
    ethnicity VARCHAR(50),
    education_level VARCHAR(100),
    occupation VARCHAR(100),
    monthly_income DECIMAL(10,2),
    
    -- Father's Information
    father_name VARCHAR(100),
    father_nic VARCHAR(12),
    father_age INT,
    father_occupation VARCHAR(100),
    father_phone VARCHAR(15),
    
    -- Address Information
    house_number VARCHAR(20),
    street_address VARCHAR(200),
    city VARCHAR(100),
    district VARCHAR(50),
    province VARCHAR(50),
    postal_code VARCHAR(10),
    gs_division VARCHAR(100),
    ds_division VARCHAR(100),
    moh_area VARCHAR(100),
    phm_area VARCHAR(100),
    
    -- Emergency Contact
    emergency_contact_name VARCHAR(100),
    emergency_contact_relationship VARCHAR(50),
    emergency_contact_phone VARCHAR(15),
    
    -- Pregnancy Information
    number_of_pregnancies INT DEFAULT 0,
    number_of_live_births INT DEFAULT 0,
    number_of_stillbirths INT DEFAULT 0,
    number_of_abortions INT DEFAULT 0,
    number_of_living_children INT DEFAULT 0,
    last_menstrual_period DATE,
    expected_delivery_date DATE,
    current_pregnancy_week INT,
    current_pregnancy_status VARCHAR(50),
    pre_pregnancy_weight DECIMAL(5,2),
    pre_pregnancy_height DECIMAL(5,2),
    pre_pregnancy_bmi DECIMAL(5,2),
    
    -- Medical History
    blood_type VARCHAR(10),
    rhesus_factor VARCHAR(10),
    chronic_diseases TEXT,
    allergies TEXT,
    medications TEXT,
    previous_pregnancy_complications TEXT,
    family_medical_history TEXT,
    
    -- Lifestyle Information
    smoking_status BOOLEAN DEFAULT FALSE,
    alcohol_consumption BOOLEAN DEFAULT FALSE,
    exercise_routine VARCHAR(200),
    dietary_restrictions TEXT,
    nutritional_supplements TEXT,
    
    -- Profile Photo
    profile_photo_url TEXT,
    profile_photo_filename VARCHAR(255),
    
    -- Additional Notes
    special_notes TEXT,
    midwife_notes TEXT,
    
    -- Status and Timestamps
    profile_completed BOOLEAN DEFAULT FALSE,
    is_high_risk_pregnancy BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(12),
    
    -- Foreign Key Constraints
    FOREIGN KEY (mother_nic) REFERENCES registration(nic_number) ON DELETE CASCADE,
    FOREIGN KEY (last_updated_by) REFERENCES registration(nic_number)
) ENGINE=InnoDB;

-- Create indexes for better performance
CREATE INDEX idx_maternal_profiles_mother_nic ON maternal_profiles(mother_nic);
CREATE INDEX idx_maternal_profiles_district ON maternal_profiles(district);
CREATE INDEX idx_maternal_profiles_gs_division ON maternal_profiles(gs_division);
CREATE INDEX idx_maternal_profiles_moh_area ON maternal_profiles(moh_area);
CREATE INDEX idx_maternal_profiles_phm_area ON maternal_profiles(phm_area);
CREATE INDEX idx_maternal_profiles_pregnancy_status ON maternal_profiles(current_pregnancy_status);
CREATE INDEX idx_maternal_profiles_high_risk ON maternal_profiles(is_high_risk_pregnancy);
CREATE INDEX idx_maternal_profiles_edd ON maternal_profiles(expected_delivery_date);

COMMIT;
