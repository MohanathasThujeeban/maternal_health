package com.example.maternalcare.model;

public enum UserRole {
    MOTHER("Mother"),
    MIDWIFE("Midwife"),
    DOCTOR("Doctor"),
    ADMIN("Administrator");
    
    private final String displayName;
    
    UserRole(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
