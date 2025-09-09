-- Migration to add baby_id column to growth_entries table
-- This allows growth records to be associated with specific babies

ALTER TABLE growth_entries 
ADD COLUMN baby_id BIGINT;

-- Add foreign key constraint to maintain referential integrity
ALTER TABLE growth_entries 
ADD CONSTRAINT fk_growth_entries_baby 
FOREIGN KEY (baby_id) REFERENCES babies(id);

-- Create index for better query performance
CREATE INDEX idx_growth_entries_baby_id ON growth_entries(baby_id);
CREATE INDEX idx_growth_entries_mother_baby ON growth_entries(mother_nic, baby_id);

-- Update existing records to associate with first baby if they exist
-- This is optional - you might want to handle this differently based on your data
UPDATE growth_entries 
SET baby_id = (
    SELECT id 
    FROM babies 
    WHERE babies.mother_nic = growth_entries.mother_nic 
    AND babies.baby_order = 1 
    AND babies.is_active = true 
    LIMIT 1
) 
WHERE baby_id IS NULL;
