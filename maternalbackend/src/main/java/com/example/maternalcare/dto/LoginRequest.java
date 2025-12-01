package com.example.maternalcare.dto;

public class LoginRequest {
    private String nicNumber;
    private String password;

    // Default constructor
    public LoginRequest() {}

    // Constructor with parameters
    public LoginRequest(String nicNumber, String password) {
        this.nicNumber = nicNumber;
        this.password = password;
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

    @Override
    public String toString() {
        return "LoginRequest{" +
                "nicNumber='" + nicNumber + '\'' +
                ", password='[PROTECTED]'" +
                '}';
    }
}
