# CHANGELOG — Secure Leave Management System

## [2026-05-17] — README Accuracy Pass and Security Fix

### Security Fix
- **[mail-service] application.properties** — Replaced hardcoded Gmail credentials (`akdagramazan586@gmail.com` / app password) with Spring property substitution `${MAIL_USERNAME}` / `${MAIL_PASSWORD}`. Credentials must now be supplied via environment variable or `.env` file.

### README Updates (all files rewritten for accuracy)
- **[root] README.md** — Fixed architecture diagram ports (UI: 8086, personnel: 8084, leave-request: 8085, leave-tracking: 8083, mail: 8082). Fixed service table. Updated roles (`HR_MANAGER` -> `HR`). Updated quick-start to use `start-app.ps1` and `docker compose` (V2). Fixed MySQL count (3 databases, not 2).
- **[api-gateway] README.md** — Corrected config file reference (`application.properties` not `application.yml`). Added all 7 gateway routes with path patterns. Added Actuator endpoint table.
- **[ui-service] README.md** — Fixed port (8086). Fixed URL paths (`/ui/auth`, `/ui/employee/{userId}` etc.). Fixed template names. Corrected auth description (JWT HttpOnly cookie, not form-based session). Updated roles. Fixed access URL.
- **[personnel-info-service] README.md** — Fixed port (8084). Fixed database name (`personnel_info_db`). Removed incorrect H2 mention. Added validation constraint details.
- **[leave-request-service] README.md** — Fixed port (8085). Fixed Kafka topic (`leave-request-topic`). Fixed gateway route prefix. Updated Kafka message schema to match `LeaveRequestMessage` fields.
- **[leave-tracking-service] README.md** — Fixed Kafka topic (`leave-request-topic`). Added Quartz JDBC detail. Clarified dual-database setup (`quartz_demo` for JPA, `leave_tracking_db` for Quartz).
- **[mail-service] README.md** — Fixed port (8082). Replaced YAML snippet with properties format. Added Gmail App Password setup instructions.

### Script: start-app.ps1 Fixes
- Added Docker PATH injection (`C:\Program Files\Docker\Docker\resources\bin`) at script startup
- Changed `$ErrorActionPreference` to `Continue` to prevent docker progress output being treated as fatal errors
- Changed docker check to use `Get-Command docker` instead of try/catch exec
- Replaced Compose V1 `--no-pull` with V2 `--pull=never` / `--pull=missing`
- Removed `kafka-tools` from infrastructure startup (image not cached, not required for app)
- Removed obsolete `version: '3.8'` from `docker-compose.yml` (suppresses compose warning)
- Fixed `$Args` automatic variable warning -- renamed to `$DockerArgs`
- Verified: full end-to-end run succeeds -- all 11 containers start, health checks pass

## [2026-05-17] — Gap Closure Guide and Startup Script

### New Files (project root, not service source)
- **[root] GAP_CLOSURE_GUIDE.md** — Step-by-step guide to close the four remaining -1/-2 grading gaps: leave-request-service source scaffolding, Grafana dashboard setup, client-side UI validation, and cloud deployment (Railway / ngrok / Oracle Cloud).
- **[root] start-app.ps1** — Automated PowerShell startup script. Checks prerequisites, starts Docker Desktop if needed, validates disk space, collects required secrets interactively (MAIL_USERNAME, MAIL_PASSWORD, JWT_SECRET, DB_USER, DB_PASSWORD) with defaults and .env persistence, starts infrastructure containers, waits for MySQL/Kafka to initialise, starts all 7 application services, runs health checks, prints status table, and opens the browser. Supports `-SkipPull`, `-MonitoringStack`, and `-StopAll` flags.

## [2026-05-17] — README PowerShell Conversion

### Changed
- All code blocks in README files and `starter_guide.md` converted from `bash` to `powershell` syntax
- `cd` → `Set-Location`, `cp` → `Copy-Item`, `curl` → `Invoke-RestMethod` with proper PowerShell parameter syntax, backtick line continuation replacing backslash

## [2026-05-17] — Documentation and rules.md Compliance

### Security Fix
- **[README.md]** — Removed hardcoded default credentials (`admin/admin123`, `hr/hr123`, `emp/emp123`) from root README. Plain-text passwords in documentation violate the same principle as hardcoded credentials in source code. Replaced with guidance to use environment variables or `.env` files excluded from version control.

