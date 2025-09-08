package com.example.maternalcare.service;

import com.example.maternalcare.model.MaternalProfile;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.model.UserRole;
import com.example.maternalcare.repository.MaternalProfileRepository;
import com.example.maternalcare.repository.RegistrationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
public class DataInitializationService implements CommandLineRunner {

    @Autowired
    private MaternalProfileRepository maternalProfileRepository;
    
    @Autowired
    private RegistrationRepository registrationRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        initializeSampleData();
    }

    private void initializeSampleData() {
        // Create sample maternal profile for the hardcoded NIC
        String sampleNic = "200201901851";
        
        // Check if maternal profile already exists
        if (!maternalProfileRepository.findByMotherNic(sampleNic).isPresent()) {
            System.out.println("Creating sample maternal profile for NIC: " + sampleNic);
            
            MaternalProfile profile = new MaternalProfile();
            profile.setMotherNic(sampleNic);
            profile.setAge(25);
            profile.setDateOfBirth(LocalDate.of(2002, 1, 19));
            profile.setCity("Colombo");
            profile.setDistrict("Colombo");
            profile.setProvince("Western");
            profile.setBloodType("O+");
            profile.setRhesusFactor("POSITIVE");
            profile.setProfileCompleted(true);
            profile.setCreatedAt(LocalDateTime.now());
            profile.setUpdatedAt(LocalDateTime.now());
            
            maternalProfileRepository.save(profile);
            System.out.println("Sample maternal profile created successfully!");
        } else {
            System.out.println("Maternal profile already exists for NIC: " + sampleNic);
        }
        
        // Also ensure registration exists for the email used in login
        String sampleEmail = "thujee44@gmail.com";
        if (!registrationRepository.findByEmail(sampleEmail).isPresent()) {
            System.out.println("Creating sample registration for email: " + sampleEmail);
            
            Registration registration = new Registration();
            registration.setEmail(sampleEmail);
            registration.setFullName("Thujeeban Sample User");
            registration.setNicNumber(sampleNic);
            registration.setPhoneNumber3("0712345678");
            registration.setPassword(passwordEncoder.encode("123456")); // Default password
            registration.setUserRole(UserRole.MOTHER);
            registration.setIsActive(true);
            registration.setCreatedAt(LocalDateTime.now());
            registration.setUpdatedAt(LocalDateTime.now());
            
            registrationRepository.save(registration);
            System.out.println("Sample registration created successfully!");
        } else {
            System.out.println("Registration already exists for email: " + sampleEmail);
        }
    }
}
