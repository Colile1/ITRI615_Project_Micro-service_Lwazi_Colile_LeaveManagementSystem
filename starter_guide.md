# Starter Guide — Secure Leave Management System

How to set up, run, and test the system from scratch.

---

## Prerequisites

| Tool | Minimum Version | Check |
|---|---|---|
| Java JDK | 17 | `java -version` |
| Maven | 3.8 | `mvn -version` |
| Docker Desktop | 24+ | `docker -v` |
| Git | any | `git --version` |

---

## 1. Clone and Configure

```powershell
git clone <repo-url>
Set-Location "ITRI615_Project_Micro-service"
```

Copy the example environment file and fill in real values:

```powershell
Copy-Item .env.example .env
# Edit .env — set MAIL_USERNAME, MAIL_PASSWORD, DB_USER, DB_PASSWORD, JWT_SECRET
```

**Never commit `.env`.** It is already in `.gitignore`.

---

## 2. Start Infrastructure (Docker)

```powershell
Set-Location "Secure Leave Management System_2"
docker-compose up -d zookeeper kafka mysql-leave-request mysql-leave-tracking
```

Wait ~15 seconds for MySQL to initialise before starting services.

---

## 3. Start Services (Development — Maven)

Start services **in this order** (each in its own terminal):

```powershell
# Terminal 1 — Service Registry (must be first)
Set-Location discovery-server
mvn spring-boot:run

# Terminal 2 — API Gateway (must be second)
Set-Location api-gateway
mvn spring-boot:run

# Terminal 3–5 — Backend services (any order)
Set-Location personnel-info-service; mvn spring-boot:run
Set-Location leave-request-service;  mvn spring-boot:run
Set-Location leave-tracking-service; mvn spring-boot:run

# Terminal 6 — Mail Service
Set-Location mail-service; mvn spring-boot:run

# Terminal 7 — UI (last)
Set-Location ui-service; mvn spring-boot:run
```

---

## 4. Start Everything (Docker Compose — All Services)

```powershell
Set-Location "Secure Leave Management System_2"
docker-compose up -d
```

---

## 5. Access the Application

| URL | Description |
|---|---|
| `http://localhost:8085` | Web UI (login page) |
| `http://localhost:8080` | API Gateway (REST) |
| `http://localhost:8761` | Eureka Dashboard |
| `http://localhost:8080/actuator/health` | Gateway health check |
| `http://localhost:8081/actuator/health` | Personnel service health |

---

## 6. Testing the System

### A. Health Check (all services registered)

Open `http://localhost:8761` — you should see 6 services registered under *Instances currently registered with Eureka*.

### B. Authentication

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/login" `
  -ContentType "application/json" `
  -Body '{"email":"<your-email>","password":"<your-password>"}'
```

A successful response returns a JWT token.

### C. Rate Limiting

Send more than 60 requests in one minute from the same IP — the 61st request should return `HTTP 429 Too Many Requests`.

### D. Role-Based Access

Use the JWT from step B to call a protected endpoint:

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/personnel" `
  -Headers @{ Authorization = "Bearer <token>" }
```

Calling an endpoint your role is not authorised for should return `HTTP 403 Forbidden`.

### E. Unit / Integration Tests

```powershell
# From any service directory
mvn test

# From project root (all services)
Set-Location "Secure Leave Management System_2"
mvn test
```

---

## 7. Common Issues

| Problem | Likely Cause | Fix |
|---|---|---|
| Service not appearing in Eureka | Discovery Server not running | Start `discovery-server` first |
| `Connection refused` on port 3306 | MySQL container not ready | Wait 15s after `docker-compose up` |
| `401 Unauthorized` on all requests | JWT secret mismatch between api-gateway and service | Ensure `JWT_SECRET` env var is the same in all services |
| `429 Too Many Requests` | Rate limit hit | Wait 1 minute or restart api-gateway |
| Kafka `Leader not available` | Kafka still starting | Wait 30s after `docker-compose up` |
