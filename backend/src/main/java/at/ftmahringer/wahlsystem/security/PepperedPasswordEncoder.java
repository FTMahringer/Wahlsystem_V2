package at.ftmahringer.wahlsystem.security;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * A {@link PasswordEncoder} decorator that applies a server-side pepper via
 * HMAC-SHA256 before delegating to the underlying hashing algorithm.
 *
 * Flow:
 *   encode:  rawPassword → HMAC-SHA256(password, pepper) → base64 → delegate.encode()
 *   matches: rawPassword → HMAC-SHA256(password, pepper) → base64 → delegate.matches()
 *
 * When pepper is blank the raw password is passed through unchanged, so this
 * wrapper is safe to use even without a configured pepper.
 */
public class PepperedPasswordEncoder implements PasswordEncoder {

    private final PasswordEncoder delegate;
    private final String pepper;

    public PepperedPasswordEncoder(PasswordEncoder delegate, String pepper) {
        this.delegate = delegate;
        this.pepper = pepper;
    }

    @Override
    public String encode(CharSequence rawPassword) {
        return delegate.encode(peppered(rawPassword));
    }

    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        return delegate.matches(peppered(rawPassword), encodedPassword);
    }

    @Override
    public boolean upgradeEncoding(String encodedPassword) {
        return delegate.upgradeEncoding(encodedPassword);
    }

    /**
     * Applies the pepper by computing HMAC-SHA256(password, pepper) and
     * returning the result as a Base64 string.
     * If no pepper is configured the original password is returned as-is.
     */
    private String peppered(CharSequence rawPassword) {
        if (pepper == null || pepper.isBlank()) {
            return rawPassword.toString();
        }
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(
                pepper.getBytes(StandardCharsets.UTF_8), "HmacSHA256"
            ));
            byte[] hmac = mac.doFinal(
                rawPassword.toString().getBytes(StandardCharsets.UTF_8)
            );
            return Base64.getEncoder().encodeToString(hmac);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to apply password pepper", e);
        }
    }
}
