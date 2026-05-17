# ITRI615 — Secure Leave Management System

A microservices-based HR Leave Management System built for the ITRI615 Computer Security course at NWU. The system demonstrates secure microservice architecture with JWT authentication, role-based access control, rate limiting, and event-driven communication.

---

## Architecture Overview

```
Browser / Client
      |
      v
[UI Service :8086]  <-- Thymeleaf server-side UI
      |
      v
[API Gateway :8080]  <-- JWT validation, rate limiting (60 req/min/IP), routing
      |
      |---> [Personnel Info Service :8084]  -- Employee records, MySQL (personnel_info_db)
      |---> [Leave Request Service  :8085]  -- Leave CRUD, MySQL, Kafka producer
      |---> [Leave Tracking Service :8083]  -- Quartz scheduler, Kafka consumer
      |---> [Mail Service           :8082]  -- Gmail SMTP notifications, Kafka consumer
      |---> [Eureka Dashboard       :8761]  -- (via /eureka/web gateway route)

[Discovery Server :8761]  <-- Netflix Eureka service registry (all services register here)

Infrastructure:
  Zookeeper :2181  /  Kafka :9092  /  MySQL x3 (:3306, :3307, :3308)
```

---

## Services

| Service | Host Port | Description |
|---|---|---|
| [api-gateway](Secure%20Leave%20Management%20System_2/api-gateway/) | 8080 | Request routing, JWT auth, rate limiting |
| [discovery-server](Secure%20Leave%20Management%20System_2/discovery-server/) | 8761 | Netflix Eureka service registry |
| [personnel-info-service](Secure%20Leave%20Management%20System_2/personnel-info-service/) | 8084 | Employee and HR data management |
| [leave-request-service](Secure%20Leave%20Management%20System_2/leave-request-service/) | 8085 | Leave request lifecycle, Kafka producer |
| [leave-tracking-service](Secure%20Leave%20Management%20System_2/leave-tracking-service/) | 8083 | Quartz scheduler, Kafka consumer |
| [mail-service](Secure%20Leave%20Management%20System_2/mail-service/) | 8082 | Email notifications via Gmail SMTP |
| [ui-service](Secure%20Leave%20Management%20System_2/ui-service/) | 8086 | Thymeleaf web frontend |

---

## Technology Stack

| Layer | Technology |
|---|---|
| Language / Runtime | Java 17 |
| Framework | Spring Boot 3.3.1, Spring Cloud 2023.0.2 |
| API Gateway | Spring Cloud Gateway MVC (servlet, not reactive) |
| Service Discovery | Netflix Eureka |
| Messaging | Apache Kafka + Zookeeper |
| Databases | MySQL (3 separate instances — one per data service) |
| Authentication | JWT (jjwt 0.12.3) — HS256, 24-hour expiry, HttpOnly cookie |
| Rate Limiting | Bucket4j 8.10.1 — token-bucket, 60 req/min/IP |
| Scheduling | Quartz Scheduler (JDBC job store) |
| Frontend | Thymeleaf (server-side rendering, XSS auto-escaping) |
| Containerisation | Docker, Docker Compose, Kubernetes YAMLs |
| Observability | Spring Boot Actuator, Micrometer, Prometheus |

---

## Security Features

| Feature | Details |
|---|---|
| JWT Authentication | HS256, 24-hour expiry, stored in HttpOnly cookie |
| RBAC | Three roles: `ADMIN`, `HR`, `EMPLOYEE` — enforced at URL and method level |
| Method Security | `@PreAuthorize` on all role-specific controllers |
| Rate Limiting | 60 requests/minute per IP — returns HTTP 429 on breach |
| Input Validation | Bean Validation (`@NotBlank`, `@Email`, `@Size`, `@Pattern`) on all DTOs |
| CORS | Explicit allowed origins — wildcard blocked when `allowCredentials=true` |
| SQL Injection | JPA parameterised queries throughout |
| XSS | Thymeleaf auto-escaping on all rendered output |
| Cookie Security | `HttpOnly`, `Path=/` — token never exposed in URLs or JS |
| Credential Security | All secrets via environment variables or `.env` (excluded from git) |

---

## Quick Start

### Prerequisites

- Docker Desktop 24+
- Java 17+ (for local Maven builds only)
- Maven 3.8+ (for local Maven builds only)

### Option A — Automated Script (recommended)

```powershell
# From ITRI615_Project_Micro-service directory:
.\start-app.ps1
```

The script checks prerequisites, prompts for secrets, starts all containers, and opens the browser.

```powershell
.\start-app.ps1 -SkipPull        # use cached Docker images (faster on re-runs)
.\start-app.ps1 -MonitoringStack # also start Prometheus + Grafana
.\start-app.ps1 -StopAll         # stop and remove all containers
```

### Option B — Docker Compose Manually

```powershell
Set-Location "Secure Leave Management System_2"

# Start infrastructure first (wait ~25 s for MySQL/Kafka to initialise)
docker compose up -d zookeeper kafka mysql-leave-request mysql-leave-tracking mysql-personnel-info

Start-Sleep -Seconds 25

# Then start all application services
docker compose up -d discovery-server api-gateway personnel-info-service leave-request-service leave-tracking-service mail-service ui-service
```

**Required environment variables** (set before running, or place in `Secure Leave Management System_2/.env`):

```
MAIL_USERNAME=you@gmail.com
MAIL_PASSWORD=your-16-char-gmail-app-password
JWT_SECRET=any-32-plus-char-random-string
DB_USER=ramo
DB_PASSWORD=12345
```

> **Never commit `.env`.** It is already listed in `.gitignore`.

---

## Access Points

| URL | Description |
|---|---|
| `http://localhost:8086/ui/auth` | Web UI — login page |
| `http://localhost:8080` | API Gateway (REST entry point) |
| `http://localhost:8761` | Eureka Dashboard |
| `http://localhost:8080/actuator/health` | Gateway health check |
| `http://localhost:8080/actuator/prometheus` | Prometheus metrics |

---

## Project Structure

```
ITRI615_Project_Micro-service/
|-- Secure Leave Management System_2/
|   |-- api-gateway/
|   |-- discovery-server/
|   |-- leave-request-service/
|   |-- leave-tracking-service/
|   |-- mail-service/
|   |-- personnel-info-service/
|   |-- ui-service/
|   |-- docker-compose.yml
|   |-- pom.xml                 (parent POM)
|   `-- CHANGELOG.md
|-- start-app.ps1               (automated startup script)
|-- GAP_CLOSURE_GUIDE.md
|-- THEORY_COMPONENT.md
|-- PRESENTATION_GUIDE.md
`-- README.md
```

---

## Authors

- **Lwazi Junior Nhlapo** — Spring Boot microservices, Docker, Kafka integration
- **Colile Sibanda** — Security hardening, JWT, rate limiting, validation, UI fixes

*ITRI615 Computer Security 1 — North-West University*
