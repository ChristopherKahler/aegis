---
id: domain-00
number: "00"
name: Context & Intent
owner_agents: [principal-engineer]
---

## Overview

Covers the foundational understanding of what the system is, why it exists, who uses it, and under what constraints it operates. Context & Intent must come first in every audit — without establishing what the system is supposed to do, every other domain is partially blind. Findings in architecture, security, or performance have no severity anchor without knowing the system's business criticality, deployment model, and operational expectations.

Scope: system purpose, stakeholder expectations, deployment context, architectural intent, regulatory environment, data sensitivity classification, and operational constraints. Does NOT cover implementation details — those belong to domains 01-12. Does NOT produce technical findings — it produces the lens through which all other findings are interpreted.

## Audit Questions

- What problem is this system solving, and for whom?
- Who are the primary users, and what are their expectations for reliability and performance?
- What is the business criticality of this system (revenue-generating, cost-saving, compliance-required, internal tooling)?
- What is the deployment model (cloud, on-premise, hybrid, edge)?
- What regulatory or compliance requirements apply (GDPR, HIPAA, SOC 2, PCI-DSS, none)?
- What are the expected load patterns (steady, bursty, seasonal, event-driven)?
- What data does the system handle, and what is its sensitivity classification?
- What are the known integration points with external systems?
- What is explicitly out of scope for this system?
- Are there documented architectural decisions, and do they reflect current reality?
- What is the team size and composition maintaining this system?
- What are the known constraints (budget, timeline, team expertise, legacy dependencies)?

## Failure Patterns

### Missing System Context

- **Description:** No documentation exists describing what the system does, why it exists, or who it serves. Engineers must reverse-engineer purpose from code.
- **Indicators:**
  - No README or README contains only setup instructions without purpose statement
  - No architecture decision records (ADRs) or design documents
  - Onboarding requires synchronous knowledge transfer from specific individuals
  - Git history is the only source of "why" information
- **Severity Tendency:** high

### Intent-Implementation Drift

- **Description:** The system's actual behavior has diverged significantly from its documented or originally intended purpose, creating a gap between what stakeholders believe the system does and what it actually does.
- **Indicators:**
  - Documentation describes features or behaviors that no longer exist
  - Significant code paths that serve no current business purpose
  - Stakeholders describe the system differently than the code implements
  - Feature flags or configuration permanently set to non-default values
- **Severity Tendency:** high

### Undocumented Assumptions

- **Description:** Critical assumptions about the operating environment, data characteristics, or user behavior are embedded in code without explicit documentation, creating hidden failure modes when assumptions are violated.
- **Indicators:**
  - Hardcoded values without explanatory comments (magic numbers, URLs, thresholds)
  - Environment-specific behavior without configuration abstraction
  - Error handling that assumes specific input shapes without validation
  - Code comments like "this should never happen" or "temporary fix"
- **Severity Tendency:** medium

### Missing Threat Model

- **Description:** No documented analysis of what could go wrong, who might attack the system, or what the consequences of various failure modes would be.
- **Indicators:**
  - No threat modeling artifacts (STRIDE, attack trees, data flow diagrams)
  - Security controls implemented reactively rather than by design
  - No classification of data sensitivity levels
  - No documented trust boundaries between components
- **Severity Tendency:** high

### Stakeholder Blindness

- **Description:** The system's design does not account for all relevant stakeholders, leading to misaligned priorities and missing requirements.
- **Indicators:**
  - No documented stakeholder map or user personas
  - Operations team not consulted during design (missing observability, deployment concerns)
  - Compliance requirements discovered late in development
  - End-user feedback loop absent from development process
- **Severity Tendency:** medium

### Scope Creep Without Context Update

- **Description:** The system has grown beyond its original scope, but the contextual documentation, constraints, and architectural boundaries have not been updated to reflect the expanded responsibilities.
- **Indicators:**
  - System handles concerns far outside its original domain
  - Multiple teams depend on the system for different, sometimes conflicting purposes
  - No clear boundary between "core" functionality and "accreted" functionality
  - Resource allocation still reflects original, smaller scope
- **Severity Tendency:** medium

## Best Practice Patterns

### System Context Documentation

- **Replaces Failure Pattern:** Missing System Context
- **Abstract Pattern:** Every system should have a living document that describes its purpose, stakeholders, constraints, and operational context — maintained as a first-class artifact alongside code.
- **Framework Mappings:**
  - Arc42: Section 1 (Introduction and Goals) + Section 3 (Context and Scope)
  - C4 Model: System Context Diagram as the entry point for all architectural understanding
  - ADR (Architecture Decision Records): Lightweight decision logs capturing "why" alongside "what"
- **Language Patterns:**
  - Any: `README.md` with structured sections (Purpose, Users, Deployment, Constraints, Non-Goals)
  - Any: `docs/architecture/` directory with ADRs using the Nygard format (Title, Status, Context, Decision, Consequences)

### Living Architecture Decision Records

