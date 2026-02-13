---
id: domain-07
number: "07"
name: Reliability & Resilience
owner_agents: [sre]
---

## Overview

Covers failure handling, retry strategies, timeouts, circuit breakers, graceful degradation, and whether the system can survive real-world failure conditions. Production systems fail constantly — network partitions, dependency outages, resource exhaustion, deployment errors — and a well-designed system degrades gracefully rather than catastrophically.

Scope: error handling strategy, retry policies, timeout configuration, circuit breaker patterns, graceful degradation paths, health checks, failure isolation, recovery procedures, and startup/shutdown safety. Does NOT cover data integrity during failures (domain 02), correctness of error handling logic (domain 03), or deployment infrastructure (domain 10).

## Audit Questions

- Is there a consistent error handling strategy, or is error handling ad-hoc per module?
- Are retries bounded with backoff and jitter, or can they cause retry storms?
- Are timeouts configured on all external calls (HTTP, database, message queue, gRPC)?
- Are circuit breakers implemented for critical dependency calls?
- What happens when a downstream dependency is unavailable — does the system degrade gracefully or fail completely?
- Are health check endpoints implemented, and do they test actual readiness (not just "process is running")?
- Are failures isolated — can one component's failure cascade to unrelated components?
- What is the startup sequence, and what happens if a dependency is unavailable at startup?
- What is the shutdown procedure, and are in-flight requests completed before shutdown?
- Are error conditions observable — do failures produce actionable logs, metrics, or alerts?
- Is there a distinction between transient failures (retry-safe) and permanent failures (fail-fast)?

## Failure Patterns

### Missing Error Handling

- **Description:** Errors are ignored, swallowed, or handled with generic catch-all blocks that obscure the nature and location of failures.
- **Indicators:**
  - Empty catch blocks or catch blocks that only log and continue
  - Generic `catch (Exception e)` without type-specific handling
  - Functions that return null/undefined on error instead of propagating
  - No error boundary or global error handler in the application
- **Severity Tendency:** high

### Retry Storms

- **Description:** Retry logic amplifies failures instead of recovering from them — when a downstream service is struggling, unbounded retries from multiple clients overwhelm it further, turning partial failures into total outages.
- **Indicators:**
  - Retry logic without maximum retry count
  - Fixed-interval retries without exponential backoff
  - No jitter on retry timing (all clients retry at the same instant)
  - Retries on non-idempotent operations (POST without idempotency key)
- **Severity Tendency:** critical

### Cascading Failures

- **Description:** A failure in one component propagates through the system because there are no isolation boundaries, causing unrelated functionality to fail.
- **Indicators:**
  - No circuit breakers on external dependency calls
  - Shared thread pools or connection pools across unrelated features
  - Synchronous call chains where any link's failure blocks the entire chain
  - Health check that reports unhealthy when a non-critical dependency is down
- **Severity Tendency:** critical

### Silent Failures

- **Description:** Operations fail without producing observable signals — no logs, no metrics, no alerts. The system appears healthy while silently producing incorrect results or dropping work.
- **Indicators:**
  - Background jobs that fail without notification
  - Catch blocks that log at DEBUG level or not at all
  - No dead letter queue for failed message processing
  - Monitoring dashboards that only show success metrics, not failure rates
- **Severity Tendency:** high

### Single Points of Failure

- **Description:** Critical system functionality depends on a single component instance with no redundancy, failover, or degradation path.
- **Indicators:**
  - Single database instance without replica or failover
  - In-memory state (caches, sessions) on a single server with no persistence
  - Critical batch job running on one host with no scheduling redundancy
  - Single external API dependency with no fallback or cache
- **Severity Tendency:** high

### Missing Health Checks

- **Description:** The system provides no mechanism for orchestration layers (load balancers, Kubernetes, etc.) to determine whether an instance is ready to serve traffic or should be replaced.
- **Indicators:**
  - No health check endpoint, or endpoint that always returns 200
  - Health check that doesn't verify actual dependencies (database, cache, external services)
  - No distinction between liveness (process alive) and readiness (can serve traffic)
  - Load balancer sending traffic to instances still initializing
- **Severity Tendency:** medium

### Unbounded Queues

- **Description:** Work queues, message buffers, or in-memory collections grow without limit, eventually exhausting memory and causing system-wide crashes.
- **Indicators:**
  - Queue implementations without maximum capacity configured
  - No backpressure mechanism — producers outpace consumers without throttling
  - Memory usage that correlates with request rate rather than staying bounded
  - OOM (Out of Memory) kills in production history
- **Severity Tendency:** high

### Missing Timeouts

