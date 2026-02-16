---
id: domain-04
number: "04"
name: Security
owner_agents: [security-engineer]
---

## Overview

This domain covers authentication, authorization, secrets management, injection vulnerabilities, dependency security, cryptography implementation, supply chain risk, and trust boundary enforcement. Security failures represent existential risks to systems and organizations. This domain focuses on preventing unauthorized access, data breaches, and exploitation of code vulnerabilities. Does NOT cover compliance or privacy regulations (domain 05), security testing methodologies (domain 06), or infrastructure security outside the codebase scope.

## Audit Questions

- Are authentication mechanisms resistant to common attacks like credential stuffing and session hijacking?
- Is authorization enforced consistently at all access points, or can it be bypassed?
- Are secrets stored outside the codebase and rotated regularly?
- Are all external inputs sanitized to prevent injection attacks?
- Are dependencies scanned for known vulnerabilities and updated promptly?
- Is cryptography implemented using vetted libraries rather than custom implementations?
- Are supply chain dependencies verified for integrity and provenance?
- Are trust boundaries clearly defined and enforced between system components?
- Is the principle of least privilege applied to service accounts and API keys?
- Are sensitive data (PII, credentials, tokens) excluded from logs and error messages?
- Do API endpoints require authentication by default, with public access as explicit exception?
- Are rate limits and input size restrictions enforced to prevent resource exhaustion?
- Is secure communication (TLS) enforced for all network traffic?
- Are file uploads validated for type, size, and content to prevent malicious payloads?
- Is Cross-Site Request Forgery (CSRF) protection enabled for state-changing operations?

## Failure Patterns

### Broken Authentication
- **Description:** Authentication mechanisms are weak, misconfigured, or bypassable, allowing unauthorized access to protected resources.
- **Indicators:**
  - No password complexity requirements or rate limiting on login
  - Session tokens that don't expire or can be reused indefinitely
  - Authentication logic that can be bypassed with crafted requests
  - Credentials transmitted over unencrypted connections
  - Default credentials not changed in production deployments
  - Authentication state stored client-side without integrity checks
  - Missing multi-factor authentication for privileged accounts
- **Severity Tendency:** critical

### Injection Vulnerabilities
- **Description:** Untrusted input is concatenated into queries or commands, allowing attackers to execute arbitrary code or access unauthorized data.
- **Indicators:**
  - SQL queries constructed with string concatenation
  - Shell commands built from user input without escaping
  - XML/JSON parsers processing untrusted input without validation
  - Template rendering with user input in executable contexts
  - LDAP/NoSQL queries using string interpolation
  - Regular expressions constructed from user input (ReDoS risk)
  - Eval-like functions processing external data
- **Severity Tendency:** critical

### Hardcoded Secrets
- **Description:** Credentials, API keys, or cryptographic keys are embedded directly in source code, making them visible to anyone with repository access.
- **Indicators:**
  - Database passwords in configuration files
  - API keys in source code or commit history
  - Private keys checked into version control
  - Encryption keys defined as string literals
  - OAuth client secrets in client-side code
  - JWT signing keys in application code
  - AWS access keys in environment variable defaults
- **Severity Tendency:** critical

### Missing Authorization Checks
- **Description:** Authorization is not enforced consistently, allowing users to access resources or perform actions beyond their privilege level.
- **Indicators:**
  - API endpoints that validate authentication but not authorization
  - Direct object references without ownership verification
  - Authorization checks only in UI layer, not backend
  - Privilege escalation possible through parameter tampering
  - Inconsistent enforcement of role-based access control
  - Authorization logic duplicated rather than centralized
  - Missing checks on secondary code paths or error handlers
- **Severity Tendency:** critical

### Dependency Vulnerabilities
- **Description:** Third-party libraries and frameworks contain known security vulnerabilities that are exploitable in the application context.
- **Indicators:**
  - Dependencies not updated for months or years
  - High or critical CVEs in direct or transitive dependencies
  - No automated dependency scanning in CI/CD pipeline
  - Outdated framework versions missing security patches
  - Dependencies from untrusted or unmaintained sources
  - Large dependency trees with unknown provenance
  - No software bill of materials (SBOM) tracking
- **Severity Tendency:** high

### Cryptography Misuse
- **Description:** Cryptographic operations use weak algorithms, insecure modes, or are implemented incorrectly, undermining security guarantees.
- **Indicators:**
  - Use of MD5, SHA1, or other deprecated hash functions for security
  - ECB mode for symmetric encryption
  - Custom cryptography implementations instead of vetted libraries
  - Hard-coded initialization vectors (IVs) or salts
  - Insufficient key lengths (e.g., RSA <2048 bits)
  - Missing or weak random number generation for security contexts
  - Password hashing without proper salting or key derivation functions
