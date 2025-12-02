-- Migration script to add is_active column to registration table if not exists
-- This ensures user suspension functionality works properly

-- Add is_active column if it doesn't exist
ALTER TABLE registration 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- Update any NULL values to TRUE (should not happen with the constraint above, but for safety)
UPDATE registration 
SET is_active = TRUE 
WHERE is_active IS NULL;

-- Add index for performance on active user queries
CREATE INDEX IF NOT EXISTS idx_registration_is_active ON registration(is_active);
CREATE INDEX IF NOT EXISTS idx_registration_user_role ON registration(user_role);
CREATE INDEX IF NOT EXISTS idx_registration_nic ON registration(nic_number);

-- Display current user count by role and status
SELECT 
    user_role,
    is_active,
    COUNT(*) as user_count
FROM registration
GROUP BY user_role, is_active
ORDER BY user_role, is_active DESC;
