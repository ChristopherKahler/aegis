---
id: domain-11
number: "11"
name: Change Risk & Evolvability
owner_agents: [staff-engineer]
---

## Overview

Change risk examines change amplification, refactor safety, blast radius, and modularity health. The central question is: "How dangerous is it to touch this code?" Research shows that high change risk predicts velocity decay and increases the likelihood of system rewrites. This domain focuses on structural properties that make code resistant or fragile to change. It does NOT cover architectural pattern selection (domain 01), team risk factors (domain 12), or holistic risk synthesis (domain 13).

## Audit Questions

- How many files must be modified on average to implement a typical feature request?
- Are refactoring operations covered by automated tests that catch regressions?
- What is the blast radius of changes to core modules or base classes?
- How frequently do changes to one module require coordinated changes across many others?
- Are external dependencies pinned to specific versions or allowed to float?
- Do public APIs use versioning to maintain backward compatibility?
- How tightly coupled are modules to specific third-party library implementations?
- Can individual components be deployed independently without full system deployment?
- How often do seemingly isolated changes cause failures in distant parts of the system?
- Are inheritance hierarchies shallow and focused, or deep and fragile?
- What percentage of the codebase can be modified safely without cascading changes?
- How frequently are breaking API changes introduced to consumers?

## Failure Patterns

### High Change Amplification

- **Description:** Single logical changes require modifications across many files, modules, or services. Increases both the cost of change and the risk of incomplete implementation or introducing inconsistencies.
- **Indicators:**
  - Feature requests routinely require changes to 10+ files
  - Adding a new data field requires updates across multiple layers
  - Business logic changes necessitate updates to database, API, UI, and tests
  - New feature implementation touches frontend, backend, and infrastructure code
  - Changes to one module require coordinated releases of several services
- **Severity Tendency:** high

### Shotgun Surgery

- **Description:** Single responsibilities scattered across many locations, forcing developers to make parallel changes in multiple places. Closely related to high change amplification but specifically focuses on fragmented responsibility.
- **Indicators:**
  - Adding a new enum value requires updates in 5+ different files
  - Error handling logic duplicated across modules rather than centralized
  - Validation rules scattered throughout presentation, business, and data layers
  - Configuration changes require updates to multiple config files
  - Feature flag checks spread throughout the codebase
- **Severity Tendency:** high

### Fragile Base Class

- **Description:** Base classes or shared modules that are frequently modified and have many dependents. Changes to these components create high risk of breaking derived classes or dependent modules across the system.
- **Indicators:**
  - Base classes modified more frequently than derived classes
  - Inheritance hierarchies deeper than 3 levels
  - Abstract base classes with more than 10 concrete implementations
  - Changes to utility classes causing test failures in distant modules
  - Shared modules imported by more than 30% of the codebase
  - Base class modifications requiring changes to many derived classes
- **Severity Tendency:** high

### Missing API Versioning

- **Description:** Public APIs that lack versioning mechanisms, forcing all consumers to upgrade simultaneously when changes occur. Creates coordination burden and prevents gradual migration strategies.
- **Indicators:**
  - HTTP APIs without version numbers in URLs or headers
  - Library packages that make breaking changes in minor versions
  - Database schemas with no migration versioning system
  - Message queue contracts that change without backward compatibility
  - GraphQL schemas with no deprecation strategy for fields
  - No sunset period or deprecation warnings before removing functionality
- **Severity Tendency:** high

### Tight Coupling to External Dependencies

- **Description:** Direct dependency on specific implementations of third-party libraries throughout the codebase. Makes dependency upgrades, replacements, or testing with mocks extremely difficult.
- **Indicators:**
  - Database client API calls scattered throughout business logic
  - HTTP client library types exposed in domain models
  - Third-party ORM annotations on domain entities
  - Cloud provider SDKs called directly from application code
  - Specific logging library references in every module
  - Framework-specific types appearing in domain layer
- **Severity Tendency:** medium

### Monolithic Deployment Units

