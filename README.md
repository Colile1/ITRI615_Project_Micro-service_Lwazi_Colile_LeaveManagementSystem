# ITRI615 — Secure Leave Management System

A microservices-based HR Leave Management System built for the ITRI615 Computer Security course at NWU. The system demonstrates secure microservice design with JWT authentication, role-based access control, rate limiting, and event-driven communication.

## Architecture Overview

```
Browser / Client
      │
      ▼
 [UI Service :8085]
      │
      ▼
[API Gateway :8080]  ──── JWT validation, rate limiting (60 req/min/IP)
      │
      ├──► [Personnel Info Service :8081]  ── Employee records, MySQL
      ├──► [Leave Request Service   :8082]  ── Leave CRUD, MySQL, Kafka producer
      └──► [Leave Tracking Service  :8083]  ── Quartz scheduler, Kafka consumer
                                                     │
                                           [Mail Service :8084]  ── Email notifications
[Discovery Server :8761]  ── Eureka service registry (all services register here)
```

## Services

| Service | Port | Description |
|---|---|---|
| [api-gateway](Secure%20Leave%20Management%20System_2/api-gateway/) | 8080 | Request routing, JWT auth, rate limiting |
| [discovery-server](Secure%20Leave%20Management%20System_2/discovery-server/) | 8761 | Eureka service registry |
| [personnel-info-service](Secure%20Leave%20Management%20System_2/personnel-info-service/) | 8081 | Employee/HR data management |
| [leave-request-service](Secure%20Leave%20Management%20System_2/leave-request-service/) | 8082 | Leave request lifecycle |
| [leave-tracking-service](Secure%20Leave%20Management%20System_2/leave-tracking-service/) | 8083 | Tracking, scheduling, Kafka consumer |
| [mail-service](Secure%20Leave%20Management%20System_2/mail-service/) | 8084 | Email notifications via SMTP |
| [ui-service](Secure%20Leave%20Management%20System_2/ui-service/) | 8085 | Thymeleaf web frontend |

## Technology Stack

- **Java 17**, **Spring Boot 3.3.1**, **Spring Cloud 2023.0.2**
- **Spring Cloud Gateway** — API Gateway with Spring Security
- **Netflix Eureka** — Service discovery
- **Apache Kafka** — Async event messaging
- **MySQL** — Persistent storage (separate DB per service)
- **JWT (jjwt 0.12.3)** — Stateless authentication
- **Bucket4j 8.10.1** — Token-bucket rate limiting
- **Quartz Scheduler** — Scheduled leave tracking jobs
- **Thymeleaf** — Server-side UI templating
- **Docker / Docker Compose / Kubernetes** — Container orchestration
- **Spring Boot Actuator + Micrometer/Prometheus** — Observability
---

# Features

## Employee Management
- Add and remove employees
- Update employee information
- Manage departments and positions
- View personnel records

## Leave Management
- Create leave requests
- Approve or reject leave requests
- Track leave status
- Manage different leave types

## Notification System
- Email notifications for leave approvals/rejections
- Kafka-based asynchronous communication
- Event-driven processing

## Microservices Infrastructure
- Service discovery using Eureka
- API routing using Spring Cloud Gateway
- Docker containerization
- Kubernetes deployment support

---
## Security Features

- JWT-based stateless authentication with 24-hour token expiry
- Role-based access control: `EMPLOYEE`, `HR_MANAGER`, `ADMIN`
- Rate limiting: 60 requests/minute per IP address
- Bean Validation on all DTOs
- CORS configured via `CorsFilter`
- Method-level security (`@PreAuthorize`)

## Quick Start

### Prerequisites

- Docker Desktop
- Java 17+
- Maven 3.8+

### Run with Docker Compose

```powershell
Set-Location "Secure Leave Management System_2"
docker-compose up -d
```

This starts Zookeeper, Kafka, two MySQL instances, and all seven services.

### Run Individually (development)

```powershell
# Start infrastructure first
docker-compose up -d zookeeper kafka mysql-leave-request mysql-leave-tracking mysql-personnel

# Then start services in order:
# 1. Discovery Server
# 2. API Gateway
# 3. Backend services (any order)
# 4. UI Service
```

### Default Credentials

Default credentials are defined in the personnel-info-service seed data. **Do not commit real passwords.** For local development, set credentials via environment variables or a `.env` file that is excluded from version control (see `.gitignore`).

## Project Structure

```
ITRI615_Project_Micro-service/
├── Secure Leave Management System_2/
│   ├── api-gateway/
│   ├── discovery-server/
│   ├── leave-request-service/
│   ├── leave-tracking-service/
│   ├── mail-service/
│   ├── personnel-info-service/
│   ├── ui-service/
│   ├── docker-compose.yml
│   └── pom.xml                  (parent POM)
├── CHANGELOG.md
└── README.md
```


