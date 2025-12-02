# Admin Dashboard - User Management System

## Overview
The admin dashboard provides comprehensive user management capabilities for the BloomCare maternal health application. Administrators can view, suspend, and delete users across all roles (Mothers, Midwives, and Doctors).

## Default Admin Credentials
```
Email: admin@bloomcare
Password: Admin@123
```

## Features

### 1. **User Management by Role**
- **Mothers Tab**: View and manage all mother accounts
- **Midwives Tab**: View and manage all midwife accounts  
- **Doctors Tab**: View and manage all doctor accounts

### 2. **User Information Display**
Each user card shows:
- Full Name
- Email Address
- Phone Number
- NIC Number
- User Role
- Account Status (Active/Suspended)

### 3. **User Actions**

#### View Details
- Opens a detailed dialog with complete user information
- Shows account status and role
- Displays all contact information

#### Suspend User
- Temporarily disable a user account
- Suspended users cannot log in
- Suspended status is visually indicated with orange badge
- Can be performed on active accounts only

#### Delete User
- Permanently remove a user from the system
- Requires confirmation before deletion
- **Warning**: This action cannot be undone

### 4. **Visual Indicators**
- **Role-based Colors**:
  - Mothers: Pink gradient
  - Midwives: Green gradient
  - Doctors: Blue gradient
- **Status Badges**: Orange badge for suspended accounts
- **User Count**: Real-time count displayed in each tab

### 5. **Refresh & Logout**
- Refresh button to reload user data
- Logout button to return to login screen

## Access the Admin Dashboard

### From the Login Screen
1. Open the app
2. On the main login screen, scroll down
3. Click the **"Admin Login"** button (purple button with admin icon)
4. Enter admin credentials:
   - Email: `admin@bloomcare`
   - Password: `Admin@123`
5. Click **"Login as Admin"**

## API Endpoints

### Admin Authentication
```
POST /admin/login
Body: {
  "email": "admin@bloomcare",
  "password": "Admin@123"
}
```

### Get All Users
```
GET /admin/users
Returns: List of all registered users with their details
```

### Suspend User
```
PUT /admin/users/{nicNumber}/suspend
Sets user's isActive field to false
```

### Delete User
```
DELETE /admin/users/{nicNumber}
Permanently removes user from database
```

## Database Migration

Run the following SQL script to ensure the `is_active` column exists:

```sql
-- Add is_active column if it doesn't exist
ALTER TABLE registration 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_registration_is_active ON registration(is_active);
CREATE INDEX IF NOT EXISTS idx_registration_user_role ON registration(user_role);
```

The migration script is available at: `migration_admin_user_management.sql`

## File Structure

### Flutter (Frontend)
```
lib/
├── features/
│   └── admin/
│       └── screens/
│           ├── admin_login_screen.dart      # Admin login UI
│           ├── admin_dashboard_screen.dart   # Main dashboard with tabs
│           └── user_details_dialog.dart      # User details popup
├── services/
│   └── admin_service.dart                    # API calls for admin actions
└── models/
    └── user_model.dart                       # User data model
```

### Spring Boot (Backend)
```
maternalbackend/src/main/java/com/example/maternalcare/
├── controller/
│   └── AdminController.java                  # Admin REST endpoints
├── dto/
│   └── AdminLoginRequest.java                # Login request DTO
├── model/
│   └── Registration.java                     # User entity (with isActive field)
└── repository/
    └── RegistrationRepository.java           # User data access
```

## Security Considerations

1. **Hardcoded Credentials**: Current implementation uses hardcoded admin credentials. For production:
   - Store credentials in environment variables
   - Use proper authentication/authorization (JWT, OAuth)
   - Implement role-based access control (RBAC)

2. **No Password Hashing**: Admin password is compared in plain text. Recommended:
   - Use BCrypt for password hashing
   - Implement secure password policies

3. **No Session Management**: No session timeout or token-based auth. Recommended:
   - Implement JWT tokens
   - Add session expiration
   - Add CSRF protection

## Theme Support

The admin dashboard fully supports light and dark modes:
- Light Mode: White backgrounds with indigo accents
- Dark Mode: Dark backgrounds with lighter text and accents
- Automatically adapts to app-wide theme settings

## Error Handling

- Connection errors are caught and displayed to the user
- Failed operations show error snackbars
- Empty states are handled with friendly messages
- Confirmation dialogs prevent accidental deletions

## Future Enhancements

1. **Advanced Filtering**
   - Search users by name, email, or NIC
   - Filter by status (active/suspended)
   - Sort by creation date, role, etc.

2. **Bulk Operations**
   - Select multiple users
   - Bulk suspend/activate
   - Export user data

3. **Analytics Dashboard**
   - Total user count by role
   - Growth charts
   - Active vs inactive users

4. **Audit Logging**
   - Track admin actions
   - Log user modifications
   - Export audit reports

5. **User Editing**
   - Update user information
   - Reset user passwords
   - Change user roles

## Testing

### Test Admin Login
1. Navigate to admin login screen
2. Use default credentials
3. Verify successful login and redirection to dashboard

### Test User Management
1. View users in each tab (Mothers, Midwives, Doctors)
2. Click "View" to see detailed user information
3. Suspend a user and verify the suspended badge appears
4. Delete a test user and verify removal from list

### Test Error Handling
1. Try admin login with wrong credentials
2. Test with backend server stopped
3. Verify error messages display correctly

## Support

For issues or questions:
- Check console logs for detailed error messages
- Verify backend server is running on correct port
- Ensure database connection is active
- Check network connectivity

---

**Note**: This is a development version. Additional security measures must be implemented before production deployment.