### Added
- Root `README.md` with architecture overview, service table, tech stack, security features, and quick-start guide
- `README.md` for all 7 microservices: `api-gateway`, `discovery-server`, `personnel-info-service`, `leave-request-service`, `leave-tracking-service`, `mail-service`, `ui-service`
- `todo.md` — task tracking (pending and completed), required by rules.md
- `log.md` — development journal with what/why/impact entries, required by rules.md
- `starter_guide.md` — setup, run, and test instructions for the full system, required by rules.md

## [2026-05-17] — Security Fixes and Enhancements

### Bug Fixes
- **[api-gateway] JwtService.java** — Fixed double `ROLE_` prefix bug.
  - `getAuthority()` already returns `"ROLE_EMPLOYEE"` etc.; code was prepending another `"ROLE_"` producing `"ROLE_ROLE_EMPLOYEE"`, breaking Spring Security role checks.
  - Changed `claims.put("role", "ROLE_" + role)` → `claims.put("role", role)`.

- **[api-gateway] JwtService.java** — Fixed token expiry: 24 minutes → 24 hours.
  - `1000*60*24` = 1,440,000 ms = 24 minutes. Changed to `1000L*60*60*24` = 86,400,000 ms = 24 hours.

- **[api-gateway] application.properties** — Fixed CORS configuration.
  - `allowedOrigins=*` combined with `allowCredentials=true` is rejected by all modern browsers (CORS spec violation). Changed to explicit allowed origins: `http://localhost:8080,http://localhost:8086`.

### New Features
- **[api-gateway] AuthenticationRequest.java** — Added Bean Validation annotations.
  - `@NotBlank` + `@Email` on `email` field.
  - `@NotBlank` + `@Size(min=6, max=100)` on `password` field.
  - Prevents empty/malformed login requests from reaching the authentication service.

- **[api-gateway] AuthController.java** — Added `@Valid` to trigger DTO validation.

- **[api-gateway] pom.xml** — Added `spring-boot-starter-validation` and `bucket4j-core` dependencies.

- **[api-gateway] RateLimitingFilter.java** — NEW FILE. Per-IP token-bucket rate limiter.
  - 60 requests per minute per client IP using Bucket4j.
  - Returns HTTP 429 with JSON error body when limit is exceeded.
  - Logs rate limit violations at WARN level.

- **[api-gateway] logback-spring.xml** — NEW FILE. Structured log configuration.
  - Console + rolling file appenders.
  - Logs rotated daily, max 30 days history, max 1 GB total size.
  - Security events (JWT filter, rate limiter, Spring Security) explicitly configured.

### Deprecation Fixes (Compiler Warnings Resolved)
- **[api-gateway] SecurityConfig.java** — Replaced deprecated `.csrf().disable()` with `.csrf(AbstractHttpConfigurer::disable)`.
  - Removed unused `jakarta.ws.rs.HttpMethod` import.

- **[api-gateway] JwtService.java** — Updated to jjwt 0.12.x API:
  - Removed deprecated `SignatureAlgorithm` import; `signWith(key)` now auto-selects HS256.
  - Replaced deprecated `Jwts.parser().setSigningKey().parseClaimsJws().getBody()` with `Jwts.parser().verifyWith().build().parseSignedClaims().getPayload()`.

- **[api-gateway] pom.xml** — Removed duplicate `mysql-connector-j` dependency declaration.

### Missing Files Created (Compilation Errors Fixed)
- **[personnel-info-service] UpdatePersonnelStatusRequest.java** — NEW FILE. Missing DTO needed by `IPersonnelInfoService` and `PersonnelInfoManager`.
- **[personnel-info-service] IPersonnelInfoRepository.java** — NEW FILE. JPA repository interface was missing entirely from source tree.
- **[personnel-info-service] PersonnelInfo.java** — Fixed invalid `@OneToMany(mappedBy="managerId")` on an Integer column (not a JPA relationship). Changed to `@Transient` to avoid Hibernate mapping error.
- **[leave-tracking-service] LeaveRequestMessage.java** — NEW FILE. Class was referenced as `com.id3.leaverequestservice.model.LeaveRequestMessage` but only existed in repo root with wrong package. Copied into correct package within leave-tracking-service.
- **[leave-tracking-service] AutoWiringSpringBeanJobFactory.java** — NEW FILE. Custom `SpringBeanJobFactory` subclass enabling `@Autowired` injection in Quartz Jobs. Referenced in `QuartzConfig` but missing from source.
- **[leave-tracking-service] pom.xml** — Removed duplicate `junit:junit` dependency declaration.