- **Description:** Large deployment units that require full system deployment for any change. Prevents incremental rollouts, increases deployment risk, and creates long deployment windows.
- **Indicators:**
  - Single deployment artifact containing all services or features
  - Inability to deploy backend without frontend changes
  - All microservices deployed together despite logical independence
  - Database migrations coupled to application deployments
  - No blue-green or canary deployment capabilities
  - Rollback requiring full system restoration
- **Severity Tendency:** medium

### Untested Refactoring Paths

- **Description:** Critical code paths that lack sufficient test coverage to enable safe refactoring. Forces developers to avoid necessary improvements due to high risk of undetected breakage.
- **Indicators:**
  - Core business logic modules with less than 60% test coverage
  - Complex algorithms with no unit tests
  - Legacy code with "do not touch" warnings in comments
  - Refactoring attempts frequently causing production incidents
  - High developer fear of modifying specific modules
  - Code marked as "technical debt" with no safe migration path
- **Severity Tendency:** high

## Best Practice Patterns

### Layered Abstraction with Clear Boundaries

- **Replaces Failure Pattern:** High Change Amplification
- **Abstract Pattern:** Organize code into well-defined layers with explicit interfaces between them. Changes within a layer should not cascade across boundaries. Use dependency inversion to point dependencies toward stable abstractions.
- **Framework Mappings:**
  - Clean Architecture: Use entities, use cases, interface adapters, frameworks layers
  - Hexagonal Architecture: Isolate domain logic from infrastructure through ports and adapters
  - Domain-Driven Design: Define bounded contexts with published language at boundaries
- **Language Patterns:**
  - Python: Use abstract base classes for layer interfaces; separate packages by layer
  - TypeScript: Use interface segregation; barrel exports for layer boundaries
  - Java: Use packages and modules to enforce layer separation; interfaces for boundaries

### Centralized Cross-Cutting Concerns

- **Replaces Failure Pattern:** Shotgun Surgery
- **Abstract Pattern:** Consolidate responsibilities that appear across many modules into dedicated services or middleware. Use aspect-oriented techniques or decorators to apply cross-cutting behavior without scattering logic.
- **Framework Mappings:**
  - Spring AOP: Use aspects for logging, security, transaction management
  - Middleware Patterns: Use Express/FastAPI middleware for HTTP concerns
  - Decorator Pattern: Wrap core behavior with cross-cutting functionality
- **Language Patterns:**
  - Python: Use decorators for cross-cutting concerns; context managers for resources
  - TypeScript: Use higher-order functions or decorators; middleware composition
  - Java: Use annotations with aspect-oriented processing or interceptors

### Composition Over Inheritance

- **Replaces Failure Pattern:** Fragile Base Class
- **Abstract Pattern:** Prefer object composition and interface implementation over deep inheritance hierarchies. Use small, focused interfaces and combine behaviors through composition to avoid fragile base class problems.
- **Framework Mappings:**
  - SOLID Principles: Apply Liskov Substitution and Interface Segregation
  - Strategy Pattern: Inject behavior through interfaces rather than inheritance
  - Mixin Pattern: Use composition or traits for behavior reuse
- **Language Patterns:**
  - Python: Use composition, protocols, and mixins; avoid deep class hierarchies
  - TypeScript: Use composition and interface implementation; prefer type unions
  - Java: Use interfaces extensively; limit inheritance to 1-2 levels

### Explicit API Versioning Strategy

- **Replaces Failure Pattern:** Missing API Versioning
- **Abstract Pattern:** Build versioning into APIs from the start. Support multiple versions simultaneously during transition periods. Use semantic versioning for libraries. Provide deprecation warnings and migration guides.
- **Framework Mappings:**
  - REST APIs: Use URL versioning (/v1/, /v2/) or header-based versioning
  - GraphQL: Use field deprecation with @deprecated directive
  - Semantic Versioning: Apply semver principles to library and API releases
- **Language Patterns:**
  - Python: Use package versioning; deprecation warnings via warnings module
  - TypeScript: Use @deprecated JSDoc tags; support multiple versions in parallel
  - Java: Use package versioning; deprecation annotations with migration paths

