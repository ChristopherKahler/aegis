---
id: domain-09
number: "09"
name: Maintainability & Code Health
owner_agents: [senior-app-engineer]
---

## Overview

Maintainability encompasses code smells, duplication, naming clarity, documentation accuracy, intent visibility, and technical debt management. Research indicates that maintenance activities consume 60-80% of total software lifecycle costs. This domain focuses on code-level quality factors that directly impact the ease and safety of making changes. It does NOT cover architectural patterns (domain 01), testing strategies (domain 06), or change risk analysis (domain 11).

## Audit Questions

- What percentage of the codebase consists of duplicated code blocks or logic?
- Are class, function, and variable names self-documenting and aligned with domain terminology?
- How much dead code exists that is no longer called or used by the system?
- Do comments and documentation accurately reflect current code behavior and intent?
- Are primitive types used directly where domain objects would improve clarity?
- What is the average cognitive complexity of functions across the codebase?
- Is code style consistent within and across modules?
- Are configuration values scattered throughout the code or centralized?
- How many functions exceed recommended length thresholds for the language?
- Does the codebase exhibit patterns of primitive obsession or feature envy?
- Are magic numbers and strings replaced with named constants?
- How frequently do developers report confusion about code intent during reviews?

## Failure Patterns

### Excessive Duplication

- **Description:** Identical or near-identical code blocks repeated across multiple locations, increasing maintenance burden and bug propagation risk. Violates the DRY principle and creates change amplification.
- **Indicators:**
  - Copy-pasted code blocks with minor variations in variable names
  - Identical business logic implemented in multiple services or modules
  - Repeated error handling patterns without abstraction
  - Similar data transformation logic scattered across layers
  - Multiple implementations of the same algorithm
- **Severity Tendency:** medium

### Poor Naming

- **Description:** Class, function, variable, and module names that fail to communicate intent, use inconsistent terminology, or create cognitive load through abbreviations and ambiguity. Forces readers to constantly reference context.
- **Indicators:**
  - Generic names like "data," "manager," "handler," "process," "doStuff"
  - Inconsistent terminology for the same concept across modules
  - Single-letter variables outside conventional loop contexts
  - Names that require comments to explain their purpose
  - Abbreviations that are not universally understood
  - Names that don't reflect the domain language
- **Severity Tendency:** medium

### Dead Code Accumulation

- **Description:** Functions, classes, modules, or entire features that are no longer called or used but remain in the codebase. Creates maintenance burden, confusion about system behavior, and false positives in search results.
- **Indicators:**
  - Functions with no call sites in the entire codebase
  - Commented-out code blocks spanning dozens of lines
  - Modules imported nowhere in the dependency graph
  - Feature flags that are permanently disabled
  - Deprecated APIs with no migration path or timeline
  - Build artifacts for components no longer compiled
- **Severity Tendency:** low

### Missing Intent Documentation

- **Description:** Code that performs non-obvious operations without explaining why specific decisions were made. Leaves future maintainers guessing about business rules, edge cases, and architectural constraints.
- **Indicators:**
  - Complex algorithms with no explanation of their purpose
  - Magic numbers without comments explaining their significance
  - Non-obvious workarounds for third-party library issues
  - Business logic with no reference to requirements or tickets
  - Conditional branches with unclear business meaning
  - Performance optimizations without justification
- **Severity Tendency:** medium

### Primitive Obsession

- **Description:** Overuse of primitive data types (strings, integers, arrays) instead of small domain objects or value types. Scatters validation logic, reduces type safety, and obscures domain concepts.
- **Indicators:**
  - String parameters representing enumerated concepts
  - Parallel arrays or tuples instead of structured objects
  - Repeated validation of primitive values across the codebase
  - Functions with multiple primitive parameters instead of domain objects
  - Type aliases for primitives without behavior or validation
  - Business logic operating on raw primitives instead of domain types
- **Severity Tendency:** medium

### Long Methods/Functions

- **Description:** Functions or methods that exceed cognitive complexity thresholds, contain multiple levels of abstraction, or perform many unrelated operations. Reduces comprehensibility and testability.
- **Indicators:**
  - Functions exceeding 50 lines in most languages
  - Multiple levels of nested conditionals or loops
  - Functions performing I/O, business logic, and presentation in sequence
  - More than 5 local variables tracking state
  - Functions requiring horizontal scrolling to read
  - Methods mixing abstraction levels without clear separation
- **Severity Tendency:** medium

