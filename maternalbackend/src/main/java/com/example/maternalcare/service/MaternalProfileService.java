package com.example.maternalcare.service;

import com.example.maternalcare.dto.MaternalProfileDTO;
import com.example.maternalcare.model.MaternalProfile;
import com.example.maternalcare.repository.MaternalProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Period;
import java.util.Optional;

@Service
@Transactional
public class MaternalProfileService {
    
    @Autowired
    private MaternalProfileRepository maternalProfileRepository;
    
    /**
     * Get maternal profile by mother NIC
     */
    public Optional<MaternalProfile> getProfileByMotherNic(String motherNic) {
        return maternalProfileRepository.findByMotherNic(motherNic);
    }
    
    /**
     * Create or update maternal profile
     */
    public MaternalProfile createOrUpdateProfile(String motherNic, MaternalProfileDTO profileDTO) {
        MaternalProfile profile = maternalProfileRepository.findByMotherNic(motherNic)
                .orElse(new MaternalProfile(motherNic));
        
        // Update profile fields from DTO
        updateProfileFromDTO(profile, profileDTO);
        
        // Calculate derived fields
        calculateDerivedFields(profile);
        
        // Set last updated by
        profile.setLastUpdatedBy(motherNic);
        
        return maternalProfileRepository.save(profile);
    }
    
