package com.example.maternalcare.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.dto.RegistrationRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.EmailVerificationToken;
import com.example.maternalcare.repository.RegistrationRepository;
import com.example.maternalcare.repository.EmailVerificationTokenRepository;
import com.example.maternalcare.services.EmailService;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/registration")
public class RegistrationController {
    private final RegistrationRepository repository;
    private final EmailService emailService;
    private final EmailVerificationTokenRepository tokenRepository;

    @Autowired
    public RegistrationController(
            RegistrationRepository repository,
            EmailService emailService,
            EmailVerificationTokenRepository tokenRepository) {
        this.repository = repository;
        this.emailService = emailService;
        this.tokenRepository = tokenRepository;
    }

    @PostMapping
    public ResponseEntity<?> register(@RequestBody RegistrationRequest request) {
        // Check for duplicate email
        if (repository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body("Email already registered");
        }

        Registration reg = new Registration();
        reg.setMotherFullName(request.getMotherFullName());
        reg.setFatherFullName(request.getFatherFullName());
        reg.setAddress(request.getAddress());
        reg.setPhoneNumber(request.getPhoneNumber());
        reg.setAge(request.getAge());
        reg.setOccupation(request.getOccupation());
        reg.setEthnicity(request.getEthnicity());
        reg.setReligion(request.getReligion());
        reg.setEducationLevel(request.getEducationLevel());
        reg.setGravida(request.getGravida());
        reg.setPara(request.getPara());
        reg.setLmp(request.getLmp());
        reg.setEdd(request.getEdd());
        reg.setPreviousPregnancies(request.getPreviousPregnancies());
        reg.setYear(request.getYear());
        reg.setDuration(request.getDuration());
        reg.setModeOfDelivery(request.getModeOfDelivery());
        reg.setBirthWeight(request.getBirthWeight());
        reg.setSex(request.getSex());
        reg.setStatus(request.getStatus());
        reg.setNicNumber(request.getNicNumber());
        reg.setPhoneNumber3(request.getPhoneNumber3());
        reg.setPassword(request.getPassword());
        reg.setEmail(request.getEmail());

        Registration saved = repository.save(reg);
        return ResponseEntity.ok(saved);
    }

    // Endpoint to send verification email
    @PostMapping("/send-verification")
    public ResponseEntity<?> sendVerification(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null || !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            return ResponseEntity.badRequest().body("Invalid email format");
        }
        if (repository.findByEmail(email).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Email already registered");
        }
        String token = UUID.randomUUID().toString();

        // Save token and email to DB
        EmailVerificationToken verificationToken = new EmailVerificationToken();
        verificationToken.setEmail(email);
        verificationToken.setToken(token);
        verificationToken.setExpiryDate(LocalDateTime.now().plusHours(24));
        verificationToken.setVerified(false);
        tokenRepository.save(verificationToken);

        emailService.sendVerificationEmail(email, token);
        return ResponseEntity.ok("Verification email sent");
    }

    // Endpoint to verify email using token
    @GetMapping("/verify")
    public ResponseEntity<?> verifyEmail(@RequestParam String token) {
        Optional<EmailVerificationToken> optionalToken = tokenRepository.findByToken(token);
        if (optionalToken.isEmpty()) {
            return ResponseEntity.badRequest().body("Invalid or expired token");
        }
        EmailVerificationToken verificationToken = optionalToken.get();
        if (verificationToken.isVerified()) {
            return ResponseEntity.ok("Email already verified!");
        }
        if (verificationToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body("Token expired");
        }
        verificationToken.setVerified(true);
        tokenRepository.save(verificationToken);
        return ResponseEntity.ok("Email verified successfully!");
    }

    // Optional: Email verification endpoint (for checking if email is available)
    @PostMapping("/verify-email")
    public ResponseEntity<?> verifyEmailAvailability(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null || !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            return ResponseEntity.badRequest().body("Invalid email format");
        }
        if (repository.findByEmail(email).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Email already registered");
        }
        return ResponseEntity.ok("Email is valid and available");
    }
}