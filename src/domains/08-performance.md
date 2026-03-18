---
id: domain-08
number: "08"
name: Scalability & Performance
owner_agents: [performance-engineer]
---

## Overview

Covers algorithmic complexity, N+1 queries, caching strategy, resource usage patterns, async behavior, bottlenecks, and backpressure. Scaling failures are often design bugs, not hardware limits — an O(n^2) algorithm in a hot path or an N+1 query pattern in a list endpoint will defeat any amount of horizontal scaling.

Scope: algorithmic complexity in critical paths, database query patterns, caching strategy and invalidation, connection pool management, async/blocking behavior, memory allocation patterns, batch processing efficiency, pagination, and backpressure mechanisms. Does NOT cover infrastructure capacity planning (domain 10), data model optimization (domain 02), or business logic correctness (domain 03).

## Audit Questions

- Are there algorithmic complexity hotspots — O(n^2) or worse operations in request-handling paths?
- Does the system exhibit N+1 query patterns in list/collection endpoints?
- Is there a caching strategy, and how is cache invalidation handled?
- Are connection pools properly sized for database, HTTP clients, and message brokers?
- Is I/O handled asynchronously where appropriate, or do synchronous blocking calls bottleneck throughput?
- Are there memory allocation patterns that grow with request volume rather than staying bounded?
- Is batch processing used where appropriate, or are operations performed one-at-a-time in loops?
- Is pagination implemented for all list endpoints, and does it use efficient cursor-based or keyset pagination?
- Is backpressure implemented — what happens when producers outpace consumers?
- What system resources grow linearly with user count, and what grows sub-linearly?
- Are there known performance bottlenecks, and are they instrumented for monitoring?
- Are database queries optimized with appropriate indexes for common access patterns?

## Failure Patterns

### N+1 Query Problem

- **Description:** A list operation issues one query to fetch a collection, then N additional queries to fetch related data for each item — turning what should be 1-2 queries into N+1 queries that scale linearly with data size.
- **Indicators:**
  - ORM lazy-loading of relationships inside loops
  - Database query count that scales linearly with list size
  - Slow list endpoints where individual item endpoints are fast
  - Database monitoring showing thousands of nearly identical queries per request
- **Severity Tendency:** high

### Missing Pagination

- **Description:** Endpoints return unbounded result sets, causing memory exhaustion and timeout failures as data grows.
- **Indicators:**
  - API endpoints that return all records without limit/offset or cursor
  - Database queries without LIMIT clause in list operations
  - Memory usage that spikes proportional to table size during API calls
  - "SELECT *" patterns without pagination in production code
- **Severity Tendency:** high

### Unbounded Memory Growth

- **Description:** Memory usage grows continuously without bound, either through genuine leaks (unreleased references) or through design that accumulates data proportional to traffic or time.
- **Indicators:**
  - In-memory caches without eviction policies or TTL
  - Event listener registrations without corresponding cleanup
  - Growing collections (maps, arrays) that are never pruned
  - Memory profiling shows steadily increasing heap that doesn't recover after GC
- **Severity Tendency:** high

### Synchronous Bottlenecks

- **Description:** I/O-bound operations (HTTP calls, file reads, database queries) are performed synchronously, blocking threads and limiting concurrency to the thread pool size.
- **Indicators:**
  - Synchronous HTTP calls in async-capable frameworks
  - Blocking file I/O in request handlers
  - Sequential database queries that could be parallelized
  - Thread pool exhaustion under moderate load
- **Severity Tendency:** medium

### Cache Stampede

- **Description:** When a popular cache entry expires, many concurrent requests simultaneously compute the same expensive result, overwhelming the backend.
- **Indicators:**
  - All cache entries for the same key type expire at the same time
  - Backend load spikes correlating with cache TTL intervals
  - No locking or probabilistic early expiration on cache refresh
  - Database query spikes immediately after cache flush or restart
- **Severity Tendency:** high

### Missing Connection Pooling

- **Description:** Database or HTTP connections are created per-request rather than pooled and reused, causing connection overhead, exhaustion of server-side connection limits, and performance degradation.
- **Indicators:**
  - New connection created inside each request handler
  - Connection count at database approaches server maximum under moderate load
  - "Too many connections" errors in logs
  - No connection pool library in dependencies or configuration
- **Severity Tendency:** high

### Algorithmic Complexity Bombs

- **Description:** O(n^2) or worse algorithms in code paths that process user-controlled input sizes, creating operations whose execution time grows dramatically with data volume.
- **Indicators:**
  - Nested loops iterating over the same or related collections
  - Array `.includes()` or `.indexOf()` called inside loops (O(n) search * O(n) iteration = O(n^2))
  - String concatenation in loops instead of builder/join patterns
  - Sort operations inside loops, or repeated full-collection scans
- **Severity Tendency:** high

### Missing Backpressure

