# Vaccination Management System Setup

This system allows midwives to manage vaccination records for all registered mothers and enables mothers to view their vaccination history.

## Features

### For Midwives:
- View all vaccination records for all registered mothers
- Search for specific mothers by NIC
- Update vaccination status (PENDING → COMPLETED)
- Add new vaccination records
- Send email notifications when updating records
- View vaccination statistics and progress

### For Mothers:
- View their own vaccination history with timeline
- See completion progress and statistics  
- Access detailed vaccination information
- Receive email notifications when records are updated

## Database Setup

1. **Ensure your vaccination table exists:**
```sql
CREATE TABLE vaccination (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    mother_nic VARCHAR(20) NOT NULL,
    child_name VARCHAR(255),
    vaccination_type VARCHAR(255) NOT NULL,
    age_to_give VARCHAR(100),
    vaccination_date DATE,
    batch_number VARCHAR(100),
    effects_following_immunization TEXT,
    status ENUM('PENDING', 'COMPLETED', 'MISSED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (mother_nic) REFERENCES registration(nic)
);
```

2. **Insert sample data (optional for testing):**
   - Run the SQL script: `sample_vaccination_data.sql`
   - This will add vaccination records for mothers with NICs: 123456789V, 987654321V, 456789123V

## Backend Configuration

1. **Email Configuration (for notifications):**
   - Configure JavaMailSender in `application.properties`:
   ```properties
   spring.mail.host=smtp.gmail.com
   spring.mail.port=587
   spring.mail.username=your-email@gmail.com
   spring.mail.password=your-app-password
   spring.mail.properties.mail.smtp.auth=true
   spring.mail.properties.mail.smtp.starttls.enable=true
   ```

2. **API Endpoints Available:**
   - `GET /api/vaccinations` - Get all vaccinations
   - `GET /api/vaccinations/mother/{nic}` - Get vaccinations by mother NIC
   - `GET /api/vaccinations/mothers` - Get all mothers with vaccination summary
   - `GET /api/vaccinations/mothers/search?q={query}` - Search mothers
   - `POST /api/vaccinations` - Create new vaccination record
   - `PUT /api/vaccinations/{id}` - Update vaccination record
   - `PATCH /api/vaccinations/{id}/status` - Update vaccination status
   - `PATCH /api/vaccinations/{id}/status/notify` - Update status with email notification

## Frontend Usage

### Testing the System:
1. **Run the backend server:** `mvn spring-boot:run`
2. **Run the Flutter app:** `flutter run`
3. **Access the test screen:** Navigate to `/vaccination-test` route in your app

### For Midwives:
1. Open the Midwife Vaccination Screen
2. Use the "Search by NIC" tab to find specific mothers
3. Use the "All Mothers" tab to see all vaccination records
4. Click on vaccination records to update status
5. Use "Select from Registered Mothers" to choose from a list

### For Mothers:
1. Login as a mother
2. Go to Health Records tab in the home screen
3. View vaccination progress and history
4. Click "View Details" for full vaccination history
5. Access detailed timeline view with statistics

## Data Flow

1. **Mother Registration:** Mothers register and get a unique NIC
2. **Vaccination Creation:** Midwives create vaccination records for mothers
3. **Status Updates:** Midwives update vaccination status and send notifications
4. **Mother View:** Mothers see real-time updates to their vaccination records
5. **Email Notifications:** Mothers receive emails when vaccinations are updated

## Troubleshooting

### Common Issues:

1. **No vaccination records showing:**
   - Check if the mother NIC exists in the registration table
   - Verify database connection
   - Check API endpoints are working

2. **Email notifications not working:**
   - Verify SMTP configuration
   - Check email credentials
   - Ensure internet connection

3. **Search not working:**
   - Verify mother NICs are correct format
   - Check registration table has mothers with those NICs
   - Test API endpoints directly

### API Testing:
Use these curl commands to test the backend:

```bash
# Get all vaccinations
curl -X GET http://localhost:8080/api/vaccinations

# Get vaccinations for a specific mother
curl -X GET http://localhost:8080/api/vaccinations/mother/123456789V

# Update vaccination status
curl -X PATCH http://localhost:8080/api/vaccinations/1/status \
  -H "Content-Type: application/json" \
  -d '{"status": "COMPLETED"}'
```

## Security Notes

- Mother NICs are used as identifiers - ensure they are properly validated
- Email notifications contain sensitive health information - use secure SMTP
- API endpoints should be secured in production
- Consider adding authentication for midwife-specific operations
