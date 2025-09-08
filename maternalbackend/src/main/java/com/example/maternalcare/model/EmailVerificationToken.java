package com.example.maternalcare.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "email_verification_tokens")
public class EmailVerificationToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String email;
    
    @Column(nullable = false, unique = true)
    private String token;
    
    @Column(nullable = false, columnDefinition = "DATETIME")
    private LocalDateTime createdAt;
    
    @Column(nullable = false, columnDefinition = "DATETIME")
    private LocalDateTime expiryDate;
    
    private boolean verified = false;

    // Constructors
    public EmailVerificationToken() {}
    
    public EmailVerificationToken(String token, String email) {
        this.token = token;
        this.email = email;
        this.createdAt = LocalDateTime.now();
        this.expiryDate = LocalDateTime.now().plusHours(24); // 24 hours expiry
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDateTime expiryDate) { this.expiryDate = expiryDate; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }
    
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiryDate);
    }
}