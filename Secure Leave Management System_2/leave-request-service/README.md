# Leave Request Service

Handles the full lifecycle of employee leave requests: submission, approval, and rejection. Publishes Kafka events when leave status changes so downstream services can react asynchronously.

## Port

`8082`

## Responsibilities

- Accept new leave requests from employees
- Allow HR Managers and Admins to approve or reject requests
- Persist leave records in MySQL
- Publish `LeaveRequestMessage` events to Kafka topics on status change

## REST Endpoints

| Method | Path | Role Required | Description |
|---|---|---|---|
| POST | `/api/leave-requests` | EMPLOYEE | Submit a leave request |
| GET | `/api/leave-requests` | HR_MANAGER, ADMIN | List all requests |
| GET | `/api/leave-requests/my` | EMPLOYEE | List own requests |
| PUT | `/api/leave-requests/{id}/approve` | HR_MANAGER, ADMIN | Approve request |
| PUT | `/api/leave-requests/{id}/reject` | HR_MANAGER, ADMIN | Reject request |

## Kafka Events

Published to topic `leave-requests`:

```json
{
  "leaveRequestId": 1,
  "employeeId": 42,
  "status": "APPROVED",
  "startDate": "2025-06-01",
  "endDate": "2025-06-05"
}
```

## Database

- **MySQL** (`leave_request_db`) — port `3306`

## Key Dependencies

- Spring Data JPA + MySQL Connector
- Spring Kafka (producer)
- Spring Security + Bean Validation
- Netflix Eureka Client

## Running

```powershell
mvn spring-boot:run
```

Requires Discovery Server, MySQL (`leave_request_db`), and Kafka to be available.