### Inconsistent Code Style

- **Description:** Lack of uniform formatting, naming conventions, and structural patterns across the codebase. Creates friction during reading, increases cognitive load, and signals weak quality standards.
- **Indicators:**
  - Mixed indentation styles (tabs vs. spaces, different widths)
  - Inconsistent brace placement and spacing conventions
  - Variable naming that switches between camelCase, snake_case, PascalCase
  - Some files formatted by linters, others not
  - Inconsistent error handling patterns (some throw, some return codes)
  - Mixed quote styles or trailing comma conventions
- **Severity Tendency:** low

### Scattered Configuration

- **Description:** Configuration values, feature flags, and environment-specific settings spread throughout the codebase rather than centralized. Makes deployment difficult and increases risk of missed configuration during environment changes.
- **Indicators:**
  - Hardcoded URLs or connection strings in multiple files
  - Environment-specific logic in business code
  - Configuration values duplicated across services
  - No single source of truth for feature flags
  - Magic strings representing configuration keys
  - Configuration embedded in class constructors throughout the codebase
- **Severity Tendency:** medium

## Best Practice Patterns

### Extract Common Abstractions

- **Replaces Failure Pattern:** Excessive Duplication
- **Abstract Pattern:** Identify repeated code blocks and extract them into shared functions, classes, or modules with clear single responsibilities. Use parameterization to handle variations while maintaining a single implementation.
- **Framework Mappings:**
  - React: Extract custom hooks for repeated stateful logic or component patterns
  - Spring: Use service classes and utility methods for common business logic
  - Django: Create model mixins, manager methods, or template tags for reusable patterns
- **Language Patterns:**
  - Python: Extract functions/classes, use decorators for cross-cutting concerns
  - TypeScript: Create utility functions, generic types, and higher-order components
  - Java: Use inheritance, composition, and utility classes for shared behavior

### Domain-Aligned Naming

- **Replaces Failure Pattern:** Poor Naming
- **Abstract Pattern:** Use names that directly reflect domain concepts and business terminology. Names should read like natural language and require no additional context to understand their purpose.
- **Framework Mappings:**
  - Domain-Driven Design: Use ubiquitous language from bounded contexts
  - Clean Architecture: Name entities, use cases, and interfaces after business concepts
  - REST APIs: Use resource nouns and HTTP verbs that match business operations
- **Language Patterns:**
  - Python: Use descriptive snake_case names; avoid abbreviations unless domain-standard
  - TypeScript: Use clear camelCase; leverage type names for additional clarity
  - Java: Use verbose PascalCase for classes; verbs for methods reflecting actions

### Aggressive Dead Code Removal

- **Replaces Failure Pattern:** Dead Code Accumulation
- **Abstract Pattern:** Continuously identify and delete unused code. Trust version control for historical reference rather than leaving commented code in place. Use feature flags for temporary disablement, not code comments.
- **Framework Mappings:**
  - Git: Use branches for experimental code; rely on history for recovery
  - Feature Flag Systems: Use LaunchDarkly, Unleash for temporary feature disablement
  - CI/CD: Add automated dead code detection to build pipelines
- **Language Patterns:**
  - Python: Use coverage tools to identify unused modules; remove commented blocks
  - TypeScript: Use "unused" linting rules; remove imports with no references
  - Java: Use IDE analysis to find unused classes; delete deprecated code after migration

### Intent-Revealing Documentation

- **Replaces Failure Pattern:** Missing Intent Documentation
- **Abstract Pattern:** Document the "why" rather than the "what." Focus on business context, architectural constraints, non-obvious trade-offs, and edge cases. Use code structure and naming to make the "what" self-evident.
- **Framework Mappings:**
  - JSDoc/TSDoc: Document non-obvious parameters, return value meanings, side effects
  - Javadoc: Explain design decisions, link to tickets, note performance considerations
  - Python Docstrings: Use Google or NumPy format for structured intent documentation
- **Language Patterns:**
  - Python: Use module-level docstrings for context; inline comments for "why" only
  - TypeScript: Use TSDoc for public APIs; inline comments for business rule references
  - Java: Use Javadoc for public interfaces; comments for complex algorithms only

### Value Objects and Domain Types

