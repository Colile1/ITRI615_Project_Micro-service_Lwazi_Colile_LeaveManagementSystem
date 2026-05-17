# API Gateway

Central entry point for all client requests. Handles JWT authentication, request routing to downstream microservices, and rate limiting.

## Responsibilities

- Route requests to `personnel-info-service`, `leave-request-service`, `leave-tracking-service`, and `ui-service`
- Validate JWT tokens on every incoming request
- Enforce rate limiting: **60 requests/minute per IP** using Bucket4j token-bucket algorithm
- Propagate authenticated user identity (roles, subject) to downstream services via request headers

## Port

`8080`

## Key Dependencies

| Dependency | Purpose |
|---|---|
| Spring Cloud Gateway MVC | Route configuration and filter chain |
| Spring Security | JWT filter, security context |
| jjwt 0.12.3 | JWT parsing and validation |
| Bucket4j 8.10.1 | In-memory rate limiting |
| Netflix Eureka Client | Service discovery for routing |

## Configuration

`src/main/resources/application.yml` — routes, rate limit settings, JWT secret, Eureka URL.

## Security Flow

```
Request → RateLimitFilter → JwtAuthFilter → Route to service
                ↓                  ↓
         429 Too Many        401 Unauthorized
           Requests
```

## Running

```bash
mvn spring-boot:run
```

Requires the discovery server to be running first.