- **Description:** External calls (HTTP, database, gRPC) have no timeout configured, allowing hung connections to block threads/goroutines indefinitely, leading to thread pool exhaustion.
- **Indicators:**
  - HTTP client instantiation without timeout configuration
  - Database connection strings without connection and query timeout parameters
  - No deadline/context propagation in gRPC or async call chains
  - Threads or connections that appear "stuck" in monitoring
- **Severity Tendency:** high

## Best Practice Patterns

### Structured Error Handling

- **Replaces Failure Pattern:** Missing Error Handling
- **Abstract Pattern:** Errors are categorized by type (transient vs permanent, expected vs unexpected), handled at the appropriate level, and always produce observable signals. No error is silently swallowed.
- **Framework Mappings:**
  - Express: Centralized error handling middleware with typed error classes (NotFoundError, ValidationError, ServiceUnavailableError)
  - Spring Boot: `@ControllerAdvice` with exception handler methods mapping domain exceptions to HTTP responses
  - Go: Explicit error return values with error wrapping (`fmt.Errorf("operation failed: %w", err)`) preserving error chain
- **Language Patterns:**
  - TypeScript: Custom error classes extending Error with `code` and `isRetryable` properties
  - Rust: `Result<T, E>` with `?` operator for propagation and `thiserror` for typed error hierarchies

### Exponential Backoff with Jitter

- **Replaces Failure Pattern:** Retry Storms
- **Abstract Pattern:** Retries use exponential backoff (each retry waits longer than the last) plus random jitter (each client retries at a slightly different time) with a maximum retry count and a maximum backoff ceiling.
- **Framework Mappings:**
  - AWS SDK: Built-in exponential backoff with full jitter (recommended default for AWS services)
  - Resilience4j (Java): `RetryConfig.custom().maxAttempts(3).waitDuration(Duration.ofMillis(500)).intervalFunction(IntervalFunction.ofExponentialRandomBackoff())`
  - Polly (.NET): `WaitAndRetryAsync` with decorrelated jitter backoff strategy
- **Language Patterns:**
  - Any: `delay = min(cap, base * 2^attempt) + random(0, base * 2^attempt)` (full jitter formula)
  - Python: `tenacity` library with `wait_exponential_jitter()` and `stop_after_attempt()`

### Circuit Breaker Pattern

- **Replaces Failure Pattern:** Cascading Failures
- **Abstract Pattern:** External dependency calls are wrapped in a circuit breaker that monitors failure rates. When failures exceed a threshold, the circuit "opens" and immediately returns a fallback/error without attempting the call, preventing cascade. After a cooldown period, it "half-opens" to test if the dependency has recovered.
- **Framework Mappings:**
  - Resilience4j (Java): `CircuitBreaker.ofDefaults("name")` with configurable failure rate threshold, wait duration, and sliding window
  - Polly (.NET): `CircuitBreakerAsync(exceptionsAllowedBeforeBreaking, durationOfBreak)` with advanced options
  - Opossum (Node.js): `new CircuitBreaker(asyncFunction, { timeout: 3000, errorThresholdPercentage: 50, resetTimeout: 30000 })`
- **Language Patterns:**
  - Go: `sony/gobreaker` with configurable thresholds and state transition callbacks
  - Python: `pybreaker` with state change listeners and exclusion of specific exceptions

### Observable Failure Signals

- **Replaces Failure Pattern:** Silent Failures
- **Abstract Pattern:** Every failure produces an observable signal — structured log entry, metric increment, and/or dead letter queue entry. Background job failures trigger alerts. No operation can fail without the operations team being able to detect it from monitoring data alone.
- **Framework Mappings:**
  - Sidekiq (Ruby): Dead set for failed jobs, retry metrics, integration with error tracking (Sentry, Honeybadger)
  - Bull/BullMQ (Node.js): Failed job events, dead letter queues, job lifecycle metrics exported to Prometheus
  - Celery (Python): `task_failure` signal handler, Flower monitoring dashboard, dead letter exchange in RabbitMQ
- **Language Patterns:**
  - Any: Every catch block increments a failure counter metric and logs at ERROR or WARN level with structured context
  - Any: Background job processors configured with dead letter queues and failure alerting thresholds

### Bulkhead Isolation

- **Replaces Failure Pattern:** Single Points of Failure
- **Abstract Pattern:** Critical resources (thread pools, connection pools, memory) are isolated per function or dependency so that one component's resource exhaustion cannot affect unrelated components. Redundancy is built in for critical paths.
- **Framework Mappings:**
  - Resilience4j: `Bulkhead.ofDefaults("name")` with separate thread pools per external dependency
  - Kubernetes: Resource limits per pod ensuring one service can't starve others, replica sets for redundancy
  - Hystrix (legacy): Thread pool isolation per command group
