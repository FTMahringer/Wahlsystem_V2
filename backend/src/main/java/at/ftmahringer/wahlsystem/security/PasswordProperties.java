package at.ftmahringer.wahlsystem.security;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Password hashing configuration.
 *
 * Algorithm choices:
 *   bcrypt  – Battle-tested, fast on CPUs. Default.
 *   argon2  – Memory-hard, winner of the Password Hashing Competition. Recommended for new setups.
 *   scrypt  – Memory-hard, requires BouncyCastle on the classpath.
 *
 * Salt:  BCrypt / Argon2 / SCrypt all generate and embed a cryptographic salt
 *        per-password automatically — you do not need to manage salts manually.
 *
 * Pepper: A server-side secret applied via HMAC-SHA256 before hashing.
 *         Even if the database is leaked, the attacker cannot crack passwords
 *         without also obtaining the pepper. Store it in an environment variable,
 *         never in source code or the database.
 *
 *         IMPORTANT: Changing the pepper or the algorithm invalidates all existing
 *         password hashes — all users must reset their passwords.
 *
 * Config example (application.yml):
 *   app.security.password:
 *     algorithm: bcrypt
 *     pepper: ${PASSWORD_PEPPER:}
 *     bcrypt:
 *       strength: 12
 */
@Configuration
@ConfigurationProperties(prefix = "app.security.password")
@Getter
@Setter
public class PasswordProperties {

    /** Hashing algorithm: bcrypt | argon2 | scrypt */
    private String algorithm = "bcrypt";

    /**
     * Server-side pepper (HMAC-SHA256 key).
     * Leave empty to disable pepper (not recommended for production).
     */
    private String pepper = "";

    private Bcrypt bcrypt = new Bcrypt();
    private Argon2 argon2 = new Argon2();
    private Scrypt scrypt = new Scrypt();

    @Getter
    @Setter
    public static class Bcrypt {
        /** BCrypt cost factor (4–31). Each +1 doubles hashing time. Default: 12 */
        private int strength = 12;
    }

    @Getter
    @Setter
    public static class Argon2 {
        /** Salt length in bytes. Default: 16 */
        private int saltLength = 16;
        /** Output hash length in bytes. Default: 32 */
        private int hashLength = 32;
        /** Degree of parallelism. Default: 1 */
        private int parallelism = 1;
        /** Memory usage in KB. Default: 65536 (64 MB) */
        private int memory = 65536;
        /** Number of iterations. Default: 3 */
        private int iterations = 3;
    }

    @Getter
    @Setter
    public static class Scrypt {
        /** CPU/memory cost (must be a power of 2). Default: 65536 */
        private int cpuCost = 65536;
        /** Block size. Default: 8 */
        private int memoryCost = 8;
        /** Parallelisation parameter. Default: 1 */
        private int parallelism = 1;
        /** Output key length in bytes. Default: 32 */
        private int keyLength = 32;
        /** Salt length in bytes. Default: 16 */
        private int saltLength = 16;
    }
}