### Dependency Abstraction Layer

- **Replaces Failure Pattern:** Tight Coupling to External Dependencies
- **Abstract Pattern:** Create thin abstraction layers around external dependencies. Define interfaces in your domain language and implement adapters for specific libraries. Enables testing with mocks and switching implementations.
- **Framework Mappings:**
  - Adapter Pattern: Wrap third-party APIs with domain-specific interfaces
  - Repository Pattern: Abstract data access behind domain-aligned interfaces
  - Anti-Corruption Layer: Translate between external models and domain models
- **Language Patterns:**
  - Python: Use Protocol or ABC to define interfaces; implement adapters
  - TypeScript: Define interfaces for external services; use dependency injection
  - Java: Use interfaces and dependency injection containers

### Independently Deployable Modules

- **Replaces Failure Pattern:** Monolithic Deployment Units
- **Abstract Pattern:** Structure systems so that components can be built, tested, and deployed independently. Use service boundaries, API contracts, and feature flags to enable incremental rollouts.
- **Framework Mappings:**
  - Microservices: Deploy services independently with versioned APIs
  - Modular Monoliths: Use internal module boundaries with independent deployment paths
  - Feature Flags: Decouple deployment from release using runtime toggles
- **Language Patterns:**
  - Python: Use separate packages with independent versioning; container-based deployment
  - TypeScript: Use monorepo with independent build targets; micro-frontends
  - Java: Use Maven/Gradle modules; OSGi or JPMS for modularity

### Comprehensive Regression Safety Net

- **Replaces Failure Pattern:** Untested Refactoring Paths
- **Abstract Pattern:** Build sufficient automated test coverage to enable confident refactoring. Focus on behavior-preserving tests at boundaries. Use approval testing for legacy code. Enable safe structural changes through test-driven refactoring.
- **Framework Mappings:**
  - Test-Driven Development: Write tests before refactoring; verify behavior preservation
  - Approval Testing: Capture current behavior as baseline; detect unintended changes
  - Mutation Testing: Verify test effectiveness by introducing artificial bugs
- **Language Patterns:**
  - Python: Use pytest with coverage tracking; approval testing with approval tests
  - TypeScript: Use Jest with coverage reports; snapshot testing for complex outputs
  - Java: Use JUnit with coverage tools; approval testing with Approval Tests

## Red Flags

- Feature changes routinely requiring modifications to 10+ files
- More than 5% of commits touch files across multiple architectural layers
- Base classes or shared modules modified more than once per week
- Public APIs with no versioning scheme
- Third-party library types appearing in domain models
- Deployment requiring coordination across multiple teams
- Modules with less than 50% test coverage marked as "do not touch"
- Inheritance hierarchies deeper than 3 levels
- Single repository deployment artifact over 500MB
- Frequent production incidents caused by "minor refactorings"
- More than 20% of codebase depends on a single utility module

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| git-history | Change amplification, co-change patterns, hotspots | primary |
| sonarqube | Coupling metrics, complexity, code smells | supporting |
| semgrep | Anti-patterns, tight coupling detection | contextual |
| syft-grype | Dependency analysis, version tracking | contextual |

## Standards & Frameworks

- Lehman's Laws of Software Evolution — structural decay and change resistance over time
- Coupling and Cohesion Metrics — measuring module interdependence
- Modularity Index — quantifying system decomposability
- SOLID Principles — Liskov Substitution, Dependency Inversion for change safety
- Semantic Versioning — version management for APIs and libraries
- Feature Flags and Toggles — decoupling deployment from release

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Change Amplification Ratio | Average files modified per logical change | < 5 files |
| Co-change Frequency | Percentage of commits touching 3+ modules | < 15% |
| API Stability Index | Percentage of API versions supported simultaneously | 2-3 versions |
| Refactoring Safety Score | Test coverage of modules targeted for refactoring | > 70% |
| Deployment Independence | Percentage of modules deployable without others | > 60% |
| Inheritance Depth Average | Average depth of class hierarchies | < 2 levels |
