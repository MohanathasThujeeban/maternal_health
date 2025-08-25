-- Sample vaccination data for testing
-- Mother NIC: 200184210125 (from debug logs)

INSERT INTO vaccinations (mother_nic, child_name, vaccination_type, age_to_give, vaccination_date, batch_number, effects_following_immunization, status, created_at, updated_at) VALUES
('200184210125', 'Baby Silva', 'BCG', 'At birth', '2025-01-15', 'BCG2025001', 'None', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'Hepatitis B', 'At birth', '2025-01-15', 'HEP2025001', 'None', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'DPT (1st dose)', '2 months', '2025-03-15', 'DPT2025001', 'Mild fever', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'OPV (1st dose)', '2 months', '2025-03-15', 'OPV2025001', 'None', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'DPT (2nd dose)', '4 months', '2025-05-15', 'DPT2025002', 'None', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'OPV (2nd dose)', '4 months', '2025-05-15', 'OPV2025002', 'None', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'DPT (3rd dose)', '6 months', '2025-07-15', 'DPT2025003', 'None', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'OPV (3rd dose)', '6 months', '2025-07-15', 'OPV2025003', 'None', 'COMPLETED', NOW(), NOW()),
('200184210125', 'Baby Silva', 'MMR', '12 months', NULL, '', '', 'PENDING', NOW(), NOW()),
('200184210125', 'Baby Silva', 'Varicella', '15 months', NULL, '', '', 'PENDING', NOW(), NOW());

-- Add some data for other mothers for testing midwife dashboard
INSERT INTO vaccinations (mother_nic, child_name, vaccination_type, age_to_give, vaccination_date, batch_number, effects_following_immunization, status, created_at, updated_at) VALUES
('199612345678', 'Baby Fernando', 'BCG', 'At birth', '2025-02-01', 'BCG2025002', 'None', 'COMPLETED', NOW(), NOW()),
('199612345678', 'Baby Fernando', 'Hepatitis B', 'At birth', '2025-02-01', 'HEP2025002', 'None', 'COMPLETED', NOW(), NOW()),
('199612345678', 'Baby Fernando', 'DPT (1st dose)', '2 months', '2025-04-01', 'DPT2025004', 'None', 'COMPLETED', NOW(), NOW()),
('199612345678', 'Baby Fernando', 'OPV (1st dose)', '2 months', NULL, '', '', 'PENDING', NOW(), NOW()),
('198503456789', 'Baby Perera', 'BCG', 'At birth', '2025-03-01', 'BCG2025003', 'None', 'COMPLETED', NOW(), NOW()),
('198503456789', 'Baby Perera', 'Hepatitis B', 'At birth', NULL, '', '', 'PENDING', NOW(), NOW());