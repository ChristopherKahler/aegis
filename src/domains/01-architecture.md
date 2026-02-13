---
id: domain-01
number: "01"
name: Architecture & System Design
owner_agents: [architect]
---

## Overview

Covers structural patterns, module boundaries, dependency direction, coupling, cohesion, layering, and whether the architecture can support the system's actual requirements. Architecture determines how easy bugs are to introduce, how expensive changes are, and whether scale is possible without rewrites. A well-designed architecture makes the right things easy and the wrong things hard; a poorly designed one does the opposite.

Scope: module responsibilities and boundaries, dependency graphs, layering consistency, coupling and cohesion metrics, API surface design, extensibility points, and adherence to stated architectural patterns. Does NOT cover data model design (domain 02), security boundaries (domain 04), or deployment architecture (domain 10).

## Audit Questions

- Is there a stated architectural pattern (layered, hexagonal, microservices, modular monolith), and does the code follow it?
- Are module boundaries clearly defined and enforced, or do modules reach into each other's internals?
- Does dependency direction follow a consistent rule (e.g., inward toward domain, downward through layers)?
- Are there circular dependencies between modules or packages?
- Are there "god modules" — modules that know about everything and are imported everywhere?
- Is domain logic separated from infrastructure concerns (database, HTTP, messaging)?
- Are API surfaces (internal and external) well-defined with clear contracts?
- Is there evidence of the "wrong abstraction" — shared code that is harder to understand than duplication would be?
- Are extensibility points (plugins, hooks, event systems) intentional or accidental?
- What is the ratio of concrete to abstract dependencies?
- Are there modules that change together but are structurally separate (hidden coupling)?
- Is the system's decomposition aligned with its domain boundaries?
- How deep is the dependency tree, and are there concerning chains?

## Failure Patterns

### Big Ball of Mud

- **Description:** The system lacks discernible architecture. Modules, layers, and boundaries are absent or unenforced, resulting in code where everything depends on everything.
- **Indicators:**
  - No clear directory structure reflecting architectural intent
  - Import graphs show dense, bidirectional connections between most modules
  - Any change requires touching files across many directories
  - No team member can draw the system's architecture from memory
- **Severity Tendency:** critical

### Leaky Abstractions

- **Description:** Module boundaries exist in name but not in practice. Internal implementation details leak through interfaces, creating hidden coupling between components.
- **Indicators:**
  - Callers make assumptions about implementation details (database schemas, internal state, ordering)
  - Interface changes propagate transitively through multiple layers
  - "Convenience" methods that bypass the intended API surface
  - Error types from lower layers surface unchanged through upper layers
- **Severity Tendency:** high

### Circular Dependencies

- **Description:** Two or more modules depend on each other, creating cycles in the dependency graph that prevent independent testing, deployment, and reasoning about each module.
- **Indicators:**
  - Import analysis reveals cycles (A imports B, B imports A)
  - Build order is fragile or requires special configuration
  - Extracting a module requires bringing its "dependencies" along
  - Initialization order bugs (module A needs B initialized first, but B needs A)
- **Severity Tendency:** high

### God Objects / God Modules

- **Description:** A single class, module, or package has accumulated responsibility for too many concerns, becoming a central point of coupling that everything depends on.
- **Indicators:**
  - One module with significantly more lines of code than any other
  - A single file or class imported by >50% of other modules
  - Module name is generic ("utils", "helpers", "common", "core", "shared")
  - Changes to this module have high blast radius
- **Severity Tendency:** high

### Layer Violations

- **Description:** The system has an intended layering (e.g., presentation → business → data), but code routinely bypasses layers, creating shortcuts that undermine the architecture's guarantees.
- **Indicators:**
  - UI/controller code directly accessing database queries
  - Business logic importing HTTP request/response types
  - Data access layer containing business rules
  - Configuration or environment variables read deep inside business logic
- **Severity Tendency:** medium

### Distributed Monolith

- **Description:** The system is deployed as multiple services but exhibits the coupling characteristics of a monolith — services cannot be deployed, tested, or reasoned about independently.
- **Indicators:**
  - Services share a database or schema
  - Deploying one service requires coordinated deployment of others
  - Shared libraries contain business logic, not just utilities
  - Synchronous call chains span 3+ services for common operations
- **Severity Tendency:** high

### Wrong Abstraction Level

