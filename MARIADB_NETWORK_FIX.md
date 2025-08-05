# Fix MariaDB Connection Issues for Cross-Device Access

## Current Problem
Your Spring Boot application is failing to connect to MariaDB with the error:
```
"Host 'host.docker.internal' is not allowed to connect to this MariaDB server"
```

## Step-by-Step Solution

### Step 1: First, Let's Get Your App Running Locally

I've reverted your database configuration to use localhost. Try running the app now:

```bash
mvn spring-boot:run
```

This should work with your local MariaDB instance.

### Step 2: Configure MariaDB for Network Access

#### A. Connect to MariaDB as Administrator

Open Command Prompt as Administrator and connect to MariaDB:

```bash
# Navigate to MariaDB bin directory (adjust path as needed)
cd "C:\Program Files\MariaDB 10.x\bin"

# Connect to MariaDB
mysql -u root -p
```

#### B. Create User for Network Access

Once connected to MariaDB, run these commands:

```sql
-- Create a user that can connect from any host
CREATE USER 'maternal_user'@'%' IDENTIFIED BY 'maternal_password_2024';

-- Grant privileges on your database
GRANT ALL PRIVILEGES ON maternaldb.* TO 'maternal_user'@'%';

-- Also create for specific IP range (more secure)
CREATE USER 'maternal_user'@'10.11.20.%' IDENTIFIED BY 'maternal_password_2024';
GRANT ALL PRIVILEGES ON maternaldb.* TO 'maternal_user'@'10.11.20.%';

-- Allow root from network (if needed)
CREATE USER 'root'@'%' IDENTIFIED BY 'your_root_password_here';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Refresh privileges
FLUSH PRIVILEGES;

-- Verify users were created
SELECT user, host FROM mysql.user WHERE user IN ('maternal_user', 'root');

-- Exit MariaDB
EXIT;
```

#### C. Configure MariaDB Server for Network Connections

1. **Find MariaDB Configuration File:**
   - Look for `my.ini` or `my.cnf` in one of these locations:
   - `C:\Program Files\MariaDB 10.x\data\my.ini`
   - `C:\ProgramData\MariaDB\data\my.ini`
   - `C:\MariaDB\data\my.ini`

2. **Edit Configuration File:**
   Open the file as Administrator and find the `[mysqld]` section.
   
   Look for these lines and modify them:
   ```ini
   # Comment out or change bind-address
   # bind-address = 127.0.0.1
   bind-address = 0.0.0.0
   
   # Allow network connections
   skip-networking = 0
   
   # Set port (default is 3306)
   port = 3306
   ```

3. **Restart MariaDB Service:**
   ```cmd
   # Stop MariaDB service
   net stop MariaDB
   
   # Start MariaDB service
   net start MariaDB
   ```

#### D. Configure Windows Firewall

Allow MariaDB port through Windows Firewall:

```cmd
# Run as Administrator
netsh advfirewall firewall add rule name="MariaDB Server" dir=in action=allow protocol=TCP localport=3306
```

### Step 3: Test Local Connection First

Update your application.properties to use the new user but still localhost:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/maternaldb?useSSL=false&serverTimezone=Asia/Colombo&allowPublicKeyRetrieval=true
spring.datasource.username=maternal_user
spring.datasource.password=maternal_password_2024
```

Test if the app starts successfully:
```bash
mvn spring-boot:run
```

### Step 4: Test Network Connection

Once local connection works, update to network IP:

```properties
spring.datasource.url=jdbc:mysql://10.11.20.8:3306/maternaldb?useSSL=false&serverTimezone=Asia/Colombo&allowPublicKeyRetrieval=true
spring.datasource.username=maternal_user
spring.datasource.password=maternal_password_2024
```

### Step 5: Test from Another Device

From another device on your network, test the connection:

```bash
# Test with telnet
telnet 10.11.20.8 3306

# Test with MariaDB client (if installed)
mysql -h 10.11.20.8 -u maternal_user -p maternaldb
```

## Alternative Quick Solution: Use Docker

If the above steps are complex, you can run MariaDB in Docker with network access:

```bash
# Stop your current MariaDB service first
net stop MariaDB

# Run MariaDB in Docker with network access
docker run -d --name mariadb-maternal ^
  -p 3306:3306 ^
  -e MYSQL_ROOT_PASSWORD=rootpassword ^
  -e MYSQL_DATABASE=maternaldb ^
  -e MYSQL_USER=maternal_user ^
  -e MYSQL_PASSWORD=maternal_password_2024 ^
  -v mariadb_data:/var/lib/mysql ^
  mariadb:latest

# Your application can now connect using:
# spring.datasource.url=jdbc:mysql://10.11.20.8:3306/maternaldb
```

## Troubleshooting Commands

### Check MariaDB Status
```bash
# Check if MariaDB is running
sc query MariaDB

# Check MariaDB process
tasklist | findstr mysql
```

### Check Network Connectivity
```bash
# Check if port 3306 is open
netstat -an | findstr :3306

# Test connection to MariaDB
telnet 10.11.20.8 3306
```

### Check MariaDB Logs
Look for MariaDB error logs in:
- `C:\Program Files\MariaDB 10.x\data\*.err`
- `C:\ProgramData\MariaDB\data\*.err`

## Security Notes

1. **Change Default Passwords**: Use strong passwords in production
2. **Restrict IP Access**: Instead of `%`, use specific IP ranges like `10.11.20.%`
3. **Enable SSL**: For production, configure SSL connections
4. **Regular Backups**: Set up automated database backups

## Next Steps

1. First get your app running locally with the reverted configuration
2. Then follow the MariaDB network configuration steps
3. Test step by step: local → network → other devices
4. Once working, update your app's database URL to use the network IP

Let me know which step you'd like help with!
