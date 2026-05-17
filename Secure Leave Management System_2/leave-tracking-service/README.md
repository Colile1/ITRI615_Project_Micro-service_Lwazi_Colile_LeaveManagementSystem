# Leave Tracking Service

Consumes leave-related Kafka events and tracks leave processing. Uses Quartz Scheduler to run periodic jobs that check and update leave statuses, and triggers email notifications via the Mail Service.

## Port

`8083`

## Responsibilities

- Listen to Kafka topics for leave request events produced by Leave Request Service
- Persist tracking records to MySQL (`leave_tracking_db`)
- Run scheduled Quartz jobs to process pending leave records
- Trigger Mail Service to send approval/rejection emails
- Update Personnel Info Service with the employee's leave status

## Kafka Consumer

Listens to topic: `leave-requests`

On receiving a message, the service records the event and schedules any follow-up processing.

## Quartz Scheduler

Jobs are configured in `application.yml` and run on a defined cron expression to sweep pending records and finalize state transitions.

## Database

- **MySQL** (`leave_tracking_db`) — port `3307`

## Key Dependencies

- Spring Kafka (consumer)
- Quartz Scheduler (`spring-boot-starter-quartz`)
- Spring Data JPA + MySQL Connector
- Netflix Eureka Client
- Spring Boot Web (for inter-service REST calls)

## Running

```bash
mvn spring-boot:run
```

Requires Discovery Server, MySQL (`leave_tracking_db`), and Kafka to be available.
