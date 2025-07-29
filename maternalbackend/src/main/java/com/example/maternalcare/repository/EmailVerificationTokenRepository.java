package com.example.maternalcare.repository;

import com.example.maternalcare.model.EmailVerificationToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

public interface EmailVerificationTokenRepository extends JpaRepository<EmailVerificationToken, Long> {
    Optional<EmailVerificationToken> findByToken(String token);
    Optional<EmailVerificationToken> findByEmail(String email);
    boolean existsByEmailAndVerified(String email, boolean verified);
    
    @Modifying
    @Transactional
    @Query("DELETE FROM EmailVerificationToken e WHERE e.email = :email")
    void deleteByEmail(String email);
    
    @Modifying
    @Transactional
    @Query("DELETE FROM EmailVerificationToken e WHERE e.expiryDate < :now")
    void deleteExpiredTokens(LocalDateTime now);
}