-- Migration script for adding multi-baby support
-- This script adds baby_id support to existing tables and creates the babies table

-- Create babies table
CREATE TABLE IF NOT EXISTS `babies` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `mother_nic` varchar(15) NOT NULL,
  `baby_name` varchar(100) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `birth_weight` double DEFAULT NULL,
  `birth_height` double DEFAULT NULL,
  `baby_order` int(11) NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_mother_nic` (`mother_nic`),
  KEY `idx_mother_nic_order` (`mother_nic`, `baby_order`),
  KEY `idx_mother_nic_name` (`mother_nic`, `baby_name`),
  FOREIGN KEY (`mother_nic`) REFERENCES `registration` (`nic_number`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Add baby_id column to vaccinations table (if it exists)
-- This column is optional to maintain backward compatibility
ALTER TABLE `vaccinations` 
ADD COLUMN IF NOT EXISTS `baby_id` bigint(20) DEFAULT NULL,
ADD KEY IF NOT EXISTS `idx_baby_id` (`baby_id`),
ADD KEY IF NOT EXISTS `idx_mother_nic_baby_id` (`mother_nic`, `baby_id`);

-- Add baby_id column to growth_records table (if it exists)
-- This column is optional to maintain backward compatibility
ALTER TABLE `growth_records` 
ADD COLUMN IF NOT EXISTS `baby_id` bigint(20) DEFAULT NULL,
ADD KEY IF NOT EXISTS `idx_baby_id` (`baby_id`),
ADD KEY IF NOT EXISTS `idx_mother_nic_baby_id` (`mother_nic`, `baby_id`);

-- Add baby_id column to appointments table
-- This column is optional to maintain backward compatibility
ALTER TABLE `appointments` 
ADD COLUMN IF NOT EXISTS `baby_id` bigint(20) DEFAULT NULL,
ADD KEY IF NOT EXISTS `idx_baby_id` (`baby_id`),
ADD KEY IF NOT EXISTS `idx_mother_nic_baby_id` (`mother_nic`, `baby_id`);

-- Add baby_id column to baby_problems table (if it exists)
ALTER TABLE `baby_problems` 
ADD COLUMN IF NOT EXISTS `baby_id` bigint(20) DEFAULT NULL,
ADD KEY IF NOT EXISTS `idx_baby_id` (`baby_id`),
ADD KEY IF NOT EXISTS `idx_mother_nic_baby_id` (`mother_nic`, `baby_id`);

-- Insert sample data for existing mothers who don't have baby records
-- This creates a default "1st child" for each existing mother
INSERT INTO `babies` (`mother_nic`, `baby_name`, `baby_order`, `is_active`, `created_at`, `updated_at`)
SELECT 
    r.nic_number as mother_nic,
    CONCAT('Baby of ', r.full_name) as baby_name,
    1 as baby_order,
    1 as is_active,
    NOW() as created_at,
    NOW() as updated_at
FROM `registration` r 
WHERE r.nic_number NOT IN (SELECT DISTINCT mother_nic FROM `babies` WHERE is_active = 1)
  AND EXISTS (
    SELECT 1 FROM `vaccinations` v WHERE v.mother_nic = r.nic_number
    UNION
    SELECT 1 FROM `growth_records` gr WHERE gr.mother_nic = r.nic_number
    UNION 
    SELECT 1 FROM `appointments` a WHERE a.mother_nic = r.nic_number
  );

-- Update existing vaccination records to link to the default baby
UPDATE `vaccinations` v 
SET baby_id = (
    SELECT b.id 
    FROM `babies` b 
    WHERE b.mother_nic = v.mother_nic 
      AND b.baby_order = 1 
      AND b.is_active = 1 
    LIMIT 1
)
WHERE v.baby_id IS NULL;

-- Update existing growth records to link to the default baby
UPDATE `growth_records` gr 
SET baby_id = (
    SELECT b.id 
    FROM `babies` b 
    WHERE b.mother_nic = gr.mother_nic 
      AND b.baby_order = 1 
      AND b.is_active = 1 
    LIMIT 1
)
WHERE gr.baby_id IS NULL;

-- Update existing appointment records to link to the default baby
UPDATE `appointments` a 
SET baby_id = (
    SELECT b.id 
    FROM `babies` b 
    WHERE b.mother_nic = a.mother_nic 
      AND b.baby_order = 1 
      AND b.is_active = 1 
    LIMIT 1
)
WHERE a.baby_id IS NULL;

-- Update existing baby problem records to link to the default baby (if table exists)
UPDATE `baby_problems` bp 
SET baby_id = (
    SELECT b.id 
    FROM `babies` b 
    WHERE b.mother_nic = bp.mother_nic 
      AND b.baby_order = 1 
      AND b.is_active = 1 
    LIMIT 1
)
WHERE bp.baby_id IS NULL;
