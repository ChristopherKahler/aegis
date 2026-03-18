---
id: domain-12
number: "12"
name: Team Ownership & Knowledge Risk
owner_agents: [staff-engineer]
---

## Overview

Team Ownership & Knowledge Risk evaluates the human sustainability of a codebase through authorship patterns, knowledge distribution, and collaborative practices. This domain identifies single points of failure in team knowledge, documentation gaps, and cultural risks around code review and ownership transitions. Systems fail socially before they fail technically—concentrated knowledge creates organizational fragility regardless of code quality. This domain does NOT cover code health metrics (domain 09), change impact analysis (domain 11), or risk synthesis across domains (domain 13).

## Audit Questions

- What is the bus factor for each critical module, and which components have single-author dependency?
- Where is tribal knowledge concentrated, and what documentation exists to mitigate knowledge loss?
- How many modules have no active maintainer or have been abandoned by their original authors?
- What percentage of changes receive meaningful code review, and what is the review-to-approval time distribution?
- Which subsystems have high author concentration (Gini coefficient >0.7), indicating knowledge silos?
- How many critical components lack comprehensive documentation or have documentation older than the code?
- What is the onboarding time for new contributors to become productive in each major subsystem?
- Are there modules where only one person has committed in the last 6 months?
- How consistent are review standards across teams, and are there bypassed review requirements?
- What percentage of commits include documentation updates, and what is the documentation debt ratio?
- How many knowledge transfer events have occurred in the past year (pairing sessions, design reviews, runbooks)?
- Which components have the longest time-to-first-external-contribution, indicating high entry barriers?

## Failure Patterns

### Single-Author Modules
- **Description:** Critical components where >80% of commits come from a single author, creating extreme bus factor risk and knowledge bottlenecks that threaten continuity.
- **Indicators:**
  - Author concentration Gini coefficient >0.8 for modules with >1000 LOC
  - No commits from secondary authors in the last 90 days
  - Module fails to build or deploy when primary author is unavailable
  - Onboarding documentation explicitly references "ask [person]" for critical knowledge
- **Severity Tendency:** high

### Knowledge Silos
- **Description:** Teams or subsystems where knowledge is concentrated within small groups with no cross-pollination, creating organizational fragility and collaboration barriers.
- **Indicators:**
  - <3 people have committed to a subsystem in the last 180 days
  - No cross-team code review activity in shared interfaces
  - Design decisions documented in private channels or not at all
  - New team members require >30 days to make first meaningful contribution
- **Severity Tendency:** high

### Missing Code Review Culture
- **Description:** Significant percentage of changes merged without peer review, bypassing quality gates and knowledge sharing opportunities that prevent defects and spread understanding.
- **Indicators:**
  - >20% of commits pushed directly to main branch without PR
  - Average review-to-approval time <10 minutes, indicating rubber-stamp reviews
  - PRs with >500 LOC changes approved with zero comments
  - Review bypass patterns during "crunch time" or by senior engineers
- **Severity Tendency:** medium

### Documentation Debt
- **Description:** Critical components lack current documentation, or documentation age significantly exceeds code age, creating barriers to understanding and maintenance.
- **Indicators:**
  - >40% of modules have no README or design documentation
  - Documentation last-modified date >12 months older than latest code changes
  - Onboarding requires >10 questions to senior engineers about undocumented subsystems
  - Zero runbooks or operational guides for production systems
- **Severity Tendency:** medium

### Tribal Knowledge Dependencies
- **Description:** Essential operational knowledge exists only in human memory or private notes, not in accessible artifacts, creating catastrophic failure risk when key people depart.
- **Indicators:**
  - Deployment procedures exist only as Slack messages or verbal instructions
  - Critical configuration parameters documented in personal notes or wikis with access restrictions
  - Incident response requires specific individuals with undocumented mental models
  - "Oral tradition" references in team communication about how systems actually work
- **Severity Tendency:** critical

### Abandoned Code Ownership
- **Description:** Modules with no clear current owner, where the original author has left or moved on, creating accountability gaps and maintenance neglect.
- **Indicators:**
  - CODEOWNERS file missing or >50% entries reference departed team members
  - Zero commits to module in last 180 days despite open bug reports
  - Pull requests to module sit unreviewed for >30 days
  - Module excluded from refactoring or upgrade initiatives due to "no one understands it"
- **Severity Tendency:** high

