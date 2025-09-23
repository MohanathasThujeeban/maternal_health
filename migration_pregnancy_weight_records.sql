-- Migration script for pregnancy weight records table
-- This table tracks current pregnancy measurements separate from pre-pregnancy data

CREATE TABLE IF NOT EXISTS pregnancy_weight_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    mother_nic VARCHAR(20) NOT NULL,
    current_weight DOUBLE,
    current_height DOUBLE,
    blood_pressure VARCHAR(20),
    pregnancy_week INTEGER,
    measurement_date DATE,
    midwife_notes TEXT,
    recorded_by VARCHAR(20),
    bmi_calculated DOUBLE,
    weight_gain_from_previous DOUBLE,
    is_high_risk_indicator BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Create index for efficient querying
    INDEX idx_mother_nic (mother_nic),
    INDEX idx_measurement_date (measurement_date),
    INDEX idx_pregnancy_week (pregnancy_week),
    INDEX idx_high_risk (is_high_risk_indicator),
    INDEX idx_recorded_by (recorded_by),
    INDEX idx_mother_date (mother_nic, measurement_date),
    INDEX idx_mother_week (mother_nic, pregnancy_week),
    
    -- Foreign key constraint to ensure mother exists
    FOREIGN KEY (mother_nic) REFERENCES maternal_profiles(nic) ON DELETE CASCADE
);

-- Add some sample data for testing (optional - can be commented out in production)
INSERT INTO pregnancy_weight_records (
    mother_nic, current_weight, current_height, blood_pressure, pregnancy_week, 
    measurement_date, midwife_notes, recorded_by, bmi_calculated, 
    weight_gain_from_previous, is_high_risk_indicator
) VALUES
-- Sample records for existing mothers (assuming they exist in maternal_profiles)
('123456789V', 65.5, 160, '120/80', 16, '2024-01-15', 'Normal weight gain progress', 'MW001', 25.6, 2.0, FALSE),
('987654321V', 58.2, 155, '115/75', 20, '2024-01-20', 'Slightly underweight, monitoring closely', 'MW001', 24.2, 1.5, FALSE),
('456789123V', 75.8, 165, '135/85', 28, '2024-01-25', 'Blood pressure slightly elevated, regular monitoring needed', 'MW002', 27.9, 3.2, TRUE);

-- Create a view for easy access to pregnancy weight records with mother information
CREATE OR REPLACE VIEW pregnancy_weight_records_with_mother_info AS
SELECT 
    pwr.*,
    mp.name as mother_name,
    mp.address as mother_address,
    mp.phone as mother_phone,
    mp.current_pregnancy_status,
    mp.last_menstrual_period,
    mp.expected_delivery_date,
    mp.pre_pregnancy_weight,
    (pwr.current_weight - mp.pre_pregnancy_weight) as total_weight_gain_from_pre_pregnancy,
    CASE 
        WHEN pwr.pregnancy_week <= 12 THEN 'First Trimester'
        WHEN pwr.pregnancy_week <= 26 THEN 'Second Trimester'
        WHEN pwr.pregnancy_week <= 42 THEN 'Third Trimester'
        ELSE 'Post Term'
    END as trimester_classification
FROM pregnancy_weight_records pwr
LEFT JOIN maternal_profiles mp ON pwr.mother_nic = mp.nic
ORDER BY pwr.measurement_date DESC;

-- Create a trigger to automatically update the updated_at timestamp
DELIMITER $$
CREATE TRIGGER pregnancy_weight_records_update_timestamp
    BEFORE UPDATE ON pregnancy_weight_records
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$
DELIMITER ;

-- Create a procedure to get weight gain statistics for a mother
DELIMITER $$
CREATE PROCEDURE GetMotherWeightGainStatistics(IN mother_nic_param VARCHAR(20))
BEGIN
    SELECT 
        COUNT(*) as total_records,
        MIN(measurement_date) as first_record_date,
        MAX(measurement_date) as latest_record_date,
        AVG(current_weight) as average_weight,
        MIN(current_weight) as min_weight,
        MAX(current_weight) as max_weight,
        AVG(weight_gain_from_previous) as average_weight_gain_between_visits,
        SUM(CASE WHEN is_high_risk_indicator = TRUE THEN 1 ELSE 0 END) as high_risk_record_count,
        AVG(bmi_calculated) as average_bmi,
        COUNT(DISTINCT pregnancy_week) as weeks_with_records
    FROM pregnancy_weight_records 
    WHERE mother_nic = mother_nic_param;
END$$
DELIMITER ;

-- Create a function to calculate recommended weight gain based on pre-pregnancy BMI
DELIMITER $$
CREATE FUNCTION GetRecommendedWeightGainRange(pre_pregnancy_bmi DOUBLE, pregnancy_week INT)
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE weight_gain_range VARCHAR(50);
    DECLARE total_recommended_min DOUBLE;
    DECLARE total_recommended_max DOUBLE;
    DECLARE weekly_gain_rate DOUBLE;
    
    -- Determine total recommended weight gain based on pre-pregnancy BMI
    IF pre_pregnancy_bmi < 18.5 THEN
        -- Underweight: 12.5-18 kg total
        SET total_recommended_min = 12.5;
        SET total_recommended_max = 18.0;
    ELSEIF pre_pregnancy_bmi <= 24.9 THEN
        -- Normal weight: 11.5-16 kg total
        SET total_recommended_min = 11.5;
        SET total_recommended_max = 16.0;
    ELSEIF pre_pregnancy_bmi <= 29.9 THEN
        -- Overweight: 7-11.5 kg total
        SET total_recommended_min = 7.0;
        SET total_recommended_max = 11.5;
    ELSE
        -- Obese: 5-9 kg total
        SET total_recommended_min = 5.0;
        SET total_recommended_max = 9.0;
    END IF;
    
    -- Calculate recommended gain for current week (assuming 40 weeks total pregnancy)
    IF pregnancy_week <= 12 THEN
        -- First trimester: 1-2 kg total
        SET weight_gain_range = CONCAT('1.0-2.0 kg (First Trimester)');
    ELSE
        -- Second and third trimester: divide remaining gain by remaining weeks
        SET weekly_gain_rate = (total_recommended_min + total_recommended_max) / 2 / 40;
        SET weight_gain_range = CONCAT(
            ROUND(weekly_gain_rate * pregnancy_week, 1), 
            '-', 
            ROUND((weekly_gain_rate * pregnancy_week) * 1.2, 1),
            ' kg (Week ', pregnancy_week, ')'
        );
    END IF;
    
    RETURN weight_gain_range;
END$$
DELIMITER ;