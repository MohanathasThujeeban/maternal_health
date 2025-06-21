package com.example.maternalcare.controller;

import org.springframework.web.bind.annotation.*;
import com.example.maternalcare.dto.RegistrationRequest;
import com.example.maternalcare.model.Registration;
import com.example.maternalcare.repository.RegistrationRepository;

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
        reg.setNicNumber(request.getNicNumber());
        reg.setPhoneNumber3(request.getPhoneNumber3());
        reg.setPassword(request.getPassword());
        return repository.save(reg);
    }
}