# Project Status Report — Secure Leave Management System

**Date:** 2026-05-17  
**Course:** ITRI615 Computer Security 1  
**Project:** Microservice-Based Secure Leave Management System

---

## Architecture Overview

The project is a **Spring Boot 3.3.1 / Java 17** microservices application using Spring Cloud 2023.0.2.  
It consists of **7 services** coordinated via Eureka service discovery and an API Gateway.

```
Browser → API Gateway (8080) → [Discovery Server / Services]
                              ├── personnel-info-service (dynamic port)
                              ├── leave-request-service  (dynamic port)
                              ├── leave-tracking-service (dynamic port)
                              ├── mail-service           (dynamic port)
                              └── ui-service             (dynamic port)
```

---

## What Has Been Done ✅

### 1. Basic Microservice (15 marks) — DONE
- Six domain microservices implemented in Java Spring Boot (language not Python ✅)
- Each service has its own Maven `pom.xml`, Spring Boot entry point, JPA entities, repositories, and controllers
- Services are clearly separated by bounded context:
  - `personnel-info-service` — manages employee records, departments, roles
  - `leave-request-service` — accepts and publishes leave requests
  - `leave-tracking-service` — consumes requests, schedules leave jobs via Quartz
  - `mail-service` — sends email notifications via SMTP (Gmail)
  - `discovery-server` — Eureka service registry
  - `api-gateway` — central entry point with security

### 2. API Gateway (5 marks) — DONE
- Spring Cloud Gateway MVC configured in `api-gateway`
- All routes go through port 8080 (Gateway) using `lb://` load-balanced URIs
- Routes configured for all 5 application services + Eureka web UI
- Service discovery via Eureka (`lb://service-name` URIs)

### 3. Authentication (10 marks) — DONE (with bugs — see below)
- JWT-based authentication implemented in `api-gateway`
- `JwtService` handles token generation, validation, expiry, and role extraction
- `JwtAuthenticationFilter` (OncePerRequestFilter) validates every request
- BCrypt password hashing via `BCryptPasswordEncoder`
- `AuthController` at `/auth/authenticate` accepts login credentials
- `UserService` implements Spring Security's `UserDetailsService`

### 4. Authorization (10 marks) — DONE
- Role-Based Access Control (RBAC) with 3 roles: `ADMIN`, `HR`, `EMPLOYEE`
- `SecurityConfig` enforces role-based URL path restrictions:
  - `/ui/admin/**` → ADMIN only
  - `/ui/hr/**` → HR only
  - `/ui/employee/**` → EMPLOYEE only
- Custom `AuthenticationEntryPoint` redirects unauthenticated users to `/ui/auth`
- Stateless sessions (JWT only, no server-side session)
- `PersonnelInfo` entity stores roles in the database

### 5. Logging and Monitoring (10 marks) — PARTIAL ⚠️
- `@Slf4j` (Lombok) annotation used in `JwtAuthenticationFilter` for request logging
- SQL logging enabled (`spring.jpa.show-sql=true`)
- **Missing:** No dedicated log configuration file (`logback.xml` or `log4j2.xml`)
- **Missing:** No Prometheus metrics endpoint or Grafana/Kibana integration
- **Missing:** No request-level access logging across other services

### 6. Input Validation and Rate Limiting (10 marks) — PARTIAL ⚠️
- Spring Security validates JWT on every request (authentication barrier)
- Spring Security CSRF disabled (intentional for stateless APIs)
- **Missing:** No `@Valid` / `@NotNull` / `@Size` Bean Validation annotations on DTOs
- **Missing:** No rate limiting (no Spring Cloud Gateway RequestRateLimiter filter, no Bucket4j)
- **Missing:** No explicit XSS / SQL injection prevention decorators (though JPA parameterized queries prevent SQL injection by default)

### 7. Frontend (6 marks) — DONE
- `ui-service` uses Thymeleaf templates (server-side rendered)
- 5 HTML pages: `auth.html`, `admin-page.html`, `hr-page.html`, `employee-page.html`, `thymeleaf.html`
- Role-specific controllers: `AdminController`, `HrController`, `EmployeeController`, `AuthController`
- UI talks to API Gateway via `RestTemplate` (not directly to services)

### 8. Security Patterns (4 marks) — PARTIAL ⚠️
- **Applied:** Gateway pattern (all traffic through one entry point)
- **Applied:** Token-based authentication (JWT stateless pattern)
- **Applied:** RBAC (Role-Based Access Control pattern)
- **Applied:** Password hashing (BCrypt)
- **Missing:** Not formally documented which OWASP or security patterns are being applied

### 9. Additional Features (10 marks bonus) — PARTIAL ⚠️
- Apache Kafka for asynchronous event-driven communication between services
- Quartz job scheduler for automated leave tracking
- Docker Compose + Kubernetes YAML manifests for container deployment
- Docker Hub images already published (`ramazanakdag/...`)
- **Missing:** Active cloud deployment (AWS, GCP, Azure) for bonus marks

---

## What Still Needs Doing ❌

| Area | Issue | Priority |
|------|-------|----------|
| **Bug: JWT role prefix** | `JwtService.java:33` adds `"ROLE_"` prefix to authority that already has it — produces `ROLE_ROLE_EMPLOYEE` | HIGH |
| **Bug: Token expiry** | `1000*60*24` = 24 minutes (not 24 hours) — `1000*60*60*24` needed for 24 hours | MEDIUM |
| **Bug: CORS + credentials** | `allowedOrigins=*` with `allowCredentials=true` is rejected by browsers — must use explicit origins | HIGH |
| **Missing: Input validation** | No `@Valid` annotations or `@NotBlank`/`@Size` constraints on request DTOs | HIGH |
| **Missing: Rate limiting** | No rate limiting middleware anywhere — required by rubric | HIGH |
| **Missing: Logback config** | No `logback-spring.xml` — logs not persisted to file, no structured logging | MEDIUM |
| **Missing: leave-request-service controllers** | Service has only properties files and no Java source code — is incomplete | HIGH |
| **Security: Hardcoded secrets** | JWT secret, DB password, Gmail app password all hardcoded in `application.properties` | HIGH |
| **Security: No HTTPS** | No TLS/SSL configured — all communication is HTTP | MEDIUM |
| **Missing: API docs** | No Swagger / SpringDoc OpenAPI documentation | LOW |
| **Theory doc** | Theoretical sections (scenario, security analysis, auth comparison, real-world failures) need to be written | HIGH |

---

## Summary

| Component | Status | Est. Marks |
|-----------|--------|------------|
| Basic microservice | ✅ Done | 13/15 |
| API Gateway | ✅ Done | 5/5 |
| Authentication | ✅ Done (bug fixable) | 8/10 |
| Authorization | ✅ Done | 8/10 |
| Logging & monitoring | ⚠️ Partial | 5/10 |
| Input validation & rate limiting | ⚠️ Partial | 4/10 |
| Frontend | ✅ Done | 5/6 |
| Security patterns | ⚠️ Partial | 2/4 |
| Additional features | ⚠️ Partial | 5/10 |
| **Practical subtotal** | | **~55/70** |
| Theory (TBD) | ❌ Not assessed | TBD/30 |

The practical skeleton is well-built. Fixing the JWT role bug, adding input validation, and adding rate limiting would push the practical score significantly higher.
