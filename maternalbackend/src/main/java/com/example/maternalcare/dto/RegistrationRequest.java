package com.example.maternalcare.dto;

public class RegistrationRequest {
    // Example fields from all three registration screens

    private String fullName;
    private String nicNumber;
    private String phoneNumber3;
    private String password;
    private String email; // New field for email

    // Getters and setters for all fields
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getNicNumber() { return nicNumber; }
    public void setNicNumber(String nicNumber) { this.nicNumber = nicNumber; }
    public String getPhoneNumber3() { return phoneNumber3; }
    public void setPhoneNumber3(String phoneNumber3) { this.phoneNumber3 = phoneNumber3; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; } // Getter for email
    public void setEmail(String email) { this.email = email; } // Setter for email
}