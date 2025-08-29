package com.example.maternalcare.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

public class MaternalProfileDTO {
    
    // Personal Information
    private LocalDate dateOfBirth;
    private Integer age;
    private String religion;
    private String ethnicity;
    private String educationLevel;
    private String occupation;
    private Double monthlyIncome;
    
    // Father's Information
    @Size(max = 100, message = "Father's name must not exceed 100 characters")
    private String fatherName;
    
    @Pattern(regexp = "^[0-9]{9}[vVxX]$|^[0-9]{12}$", 
             message = "Invalid Father's NIC format")
    private String fatherNic;
    
    private Integer fatherAge;
    private String fatherOccupation;
    
    @Pattern(regexp = "^0[0-9]{9}$", message = "Invalid father's phone number format")
    private String fatherPhone;
    
    // Address Information
    private String houseNumber;
    private String streetAddress;
    private String city;
    private String district;
    private String province;
    private String postalCode;
    private String gsDivision;
    private String dsDivision;
    private String mohArea;
    private String phmArea;
    
    // Emergency Contact
    private String emergencyContactName;
    private String emergencyContactRelationship;
    
    @Pattern(regexp = "^0[0-9]{9}$", message = "Invalid emergency contact phone format")
    private String emergencyContactPhone;
    
    // Pregnancy Information
    @Min(value = 0, message = "Number of pregnancies must be 0 or positive")
    private Integer numberOfPregnancies;
    
    @Min(value = 0, message = "Number of live births must be 0 or positive")
    private Integer numberOfLiveBirths;
    
    @Min(value = 0, message = "Number of stillbirths must be 0 or positive")
    private Integer numberOfStillbirths;
    
    @Min(value = 0, message = "Number of abortions must be 0 or positive")
    private Integer numberOfAbortions;
    
    @Min(value = 0, message = "Number of living children must be 0 or positive")
    private Integer numberOfLivingChildren;
    
    private LocalDate lastMenstrualPeriod;
    private LocalDate expectedDeliveryDate;
    
    @Min(value = 1, message = "Pregnancy week must be between 1 and 42")
    @Max(value = 42, message = "Pregnancy week must be between 1 and 42")
    private Integer currentPregnancyWeek;
    
    private String currentPregnancyStatus;
    
    @DecimalMin(value = "30.0", message = "Pre-pregnancy weight must be at least 30 kg")
    @DecimalMax(value = "200.0", message = "Pre-pregnancy weight must not exceed 200 kg")
    private Double prePregnancyWeight;
    
    @DecimalMin(value = "120.0", message = "Height must be at least 120 cm")
    @DecimalMax(value = "250.0", message = "Height must not exceed 250 cm")
    private Double prePregnancyHeight;
    
    private Double prePregnancyBmi;
    
    // Medical History
    @Pattern(regexp = "^(A|B|AB|O)[+-]$", message = "Invalid blood type format (e.g., A+, B-, AB+, O-)")
    private String bloodType;
    
    @Pattern(regexp = "^(Positive|Negative)$", message = "Rhesus factor must be Positive or Negative")
    private String rhesusFactor;
    
    private String chronicDiseases;
    private String allergies;
    private String currentMedications;
    private String previousPregnancyComplications;
    private String familyMedicalHistory;
    
    // Lifestyle Information
    private Boolean smokingStatus = false;
    private Boolean alcoholConsumption = false;
    private String exerciseRoutine;
    private String dietaryRestrictions;
    private String nutritionalSupplements;
    
    // Profile Photo
    private String profilePhotoUrl;
    private String profilePhotoFilename;
    
    // Additional Notes
    private String specialNotes;
    
    // Status
    private Boolean profileCompleted = false;
    private Boolean isHighRiskPregnancy = false;
    
    // Default constructor
    public MaternalProfileDTO() {}
    
