---
id: domain-03
number: "03"
name: Correctness & Logic
owner_agents: [senior-app-engineer]
---

## Overview

This domain covers logic correctness, error propagation, edge case handling, concurrency safety, input validation, invariant enforcement, and idempotency. Most production incidents stem from mundane logic bugs rather than exotic failures. This domain focuses on whether the code does what it claims to do under all conditions, including edge cases, concurrent execution, and failure scenarios. Does NOT cover security vulnerabilities (domain 04), testing strategies (domain 06), or architectural patterns (domain 01).

## Audit Questions

- Are errors caught and propagated with sufficient context, or are they silently swallowed?
- Does the code handle edge cases like empty collections, boundary values, and null inputs?
- Are race conditions possible in concurrent access to shared state?
- Are critical assumptions documented and validated at runtime?
- Is input validation performed before business logic execution?
- Are invariants explicitly enforced at state transition boundaries?
- Can retry operations be safely executed multiple times without side effects?
- Does error handling follow a consistent pattern across the codebase?
- Are null/undefined values handled defensively throughout data flows?
- Are off-by-one errors prevented in loops, pagination, and range operations?
- Do concurrent operations maintain data consistency guarantees?
- Are temporal assumptions (ordering, timing) explicitly validated?

## Failure Patterns

### Swallowed Errors
- **Description:** Exceptions or error conditions are caught but not logged, propagated, or handled, causing silent failures that are difficult to diagnose in production.
- **Indicators:**
  - Empty catch blocks or catch blocks with only comments
  - Error handlers that return default values without logging
  - Promise rejections without .catch() handlers
  - Error objects created but never thrown or returned
  - try-catch wrapping entire functions without discrimination
- **Severity Tendency:** high

### Missing Edge Case Handling
- **Description:** Code assumes happy-path conditions and fails on boundary values, empty inputs, or unusual but valid data states.
- **Indicators:**
  - No validation for empty arrays before accessing elements
  - Division operations without zero checks
  - String operations without length validation
  - Loops that assume non-empty collections
  - Missing null/undefined checks before property access
  - Pagination logic that fails on single-page results
- **Severity Tendency:** medium

### Race Conditions
- **Description:** Concurrent operations on shared state produce inconsistent results due to timing-dependent execution order.
- **Indicators:**
  - Check-then-act patterns without synchronization
  - Shared mutable state accessed from multiple threads/async contexts
  - Database reads followed by writes without transactions
  - Cache invalidation logic that races with updates
  - Counter increments without atomic operations
  - File operations without locking mechanisms
- **Severity Tendency:** critical

### Implicit Assumptions
- **Description:** Code relies on undocumented assumptions about data shape, execution environment, or temporal conditions that may not hold.
- **Indicators:**
  - Missing assertions for preconditions
  - Array access without bounds checking
  - Type coercion without validation
  - Assumptions about API response structure without schema validation
  - Hard-coded constants derived from production data
  - Dependencies on execution order without enforcement
- **Severity Tendency:** high

### Missing Input Validation
- **Description:** External inputs are processed without validation, allowing invalid data to corrupt business logic or system state.
- **Indicators:**
  - API handlers that directly use request parameters
  - Database queries constructed from unvalidated input
  - File paths constructed from user input without sanitization
  - Numeric inputs used in calculations without range checks
  - Enum values not validated against allowed set
  - Date/time inputs without format validation
- **Severity Tendency:** high

### Non-Idempotent Retries
- **Description:** Retry logic can produce duplicate side effects because operations are not designed to be safely re-executed.
- **Indicators:**
  - Operations that create resources without uniqueness checks
  - Retry logic that increments counters multiple times
  - Payment processing without idempotency keys
  - Email sending in retry paths without deduplication
  - Database inserts in retry handlers without conflict resolution
  - Event publishing without delivery guarantees
- **Severity Tendency:** critical

### Inconsistent Error Propagation
- **Description:** Error handling patterns vary across the codebase, making it difficult to predict failure behavior and implement reliable error recovery.
- **Indicators:**
  - Mix of error codes, exceptions, and sentinel values
  - Some functions return errors, others throw exceptions
  - Inconsistent use of Result/Either types
  - Error messages lack context or stack traces
  - Different error formats from different modules
  - No standardized error hierarchy or taxonomy
- **Severity Tendency:** medium

## Best Practice Patterns

### Explicit Error Propagation
- **Replaces Failure Pattern:** Swallowed Errors
- **Abstract Pattern:** Every error should be logged with context and either handled locally with recovery logic or propagated to a caller capable of making handling decisions. Error handling should be explicit and traceable.
- **Framework Mappings:**
  - Express.js: Centralized error middleware with `next(error)` propagation
  - Spring Boot: `@ControllerAdvice` with exception hierarchies
  - FastAPI: Exception handlers with status code mapping
- **Language Patterns:**
  - Go: Explicit error returns with `if err != nil` checks and `fmt.Errorf` wrapping
  - Rust: Result<T, E> types with `?` operator for propagation
  - TypeScript: Either/Result types or explicit Promise rejection handling

### Defensive Edge Case Guards
- **Replaces Failure Pattern:** Missing Edge Case Handling
- **Abstract Pattern:** Validate boundary conditions, empty states, and null cases before executing business logic. Use guard clauses to fail fast with clear error messages.
- **Framework Mappings:**
  - Django: Model field validators with `clean()` methods
  - Rails: ActiveModel validations with custom validators
  - NestJS: ValidationPipe with class-validator decorators
