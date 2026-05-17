package com.id3.config;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Simple per-IP token-bucket rate limiter using Bucket4j.
 * Limits each client IP to 60 requests per minute.
 */
@Component
@Slf4j
public class RateLimitingFilter extends OncePerRequestFilter {

    private static final int REQUESTS_PER_MINUTE = 60;
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    private Bucket resolveBucket(String clientIp) {
        return buckets.computeIfAbsent(clientIp, ip ->
                Bucket.builder()
                        .addLimit(Bandwidth.builder()
                                .capacity(REQUESTS_PER_MINUTE)
                                .refillGreedy(REQUESTS_PER_MINUTE, Duration.ofMinutes(1))
                                .build())
                        .build()
        );
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String clientIp = getClientIp(request);
        Bucket bucket = resolveBucket(clientIp);

        if (bucket.tryConsume(1)) {
            filterChain.doFilter(request, response);
        } else {
            log.warn("Rate limit exceeded for IP: {}", clientIp);
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Too many requests. Please wait before retrying.\"}");
        }
    }

    private String getClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