    // Getters and Setters
    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }
    
    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }
    
    public Integer getAge() {
        return age;
    }
    
    public void setAge(Integer age) {
        this.age = age;
    }
    
    public String getReligion() {
        return religion;
    }
    
    public void setReligion(String religion) {
        this.religion = religion;
    }
    
    public String getEthnicity() {
        return ethnicity;
    }
    
    public void setEthnicity(String ethnicity) {
        this.ethnicity = ethnicity;
    }
    
    public String getEducationLevel() {
        return educationLevel;
    }
    
    public void setEducationLevel(String educationLevel) {
        this.educationLevel = educationLevel;
    }
    
    public String getOccupation() {
        return occupation;
    }
    
    public void setOccupation(String occupation) {
        this.occupation = occupation;
    }
    
    public Double getMonthlyIncome() {
        return monthlyIncome;
    }
    
    public void setMonthlyIncome(Double monthlyIncome) {
        this.monthlyIncome = monthlyIncome;
    }
    
    public String getFatherName() {
        return fatherName;
    }
    
    public void setFatherName(String fatherName) {
        this.fatherName = fatherName;
    }
    
    public String getFatherNic() {
        return fatherNic;
    }
    
    public void setFatherNic(String fatherNic) {
        this.fatherNic = fatherNic;
    }
    
    public Integer getFatherAge() {
        return fatherAge;
    }
    
    public void setFatherAge(Integer fatherAge) {
        this.fatherAge = fatherAge;
    }
    
    public String getFatherOccupation() {
        return fatherOccupation;
    }
    
    public void setFatherOccupation(String fatherOccupation) {
        this.fatherOccupation = fatherOccupation;
    }
    
    public String getFatherPhone() {
        return fatherPhone;
    }
    
    public void setFatherPhone(String fatherPhone) {
        this.fatherPhone = fatherPhone;
    }
    
    public String getHouseNumber() {
        return houseNumber;
    }
    
    public void setHouseNumber(String houseNumber) {
        this.houseNumber = houseNumber;
    }
    
    public String getStreetAddress() {
        return streetAddress;
    }
    
    public void setStreetAddress(String streetAddress) {
        this.streetAddress = streetAddress;
    }
    
    public String getCity() {
        return city;
    }
    
    public void setCity(String city) {
        this.city = city;
    }
    
    public String getDistrict() {
        return district;
    }
    
    public void setDistrict(String district) {
        this.district = district;
    }
    
    public String getProvince() {
        return province;
    }
    
    public void setProvince(String province) {
        this.province = province;
    }
    
    public String getPostalCode() {
        return postalCode;
    }
    
    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }
    
    public String getGsDivision() {
        return gsDivision;
    }
    
    public void setGsDivision(String gsDivision) {
        this.gsDivision = gsDivision;
    }
    
    public String getDsDivision() {
        return dsDivision;
    }
    
    public void setDsDivision(String dsDivision) {
        this.dsDivision = dsDivision;
    }
    
    public String getMohArea() {
        return mohArea;
    }
    
    public void setMohArea(String mohArea) {
        this.mohArea = mohArea;
    }
    
    public String getPhmArea() {
        return phmArea;
    }
    
    public void setPhmArea(String phmArea) {
        this.phmArea = phmArea;
    }
    
    public String getEmergencyContactName() {
        return emergencyContactName;
    }
    
    public void setEmergencyContactName(String emergencyContactName) {
        this.emergencyContactName = emergencyContactName;
    }
    
    public String getEmergencyContactRelationship() {
        return emergencyContactRelationship;
    }
    
    public void setEmergencyContactRelationship(String emergencyContactRelationship) {
        this.emergencyContactRelationship = emergencyContactRelationship;
    }
    
    public String getEmergencyContactPhone() {
        return emergencyContactPhone;
    }
    
    public void setEmergencyContactPhone(String emergencyContactPhone) {
        this.emergencyContactPhone = emergencyContactPhone;
    }
    
    public Integer getNumberOfPregnancies() {
        return numberOfPregnancies;
    }
    
    public void setNumberOfPregnancies(Integer numberOfPregnancies) {
        this.numberOfPregnancies = numberOfPregnancies;
    }
    
    public Integer getNumberOfLiveBirths() {
        return numberOfLiveBirths;
    }
    
    public void setNumberOfLiveBirths(Integer numberOfLiveBirths) {
        this.numberOfLiveBirths = numberOfLiveBirths;
    }
    
    public Integer getNumberOfStillbirths() {
        return numberOfStillbirths;
    }
    
    public void setNumberOfStillbirths(Integer numberOfStillbirths) {
        this.numberOfStillbirths = numberOfStillbirths;
    }
    
    public Integer getNumberOfAbortions() {
        return numberOfAbortions;
    }
    
    public void setNumberOfAbortions(Integer numberOfAbortions) {
        this.numberOfAbortions = numberOfAbortions;
    }
    
    public Integer getNumberOfLivingChildren() {
        return numberOfLivingChildren;
    }
    
    public void setNumberOfLivingChildren(Integer numberOfLivingChildren) {
        this.numberOfLivingChildren = numberOfLivingChildren;
    }
    
    public LocalDate getLastMenstrualPeriod() {
        return lastMenstrualPeriod;
    }
    
    public void setLastMenstrualPeriod(LocalDate lastMenstrualPeriod) {
        this.lastMenstrualPeriod = lastMenstrualPeriod;
    }
    
    public LocalDate getExpectedDeliveryDate() {
        return expectedDeliveryDate;
    }
    
    public void setExpectedDeliveryDate(LocalDate expectedDeliveryDate) {
        this.expectedDeliveryDate = expectedDeliveryDate;
    }
    
    public Integer getCurrentPregnancyWeek() {
        return currentPregnancyWeek;
    }
    
    public void setCurrentPregnancyWeek(Integer currentPregnancyWeek) {
        this.currentPregnancyWeek = currentPregnancyWeek;
    }
    
    public String getCurrentPregnancyStatus() {
        return currentPregnancyStatus;
    }
    
    public void setCurrentPregnancyStatus(String currentPregnancyStatus) {
        this.currentPregnancyStatus = currentPregnancyStatus;
    }
    
    public Double getPrePregnancyWeight() {
        return prePregnancyWeight;
    }
    
    public void setPrePregnancyWeight(Double prePregnancyWeight) {
        this.prePregnancyWeight = prePregnancyWeight;
    }
    
    public Double getPrePregnancyHeight() {
        return prePregnancyHeight;
    }
    
    public void setPrePregnancyHeight(Double prePregnancyHeight) {
        this.prePregnancyHeight = prePregnancyHeight;
    }
    
    public Double getPrePregnancyBmi() {
        return prePregnancyBmi;
    }
    
    public void setPrePregnancyBmi(Double prePregnancyBmi) {
        this.prePregnancyBmi = prePregnancyBmi;
    }
    
    public String getBloodType() {
        return bloodType;
    }
    
    public void setBloodType(String bloodType) {
        this.bloodType = bloodType;
    }
    
    public String getRhesusFactor() {
        return rhesusFactor;
    }
    
    public void setRhesusFactor(String rhesusFactor) {
        this.rhesusFactor = rhesusFactor;
    }
    
    public String getChronicDiseases() {
        return chronicDiseases;
    }
    
    public void setChronicDiseases(String chronicDiseases) {
        this.chronicDiseases = chronicDiseases;
    }
    
    public String getAllergies() {
        return allergies;
    }
    
    public void setAllergies(String allergies) {
        this.allergies = allergies;
    }
    
    public String getCurrentMedications() {
        return currentMedications;
    }
    
    public void setCurrentMedications(String currentMedications) {
        this.currentMedications = currentMedications;
    }
    
    public String getPreviousPregnancyComplications() {
        return previousPregnancyComplications;
    }
    
    public void setPreviousPregnancyComplications(String previousPregnancyComplications) {
        this.previousPregnancyComplications = previousPregnancyComplications;
    }
    
    public String getFamilyMedicalHistory() {
        return familyMedicalHistory;
    }
    
    public void setFamilyMedicalHistory(String familyMedicalHistory) {
        this.familyMedicalHistory = familyMedicalHistory;
    }
    
    public Boolean getSmokingStatus() {
        return smokingStatus;
    }
    
    public void setSmokingStatus(Boolean smokingStatus) {
        this.smokingStatus = smokingStatus;
    }
    
    public Boolean getAlcoholConsumption() {
        return alcoholConsumption;
    }
    
    public void setAlcoholConsumption(Boolean alcoholConsumption) {
        this.alcoholConsumption = alcoholConsumption;
    }
    
    public String getExerciseRoutine() {
        return exerciseRoutine;
    }
    
    public void setExerciseRoutine(String exerciseRoutine) {
        this.exerciseRoutine = exerciseRoutine;
    }
    
    public String getDietaryRestrictions() {
        return dietaryRestrictions;
    }
    
    public void setDietaryRestrictions(String dietaryRestrictions) {
        this.dietaryRestrictions = dietaryRestrictions;
    }
    
    public String getNutritionalSupplements() {
        return nutritionalSupplements;
    }
    
    public void setNutritionalSupplements(String nutritionalSupplements) {
        this.nutritionalSupplements = nutritionalSupplements;
    }
    
    public String getProfilePhotoUrl() {
        return profilePhotoUrl;
    }
    
    public void setProfilePhotoUrl(String profilePhotoUrl) {
        this.profilePhotoUrl = profilePhotoUrl;
    }
    
    public String getProfilePhotoFilename() {
        return profilePhotoFilename;
    }
    
    public void setProfilePhotoFilename(String profilePhotoFilename) {
        this.profilePhotoFilename = profilePhotoFilename;
    }
    
    public String getSpecialNotes() {
        return specialNotes;
    }
    
    public void setSpecialNotes(String specialNotes) {
        this.specialNotes = specialNotes;
    }
    
    public Boolean getProfileCompleted() {
        return profileCompleted;
    }
    
    public void setProfileCompleted(Boolean profileCompleted) {
        this.profileCompleted = profileCompleted;
    }
    
    public Boolean getIsHighRiskPregnancy() {
        return isHighRiskPregnancy;
    }
    
    public void setIsHighRiskPregnancy(Boolean isHighRiskPregnancy) {
        this.isHighRiskPregnancy = isHighRiskPregnancy;
    }
}