- **Replaces Failure Pattern:** Primitive Obsession
- **Abstract Pattern:** Replace primitive types with small, immutable domain objects that encapsulate validation, behavior, and business meaning. Use type systems to enforce domain constraints at compile time.
- **Framework Mappings:**
  - Domain-Driven Design: Create value objects for domain concepts like Money, EmailAddress
  - Type Systems: Use branded types or newtypes to prevent primitive mixing
  - ORMs: Define custom column types for domain value objects
- **Language Patterns:**
  - Python: Use dataclasses or attrs for value objects with validation
  - TypeScript: Use branded types, classes, or Zod schemas for domain types
  - Java: Use records or immutable classes with private constructors

### Single-Purpose Functions

- **Replaces Failure Pattern:** Long Methods/Functions
- **Abstract Pattern:** Extract functions to perform one task at one level of abstraction. Functions should read like a table of contents, delegating details to lower-level functions. Aim for functions under 20 lines in most cases.
- **Framework Mappings:**
  - Clean Code: Apply Extract Method refactoring until each function has one reason to change
  - Functional Programming: Use function composition to build complex operations from simple ones
  - SOLID Principles: Apply Single Responsibility Principle at function level
- **Language Patterns:**
  - Python: Use clear function names; extract inner functions or private methods
  - TypeScript: Use arrow functions for small operations; extract named functions for clarity
  - Java: Use private methods for decomposition; apply Extract Method refactoring

### Automated Style Enforcement

- **Replaces Failure Pattern:** Inconsistent Code Style
- **Abstract Pattern:** Use automated formatters and linters integrated into development workflow and CI/CD pipeline. Remove style decisions from code review by enforcing standards automatically.
- **Framework Mappings:**
  - Pre-commit Hooks: Use Husky, pre-commit to format before commit
  - CI/CD: Fail builds on style violations; use formatters as validation steps
  - IDE Integration: Configure auto-format on save with project-wide settings
- **Language Patterns:**
  - Python: Use Black for formatting, Ruff or Flake8 for linting
  - TypeScript: Use Prettier for formatting, ESLint for code quality rules
  - Java: Use Google Java Format or Prettier Java; Checkstyle for validation

### Centralized Configuration Management

- **Replaces Failure Pattern:** Scattered Configuration
- **Abstract Pattern:** Consolidate all configuration into dedicated files or configuration management systems. Load configuration once at application startup and inject it through dependency injection or context objects.
- **Framework Mappings:**
  - 12-Factor App: Store config in environment variables; never in code
  - Spring: Use application.properties/yml with profiles for environment-specific config
  - Environment Management: Use dotenv, viper, or similar libraries for configuration loading
- **Language Patterns:**
  - Python: Use python-dotenv, pydantic Settings for typed configuration
  - TypeScript: Use dotenv with Zod validation; create typed config objects
  - Java: Use Spring @ConfigurationProperties or MicroProfile Config

## Red Flags

- Duplication percentage above 5% of total codebase
- More than 10% of functions exceed language-specific complexity thresholds
- Class or function names containing "Manager," "Utility," "Helper," "Data" without qualifiers
- Dead code percentage above 2% of total codebase
- Configuration values hardcoded in more than one location
- Inconsistent indentation or formatting across files
- Functions regularly exceeding 50 lines
- Comments explaining what code does rather than why it exists
- Multiple implementations of the same business logic
- Magic numbers without named constants
- Over 15% of codebase consists of commented-out code blocks

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| sonarqube | Code smells, duplication, cognitive complexity | primary |
| semgrep | Anti-patterns, code smells, custom rules | supporting |
| git-history | Code churn patterns, refactoring history | supporting |
| gitleaks | Hardcoded secrets in configuration | contextual |

## Standards & Frameworks

- Clean Code (Robert Martin) — principles for readable, maintainable code
- Refactoring (Martin Fowler) — catalog of code smell patterns and refactorings
- Cognitive Complexity (SonarSource) — metric for measuring code understandability
- DRY Principle (Don't Repeat Yourself) — minimizing duplication through abstraction
- Code Complete (Steve McConnell) — comprehensive guidance on code construction quality
- SOLID Principles — single responsibility applies to functions and modules

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Duplication Percentage | Percentage of codebase that is duplicated code | < 3% |
| Cognitive Complexity Average | Average cognitive complexity per function | < 10 |
| Dead Code Percentage | Percentage of codebase that is unused | < 1% |
| Code Churn Rate | Percentage of code rewritten within 3 weeks | < 15% |
| Function Length Average | Average lines of code per function | < 25 lines |
| Comment-to-Code Ratio | Ratio of comment lines to code lines | 10-20% |