    /**
     * Update profile fields from DTO
     */
    private void updateProfileFromDTO(MaternalProfile profile, MaternalProfileDTO dto) {
        // Personal Information
        if (dto.getDateOfBirth() != null) {
            profile.setDateOfBirth(dto.getDateOfBirth());
        }
        if (dto.getAge() != null) {
            profile.setAge(dto.getAge());
        }
        if (dto.getReligion() != null) {
            profile.setReligion(dto.getReligion());
        }
        if (dto.getEthnicity() != null) {
            profile.setEthnicity(dto.getEthnicity());
        }
        if (dto.getEducationLevel() != null) {
            profile.setEducationLevel(dto.getEducationLevel());
        }
        if (dto.getOccupation() != null) {
            profile.setOccupation(dto.getOccupation());
        }
        if (dto.getMonthlyIncome() != null) {
            profile.setMonthlyIncome(dto.getMonthlyIncome());
        }
        
        // Father's Information
        if (dto.getFatherName() != null) {
            profile.setFatherName(dto.getFatherName());
        }
        if (dto.getFatherNic() != null) {
            profile.setFatherNic(dto.getFatherNic());
        }
        if (dto.getFatherAge() != null) {
            profile.setFatherAge(dto.getFatherAge());
        }
        if (dto.getFatherOccupation() != null) {
            profile.setFatherOccupation(dto.getFatherOccupation());
        }
        if (dto.getFatherPhone() != null) {
            profile.setFatherPhone(dto.getFatherPhone());
        }
        
        // Address Information
        if (dto.getHouseNumber() != null) {
            profile.setHouseNumber(dto.getHouseNumber());
        }
        if (dto.getStreetAddress() != null) {
            profile.setStreetAddress(dto.getStreetAddress());
        }
        if (dto.getCity() != null) {
            profile.setCity(dto.getCity());
        }
        if (dto.getDistrict() != null) {
            profile.setDistrict(dto.getDistrict());
        }
        if (dto.getProvince() != null) {
            profile.setProvince(dto.getProvince());
        }
        if (dto.getPostalCode() != null) {
            profile.setPostalCode(dto.getPostalCode());
        }
        if (dto.getGsDivision() != null) {
            profile.setGsDivision(dto.getGsDivision());
        }
        if (dto.getDsDivision() != null) {
            profile.setDsDivision(dto.getDsDivision());
        }
        if (dto.getMohArea() != null) {
            profile.setMohArea(dto.getMohArea());
        }
        if (dto.getPhmArea() != null) {
            profile.setPhmArea(dto.getPhmArea());
        }
        
        // Emergency Contact
        if (dto.getEmergencyContactName() != null) {
            profile.setEmergencyContactName(dto.getEmergencyContactName());
        }
        if (dto.getEmergencyContactRelationship() != null) {
            profile.setEmergencyContactRelationship(dto.getEmergencyContactRelationship());
        }
        if (dto.getEmergencyContactPhone() != null) {
            profile.setEmergencyContactPhone(dto.getEmergencyContactPhone());
        }
        
        // Pregnancy Information
        if (dto.getNumberOfPregnancies() != null) {
            profile.setNumberOfPregnancies(dto.getNumberOfPregnancies());
        }
        if (dto.getNumberOfLiveBirths() != null) {
            profile.setNumberOfLiveBirths(dto.getNumberOfLiveBirths());
        }
        if (dto.getNumberOfStillbirths() != null) {
            profile.setNumberOfStillbirths(dto.getNumberOfStillbirths());
        }
        if (dto.getNumberOfAbortions() != null) {
            profile.setNumberOfAbortions(dto.getNumberOfAbortions());
        }
        if (dto.getNumberOfLivingChildren() != null) {
            profile.setNumberOfLivingChildren(dto.getNumberOfLivingChildren());
        }
        if (dto.getLastMenstrualPeriod() != null) {
            profile.setLastMenstrualPeriod(dto.getLastMenstrualPeriod());
        }
        if (dto.getExpectedDeliveryDate() != null) {
            profile.setExpectedDeliveryDate(dto.getExpectedDeliveryDate());
        }
        if (dto.getCurrentPregnancyWeek() != null) {
            profile.setCurrentPregnancyWeek(dto.getCurrentPregnancyWeek());
        }
        if (dto.getCurrentPregnancyStatus() != null) {
            profile.setCurrentPregnancyStatus(dto.getCurrentPregnancyStatus());
        }
        if (dto.getPrePregnancyWeight() != null) {
            profile.setPrePregnancyWeight(dto.getPrePregnancyWeight());
        }
        if (dto.getPrePregnancyHeight() != null) {
            profile.setPrePregnancyHeight(dto.getPrePregnancyHeight());
        }
        
        // Medical History
        if (dto.getBloodType() != null) {
            profile.setBloodType(dto.getBloodType());
        }
        if (dto.getRhesusFactor() != null) {
            profile.setRhesusFactor(dto.getRhesusFactor());
        }
        if (dto.getChronicDiseases() != null) {
            profile.setChronicDiseases(dto.getChronicDiseases());
        }
        if (dto.getAllergies() != null) {
            profile.setAllergies(dto.getAllergies());
        }
        if (dto.getCurrentMedications() != null) {
            profile.setCurrentMedications(dto.getCurrentMedications());
        }
        if (dto.getPreviousPregnancyComplications() != null) {
            profile.setPreviousPregnancyComplications(dto.getPreviousPregnancyComplications());
        }
        if (dto.getFamilyMedicalHistory() != null) {
            profile.setFamilyMedicalHistory(dto.getFamilyMedicalHistory());
        }
        
        // Lifestyle Information
        if (dto.getSmokingStatus() != null) {
            profile.setSmokingStatus(dto.getSmokingStatus());
        }
        if (dto.getAlcoholConsumption() != null) {
            profile.setAlcoholConsumption(dto.getAlcoholConsumption());
        }
        if (dto.getExerciseRoutine() != null) {
            profile.setExerciseRoutine(dto.getExerciseRoutine());
        }
        if (dto.getDietaryRestrictions() != null) {
            profile.setDietaryRestrictions(dto.getDietaryRestrictions());
        }
        if (dto.getNutritionalSupplements() != null) {
            profile.setNutritionalSupplements(dto.getNutritionalSupplements());
        }
        
        // Profile Photo
        if (dto.getProfilePhotoUrl() != null) {
            profile.setProfilePhotoUrl(dto.getProfilePhotoUrl());
        }
        if (dto.getProfilePhotoFilename() != null) {
            profile.setProfilePhotoFilename(dto.getProfilePhotoFilename());
        }
        
        // Additional Notes
        if (dto.getSpecialNotes() != null) {
            profile.setSpecialNotes(dto.getSpecialNotes());
        }
        
        // Status
        if (dto.getProfileCompleted() != null) {
            profile.setProfileCompleted(dto.getProfileCompleted());
        }
        if (dto.getIsHighRiskPregnancy() != null) {
            profile.setIsHighRiskPregnancy(dto.getIsHighRiskPregnancy());
        }
    }
    