- **Description:** Code has been prematurely or incorrectly abstracted — shared modules, base classes, or generic frameworks that make the code harder to understand than simple duplication would.
- **Indicators:**
  - Abstract base classes with only one concrete implementation
  - Generic frameworks used for a single use case
  - Utility functions with boolean parameters that switch between unrelated behaviors
  - Code that requires understanding the abstraction layer to understand any concrete use case
- **Severity Tendency:** medium

### Feature Envy

- **Description:** Modules or classes that primarily operate on another module's data rather than their own, indicating misplaced responsibility and a domain modeling failure.
- **Indicators:**
  - Methods that take an object and call multiple getters/accessors on it
  - Modules that import data structures from another module more than their own
  - Transformation logic located far from the data it transforms
  - "Manager" or "Service" classes that orchestrate another module's internal operations
- **Severity Tendency:** medium

## Best Practice Patterns

### Clean Architecture / Hexagonal Architecture

- **Replaces Failure Pattern:** Big Ball of Mud
- **Abstract Pattern:** Structure the system with a clear dependency direction — outer layers depend on inner layers, never the reverse. Domain logic sits at the center with no dependencies on infrastructure. All external concerns (database, HTTP, messaging) are behind interfaces defined by the domain.
- **Framework Mappings:**
  - Spring Boot: Domain layer as plain POJOs, repository interfaces defined in domain, implementations in infrastructure module
  - NestJS: Modules with clear imports, domain services with no framework decorators, repository pattern for data access
  - Laravel: Domain directory separate from app/, repository interfaces in domain, Eloquent implementations in infrastructure
- **Language Patterns:**
  - Java/Kotlin: Package-by-feature with domain packages having zero framework imports
  - TypeScript: Barrel exports per module, no cross-module deep imports, dependency injection for infrastructure

### Interface Segregation

- **Replaces Failure Pattern:** Leaky Abstractions
- **Abstract Pattern:** Expose narrow, purpose-specific interfaces rather than broad, implementation-revealing ones. Each consumer should depend only on the methods it uses, not the entire capability of the provider.
- **Framework Mappings:**
  - Go: Small interfaces defined at the consumer site, not the provider (io.Reader, io.Writer as exemplars)
  - Spring Boot: Separate query and command interfaces for repositories (CQRS-lite)
  - Express/NestJS: Route-specific DTOs rather than exposing domain entities directly
- **Language Patterns:**
  - TypeScript: Interface per use case (`UserReader`, `UserWriter`) rather than one fat `UserRepository`
  - Python: Protocol classes (PEP 544) for structural typing, ABC for small capability interfaces

### Acyclic Dependencies Principle

- **Replaces Failure Pattern:** Circular Dependencies
- **Abstract Pattern:** The dependency graph between modules must be a directed acyclic graph (DAG). Break cycles through dependency inversion — introduce an interface owned by the higher-level module that the lower-level module implements.
- **Framework Mappings:**
  - Spring Boot: Event-driven communication between modules via ApplicationEventPublisher to break synchronous cycles
  - NestJS: forwardRef() as a temporary fix, but proper solution is extracting shared interfaces into a separate module
  - Django: Signal system for decoupled module communication
- **Language Patterns:**
  - Java: Dependency inversion with interfaces — module A defines the interface, module B implements it
  - TypeScript: Shared types/interfaces package that both modules depend on, breaking the direct cycle

### Module Cohesion

- **Replaces Failure Pattern:** God Objects / God Modules
- **Abstract Pattern:** Each module should have a single, well-defined responsibility. If a module's name requires "and" to describe, it should be split. Utility grab-bags should be decomposed into purpose-specific modules.
- **Framework Mappings:**
  - DDD: Aggregate roots as natural module boundaries — each aggregate is a cohesion unit
  - Spring Boot: One @Service per bounded context operation, packages named by domain concept
  - Rails: Concerns and service objects to extract responsibilities from fat models/controllers
- **Language Patterns:**
  - Any: Replace `utils/` with purpose-named modules (`formatting`, `validation`, `date-helpers`)
  - Go: Package per domain concept with short, focused packages preferred over large "everything" packages

### Strict Layering

- **Replaces Failure Pattern:** Layer Violations
- **Abstract Pattern:** Each layer may only depend on the layer immediately below it. Skip-layer access is forbidden. Layer boundaries are enforced through module visibility, dependency rules, or architectural fitness functions.
- **Framework Mappings:**
  - Spring Boot: ArchUnit tests enforcing layer dependencies (controller → service → repository, never controller → repository)
  - .NET: Project references enforcing layer separation (API project references Domain, not Infrastructure)
  - NestJS: Module imports enforcing dependency direction with strict mode
