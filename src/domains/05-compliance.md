---
id: domain-05
number: "05"
name: Compliance Privacy & Governance
owner_agents: [compliance-officer]
---

## Overview

This domain addresses PII handling, data classification, retention policies, encryption standards, audit logging, consent tracking, and regulatory exposure. Compliance failures lead to fines, lawsuits, operational shutdowns, and reputational damage. Senior engineers recognize that compliance is not optional and must be embedded in system design from the start. This domain does NOT cover general security vulnerabilities (domain 04), architectural patterns (domain 01), or operational monitoring concerns (domain 10).

## Audit Questions

- Are all PII fields explicitly classified with data sensitivity labels in schema definitions or documentation?
- Does the codebase implement data retention policies with automated expiration for different data classifications?
- Is sensitive data encrypted at rest using industry-standard algorithms with proper key management?
- Are all sensitive data transmissions protected by TLS 1.2+ or equivalent transport encryption?
- Does the system maintain comprehensive audit logs capturing access, modification, and deletion of sensitive data?
- Is user consent explicitly tracked and stored with timestamps, scope, and version information?
- Can users request complete data deletion, and does the system enforce cascading deletion across all storage layers?
- Are access controls on PII enforced at the data layer with role-based or attribute-based policies?
- Does the system handle cross-border data transfers in compliance with regional data sovereignty requirements?
- Are third-party data sharing agreements documented, and is shared data minimized to necessary fields only?
- Can the system generate audit reports demonstrating compliance with relevant regulations (GDPR, CCPA, HIPAA)?
- Are data breach notification procedures documented and testable?

## Failure Patterns

### Unclassified PII
- **Description:** Personally identifiable information stored without explicit classification, sensitivity labels, or handling requirements. Fields containing names, emails, addresses, phone numbers, or financial data lack metadata indicating regulatory scope or protection requirements.
- **Indicators:**
  - Database schemas or ORMs define user-related fields without sensitivity annotations or comments
  - No centralized PII inventory mapping fields to regulatory frameworks (GDPR Article 4, CCPA 1798.140)
  - Code comments or documentation do not distinguish PII from non-sensitive data
  - API responses return user data without filtering based on data classification policies
  - Search or analytics systems index PII fields without classification-aware controls
- **Severity Tendency:** high

### Missing Data Retention Policy
- **Description:** System lacks automated enforcement of data retention periods, leading to indefinite storage of user data beyond legal or business requirements. No scheduled deletion or archival processes exist for expired data.
- **Indicators:**
  - No TTL (time-to-live) configurations on database records or object storage buckets
  - Absence of cron jobs, scheduled tasks, or event-driven workflows for data expiration
  - Backup systems retain data indefinitely without retention period enforcement
  - No documented retention periods per data classification in technical specifications
  - User account deletion does not trigger cascading deletion of associated historical data
- **Severity Tendency:** high

### Unencrypted Sensitive Data
- **Description:** PII or regulated data stored in plaintext without encryption at rest. Disk-level encryption alone is insufficient; application-layer encryption is required for sensitive fields.
- **Indicators:**
  - Database columns containing passwords, SSNs, credit card numbers, or health records stored as plaintext strings
  - Configuration files, environment variables, or secrets management systems expose sensitive data unencrypted
  - File storage (S3, GCS, Azure Blob) lacks server-side encryption or customer-managed keys
  - Log files or error messages contain plaintext sensitive data
  - Backups and snapshots do not use encrypted storage with separate key management
- **Severity Tendency:** critical

### Missing Audit Trail
- **Description:** System does not log access, modification, or deletion events for sensitive data, preventing investigation of data breaches or compliance audits. Audit logs are absent, incomplete, or not tamper-evident.
- **Indicators:**
  - No logging for read operations on PII fields (user profiles, payment data, health records)
  - Database triggers or ORM hooks do not capture UPDATE or DELETE operations on sensitive tables
  - Application logs omit user identity, timestamp, operation type, or affected record identifiers
  - Audit logs are stored in mutable locations without integrity verification (hashing, blockchain, write-once storage)
  - No centralized audit log aggregation or retention separate from application logs
- **Severity Tendency:** high

