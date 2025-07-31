@echo off
echo Restarting Maternal Health Backend Server...

cd /d "C:\Users\ASUS\Desktop\project\maternal_health\maternalbackend"

echo Stopping existing Java processes...
taskkill /F /IM java.exe 2>nul

echo Starting backend server...
timeout /t 2

echo Using Maven wrapper to start Spring Boot...
cmd /c "mvnw.cmd spring-boot:run"

pause
