package at.ftmahringer.wahlsystem.service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

/**
 * Tracks failed login attempts per username and temporarily blocks accounts
 * that exceed the allowed threshold (brute-force protection).
 *
 * Max 5 failed attempts within a rolling 15-minute window.
 * After the window expires, the counter resets automatically.
 */
@Service
@Slf4j
public class LoginAttemptService {

    private static final int MAX_ATTEMPTS = 5;
    private static final long LOCK_DURATION_MS = 15 * 60 * 1000L;

    private record Attempt(int count, long firstMs, long lastMs) {}

    private final Map<String, Attempt> attempts = new ConcurrentHashMap<>();

    public boolean isBlocked(String username) {
        Attempt a = attempts.get(key(username));
        if (a == null || a.count() < MAX_ATTEMPTS) return false;
        if (elapsed(a.lastMs()) >= LOCK_DURATION_MS) {
            attempts.remove(key(username));
            return false;
        }
        return true;
    }

    public long remainingLockSeconds(String username) {
        Attempt a = attempts.get(key(username));
        if (a == null || a.count() < MAX_ATTEMPTS) return 0;
        long remaining = LOCK_DURATION_MS - elapsed(a.lastMs());
        return remaining > 0 ? remaining / 1000 : 0;
    }

    public void loginFailed(String username) {
        long now = Instant.now().toEpochMilli();
        String k = key(username);
        attempts.merge(k, new Attempt(1, now, now), (old, fresh) -> {
            if (elapsed(old.lastMs()) >= LOCK_DURATION_MS) return fresh;
            return new Attempt(old.count() + 1, old.firstMs(), now);
        });
        Attempt current = attempts.get(k);
        if (current != null && current.count() >= MAX_ATTEMPTS) {
            log.warn("Login blocked for '{}' after {} failed attempts", username, MAX_ATTEMPTS);
        }
    }

    public void loginSucceeded(String username) {
        attempts.remove(key(username));
    }

    @Scheduled(fixedDelay = 30 * 60 * 1000L)
    public void cleanExpired() {
        attempts.entrySet().removeIf(e -> elapsed(e.getValue().lastMs()) >= LOCK_DURATION_MS);
    }

    private static String key(String username) {
        return username == null ? "" : username.toLowerCase();
    }

    private static long elapsed(long fromMs) {
        return Instant.now().toEpochMilli() - fromMs;
    }
}
