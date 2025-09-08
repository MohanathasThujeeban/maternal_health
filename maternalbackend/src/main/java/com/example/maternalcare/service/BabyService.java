package com.example.maternalcare.service;

import com.example.maternalcare.dto.BabyRequest;
import com.example.maternalcare.dto.BabyResponse;
import com.example.maternalcare.model.Baby;
import com.example.maternalcare.model.MaternalProfile;
import com.example.maternalcare.repository.BabyRepository;
import com.example.maternalcare.repository.MaternalProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class BabyService {
    
    @Autowired
    private BabyRepository babyRepository;
    
    @Autowired
    private MaternalProfileRepository maternalProfileRepository;
    
    /**
     * Create a new baby for a mother
     */
    public BabyResponse createBaby(BabyRequest request) {
        System.out.println("=== BABY SERVICE: CREATE BABY ===");
        System.out.println("Looking for mother with NIC: " + request.getMotherNic());
        
        // Validate that the mother exists in maternal profiles
        Optional<MaternalProfile> motherOpt = maternalProfileRepository.findByMotherNic(request.getMotherNic());
        if (motherOpt.isEmpty()) {
            System.err.println("ERROR: Mother not found with NIC: " + request.getMotherNic());
            throw new RuntimeException("Mother not found with NIC: " + request.getMotherNic());
        }
        
        System.out.println("Mother found: " + motherOpt.get().getMotherNic());
        
        // Check if baby name already exists for this mother
        if (babyRepository.existsByMotherNicAndBabyNameExcludingId(request.getMotherNic(), request.getBabyName(), null)) {
            System.err.println("ERROR: Baby name already exists: " + request.getBabyName());
            throw new RuntimeException("A baby with name '" + request.getBabyName() + "' already exists for this mother");
        }
        
        // Get the next baby order
        Integer nextOrder = babyRepository.getNextBabyOrder(request.getMotherNic());
        System.out.println("Next baby order: " + nextOrder);
        
        // Create the baby
        Baby baby = new Baby(
            request.getMotherNic(),
            request.getBabyName(),
            request.getBirthDate(),
            request.getGender(),
            request.getBirthWeight(),
            request.getBirthHeight(),
            nextOrder
        );
        
        System.out.println("Saving baby to database...");
        Baby savedBaby = babyRepository.save(baby);
        System.out.println("Baby saved with ID: " + savedBaby.getId());
        
        BabyResponse response = convertToResponse(savedBaby);
        System.out.println("=== BABY SERVICE: CREATE BABY COMPLETE ===");
        return response;
    }
    
    /**
     * Get all babies for a mother
     */
    public List<BabyResponse> getBabiesByMotherNic(String motherNic) {
        List<Baby> babies = babyRepository.findByMotherNicAndIsActiveTrueOrderByBabyOrder(motherNic);
        return babies.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    /**
     * Get a specific baby by ID
     */
    public Optional<BabyResponse> getBabyById(Long id) {
        Optional<Baby> baby = babyRepository.findById(id);
        return baby.map(this::convertToResponse);
    }
    
    /**
     * Get a specific baby by mother NIC and baby order
     */
    public Optional<BabyResponse> getBabyByMotherNicAndOrder(String motherNic, Integer babyOrder) {
        Optional<Baby> baby = babyRepository.findByMotherNicAndBabyOrderAndIsActiveTrue(motherNic, babyOrder);
        return baby.map(this::convertToResponse);
    }
    
    /**
     * Get a specific baby by mother NIC and baby name
     */
    public Optional<BabyResponse> getBabyByMotherNicAndName(String motherNic, String babyName) {
        Optional<Baby> baby = babyRepository.findByMotherNicAndBabyNameAndIsActiveTrue(motherNic, babyName);
        return baby.map(this::convertToResponse);
    }
    
    /**
     * Update baby information
     */
    public BabyResponse updateBaby(Long id, BabyRequest request) {
        Optional<Baby> babyOpt = babyRepository.findById(id);
        if (babyOpt.isEmpty()) {
            throw new RuntimeException("Baby not found with ID: " + id);
        }
        
        Baby baby = babyOpt.get();
        
        // Validate that the mother NIC matches (security check)
        if (!baby.getMotherNic().equals(request.getMotherNic())) {
            throw new RuntimeException("Baby does not belong to the specified mother");
        }
        
        // Check if the new baby name conflicts with existing babies (excluding current baby)
        if (!baby.getBabyName().equals(request.getBabyName()) && 
            babyRepository.existsByMotherNicAndBabyNameExcludingId(request.getMotherNic(), request.getBabyName(), id)) {
            throw new RuntimeException("A baby with name '" + request.getBabyName() + "' already exists for this mother");
        }
        
        // Update the baby
        baby.setBabyName(request.getBabyName());
        baby.setBirthDate(request.getBirthDate());
        baby.setGender(request.getGender());
        baby.setBirthWeight(request.getBirthWeight());
        baby.setBirthHeight(request.getBirthHeight());
        
        Baby updatedBaby = babyRepository.save(baby);
        return convertToResponse(updatedBaby);
    }
    
    /**
     * Soft delete a baby (set isActive to false)
     */
    public void deleteBaby(Long id, String motherNic) {
        Optional<Baby> babyOpt = babyRepository.findByIdAndMotherNic(id, motherNic);
        if (babyOpt.isEmpty()) {
            throw new RuntimeException("Baby not found or does not belong to the specified mother");
        }
        
        Baby baby = babyOpt.get();
        baby.setIsActive(false);
        babyRepository.save(baby);
    }
    
    /**
     * Get count of babies for a mother
     */
    public Long getBabyCount(String motherNic) {
        return babyRepository.countActiveBabiesByMotherNic(motherNic);
    }
    
    /**
     * Convert Baby entity to BabyResponse DTO
     */
    private BabyResponse convertToResponse(Baby baby) {
        // Get mother's name from maternal profile
        String motherName = "Unknown";
        Optional<MaternalProfile> motherOpt = maternalProfileRepository.findByMotherNic(baby.getMotherNic());
        if (motherOpt.isPresent()) {
            // Assuming MaternalProfile has a method to get the full name
            // You might need to adjust this based on the actual field name
            motherName = motherOpt.get().getMotherNic(); // Placeholder - update with actual name field
        }
        
        return new BabyResponse(
            baby.getId(),
            baby.getMotherNic(),
            motherName,
            baby.getBabyName(),
            baby.getBirthDate(),
            baby.getGender(),
            baby.getBirthWeight(),
            baby.getBirthHeight(),
            baby.getBabyOrder(),
            baby.getIsActive(),
            baby.getCreatedAt(),
            baby.getUpdatedAt()
        );
    }
}
