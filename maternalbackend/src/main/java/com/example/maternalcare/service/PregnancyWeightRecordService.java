package com.example.maternalcare.service;

import com.example.maternalcare.model.PregnancyWeightRecord;
import com.example.maternalcare.repository.PregnancyWeightRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class PregnancyWeightRecordService {
    
    @Autowired
    private PregnancyWeightRecordRepository pregnancyWeightRecordRepository;
    
    /**
     * Save a new pregnancy weight record with calculations
     */
    public PregnancyWeightRecord saveWeightRecord(PregnancyWeightRecord record) {
        // Calculate BMI if height is provided
        if (record.getCurrentHeight() != null && record.getCurrentWeight() != null) {
            double heightInMeters = record.getCurrentHeight() / 100.0; // Convert cm to meters
            double bmi = record.getCurrentWeight() / (heightInMeters * heightInMeters);
            record.setBmiCalculated(Math.round(bmi * 10.0) / 10.0); // Round to 1 decimal place
        }
        
        // Calculate weight gain from previous record
        calculateWeightGainFromPrevious(record);
        
        // Check for high-risk indicators
        checkHighRiskIndicators(record);
        
        return pregnancyWeightRecordRepository.save(record);
    }
    
    /**
     * Get all weight records for a mother
     */
    public List<PregnancyWeightRecord> getWeightRecordsByMotherNic(String motherNic) {
        return pregnancyWeightRecordRepository.findByMotherNicOrderByMeasurementDateDesc(motherNic);
    }
    
    /**
     * Get weight records within a date range
     */
    public List<PregnancyWeightRecord> getWeightRecordsInDateRange(String motherNic, LocalDate startDate, LocalDate endDate) {
        return pregnancyWeightRecordRepository.findByMotherNicAndMeasurementDateBetweenOrderByMeasurementDateDesc(
                motherNic, startDate, endDate);
    }
    
    /**
     * Get the most recent weight record for a mother
     */
    public Optional<PregnancyWeightRecord> getLatestWeightRecord(String motherNic) {
        return pregnancyWeightRecordRepository.findFirstByMotherNicOrderByMeasurementDateDescCreatedAtDesc(motherNic);
    }
    
    /**
     * Get weight records by pregnancy week range
     */
    public List<PregnancyWeightRecord> getWeightRecordsByWeekRange(String motherNic, Integer startWeek, Integer endWeek) {
        return pregnancyWeightRecordRepository.findByMotherNicAndPregnancyWeekBetween(motherNic, startWeek, endWeek);
    }
    
    /**
     * Get all high-risk weight records
     */
    public List<PregnancyWeightRecord> getHighRiskRecords() {
        return pregnancyWeightRecordRepository.findByIsHighRiskIndicatorTrueOrderByCreatedAtDesc();
    }
    
    /**
     * Get high-risk weight records for a specific mother
     */
    public List<PregnancyWeightRecord> getHighRiskRecordsByMother(String motherNic) {
        return pregnancyWeightRecordRepository.findByMotherNicAndIsHighRiskIndicatorTrueOrderByMeasurementDateDesc(motherNic);
    }
    
    /**
     * Update an existing weight record
     */
    public PregnancyWeightRecord updateWeightRecord(Long recordId, PregnancyWeightRecord updatedRecord) {
        Optional<PregnancyWeightRecord> existingRecord = pregnancyWeightRecordRepository.findById(recordId);
        
        if (existingRecord.isPresent()) {
            PregnancyWeightRecord record = existingRecord.get();
            
            // Update fields
            record.setCurrentWeight(updatedRecord.getCurrentWeight());
            record.setCurrentHeight(updatedRecord.getCurrentHeight());
            record.setBloodPressure(updatedRecord.getBloodPressure());
            record.setPregnancyWeek(updatedRecord.getPregnancyWeek());
            record.setMeasurementDate(updatedRecord.getMeasurementDate());
            record.setMidwifeNotes(updatedRecord.getMidwifeNotes());
            
            // Recalculate BMI if height and weight are provided
            if (record.getCurrentHeight() != null && record.getCurrentWeight() != null) {
                double heightInMeters = record.getCurrentHeight() / 100.0;
                double bmi = record.getCurrentWeight() / (heightInMeters * heightInMeters);
                record.setBmiCalculated(Math.round(bmi * 10.0) / 10.0);
            }
            
            // Recalculate weight gain from previous
            calculateWeightGainFromPrevious(record);
            
            // Recheck high-risk indicators
            checkHighRiskIndicators(record);
            
            return pregnancyWeightRecordRepository.save(record);
        }
        
        throw new RuntimeException("Weight record not found with id: " + recordId);
    }
    
    /**
     * Delete a weight record
     */
    public void deleteWeightRecord(Long recordId) {
        pregnancyWeightRecordRepository.deleteById(recordId);
    }
    
    /**
     * Get records by midwife
     */
    public List<PregnancyWeightRecord> getRecordsByMidwife(String midwifeNic) {
        return pregnancyWeightRecordRepository.findByRecordedByOrderByCreatedAtDesc(midwifeNic);
    }
    
    /**
     * Get weight gain statistics for a mother
     */
    public Double getAverageWeightGainForTrimester(String motherNic, int trimester) {
        int startWeek, endWeek;
        
        switch (trimester) {
            case 1:
                startWeek = 1;
                endWeek = 12;
                break;
            case 2:
                startWeek = 13;
                endWeek = 26;
                break;
            case 3:
                startWeek = 27;
                endWeek = 42;
                break;
            default:
                throw new IllegalArgumentException("Invalid trimester: " + trimester);
        }
        
        return pregnancyWeightRecordRepository.getAverageWeightGainForPeriod(motherNic, startWeek, endWeek);
    }
    
    /**
     * Check if a mother has any weight records
     */
    public boolean hasWeightRecords(String motherNic) {
        return pregnancyWeightRecordRepository.existsByMotherNic(motherNic);
    }
    
    /**
     * Get total count of weight records for a mother
     */
    public Long getRecordCount(String motherNic) {
        return pregnancyWeightRecordRepository.countByMotherNic(motherNic);
    }
    
    /**
     * Calculate weight gain from previous record
     */
    private void calculateWeightGainFromPrevious(PregnancyWeightRecord currentRecord) {
        if (currentRecord.getMeasurementDate() != null) {
            List<PregnancyWeightRecord> previousRecords = pregnancyWeightRecordRepository
                    .findLatestWeightRecordBefore(currentRecord.getMotherNic(), currentRecord.getMeasurementDate());
            
            if (!previousRecords.isEmpty()) {
                PregnancyWeightRecord previousRecord = previousRecords.get(0);
                double weightGain = currentRecord.getCurrentWeight() - previousRecord.getCurrentWeight();
                currentRecord.setWeightGainFromPrevious(Math.round(weightGain * 10.0) / 10.0);
            }
        }
    }
    
    /**
     * Check for high-risk indicators based on weight, BMI, and weight gain
     */
    private void checkHighRiskIndicators(PregnancyWeightRecord record) {
        boolean isHighRisk = false;
        
        // High-risk BMI indicators
        if (record.getBmiCalculated() != null) {
            // BMI < 18.5 (underweight) or BMI > 30 (obese) during pregnancy
            if (record.getBmiCalculated() < 18.5 || record.getBmiCalculated() > 30.0) {
                isHighRisk = true;
            }
        }
        
        // Excessive weight gain indicators
        if (record.getWeightGainFromPrevious() != null) {
            // More than 2.5 kg weight gain per month (approximately)
            if (record.getWeightGainFromPrevious() > 2.5) {
                isHighRisk = true;
            }
            
            // Rapid weight loss during pregnancy (concerning)
            if (record.getWeightGainFromPrevious() < -1.0) {
                isHighRisk = true;
            }
        }
        
        // Blood pressure indicators (if provided)
        if (record.getBloodPressure() != null && !record.getBloodPressure().isEmpty()) {
            try {
                String[] parts = record.getBloodPressure().split("/");
                if (parts.length == 2) {
                    int systolic = Integer.parseInt(parts[0].trim());
                    int diastolic = Integer.parseInt(parts[1].trim());
                    
                    // High blood pressure indicators (≥140/90 or ≥160/110)
                    if (systolic >= 140 || diastolic >= 90) {
                        isHighRisk = true;
                    }
                }
            } catch (NumberFormatException e) {
                // Invalid blood pressure format, ignore
            }
        }
        
        record.setIsHighRiskIndicator(isHighRisk);
    }
}