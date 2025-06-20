package com.example.maternalcare.dto;

import lombok.Data;

@Data
public class RegistrationRequest {
    // Screen 1
    private String motherFullName;
    private String fatherFullName;
    private String address;
    private String phoneNumber;
    private int age;
    private String occupation;
    private String ethnicity;
    private String religion;
    private String educationLevel;

    // Screen 2
    private String gravida;
    private String para;
    private String lmp;
    private String edd;
    private String previousPregnancies;
    private String year;
    private String duration;
    private String modeOfDelivery;
    private String birthWeight;
    private String sex;
    private String status;

    // Add more fields for screen 3 as needed
}
