# Quick Setup Guide for Cross-Device Database Access

## Step-by-Step Instructions

### 1. Configure MySQL for Network Access

#### Option A: Using MySQL Workbench (Recommended)
1. Open MySQL Workbench
2. Connect to your local MySQL server
3. Go to "Server" menu → "Users and Privileges"
4. Click "Add Account"
5. Set:
   - Login Name: `maternal_user`
   - Limit to Hosts Matching: `%` (allows from any IP)
   - Password: `maternal_password_2024`
6. Go to "Schema Privileges" tab
7. Click "Add Entry"
8. Select "Selected schema" and choose `maternaldb`
9. Click "Select ALL" to grant all privileges
10. Click "Apply"

#### Option B: Using Command Line
1. Open Command Prompt as Administrator
2. Navigate to MySQL bin directory (usually `C:\Program Files\MySQL\MySQL Server 8.0\bin`)
3. Run: `mysql -u root -p`
4. Enter your root password
5. Execute these commands:

```sql
CREATE USER 'maternal_user'@'%' IDENTIFIED BY 'maternal_password_2024';
GRANT ALL PRIVILEGES ON maternaldb.* TO 'maternal_user'@'%';
FLUSH PRIVILEGES;
```

### 2. Configure MySQL Server for Remote Connections

#### Find and Edit MySQL Configuration:
1. Look for `my.ini` file in one of these locations:
   - `C:\ProgramData\MySQL\MySQL Server 8.0\my.ini`
   - `C:\Program Files\MySQL\MySQL Server 8.0\my.ini`
   - `C:\MySQL\my.ini`

2. Open the file as Administrator (right-click → "Run as administrator")

3. Find the line that says:
   ```
   bind-address = 127.0.0.1
   ```

4. Change it to:
   ```
   bind-address = 0.0.0.0
   ```
   Or comment it out by adding # at the beginning:
   ```
   # bind-address = 127.0.0.1
   ```

### 3. Restart MySQL Service

#### Using Services Manager:
1. Press Windows + R, type `services.msc`, press Enter
2. Find "MySQL80" or "MySQL" service
3. Right-click → "Restart"

#### Using Command Prompt (as Administrator):
```cmd
net stop MySQL80
net start MySQL80
```

### 4. Configure Windows Firewall

#### Using Windows Defender Firewall:
1. Search "Windows Defender Firewall" in Start menu
2. Click "Advanced settings" on the left
3. Click "Inbound Rules" → "New Rule"
4. Select "Port" → Next
5. Select "TCP" and enter "3306" → Next
6. Select "Allow the connection" → Next
7. Check all profiles → Next
8. Name it "MySQL Server" → Finish

#### Using Command Prompt (as Administrator):
```cmd
netsh advfirewall firewall add rule name="MySQL Server" dir=in action=allow protocol=TCP localport=3306
```

### 5. Test the Configuration

#### From the same machine:
```cmd
mysql -h 10.11.20.8 -u maternal_user -p maternaldb
```

#### From another device on the network:
1. Install MySQL client or use an app like phpMyAdmin
2. Connect with:
   - Host: 10.11.20.8
   - Port: 3306
   - Username: maternal_user
   - Password: maternal_password_2024
   - Database: maternaldb

### 6. Start Your Spring Boot Application

After completing the above steps, your Spring Boot application should be able to connect to MySQL from any device on your network using the IP address 10.11.20.8.

## Troubleshooting

### If connection fails:
1. Check if MySQL service is running
2. Verify firewall rules
3. Test with telnet: `telnet 10.11.20.8 3306`
4. Check MySQL error logs
5. Verify user permissions in MySQL

### Security Note:
- This setup allows connections from any IP address (%)
- For production, consider restricting to specific IP ranges
- Use strong passwords
- Consider SSL encryption for sensitive data

## Alternative: Quick Docker Solution

If you prefer, you can run MySQL in Docker with network access:

```bash
docker run -d --name mysql-maternal \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=maternaldb \
  -e MYSQL_USER=maternal_user \
  -e MYSQL_PASSWORD=maternal_password_2024 \
  mysql:8.0
```

This automatically configures MySQL for network access.