- **Severity Tendency:** high

### Insufficient Input Sanitization
- **Description:** User input is not properly validated, encoded, or sanitized before use, creating vectors for cross-site scripting, path traversal, and other attacks.
- **Indicators:**
  - User input directly rendered in HTML without escaping
  - File paths constructed from user input without validation
  - URL redirects accepting arbitrary destinations
  - File uploads without type/content validation
  - No size limits on input fields enabling DoS attacks
  - User-controlled data in security-sensitive contexts (cookies, headers)
  - Missing output encoding for context (HTML, URL, JavaScript)
- **Severity Tendency:** high

### Missing Trust Boundaries
- **Description:** Components trust data or actions from other components without validation, allowing compromise to spread laterally across system boundaries.
- **Indicators:**
  - Internal APIs assuming all calls are legitimate
  - Microservices that don't authenticate peer requests
  - Database queries trusting data from message queues
  - Frontend code trusting backend responses without validation
  - Service-to-service communication without mutual TLS
  - Shared secrets across multiple trust zones
  - No network segmentation between application tiers
- **Severity Tendency:** high

## Best Practice Patterns

### Robust Authentication
- **Replaces Failure Pattern:** Broken Authentication
- **Abstract Pattern:** Implement multi-layered authentication using industry-standard protocols, enforce strong credentials, protect session integrity, and apply defense-in-depth with rate limiting and monitoring.
- **Framework Mappings:**
  - OAuth 2.0 / OpenID Connect: Delegated authentication with token-based access
  - Passport.js: Strategy-based authentication for Node.js applications
  - Spring Security: Comprehensive authentication and authorization for Java
- **Language Patterns:**
  - Python: Flask-Login or Django authentication with bcrypt password hashing
  - Go: JWT middleware with RS256 signing and refresh token rotation
  - .NET: ASP.NET Identity with configurable password policies and lockout

### Parameterized Queries
- **Replaces Failure Pattern:** Injection Vulnerabilities
- **Abstract Pattern:** Use prepared statements, parameterized queries, or ORM abstractions that separate code from data, preventing injection of executable commands.
- **Framework Mappings:**
  - SQLAlchemy: ORM with bound parameters for Python database access
  - JDBC PreparedStatement: Parameterized queries for Java SQL
  - Entity Framework: LINQ queries with automatic parameterization
- **Language Patterns:**
  - JavaScript: Parameterized queries with `pg` or `mysql2` libraries
  - PHP: PDO with prepared statements and bound parameters
  - Ruby: ActiveRecord with query parameter binding

### Externalized Secrets Management
- **Replaces Failure Pattern:** Hardcoded Secrets
- **Abstract Pattern:** Store secrets in dedicated secret management systems, inject them at runtime, rotate them regularly, and never commit them to version control.
- **Framework Mappings:**
  - HashiCorp Vault: Centralized secret storage with dynamic secrets
  - AWS Secrets Manager: Cloud-native secret rotation and access control
  - Kubernetes Secrets: Encrypted secret distribution to pods
- **Language Patterns:**
  - Python: Environment variable loading with `python-dotenv` and validation
  - Go: Secret injection via environment variables with `viper` configuration
  - Node.js: `dotenv` for development, cloud secret managers for production

### Centralized Authorization
- **Replaces Failure Pattern:** Missing Authorization Checks
- **Abstract Pattern:** Enforce authorization through a single decision point using attribute-based or role-based access control, applied consistently across all entry points.
- **Framework Mappings:**
  - Casbin: Policy-based authorization engine supporting RBAC, ABAC
  - AWS IAM: Role and policy-based authorization for cloud resources
  - Open Policy Agent (OPA): General-purpose policy engine for microservices
- **Language Patterns:**
  - Python: Decorators for route-level authorization checks
  - Java: Aspect-oriented programming for method-level security annotations
  - TypeScript: Middleware chains enforcing authorization before handlers

### Automated Dependency Scanning
- **Replaces Failure Pattern:** Dependency Vulnerabilities
- **Abstract Pattern:** Continuously scan dependencies for known vulnerabilities, automate updates for security patches, and maintain a software bill of materials.
- **Framework Mappings:**
  - Dependabot: Automated dependency updates for GitHub repositories
  - Snyk: Vulnerability scanning with remediation guidance
  - OWASP Dependency-Check: SCA tool for detecting vulnerable dependencies
