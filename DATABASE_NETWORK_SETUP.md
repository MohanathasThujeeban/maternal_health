# MySQL Network Configuration for Cross-Device Access

## Current Issue
Your MySQL database is configured to only accept connections from localhost, which means other devices can't access your data.

## Solution Steps

### 1. Configure MySQL to Accept Remote Connections

#### A. Edit MySQL Configuration File
1. Find your MySQL configuration file (`my.ini` on Windows):
   - Usually located at: `C:\ProgramData\MySQL\MySQL Server 8.0\my.ini`
   - Or check: `C:\Program Files\MySQL\MySQL Server 8.0\my.ini`

2. Open the file as Administrator and find the line:
   ```
   bind-address = 127.0.0.1
   ```
   
3. Change it to:
   ```
   bind-address = 0.0.0.0
   ```
   Or comment it out:
   ```
   # bind-address = 127.0.0.1
   ```

#### B. Restart MySQL Service
1. Open Services (Windows + R, type `services.msc`)
2. Find "MySQL80" or "MySQL" service
3. Right-click and select "Restart"

### 2. Create a User for Remote Access

Connect to MySQL and run these commands:

```sql
-- Connect to MySQL as root
mysql -u root -p

-- Create a user that can connect from any IP address
CREATE USER 'maternal_user'@'%' IDENTIFIED BY 'maternal_password_2024';

-- Grant all privileges on the maternal database
GRANT ALL PRIVILEGES ON maternaldb.* TO 'maternal_user'@'%';

-- Also allow the root user from any IP (optional, less secure)
CREATE USER 'root'@'%' IDENTIFIED BY 'your_root_password';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Refresh privileges
FLUSH PRIVILEGES;

-- Show current users to verify
SELECT user, host FROM mysql.user WHERE user IN ('root', 'maternal_user');
```

### 3. Configure Windows Firewall

Add a firewall rule to allow MySQL connections:

1. Open Windows Defender Firewall with Advanced Security
2. Click "Inbound Rules" → "New Rule"
3. Select "Port" → Next
4. Select "TCP" and enter port "3306" → Next
5. Select "Allow the connection" → Next
6. Check all profiles (Domain, Private, Public) → Next
7. Name it "MySQL Server" → Finish

Or use Command Prompt as Administrator:
```cmd
netsh advfirewall firewall add rule name="MySQL Server" dir=in action=allow protocol=TCP localport=3306
```

### 4. Update Application Configuration

Your application.properties has been updated to use your network IP:
```properties
spring.datasource.url=jdbc:mysql://10.11.20.8:3306/maternaldb?useSSL=false&serverTimezone=Asia/Colombo&allowPublicKeyRetrieval=true
spring.datasource.username=maternal_user
spring.datasource.password=maternal_password_2024
```

### 5. Test Connection from Another Device

From another device on the same network, test the connection:

```bash
# Test with telnet (if available)
telnet 10.11.20.8 3306

# Test with MySQL client (if installed)
mysql -h 10.11.20.8 -u maternal_user -p maternaldb
```

## Security Considerations

1. **Change Default Passwords**: Never use weak passwords in production
2. **Restrict IP Access**: Instead of '%', consider specific IP ranges like '10.11.20.%'
3. **Use SSL**: For production, enable SSL connections
4. **Regular Backups**: Set up automated database backups

## Troubleshooting

### Common Issues:

1. **Connection Refused**: MySQL not configured for remote access
2. **Access Denied**: User permissions not set correctly
3. **Timeout**: Firewall blocking connections
4. **Host Not Allowed**: User not created for remote access

### Quick Test Commands:

```sql
-- Check current user privileges
SHOW GRANTS FOR 'maternal_user'@'%';

-- Check if MySQL is listening on network interface
SHOW VARIABLES LIKE 'bind_address';

-- Check current connections
SHOW PROCESSLIST;
```

## Alternative Solutions

### Option 1: Cloud Database
Consider using a cloud database service like:
- Amazon RDS
- Google Cloud SQL
- Azure Database for MySQL
- DigitalOcean Managed Databases

### Option 2: Local Network Database Server
Set up a dedicated database server on your network that all devices connect to.

### Option 3: Docker with Network Access
Run MySQL in Docker with network access:

```bash
docker run -d --name mysql-maternal \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=your_password \
  -e MYSQL_DATABASE=maternaldb \
  -e MYSQL_USER=maternal_user \
  -e MYSQL_PASSWORD=maternal_password_2024 \
  mysql:8.0
```

## Next Steps

1. Follow the MySQL configuration steps above
2. Update your application.properties with the new user credentials
3. Test the connection from another device
4. Deploy your Spring Boot application with the updated configuration