### Inconsistent Review Standards
- **Description:** Different teams or individuals apply wildly different review rigor, creating quality variance and cultural friction that undermines trust in the review process.
- **Indicators:**
  - Reviewer X approves 95% of PRs within 5 minutes; Reviewer Y averages 45 minutes with detailed feedback
  - Some teams require 2+ approvals; others allow single-approval merge
  - Security/performance issues caught in production that were visible in reviewed PRs
  - Team retrospectives mention "review lottery" or reviewer shopping behavior
- **Severity Tendency:** medium

## Best Practice Patterns

### Distributed Ownership
- **Replaces Failure Pattern:** Single-Author Modules
- **Abstract Pattern:** Critical components maintained by 3+ active contributors with balanced commit distribution, ensuring knowledge redundancy and sustainable maintenance through collaborative stewardship.
- **Framework Mappings:**
  - GitHub CODEOWNERS: Require 2+ reviewers from different teams for protected modules
  - GitLab Code Owners: Use group-based ownership with mandatory secondary reviewers
  - Azure DevOps: Configure branch policies requiring multi-team approval for critical paths
- **Language Patterns:**
  - Microservices (any language): Rotate on-call ownership quarterly to spread operational knowledge
  - Monorepo (TypeScript/Go): Use package-level CODEOWNERS with explicit fallback reviewers
  - Infrastructure (Terraform/Kubernetes): Require platform team + product team dual approval

### Cross-Team Knowledge Sharing
- **Replaces Failure Pattern:** Knowledge Silos
- **Abstract Pattern:** Scheduled knowledge transfer activities, cross-team pairing rotations, and shared documentation practices that build organizational resilience through deliberate knowledge distribution.
- **Framework Mappings:**
  - Team Topologies: Implement "community of practice" groups for shared technical domains
  - Spotify Model: Host guild meetings for architecture, security, and operations knowledge sharing
  - DevOps: Embed SRE engineers with product teams for bidirectional knowledge flow
- **Language Patterns:**
  - Backend teams: Monthly architecture deep-dives with rotation presenters from different teams
  - Frontend teams: Shared component library ownership with contribution guidelines requiring cross-team review
  - Data teams: Weekly data model review sessions with product and engineering representation

### Rigorous Review Process
- **Replaces Failure Pattern:** Missing Code Review Culture
- **Abstract Pattern:** Mandatory peer review with clear standards, review checklists, and metrics tracking review quality, ensuring every change receives thoughtful scrutiny before integration.
- **Framework Mappings:**
  - GitHub: Use required reviewers, status checks, and review assignment automation (CODEOWNERS)
  - GitLab: Configure approval rules with eligible approvers and required approval count
  - Gerrit: Enforce verified+2 from CI and code-review+2 from human before submit
- **Language Patterns:**
  - Pull request templates: Include security checklist, test coverage requirements, and breaking change assessment
  - Review bots: Automate size limits (<400 LOC), test coverage gates (>80%), and documentation checks
  - Review guidelines: Publish standards for response time (24h), approval criteria, and constructive feedback tone

### Living Documentation
- **Replaces Failure Pattern:** Documentation Debt
- **Abstract Pattern:** Documentation colocated with code, updated in the same commits as implementation changes, with CI enforcement and regular audits to maintain accuracy and relevance.
- **Framework Mappings:**
  - Docs-as-code: Markdown in repository, versioned with code, published via CI (Docusaurus, MkDocs, Sphinx)
  - ADR (Architecture Decision Records): Lightweight decisions in docs/adr/ directory, numbered and immutable
  - README-driven development: Write README before implementation, update in same PR as code changes
- **Language Patterns:**
  - Rust: Use `cargo doc` with enforced `#![warn(missing_docs)]` for public APIs
  - TypeScript: Generate API docs from TSDoc comments via TypeDoc, published automatically
  - Python: Maintain Sphinx documentation with docstring coverage >90%, checked in CI

### Explicit Knowledge Capture
- **Replaces Failure Pattern:** Tribal Knowledge Dependencies
- **Abstract Pattern:** Operational runbooks, architecture decision records, and incident postmortems as first-class artifacts, reviewed and updated with the same rigor as code.
- **Framework Mappings:**
  - SRE runbooks: Step-by-step procedures for deployment, rollback, and incident response in shared wiki
  - PagerDuty runbooks: Linked from alerts with copy-paste commands and decision trees
  - Incident retrospectives: Blameless postmortems with action items tracked in ticketing system
