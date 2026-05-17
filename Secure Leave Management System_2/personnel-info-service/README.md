# Personnel Info Service

Manages employee and HR personnel records. Provides CRUD operations secured with role-based access control, input validation, and health monitoring.

## Port

`8084` (host) → `8080` (container — uses Eureka port `0` dynamic assignment internally)

## Responsibilities

- Store and retrieve employee profiles (name, email, department, position, role, status)
- Expose REST endpoints consumed by the UI Service via the API Gateway
- Update employee status when leave is approved or rejected
- Validate all incoming DTOs with Bean Validation

## Gateway Route Prefix

All requests routed through: `/personnel-info/**`

## Key Endpoints (via API Gateway at port 8080)

| Method | Path | Role Required | Description |
|---|---|---|---|
| GET | `/personnel-info/...` | Any authenticated | List or retrieve personnel |
| POST | `/personnel-info/...` | `HR`, `ADMIN` | Create new employee |
| PUT | `/personnel-info/...` | `HR`, `ADMIN` | Update employee |
| DELETE | `/personnel-info/...` | `ADMIN` | Remove employee |
| GET | `/actuator/health` | — | Health check |

## Database

- **MySQL** — database: `personnel_info_db`, host port: `3308`
- Connection: `jdbc:mysql://mysql-personnel-info:3306/personnel_info_db` (Docker)
- Schema managed by Hibernate `ddl-auto=update`

## Input Validation

`CreatePersonnelRequest` enforces:
- `@NotBlank @Email` on email
- `@NotBlank @Size(min=2, max=50)` on first name, last name
- `@Pattern(regexp = "ADMIN|HR|EMPLOYEE")` on role
- `@NotBlank` on department, position

`UpdatePersonnelStatusRequest` enforces:
- `@NotBlank @Email` on email
- `@Pattern(regexp = "ACTIVE|INACTIVE|ON_LEAVE")` on status

## Key Dependencies

- Spring Data JPA + MySQL Connector
- Spring Boot Actuator + Micrometer Prometheus
- Spring Boot Validation (Bean Validation)
- Netflix Eureka Client

## Running Locally

```powershell
Set-Location personnel-info-service
mvn spring-boot:run
```

Requires Discovery Server and MySQL (`personnel_info_db` on port `3308`) to be available.