- **Description:** Producers can generate work faster than consumers can process it, with no mechanism to slow producers down, leading to queue overflow, memory exhaustion, or dropped work.
- **Indicators:**
  - Unbounded in-memory queues between producer and consumer
  - No rate limiting on API endpoints that trigger expensive background work
  - Message queue consumers with no prefetch limit
  - Worker processes that accept unlimited concurrent tasks
- **Severity Tendency:** high

## Best Practice Patterns

### Eager Loading / DataLoader Pattern

- **Replaces Failure Pattern:** N+1 Query Problem
- **Abstract Pattern:** Batch related-data fetching into a single query per relationship type. Either eagerly load relationships when the collection is fetched, or use a DataLoader that collects individual requests and batches them into one query.
- **Framework Mappings:**
  - Rails: `includes(:association)` for eager loading, `preload` for separate queries, `eager_load` for JOIN-based loading
  - Django: `select_related()` for FK joins, `prefetch_related()` for separate batched queries
  - GraphQL: DataLoader pattern — collects individual `load(id)` calls within a tick and batches into `loadMany(ids)`
- **Language Patterns:**
  - SQL: `SELECT * FROM orders JOIN users ON orders.user_id = users.id WHERE orders.id IN (...)` — single query for all related data
  - TypeScript: `dataloader` library with per-request caching and automatic batching within event loop tick

### Cursor-Based Pagination

- **Replaces Failure Pattern:** Missing Pagination
- **Abstract Pattern:** Use cursor-based (keyset) pagination for stable, efficient pagination that doesn't degrade with table size. Each page returns a cursor pointing to the last item, and the next page starts from that cursor.
- **Framework Mappings:**
  - GraphQL Relay: Connections spec with `first`, `after`, `last`, `before` cursor arguments
  - Django REST Framework: `CursorPagination` class using encoded cursor tokens
  - Spring Data: `Pageable` with keyset-based `ScrollPosition` for efficient deep pagination
- **Language Patterns:**
  - SQL: `SELECT * FROM items WHERE id > :cursor ORDER BY id ASC LIMIT :page_size` — no OFFSET, uses index scan
  - Any: Encode last-seen ID or sort key as opaque cursor token returned to client

### Bounded Caching with Eviction

- **Replaces Failure Pattern:** Cache Stampede
- **Abstract Pattern:** Caches have explicit maximum size, TTL-based expiration, and eviction policies. Cache stampede is prevented through probabilistic early refresh, locking, or stale-while-revalidate patterns.
- **Framework Mappings:**
  - Redis: `SETEX` with TTL, `maxmemory-policy allkeys-lru` for automatic eviction, Redlock for distributed locking on refresh
  - Caffeine (Java): `maximumSize()`, `expireAfterWrite()`, `refreshAfterWrite()` with async refresh to prevent stampede
  - Node.js: `lru-cache` with `max` entries and `ttl`, `fetchMethod` for stale-while-revalidate
- **Language Patterns:**
  - Any: Cache-aside pattern: check cache → if miss, acquire lock → compute → store → release lock (other waiters get lock or read fresh cache)
  - Any: Probabilistic early expiration: refresh cache entry when `remaining_ttl < random(0, base_ttl * 0.1)` to spread refresh across time

### Resource Lifecycle Management

- **Replaces Failure Pattern:** Unbounded Memory Growth
- **Abstract Pattern:** Every allocated resource (cache entries, event listeners, connections, buffers) has a defined lifecycle — creation, usage, and cleanup. In-memory collections have maximum sizes or TTL-based eviction. Subscriptions and listeners are deregistered when their owners are destroyed.
- **Framework Mappings:**
  - Java: `try-with-resources` for AutoCloseable resources, WeakReferences for cache entries, `@PreDestroy` for cleanup
  - .NET: `IDisposable` pattern with `using` blocks, `ConditionalWeakTable` for metadata caches
  - React: `useEffect` cleanup functions for subscriptions, `AbortController` for fetch cancellation on unmount
- **Language Patterns:**
  - Go: `defer` for cleanup, `context.WithCancel()` for goroutine lifecycle management
  - Python: Context managers (`with` statements) for resource cleanup, `weakref` for cache entries that don't prevent GC

### Async-First Architecture

- **Replaces Failure Pattern:** Synchronous Bottlenecks
- **Abstract Pattern:** I/O-bound operations use async/non-blocking APIs by default. Synchronous blocking is only used for CPU-bound work on dedicated thread pools. The system's concurrency model matches its workload profile.
- **Framework Mappings:**
  - Spring WebFlux: Reactive streams with non-blocking I/O throughout the stack
  - Fastify/Express: `async/await` handlers with non-blocking database drivers (pg-pool, ioredis)
  - Go: Goroutines with channels — lightweight concurrency without callback complexity
- **Language Patterns:**
  - Node.js: `async/await` for all I/O, `Promise.all()` for parallel independent operations
  - Python: `asyncio` with `aiohttp` for HTTP, `asyncpg` for database — event loop for I/O concurrency