- **Replaces Failure Pattern:** Intent-Implementation Drift
- **Abstract Pattern:** Architectural decisions are recorded when made and updated when the system evolves, creating a traceable chain from intent to implementation that surfaces drift early.
- **Framework Mappings:**
  - MADR (Markdown ADR): Structured decision records with status tracking (proposed, accepted, deprecated, superseded)
  - Log4brains: ADR tooling that integrates decision records into CI/CD and makes them searchable
  - Lightweight ADR: Simple markdown files in `docs/decisions/` with sequential numbering
- **Language Patterns:**
  - Any: ADR files with explicit "Status" field that gets updated when decisions change
  - Any: Git commit messages that reference ADR numbers when implementing decisions

### Explicit Assumption Register

- **Replaces Failure Pattern:** Undocumented Assumptions
- **Abstract Pattern:** Assumptions about the operating environment, data characteristics, and user behavior are captured in an explicit register — each assumption has an owner, a validation method, and a consequence-if-violated statement.
- **Framework Mappings:**
  - TOGAF: Architecture Requirements Specification includes explicit assumption documentation
  - Risk Management (ISO 31000): Assumptions as risk inputs with monitoring criteria
  - Lean Architecture: Validated assumptions through hypothesis testing
- **Language Patterns:**
  - Any: `ASSUMPTIONS.md` or structured section in architecture docs listing each assumption with validation criteria
  - Any: Code comments using a structured format: `// ASSUMPTION: [statement] | VALIDATED BY: [method] | IF WRONG: [consequence]`

### Threat Model as Code

- **Replaces Failure Pattern:** Missing Threat Model
- **Abstract Pattern:** Threat modeling is treated as an ongoing, version-controlled activity that evolves with the system, not a one-time exercise.
- **Framework Mappings:**
  - STRIDE: Systematic threat categorization (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)
  - OWASP Threat Dragon: Visual threat modeling tool that produces version-controllable output
  - pytm (Python Threat Modeling): Threat models defined as code, producing data flow diagrams and threat lists
- **Language Patterns:**
  - Python: `pytm` library for defining system components and data flows as code
  - Any: YAML/JSON threat model definitions stored alongside architecture docs

### Stakeholder Map

- **Replaces Failure Pattern:** Stakeholder Blindness
- **Abstract Pattern:** All stakeholders (users, operators, maintainers, compliance, business owners) are explicitly identified with their needs, communication channels, and influence on system design.
- **Framework Mappings:**
  - Impact Mapping: Goal → Actors → Impacts → Deliverables tree connecting stakeholders to system features
  - Wardley Mapping: Value chain positioning that reveals stakeholder dependencies
  - User Story Mapping: Backbone → Walking Skeleton approach that ensures all user types are represented
- **Language Patterns:**
  - Any: `STAKEHOLDERS.md` with categorized stakeholder list (primary users, secondary users, operators, business owners)
  - Any: User persona documents with specific needs, access patterns, and quality expectations

### Scope Governance

- **Replaces Failure Pattern:** Scope Creep Without Context Update
- **Abstract Pattern:** System scope is explicitly defined and bounded, with a formal process for expanding scope that requires updating context documentation, resource allocation, and architectural boundaries.
- **Framework Mappings:**
  - DDD (Domain-Driven Design): Bounded Contexts with explicit context maps showing relationships between domains
  - Team Topologies: Stream-aligned teams with clear ownership boundaries that prevent uncontrolled scope expansion
  - TOGAF: Architecture governance including change management for scope modifications
- **Language Patterns:**
  - Any: `SCOPE.md` or scope section in architecture docs with explicit "In Scope" and "Out of Scope" lists
  - Any: Module boundary enforcement through package visibility, dependency rules, or architectural fitness functions

## Red Flags

- No README, or README contains only "how to install" without "what this is"
- No architecture documentation of any kind
- Onboarding requires specific people ("ask Sarah, she knows how it works")
- No ADRs and no design documents
- Comments in code that say "I don't know why this is here" or "legacy — don't touch"
- System handles data types not mentioned in any documentation
- Multiple conflicting descriptions of the system's purpose from different team members
- No deployment documentation or runbooks
- Configuration values that no one can explain the origin of
- Missing or outdated dependency on external systems not documented anywhere

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| git-history | Commit patterns, authorship concentration, and change frequency reveal implicit intent and knowledge distribution | contextual |
| sonarqube | Complexity metrics and code smell density hint at areas where intent may be misaligned with implementation | contextual |

## Standards & Frameworks

- ISO 25010 — Software product quality model (defines quality characteristics that context establishes priorities for)
- TOGAF — Enterprise architecture framework with structured context documentation requirements
- C4 Model — Hierarchical architecture diagramming (System Context as the outermost view)
- Arc42 — Architecture documentation template with explicit context and scope sections
- ISO 31000 — Risk management framework (assumptions as risk inputs)

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| README completeness score | Presence of purpose, users, deployment, constraints, and non-goals sections | 5/5 sections present |
| ADR count | Number of architecture decision records | ≥1 per major architectural choice |
| Documentation freshness | Time since last update to architecture/context docs | <6 months |
| Stakeholder coverage | Number of identified stakeholder types with documented needs | ≥3 stakeholder types |
| Assumption register size | Number of explicitly documented assumptions | ≥5 for non-trivial systems |
