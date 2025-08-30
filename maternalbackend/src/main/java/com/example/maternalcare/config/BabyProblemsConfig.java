
package com.example.maternalcare.config;

import com.example.maternalcare.model.ProblemRecord;
import com.example.maternalcare.repository.ProblemRecordRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDate;

@Configuration
public class BabyProblemsConfig {
    
    @Bean
    public CommandLineRunner initBabyProblemsData(ProblemRecordRepository repository) {
        return args -> {
            // Add sample data if database is empty
            if (repository.count() == 0) {
                ProblemRecord record1 = new ProblemRecord(
                    "Baby Perera",
                    "123456789V", // motherNic
                    "Blocked Tear Duct",
                    "None",
                    "1-2 weeks",
                    "Excessive tearing in left eye. Gentle massage recommended.",
                    LocalDate.now().minusDays(6)
                );
                
                ProblemRecord record2 = new ProblemRecord(
                    "Baby Silva",
                    "987654321V", // motherNic
                    "None",
                    "Ear Infection",
                    "3-7 days",
                    "Fussy, pulling at ear. Prescribed antibiotic drops.",
                    LocalDate.now().minusDays(4)
                );
                
                ProblemRecord record3 = new ProblemRecord(
                    "Baby Fernando",
                    "456789123V", // motherNic
                    "Conjunctivitis (Pink Eye)",
                    "Ear Pain/Fussiness",
                    "Less than 1 day",
                    "Both eye and ear issues observed during checkup.",
                    LocalDate.now().minusDays(1)
                );
                
                repository.save(record1);
                repository.save(record2);
                repository.save(record3);
                
                System.out.println("Baby Problems sample data initialized!");
            }
        };
    }
}
