package com.example.maternalcare.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "password_reset_token")
public class PasswordResetToken {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String token;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = true)
    private Registration user;
    
    // For healthcare provider password reset
    @Column(name = "provider_email")
    private String providerEmail;
    
    @Column(name = "provider_type")
    private String providerType; // "REGULAR_USER" or "HEALTHCARE_PROVIDER"
    
    @Column(nullable = false, columnDefinition = "DATETIME")
    private LocalDateTime expiryDate;
    
    @Column(nullable = false)
    private Boolean used = false;
    
    @Column(name = "created_at", nullable = false, columnDefinition = "DATETIME")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    // Constructors
    public PasswordResetToken() {}
    
    public PasswordResetToken(String token, Registration user, LocalDateTime expiryDate) {
        this.token = token;
        this.user = user;
        this.expiryDate = expiryDate;
        this.providerType = "REGULAR_USER";
    }
    
    // Constructor for healthcare provider password reset
    public PasswordResetToken(String token, String providerEmail, String providerType, LocalDateTime expiryDate) {
        this.token = token;
        this.providerEmail = providerEmail;
        this.providerType = providerType;
        this.expiryDate = expiryDate;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public Registration getUser() {
        return user;
    }
    
    public void setUser(Registration user) {
        this.user = user;
    }
    
    public LocalDateTime getExpiryDate() {
        return expiryDate;
    }
    
    public void setExpiryDate(LocalDateTime expiryDate) {
        this.expiryDate = expiryDate;
    }
    
    public Boolean getUsed() {
        return used;
    }
    
    public void setUsed(Boolean used) {
        this.used = used;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getProviderEmail() {
        return providerEmail;
    }
    
    public void setProviderEmail(String providerEmail) {
        this.providerEmail = providerEmail;
    }
    
    public String getProviderType() {
        return providerType;
    }
    
    public void setProviderType(String providerType) {
        this.providerType = providerType;
    }
    
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiryDate);
    }
}
