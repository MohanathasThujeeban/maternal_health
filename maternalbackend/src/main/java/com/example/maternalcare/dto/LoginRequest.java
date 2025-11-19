package com.example.maternalcare.dto;

public class LoginRequest {
    private String nicNumber;
    private String password;
    private String fullName;

    // Default constructor
    public LoginRequest() {}

    // Constructor with parameters
    public LoginRequest(String nicNumber, String password, String fullName) {
        this.nicNumber = nicNumber;
        this.password = password;
        this.fullName = fullName;
        
    }

    // Getters and setters
    public String getNicNumber() {
        return nicNumber;
    }

    public void setNicNumber(String nicNumber) {
        this.nicNumber = nicNumber;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    public String getFullName() {
        return fullName;
    }
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    @Override
    public String toString() {
        return "LoginRequest{" +
                "nicNumber='" + nicNumber + '\'' +
                ", password='[PROTECTED]'" +
                ", fullName='" + fullName + '\'' +
                '}';
    }
}
