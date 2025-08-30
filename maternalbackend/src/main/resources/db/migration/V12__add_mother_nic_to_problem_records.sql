-- Add mother_nic column to problem_records table to link records to mothers
ALTER TABLE problem_records 
ADD COLUMN mother_nic VARCHAR(255);

-- Create index for faster queries by mother_nic
CREATE INDEX idx_problem_records_mother_nic ON problem_records(mother_nic);

-- Update existing records with sample data (optional - can be removed in production)
-- This is just for testing purposes
UPDATE problem_records 
SET mother_nic = '200201901851' 
WHERE mother_nic IS NULL;
