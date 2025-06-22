package com.example.maternalcare.dto;

public class RegistrationRequest {
    // Example fields from all three registration screens
    private String motherFullName;
    private String fatherFullName;
    private String address;
    private String phoneNumber;
    private String age;
    private String occupation;
    private String ethnicity;
    private String religion;
    private String educationLevel;

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

    private String nicNumber;
    private String phoneNumber3;
    private String password;
    private String email; // New field for email

    // Getters and setters for all fields
    public String getMotherFullName() { return motherFullName; }
    public void setMotherFullName(String motherFullName) { this.motherFullName = motherFullName; }
    public String getFatherFullName() { return fatherFullName; }
    public void setFatherFullName(String fatherFullName) { this.fatherFullName = fatherFullName; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getAge() { return age; }
    public void setAge(String age) { this.age = age; }
    public String getOccupation() { return occupation; }
    public void setOccupation(String occupation) { this.occupation = occupation; }
    public String getEthnicity() { return ethnicity; }
    public void setEthnicity(String ethnicity) { this.ethnicity = ethnicity; }
    public String getReligion() { return religion; }
    public void setReligion(String religion) { this.religion = religion; }
    public String getEducationLevel() { return educationLevel; }
    public void setEducationLevel(String educationLevel) { this.educationLevel = educationLevel; }
    public String getGravida() { return gravida; }
    public void setGravida(String gravida) { this.gravida = gravida; }
    public String getPara() { return para; }
    public void setPara(String para) { this.para = para; }
    public String getLmp() { return lmp; }
    public void setLmp(String lmp) { this.lmp = lmp; }
    public String getEdd() { return edd; }
    public void setEdd(String edd) { this.edd = edd; }
    public String getPreviousPregnancies() { return previousPregnancies; }
    public void setPreviousPregnancies(String previousPregnancies) { this.previousPregnancies = previousPregnancies; }
    public String getYear() { return year; }
    public void setYear(String year) { this.year = year; }
    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }
    public String getModeOfDelivery() { return modeOfDelivery; }
    public void setModeOfDelivery(String modeOfDelivery) { this.modeOfDelivery = modeOfDelivery; }
    public String getBirthWeight() { return birthWeight; }
    public void setBirthWeight(String birthWeight) { this.birthWeight = birthWeight; }
    public String getSex() { return sex; }
    public void setSex(String sex) { this.sex = sex; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getNicNumber() { return nicNumber; }
    public void setNicNumber(String nicNumber) { this.nicNumber = nicNumber; }
    public String getPhoneNumber3() { return phoneNumber3; }
    public void setPhoneNumber3(String phoneNumber3) { this.phoneNumber3 = phoneNumber3; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; } // Getter for email
    public void setEmail(String email) { this.email = email; } // Setter for email
}