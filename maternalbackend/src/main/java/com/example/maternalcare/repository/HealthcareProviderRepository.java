package com.example.maternalcare.repository;

import com.example.maternalcare.model.HealthcareProvider;
import com.example.maternalcare.model.ProviderType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface HealthcareProviderRepository extends JpaRepository<HealthcareProvider, Long> {
    
    // Find by medical license number (primary login method)
    Optional<HealthcareProvider> findByMedicalLicenseNumber(String medicalLicenseNumber);
    
    // Find by email
    Optional<HealthcareProvider> findByEmail(String email);
    
    // Find by NIC number
    Optional<HealthcareProvider> findByNicNumber(String nicNumber);
    
    // Find by provider type
    List<HealthcareProvider> findByProviderType(ProviderType providerType);
    
    // Find approved providers
    List<HealthcareProvider> findByIsApprovedTrueAndIsActiveTrue();
    
    // Find pending approval providers
    List<HealthcareProvider> findByIsApprovedFalseAndIsActiveTrue();
    
    // Find by institution
    List<HealthcareProvider> findByInstitution(String institution);
    
    // Find email verified providers
    List<HealthcareProvider> findByIsEmailVerifiedTrue();
    
    // Custom query to find providers by specialization
    @Query("SELECT hp FROM HealthcareProvider hp WHERE hp.specialization LIKE %:specialization% AND hp.isApproved = true AND hp.isActive = true")
    List<HealthcareProvider> findBySpecializationContaining(@Param("specialization") String specialization);
    
    // Count providers by type
    @Query("SELECT COUNT(hp) FROM HealthcareProvider hp WHERE hp.providerType = :providerType AND hp.isApproved = true AND hp.isActive = true")
    Long countByProviderType(@Param("providerType") ProviderType providerType);
    
    // Find providers needing license renewal (expiring soon)
    @Query("SELECT hp FROM HealthcareProvider hp WHERE hp.licenseExpiryDate <= :expiryDate AND hp.isActive = true")
    List<HealthcareProvider> findProvidersWithExpiringLicenses(@Param("expiryDate") java.time.LocalDateTime expiryDate);
}
