package com.example.maternalcare.dto;

import java.time.LocalDateTime;

public class LoginResponse {
    private boolean success;
    private String message;
    private Long userId;
    private String email;
    private String nicNumber;
    private String phoneNumber;
    private LocalDateTime timestamp;

    // Default constructor
    public LoginResponse() {}

    // Constructor for success response
    public LoginResponse(boolean success, String message, Long userId, String email, String nicNumber, String phoneNumber) {
        this.success = success;
        this.message = message;
        this.userId = userId;
        this.email = email;
        this.nicNumber = nicNumber;
        this.phoneNumber = phoneNumber;
        this.timestamp = LocalDateTime.now();
    }

    // Constructor for error response
    public LoginResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNicNumber() {
        return nicNumber;
    }

    public void setNicNumber(String nicNumber) {
        this.nicNumber = nicNumber;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