### Connection Pooling

- **Replaces Failure Pattern:** Missing Connection Pooling
- **Abstract Pattern:** Database and HTTP client connections are managed through pools with configured minimum, maximum, idle timeout, and connection lifetime. Pools are shared across request handlers and monitored for exhaustion.
- **Framework Mappings:**
  - HikariCP (Java): High-performance JDBC connection pool with `maximumPoolSize`, `minimumIdle`, `connectionTimeout`, `maxLifetime`
  - pg-pool (Node.js): PostgreSQL connection pool with `max`, `idleTimeoutMillis`, `connectionTimeoutMillis`
  - SQLAlchemy (Python): `pool_size`, `max_overflow`, `pool_recycle` configuration for database engine
- **Language Patterns:**
  - Any: Pool size = `(core_count * 2) + effective_spindle_count` as starting point (PostgreSQL recommendation)
  - Any: Connection pool metrics (active, idle, waiting, timeouts) exported to monitoring

### Backpressure Mechanisms

- **Replaces Failure Pattern:** Missing Backpressure
- **Abstract Pattern:** Consumers communicate capacity to producers. When consumers fall behind, producers are slowed (blocking backpressure), work is shed (load shedding), or excess is redirected (overflow routing). Queue depths are bounded and monitored.
- **Framework Mappings:**
  - RabbitMQ: `prefetch_count` limiting unacked messages per consumer, queue `x-max-length` with dead letter routing
  - Kafka: Consumer group rebalancing with `max.poll.records` controlling batch size
  - Reactive Streams (Java): `Flux.onBackpressureBuffer(maxSize)` or `onBackpressureDrop()` for explicit strategy
- **Language Patterns:**
  - Go: Buffered channels with select-default pattern for non-blocking sends
  - Node.js: Streams with `highWaterMark` and `drain` event for built-in backpressure

### Complexity-Aware Data Structure Selection

- **Replaces Failure Pattern:** Algorithmic Complexity Bombs
- **Abstract Pattern:** Data structures and algorithms are chosen based on the complexity requirements of the access patterns they serve. Hot paths are profiled and audited for quadratic or worse operations. Linear search in loops is replaced with hash-based lookups.
- **Framework Mappings:**
  - Java: `HashMap`/`HashSet` for O(1) lookups replacing `List.contains()` in loops, `StringBuilder` replacing string concatenation in loops
  - Python: Set/dict comprehensions for membership testing replacing list iteration, `collections.defaultdict` for grouping
  - PostgreSQL: Query plan analysis with `EXPLAIN ANALYZE` to detect sequential scans on large tables where index scans are expected
- **Language Patterns:**
  - JavaScript/TypeScript: Convert arrays to `Set` or `Map` before loop-based lookups: `const idSet = new Set(ids)` then `idSet.has(id)` instead of `ids.includes(id)`
  - Any: Pre-sort + binary search or hash-based index for repeated lookups against the same collection

## Red Flags

- ORM calls inside loops (`.find()`, `.get()`, `.load()` per iteration)
- API endpoints returning collections without pagination parameters
- In-memory caches without TTL or maximum size
- Database queries without LIMIT clause in any list operation
- Nested loops over collections where inner collection size depends on outer
- No connection pool configuration in database client setup
- `SELECT *` in production queries
- Synchronous HTTP calls in async request handlers
- No rate limiting on public-facing API endpoints
- Growing memory usage visible in production metrics without plateau

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| sonarqube | Cognitive complexity hotspots, code duplication in performance-critical paths, method length as proxy for algorithmic complexity | primary |
| semgrep | Pattern detection for N+1 queries, missing pagination, synchronous calls in async contexts, unbounded loops | supporting |
| git-history | Performance-related commit patterns (commits mentioning "slow", "timeout", "optimize") reveal historical pain points | contextual |

## Standards & Frameworks

- Google SRE performance guidelines — Latency budgets, load testing principles, capacity planning
- USE Method (Brendan Gregg) — Utilization, Saturation, Errors for resource performance analysis
- Database optimization patterns — Index design, query planning, denormalization trade-offs
- Reactive Manifesto — Responsive, Resilient, Elastic, Message-Driven principles for scalable systems
- Little's Law — L = λW (concurrent requests = arrival rate × average latency) for capacity modeling

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Query count per request | Average database queries per API request | <10 for list endpoints, <5 for detail endpoints |
| P95/P99 response time | Tail latency for API endpoints | P95 <500ms, P99 <2s (application-dependent) |
| Cache hit ratio | Percentage of reads served from cache | >80% for read-heavy endpoints |
| Connection pool utilization | Active connections as percentage of max pool size | 30-70% at normal load, <90% at peak |
| Memory growth rate | Rate of heap growth between GC cycles | Flat or near-zero (no sustained growth) |
| Algorithmic hotspot count | Number of O(n^2)+ operations in request-handling paths | 0 in hot paths |
