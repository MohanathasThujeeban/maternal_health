package com.example.maternalcare.services;

import com.example.maternalcare.model.HealthcareProvider;
import com.example.maternalcare.model.ProviderType;
import com.example.maternalcare.repository.HealthcareProviderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class HealthcareProviderService {
    
    @Autowired
    private HealthcareProviderRepository healthcareProviderRepository;
    
    // Get all active healthcare providers
    public List<HealthcareProvider> getAllActiveProviders() {
        return healthcareProviderRepository.findByIsApprovedTrueAndIsActiveTrue();
    }
    
    // Get providers by type
    public List<HealthcareProvider> getProvidersByType(ProviderType providerType) {
        return healthcareProviderRepository.findByProviderType(providerType)
                .stream()
                .filter(provider -> provider.getIsApproved() && provider.getIsActive())
                .collect(Collectors.toList());
    }
    
    // Get available providers formatted for appointment service
    public Map<String, List<Map<String, String>>> getAvailableProvidersForAppointments() {
        List<HealthcareProvider> doctors = getProvidersByType(ProviderType.DOCTOR);
        List<HealthcareProvider> midwives = getProvidersByType(ProviderType.MIDWIFE);
        
        return Map.of(
            "doctor", doctors.stream()
                    .map(this::convertToProviderMap)
                    .collect(Collectors.toList()),
            "midwife", midwives.stream()
                    .map(this::convertToProviderMap)
                    .collect(Collectors.toList())
        );
    }
    
    // Convert HealthcareProvider to Map format for appointments
    private Map<String, String> convertToProviderMap(HealthcareProvider provider) {
        return Map.of(
            "id", provider.getMedicalLicenseNumber(), // Using license number as ID
            "name", provider.getFullName(),
            "title", formatProviderTitle(provider),
            "specialization", provider.getSpecialization() != null ? provider.getSpecialization() : "",
            "hospital", provider.getInstitution(),
            "experience", provider.getYearsOfExperience() != null ? provider.getYearsOfExperience() + " years" : "",
            "contactNumber", provider.getPhoneNumber()
        );
    }
    
    // Format provider title
    private String formatProviderTitle(HealthcareProvider provider) {
        String title = "";
        if (provider.getProviderType() == ProviderType.DOCTOR) {
            title = "Dr. ";
        } else if (provider.getProviderType() == ProviderType.MIDWIFE) {
            title = "Mrs./Ms. ";
        }
        return title + provider.getFullName();
    }
    
    // Find provider by medical license number
    public Optional<HealthcareProvider> findByLicenseNumber(String licenseNumber) {
        return healthcareProviderRepository.findByMedicalLicenseNumber(licenseNumber);
    }
    
    // Find provider by email
    public Optional<HealthcareProvider> findByEmail(String email) {
        return healthcareProviderRepository.findByEmail(email);
    }
    
    // Get provider by ID for appointment display
    public HealthcareProvider getProviderById(String providerId) {
        // First try to find by medical license number (which we use as ID)
        Optional<HealthcareProvider> provider = healthcareProviderRepository.findByMedicalLicenseNumber(providerId);
        
        if (provider.isPresent()) {
            return provider.get();
        }
        
        // If not found, try to find by name for backward compatibility
        List<HealthcareProvider> allProviders = healthcareProviderRepository.findByIsApprovedTrueAndIsActiveTrue();
        return allProviders.stream()
                .filter(p -> p.getFullName().equals(providerId))
                .findFirst()
                .orElse(null);
    }
    
    // Get provider display name by ID
    public String getProviderNameById(String providerId) {
        HealthcareProvider provider = getProviderById(providerId);
        return provider != null ? provider.getFullName() : providerId;
    }
    
    // Save or update provider
    public HealthcareProvider saveProvider(HealthcareProvider provider) {
        return healthcareProviderRepository.save(provider);
    }
    
    // Delete provider
    public void deleteProvider(Long providerId) {
        healthcareProviderRepository.deleteById(providerId);
    }
    
    // Check if provider exists by license number
    public boolean existsByLicenseNumber(String licenseNumber) {
        return healthcareProviderRepository.findByMedicalLicenseNumber(licenseNumber).isPresent();
    }
    
    // Check if provider exists by email
    public boolean existsByEmail(String email) {
        return healthcareProviderRepository.findByEmail(email).isPresent();
    }
}