- **Language Patterns:**
  - Java: Separate `ExecutorService` instances per dependency with bounded thread pools
  - Node.js: Worker thread pools with per-task timeout and separate event loop isolation for CPU-bound work

### Health Check Endpoints

- **Replaces Failure Pattern:** Missing Health Checks
- **Abstract Pattern:** The system exposes separate liveness (is the process alive?) and readiness (can it serve traffic?) endpoints that verify actual dependency connectivity, not just process status.
- **Framework Mappings:**
  - Spring Boot Actuator: `/actuator/health` with auto-configured health indicators for database, Redis, message brokers
  - Kubernetes: `livenessProbe` (restart if failed) and `readinessProbe` (remove from service if failed) as separate configs
  - Express: Custom `/healthz` (liveness) and `/readyz` (readiness) endpoints checking dependency connectivity
- **Language Patterns:**
  - Any: Readiness check that pings database, cache, and critical external services with short timeout
  - Any: Liveness check that verifies the process can handle requests (not deadlocked) — typically a simple 200 response

### Bounded Queues with Overflow Handling

- **Replaces Failure Pattern:** Unbounded Queues
- **Abstract Pattern:** All queues and buffers have explicit maximum capacity. When capacity is reached, a defined overflow strategy activates — backpressure, load shedding, or dead letter routing — rather than unbounded growth.
- **Framework Mappings:**
  - RabbitMQ: Queue `x-max-length` with `x-overflow: reject-publish` or dead letter exchange for overflow routing
  - Kafka: Topic retention and partition limits with consumer group lag monitoring
  - SQS: Maximum message size, visibility timeout, and dead letter queue after N receive attempts
- **Language Patterns:**
  - Go: Buffered channels with `select` + `default` case for non-blocking sends when full
  - Java: `ArrayBlockingQueue` with capacity limit and `offer()` returning false when full instead of blocking indefinitely

### Timeout Budgets

- **Replaces Failure Pattern:** Missing Timeouts
- **Abstract Pattern:** Every external call has an explicit timeout configured. For call chains, a deadline or timeout budget propagates from the entry point so that downstream calls share a total time budget rather than each having an independent timeout.
- **Framework Mappings:**
  - gRPC: Deadline propagation — initial deadline set at the edge, automatically decremented through service-to-service calls
  - Spring Boot: `RestTemplate` and `WebClient` with `connectTimeout` and `readTimeout` configured at client creation
  - Express/Axios: Request-level timeout with `AbortController` for cancellation on deadline
- **Language Patterns:**
  - Go: `context.WithTimeout()` propagated through the entire call chain — every function accepts `ctx context.Context`
  - Any: Timeouts on every external call: `http.get(url, { timeout: 5000 })` — never use framework defaults

## Red Flags

- Empty catch/except blocks anywhere in the codebase
- HTTP clients instantiated without timeout configuration
- Retry logic with no maximum attempt count
- No circuit breaker library in dependencies
- Health check endpoint that returns 200 without checking any dependencies
- A single catch-all error handler that logs "something went wrong"
- Background job processor with no dead letter queue or failure alerting
- Thread pool sized at Integer.MAX_VALUE or equivalent unbounded configuration
- No graceful shutdown handler (SIGTERM handling)
- Error logging at DEBUG level or below

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| sonarqube | Empty catch blocks, unreachable error handling, exception handling code smells | primary |
| semgrep | Pattern detection for missing timeouts, unbounded retries, swallowed exceptions, missing error propagation | primary |
| git-history | Incident-correlated changes — commits tagged with incident IDs reveal reliability pain points | contextual |

## Standards & Frameworks

- Release It! (Michael Nygard) — Stability patterns: circuit breakers, bulkheads, timeouts, steady state
- Netflix resilience patterns — Hystrix, chaos engineering principles, adaptive concurrency
- SRE principles (Google) — Error budgets, SLOs, toil reduction, defense in depth
- Chaos Engineering (Principles of Chaos) — Proactive failure injection to surface reliability gaps before production incidents
- The Twelve-Factor App — Factor XII (Admin processes) for operational safety

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Error handling coverage | Percentage of external calls with explicit error handling | >95% |
| Timeout configuration rate | Percentage of external calls with timeout configured | 100% |
| Circuit breaker count | Number of circuit breakers on external dependency calls | ≥1 per external dependency |
| Health check endpoint count | Number of health check endpoints (liveness + readiness) | ≥2 (liveness + readiness) |
| Mean time to detection | Average time between failure occurrence and alerting | <5 minutes |
| Graceful shutdown coverage | Whether SIGTERM handler exists and drains in-flight requests | Present and tested |