### No Consent Tracking
- **Description:** System does not record explicit user consent for data collection, processing, or sharing. Consent records lack timestamps, version information, or scope details required by GDPR Article 7 and CCPA 1798.120.
- **Indicators:**
  - User account creation does not store consent agreements with version identifiers and acceptance timestamps
  - Marketing preferences, analytics opt-ins, or third-party data sharing lack granular consent records
  - No mechanism to withdraw consent or update preferences retroactively
  - Terms of service or privacy policy changes do not trigger re-consent workflows
  - Consent records are stored in session state or cookies rather than persistent, auditable storage
- **Severity Tendency:** high

### Incomplete Data Deletion
- **Description:** User data deletion requests do not cascade across all storage layers, leaving orphaned records in caches, backups, analytics systems, or third-party integrations. Right-to-be-forgotten (GDPR Article 17) cannot be fully satisfied.
- **Indicators:**
  - Soft-delete patterns mark records as inactive but do not purge data from primary storage
  - CDN caches, Redis/Memcached, or search indexes retain deleted user data
  - Backup restoration procedures do not exclude deleted user records
  - Third-party analytics (Google Analytics, Mixpanel), CRMs, or email platforms retain data after account deletion
  - No documented data deletion verification process or automated reconciliation checks
- **Severity Tendency:** high

### Missing Access Controls on PII
- **Description:** PII is accessible to unauthorized roles, services, or processes due to insufficient role-based access control (RBAC) or attribute-based access control (ABAC). Data layer permissions are too broad or unenforced.
- **Indicators:**
  - Database users or service accounts have SELECT privileges on PII tables without business justification
  - API endpoints return PII fields without authentication or authorization checks
  - Internal admin tools expose PII to non-compliance-trained personnel
  - No column-level security or field-level encryption separating PII access from general application access
  - Lack of principle-of-least-privilege enforcement in IAM policies or database grants
- **Severity Tendency:** high

## Best Practice Patterns

### Explicit PII Classification
- **Replaces Failure Pattern:** Unclassified PII
- **Abstract Pattern:** Annotate all data fields with sensitivity classifications at the schema level, enabling automated policy enforcement and audit trail generation. Maintain a centralized PII inventory mapping fields to regulatory frameworks.
- **Framework Mappings:**
  - **Django ORM:** Use custom field metadata (e.g., `field.help_text = "PII: GDPR Art. 4"`) or third-party packages like `django-fernet-fields` with classification decorators.
  - **Spring Boot (JPA):** Apply custom annotations (`@PII(classification = "sensitive")`) on entity fields, enforced by aspect-oriented programming (AOP) interceptors.
  - **TypeORM:** Use column comment metadata (`@Column({ comment: "PII: email, CCPA covered" })`) combined with schema validation tools.
- **Language Patterns:**
  - **Python:** Use dataclass metadata (`field(metadata={"pii": "email", "regulation": "GDPR"})`) with runtime validation.
  - **Java:** Leverage JSR-303 annotations (`@Sensitive(category = "PII", regulation = "HIPAA")`) with bean validation integration.
  - **TypeScript:** Apply decorator metadata (`@PII({ type: "email", retention: "7y" })`) with reflection-based policy engines.

### Automated Retention Enforcement
- **Replaces Failure Pattern:** Missing Data Retention Policy
- **Abstract Pattern:** Implement time-based data expiration at the storage layer using TTL configurations, scheduled purge jobs, or event-driven deletion workflows. Document retention periods per data classification and automate enforcement.
- **Framework Mappings:**
  - **PostgreSQL:** Use `pg_cron` extension to schedule DELETE operations with WHERE clauses on timestamp columns (`created_at < NOW() - INTERVAL '7 years'`).
  - **MongoDB:** Apply TTL indexes on timestamp fields (`db.collection.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 220752000 })`).
  - **AWS S3:** Configure lifecycle policies with expiration rules for object age or versioning-based retention.
- **Language Patterns:**
  - **Python:** Use Celery beat schedules or APScheduler to trigger periodic deletion tasks via ORM queries.
  - **Java:** Implement `@Scheduled` methods in Spring Boot to execute retention policy enforcement via batch processing.
  - **Node.js:** Use cron libraries (`node-cron`) to invoke Sequelize or TypeORM bulk delete operations on expired records.

