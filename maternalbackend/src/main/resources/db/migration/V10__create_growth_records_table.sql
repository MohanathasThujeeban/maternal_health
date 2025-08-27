START TRANSACTION;

DROP TABLE IF EXISTS growth_records;

CREATE TABLE growth_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    mother_nic VARCHAR(12) NOT NULL,
    height DOUBLE NOT NULL,
    weight DOUBLE NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (mother_nic) REFERENCES registration(nic_number)
) ENGINE=InnoDB;

CREATE INDEX idx_growth_records_mother_nic ON growth_records(mother_nic);

COMMIT;
