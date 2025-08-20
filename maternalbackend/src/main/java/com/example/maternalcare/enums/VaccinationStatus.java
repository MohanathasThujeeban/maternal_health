package com.example.maternalcare.enums;

public enum VaccinationStatus {
    PENDING("Pending"),
    COMPLETED("Completed"),
    MISSED("Missed"),
    OVERDUE("Overdue");

    private final String displayName;

    VaccinationStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }
}
