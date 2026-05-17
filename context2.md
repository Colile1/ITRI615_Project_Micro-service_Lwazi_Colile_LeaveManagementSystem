3.1 Microservice Scenario (3 Marks)

The developed system is a Secure Leave Management System based on a microservices architecture. The system is designed to assist organizations in managing employee leave requests, personnel information, authentication, notifications, and administrative operations in a secure and scalable manner.

The system consists of multiple independent microservices such as:

Authentication Service
Leave Request Service
Personnel Information Service
API Gateway
Discovery Server
Mail Service
Leave Tracking Service

Employees can submit leave requests through the frontend application, while HR managers and administrators can review, approve, reject, and manage employee leave records. Communication between services is handled through REST APIs and Kafka messaging.

It is important that the data in this microservice system remains secure because the platform stores sensitive organizational and employee information such as:

Employee personal details
Authentication credentials
Leave history and leave balances
HR decisions and approvals
Administrative access privileges

If this information is exposed or modified by unauthorized users, it could lead to privacy violations, identity theft, unauthorized leave approvals, financial losses, reputational damage, and disruption of organizational operations. Therefore, strong security mechanisms such as JWT authentication, role-based authorization, API Gateway protection, input validation, and secure communication were implemented to protect the system.

3.3 Authentication and Authorization Methods (10 Marks)

Authentication and authorization are essential security components in modern distributed systems and microservice architectures.

Authentication refers to the process of verifying the identity of a user or system, while authorization determines what resources or actions an authenticated user is allowed to access.

Authentication Methods
1. Username and Password Authentication

This is the most common authentication method where users provide credentials such as a username and password. The system verifies the credentials against stored user data.

Advantages:

Easy to implement
Widely supported

Disadvantages:

Vulnerable to brute-force attacks
Password theft can compromise accounts
2. JWT (JSON Web Token) Authentication

JWT authentication uses digitally signed tokens to authenticate users after successful login. Once authenticated, the server generates a token that the client sends with every request.

Advantages:

Stateless authentication
Suitable for distributed microservices
Scalable and lightweight
Reduces server-side session storage

Disadvantages:

Token expiration must be managed carefully
Stolen tokens may be abused if not secured properly

The project implemented JWT authentication because it is highly suitable for microservice architectures where multiple services need to validate user identity independently.

Example JWT flow:

User logs in
Authentication service validates credentials
JWT token is generated
Token is sent to the frontend
Frontend includes token in API requests
Backend validates token before processing requests
3. Multi-Factor Authentication (MFA)

MFA requires users to verify their identity using multiple methods such as passwords, OTPs, or biometrics.

Advantages:

Stronger security
Reduces risk of compromised passwords

Disadvantages:

More complex implementation
Additional user interaction required

Although MFA was not implemented in this project, it is recommended for future improvements.

Authorization Methods
1. Role-Based Access Control (RBAC)

RBAC restricts access based on user roles such as:

Admin
HR Manager
Employee

Each role has specific permissions within the system.

Examples:

Employees can submit leave requests
HR Managers can approve/reject leave requests
Admins can manage users and roles

Advantages:

Easy to manage
Improves access control
Reduces unauthorized access

The project implemented RBAC because it aligns well with organizational structures and provides a simple but effective authorization strategy.

2. OAuth 2.0

OAuth 2.0 is an authorization framework that allows third-party applications to access resources without exposing user credentials.

Advantages:

Secure delegated access
Commonly used in enterprise systems

Disadvantages:

More complex to implement
Requires additional infrastructure

OAuth was considered, but JWT with RBAC was selected because it provided a simpler and more suitable solution for the project scope and academic requirements.

Justification of Selected Approach

The project used JWT authentication together with Role-Based Access Control (RBAC) because these methods are lightweight, scalable, secure, and highly compatible with microservice architectures.

Reasons for selection:

Stateless authentication improves scalability
JWT works efficiently across distributed services
RBAC simplifies permission management
Easy integration with Spring Boot Security
Reduces server overhead
Suitable for frontend-backend communication

This combination provided strong protection against unauthorized access while maintaining system performance and usability.

References
Richardson, C. (2018). Microservices Patterns. Manning Publications.
OWASP Foundation. (2024). OWASP API Security Top 10. Available at: https://owasp.org
JWT Official Documentation. Available at: https://jwt.io
Spring Security Documentation. Available at: https://spring.io/projects/spring-security
3.4 Real-World Security Failures and Analysis (10 Marks)
1. Equifax Data Breach (2017)

The Equifax breach exposed sensitive information of approximately 147 million people. Attackers exploited a vulnerability in the Apache Struts framework that had not been patched.

Causes
Failure to apply security patches
Weak vulnerability management
Poor monitoring and incident response
Impact
Exposure of personal information
Financial losses
Reputational damage
Legal consequences
Prevention Measures
Regular patch management
Continuous vulnerability scanning
Security monitoring and logging
Strong incident response procedures

This demonstrates the importance of maintaining updated systems and implementing monitoring tools in microservice environments.

2. Uber Data Breach (2016)

Uber suffered a major data breach after attackers gained access to cloud credentials stored in a GitHub repository.

Causes
Credentials exposed in source control
Weak access management
Lack of proper secret management
Impact
Exposure of customer and driver data
Financial penalties
Loss of customer trust
Prevention Measures
Use environment variables and secret managers
Never store credentials in GitHub repositories
Implement access control and monitoring
Use multi-factor authentication

This project avoided exposing sensitive credentials by using external configuration and secure environment-based settings.

3. Facebook Access Token Vulnerability (2018)

Facebook experienced a vulnerability where attackers exploited weaknesses in access token management and gained unauthorized access to millions of accounts.

Causes
Improper token handling
Weak authorization validation
Insufficient session protection
Impact
Unauthorized account access
Privacy violations
Loss of public trust
Prevention Measures
Secure token validation
Token expiration and refresh mechanisms
Strong authorization controls
Continuous security testing

This highlights the importance of securely managing JWT tokens in modern applications.

Analysis

These real-world incidents demonstrate that improper authentication, weak authorization, exposed credentials, and poor security management can lead to severe consequences.

To reduce these risks, the Secure Leave Management System implemented several security measures including:

JWT authentication
Role-Based Access Control
API Gateway protection
Input validation and sanitization
Secure password encryption
Logging and monitoring
Secure microservice communication

These mechanisms help protect sensitive employee and organizational data while reducing the likelihood of unauthorized access and security breaches.

References
OWASP Foundation. (2024). OWASP Top 10 Security Risks. Available at: https://owasp.org
Krebs, B. (2017). Equifax Breach Analysis. Available at: https://krebsonsecurity.com
Uber Security Incident Report (2016). Available at: https://www.uber.com/newsroom
Facebook Engineering Security Report (2018). Available at: https://engineering.fb.com/security/