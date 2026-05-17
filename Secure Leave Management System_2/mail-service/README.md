# Mail Service

Sends email notifications to employees when their leave requests are approved or rejected. Consumes events from a Kafka topic and dispatches emails via SMTP.

## Port

`8084`

## Responsibilities

- Listen to a Kafka topic for mail notification events
- Compose and send HTML/plain-text emails using Spring Mail
- Support approval and rejection notification templates

## Kafka Consumer

Listens to topic: `mail-notifications` (or equivalent topic configured in `application.yml`)

Expected message payload:

```json
{
  "to": "employee@example.com",
  "subject": "Leave Request Approved",
  "body": "Your leave request from 2025-06-01 to 2025-06-05 has been approved."
}
```

## SMTP Configuration

Configure in `application.yml`:

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: ${MAIL_USERNAME}
    password: ${MAIL_PASSWORD}
    properties:
      mail.smtp.auth: true
      mail.smtp.starttls.enable: true
```

Set `MAIL_USERNAME` and `MAIL_PASSWORD` as environment variables or in a `.env` file (do not commit credentials).

## Key Dependencies

- Spring Kafka (consumer)
- Spring Boot Mail (`spring-boot-starter-mail`)
- Netflix Eureka Client

## Running

```bash
mvn spring-boot:run
```

Requires Discovery Server and Kafka to be available.
