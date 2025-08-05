-- MySQL Setup Script for Cross-Device Access
-- Run this as MySQL root user

-- Create a dedicated user for the maternal health application
CREATE USER IF NOT EXISTS 'maternal_user'@'%' IDENTIFIED BY 'maternal_password_2024';

-- Grant all privileges on the maternal database to the new user
GRANT ALL PRIVILEGES ON maternaldb.* TO 'maternal_user'@'%';

-- Also allow connections from specific IP range for better security (optional)
CREATE USER IF NOT EXISTS 'maternal_user'@'10.11.20.%' IDENTIFIED BY 'maternal_password_2024';
GRANT ALL PRIVILEGES ON maternaldb.* TO 'maternal_user'@'10.11.20.%';

-- If you want to allow root user from network (less secure, but simpler for development)
-- Uncomment the next lines if needed:
-- CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'your_root_password_here';
-- GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Refresh the privilege tables
FLUSH PRIVILEGES;

-- Show the users we just created
SELECT user, host FROM mysql.user WHERE user IN ('maternal_user', 'root');

-- Show the privileges for our new user
SHOW GRANTS FOR 'maternal_user'@'%';