### Application-Layer Encryption
- **Replaces Failure Pattern:** Unencrypted Sensitive Data
- **Abstract Pattern:** Encrypt sensitive fields at the application layer using AES-256 or equivalent algorithms with customer-managed keys stored in dedicated secrets management systems. Ensure encryption at rest is separate from disk-level encryption.
- **Framework Mappings:**
  - **Django:** Use `django-fernet-fields` or `django-cryptography` to transparently encrypt model fields with key rotation support.
  - **Rails:** Apply `attr_encrypted` gem with AES-256-GCM and key storage in AWS KMS or HashiCorp Vault.
  - **Laravel:** Use `laravel-encrypted-model` trait with `APP_KEY`-based encryption or external key management integration.
- **Language Patterns:**
  - **Python:** Use `cryptography.fernet` for symmetric encryption with PBKDF2-derived keys stored in AWS Secrets Manager.
  - **Java:** Leverage `javax.crypto.Cipher` with AES/GCM/NoPadding mode and key retrieval via Spring Cloud Config.
  - **Go:** Apply `crypto/aes` with GCM mode and key management via HashiCorp Vault or Google Secret Manager.

### Comprehensive Audit Logging
- **Replaces Failure Pattern:** Missing Audit Trail
- **Abstract Pattern:** Log all access, modification, and deletion events for sensitive data to immutable, centralized storage. Include user identity, timestamp, operation type, affected record identifiers, and integrity verification.
- **Framework Mappings:**
  - **Django:** Use `django-auditlog` or `django-simple-history` with post-save/post-delete signals to capture changes with user context.
  - **Spring Boot:** Apply `@EnableJpaAuditing` with `AuditorAware` beans and custom event listeners for sensitive entity operations.
  - **Sequelize:** Use model hooks (`afterFind`, `afterUpdate`, `afterDestroy`) combined with Winston or Bunyan loggers.
- **Language Patterns:**
  - **Python:** Integrate SQLAlchemy event listeners (`@event.listens_for`) with structured logging (structlog) to centralized sinks (ELK, Splunk).
  - **Java:** Use Hibernate interceptors or JPA entity listeners to capture CRUD operations, published to Kafka or CloudWatch Logs.
  - **JavaScript:** Apply Mongoose middleware (`pre`/`post` hooks) with immutable log storage in AWS CloudWatch or Azure Monitor.

### Granular Consent Management
- **Replaces Failure Pattern:** No Consent Tracking
- **Abstract Pattern:** Store explicit user consent records with timestamps, version identifiers, scope details, and withdrawal mechanisms. Support consent history and granular opt-in/opt-out per data processing purpose.
- **Framework Mappings:**
  - **Custom Consent Service:** Build dedicated consent microservice with versioned consent documents, user consent snapshots, and audit trail integration.
  - **Django:** Use custom models (`ConsentRecord`) with foreign keys to users, consent document versions, and timestamp fields, queryable for compliance reports.
  - **Firestore/DynamoDB:** Store consent records as nested documents with composite keys (user_id + consent_type + version) for efficient querying.
- **Language Patterns:**
  - **Python:** Define Pydantic models for consent records with validation rules (required fields: user_id, consent_type, version, timestamp, scope).
  - **Java:** Use JPA entities with composite primary keys and temporal tables for consent history tracking.
  - **TypeScript:** Apply Zod schemas for consent payloads with strict validation and versioned API endpoints.

### Cascading Data Deletion
- **Replaces Failure Pattern:** Incomplete Data Deletion
- **Abstract Pattern:** Implement comprehensive deletion workflows that purge user data across all storage layers: primary databases, caches, backups, analytics systems, and third-party integrations. Verify deletion with automated reconciliation checks.
- **Framework Mappings:**
  - **Event-Driven Architecture:** Publish user deletion events to message queues (Kafka, RabbitMQ) with subscribers for each storage layer (database, Redis, S3, third-party APIs).
  - **Django Signals:** Use `post_delete` signals with chained deletion tasks via Celery to purge caches, invalidate sessions, and call third-party deletion APIs.
  - **Saga Pattern:** Implement distributed deletion workflows with compensating transactions for rollback on partial failures.
- **Language Patterns:**
  - **Python:** Use Celery chains or groups to orchestrate deletion tasks across multiple storage backends with idempotent retry logic.
  - **Java:** Implement Spring Batch jobs for bulk deletion with step listeners for cache invalidation and third-party API calls.
  - **Node.js:** Use Bull queues with job dependencies to sequence deletion operations (database → cache → analytics → backup).

