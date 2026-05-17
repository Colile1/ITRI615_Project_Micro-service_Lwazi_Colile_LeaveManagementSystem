# UI Service

Server-side web frontend built with Thymeleaf and Spring MVC. Provides role-specific pages for Employees, HR Managers, and Admins. Authentication uses JWT stored in an HttpOnly cookie — no server-side session.

## Port

`8086` (host) → `8080` (container)

## Responsibilities

- Serve login page (`/ui/auth`) and role-based pages
- Accept login credentials, call the API Gateway auth endpoint, and store the returned JWT as an HttpOnly cookie
- Redirect to the correct role-specific page based on the JWT role claim
- Forward all API calls through the API Gateway on port `8080`

## URL Paths

| Path | Description |
|---|---|
| `/ui/auth` | Login page |
| `/ui/auth/login` | POST — submits credentials, sets JWT cookie |
| `/ui/admin/{userId}` | Admin dashboard (requires `ADMIN` role) |
| `/ui/hr/{userId}` | HR dashboard — create personnel (requires `HR` role) |
| `/ui/employee/{userId}` | Employee dashboard — view leave requests (requires `EMPLOYEE` role) |

## Roles and Access

| Role | Controller | Access |
|---|---|---|
| `ADMIN` | `AdminController` | Personnel management, system overview |
| `HR` | `HrController` | Create personnel, manage requests |
| `EMPLOYEE` | `EmployeeController` | View own leave requests |

All role-specific controllers are annotated with `@PreAuthorize` — access is enforced at both URL level (SecurityConfig) and method level.

## Authentication Flow

```
POST /ui/auth/login
  |
  v
API Gateway /api/auth/authenticate
  |
  v
JWT token returned --> stored as HttpOnly cookie (path="/")
  |
  v
Redirect to /ui/{role}/{userId}   (no token in URL)
```

## Template Files

| Template | Path | Used By |
|---|---|---|
| `auth.html` | `/ui/auth` | Login form |
| `admin-page.html` | `/ui/admin/{userId}` | Admin dashboard |
| `hr-page.html` | `/ui/hr/{userId}` | HR dashboard |
| `employee-page.html` | `/ui/employee/{userId}` | Employee dashboard |

## Key Dependencies

- Spring MVC + Thymeleaf (server-side rendering, XSS auto-escaping)
- Spring Security (`@EnableMethodSecurity`, `@PreAuthorize`)
- Bean Validation (`@NotBlank`, `@Email`, `@Size` on `LoginForm`)
- Netflix Eureka Client (service discovery)
- `CorsFilter` (servlet-based, explicit allowed origins)

## Running Locally

```powershell
Set-Location ui-service
mvn spring-boot:run
```

Requires Discovery Server and API Gateway to be running. Access at `http://localhost:8086/ui/auth`.
