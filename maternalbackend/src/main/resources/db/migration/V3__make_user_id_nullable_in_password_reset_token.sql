-- Migration to make user_id nullable in password_reset_token table for healthcare provider support

ALTER TABLE password_reset_token 
MODIFY COLUMN user_id BIGINT NULL;

-- Add indexes for healthcare provider fields
CREATE INDEX idx_password_reset_token_provider_email 
ON password_reset_token(provider_email);

CREATE INDEX idx_password_reset_token_provider_type 
ON password_reset_token(provider_type);

-- Add index for token lookups
CREATE INDEX idx_password_reset_token_token_used 
ON password_reset_token(token, used);
