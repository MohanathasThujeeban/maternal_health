-- Fix Thiriposa Records Table Schema
DROP TABLE IF EXISTS thiriposa_records;

CREATE TABLE thiriposa_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    mother_nic VARCHAR(20) NOT NULL,
    supply_date TIMESTAMP NOT NULL,
    quantity INT NOT NULL,
    midwife_id BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_thiriposa_mother_nic FOREIGN KEY (mother_nic) REFERENCES registration(nic_number) ON DELETE CASCADE,
    INDEX idx_thiriposa_mother_nic (mother_nic),
    INDEX idx_thiriposa_supply_date (supply_date)
);
