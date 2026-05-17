# Leave Request Service

Handles the full lifecycle of employee leave requests: submission, approval, and rejection. Publishes Kafka events when leave status changes so downstream services (Leave Tracking, Mail) can react asynchronously.

## Port

`8085` (host) → dynamic Eureka port internally (`server.port=0`)

## Responsibilities

- Accept new leave requests from employees
- Allow HR and Admins to approve or reject requests
- Persist leave records in MySQL (`leave_request_db`)
- Publish `LeaveRequestMessage` events to Kafka topic `leave-request-topic` on status change

## Gateway Route Prefix

All requests routed through: `/leave-request/**`

## REST Endpoints (via API Gateway at port 8080)

| Method | Path | Role Required | Description |
|---|---|---|---|
| GET | `/leave-request/{userId}` | `EMPLOYEE`, `HR`, `ADMIN` | Get leave requests for a user |
| POST | `/leave-request` | `EMPLOYEE` | Submit a new leave request |
| PUT | `/leave-request/{id}/approve` | `HR`, `ADMIN` | Approve request |
| PUT | `/leave-request/{id}/reject` | `HR`, `ADMIN` | Reject request |

> Note: this service runs from the Docker Hub image `ramazanakdag/leave-request-service:latest`. The local source only contains `application.properties` files.

## Kafka Events

Publishes to topic `leave-request-topic`:

```json
{
  "firstName": "Jane",
  "lastName": "Smith",
  "mail": "jane@example.com",
  "managerMail": "manager@example.com",
  "leaveStartDate": "2025-06-01",
  "leaveEndDate": "2025-06-05",
  "description": "Annual leave",
  "leaveType": "ANNUAL",
  "status": "PENDING"
}
```

## Database

- **MySQL** — database: `leave_request_db`, host port: `3306`
- Connection: `jdbc:mysql://mysql-leave-request:3306/leave_request_db` (Docker)

## Key Dependencies

- Spring Data JPA + MySQL Connector
- Spring Kafka (producer)
- Netflix Eureka Client

## Running Locally

```powershell
Set-Location leave-request-service
mvn spring-boot:run
```

Requires Discovery Server, MySQL (`leave_request_db` on port `3306`), and Kafka to be available.