- **Language Patterns:**
  - Java: Package-private visibility for implementation classes, public only for interfaces
  - TypeScript: `index.ts` barrel exports controlling module surface, eslint-plugin-import rules preventing deep imports

### Service Autonomy

- **Replaces Failure Pattern:** Distributed Monolith
- **Abstract Pattern:** Each service owns its data, can be deployed independently, and communicates through well-defined asynchronous contracts. Shared databases are replaced with API contracts or event-driven integration.
- **Framework Mappings:**
  - Kafka/RabbitMQ: Event-driven integration replacing synchronous call chains
  - gRPC: Strongly-typed service contracts with independent schema evolution
  - API Gateway: Centralized routing with independent service deployments behind it
- **Language Patterns:**
  - Any: Database-per-service with API or event-based data sharing
  - Any: Consumer-driven contract tests (Pact) to validate integration without coupling

### Justified Abstraction

- **Replaces Failure Pattern:** Wrong Abstraction Level
- **Abstract Pattern:** Prefer duplication over the wrong abstraction. Introduce abstractions only when three or more concrete cases exist and the shared pattern is stable and well-understood. Every abstraction should earn its keep.
- **Framework Mappings:**
  - Rule of Three: Wait for three instances before extracting a shared abstraction
  - Martin Fowler's Refactoring: Extract only when duplication is proven harmful, not merely present
  - Sandi Metz: "Prefer duplication over the wrong abstraction" — wrong abstractions are more expensive than duplicated code
- **Language Patterns:**
  - Any: Inline implementation for single-use patterns; extract only after multiple proven uses
  - Any: Composition over inheritance — small, focused functions combined rather than class hierarchies

### Responsibility Alignment

- **Replaces Failure Pattern:** Feature Envy
- **Abstract Pattern:** Operations should live with the data they operate on. If a function primarily uses another module's data, it belongs in that module. Domain modeling should align code boundaries with data ownership.
- **Framework Mappings:**
  - DDD: Rich domain models where behavior lives with the entity it operates on
  - Tell, Don't Ask: Objects expose behavior (tell), not data for external computation (ask)
  - CQRS: Separate read/write models to avoid cross-module data access for queries
- **Language Patterns:**
  - Java/Kotlin: Methods on the domain object itself rather than in external "service" classes
  - Python: Instance methods for operations on instance data; module-level functions for operations on module's data types

## Red Flags

- Directory named `utils/`, `helpers/`, `common/`, or `misc/` with >500 lines
- A single file imported by more than half the codebase
- Import statements that reach 3+ levels deep into another module's directory structure
- Module names that require "and" to describe their purpose
- Business logic in controller/handler files
- Database queries in UI component files
- Circular import warnings from build tools
- "Shared" library containing business logic, not just utilities
- God class with >1000 lines and >20 methods
- Service-to-service calls requiring synchronized deployments

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| sonarqube | Cyclomatic complexity, cognitive complexity, coupling between modules, duplication density | primary |
| semgrep | Custom rules to detect layer violations, forbidden imports, architectural pattern violations | supporting |
| git-history | Change coupling analysis — files that always change together reveal hidden architectural dependencies | supporting |

## Standards & Frameworks

- SOLID Principles — Single Responsibility, Open-Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- Clean Architecture (Robert C. Martin) — Dependency rule, entity/use-case/interface-adapter/framework layers
- Hexagonal Architecture (Alistair Cockburn) — Ports and adapters separating domain from infrastructure
- Domain-Driven Design (Eric Evans) — Bounded contexts, aggregates, ubiquitous language
- Package Principles (Robert C. Martin) — Reuse-Release, Common-Closure, Common-Reuse, Acyclic Dependencies, Stable Dependencies, Stable Abstractions

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Coupling between modules | Number of inter-module dependencies relative to total modules | <0.3 (normalized, lower is better) |
| Average cyclomatic complexity | Average decision complexity per function | <10 per function |
| Dependency depth | Longest chain in the module dependency graph | <5 levels |
| File size distribution (P90) | 90th percentile file size in lines of code | <400 lines |
| Circular dependency count | Number of cycles in the module dependency graph | 0 |
| Afferent/efferent coupling ratio | Balance between incoming and outgoing dependencies per module | Varies — instability index (Ce/(Ca+Ce)) should be 0 or 1, not middle |
