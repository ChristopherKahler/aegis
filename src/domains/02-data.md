---
id: domain-02
number: "02"
name: Data & State Integrity
owner_agents: [data-engineer]
---

## Overview

Covers data models, schema evolution, migrations, referential integrity, consistency guarantees, and state transition safety. Most catastrophic failures are data bugs, not code bugs — corrupt state, irreversible migrations, silent data loss, and inconsistent derived data can cause damage that outlasts any code fix.

Scope: schema design and evolution, migration strategy, referential integrity enforcement, state machine correctness, data validation at system boundaries, backup and recovery strategies, and data lifecycle management. Does NOT cover data security or privacy (domains 04, 05), performance of data access patterns (domain 08), or business logic correctness that happens to involve data (domain 03).

## Audit Questions

- Are data models explicitly defined (ORM models, schema files, type definitions), or is the schema implicit in code?
- Is there a versioned migration strategy, and are migrations reversible?
- Are referential integrity constraints enforced at the database level, application level, or both?
- Are state machines explicit with defined transitions, or are state changes scattered across the codebase?
- Is input data validated at system boundaries before entering the data layer?
- What is the backup and recovery strategy, and has it been tested?
- Are there orphaned records or data consistency issues that accumulate over time?
- How is schema evolution handled for API contracts (versioning, backward compatibility)?
- Is there a data lifecycle policy (retention, archival, deletion)?
- Are derived/computed data stores (caches, materialized views, denormalized tables) kept consistent with source data?
- What happens to in-flight data during deployments or schema migrations?

## Failure Patterns

### Schema Drift

- **Description:** The actual database schema has diverged from what the application code expects, causing runtime errors, data corruption, or silent data loss.
- **Indicators:**
  - Migration files that don't match the current database state
  - ORM model definitions inconsistent with actual table schemas
  - Queries that reference columns or tables that may not exist in all environments
  - Manual schema changes applied directly to production without migration files
- **Severity Tendency:** critical

### Missing Migrations

- **Description:** Schema changes are applied manually or through ad-hoc scripts rather than through a versioned, repeatable migration system.
- **Indicators:**
  - No migration directory or migration tool configured
  - SQL scripts named with dates or "fix_" prefixes applied manually
  - Different environments have different schema states
  - Schema changes require coordination calls or runbooks
- **Severity Tendency:** high

### Inconsistent State Machines

- **Description:** Entity state transitions are managed through scattered conditional logic rather than an explicit state machine, allowing invalid transitions and orphaned states.
- **Indicators:**
  - Status fields with string values set in multiple locations across the codebase
  - No validation of state transitions (e.g., "completed" directly from "draft" skipping "in_progress")
  - Dead states — status values that exist in the database but no code path produces them
  - Business logic that checks status with long if/else chains instead of state machine patterns
- **Severity Tendency:** high

### Data Validation Gaps