- **Language Patterns:**
  - Python: Guard clauses with early returns and `assert` for invariants
  - Java: Optional<T> for nullable values with `orElseThrow()`
  - JavaScript: Nullish coalescing and optional chaining with validation

### Synchronized State Access
- **Replaces Failure Pattern:** Race Conditions
- **Abstract Pattern:** Use locks, atomic operations, or immutable data structures to ensure state consistency under concurrent access. Prefer isolation mechanisms provided by databases or message queues.
- **Framework Mappings:**
  - PostgreSQL: Serializable transactions with SELECT FOR UPDATE
  - Redis: MULTI/EXEC transactions or Lua scripts for atomicity
  - MongoDB: Document-level atomic operations with transactions
- **Language Patterns:**
  - Java: `synchronized` blocks or `java.util.concurrent` locks
  - Go: Mutexes (`sync.Mutex`) or channels for coordination
  - Rust: Arc<Mutex<T>> or lock-free atomic types

### Documented Preconditions
- **Replaces Failure Pattern:** Implicit Assumptions
- **Abstract Pattern:** Document assumptions as executable assertions or type constraints. Validate preconditions at function boundaries and invariants at state transitions.
- **Framework Mappings:**
  - DbC libraries: Contract-based programming with precondition/postcondition decorators
  - GraphQL: Schema validation enforcing structure assumptions
  - OpenAPI: Request/response schemas with strict validation
- **Language Patterns:**
  - TypeScript: Branded types and discriminated unions for compile-time guarantees
  - Python: Type hints with runtime validation via Pydantic
  - C++: Concepts and static assertions for template constraints

### Validated Input Boundaries
- **Replaces Failure Pattern:** Missing Input Validation
- **Abstract Pattern:** Validate all external inputs at system boundaries using schema validation or type systems before allowing data to flow into business logic.
- **Framework Mappings:**
  - Zod/Yup: Schema validation for JavaScript/TypeScript APIs
  - JSON Schema: Standardized validation across languages
  - Bean Validation: JSR-380 annotations for Java
- **Language Patterns:**
  - Rust: Type system ensures validation at compile time with newtype patterns
  - Elixir: Ecto changesets for data validation and casting
  - Scala: Refined types for compile-time constraint enforcement

### Idempotent Operations
- **Replaces Failure Pattern:** Non-Idempotent Retries
- **Abstract Pattern:** Design operations to produce the same outcome regardless of how many times they are executed. Use idempotency keys, conditional writes, or natural idempotence.
- **Framework Mappings:**
  - Stripe API: Idempotency-Key headers for payment operations
  - AWS S3: ETags for conditional writes
  - HTTP: PUT and DELETE methods with idempotent semantics
- **Language Patterns:**
  - SQL: INSERT ... ON CONFLICT DO NOTHING for safe retries
  - REST: Idempotency middleware checking request fingerprints
  - Event Sourcing: Append-only logs with deduplication on read

### Standardized Error Handling
- **Replaces Failure Pattern:** Inconsistent Error Propagation
- **Abstract Pattern:** Establish a single error handling strategy across the codebase with consistent error types, context propagation, and recovery patterns.
- **Framework Mappings:**
  - gRPC: Status codes with structured error details
  - Problem Details (RFC 7807): Standardized HTTP error responses
  - GraphQL: Errors array with extensions for context
- **Language Patterns:**
  - Go: Error wrapping with `fmt.Errorf("%w", err)` and `errors.Is()`
  - Java: Exception hierarchies with checked/unchecked distinction
  - Kotlin: Sealed classes for exhaustive error handling

## Red Flags

- Empty catch blocks or generic exception handlers without logging
- Array/list access with hardcoded indices like `items[0]`
- Division operations without denominator checks
- Check-then-act patterns: `if (exists) { use() }`
- Missing null checks before method calls or property access
- Retry logic that doesn't use idempotency keys or uniqueness constraints
- Error handling that varies between similar functions
- String parsing without format validation
- Numeric operations without overflow protection
- Assumptions about API response structure without validation
- Concurrent access to shared state without synchronization primitives
- Database operations outside transactions when consistency matters

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| SonarQube | Null pointer risks, complexity metrics, error handling gaps | primary |
| Semgrep | Logic patterns, validation missing, concurrency issues | primary |
| git-history | Logic change patterns, bug fix frequency in modules | contextual |

## Standards & Frameworks

- Defensive Programming Principles: Validate inputs, handle errors explicitly, fail fast
- Design by Contract (DbC): Preconditions, postconditions, invariants as first-class concerns
- CWE-703 (Improper Check or Handling of Exceptional Conditions): Industry classification of error handling failures
- ACID Properties: Atomicity, Consistency, Isolation, Durability for data correctness
- CAP Theorem Awareness: Understanding consistency trade-offs in distributed systems

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Bug Density (bugs per KLOC) | Logic defects found in production or testing per thousand lines | <0.5 for mature code, <2.0 for new features |
| Error Handling Coverage | Percentage of functions with explicit error handling paths | >90% |
| Cyclomatic Complexity (Hot Paths) | Decision point density in critical business logic | <10 per function in performance-critical or high-risk paths |
| Null Safety Violations | Potential null pointer dereferences detected by static analysis | 0 in critical paths, <5 per 10K LOC overall |
| Race Condition Density | Concurrent access issues per 1K LOC of concurrent code | <0.1 |
