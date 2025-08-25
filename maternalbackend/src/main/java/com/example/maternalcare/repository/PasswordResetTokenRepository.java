package com.example.maternalcare.repository;

import com.example.maternalcare.model.PasswordResetToken;
import com.example.maternalcare.model.Registration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {
    
    Optional<PasswordResetToken> findByToken(String token);
    
    Optional<PasswordResetToken> findByTokenAndUsedFalse(String token);
    
    void deleteByUser(Registration user);
    
    // For healthcare provider password reset
    void deleteByProviderEmail(String providerEmail);
    
    Optional<PasswordResetToken> findByTokenAndProviderTypeAndUsedFalse(String token, String providerType);
    
    @Modifying
    @Query("DELETE FROM PasswordResetToken t WHERE t.expiryDate < :now")
    void deleteExpiredTokens(@Param("now") LocalDateTime now);
    
    @Query("SELECT t FROM PasswordResetToken t WHERE t.user = :user AND t.used = false AND t.expiryDate > :now")
    Optional<PasswordResetToken> findValidTokenByUser(@Param("user") Registration user, @Param("now") LocalDateTime now);
    
    @Query("SELECT t FROM PasswordResetToken t WHERE t.providerEmail = :email AND t.providerType = 'HEALTHCARE_PROVIDER' AND t.used = false AND t.expiryDate > :now")
    Optional<PasswordResetToken> findValidTokenByProviderEmail(@Param("email") String email, @Param("now") LocalDateTime now);
}