- **Language Patterns:**
  - Kubernetes: Document deployment topologies with diagrams, config explanations, and troubleshooting steps
  - AWS: Maintain infrastructure-as-code with inline comments explaining non-obvious design decisions
  - Database: Create migration runbooks documenting rollback procedures and data validation steps

### Active Maintainership
- **Replaces Failure Pattern:** Abandoned Code Ownership
- **Abstract Pattern:** Explicit ownership assignments with accountability for responsiveness, regularly audited and reassigned as team composition changes, ensuring every component has an engaged steward.
- **Framework Mappings:**
  - CODEOWNERS file: Updated quarterly with current team members, synced to org chart
  - Service catalog: Document owner, on-call rotation, and escalation path for each service
  - Ownership dashboard: Visualize modules with inactive owners, flagging reassignment needs
- **Language Patterns:**
  - Microservices: Each service has named owner team with SLO commitments and support tier
  - Libraries: Package.json or setup.py includes maintainers field, synced to GitHub team
  - Infrastructure: Terraform modules have provider blocks with owner annotations and review requirements

### Standardized Review Criteria
- **Replaces Failure Pattern:** Inconsistent Review Standards
- **Abstract Pattern:** Documented review guidelines with checklists, training for reviewers, and periodic calibration sessions to align expectations and maintain quality standards across teams.
- **Framework Mappings:**
  - Review guidelines doc: Published standards covering correctness, readability, security, and test coverage
  - Review training program: Onboard new reviewers with shadowing and calibration exercises
  - Review metrics dashboard: Track approval rates, comment depth, and review time by reviewer to identify outliers
- **Language Patterns:**
  - Code review checklist: Security (input validation, auth), performance (algorithmic complexity), maintainability (naming, modularity)
  - Review escalation: Require senior engineer review for PRs touching critical paths or changing interfaces
  - Review retrospectives: Quarterly calibration sessions where team reviews same PR and compares feedback

## Red Flags

- Single commit author for entire module with >5000 LOC
- CODEOWNERS file not updated in >12 months
- >30% of PRs merged with zero review comments
- Documentation directory last touched >2 years ago
- No ADRs or design docs for system with >50K LOC
- Critical deployment procedure exists only in Slack history
- On-call runbook says "call [specific person]" instead of providing steps
- Module has open PRs from 6+ months ago with no reviewer assignment
- New hire onboarding checklist includes >10 "ask [person]" items
- Team retrospectives repeatedly mention knowledge silos as blocker
- Production incident required 2+ hours to find someone who understood system

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| git-history | Author concentration per module, commit timeline by contributor, review participation | primary |
| git-history | Bus factor calculation, abandoned file detection (no commits in 180+ days) | primary |
| git-history | Documentation staleness (last-modified dates relative to code) | primary |
| SonarQube | Code review coverage metrics, PR decoration with quality gates | contextual |

## Standards & Frameworks

- **Team Topologies** — Stream-aligned teams, enabling teams, and community of practice models for knowledge sharing
- **DevOps Research (DORA)** — Elite performer characteristics include low bus factor and high review participation
- **Conway's Law** — System design mirrors communication structure; ownership patterns reveal architectural coupling
- **Spotify Model** — Guilds and chapters as knowledge-sharing mechanisms across squad boundaries
- **CODEOWNERS (GitHub/GitLab)** — Explicit ownership declarations with review enforcement
- **SRE Principles (Google)** — On-call rotations and runbook culture as operational knowledge distribution

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Bus Factor (per module) | Minimum number of contributors who must leave before knowledge loss becomes critical | ≥3 for critical modules |
| Author Concentration (Gini) | Distribution inequality of commits across contributors (0=equal, 1=monopoly) | <0.6 for critical modules |
| Review Coverage | Percentage of commits that went through peer review before merge | >90% |
| Review Comment Depth | Average comments per reviewed PR, indicating engagement quality | 2-8 comments |
| Documentation Freshness | Ratio of documentation age to code age (days since doc update / days since code update) | <0.5 (docs updated at least half as recently) |
| Time to First Contribution | Days for new contributor to land first merged PR, indicating entry barriers | <30 days |
| Abandoned Module Count | Modules with zero commits in last 180 days and open issues | 0 |
| Onboarding Dependency | Number of "ask [person]" items in onboarding checklist, indicating tribal knowledge | <3 |