    /**
     * Calculate derived fields like BMI, age from DOB, etc.
     */
    private void calculateDerivedFields(MaternalProfile profile) {
        // Calculate age from date of birth
        if (profile.getDateOfBirth() != null) {
            LocalDate now = LocalDate.now();
            Period period = Period.between(profile.getDateOfBirth(), now);
            profile.setAge(period.getYears());
        }
        
        // Calculate BMI if weight and height are available
        if (profile.getPrePregnancyWeight() != null && profile.getPrePregnancyHeight() != null) {
            double heightInMeters = profile.getPrePregnancyHeight() / 100.0;
            double bmi = profile.getPrePregnancyWeight() / (heightInMeters * heightInMeters);
            profile.setPrePregnancyBmi(Math.round(bmi * 100.0) / 100.0);
        }
        
        // Calculate expected delivery date from LMP if not provided
        if (profile.getLastMenstrualPeriod() != null && profile.getExpectedDeliveryDate() == null) {
            LocalDate edd = profile.getLastMenstrualPeriod().plusDays(280); // 40 weeks
            profile.setExpectedDeliveryDate(edd);
        }
        
        // Calculate current pregnancy week from LMP
        if (profile.getLastMenstrualPeriod() != null) {
            LocalDate now = LocalDate.now();
            long daysSinceLMP = profile.getLastMenstrualPeriod().until(now).getDays();
            int weeks = (int) (daysSinceLMP / 7);
            if (weeks >= 0 && weeks <= 42) {
                profile.setCurrentPregnancyWeek(weeks);
            }
        }
        
        // Determine if high-risk pregnancy
        determineHighRiskPregnancy(profile);
    }
    
    /**
     * Determine if this is a high-risk pregnancy based on various factors
     */
    private void determineHighRiskPregnancy(MaternalProfile profile) {
        boolean isHighRisk = false;
        
        // Age-related risk factors
        if (profile.getAge() != null && (profile.getAge() < 18 || profile.getAge() > 35)) {
            isHighRisk = true;
        }
        
        // BMI-related risk factors
        if (profile.getPrePregnancyBmi() != null && 
            (profile.getPrePregnancyBmi() < 18.5 || profile.getPrePregnancyBmi() > 30.0)) {
            isHighRisk = true;
        }
        
        // Medical history risk factors
        if (profile.getChronicDiseases() != null && !profile.getChronicDiseases().trim().isEmpty()) {
            isHighRisk = true;
        }
        
        // Previous pregnancy complications
        if (profile.getPreviousPregnancyComplications() != null && 
            !profile.getPreviousPregnancyComplications().trim().isEmpty()) {
            isHighRisk = true;
        }
        
        // Multiple pregnancies
        if (profile.getNumberOfPregnancies() != null && profile.getNumberOfPregnancies() > 5) {
            isHighRisk = true;
        }
        
        // Lifestyle risk factors
        if (Boolean.TRUE.equals(profile.getSmokingStatus()) || 
            Boolean.TRUE.equals(profile.getAlcoholConsumption())) {
            isHighRisk = true;
        }
        
        profile.setIsHighRiskPregnancy(isHighRisk);
    }
    
    /**
     * Check if profile exists for mother NIC
     */
    public boolean profileExists(String motherNic) {
        return maternalProfileRepository.existsByMotherNic(motherNic);
    }
    
    /**
     * Delete profile by mother NIC
     */
    public boolean deleteProfile(String motherNic) {
        Optional<MaternalProfile> profile = maternalProfileRepository.findByMotherNic(motherNic);
        if (profile.isPresent()) {
            maternalProfileRepository.delete(profile.get());
            return true;
        }
        return false;
    }
}
