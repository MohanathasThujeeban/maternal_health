sql 
CREATE TABLE IF NOT EXISTS problem_records ( 
    id BIGINT AUTO_INCREMENT PRIMARY KEY, 
    patient_name VARCHAR(255) NOT NULL, 
    eye_problem VARCHAR(255), 
    ear_problem VARCHAR(255), 
    symptoms_duration VARCHAR(255), 
    remarks TEXT, 
    date_of_diagnosis DATE NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
     );