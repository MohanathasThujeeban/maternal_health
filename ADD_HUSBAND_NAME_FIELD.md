# Add "Husband Name" Field to Registration

This upgraded guide is your teacher-facing and developer checklist for adding a new optional field "Husband Name" to the registration flow (DB, Spring Boot backend, Flutter frontend). Only documentation is provided here (no code has been changed yet). Use this when the task is assigned; it is scoped for this repository structure.

Location of this guide: `maternal_health/ADD_HUSBAND_NAME_FIELD.md`

---

## 0. Purpose & Trigger
Add a `husbandName` attribute so the system can store a registrant's husband name for maternal profiling or communication templates. Activate this task only when required (e.g., a teacher request or feature ticket). Keep it OPTIONAL unless business rules later demand mandatory input.

---

## 1. Assumptions
Because code file names may vary (e.g., `User`, `Mother`, `Patient`, `AppUser`), steps below use generic names. Adjust after identifying actual file names with search.

We assume:
- Spring Boot with Maven lives in `maternalbackend/`.
- Flutter client lives under `lib/`.
- Existing registration endpoint already handles name/password/email.
- Database migrations are applied manually or via scripts beside existing `migration_*` SQL files.

If any assumption is false, adapt the respective section (no code change yet made).

---

## 2. High-Level Checklist (Teacher Review Friendly)
Front + Back + DB sequence:
1. Identify registration table name (DB).
2. Create SQL migration adding `husband_name` (nullable).
3. Add field to JPA Entity (`husbandName`).
4. Add field to Register Request DTO.
5. Map DTO -> Entity (service/mapper).
6. (Optional) Extend Response DTO.
7. Add Flutter `TextFormField` + controller.
8. Add to JSON payload only if non-empty.
9. Add validator (length >= 2 when provided).
10. Test: backend POST + Flutter manual run.
11. Update localization keys (if using ARB).
12. Document rollback & optional requirement toggle.

You can tick each item during implementation.

---

## 3. Repository Landmarks
- Root: `maternal_health/`
- Backend: `maternal_health/maternalbackend/`
  - Java: `maternalbackend/src/main/java/...`
  - Config/resources: `maternalbackend/src/main/resources/`
- Flutter: `maternal_health/lib/`
- SQL/Migrations: files at root (`maternaldb.sql`, `migration_*.sql`).

Search terms to locate registration-related code (Ctrl+Shift+F):
```
@PostMapping("/register")
RegisterRequest
AuthController
UserRepository
TextFormField
"/api/auth/register"
http.post(
```

### 3A. Exact Existing File Paths (Current Project)
Backend:
- Entity (add column): `maternalbackend/src/main/java/com/example/maternalcare/model/Registration.java`
- DTO (already has husbandName field): `maternalbackend/src/main/java/com/example/maternalcare/dto/RegistrationRequest.java`
- Controller (map husbandName): `maternalbackend/src/main/java/com/example/maternalcare/controller/RegistrationController.java`
- Repository (no change required): `maternalbackend/src/main/java/com/example/maternalcare/repository/RegistrationRepository.java`

Flutter:
- Registration step screen: `lib/features/auth/screens/register3_screen.dart`
- Registration data model: `lib/features/auth/screens/registration_data.dart`
- API HTTP client: `lib/features/auth/services/api_service.dart`

Database:
- Table name for registrations: `registration`
- New migration file to create: `maternal_health/migration_add_husband_name.sql`

Add husband name in these files only; do not modify unrelated modules.

---

## 4. Database Migration
Create new file (no execution yet): `maternal_health/migration_add_husband_name.sql`

Determine table name: in this project it is `registration` (see `@Table(name = "registration")` in `Registration.java`).

MySQL/MariaDB template (place after `email` for clarity):
```sql
ALTER TABLE registration
  ADD COLUMN husband_name VARCHAR(100) NULL AFTER email;
```
PostgreSQL template:
```sql
ALTER TABLE registration ADD COLUMN husband_name VARCHAR(100);
```
Roll-forward only; existing rows will have NULL.