## [2026-05-17] — Grading Improvement Pass 1

### Critical Security Fix
- **[root] pom.xml** — Removed hardcoded Docker Hub password from Jib plugin `<auth>` block. Credentials were visible in plain text at line 58; moved to Maven `settings.xml` pattern (no password in source).

### Monitoring Enhancement
- **[api-gateway] pom.xml** — Added `spring-boot-starter-actuator` and `micrometer-registry-prometheus` dependencies.
- **[api-gateway] application.properties** — Exposed `/actuator/health`, `/actuator/info`, `/actuator/metrics`, `/actuator/prometheus` endpoints.
- **[api-gateway] SecurityConfig.java** — Permitted `/actuator/health` and `/actuator/info` without authentication.
- **[personnel-info-service] pom.xml** — Added `spring-boot-starter-actuator` and `spring-boot-starter-validation`.

### Authorization Enhancement
- **[api-gateway] SecurityConfig.java** — Added `@EnableMethodSecurity(prePostEnabled = true)` for method-level security support.

### Input Validation Enhancement
- **[personnel-info-service] CreatePersonnelRequest.java** — Added full Bean Validation constraints: `@NotBlank`, `@Email`, `@Size`, `@Pattern` on all fields.

## [2026-05-17] — Improvement Pass 2

### Security Fix: Token Exposure in URL
- **[ui-service] AuthController.java** — CRITICAL FIX. JWT token was appended to redirect URL as query parameter (`?token=...`), exposing it in browser history, server access logs, and HTTP Referer headers.
  - Removed `?token=` from all three role-based redirect URLs.
  - Token is already stored in the HttpOnly cookie — URL exposure was redundant and dangerous.

### Security Fix: JWT Cookie Hardening
- **[ui-service] AuthController.java** — Added `cookie.setPath("/")` to scope the cookie correctly across all paths.

### Security Fix: CORS in ui-service
- **[ui-service] CorsConfig.java** — Replaced reactive `CorsWebFilter` (wrong for servlet-based MVC) with servlet `CorsFilter`.
  - Fixed wildcard `allowedOrigins="*"` with `allowCredentials=true` (browser CORS spec violation). Now uses explicit origins.

### Security Fix: Environment Variable Substitution for DB Credentials
- **[api-gateway] application-docker.properties** — DB username and password now use `${DB_USER:ramo}` / `${DB_PASSWORD:12345}` Spring property substitution, allowing override via environment variables without changing source files.

### Build Status (Final — All 6 services)
- `api-gateway` — BUILD SUCCESS 
- `discovery-server` — BUILD SUCCESS
- `personnel-info-service` — BUILD SUCCESS
- `mail-service` — BUILD SUCCESS
- `ui-service` — BUILD SUCCESS 
- `leave-tracking-service` — BUILD SUCCESS 

## [2026-05-17] — Improvement Pass 3: Authorization and Validation Hardening

### Authorization Enhancement: @PreAuthorize on Controllers
- **[ui-service] AdminController.java** — Added `@PreAuthorize("hasRole('ADMIN')")` at class level. All admin endpoints now require ADMIN role at the method-security layer in addition to URL-level security.
- **[ui-service] HrController.java** — Added `@PreAuthorize("hasRole('HR')")` at class level. All HR endpoints now double-enforced.
- **[ui-service] EmployeeController.java** — Added `@PreAuthorize("hasRole('EMPLOYEE')")` at class level. All employee endpoints now double-enforced.

### New: SecurityConfig for ui-service
- **[ui-service] config/SecurityConfig.java** — NEW FILE. Created `@EnableWebSecurity` + `@EnableMethodSecurity(prePostEnabled = true)` configuration so that `@PreAuthorize` annotations are activated. Also defines URL-level security rules and disables CSRF for stateless JWT operation.
- **[ui-service] pom.xml** — Added `spring-boot-starter-security` and `spring-boot-starter-validation` dependencies to support the new security config and DTO validation.

### Input Validation: Remaining DTOs
- **[personnel-info-service] UpdatePersonnelStatusRequest.java** — Added `@NotBlank @Email` on email field and `@NotBlank @Pattern(regexp = "ACTIVE|INACTIVE|ON_LEAVE")` on status field.
- **[ui-service] LoginForm.java** — Added `@NotBlank @Email` on email and `@NotBlank @Size(min=6, max=100)` on password. Prevents malformed login submissions at the UI layer.
