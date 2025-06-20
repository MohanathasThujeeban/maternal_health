package com.example.maternalcare.controller;

import com.example.maternalcare.dto.RegistrationRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.RegistrationRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/registration")
public class RegistrationController {
    private final RegistrationRepository repository;

    public RegistrationController(RegistrationRepository repository) {
        this.repository = repository;
    }

    @PostMapping
    public Registration register(@RequestBody RegistrationRequest request) {
        Registration reg = new Registration();
        // Copy all fields from request to reg
        reg.setMotherFullName(request.getMotherFullName());
        reg.setFatherFullName(request.getFatherFullName());
        reg.setAddress(request.getAddress());
        reg.setPhoneNumber(request.getPhoneNumber());
        reg.setAge(request.getAge());
        reg.setOccupation(request.getOccupation());
        reg.setEthnicity(request.getEthnicity());
        reg.setReligion(request.getReligion());
        reg.setEducationLevel(request.getEducationLevel());

        reg.setGravida(request.getGravida());
        reg.setPara(request.getPara());
        reg.setLmp(request.getLmp());
        reg.setEdd(request.getEdd());
        reg.setPreviousPregnancies(request.getPreviousPregnancies());
        reg.setYear(request.getYear());
        reg.setDuration(request.getDuration());
        reg.setModeOfDelivery(request.getModeOfDelivery());
        reg.setBirthWeight(request.getBirthWeight());
        reg.setSex(request.getSex());
        reg.setStatus(request.getStatus());

        // Add more fields as needed

        return repository.save(reg);
    }
}