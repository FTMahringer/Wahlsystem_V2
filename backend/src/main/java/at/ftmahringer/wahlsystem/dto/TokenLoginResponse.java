package at.ftmahringer.wahlsystem.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TokenLoginResponse {

    private String token;
    private Long electionId;
}
