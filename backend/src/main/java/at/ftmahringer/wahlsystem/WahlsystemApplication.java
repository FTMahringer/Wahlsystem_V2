package at.ftmahringer.wahlsystem;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class WahlsystemApplication {

    public static void main(String[] args) {
        SpringApplication.run(WahlsystemApplication.class, args);
    }

}
