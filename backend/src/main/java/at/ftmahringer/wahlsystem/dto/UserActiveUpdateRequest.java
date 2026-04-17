package at.ftmahringer.wahlsystem.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UserActiveUpdateRequest {

    @NotNull
    private Boolean active;
}