Validation after applying:
```sql
SELECT husband_name FROM registration LIMIT 5;
```

Rollback (MySQL/PostgreSQL):
```sql
ALTER TABLE registration DROP COLUMN husband_name;
```

---

## 5. Backend Changes (Planned, Not Applied Yet)

### 5.1 Entity Field
```java
// File path: maternalbackend/src/main/java/com/example/maternalcare/model/Registration.java
@Column(name = "husband_name", length = 100)
private String husbandName;

public String getHusbandName() { return husbandName; }
public void setHusbandName(String husbandName) { this.husbandName = husbandName; }
```

### 5.2 DTO (RegisterRequest)
```java
// File path: maternalbackend/src/main/java/com/example/maternalcare/dto/RegistrationRequest.java
@Size(min = 2, max = 100, message = "Husband name must be 2-100 characters")
private String husbandName; // optional field
```
Add getter/setter.

To make required later:
```java
@NotBlank
@Size(min = 2, max = 100)
private String husbandName;
```

### 5.3 Mapping Example (Manual)
```java
// File path (controller): maternalbackend/src/main/java/com/example/maternalcare/controller/RegistrationController.java
User user = new User();
// existing mappings
user.setHusbandName(request.getHusbandName());
```

### 5.4 Controller Reminder
Ensure `@Valid @RequestBody RegisterRequest` contains the new field. No endpoint path change.

### 5.5 Response DTO (Optional)
If returning a user summary after registration:
```java
private String husbandName;
```

### 5.6 Minimal Diff (Illustrative Only)
```diff
 class User {
   // existing fields
+  @Column(name = "husband_name", length = 100)
+  private String husbandName;
 }
```
```diff
 class RegisterRequest {
   // existing fields
+  @Size(min = 2, max = 100, message = "Husband name must be 2-100 characters")
+  private String husbandName;
 }
```
These diffs are examples; not yet applied.

---

## 6. Flutter Frontend Changes (Planned)

### 6.1 Add Controller & Field
```dart
// File path: lib/features/auth/screens/register3_screen.dart
final TextEditingController husbandNameController = TextEditingController();

TextFormField(
  controller: husbandNameController,
  decoration: const InputDecoration(
    labelText: 'Husband Name',
    hintText: "Enter husband's name",
  ),
  maxLength: 100,
  validator: (v) {
    if (v == null || v.isEmpty) return null; // optional
    if (v.length < 2) return 'At least 2 characters';
    return null;
  },
);
```
Dispose in `dispose()`:
```dart
// File path: lib/features/auth/screens/register3_screen.dart
husbandNameController.dispose();
```

### 6.2 Include in Payload
```dart
// File path: lib/features/auth/screens/register3_screen.dart
final body = {
  'name': nameController.text,
  'email': emailController.text,
  'password': passwordController.text,
  if (husbandNameController.text.trim().isNotEmpty)
    'husbandName': husbandNameController.text.trim(),
};
```

### 6.3 Request Model (Optional)
```dart
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? husbandName;
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    if (husbandName != null && husbandName!.isNotEmpty) 'husbandName': husbandName,
  };
}
```

### 6.4 Localization (If Used)
Add to ARB:
```json
"husbandNameLabel": "Husband Name",
"husbandNameHint": "Enter husband's name",
"husbandNameTooShort": "At least 2 characters"
```
Run generator:
```powershell
flutter gen-l10n
```

### 6.5 Minimal Diff Example
```diff
 Column(children: [
   // existing
+  TextFormField(
+    controller: husbandNameController,
+    decoration: InputDecoration(labelText: 'Husband Name'),
+  ),
 ])
```

---

## 7. Validation & Security Notes
- Field is optional: skip server rejection if empty.
- Trim whitespace before persistence.
- Maximum length 100: prevents oversized input & UI overflow.
- Avoid enforcing uniqueness: husband names are not identifiers.
- Sanitization: rely on parameter binding + prepared statements (JPA/Hibernate) — no manual concatenated SQL.
- Log redaction: do not log entire request body containing credentials when adding new field.

