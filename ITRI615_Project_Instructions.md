# ITRI615 Project option 1Lecturer: Prof. Lynette Drevin
Facilitator: Mr. Bernard Swanepoel
Date: May

## 1 Introduction
This project introduces students to core system-architecture concepts, with a
specific focus on the microservices architectural style and its security implica-
tions. Students will design and implement a microservice-based backend and
frontend, and secure endpoints and data access using established security pat-
terns and standards. The project consists of 70% practical work and 30% the-
oretical analysis.
NOTE!
•Python and Firebase is prohibited due to their ease of building
backends.
•GitHub or any other source control should be used throughout
this project.


## 2 Practical part (70 marks)
2.1 Basic microservice (15 marks)
Students must create a basic microservice in any language except Python.
This microservice can implement any functionality with any database and data.
The initial microservice should be simple and account for only 15 marks of
the project. The core objective of this project is to secure the microservice by
implementing various security techniques. The project is broken down into the
following components:
2.2 API gateway requirement (5 marks)
All access to microservices must go through an API Gateway.
2.3 Authentication (10 marks)
Implement authentication using JWT (JSON Web Token) or a similar method.
Ensure that users can securely log in and interact with the microservice.
2.4 Authorization (10 marks)
Implement OAuth or a role-based authorization system to ensure that users
have proper permissions and access control to the microservice.
1
2.5 Logging and monitoring (10 marks)
Implement basic logging and monitoring using tools such as Kibana and Prometheus,
or code-based solutions like Logger and LoggerFactory in Java Spring Boot, or
Winston in Express.js, or cloud-service–based solutions such as Amazon Cloud-
Watch Logs.
2.6 Input validation and limiting (10 marks)
Ensure all incoming requests are validated and sanitized to prevent security
vulnerabilities such as SQL Injection and XSS. Additionally, implement request
rate limiting to mitigate potential DDoS attacks.
2.7 Frontend implementation (6 marks)
Develop a simple web-based user interface using vanilla JavaScript or a JavaScript
framework such as React, Angular, or Vue. No styling or CSS is required;
the goal is to verify secure communication between the frontend and backend.
The web frontend can also be substituted with a mobile app frontend using
JavaScript with React Native, Dart and Flutter, C# and .Net MAUI, Kotlin
with Jetpack Compose or any other mobile app tech you like.
2.8 Application of security patterns (4 marks)
To conform to best practices, students should apply formal security patterns
where applicable. Here is a link to some useful resources on security patterns.
2.9 Additional features (10 marks)
Bonus marks will be awarded for implementing additional security measures,
deploying the microservice in the cloud, or using other innovative technologies.
However, marks cannot exceed 100% of the total project score.


## 3 Theory component (30 marks)
3.1 Microservice scenario (3 marks)
Give the scenario of your microservice. Why is it important that this microser-
vice’s data is kept secure?
3.2 Security analysis (7 marks)
Explain how your entire frontend and backend are secured. Discuss the security
strategies implemented and their effectiveness.
2
3.3 Authentication and authorization methods (10 marks)
Provide an overview of different authentication and authorization methods. Jus-
tify your choice and explain why it is the most suitable approach for your project.
Provide references where applicable.
3.4 Real-world security failures and analysis (10 marks)
Analyze real-world security failures where improper authentication, authoriza-
tion, or security implementations led to vulnerabilities. Discuss what security
measures should have been implemented to prevent such failures. Provide ref-
erences where applicable.
Resources
•(Link to useful resources for understanding the microservice architecture)
•(Example of microservice backend)
•(Example of microservice frontend)
3


## 4 Summary of marks
Component Description Marks
Total Practical Marks: 70
Basic microservice implementation Develop a basic microservice in any lan-
guage except Python
15
API gateway requirement Ensure microservice is accessed via an
API Gateway
5
Authentication Implement authentication using JWT
or a similar method
10
Authorization Implement OAuth or role-based autho-
rization
10
Logging and monitoring Use tools like Kibana, Prometheus, or
code-based logging solutions
10
Input validation and limiting Validate and sanitize inputs, implement
rate limiting
10
Frontend integration Develop a basic web UI (React, Angu-
lar, Vue, or Vanilla JS)
6
Application of security patterns Apply formal security patterns where
applicable
4
Additional features Bonus marks for advanced security
or cloud deployment in AWS, Google
Cloud or Azure
10
Total Theory Marks: 30
Microservice scenario Give microservice scenario and explain
why it is relevant to be kept secure
3
Security analysis Explain security measures in the fron-
tend and backend
7
Auth methods comparison Discuss different authentication and
authorization methods, motivate your
choice
10
Real-world failures Analyze security failures and suggest
improvements
10
Deductions (if applicable)
Credentials exposed in GitHub Deduction for exposing sensitive cre-
dentials in GitHub repositories
-10
Use of Python or Firebase Made use of Python or Firebase as a
”easy way out”
-10
Total for this project: 100