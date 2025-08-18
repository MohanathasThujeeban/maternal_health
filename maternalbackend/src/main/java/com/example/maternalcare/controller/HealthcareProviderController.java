package com.example.maternalcare.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.model.HealthcareProvider;
import com.example.maternalcare.model.ProviderType;
import com.example.maternalcare.model.EmailVerificationToken;
import com.example.maternalcare.repository.HealthcareProviderRepository;
import com.example.maternalcare.repository.EmailVerificationTokenRepository;
import com.example.maternalcare.dto.HealthcareProviderRegistrationRequest;
import com.example.maternalcare.services.EmailService;
import com.example.maternalcare.services.EmailVerificationService;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/healthcare")
public class HealthcareProviderController {

    @Autowired
    private HealthcareProviderRepository healthcareProviderRepository;
    
    @Autowired
    private EmailVerificationTokenRepository emailVerificationTokenRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private EmailVerificationService emailVerificationService;

    @PostMapping("/register")
    public ResponseEntity<?> registerHealthcareProvider(@Valid @RequestBody HealthcareProviderRegistrationRequest request) {
        System.out.println("=== HEALTHCARE PROVIDER REGISTRATION ENDPOINT HIT ===");
        
        try {
            // Validate request
            if (request == null) {
                return createErrorResponse("Invalid request body", HttpStatus.BAD_REQUEST);
            }

            // Check for duplicate email
            if (healthcareProviderRepository.findByEmail(request.getEmail().trim().toLowerCase()).isPresent()) {
                return createErrorResponse("Email already registered", HttpStatus.CONFLICT);
            }

            // Check if email is verified
            boolean emailVerified = emailVerificationTokenRepository.existsByEmailAndVerified(request.getEmail().trim().toLowerCase(), true);
            if (!emailVerified) {
                return createErrorResponse("Email not verified. Please verify your email before registering.", HttpStatus.BAD_REQUEST);
            }

            // Check for duplicate NIC
            if (healthcareProviderRepository.findByNicNumber(request.getNicNumber().trim()).isPresent()) {
                return createErrorResponse("NIC number already registered", HttpStatus.CONFLICT);
            }
            
            // Check for duplicate medical license number
            if (healthcareProviderRepository.findByMedicalLicenseNumber(request.getMedicalLicenseNumber().trim()).isPresent()) {
                return createErrorResponse("Medical license number already registered", HttpStatus.CONFLICT);
            }

            // Validate provider type
            if (request.getProviderType() == null) {
                return createErrorResponse("Provider type is required", HttpStatus.BAD_REQUEST);
            }

            // Check if email is verified (if email verification is enabled)
            String email = request.getEmail().trim().toLowerCase();
            try {
                if (!emailVerificationService.isEmailVerified(email)) {
                    return createErrorResponse("Email not verified. Please verify your email before registering.", HttpStatus.BAD_REQUEST);
                }
            } catch (Exception e) {
                // If email verification service fails, continue with registration but mark as unverified
                System.out.println("Email verification check failed: " + e.getMessage());
            }

            // Create new healthcare provider registration
            HealthcareProvider provider = new HealthcareProvider();
            provider.setFullName(request.getFullName().trim());
            provider.setNicNumber(request.getNicNumber().trim());
            provider.setPhoneNumber(request.getPhoneNumber().trim());
            provider.setPassword(passwordEncoder.encode(request.getPassword()));
            provider.setEmail(email);
            provider.setProviderType(request.getProviderType());
            provider.setMedicalLicenseNumber(request.getMedicalLicenseNumber().trim());
            provider.setInstitution(request.getInstitution().trim());
            
            // Auto-approve healthcare providers (no admin approval required)
            provider.setIsApproved(true);
            provider.setApprovedAt(LocalDateTime.now());
            
            // Set optional fields
            if (request.getSpecialization() != null && !request.getSpecialization().trim().isEmpty()) {
                provider.setSpecialization(request.getSpecialization().trim());
            }
            if (request.getYearsOfExperience() != null) {
                provider.setYearsOfExperience(request.getYearsOfExperience());
            }
            if (request.getLicenseExpiryDate() != null) {
                provider.setLicenseExpiryDate(request.getLicenseExpiryDate());
            }

            HealthcareProvider saved = healthcareProviderRepository.save(provider);
            System.out.println("Healthcare provider registered successfully with ID: " + saved.getId());

            // Send welcome email
            try {
                emailService.sendHealthcareProviderWelcomeEmail(saved.getEmail(), saved.getFullName(), saved.getProviderType().getDisplayName());
                System.out.println("Welcome email sent to: " + saved.getEmail());
            } catch (Exception emailException) {
                System.err.println("Failed to send welcome email: " + emailException.getMessage());
            }

            // Create success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Healthcare provider registered successfully! You can now login.");
            response.put("providerId", saved.getId());
            response.put("email", saved.getEmail());
            response.put("fullName", saved.getFullName());
            response.put("providerType", saved.getProviderType().toString());
            response.put("medicalLicenseNumber", saved.getMedicalLicenseNumber());
            response.put("isApproved", saved.getIsApproved());
            response.put("timestamp", LocalDateTime.now());

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            System.err.println("Healthcare provider registration error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Registration failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginHealthcareProvider(@RequestBody Map<String, String> loginRequest) {
        System.out.println("=== HEALTHCARE PROVIDER LOGIN ENDPOINT HIT ===");
        
        try {
            String medicalLicenseNumber = loginRequest.get("medicalLicenseNumber");
            String password = loginRequest.get("password");
            
            if (medicalLicenseNumber == null || medicalLicenseNumber.trim().isEmpty()) {
                return createErrorResponse("Medical license number is required", HttpStatus.BAD_REQUEST);
            }
            
            if (password == null || password.trim().isEmpty()) {
                return createErrorResponse("Password is required", HttpStatus.BAD_REQUEST);
            }
            
            // Find provider by medical license number
            Optional<HealthcareProvider> providerOptional = healthcareProviderRepository.findByMedicalLicenseNumber(medicalLicenseNumber.trim());
            
            if (providerOptional.isEmpty()) {
                return createErrorResponse("Invalid medical license number or password", HttpStatus.UNAUTHORIZED);
            }
            
            HealthcareProvider provider = providerOptional.get();
            
            // Check if provider is active
            if (!provider.getIsActive()) {
                return createErrorResponse("Account is deactivated. Please contact support.", HttpStatus.UNAUTHORIZED);
            }
            
            // Check if provider is approved
            if (!provider.getIsApproved()) {
                return createErrorResponse("Account is pending approval. Please wait for admin approval.", HttpStatus.UNAUTHORIZED);
            }
            
            // Verify password
            if (!passwordEncoder.matches(password, provider.getPassword())) {
                return createErrorResponse("Invalid medical license number or password", HttpStatus.UNAUTHORIZED);
            }
            
            // Create success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Login successful");
            response.put("providerId", provider.getId());
            response.put("fullName", provider.getFullName());
            response.put("email", provider.getEmail());
            response.put("nicNumber", provider.getNicNumber());
            response.put("phoneNumber", provider.getPhoneNumber());
            response.put("medicalLicenseNumber", provider.getMedicalLicenseNumber());
            response.put("institution", provider.getInstitution());
            response.put("providerType", provider.getProviderType().toString());
            response.put("specialization", provider.getSpecialization());
            response.put("yearsOfExperience", provider.getYearsOfExperience());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Healthcare provider login error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Login failed: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/send-verification")
    public ResponseEntity<?> sendEmailVerification(@RequestBody Map<String, String> request) {
        System.out.println("=== SEND EMAIL VERIFICATION ENDPOINT HIT ===");
        
        try {
            String email = request.get("email");
            
            if (email == null || email.trim().isEmpty()) {
                return createErrorResponse("Email is required", HttpStatus.BAD_REQUEST);
            }
            
            if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                return createErrorResponse("Invalid email format", HttpStatus.BAD_REQUEST);
            }
            
            // Check if email is already registered
            if (healthcareProviderRepository.findByEmail(email.trim().toLowerCase()).isPresent()) {
                return createErrorResponse("Email already registered", HttpStatus.CONFLICT);
            }
            
            boolean success = emailVerificationService.sendVerificationEmail(email.trim().toLowerCase());
            
            Map<String, Object> response = new HashMap<>();
            if (success) {
                response.put("success", true);
                response.put("message", "Verification email sent successfully");
            } else {
                response.put("success", false);
                response.put("message", "Failed to send verification email");
            }
            response.put("timestamp", LocalDateTime.now());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Send verification error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to send verification email: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/providers")
    public ResponseEntity<?> getAllHealthcareProviders() {
        System.out.println("=== GET ALL HEALTHCARE PROVIDERS ENDPOINT HIT ===");
        
        try {
            List<HealthcareProvider> providers = healthcareProviderRepository.findByIsApprovedTrueAndIsActiveTrue();
            
            List<Map<String, Object>> providerList = providers.stream()
                .map(provider -> {
                    Map<String, Object> providerData = new HashMap<>();
                    providerData.put("id", provider.getId());
                    providerData.put("fullName", provider.getFullName());
                    providerData.put("email", provider.getEmail());
                    providerData.put("phoneNumber", provider.getPhoneNumber());
                    providerData.put("medicalLicenseNumber", provider.getMedicalLicenseNumber());
                    providerData.put("institution", provider.getInstitution());
                    providerData.put("providerType", provider.getProviderType().toString());
                    providerData.put("specialization", provider.getSpecialization());
                    providerData.put("yearsOfExperience", provider.getYearsOfExperience());
                    providerData.put("createdAt", provider.getCreatedAt());
                    return providerData;
                })
                .toList();
                
            System.out.println("Found " + providerList.size() + " approved healthcare providers");
            return ResponseEntity.ok(providerList);
                
        } catch (Exception e) {
            System.err.println("Get healthcare providers error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to fetch healthcare providers: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/pending-approval")
    public ResponseEntity<?> getPendingProviders() {
        System.out.println("=== GET PENDING APPROVAL PROVIDERS ENDPOINT HIT ===");
        
        try {
            List<HealthcareProvider> pendingProviders = healthcareProviderRepository.findByIsApprovedFalseAndIsActiveTrue();
            
            List<Map<String, Object>> providerList = pendingProviders.stream()
                .map(provider -> {
                    Map<String, Object> providerData = new HashMap<>();
                    providerData.put("id", provider.getId());
                    providerData.put("fullName", provider.getFullName());
                    providerData.put("email", provider.getEmail());
                    providerData.put("phoneNumber", provider.getPhoneNumber());
                    providerData.put("medicalLicenseNumber", provider.getMedicalLicenseNumber());
                    providerData.put("institution", provider.getInstitution());
                    providerData.put("providerType", provider.getProviderType().toString());
                    providerData.put("specialization", provider.getSpecialization());
                    providerData.put("yearsOfExperience", provider.getYearsOfExperience());
                    providerData.put("createdAt", provider.getCreatedAt());
                    return providerData;
                })
                .toList();
                
            return ResponseEntity.ok(providerList);
                
        } catch (Exception e) {
            System.err.println("Get pending providers error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to fetch pending providers: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/{providerId}/approve")
    public ResponseEntity<?> approveProvider(@PathVariable Long providerId) {
        System.out.println("=== APPROVE PROVIDER ENDPOINT HIT ===");
        
        try {
            Optional<HealthcareProvider> providerOptional = healthcareProviderRepository.findById(providerId);
            
            if (providerOptional.isEmpty()) {
                return createErrorResponse("Healthcare provider not found", HttpStatus.NOT_FOUND);
            }
            
            HealthcareProvider provider = providerOptional.get();
            provider.setIsApproved(true);
            provider.setApprovedAt(LocalDateTime.now());
            // TODO: Set approved_by to current admin user ID
            
            healthcareProviderRepository.save(provider);
            
            // Send approval email
            try {
                emailService.sendHealthcareProviderApprovalEmail(
                    provider.getEmail(), 
                    provider.getFullName(),
                    provider.getProviderType().toString()
                );
            } catch (Exception e) {
                System.err.println("Failed to send approval email: " + e.getMessage());
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Healthcare provider approved successfully");
            response.put("providerId", provider.getId());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Approve provider error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to approve provider: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/send-verification-email")
    public ResponseEntity<?> sendVerificationEmail(@RequestBody Map<String, String> request) {
        System.out.println("=== EMAIL VERIFICATION ENDPOINT HIT ===");
        
        try {
            String email = request.get("email");
            String verificationCode = request.get("verificationCode");
            String fullName = request.get("fullName");
            
            if (email == null || email.trim().isEmpty()) {
                return createErrorResponse("Email is required", HttpStatus.BAD_REQUEST);
            }
            
            if (verificationCode == null || verificationCode.trim().isEmpty()) {
                return createErrorResponse("Verification code is required", HttpStatus.BAD_REQUEST);
            }
            
            // Validate email format
            if (!email.matches("^[^@]+@[^@]+\\.[^@]+$")) {
                return createErrorResponse("Invalid email format", HttpStatus.BAD_REQUEST);
            }
            
            // Check if email is already registered
            if (healthcareProviderRepository.findByEmail(email.trim().toLowerCase()).isPresent()) {
                return createErrorResponse("Email is already registered", HttpStatus.CONFLICT);
            }
            
            // Delete any existing verification token for this email
            emailVerificationTokenRepository.deleteByEmail(email.trim().toLowerCase());
            
            // Create and save verification token
            EmailVerificationToken token = new EmailVerificationToken(verificationCode, email.trim().toLowerCase());
            emailVerificationTokenRepository.save(token);
            
            // Send verification email
            try {
                emailService.sendVerificationEmail(email.trim().toLowerCase(), fullName, verificationCode);
                System.out.println("Verification email sent to: " + email);
            } catch (Exception emailException) {
                System.err.println("Failed to send verification email: " + emailException.getMessage());
                return createErrorResponse("Failed to send verification email", HttpStatus.INTERNAL_SERVER_ERROR);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Verification email sent successfully");
            response.put("email", email.trim().toLowerCase());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Send verification email error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to send verification email: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/verify-email-code")
    public ResponseEntity<?> verifyEmailCode(@RequestBody Map<String, String> request) {
        System.out.println("=== EMAIL CODE VERIFICATION ENDPOINT HIT ===");
        
        try {
            String email = request.get("email");
            String code = request.get("code");
            
            if (email == null || email.trim().isEmpty()) {
                return createErrorResponse("Email is required", HttpStatus.BAD_REQUEST);
            }
            
            if (code == null || code.trim().isEmpty()) {
                return createErrorResponse("Verification code is required", HttpStatus.BAD_REQUEST);
            }
            
            // Find the verification token
            Optional<EmailVerificationToken> tokenOptional = emailVerificationTokenRepository.findByEmail(email.trim().toLowerCase());
            
            if (tokenOptional.isEmpty()) {
                return createErrorResponse("No verification code found for this email", HttpStatus.NOT_FOUND);
            }
            
            EmailVerificationToken token = tokenOptional.get();
            
            // Check if token is expired
            if (token.isExpired()) {
                emailVerificationTokenRepository.delete(token);
                return createErrorResponse("Verification code has expired", HttpStatus.BAD_REQUEST);
            }
            
            // Check if code matches
            if (!token.getToken().equals(code.trim())) {
                return createErrorResponse("Invalid verification code", HttpStatus.BAD_REQUEST);
            }
            
            // Mark as verified
            token.setVerified(true);
            emailVerificationTokenRepository.save(token);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Email verified successfully");
            response.put("email", email.trim().toLowerCase());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Verify email code error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to verify email code: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/available")
    public ResponseEntity<?> getAvailableHealthcareProviders() {
        System.out.println("=== GET AVAILABLE HEALTHCARE PROVIDERS ENDPOINT HIT ===");
        
        try {
            // Get all approved healthcare providers
            List<HealthcareProvider> providers = healthcareProviderRepository.findByIsApprovedTrueAndIsActiveTrue();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Available healthcare providers fetched successfully");
            response.put("providers", providers.stream().map(provider -> {
                Map<String, Object> providerData = new HashMap<>();
                providerData.put("id", provider.getId());
                providerData.put("fullName", provider.getFullName());
                providerData.put("nicNumber", provider.getNicNumber());
                providerData.put("providerType", provider.getProviderType().toString());
                providerData.put("specialization", provider.getSpecialization());
                providerData.put("institution", provider.getInstitution());
                providerData.put("yearsOfExperience", provider.getYearsOfExperience());
                providerData.put("email", provider.getEmail());
                providerData.put("phoneNumber", provider.getPhoneNumber());
                providerData.put("medicalLicenseNumber", provider.getMedicalLicenseNumber());
                return providerData;
            }).toList());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("Get available providers error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to fetch available providers: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    // Auto-approve all existing healthcare providers (temporary endpoint for migration)
    @PostMapping("/auto-approve-all")
    public ResponseEntity<?> autoApproveAllProviders() {
        System.out.println("=== AUTO APPROVE ALL PROVIDERS ENDPOINT HIT ===");
        try {
            List<HealthcareProvider> unapprovedProviders = healthcareProviderRepository.findByIsApprovedFalseAndIsActiveTrue();
            
            for (HealthcareProvider provider : unapprovedProviders) {
                provider.setIsApproved(true);
                provider.setApprovedAt(LocalDateTime.now());
                healthcareProviderRepository.save(provider);
                System.out.println("Auto-approved provider: " + provider.getFullName());
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Auto-approved " + unapprovedProviders.size() + " healthcare providers");
            response.put("approvedCount", unapprovedProviders.size());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Auto approve all providers error: " + e.getMessage());
            e.printStackTrace();
            return createErrorResponse("Failed to auto-approve providers: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    private ResponseEntity<?> createErrorResponse(String message, HttpStatus status) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("error", message);
        errorResponse.put("timestamp", LocalDateTime.now());
        return ResponseEntity.status(status).body(errorResponse);
    }
}
