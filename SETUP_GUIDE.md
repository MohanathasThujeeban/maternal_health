# Complete Setup Guide for Maternal Health App on New Laptop

## Prerequisites Installation

### 1. Install Java Development Kit (JDK 17)
```bash
# Download and install JDK 17 from Oracle or OpenJDK
# Verify installation:
java -version
javac -version
```

### 2. Install MySQL
```bash
# Download MySQL Community Server from mysql.com
# During installation, set root password (or leave empty)
# Start MySQL service
```

### 3. Install Flutter SDK
```bash
# Download Flutter SDK from flutter.dev
# Add Flutter to system PATH
# Verify installation:
flutter doctor
```

### 4. Install Maven (Optional - project includes Maven wrapper)
```bash
# Maven wrapper (mvnw.cmd) is included in project
# No separate Maven installation needed
```

## Database Setup

### 1. Create Database
```sql
# Open MySQL Command Line or MySQL Workbench
# Connect as root user
CREATE DATABASE maternaldb;

# Verify database creation
SHOW DATABASES;
```

### 2. Configure Database Connection
Check `maternalbackend/src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/maternaldb?useSSL=false&serverTimezone=Asia/Colombo&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=
# ^^ Set your MySQL root password here if you have one
```

## Email Configuration (For Full Functionality)

### 1. Gmail App Password Setup
1. Go to Google Account settings
2. Enable 2-Factor Authentication
3. Generate App Password for "Mail"
4. Copy the 16-character app password

### 2. Update Email Configuration
Update `application.properties`:
```properties
spring.mail.username=your-email@gmail.com
spring.mail.password=your-16-char-app-password
```

## Running the Application

### 1. Start Backend Server
```bash
# Navigate to backend directory
cd maternal_health/maternalbackend

# Start Spring Boot server
mvnw.cmd spring-boot:run
# or on Mac/Linux: ./mvnw spring-boot:run

# Wait for "Started MaternalhealthApplication" message
# Server will run on http://localhost:8080
```

### 2. Start Flutter App
```bash
# Open new terminal
# Navigate to Flutter project root
cd maternal_health

# Get dependencies
flutter pub get

# Run app (with device/emulator connected)
flutter run
```

## Verification Steps

### 1. Backend Health Check
Visit http://localhost:8080/api/appointments/health in browser
Expected: `{"status":"Appointment service is running"}`

### 2. Database Connection
Check backend console for:
```
HikariPool-1 - Start completed.
Started MaternalhealthApplication in X seconds
```

### 3. Flutter App
- App should start without errors
- Registration should work with email verification
- Login should work properly
- Appointments should be creatable and viewable

## Common Issues & Solutions

### Issue: "Connection refused" error
**Solution**: Backend server not running
```bash
cd maternalbackend
mvnw.cmd spring-boot:run
```

### Issue: Database connection error
**Solution**: 
1. Check MySQL is running
2. Verify database exists: `SHOW DATABASES;`
3. Check credentials in `application.properties`

### Issue: Email verification timeout
**Solutions**:
1. Check Gmail app password is correct
2. Verify internet connection
3. Check Gmail account has 2FA enabled

### Issue: Flutter build errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

## Project Structure
```
maternal_health/
├── lib/                    # Flutter source code
├── android/               # Android configuration
├── ios/                   # iOS configuration
├── maternalbackend/       # Spring Boot backend
│   ├── src/main/java/     # Java source code
│   ├── src/main/resources/ # Configuration files
│   └── mvnw.cmd           # Maven wrapper
└── README.md
```

## API Endpoints
- Registration: `POST /api/registration`
- Login: `POST /api/login`
- Email Verification: `POST /api/send-verification-code`
- Appointments: `GET/POST /api/appointments/*`
- User Profile: `GET /api/user/profile/{nic}`

## Development Tips

### 1. Hot Reload
Flutter supports hot reload - save files to see changes instantly

### 2. Backend Changes
Restart Spring Boot server after Java code changes:
```bash
# Stop with Ctrl+C, then restart
mvnw.cmd spring-boot:run
```

### 3. Database Schema Updates
Backend uses Hibernate auto-update - schema changes apply automatically

### 4. Debugging
- Flutter: Use `print()` statements or VS Code debugger
- Backend: Check console logs or add `System.out.println()`

## Production Deployment

### 1. Flutter Web Build
```bash
flutter build web
# Deploy dist/ folder to web server
```

### 2. Android APK Build
```bash
flutter build apk --release
# APK file in build/app/outputs/flutter-apk/
```

### 3. Backend JAR Build
```bash
mvnw.cmd clean package
# JAR file in target/ folder
java -jar target/maternalhealth-0.0.1-SNAPSHOT.jar
```

## Support
If you encounter issues:
1. Check this setup guide
2. Verify all prerequisites are installed
3. Check console logs for error messages
4. Ensure all services (MySQL, backend) are running

---
Created: August 2025
Author: Maternal Health Development Team
