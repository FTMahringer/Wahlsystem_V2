package at.ftmahringer.wahlsystem.security;

import java.util.Arrays;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.crypto.scrypt.SCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final UserDetailsServiceImpl userDetailsService;
    private final PasswordProperties passwordProperties;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http)
        throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authenticationProvider(authenticationProvider())
            .addFilterBefore(
                jwtAuthenticationFilter,
                UsernamePasswordAuthenticationFilter.class
            )
            .authorizeHttpRequests(auth ->
                auth
                    // Public endpoints
                    .requestMatchers("/api/v1/auth/**")
                    .permitAll()
                    .requestMatchers(
                        "/swagger-ui/**",
                        "/api-docs/**",
                        "/swagger-ui.html"
                    )
                    .permitAll()
                    .requestMatchers("/actuator/health")
                    .permitAll()
                    // Public election endpoints (read-only)
                    .requestMatchers(HttpMethod.GET, "/api/v1/elections/**")
                    .permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/v1/candidates/**")
                    .permitAll()
                    // School classes read-only for authenticated users
                    .requestMatchers(
                        HttpMethod.GET,
                        "/api/v1/school-classes/**"
                    )
                    .authenticated()
                    // Student token endpoints
                    .requestMatchers("/api/v1/student/**")
                    .hasRole("STUDENT")
                    // Teacher token distribution endpoints
                    .requestMatchers("/api/v1/teacher/**")
                    .hasAnyRole("TEACHER", "ADMIN")
                    // Admin endpoints
                    .requestMatchers("/api/v1/admin/**")
                    .hasAnyRole("ADMIN", "TEACHER")
                    .requestMatchers("/api/v1/users/**")
                    .hasRole("ADMIN")
                    // Voting endpoints use election tokens instead of a user session
                    .requestMatchers(HttpMethod.POST, "/api/v1/votes/**")
                    .permitAll()
                    // All other requests need authentication
                    .anyRequest()
                    .authenticated()
            );

        return http.build();
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider(
            userDetailsService
        );
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(
        AuthenticationConfiguration config
    ) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        PasswordEncoder base = switch (
            passwordProperties.getAlgorithm().toLowerCase()
        ) {
            case "argon2" -> {
                PasswordProperties.Argon2 c = passwordProperties.getArgon2();
                yield new Argon2PasswordEncoder(
                    c.getSaltLength(),
                    c.getHashLength(),
                    c.getParallelism(),
                    c.getMemory(),
                    c.getIterations()
                );
            }
            case "scrypt" -> {
                PasswordProperties.Scrypt c = passwordProperties.getScrypt();
                yield new SCryptPasswordEncoder(
                    c.getCpuCost(),
                    c.getMemoryCost(),
                    c.getParallelism(),
                    c.getKeyLength(),
                    c.getSaltLength()
                );
            }
            default -> new BCryptPasswordEncoder(
                passwordProperties.getBcrypt().getStrength()
            );
        };
        return new PepperedPasswordEncoder(
            base,
            passwordProperties.getPepper()
        );
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("*"));
        configuration.setAllowedMethods(
            Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS")
        );
        configuration.setAllowedHeaders(
            Arrays.asList("Authorization", "Content-Type", "X-Requested-With")
        );
        configuration.setExposedHeaders(List.of("Authorization"));
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source =
            new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
