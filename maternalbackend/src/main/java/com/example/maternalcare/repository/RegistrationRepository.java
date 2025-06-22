package com.example.maternalcare.repository;

import java.util.Optional;
import com.example.maternalcare.model.Registration;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RegistrationRepository extends JpaRepository<Registration, Long> {
    Optional<Registration> findByEmail(String email);
}