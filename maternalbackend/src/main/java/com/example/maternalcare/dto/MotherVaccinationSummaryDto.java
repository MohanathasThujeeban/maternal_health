package com.example.maternalcare.dto;

import java.time.LocalDate;
import java.util.List;

public class MotherVaccinationSummaryDto {
    private String motherNic;
    private String motherName;
    private String phoneNumber;
    private String email;
    private LocalDate registrationDate;
    private int totalVaccinations;
    private int completedVaccinations;
    private int upcomingVaccinations;
    private int overdueVaccinations;
    private List<VaccinationResponse> vaccinations;
    private String currentVaccinationStatus; // Overall status for the mother

    // Default constructor
    public MotherVaccinationSummaryDto() {}

    // Full constructor
    public MotherVaccinationSummaryDto(String motherNic, String motherName, String phoneNumber, 
                                      String email, LocalDate registrationDate, int totalVaccinations, 
                                      int completedVaccinations, int upcomingVaccinations, 
                                      int overdueVaccinations, List<VaccinationResponse> vaccinations,
                                      String currentVaccinationStatus) {
        this.motherNic = motherNic;
        this.motherName = motherName;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.registrationDate = registrationDate;
        this.totalVaccinations = totalVaccinations;
        this.completedVaccinations = completedVaccinations;
        this.upcomingVaccinations = upcomingVaccinations;
        this.overdueVaccinations = overdueVaccinations;
        this.vaccinations = vaccinations;
        this.currentVaccinationStatus = currentVaccinationStatus;
    }

    // Getters and setters
    public String getMotherNic() {
        return motherNic;
    }

    public void setMotherNic(String motherNic) {
        this.motherNic = motherNic;
    }

    public String getMotherName() {
        return motherName;
    }

    public void setMotherName(String motherName) {
        this.motherName = motherName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDate getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(LocalDate registrationDate) {
        this.registrationDate = registrationDate;
    }

    public int getTotalVaccinations() {
        return totalVaccinations;
    }

    public void setTotalVaccinations(int totalVaccinations) {
        this.totalVaccinations = totalVaccinations;
    }

    public int getCompletedVaccinations() {
        return completedVaccinations;
    }

    public void setCompletedVaccinations(int completedVaccinations) {
        this.completedVaccinations = completedVaccinations;
    }

    public int getUpcomingVaccinations() {
        return upcomingVaccinations;
    }

    public void setUpcomingVaccinations(int upcomingVaccinations) {
        this.upcomingVaccinations = upcomingVaccinations;
    }

    public int getOverdueVaccinations() {
        return overdueVaccinations;
    }

    public void setOverdueVaccinations(int overdueVaccinations) {
        this.overdueVaccinations = overdueVaccinations;
    }

    public List<VaccinationResponse> getVaccinations() {
        return vaccinations;
    }

    public void setVaccinations(List<VaccinationResponse> vaccinations) {
        this.vaccinations = vaccinations;
    }

    public String getCurrentVaccinationStatus() {
        return currentVaccinationStatus;
    }

    public void setCurrentVaccinationStatus(String currentVaccinationStatus) {
        this.currentVaccinationStatus = currentVaccinationStatus;
    }

    @Override
    public String toString() {
        return "MotherVaccinationSummaryDto{" +
                "motherNic='" + motherNic + '\'' +
                ", motherName='" + motherName + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", email='" + email + '\'' +
                ", registrationDate=" + registrationDate +
                ", totalVaccinations=" + totalVaccinations +
                ", completedVaccinations=" + completedVaccinations +
                ", upcomingVaccinations=" + upcomingVaccinations +
                ", overdueVaccinations=" + overdueVaccinations +
                ", vaccinations=" + vaccinations +
                ", currentVaccinationStatus='" + currentVaccinationStatus + '\'' +
                '}';
    }
}
