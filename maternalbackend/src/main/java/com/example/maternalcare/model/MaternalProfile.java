package com.example.maternalcare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "maternal_profiles")
public class MaternalProfile {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mother_nic", nullable = false, unique = true, length = 12)
    @NotBlank(message = "Mother NIC is required")
    private String motherNic;
    
    // Personal Information
    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;
    
    @Column(name = "age")
    private Integer age;
    
    @Column(name = "religion", length = 50)
    private String religion;
    
    @Column(name = "ethnicity", length = 50)
    private String ethnicity;
    
    @Column(name = "education_level", length = 100)
    private String educationLevel;
    
    @Column(name = "occupation", length = 100)
    private String occupation;
    
    @Column(name = "monthly_income")
    private Double monthlyIncome;
    
    // Father's Information
    @Column(name = "father_name", length = 100)
    private String fatherName;
    
    @Column(name = "father_nic", length = 12)
    private String fatherNic;
    
    @Column(name = "father_age")
    private Integer fatherAge;
    
    @Column(name = "father_occupation", length = 100)
    private String fatherOccupation;
    
    @Column(name = "father_phone", length = 15)
    private String fatherPhone;
    
    // Address Information
    @Column(name = "house_number", length = 20)
    private String houseNumber;
    
    @Column(name = "street_address", length = 200)
    private String streetAddress;
    
    @Column(name = "city", length = 100)
    private String city;
    
    @Column(name = "district", length = 50)
    private String district;
    
    @Column(name = "province", length = 50)
    private String province;
    
    @Column(name = "postal_code", length = 10)
    private String postalCode;
    
    @Column(name = "gs_division", length = 100)
    private String gsDivision;
    
    @Column(name = "ds_division", length = 100)
    private String dsDivision;
    
    @Column(name = "moh_area", length = 100)
    private String mohArea;
    
    @Column(name = "phm_area", length = 100)
    private String phmArea;
    
    // Emergency Contact
    @Column(name = "emergency_contact_name", length = 100)
    private String emergencyContactName;
    
    @Column(name = "emergency_contact_relationship", length = 50)
    private String emergencyContactRelationship;
    
    @Column(name = "emergency_contact_phone", length = 15)
    private String emergencyContactPhone;
    
    // Pregnancy Information
    @Column(name = "number_of_pregnancies")
    private Integer numberOfPregnancies;
    
    @Column(name = "number_of_live_births")
    private Integer numberOfLiveBirths;
    
    @Column(name = "number_of_stillbirths")
    private Integer numberOfStillbirths;
    
    @Column(name = "number_of_abortions")
    private Integer numberOfAbortions;
    
    @Column(name = "number_of_living_children")
    private Integer numberOfLivingChildren;
    
    @Column(name = "last_menstrual_period")
    private LocalDate lastMenstrualPeriod;
    
    @Column(name = "expected_delivery_date")
    private LocalDate expectedDeliveryDate;
    
    @Column(name = "current_pregnancy_week")
    private Integer currentPregnancyWeek;
    
    @Column(name = "current_pregnancy_status", length = 50)
    private String currentPregnancyStatus;
    
    @Column(name = "pre_pregnancy_weight")
    private Double prePregnancyWeight;
    
    @Column(name = "pre_pregnancy_height")
    private Double prePregnancyHeight;
    
    @Column(name = "pre_pregnancy_bmi")
    private Double prePregnancyBmi;
    
    // Medical History
    @Column(name = "blood_type", length = 10)
    private String bloodType;
    
    @Column(name = "rhesus_factor", length = 10)
    private String rhesusFactor;
    
    @Column(name = "chronic_diseases", columnDefinition = "TEXT")
    private String chronicDiseases;
    
    @Column(name = "allergies", columnDefinition = "TEXT")
    private String allergies;
    
    @Column(name = "medications", columnDefinition = "TEXT")
    private String currentMedications;
    
    @Column(name = "previous_pregnancy_complications", columnDefinition = "TEXT")
    private String previousPregnancyComplications;
    
    @Column(name = "family_medical_history", columnDefinition = "TEXT")
    private String familyMedicalHistory;
    
    // Lifestyle Information
    @Column(name = "smoking_status")
    private Boolean smokingStatus = false;
    
    @Column(name = "alcohol_consumption")
    private Boolean alcoholConsumption = false;
    
    @Column(name = "exercise_routine", length = 200)
    private String exerciseRoutine;
    
    @Column(name = "dietary_restrictions", columnDefinition = "TEXT")
    private String dietaryRestrictions;
    
    @Column(name = "nutritional_supplements", columnDefinition = "TEXT")
    private String nutritionalSupplements;
    
    // Profile Photo
    @Column(name = "profile_photo_url", columnDefinition = "TEXT")
    private String profilePhotoUrl;
    
    @Column(name = "profile_photo_filename", length = 255)
    private String profilePhotoFilename;
    
    // Additional Notes
    @Column(name = "special_notes", columnDefinition = "TEXT")
    private String specialNotes;
    
    @Column(name = "midwife_notes", columnDefinition = "TEXT")
    private String midwifeNotes;
    
    // Status and Timestamps
    @Column(name = "profile_completed", nullable = false)
    private Boolean profileCompleted = false;
    
    @Column(name = "is_high_risk_pregnancy")
    private Boolean isHighRiskPregnancy = false;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false, columnDefinition = "DATETIME")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", columnDefinition = "DATETIME")
    private LocalDateTime updatedAt;
    
    @Column(name = "last_updated_by", length = 12)
    private String lastUpdatedBy;
    
    // Default constructor
    public MaternalProfile() {}
    
    // Constructor with mother NIC
    public MaternalProfile(String motherNic) {
        this.motherNic = motherNic;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getMotherNic() {
        return motherNic;
    }
    
    public void setMotherNic(String motherNic) {
        this.motherNic = motherNic;
    }
    
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
    
    public String getMidwifeNotes() {
        return midwifeNotes;
    }
    
    public void setMidwifeNotes(String midwifeNotes) {
        this.midwifeNotes = midwifeNotes;
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
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getLastUpdatedBy() {
        return lastUpdatedBy;
    }
    
    public void setLastUpdatedBy(String lastUpdatedBy) {
        this.lastUpdatedBy = lastUpdatedBy;
    }
}