### Field-Level Access Control
- **Replaces Failure Pattern:** Missing Access Controls on PII
- **Abstract Pattern:** Enforce role-based or attribute-based access control at the data layer, restricting PII access to authorized roles and services only. Apply column-level security or field-level encryption with separate key access policies.
- **Framework Mappings:**
  - **PostgreSQL Row-Level Security:** Define RLS policies restricting SELECT/UPDATE/DELETE on PII columns based on session user roles (`USING (has_pii_access(current_user))`).
  - **Django Guardian:** Apply object-level permissions with custom permission checks on model fields, enforced in serializers or views.
  - **GraphQL:** Use field-level resolvers with authorization middleware (e.g., `@auth(requires: "PII_READ")`) to conditionally expose PII fields.
- **Language Patterns:**
  - **Python:** Implement Django REST Framework serializer mixins that filter PII fields based on `request.user.has_perm('view_pii')` checks.
  - **Java:** Use Spring Security method-level annotations (`@PreAuthorize("hasRole('COMPLIANCE_OFFICER')")`) on service methods returning PII.
  - **JavaScript:** Apply Express.js middleware or NestJS guards to intercept requests and redact PII fields based on JWT claims or session roles.

## Red Flags

- Database schemas contain fields like `ssn`, `credit_card`, `passport_number` without encryption or classification comments
- User deletion endpoints return HTTP 200 but only soft-delete records, leaving data in backups and caches
- No documented data retention policies or scheduled deletion jobs in codebase
- Audit logs stored in same database as application data, vulnerable to tampering
- Consent tracking implemented with boolean flags (`marketing_opt_in`) without timestamps or version history
- Third-party analytics scripts loaded without consent verification checks
- Admin panels expose full PII datasets to non-compliance-trained personnel
- API responses return full user objects with PII to frontend clients without field filtering
- Encryption keys stored in application code or environment variables without rotation mechanisms
- GDPR/CCPA compliance documentation missing from repository or outdated

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| Semgrep | PII exposure patterns, unencrypted storage, missing audit logs | primary |
| Gitleaks | Hardcoded secrets, encryption keys, API tokens in code | supporting |
| Checkov | IaC misconfigurations (unencrypted S3, public RDS, missing KMS) | supporting |
| Trivy | Dependency vulnerabilities in encryption libraries, secrets in containers | contextual |
| SonarQube | Code smells in data handling logic, complexity in consent workflows | contextual |
| git-history | Historical exposure of PII in commits, deleted but recoverable secrets | contextual |

## Standards & Frameworks

- **GDPR (General Data Protection Regulation):** Articles 4 (definitions), 7 (consent), 17 (right to erasure), 32 (security of processing)
- **CCPA (California Consumer Privacy Act):** Sections 1798.100 (consumer rights), 1798.120 (opt-out), 1798.140 (definitions)
- **HIPAA (Health Insurance Portability and Accountability Act):** Security Rule (encryption, access controls, audit logging)
- **SOC 2 Type II:** Trust Services Criteria for confidentiality, privacy, and availability
- **PCI-DSS (Payment Card Industry Data Security Standard):** Requirements 3 (protect stored data), 4 (encrypt transmission), 10 (track and monitor access)
- **ISO/IEC 27701:** Privacy Information Management System (PIMS) extension to ISO 27001
- **NIST Privacy Framework:** Core functions (identify, govern, control, communicate, protect)

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| PII Field Classification Coverage | Percentage of database columns containing PII that are explicitly classified with sensitivity labels | ≥95% |
| Encryption-at-Rest Coverage | Percentage of PII fields using application-layer encryption (not just disk encryption) | 100% |
| Audit Log Completeness | Percentage of PII access/modification operations captured in tamper-evident audit logs | ≥99% |
| Retention Policy Compliance | Percentage of data classifications with automated retention enforcement (TTL, scheduled purge) | 100% |
| Consent Record Integrity | Percentage of user accounts with complete consent records (timestamp, version, scope) | ≥98% |
| Data Deletion Verification Rate | Percentage of deletion requests successfully verified across all storage layers within SLA | ≥95% |
