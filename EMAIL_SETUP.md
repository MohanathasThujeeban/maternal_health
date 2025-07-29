# Email Configuration Guide

## Setting up Gmail SMTP for Maternal Health App

To enable email functionality (password reset, email verification), you need to configure Gmail SMTP settings.

### Step 1: Gmail App Password Setup

1. Go to your Google Account settings: https://myaccount.google.com/
2. Click on "Security" in the left sidebar
3. Under "Signing in to Google", click on "2-Step Verification" (enable if not already enabled)
4. Once 2-Step Verification is enabled, go back to Security
5. Under "Signing in to Google", click on "App passwords"
6. Select "Mail" for the app and "Other" for device
7. Enter "Maternal Health App" as the device name
8. Click "Generate"
9. Copy the 16-character app password

### Step 2: Update Application Configuration

Edit the file: `maternalbackend/src/main/resources/application.properties`

Replace these lines:
```properties
spring.mail.username=your_email@gmail.com
spring.mail.password=your_app_password
```

With your actual Gmail credentials:
```properties
spring.mail.username=youremail@gmail.com
spring.mail.password=abcd efgh ijkl mnop
```

**Important:** Use the 16-character app password, NOT your regular Gmail password!

### Step 3: Test Email Configuration

1. Start the backend server
2. Use this endpoint to test email sending:
   ```
   POST http://localhost:8080/api/test/email?email=thujeeforearn@gmail.com
   ```

### Step 4: Features Enabled After Email Setup

✅ **Password Reset**: Users can request password reset via email
✅ **Email Verification**: Registration emails can be sent
✅ **Account Recovery**: Users can recover forgotten passwords

### Troubleshooting

**Common Issues:**

1. **"Authentication failed"** - Check app password is correct
2. **"Connection timeout"** - Check firewall/antivirus settings
3. **"Invalid credentials"** - Ensure 2-Step Verification is enabled

**Test Commands:**
```bash
# Test email configuration
curl -X GET http://localhost:8080/api/test/email-config

# Send test email
curl -X POST http://localhost:8080/api/test/email?email=test@example.com
```

### Security Notes

- Never commit your real email credentials to version control
- Use environment variables in production
- App passwords are safer than regular passwords
- Enable 2-Factor Authentication for better security

### Alternative Email Providers

If you don't want to use Gmail, you can configure other providers:

**Outlook/Hotmail:**
```properties
spring.mail.host=smtp-mail.outlook.com
spring.mail.port=587
```

**Yahoo:**
```properties
spring.mail.host=smtp.mail.yahoo.com
spring.mail.port=587
```

### Production Deployment

For production, use environment variables:
```properties
spring.mail.username=${EMAIL_USERNAME}
spring.mail.password=${EMAIL_PASSWORD}
```

Set environment variables:
```bash
export EMAIL_USERNAME=youremail@gmail.com
export EMAIL_PASSWORD=your-app-password
```
