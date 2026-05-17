# Discovery Server

Netflix Eureka-based service registry. All microservices register themselves here on startup, enabling dynamic service discovery and load balancing without hardcoded URLs.

## Port

`8761`

## Responsibilities

- Maintain a registry of all running service instances
- Provide service location information to the API Gateway and inter-service calls
- Health-check registered instances and evict unresponsive ones

## Eureka Dashboard

Available at `http://localhost:8761` when running locally. Shows all registered service instances and their status.

## Key Dependency

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
</dependency>
```

## Running

```bash
mvn spring-boot:run
```

Start this service **first** before any other microservice.
