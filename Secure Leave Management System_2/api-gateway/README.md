# API Gateway

Central entry point for all client requests. Handles JWT authentication, routing to downstream microservices, CORS, and rate limiting.

## Port

`8080`

## Responsibilities

- Route requests to all backend services using Spring Cloud Gateway MVC
- Validate JWT tokens on every incoming request via `JwtAuthenticationFilter`
- Enforce per-IP rate limiting: **60 requests/minute** using Bucket4j token-bucket
- Forward authenticated user identity downstream via request headers
- Provide CORS policy for browser clients

## Gateway Routes

| Route ID | Path Pattern | Upstream Service |
|---|---|---|
| `personnel-info-service` | `/personnel-info/**` | personnel-info-service |
| `mail-service` | `/mail/**` | mail-service |
| `leave-tracking-service` | `/leave-tracking/**` | leave-tracking-service |
| `leave-request-service` | `/leave-request/**` | leave-request-service |
| `discovery-server` | `/eureka/web` | Eureka Dashboard (direct) |
| `discovery-server-static` | `/eureka/**` | Eureka static assets (direct) |
| `ui-service` | `/ui/**` | ui-service |

## Security Flow

```
Request
  |
  v
RateLimitingFilter  -->  429 Too Many Requests (if > 60 req/min from this IP)
  |
  v
JwtAuthenticationFilter  -->  401 Unauthorized (if token missing/invalid/expired)
  |
  v
Spring Security URL rules  -->  403 Forbidden (if role insufficient)
  |
  v
Gateway routes to upstream service
```

## Key Dependencies

| Dependency | Purpose |
|---|---|
| Spring Cloud Gateway MVC | Servlet-based route configuration and filter chain |
| Spring Security | JWT filter, security context, method security |
| jjwt 0.12.3 | JWT parsing and validation (HS256) |
| Bucket4j 8.10.1 | In-memory per-IP rate limiting |
| Netflix Eureka Client | Load-balanced routing via `lb://service-name` URIs |
| Spring Boot Actuator + Micrometer | Health, metrics, Prometheus endpoints |
| Bean Validation | Input validation on `AuthenticationRequest` DTO |

## Configuration

`src/main/resources/application.properties` — routes, CORS origins, Eureka URL, Actuator exposure.

`src/main/resources/application-docker.properties` — Docker-specific datasource config using env var substitution (`${DB_USER}`, `${DB_PASSWORD}`).

## Actuator Endpoints

| Endpoint | Auth Required | Description |
|---|---|---|
| `/actuator/health` | No | Service health status |
| `/actuator/info` | No | Build info |
| `/actuator/prometheus` | Yes | Prometheus metrics scrape target |

## Running Locally

```powershell
Set-Location api-gateway
mvn spring-boot:run
```

Requires the Discovery Server to be running first. Access at `http://localhost:8080`.
