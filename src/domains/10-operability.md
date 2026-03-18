---
id: domain-10
number: "10"
name: Operability & Developer Experience
owner_agents: [sre]
---

## Overview

Covers CI/CD pipeline quality, deployment safety, rollback capability, observability (logging, metrics, tracing), developer onboarding friction, and operational readiness. Many "great codebases" fail in production because operations was an afterthought — deployments are manual and error-prone, incidents take hours to diagnose, and new developers need weeks to become productive.

Scope: CI/CD pipeline stages and quality gates, deployment strategy and rollback procedures, observability stack (structured logging, metrics, distributed tracing), alerting, developer environment setup, documentation for operators, environment parity, and ownership clarity. Does NOT cover code quality metrics (domain 09), reliability patterns in application code (domain 07), or security of deployment infrastructure (domain 04).

## Audit Questions

- Is there an automated CI/CD pipeline, and what stages does it include (lint, test, build, deploy)?
- How frequently is the system deployed, and what is the lead time from commit to production?
- Is there a documented and tested rollback procedure?
- Is logging structured (JSON, key-value) or unstructured (free-text)?
- Are application metrics collected and exported to a monitoring system?
- Is distributed tracing implemented for cross-service request correlation?
- Are alerts actionable — does each alert have a runbook or clear next step?
- How long does it take a new developer to set up a working local environment?
- Is there environment parity — do local, staging, and production behave similarly?
- Is ownership clear — can you determine who is responsible for each component?
- Are feature flags used for safe deployment of new functionality?
- Can incidents be diagnosed from observability data alone, or do they require SSH access to production?

## Failure Patterns

### Missing CI/CD

