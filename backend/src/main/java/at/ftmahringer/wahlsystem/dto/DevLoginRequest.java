package at.ftmahringer.wahlsystem.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DevLoginRequest {

    @NotBlank(message = "Username is required")
    private String username;
}