- **Description:** User input or external data enters the system without proper validation, allowing malformed, out-of-range, or structurally invalid data to persist in storage.
- **Indicators:**
  - No validation middleware or schema validation library in the request pipeline
  - Database columns without constraints (nullable when shouldn't be, no length limits, no check constraints)
  - Tests that only use well-formed data — no edge case or boundary testing
  - Error reports showing unexpected data types or formats in database records
- **Severity Tendency:** high

### Orphaned Records

- **Description:** Related records become disconnected due to missing cascade deletes, soft-delete inconsistencies, or partial transaction failures, leaving data that references nonexistent parents.
- **Indicators:**
  - Foreign keys without ON DELETE behavior defined
  - Soft-delete implementation that doesn't propagate to related records
  - Cleanup scripts or cron jobs that exist to "fix" orphaned data
  - Queries with LEFT JOINs where INNER JOINs would be semantically correct (defensive coding around orphans)
- **Severity Tendency:** medium

### Implicit Schema

- **Description:** The data model has no explicit definition — the schema exists only as an emergent property of the code that reads and writes data, common in NoSQL or dynamic-language systems.
- **Indicators:**
  - Document databases (MongoDB, DynamoDB) used without schema validation
  - Dynamic object properties added at various points in the codebase
  - No TypeScript interfaces, JSON Schema, or Pydantic models for data structures
  - Different code paths write different fields to the same collection/table
- **Severity Tendency:** high

### Race Conditions in State Transitions

- **Description:** Concurrent operations can cause state corruption because state reads and writes are not atomic, leading to lost updates, duplicate processing, or invalid state combinations.
- **Indicators:**
  - Read-then-write patterns without locking or optimistic concurrency control
  - No unique constraints or idempotency keys on operations that should be atomic
  - Race condition bugs in production history (double charges, duplicate records)
  - State updates using UPDATE without WHERE clause checking current state
- **Severity Tendency:** critical

## Best Practice Patterns

### Versioned Migrations

- **Replaces Failure Pattern:** Missing Migrations
- **Abstract Pattern:** Every schema change is captured as a versioned, ordered, idempotent migration file that can be applied forward and (where possible) rolled back. The migration history is the authoritative record of schema evolution.
- **Framework Mappings:**
  - Rails: ActiveRecord migrations with `db:migrate` and `db:rollback` — timestamped, reversible, tracked in `schema_migrations` table
  - Django: `makemigrations` + `migrate` — auto-generated from model changes, dependency-tracked
  - Laravel: Artisan migrations with `up()` and `down()` methods, batch-tracked
- **Language Patterns:**
  - Node.js: Knex migrations or Prisma Migrate with explicit up/down SQL
  - Go: golang-migrate or Atlas with versioned SQL files and checksum verification

### Schema-Code Synchronization

- **Replaces Failure Pattern:** Schema Drift
- **Abstract Pattern:** The database schema and application code are kept in sync through automated checks that detect divergence. Schema validation runs in CI to ensure the code's expectations match the actual database structure.
- **Framework Mappings:**
  - Prisma: `prisma db pull` + `prisma migrate diff` to detect drift between schema file and live database
  - Django: `makemigrations --check` in CI fails if model definitions don't match the current migration state
  - Flyway: `flyway validate` checks that applied migrations match the expected checksums and sequence
- **Language Patterns:**
  - Any: CI pipeline step that compares declared schema against actual database and fails on mismatch
  - TypeScript/Python: ORM schema introspection tools that generate drift reports as part of deployment checks

### Explicit State Machines

- **Replaces Failure Pattern:** Inconsistent State Machines
- **Abstract Pattern:** State transitions are modeled as a finite state machine with explicitly defined states, allowed transitions, guard conditions, and side effects. Invalid transitions are rejected, not silently ignored.
- **Framework Mappings:**
  - Ruby: `aasm` gem — declarative state machine DSL with events, guards, and callbacks
  - Python: `transitions` library — lightweight FSM with diagram generation
  - Laravel: `spatie/laravel-model-states` — type-safe state transitions with configurable transition classes
- **Language Patterns:**
  - TypeScript: Discriminated unions for states with exhaustive switch statements enforcing transition handling
  - Java/Kotlin: Enum-based state machines with transition methods that return `Optional<NextState>`

### Input Validation at Boundaries

- **Replaces Failure Pattern:** Data Validation Gaps
- **Abstract Pattern:** All data entering the system is validated at the boundary — API endpoints, message consumers, file parsers — using schema validation that rejects invalid data before it reaches business logic or persistence.
- **Framework Mappings:**
  - Express: `zod` or `joi` validation middleware applied at route level
  - Spring Boot: `@Valid` annotation with Bean Validation (JSR 380) on request DTOs
  - FastAPI: Pydantic models as request types — automatic validation and documentation
- **Language Patterns:**
  - TypeScript: Zod schemas that parse (not just type-check) incoming data: `const user = UserSchema.parse(req.body)`
  - Python: Pydantic models or `marshmallow` schemas at every external data entry point

### Referential Integrity Enforcement

- **Replaces Failure Pattern:** Orphaned Records
- **Abstract Pattern:** Relationships between records are enforced at the database level through foreign keys, cascade rules, and constraints — not solely through application logic. The database is the last line of defense for data consistency.
- **Framework Mappings:**
  - PostgreSQL: Foreign keys with explicit ON DELETE (CASCADE, SET NULL, RESTRICT) based on domain semantics
  - Rails: `dependent: :destroy` at the model level plus database-level foreign key constraints
  - Django: `on_delete` parameter (CASCADE, PROTECT, SET_NULL) on ForeignKey fields
- **Language Patterns:**
  - SQL: `ALTER TABLE ADD CONSTRAINT ... FOREIGN KEY ... ON DELETE CASCADE` for parent-owned children
  - Any ORM: Configure both ORM-level and database-level constraints — belt and suspenders approach

### Schema-First Data Modeling

- **Replaces Failure Pattern:** Implicit Schema
- **Abstract Pattern:** Data schemas are defined explicitly and centrally before code is written against them. The schema definition is the source of truth — code is generated from or validated against the schema, not the other way around.
- **Framework Mappings:**
  - Prisma: Schema file as single source of truth generating client, types, and migrations
  - Protocol Buffers / gRPC: .proto files defining data structures with code generation for all languages
  - JSON Schema: Central schema definition with runtime validation in document databases
- **Language Patterns:**
  - TypeScript: Zod schemas that generate TypeScript types: `type User = z.infer<typeof UserSchema>`
  - Python: Pydantic models serving as both validation and documentation for data structures

### Optimistic Concurrency Control

- **Replaces Failure Pattern:** Race Conditions in State Transitions
- **Abstract Pattern:** State modifications include a version check — each update verifies that the record hasn't changed since it was read. Conflicts are detected and surfaced rather than silently overwritten.
- **Framework Mappings:**
  - JPA/Hibernate: `@Version` annotation on a version column — automatic optimistic locking
  - Rails: `lock_version` column with built-in ActiveRecord optimistic locking
  - DynamoDB: Conditional writes using `ConditionExpression` to enforce atomic state transitions
- **Language Patterns:**
  - SQL: `UPDATE ... SET status = 'shipped', version = version + 1 WHERE id = ? AND version = ?` — zero affected rows means conflict
  - Any: Idempotency keys on write operations to safely retry without duplication

## Red Flags

- No migration directory or migration tool in the project
- Database columns with `TEXT` type where structured data is stored (JSON as unvalidated strings)
- Status fields with string type and no enum constraint
- Multiple code locations writing to the same table with different field assumptions
- Manual SQL scripts in a `fixes/` or `patches/` directory
- Foreign keys missing between obviously related tables
- No `created_at` / `updated_at` timestamps on tables that track entities
- Soft-delete (`deleted_at`) without corresponding query scoping
- NoSQL collections with no schema validation configured
- Data transformation logic scattered across controllers, services, and background jobs

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| sonarqube | Data flow analysis, detecting potential null dereferences and unvalidated data usage | contextual |
| semgrep | Pattern detection for SQL injection, unparameterized queries, missing validation, raw query construction | supporting |
| checkov | Infrastructure-as-code database configuration — encryption, backup, access controls | supporting |

## Standards & Frameworks

- Database normalization (1NF through BCNF) — structured approach to eliminating data redundancy and anomalies
- ACID properties — Atomicity, Consistency, Isolation, Durability as transaction correctness guarantees
- CAP theorem — Consistency, Availability, Partition tolerance trade-offs for distributed data systems
- Event Sourcing — Storing state as an append-only sequence of events for full auditability and replay
- CQRS (Command Query Responsibility Segregation) — Separating read and write models for data access optimization
- Schema evolution patterns (Avro, Protobuf) — Forward and backward compatible schema changes

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Migration count vs schema age | Ratio of migrations to system age (months) | ≥1 migration per month of active development |
| Orphan record percentage | Percentage of child records referencing nonexistent parents | 0% |
| Foreign key coverage | Percentage of relationships enforced by database-level foreign keys | >90% |
| Schema validation coverage | Percentage of external data entry points with schema validation | >95% |
| State machine explicitness | Percentage of stateful entities with formally defined state machines | >80% for entities with ≥3 states |
