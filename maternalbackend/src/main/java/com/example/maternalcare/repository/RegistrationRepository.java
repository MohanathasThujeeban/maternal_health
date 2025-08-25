package com.example.maternalcare.repository;

import java.util.List;
import java.util.Optional;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RegistrationRepository extends JpaRepository<Registration, Long> {
    Optional<Registration> findByEmail(String email);
    Optional<Registration> findByNicNumber(String nicNumber);
    Optional<Registration> findByMedicalLicenseNumber(String medicalLicenseNumber);
    List<Registration> findByNicNumberContainingOrFullNameContainingIgnoreCase(String nicNumber, String fullName);
    List<Registration> findByUserRole(UserRole userRole);
}