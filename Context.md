Secure Leave Management System
An enterprise-grade Leave Management System built using a microservices architecture with Spring Boot, Spring Cloud, Kafka, Docker, Kubernetes, and MySQL.

This project was developed to streamline employee leave management processes in corporate environments by enabling efficient leave request handling, personnel management, notifications, and service orchestration.

System Architecture
The application follows a distributed microservices architecture consisting of independent services communicating through REST APIs and Apache Kafka messaging.

Core Components
API Gateway
Eureka Discovery Server
Leave Request Service
Leave Tracking Service
Personnel Information Service
Mail Service
UI Service
Kafka & Zookeeper
MySQL Databases
Features
Employee Management
Add and remove employees
Update employee information
Manage departments and positions
View personnel records
Leave Management
Create leave requests
Approve or reject leave requests
Track leave status
Manage different leave types
Notification System
Email notifications for leave approvals/rejections
Kafka-based asynchronous communication
Event-driven processing
Microservices Infrastructure
Service discovery using Eureka
API routing using Spring Cloud Gateway
Docker containerization
Kubernetes deployment support
Technologies Used
Backend
Java 17
Spring Boot
Spring Cloud
Spring Data JPA
Hibernate
Microservices & Communication
Eureka Discovery Server
Spring Cloud Gateway
Apache Kafka
REST APIs
Database
MySQL
H2 Database (Development)
Frontend
Thymeleaf
HTML/CSS
Bootstrap
DevOps & Deployment
Docker
Docker Compose
Kubernetes
Maven
Scheduling & Messaging
Quartz Scheduler
Kafka Listeners
Microservices
1. API Gateway
Routes incoming requests to the appropriate microservices.

Technologies
Spring Cloud Gateway
Eureka Client
2. Discovery Server
Handles service registration and discovery.

Technologies
Eureka Server
3. Leave Request Service
Handles employee leave request operations.

Features
Create leave requests
Approve/reject requests
Store leave records
Publish Kafka events
Technologies
Spring Boot
REST API
Kafka
MySQL
4. Personnel Information Service
Manages employee and HR information.

Features
Employee profile management
Personnel records
HR operations
Technologies
Spring Boot
Spring Data JPA
MySQL
5. Leave Tracking Service
Tracks leave request processing and schedules related operations.

Features
Leave tracking
Quartz scheduling
Kafka event processing
Technologies
Quartz Scheduler
Kafka Listener
MySQL
6. Mail Service
Handles email notifications.

Features
Leave approval notifications
Leave rejection notifications
Email event processing
Technologies
Spring Boot
Kafka Listener
Java Mail Sender
7. UI Service
Provides the frontend user interface.

Features
Employee dashboard
HR dashboard
Admin dashboard
Technologies
Thymeleaf
Spring MVC
Secure Leave Management System
System Workflow
Leave Request Flow
UI Service
    ↓
API Gateway
    ↓
Leave Request Service
    ↓
Kafka Messaging
    ↓
Leave Tracking Service
    ↓
Mail Service
Workflow Description
Employee submits a leave request
Request is stored in the database
Kafka event is published
HR manager approves/rejects request
Leave tracking service processes updates
Mail service sends notifications
API Endpoints
Leave Request Service
Create Leave Request
POST /leave-request
View All Leave Requests
GET /leave-request
Approve Leave Request
POST /leave-request/accept
Reject Leave Request
POST /leave-request/reject
Employee Leave Requests
GET /leave-request/{userId}
Personnel Information Service
Get All Personnel
GET /personnel-info
Get Personnel By ID
GET /personnel-info/{personnelId}
Add Personnel
POST /personnel-info
Update Personnel
POST /personnel-info/update
User Roles
Admin
Manage HR managers
Manage user roles
System administration
HR Manager
Manage employees
Approve/reject leave requests
Update personnel information
Employee
Create leave requests
View leave status
Manage profile information
Running the Project
Prerequisites
Install the following:

Java 17+
Maven
Docker
Docker Compose
MySQL
Kubernetes (optional)
Local Development Setup
Clone Repository
git clone https://github.com/YOUR_USERNAME/secure-leave-management-system.git
Navigate to Project
cd secure-leave-management-system
Build Project
mvn clean install
Run Services
Using Maven
mvn spring-boot:run
Using Docker Compose
docker-compose up
Kubernetes Deployment
Deploy all services:

kubectl apply -f .
Check running pods:

kubectl get pods
UI Access
Employee Dashboard
http://localhost:8080/ui/employee/{userId}
HR Dashboard
http://localhost:8080/ui/hr/{userId}
Admin Dashboard
http://localhost:8080/ui/admin/{userId}
Screenshots
Eureka Dashboard
![Eureka Dashboard](screenshots/eureka-dashboard.png)
Employee Dashboard
<img width="1058" height="286" alt="Admin1" src="https://github.com/user-attachments/assets/5ca612c8-60c9-41a2-ae08-6f21a09cb2d0" />
<img width="498" height="225" alt="Admin2-1" src="https://github.com/user-attachments/assets/bda6b404-0ded-4348-b76e-66d85f82ea83" />
<img width="1575" height="160" alt="Admin2-2" src="https://github.com/user-attachments/assets/0f6b6adc-29d6-4347-ba5b-ec0b8f1e1464" />

![Employee Dashboard](screenshots/employee-dashboard.png)
HR Dashboard
<img width="1856" height="285" alt="HR1-1" src="https://github.com/user-attachments/assets/4b6b2ec0-e618-4a26-8e4d-fbabee71b38c" />
<img width="1846" height="319" alt="HR1-2" src="https://github.com/user-attachments/assets/954ae49e-3789-40e8-99f9-428597dea860" />
<img width="1855" height="232" alt="HR2" src="https://github.com/user-attachments/assets/b620bbb1-d562-415d-8adc-9ebbc73321ab" />

![HR Dashboard](screenshots/hr-dashboard.png)
Kubernetes Deployment
![Kubernetes](screenshots/kubernetes.png)
Future Improvements
JWT Authentication
Role-Based Access Control (RBAC)
CI/CD Pipeline
Swagger/OpenAPI Documentation
Monitoring with Prometheus & Grafana
Centralized Logging
React Frontend Migration
Kubernetes Ingress & Secrets
Development Process
Requirement Analysis
System Design
Microservices Development
Kafka Integration
Testing & Validation
Docker Containerization
Kubernetes Deployment
Testing
Run tests using:

mvn test
Contribution
Contributions are welcome.

Fork the repository
Create a feature branch
Commit changes
Open a pull request
License
This project is licensed under the MIT License.

Author
Lwazi Junior Nhlapo
Aspiring Data Scientist, Software Developer, and Cloud & AI Engineer from Johannesburg, South Africa.

Project Structure
secure-leave-management-system/
│
├── api-gateway/
├── discovery-server/
├── leave-request-service/
├── leave-tracking-service/
├── mail-service/
├── personnel-info-service/
├── ui-service/
│
├── docker-compose.yml
├── kafka-docker-compose.yml
├── pom.xml
│
├── api-gateway-deployment.yaml
├── discovery-server-deployment.yaml
├── kafka-deployment.yaml
├── zookeeper-deployment.yaml
│
├── screenshots/
│
└── README.md

