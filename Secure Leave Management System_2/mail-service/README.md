# Mail Service

Sends email notifications to employees when their leave requests are approved or rejected. Consumes events from Kafka and dispatches emails via Gmail SMTP.

## Port

`8082` (host) → `8080` (container — uses Eureka dynamic port `0` internally)

## Responsibilities

- Listen to Kafka for mail notification events (produced by Leave Tracking Service)
- Compose and send emails via Gmail SMTP using Spring Mail
- Support approval and rejection message templates

## Configuration

Credentials are supplied via environment variables — never hardcoded:

```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=${MAIL_USERNAME:your-email@gmail.com}
spring.mail.password=${MAIL_PASSWORD:your-app-password}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```

Set `MAIL_USERNAME` and `MAIL_PASSWORD` as environment variables or in the project `.env` file (excluded from version control).

**Gmail App Password setup:**
1. Enable 2-Step Verification on your Google account
2. Go to `myaccount.google.com` > Security > App passwords
3. Generate a 16-character app password
4. Use that as `MAIL_PASSWORD` — not your Google account password

## Key Dependencies

- Spring Boot Mail (`spring-boot-starter-mail`)
- Spring Kafka (consumer)
- Netflix Eureka Client

## Running Locally

```powershell
Set-Location mail-service
mvn spring-boot:run
```

Requires Discovery Server and Kafka to be available. `MAIL_USERNAME` and `MAIL_PASSWORD` must be set.