---

## 8. Testing Plan (Manual)
Backend (PowerShell):
```powershell
cd "c:\Users\ASUS\Desktop\our Final full project\maternal_health\maternalbackend";
.\mvnw.cmd -q spring-boot:run
```
Request with field:
```powershell
$body = @{ name='Test User'; email='test@example.com'; password='Password@123'; husbandName='John Doe' } | ConvertTo-Json;
Invoke-RestMethod -Method Post -Uri http://localhost:8080/api/auth/register -ContentType 'application/json' -Body $body
```
Request without field (should still succeed):
```powershell
$body = @{ name='Test User2'; email='test2@example.com'; password='Password@123' } | ConvertTo-Json;
Invoke-RestMethod -Method Post -Uri http://localhost:8080/api/auth/register -ContentType 'application/json' -Body $body
```
Verify DB row has `husband_name` either NULL or the provided value.

Flutter:
```powershell
cd "c:\Users\ASUS\Desktop\our Final full project\maternal_health";
flutter pub get;
flutter run
```
Form tests:
- Submit with value (len 2, boundary 100).
- Submit empty (no error).
- Submit too short (1 char) -> validator error.

---

## 9. Rollback Process
1. Remove Flutter field (controller & widget).
2. Remove DTO + entity field.
3. Drop column:
```sql
ALTER TABLE users DROP COLUMN husband_name;
```
4. Clear docs (delete or archive this file version).

---

## 10. Making Field Mandatory Later
Changes required:
- DB: leave as NOT NULL (ALTER TABLE if needed).
- Backend: add `@NotBlank` and maybe `@Pattern`.
- Flutter: validator returns error if empty.
- Migration to populate existing rows with placeholder or collected data.

---

## 11. Teacher Evaluation Section (Optional)
You can present the following summary during review:
| Layer | Change | Status |
|-------|--------|--------|
| DB | Added `husband_name` column | Pending |
| Backend Entity | Field + getter/setter | Pending |
| DTO | Field + validation | Pending |
| Mapping | Added setter call | Pending |
| Controller | Accepts DTO | Existing |
| Response DTO | Optional addition | Pending |
| Flutter UI | `TextFormField` | Pending |
| Networking | JSON key `husbandName` | Pending |
| Localization | New labels | Optional |

Update "Pending" to "Done" as you implement.

---

## 12. Next Actions (Automated Support Option)
If you now want automatic code patches applied, request:
`Please patch backend + Flutter for husbandName`.

This will:
1. Locate actual entity and controller files.
2. Insert only the new field + getter/setter + DTO additions.
3. Add Flutter UI field and request mapping.
4. Leave other code untouched.

---

## 13. Quick Reference Snippets (Copy/Paste Ready)

Entity field:
```java
@Column(name = "husband_name", length = 100)
private String husbandName;
```
DTO field:
```java
@Size(min = 2, max = 100, message = "Husband name must be 2-100 characters")
private String husbandName;
```
Flutter field:
```dart
TextFormField(
  controller: husbandNameController,
  decoration: const InputDecoration(labelText: 'Husband Name'),
)
```
Payload addition:
```dart
if (husbandNameController.text.trim().isNotEmpty)
  body['husbandName'] = husbandNameController.text.trim();
```
Registration data model addition (file: `lib/features/auth/screens/registration_data.dart`):
```dart
String husbandName = '';
// In toJson(): if (husbandName.trim().isNotEmpty) 'husbandName': husbandName.trim(),
```

---

## 14. Glossary
- DTO: Data Transfer Object used for request/response bodies.
- Optional Field: Field may be missing or empty without causing validation failure.
- Migration: Script altering database schema (add/drop column).
- Rollback: Steps to revert schema & code changes safely.

---

## 15. Final Reminder
No code has been modified yet. This document is implementation-ready guidance. Execute steps only when the task is officially approved.

---

End of guide.