- **Description:** No automated build, test, or deployment pipeline exists. Deployments are manual, error-prone, and dependent on specific individuals.
- **Indicators:**
  - No CI configuration files (`.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, etc.)
  - Deployment instructions reference manual steps ("SSH into server and run...")
  - No automated test execution — tests run only when developers remember
  - Build artifacts created on developer machines, not CI servers
- **Severity Tendency:** high

### Manual Deployments

- **Description:** Deployments require human intervention beyond clicking "deploy" — manual file copies, database scripts, configuration changes, or coordinated multi-step procedures.
- **Indicators:**
  - Deployment runbook with more than 3 manual steps
  - Deployment can only be performed by specific team members
  - Production configuration differs from source-controlled configuration
  - Post-deployment manual verification steps required
- **Severity Tendency:** high

### No Rollback Procedure

- **Description:** There is no documented or tested way to revert a bad deployment, making every deployment a one-way door that increases the blast radius of bugs.
- **Indicators:**
  - No documented rollback steps in deployment runbooks
  - Database migrations without `down` methods or rollback scripts
  - Deployments that destroy previous artifacts (no version retention)
  - Team has never tested a rollback in staging or production
- **Severity Tendency:** high

### Insufficient Logging

- **Description:** Logging is absent, inconsistent, or unstructured — making incident diagnosis slow and dependent on guesswork rather than data.
- **Indicators:**
  - No logging framework configured — only `console.log` / `print` statements
  - Log messages without context (no request ID, user ID, operation name)
  - Mixed log levels — DEBUG-level noise in production, ERROR-level for non-errors
  - Unstructured log format that cannot be parsed by log aggregation tools
- **Severity Tendency:** medium

### Missing Observability Stack

- **Description:** The system has no integrated observability — no metrics, no tracing, no centralized logging. Operators cannot answer "what is happening right now?" without inspecting code or databases directly.
- **Indicators:**
  - No metrics library or export configuration in the application
  - No distributed tracing headers or trace context propagation
  - Logs stored only on local disk, not shipped to a centralized system
  - Dashboards, if they exist, show only infrastructure metrics, not application metrics
- **Severity Tendency:** high

### Alert Fatigue

- **Description:** Too many alerts fire, most of which are not actionable, causing operators to ignore alerts and miss real incidents.
- **Indicators:**
  - Alerting rules that fire multiple times per day
  - Alerts without associated runbooks or severity levels
  - Team members who have muted alert channels
  - Mean time to acknowledge alerts is high (>30 minutes)
  - Alerts on metrics with no defined healthy range or SLO
- **Severity Tendency:** medium

### Slow Developer Onboarding

- **Description:** New developers cannot get a working local environment or make meaningful contributions without extensive help from existing team members.
- **Indicators:**
  - Setup documentation is outdated or incomplete
  - Local setup requires installing specific OS-level dependencies manually
  - No containerized development environment (Docker Compose, devcontainers)
  - First PR takes weeks instead of days
  - "Works on my machine" incidents are common
- **Severity Tendency:** medium

### Missing Environment Parity

- **Description:** Local, staging, and production environments behave differently, causing bugs that appear only in production and making staging unreliable for validation.
- **Indicators:**
  - Different databases in different environments (SQLite locally, PostgreSQL in production)
  - Environment-specific code branches (`if (process.env.NODE_ENV === 'production')` containing business logic)
  - Staging has different resource constraints, feature flags, or data shapes than production
  - "Works in staging, fails in production" incidents are recurring
- **Severity Tendency:** medium

## Best Practice Patterns

### Automated CI/CD Pipeline

- **Replaces Failure Pattern:** Missing CI/CD
- **Abstract Pattern:** Every commit triggers an automated pipeline that lints, tests, builds, and produces deployable artifacts. The pipeline is the authoritative build mechanism — no artifacts are created outside of CI.
- **Framework Mappings:**
  - GitHub Actions: Workflow files in `.github/workflows/` with lint, test, build, deploy stages and environment protection rules
  - GitLab CI: `.gitlab-ci.yml` with staged pipeline (test → build → staging → production) and manual promotion gates
  - ArgoCD/Flux: GitOps — infrastructure changes are PRs, deployments happen automatically when manifests merge
- **Language Patterns:**
  - Any: Pipeline-as-code checked into the repository alongside application code
  - Any: Deployment requires only a merge to the main branch (or a manual approval click) — never SSH or manual scripts

### Push-Button Deployments

- **Replaces Failure Pattern:** Manual Deployments
- **Abstract Pattern:** Deployment is a single action — a button click, a merged PR, or a CLI command — with no manual steps, SSH sessions, or coordination calls required. The deployment system handles all sequencing, configuration, and verification.
- **Framework Mappings:**
  - GitHub Actions: Deployment workflows triggered by merge to main, with environment protection rules for production gates
  - AWS CodePipeline: Source → Build → Deploy stages with automatic progression and manual approval gate for production
  - Heroku/Railway/Fly.io: Git push triggers automatic build and deploy with zero manual infrastructure steps
- **Language Patterns:**
  - Any: `git push origin main` or merge PR as the only action needed to deploy
  - Any: Deployment configuration (Procfile, Dockerfile, buildpack) checked into the repository

### Blue-Green / Canary Deployments

- **Replaces Failure Pattern:** No Rollback Procedure
- **Abstract Pattern:** New versions are deployed alongside the current version. Traffic is gradually shifted to the new version, with automatic rollback if error rates increase. Rolling back is as simple as shifting traffic back.
- **Framework Mappings:**
  - Kubernetes: Rolling update strategy with `maxSurge` and `maxUnavailable`, or Argo Rollouts for canary/blue-green
  - AWS: Blue-green via CodeDeploy with automatic rollback on CloudWatch alarm
  - Istio/Linkerd: Traffic splitting with weighted routing (90/10, 50/50) during canary progression
- **Language Patterns:**
  - Any: Feature flags for dark launching — new code deployed but inactive until flag enables it
  - Any: Database migration compatibility — new code works with both old and new schema during transition

### Structured Logging

- **Replaces Failure Pattern:** Insufficient Logging
- **Abstract Pattern:** All log entries are structured (JSON or key-value), include standard context fields (timestamp, request ID, severity, service name), and are shipped to a centralized logging system for search and analysis.
- **Framework Mappings:**
  - Winston (Node.js): JSON transport with custom fields, request ID middleware, log level filtering
  - Logback/SLF4J (Java): Structured JSON encoder with MDC (Mapped Diagnostic Context) for request-scoped fields
  - structlog (Python): Processor pipeline adding context automatically, JSON serialization, bound loggers
- **Language Patterns:**
  - Any: Log format: `{"timestamp": "...", "level": "info", "request_id": "...", "service": "...", "message": "...", "data": {...}}`
  - Any: Request ID generated at edge and propagated through all service calls for correlation

### Distributed Tracing

- **Replaces Failure Pattern:** Missing Observability Stack
- **Abstract Pattern:** Every request entering the system receives a trace ID that propagates through all services and operations. Each operation is a span within the trace. Traces are collected centrally for latency analysis, dependency mapping, and error localization.
- **Framework Mappings:**
  - OpenTelemetry: Vendor-neutral SDK for traces, metrics, and logs with auto-instrumentation for popular frameworks
  - Jaeger: Distributed tracing backend with dependency graphs and latency histograms
  - Datadog APM: Automatic tracing with service maps, error tracking, and latency percentile dashboards
- **Language Patterns:**
  - Any: W3C Trace Context headers (`traceparent`, `tracestate`) propagated in all inter-service HTTP calls
  - Any: OpenTelemetry SDK initialization in application startup with automatic HTTP/database instrumentation

### Infrastructure as Code

- **Replaces Failure Pattern:** Missing Environment Parity
- **Abstract Pattern:** All infrastructure (servers, databases, networking, permissions) is defined in version-controlled code that produces identical environments. No configuration exists only in a cloud console or on a server.
- **Framework Mappings:**
  - Terraform: Declarative infrastructure definitions with state management and plan/apply workflow
  - Pulumi: Infrastructure as real code (TypeScript, Python, Go) with testing, refactoring, and IDE support
  - Docker Compose: Local environment matching production topology with service definitions, networks, and volumes
- **Language Patterns:**
  - Any: `docker-compose.yml` for local development matching production service topology
  - Any: Environment variables for configuration differences, not code branches

### Developer Environment Automation

- **Replaces Failure Pattern:** Slow Developer Onboarding
- **Abstract Pattern:** A new developer can go from clone to running application in one command. Development environments are containerized or automated with dependency management built in. No manual installation of language runtimes, databases, or services required.
- **Framework Mappings:**
  - DevContainers: VS Code dev containers with all dependencies pre-configured
  - Nix/Devbox: Reproducible development environments with declarative dependency specifications
  - Make/Task: `make dev` or `task dev` as single entry point that sets up and starts everything
- **Language Patterns:**
  - Any: `README.md` quick start: `git clone && make dev` (two commands maximum)
  - Any: `.tool-versions` (asdf) or `.nvmrc` / `.python-version` for language runtime version pinning

### Intentional Alerting

- **Replaces Failure Pattern:** Alert Fatigue
- **Abstract Pattern:** Every alert is actionable, owned, and linked to a runbook. Alerts fire only when human intervention is needed. Non-actionable signals are dashboards and metrics, not alerts. Alert volume is treated as a quality metric.
- **Framework Mappings:**
  - PagerDuty: Escalation policies with alert grouping, suppression for known transient issues, and service-level ownership
  - Prometheus Alertmanager: Alert routing by severity and team, inhibition rules to suppress dependent alerts, grouping to reduce noise
  - Datadog Monitors: Multi-condition alerts with recovery thresholds, composite monitors to reduce false positives
- **Language Patterns:**
  - Any: Alert annotations include `runbook_url`, `owner`, and `severity` fields as mandatory metadata
  - Any: Alert audit process — review all firing alerts monthly, delete or tune alerts that fire without action taken

## Red Flags

- No CI configuration files in the repository
- Deployment documentation with more than 5 manual steps
- `console.log` / `print` as the only logging mechanism
- No monitoring or metrics library in dependencies
- README setup instructions that are clearly outdated ("install Node 12")
- Environment-specific business logic in if/else blocks
- No `.env.example` or environment variable documentation
- Alerts firing more than 10 times per day in non-incident periods
- Developer setup requiring manual database seeding or configuration file creation
- No rollback mentioned in any deployment documentation

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| checkov | Infrastructure-as-code configuration scanning — Terraform, CloudFormation, Kubernetes manifests for security and best practices | primary |
| git-history | Deployment frequency (tagged releases, merge-to-main cadence), lead time indicators | primary |
| sonarqube | Code quality metrics as CI quality gate — technical debt, coverage, duplication | supporting |
| gitleaks | Secrets in CI/CD configuration files, environment files, deployment scripts | supporting |

## Standards & Frameworks

- DORA metrics — Deployment Frequency, Lead Time for Changes, Mean Time to Recovery, Change Failure Rate as measures of software delivery performance
- The Twelve-Factor App — Methodology for building modern, deployment-friendly applications (config, dependencies, logs, disposability)
- SRE principles (Google) — Service Level Objectives, error budgets, toil reduction, postmortem culture
- GitOps (Weaveworks) — Infrastructure and application changes managed through Git as single source of truth
- OpenTelemetry — Vendor-neutral observability framework for traces, metrics, and logs

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Deployment frequency | How often code is deployed to production | Multiple times per week to multiple times per day |
| Lead time for changes | Time from commit to production deployment | <1 day (elite), <1 week (high) |
| Mean time to recovery (MTTR) | Time from incident detection to resolution | <1 hour (elite), <1 day (high) |
| Change failure rate | Percentage of deployments causing incidents | <15% |
| Developer setup time | Time from clone to working local environment | <30 minutes |
| Alert-to-runbook coverage | Percentage of alerts linked to documented runbooks | >90% |
