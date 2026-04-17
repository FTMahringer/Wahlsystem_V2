package at.ftmahringer.wahlsystem.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TokenLoginRequest {

    @NotBlank
    private String token;
}
