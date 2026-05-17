# UI Service

Server-side web frontend built with Thymeleaf and Spring MVC. Provides role-specific dashboards for Employees, HR Managers, and Admins. All backend calls are made through the API Gateway.

## Port

`8085`

## Responsibilities

- Serve login page and role-based dashboards
- Handle session authentication (Spring Security form login)
- Forward API requests to the API Gateway (port 8080)
- Display leave request status, personnel lists, and admin panels

## Roles & Views

| Role | Landing Page | Capabilities |
|---|---|---|
| `EMPLOYEE` | `/dashboard/employee` | View own leave requests, submit new request |
| `HR_MANAGER` | `/dashboard/hr` | View all requests, approve/reject |
| `ADMIN` | `/dashboard/admin` | Full access including personnel management |

## Key Dependencies

- Spring MVC + Thymeleaf
- Spring Security (form-based login, session management)
- Netflix Eureka Client
- Spring Boot Web

## Template Structure

```
src/main/resources/
├── templates/
│   ├── login.html
│   ├── dashboard/
│   │   ├── employee.html
│   │   ├── hr.html
│   │   └── admin.html
│   └── fragments/
│       └── nav.html
└── static/
    └── css/
```

## Running

```powershell
mvn spring-boot:run
```

Requires Discovery Server and API Gateway to be running. Access at `http://localhost:8085`.
