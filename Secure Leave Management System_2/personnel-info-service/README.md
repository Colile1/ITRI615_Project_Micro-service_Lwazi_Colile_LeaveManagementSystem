# Personnel Info Service

Manages employee and HR personnel records. Provides CRUD operations for employees, departments, and positions, secured with role-based access control.

## Port

`8081`

## Responsibilities

- Store and retrieve employee profiles (name, department, position, status)
- Expose REST endpoints consumed by UI Service and Leave Request Service
- Update employee leave status when leave is approved/rejected (consumed via Kafka or direct call)
- Enforce method-level security via `@PreAuthorize`

## REST Endpoints

| Method | Path | Role Required | Description |
|---|---|---|---|
| GET | `/api/personnel` | EMPLOYEE | List all personnel |
| GET | `/api/personnel/{id}` | EMPLOYEE | Get one employee |
| POST | `/api/personnel` | HR_MANAGER, ADMIN | Create employee |
| PUT | `/api/personnel/{id}` | HR_MANAGER, ADMIN | Update employee |
| DELETE | `/api/personnel/{id}` | ADMIN | Delete employee |
| GET | `/actuator/health` | — | Health check |

## Database

- **MySQL** (`personnel_db`) in production
- **H2** in-memory for development/testing

## Key Dependencies

- Spring Data JPA + MySQL Connector
- Spring Security + Bean Validation
- Spring Boot Actuator + Micrometer Prometheus
- Netflix Eureka Client

## Running

```bash
mvn spring-boot:run
```

Requires Discovery Server and MySQL (`personnel_db`) to be available.
