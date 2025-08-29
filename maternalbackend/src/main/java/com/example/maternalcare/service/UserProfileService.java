package com.example.maternalcare.service;

import com.example.maternalcare.dto.ProfileUpdateRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.RegistrationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserProfileService {

    @Autowired
    private RegistrationRepository registrationRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public Registration getUserByNic(String nicNumber) {
        Optional<Registration> user = registrationRepository.findByNicNumber(nicNumber);
        return user.orElse(null);
    }

    public Registration updateUserProfile(String nicNumber, ProfileUpdateRequest request) {
        Optional<Registration> userOptional = registrationRepository.findByNicNumber(nicNumber);
        
        if (userOptional.isEmpty()) {
            return null;
        }
        
        Registration user = userOptional.get();
        
        // Update basic information
        user.setFullName(request.getFullName());
        user.setPhoneNumber3(request.getPhoneNumber());
        user.setEmail(request.getEmail());
        
        // Update password if provided
        if (request.getNewPassword() != null && !request.getNewPassword().trim().isEmpty()) {
            String encodedPassword = passwordEncoder.encode(request.getNewPassword());
            user.setPassword(encodedPassword);
        }
        
        // Save updated user
        return registrationRepository.save(user);
    }
    
    public boolean isEmailTaken(String email, String currentNic) {
        Optional<Registration> existingUser = registrationRepository.findByEmail(email);
        if (existingUser.isPresent()) {
            // Check if it's the same user
            return !existingUser.get().getNicNumber().equals(currentNic);
        }
        return false;
    }
}
