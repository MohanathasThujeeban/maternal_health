package com.example.maternalcare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

@SpringBootApplication
@EntityScan(basePackages = {
    "com.example.maternalcare.model"      // All entities
})
public class MaternalhealthApplication {

    public static void main(String[] args) {
        SpringApplication.run(MaternalhealthApplication.class, args);
    }

}
