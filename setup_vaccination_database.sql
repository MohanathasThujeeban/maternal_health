-- Create vaccination table if it doesn't exist
CREATE TABLE IF NOT EXISTS vaccination (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    mother_nic VARCHAR(20) NOT NULL,
    child_name VARCHAR(255),
    vaccination_type VARCHAR(255) NOT NULL,
    age_to_give VARCHAR(100),
    vaccination_date DATE,
    batch_number VARCHAR(100),
    effects_following_immunization TEXT,
    status ENUM('PENDING', 'COMPLETED', 'MISSED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_mother_nic (mother_nic),
    INDEX idx_status (status),
    INDEX idx_vaccination_type (vaccination_type)
);

-- Check if registration table exists and has data
SELECT COUNT(*) as total_mothers FROM registration;

-- Show first 5 registered mothers to get actual NICs
SELECT nic, name, email FROM registration LIMIT 5;

-- Clear any existing vaccination data (optional - uncomment if needed)
-- DELETE FROM vaccination;

-- Insert vaccination records for actual registered mothers
-- Note: Replace these NICs with actual NICs from your registration table
INSERT IGNORE INTO vaccination (
    mother_nic, child_name, vaccination_type, age_to_give, 
    vaccination_date, batch_number, effects_following_immunization, status, 
    created_at, updated_at
) 
SELECT 
    r.nic as mother_nic,
    CONCAT('Baby of ', SUBSTRING(r.name, 1, LOCATE(' ', r.name) - 1)) as child_name,
    'BCG' as vaccination_type,
    'At birth' as age_to_give,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY) as vaccination_date,
    CONCAT('BCG2025', LPAD(FLOOR(RAND() * 999) + 1, 3, '0')) as batch_number,
    'None' as effects_following_immunization,
    'COMPLETED' as status,
    NOW() as created_at,
    NOW() as updated_at
FROM registration r
WHERE r.role = 'mother' 
LIMIT 10;

-- Insert Hepatitis B vaccination records
INSERT IGNORE INTO vaccination (
    mother_nic, child_name, vaccination_type, age_to_give, 
    vaccination_date, batch_number, effects_following_immunization, status, 
    created_at, updated_at
) 
SELECT 
    r.nic as mother_nic,
    CONCAT('Baby of ', SUBSTRING(r.name, 1, LOCATE(' ', r.name) - 1)) as child_name,
    'Hepatitis B' as vaccination_type,
    '0-24 hours' as age_to_give,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY) as vaccination_date,
    CONCAT('HEP2025', LPAD(FLOOR(RAND() * 999) + 1, 3, '0')) as batch_number,
    'None' as effects_following_immunization,
    'COMPLETED' as status,
    NOW() as created_at,
    NOW() as updated_at
FROM registration r
WHERE r.role = 'mother' 
LIMIT 10;

-- Insert DPT (1st dose) vaccination records
INSERT IGNORE INTO vaccination (
    mother_nic, child_name, vaccination_type, age_to_give, 
    vaccination_date, batch_number, effects_following_immunization, status, 
    created_at, updated_at
) 
SELECT 
    r.nic as mother_nic,
    CONCAT('Baby of ', SUBSTRING(r.name, 1, LOCATE(' ', r.name) - 1)) as child_name,
    'DPT (1st dose)' as vaccination_type,
    '6 weeks' as age_to_give,
    CASE 
        WHEN RAND() > 0.3 THEN DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 60) DAY)
        ELSE NULL 
    END as vaccination_date,
    CASE 
        WHEN RAND() > 0.3 THEN CONCAT('DPT2025', LPAD(FLOOR(RAND() * 999) + 1, 3, '0'))
        ELSE '' 
    END as batch_number,
    CASE 
        WHEN RAND() > 0.8 THEN 'Mild fever for 1 day'
        WHEN RAND() > 0.3 THEN 'None'
        ELSE '' 
    END as effects_following_immunization,
    CASE 
        WHEN RAND() > 0.3 THEN 'COMPLETED'
        ELSE 'PENDING' 
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM registration r
WHERE r.role = 'mother' 
LIMIT 10;

-- Insert OPV (1st dose) vaccination records
INSERT IGNORE INTO vaccination (
    mother_nic, child_name, vaccination_type, age_to_give, 
    vaccination_date, batch_number, effects_following_immunization, status, 
    created_at, updated_at
) 
SELECT 
    r.nic as mother_nic,
    CONCAT('Baby of ', SUBSTRING(r.name, 1, LOCATE(' ', r.name) - 1)) as child_name,
    'OPV (1st dose)' as vaccination_type,
    '6 weeks' as age_to_give,
    CASE 
        WHEN RAND() > 0.3 THEN DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 60) DAY)
        ELSE NULL 
    END as vaccination_date,
    CASE 
        WHEN RAND() > 0.3 THEN CONCAT('OPV2025', LPAD(FLOOR(RAND() * 999) + 1, 3, '0'))
        ELSE '' 
    END as batch_number,
    'None' as effects_following_immunization,
    CASE 
        WHEN RAND() > 0.3 THEN 'COMPLETED'
        ELSE 'PENDING' 
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM registration r
WHERE r.role = 'mother' 
LIMIT 10;

-- Insert MMR vaccination records (mostly pending as it's for 12 months)
INSERT IGNORE INTO vaccination (
    mother_nic, child_name, vaccination_type, age_to_give, 
    vaccination_date, batch_number, effects_following_immunization, status, 
    created_at, updated_at
) 
SELECT 
    r.nic as mother_nic,
    CONCAT('Baby of ', SUBSTRING(r.name, 1, LOCATE(' ', r.name) - 1)) as child_name,
    'MMR' as vaccination_type,
    '12 months' as age_to_give,
    NULL as vaccination_date,
    '' as batch_number,
    '' as effects_following_immunization,
    'PENDING' as status,
    NOW() as created_at,
    NOW() as updated_at
FROM registration r
WHERE r.role = 'mother' 
LIMIT 10;

-- Show vaccination summary by status
SELECT 
    status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vaccination), 2) as percentage
FROM vaccination 
GROUP BY status;

-- Show vaccination records by mother (first 5 mothers)
SELECT 
    v.mother_nic,
    r.name as mother_name,
    COUNT(*) as total_vaccinations,
    SUM(CASE WHEN v.status = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
    SUM(CASE WHEN v.status = 'PENDING' THEN 1 ELSE 0 END) as pending
FROM vaccination v
JOIN registration r ON v.mother_nic = r.nic
GROUP BY v.mother_nic, r.name
LIMIT 5;