- **Language Patterns:**
  - npm: `npm audit` with automated fix suggestions
  - Maven: OWASP Dependency-Check plugin in build lifecycle
  - Go: `govulncheck` for vulnerability detection in Go modules

### Vetted Cryptography Libraries
- **Replaces Failure Pattern:** Cryptography Misuse
- **Abstract Pattern:** Use well-maintained cryptographic libraries implementing current standards, avoid custom implementations, and follow secure configuration guidelines.
- **Framework Mappings:**
  - libsodium: Modern cryptography library with safe defaults
  - AWS KMS: Managed cryptographic key storage and operations
  - Bouncy Castle: Comprehensive cryptography library for Java/.NET
- **Language Patterns:**
  - Python: `cryptography` library with high-level recipes
  - Node.js: Native `crypto` module with secure random and modern algorithms
  - Rust: `ring` or `RustCrypto` for memory-safe cryptographic operations

### Context-Aware Input Validation
- **Replaces Failure Pattern:** Insufficient Input Sanitization
- **Abstract Pattern:** Validate input against expected schemas at entry points, sanitize for specific output contexts (HTML, SQL, shell), and enforce size and rate limits.
- **Framework Mappings:**
  - OWASP Java Encoder: Context-specific output encoding library
  - DOMPurify: HTML sanitization for browser environments
  - bleach: HTML sanitization for Python web applications
- **Language Patterns:**
  - JavaScript: Template literals with automatic escaping in modern frameworks
  - Go: `html/template` package with automatic HTML escaping
  - PHP: `htmlspecialchars()` with appropriate flags for context

### Defense in Depth Boundaries
- **Replaces Failure Pattern:** Missing Trust Boundaries
- **Abstract Pattern:** Validate and authenticate at every trust boundary, use network segmentation, encrypt inter-service communication, and apply least privilege principles.
- **Framework Mappings:**
  - Mutual TLS: Certificate-based authentication for service-to-service communication
  - Service Mesh (Istio/Linkerd): Automatic encryption and authentication between services
  - Zero Trust Architecture: Explicit verification at every access point
- **Language Patterns:**
  - gRPC: Built-in TLS and token-based authentication between services
  - REST: API gateways enforcing authentication and rate limiting
  - Message Queues: ACLs and encryption for inter-component messaging

## Red Flags

- Database query strings built with concatenation or template literals
- API keys or passwords visible in source code or configuration files
- Authentication cookies without HttpOnly, Secure, or SameSite flags
- Admin interfaces accessible without additional authentication layers
- Dependency versions pinned to outdated releases with known CVEs
- Use of `eval()` or similar dynamic code execution with external input
- File upload functionality without type/size validation
- Error messages exposing stack traces or internal paths to users
- HTTP endpoints handling sensitive data without TLS
- Authorization checks only on client side or in UI logic
- Cryptographic operations using MD5, SHA1, or DES
- Session tokens generated with predictable patterns
- CORS policies allowing all origins (`Access-Control-Allow-Origin: *`)
- Deserialization of untrusted data without type validation
- Missing rate limiting on authentication or resource-intensive endpoints

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| Semgrep | Injection patterns, hardcoded secrets, crypto misuse | primary |
| Gitleaks | Secrets in code and commit history | primary |
| Trivy | Container and filesystem vulnerability scanning | primary |
| Syft+Grype | SBOM generation and dependency vulnerability matching | supporting |
| SonarQube | Security hotspots, authentication logic issues | supporting |
| Checkov | Infrastructure-as-code security misconfigurations | contextual |

## Standards & Frameworks

- OWASP Top 10: Industry-standard classification of web application security risks
- CWE/SANS Top 25: Most dangerous software weaknesses with mitigation guidance
- NIST SP 800-53: Security controls for federal information systems (widely adopted)
- OWASP ASVS: Application Security Verification Standard for testing requirements
- NIST Cybersecurity Framework: Risk management framework applicable to application security
- MITRE ATT&CK: Adversary tactics and techniques for threat modeling
- PCI DSS: Payment card industry security standards for systems handling card data

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Critical CVE Count | Number of critical vulnerabilities in dependencies | 0 |
| Secrets Detected | Hardcoded secrets found by scanning tools | 0 |
| Input Validation Coverage | Percentage of external entry points with validation | >95% |
| Auth Centralization Ratio | Proportion of endpoints using centralized auth vs. custom | >90% centralized |
| Mean Time to Patch (MTTP) | Average time from CVE disclosure to deployment of patch | <7 days for critical, <30 days for high |
| Security Test Coverage | Percentage of security requirements validated by automated tests | >80% |
