#!/bin/bash
# Quick backend server start script

echo "Starting Maternal Health Backend Server..."

# Navigate to backend directory
cd "C:\Users\ASUS\Desktop\project\maternal_health\maternalbackend"

# Kill any existing Java processes
taskkill /F /IM java.exe 2>nul

# Start the server using the wrapper
echo "Attempting to start with Maven wrapper..."
cmd /c "mvnw.cmd spring-boot:run"
