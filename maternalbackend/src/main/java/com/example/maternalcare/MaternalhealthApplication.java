package com.example.maternalcare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

@SpringBootApplication
@EntityScan(basePackages = {
    "com.example.maternalhealth.model",   // GrowthEntry entity
    "com.example.maternalcare.model"      // Appointment entity
})
public class MaternalhealthApplication {

    public static void main(String[] args) {
        SpringApplication.run(MaternalhealthApplication.class, args);
    }

}
