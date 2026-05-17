# Leave Tracking Service

Consumes leave-related Kafka events and tracks leave processing. Uses Quartz Scheduler with a JDBC job store to run periodic jobs that check and update leave statuses, then triggers email notifications via the Mail Service.

## Port

`8083` (host) → `8080` (container — uses Eureka dynamic port `0` internally)

## Responsibilities

- Consume messages from Kafka topic `leave-request-topic` produced by Leave Request Service
- Persist and schedule tracking jobs using Quartz with MySQL-backed JDBC job store
- Trigger Mail Service to send approval/rejection emails
- Call Personnel Info Service to update an employee's leave status after processing

## Kafka Consumer

| Property | Value |
|---|---|
| Topic | `leave-request-topic` |
| Group ID | `listener` |
| Value deserializer | `JsonDeserializer` |
| Message type | `LeaveRequestMessage` (`com.id3.leaverequestservice.model.LeaveRequestMessage`) |

## Quartz Scheduler

- Job store type: **JDBC** (persists jobs across restarts)
- Data source: `leave_tracking_db` on MySQL port `3307`
- Instance name: `QuartzScheduler` with `instanceId=AUTO`
- Thread pool: 5 threads

## Databases

| Purpose | Database | MySQL Host Port |
|---|---|---|
| JPA (general persistence) | `quartz_demo` | `3306` |
| Quartz JDBC job store | `leave_tracking_db` | `3307` |

## Key Dependencies

- Spring Kafka (consumer)
- `spring-boot-starter-quartz` + `AutoWiringSpringBeanJobFactory` (enables `@Autowired` in Quartz Jobs)
- Spring Data JPA + MySQL Connector
- Netflix Eureka Client
- Spring Boot Web (for REST calls to other services)

## Running Locally

```powershell
Set-Location leave-tracking-service
mvn spring-boot:run
```

Requires Discovery Server, MySQL (`leave_tracking_db` on port `3307`), and Kafka to be available.
