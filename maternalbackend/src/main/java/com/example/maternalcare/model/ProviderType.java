package com.example.maternalcare.model;

public enum ProviderType {
    MIDWIFE("Midwife"),
    DOCTOR("Doctor"),
    NURSE("Nurse"),
    SPECIALIST("Specialist");
    
    private final String displayName;
    
    ProviderType(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
