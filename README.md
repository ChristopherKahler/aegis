# AEGIS

**Automated Epistemic Governance & Intelligence System**

---

## Identity

**AEGIS** (/ee-jis/) — In Greek mythology, the aegis was the divine shield carried by Zeus and Athena. It represented protection under authority — not passive defense, but the active, authoritative safeguarding of what matters.

AEGIS is that shield for codebases.

The name encodes what the system actually does:

- **Automated** — Multi-agent, multi-phase, tool-augmented analysis requiring no manual orchestration
- **Epistemic** — Built on a formal schema for how knowledge is structured, challenged, and trusted under uncertainty
- **Governance** — Compliance, oversight, and the Principal Engineer's role as epistemic governor of the entire audit
- **Intelligence** — AI-powered domain expert agents producing findings no single human could match in breadth
- **System** — Not a tool, not a script. A coordinated system of systems with defined phases, roles, and accountability

---

## What AEGIS Is

AEGIS is a **multi-session, multi-agent codebase audit system** built on Claude Code. It deploys a team of senior engineering personas — each an expert in a specific domain — to conduct a comprehensive analysis of any application codebase.

It is not a linter. It is not a static analyzer. It is not a report generator.

It is **an AI Principal Engineer** — a machine that performs disciplined doubt.

AEGIS answers five fundamental questions that senior engineers ask when they walk into an unknown codebase:

1. Can this system be **trusted**?
2. Can it survive **change**?
3. Can it **scale**?
4. Can it be **operated safely**?
5. Can new engineers **understand** it?

Every audit produces findings across all domains, uses structured epistemic reasoning, cross-validates through adversarial review, and synthesizes into actionable, severity-ranked reports.

---

## Core Philosophy

> Senior engineers don't just find bugs — they find **future failures**.

Three principles distinguish AEGIS from conventional code analysis:

1. **Disciplined Doubt Over Coherent Confidence** — Most AI systems optimize for helpfulness and clean narratives. AEGIS optimizes for correctness under uncertainty, asymmetric risk detection, and institutional memory of failure patterns.

2. **The Principal Builds the Story. The Devil's Advocate Breaks It. Truth Lives in the Tension.** — No finding survives without challenge. No conclusion is trusted without adversarial review. Disagreement is signal, not noise.

3. **Evidence > Assumptions > Code > Documentation** — The epistemic schema enforces a strict separation between observations, interpretations, and judgments. No shortcuts. No opinion soup.

---

## The 14 Audit Domains

AEGIS audits across 14 domains (0-13). Every audit produces findings in each domain — even if the finding is "no major issues found." Nothing is optional.

### Domain 0 — Context & Intent

**Must come first. Without this, every other audit is partially blind.**

| Aspect | Details |
|---|---|
| Owner | Principal Engineer |
| Purpose | Establish what the system does, who uses it, what constraints exist |

What to audit:
- What problem is this system solving?
- Who are the users?
- What are success/failure criteria?
- What data does it handle?
- What are its failure modes?
- What is the business criticality?
- What constraints exist (regulatory, cost, latency, team size)?
- What is explicitly OUT of scope?

### Domain 1 — Architecture & System Design

| Aspect | Details |
|---|---|
| Owner | Architect Agent |
| Why it matters | Architecture determines how easy bugs are to introduce, how expensive changes are, and whether scale is possible without rewrites |

What to audit:
- System boundaries and module responsibilities
- Dependency direction and layering consistency
- Coupling vs cohesion
- Domain modeling quality
- Data flow clarity
- Presence of clear architectural pattern (hexagonal, layered, microservices, etc.)
- Boundary enforcement vs violation
- "God modules" or "utility dumping grounds"
- Domain logic mixed with infrastructure

Key questions:
- Is there a clear architectural pattern?
- Are boundaries enforced or violated?
- Are "god modules" present?
- Is domain logic mixed with infrastructure?

### Domain 2 — Data & State Integrity

| Aspect | Details |
|---|---|
| Owner | Data Engineer Agent |
| Why it matters | Most catastrophic failures are data bugs, not code bugs — corrupt state, irreversible migrations, silent data loss, inconsistent derived data |

What to audit:
- Data models and schemas
- Schema evolution and migrations
- Backward compatibility
- Referential integrity
- Eventual consistency guarantees
- State transitions and invariants
- Data loss risks

### Domain 3 — Correctness & Logic

| Aspect | Details |
|---|---|
| Owner | Senior Application Engineer Agent |
| Why it matters | Most production incidents are boring logic bugs, not exotic failures |

What to audit:
- Logic errors and edge case handling
- Error propagation (swallowed, ignored, or properly handled)
- Concurrency correctness
- Input validation
- Data consistency
- Assumption documentation (documented or implicit)
- Invariant enforcement
- Retry safety (idempotency)

### Domain 4 — Security

| Aspect | Details |
|---|---|
| Owner | Security Engineer Agent |
| Why it matters | Security failures are existential risks |

What to audit:
- Authentication and authorization (AuthN/AuthZ)
- Secrets handling
- Input sanitization
- Injection risks (SQL, XSS, command, etc.)
- Dependency vulnerabilities
- Cryptography misuse
- Supply chain risk
- Trust boundaries
- Least-privilege enforcement
- Sensitive data in logs

### Domain 5 — Compliance, Privacy & Governance

| Aspect | Details |
|---|---|
| Owner | Compliance Officer Agent |
| Why it matters | Compliance failures lead to fines, lawsuits, and shutdowns |

What to audit:
- PII handling and data classification
- Data retention policies
- Encryption at rest and in transit
- Audit logging
- Consent tracking
- Where personal data is stored
- How personal data is deleted
- Whether access is auditable

### Domain 6 — Testing Strategy & Verification

| Aspect | Details |
|---|---|
| Owner | Test Engineer Agent |
| Why it matters | Senior engineers don't ask "Do you have tests?" — they ask "Would these tests catch the most expensive failures?" |

What to audit:
- Test pyramid shape (unit vs integration vs e2e balance)
- Determinism vs flakiness
- What ISN'T tested (gaps)
- Mutation resistance
- Contract testing presence
- Tests as documentation
- Failure coverage (do tests cover failure paths, not just happy paths?)

### Domain 7 — Reliability & Resilience

| Aspect | Details |
|---|---|
| Owner | SRE Agent |
| Why it matters | Production systems fail constantly — good ones degrade gracefully |

What to audit:
- Failure handling patterns
- Retry strategies (bounded? with backoff?)
- Timeouts
- Circuit breakers
- Startup/shutdown safety
- What happens when dependencies fail
- Whether failures are noisy or silent
- State recoverability

### Domain 8 — Scalability & Performance

| Aspect | Details |
|---|---|
| Owner | Performance Engineer Agent |
| Why it matters | Scaling failures are often design bugs, not hardware limits |

What to audit:
- Algorithmic complexity
- N+1 queries
- Caching strategy
- Resource usage patterns
- Async vs blocking behavior
- What grows with user count
- What grows with data size
- Where bottlenecks exist
- Whether backpressure is implemented

### Domain 9 — Maintainability & Code Health

| Aspect | Details |
|---|---|
| Owner | Senior Application Engineer Agent |
| Why it matters | Maintenance cost dominates total lifecycle cost |

What to audit:
- Code smells and duplication
- Naming clarity
- Documentation accuracy
- Whether intent is obvious
- Whether tests are meaningful or superficial
- Tech debt interest accruing

### Domain 10 — Operability & Developer Experience

| Aspect | Details |
|---|---|
| Owner | SRE Agent |
| Why it matters | Many "great codebases" fail in production because ops was ignored |

What to audit:
- CI/CD pipelines
- Rollback safety
- Feature flags
- Observability (logging, metrics, tracing)
- Ownership clarity
- Debuggability
- Local dev friction
- Can this be safely deployed on Friday?
- Can incidents be diagnosed quickly?
- Who owns what?

### Domain 11 — Change Risk & Evolvability

| Aspect | Details |
|---|---|
| Owner | Staff Engineer / Tech Lead Agent |
| Why it matters | "How dangerous is it to touch this code?" predicts velocity decay, team burnout, and rewrite pressure |

What to audit:
- Change amplification (how many files does one change touch?)
- Refactor safety
- Blast radius analysis
- Modularity health
- How risky future changes are

### Domain 12 — Team, Ownership & Knowledge Risk

| Aspect | Details |
|---|---|
| Owner | Staff Engineer / Tech Lead Agent |
| Why it matters | Systems fail socially before they fail technically |

What to audit:
- Code authorship concentration
- Bus factor per module
- Tribal knowledge hotspots
- Documentation debt
- Review culture artifacts
- Knowledge silos

### Domain 13 — Risk Synthesis & Forecasting

| Aspect | Details |
|---|---|
| Owner | Principal Engineer Agent |
| Why it matters | Senior engineers think in predictions: "This will break in 3 months," "This will fail at 10x traffic," "This is safe unless compliance changes" |

What to synthesize:
- Likelihood x impact for all findings
- Time-to-failure predictions
- "What breaks first" analysis
- Risk acceptance vs remediation recommendations
- Cross-domain emergent risks

---

## The Agent Team

AEGIS deploys a minimal-complete set of agent personas. Each exists because removing it would leave a blind spot. No overlap, no bloat.

### 1. Principal Engineer

**Role:** Epistemic governor of the entire audit

The Principal Engineer is NOT the best coder, architect, or the most knowledgeable in every domain. They are the person accountable for the **correctness of collective reasoning**.

**Core mental models:**
- Thinks in systems of systems — "What behavior emerges from these interactions?"
- Separates facts, interpretations, and judgments (enforces the epistemic schema)
- Actively manages uncertainty — budgets it rather than eliminating it
- Thinks in time horizons (immediate, near-term, long-term, hypothetical)
- Optimizes organizational attention, not code

**Responsibilities:**
1. Define audit scope and non-goals (Phase 0)
2. Calibrate severity scales
3. Resolve cross-domain conflicts
4. Synthesize narrative
5. Forecast future failure
6. Translate findings for multiple audiences
7. Own the final call
8. Explicitly respond to every Devil's Advocate critique

**Must never:**
- Introduce new raw findings late
- Re-run tools
- Argue minutiae

They reason, arbitrate, and narrate.

**Active in:** Phase 0 (Context), Phase 5 (Synthesis)

### 2. Architect

**Domains:** 1 (Architecture & System Design)

Evaluates structural patterns, boundaries, dependency direction, coupling, cohesion, and whether the architecture can support the system's actual requirements.

### 3. Data Engineer

**Domains:** 2 (Data & State Integrity)

Evaluates data models, schema evolution, migrations, referential integrity, consistency guarantees, and state transition safety.

### 4. Security Engineer

**Domains:** 4 (Security)

Evaluates AuthN/AuthZ, secrets handling, injection risks, supply chain, cryptography, trust boundaries, and attacker models.

### 5. Compliance Officer

**Domains:** 5 (Compliance, Privacy & Governance)

Evaluates PII handling, data retention, encryption, audit logging, consent tracking, and regulatory exposure.

### 6. Senior Application Engineer

**Domains:** 3 (Correctness & Logic), 9 (Maintainability & Code Health)

Evaluates logic correctness, error handling, edge cases, idempotency, code smells, naming, duplication, and intent clarity.

### 7. SRE (Site Reliability Engineer)

**Domains:** 7 (Reliability & Resilience), 10 (Operability & DevEx)

Evaluates failure handling, retries, timeouts, circuit breakers, CI/CD, rollback safety, observability, and operational readiness.

### 8. Performance Engineer

**Domains:** 8 (Scalability & Performance)

Evaluates algorithmic complexity, N+1 queries, caching, resource usage, async behavior, bottlenecks, and backpressure.

### 9. Test Engineer

**Domains:** 6 (Testing Strategy & Verification)

Evaluates test pyramid, determinism, mutation resistance, contract tests, failure coverage, and test-as-documentation quality.

### 10. Staff Engineer / Tech Lead

**Domains:** 11 (Change Risk & Evolvability), 12 (Team, Ownership & Knowledge Risk)

Evaluates change amplification, refactor safety, blast radius, bus factor, knowledge silos, and documentation debt. This is a synthesis-heavy role that draws on git history and social signals.

### 11. Reality Gap Analyst

**Purpose:** Detect divergence between "code as written" and "system as run"

This agent often finds: "The audit is technically correct but operationally wrong." Audits config files, environment-specific behavior, feature flags, deployment manifests, runtime overrides, and kill switches.

See [Reality Gap Framework](#reality-gap-framework) for full details.

### 12. Devil's Advocate Reviewer

**Purpose:** Hunt collective blind spots

The Devil's Advocate is NOT a contrarian, NOT "the negative one," NOT "the security pessimist." They are the agent that hunts collective blind spots.

**Why this role exists:**
Every audit naturally develops consensus gravity, optimism bias, tool bias ("the scanner didn't find anything"), and authority bias. The Devil's Advocate exists to break coherence.

**Core mental models:**
- Assume the model is wrong: "If this report is wrong, *how* would it be wrong?"
- Attack confidence, not just conclusions — target high-confidence claims, clean narratives, and areas with little disagreement
- Seek asymmetric failure: "What failure would be disproportionately damaging relative to how little we're talking about it?"
- Use inversion relentlessly: "Under what conditions does this become unsafe?"
- Do NOT propose solutions — solutions dilute the critique

**Outputs:**
1. Most confident claim I distrust
2. Least discussed but highest-impact risk
3. Assumptions that must hold for conclusions to be true
4. Evidence that was overweighted
5. Evidence that was ignored or unavailable
6. Alternate narrative that fits the data

**Critical rule:** If the Devil's Advocate panel is empty, the system is broken.

---

## Execution Phases

AEGIS executes in six phases. Order matters.

### Phase 0 — Context & Threat Modeling

**Agent:** Principal Engineer

Establish intent, constraints, risk profile, and non-goals. Without this phase, all audits are shallow.

Inputs: Repository, documentation, README, deployment configs, any available business context.

Outputs: Audit scope document, threat model, risk profile, explicit non-goals.

### Phase 1 — Automated Signal Gathering

**Agents:** Tool runners (non-reasoning heavy)

Run automated tools. Gather signals across six orthogonal dimensions. No opinions yet. Just evidence.

**Signal dimensions:**
1. **Structure** — SonarQube, CodeScene, dependency graphs
2. **Behavior** — Profilers, async analysis
3. **History** — Git churn, file age vs modification frequency, author concentration
4. **Dependencies** — Trivy, Syft + Grype, OpenSSF Scorecard
5. **Policy posture** — Checkov, Gitleaks, Semgrep
6. **Runtime contracts** — OpenAPI/gRPC schema validation, backward compatibility

Outputs: Normalized signal data tagged with severity, confidence, blast radius, and domain relevance.

### Phase 2 — Deep Domain Audits

**Agents:** Architect, Data Engineer, Security Engineer, Compliance Officer, Senior Application Engineer, SRE, Performance Engineer, Test Engineer

Each agent audits ONLY their assigned domains. Each receives the same Phase 1 evidence. Each produces independent findings using the formal epistemic schema.

Sessions can run in parallel. Each produces a structured findings file.

### Phase 3 — Change Risk, Team Risk & Reality Gap

**Agents:** Staff Engineer / Tech Lead, Reality Gap Analyst

Synthesis-heavy roles that draw on Phase 2 findings + git history + configuration analysis.

The Staff Engineer evaluates change risk and ownership risk.
The Reality Gap Analyst checks for divergence between code-as-written and system-as-run.

### Phase 4 — Adversarial Review ("Fresh Eyes")

**Agent:** Devil's Advocate Reviewer

Goal: Invalidate conclusions, not agree. A fresh session whose only job is to challenge assumptions, attack confidence, and surface what was missed.

The Devil's Advocate reads ALL domain findings and produces their critique.

### Phase 5 — Synthesis & Report Generation

**Agent:** Principal Engineer

The Principal reads all domain findings + Devil's Advocate critique. For every disagreement, they must explicitly respond. Silence is not allowed.

Produces the final AEGIS report:
1. Executive Risk Summary
2. Architecture Narrative
3. Findings by Domain (severity-ranked)
4. Cross-Validation Notes (disagreements and resolutions)
5. Remediation Roadmap
6. Long-Term Structural Risks
7. "What Would Break First at 10x Scale"

---

## The Formal Epistemic Schema

This is the intellectual core of AEGIS — the formal spine that prevents the system from becoming a pile of clever prompts.

### Core Principle

**All findings must be decomposed into epistemic layers.** No agent is allowed to output a conclusion without explicitly passing through these layers.

### The 7-Layer Epistemic Stack

Every finding is a structured object with seven layers:

#### Layer 1 — Observation (Raw Signal)

What exists independently of interpretation.

- "Function `retryRequest()` retries on HTTP 500"
- "Config flag `ENABLE_LEGACY_FLOW=true` in prod"
- "Table `users` lacks a unique constraint on email"

**Rules:** No adjectives. No risk language. Tool outputs live here.

#### Layer 2 — Evidence Source

Why we believe the observation is real.

Fields:
- Source type (static analysis, config file, runtime metric, log, commit history)
- Tool or artifact name
- Location (file, line, environment)
- Freshness (static / historical / live)

**Purpose:** Prevents tool bias, hallucinated certainty, and overweighting single sources.

#### Layer 3 — Interpretation (Mechanism)

What this observation means in context.

- "Unbounded retries can amplify load during partial outages"
- "Legacy flow bypasses new validation logic"
- "Duplicate emails can be created under race conditions"

**Rules:** Must explain causal mechanism. No value judgment yet. Multiple interpretations allowed.

#### Layer 4 — Assumptions

What must be true for the interpretation to hold.

- "Service receives concurrent requests"
- "Flag is enabled in all regions"
- "Email uniqueness is required by business logic"

**This is where the Devil's Advocate attacks.**

#### Layer 5 — Risk Statement

What could go wrong if the interpretation is correct.

Format: *If [interpretation], then [failure mode], impacting [asset]*

Example: "Retry storms could overwhelm downstream services, causing cascading failures"

#### Layer 6 — Impact & Likelihood

Severity modeling, not vibes.

Fields:
- **Impact domain:** security, data integrity, availability, compliance, velocity
- **Impact magnitude:** low, moderate, high, critical, existential
- **Likelihood:** rare, unlikely, possible, likely, frequent
- **Time horizon:** immediate, near-term, long-term, hypothetical
- **Blast radius:** localized, service-level, systemic, org-wide/legal/existential

#### Layer 7 — Judgment (Decision-Oriented)

What should be done about it.

Options: Must fix | Should fix | Accept risk | Monitor | Out of scope

**Rules:**
- Judgment is explicitly separated from facts
- Principal Engineer owns this layer
- Devil's Advocate may challenge but not decide

### Confidence Modeling

Each finding carries a **confidence vector**, not a scalar.

**Confidence dimensions:**
- Evidence diversity (1 tool vs many)
- Signal freshness (static vs runtime)
- Assumption fragility
- Historical precedent (known failure pattern?)

This enables statements like: "High-impact, low-confidence risk — validate before remediation." That's senior-level nuance.

### Epistemic Hygiene Rules (System-Wide Invariants)

These are non-negotiable:

1. No risk statements without observations
2. No judgments without risk modeling
3. No confidence without evidence
4. No synthesis without acknowledging uncertainty
5. No "clean narrative" without Devil's Advocate response

---

## Disagreement Resolution System

### Why Disagreements Happen

Usually because of:
- Different threat models
- Different time horizons
- Different failure memories
- Different tolerance for risk

AEGIS surfaces these differences. It does not hide them.

### Resolution Mental Models

Senior engineers do not vote. They reason under uncertainty using five canonical models:

**Model 1 — Evidence Dominance**
"Which claim is better supported by independent signals?"
Weight: number of tools, signal diversity, historical precedent.

**Model 2 — Risk Asymmetry**
"If we're wrong, who pays and how badly?"
Security and data risks often override performance disagreements.

**Model 3 — Reversibility**
"How hard is it to undo this decision?"
Irreversible decisions get stricter scrutiny.

**Model 4 — Time-to-Failure**
"Which concern manifests first?"
Near-term risks outrank theoretical long-term ones.

**Model 5 — Blast Radius**
"How much breaks if this is wrong?"
Localized risk < systemic risk.

### Disagreement as First-Class Object

Every disagreement is a structured record:

```
Disagreement {
  id
  finding_id
  epistemic_layer_disputed    // interpretation, assumptions, impact, likelihood, judgment
  agents_involved
  positions[]                 // one per agent, each with claim + evidence + assumptions + confidence
  root_cause                  // from closed set (see below)
  resolution_model_applied
  principal_response           // REQUIRED - silence is not allowed
  status                      // open, mitigated, accepted_risk, deferred, out_of_scope
}
```

**Root cause taxonomy (closed set):**
- Threat model mismatch
- Time horizon mismatch
- Evidence availability mismatch
- Risk tolerance mismatch
- Domain boundary mismatch
- Optimism vs pessimism bias
- Tool trust bias

### Resolution Protocol

The Principal must explicitly respond to every Devil's Advocate critique and every unresolved disagreement:

1. Acknowledge it explicitly
2. Choose a resolution model (evidence dominance, risk asymmetry, reversibility, time-to-failure, accept risk)
3. Record rationale
4. Assign follow-up if needed

**Status states:** Open | Mitigated by evidence | Accepted risk | Deferred pending validation | Out of scope

No silent disappearance allowed.

### Critical Anti-Patterns

1. Auto-resolving disagreements
2. Averaging opinions
3. Forcing consensus language
4. Hiding disagreement in footnotes
5. Treating Devil's Advocate as optional

These destroy trust.

---

## Disagreement Visualization Model

### Philosophy

Agreement is cheap. Disagreement is where risk hides.

The goal is not convergence. The goal is **epistemic transparency** — showing leadership where understanding is weakest relative to risk.

### Five Visualization Axes

**Axis 1 — Severity vs Disagreement Intensity**

| | Low Disagreement | High Disagreement |
|---|---|---|
| **High Severity** | ACT | CRITICAL ATTENTION |
| **Low Severity** | Ignore | Investigate lightly |

**Axis 2 — Confidence Asymmetry**
Shows when Agent A has high confidence and Agent B has low confidence, revealing overconfidence risk and evidence imbalance.

**Axis 3 — Evidence Diversity**
How many independent evidence sources support each side. Senior engineers often weight one runtime log + historical incident over three static tool outputs.

**Axis 4 — Time Horizon**
Disagreements often aren't about *if*, but *when*. Visualizes: immediate, near-term, long-term, hypothetical.

**Axis 5 — Blast Radius**
Localized, service-level, systemic, org-wide/legal/existential. This axis often breaks ties.

### Canonical Views

**1. Disagreement Heatmap (Executive View)**
Rows = findings, color intensity = severity x disagreement x confidence gap. Tells leadership: "Where are we least sure about the most important things?"

**2. Epistemic Stack Diff (Per Finding)**
Shows which layers are agreed vs disputed:
```
Observation        [agreed]
Interpretation     [disputed]
Assumptions        [disputed]
Impact             [disputed]
Judgment           [deferred]
```

**3. Agent Position Overlay**
For high-risk findings, plots each agent's position across impact, likelihood, and time horizon. Clusters vs outliers — outliers matter.

**4. Devil's Advocate Focus Panel**
Dedicated view: findings where Devil's Advocate dissents, confidence vs evidence delta, Principal's response. If this panel is empty, the system is broken.

**5. Assumption Fragility Graph**
Shows which assumptions multiple conclusions rely on and which are weakest/unverified. Identifies single-point epistemic failures.

---

## Reality Gap Framework

### Definition

**Reality Gap = Difference between system behavior as inferred from code and behavior as it actually executes in production.**

Most incidents live here. Most audits miss it entirely.

### The Four Divergence Vectors

1. **Configuration** — what's configured differently than the code assumes
2. **Environment** — what's different between dev/staging/prod
3. **Runtime Control Planes** — what external systems alter behavior
4. **Human Intervention** — what manual processes bypass safeguards

### Reality Gap Domains

**RG-1: Configuration Drift**
- Environment variables, YAML/JSON/HCL configs
- Default vs overridden values
- Secrets managers, region-specific configs
- Failure patterns: safe defaults overridden unsafely, flags enabled in prod only, test env != prod env

**RG-2: Feature Flags & Kill Switches**
- Flag inventory, ownership, lifetimes
- Conditional code paths
- Failure patterns: permanent "temporary" flags, untested flag combinations, flag-dependent logic bypassing invariants
- Senior question: "What code runs *only* when things go wrong?"

**RG-3: Deployment & Infrastructure Overlay**
- Kubernetes manifests, Terraform/CloudFormation
- Sidecars, proxies, service meshes, init containers, CronJobs
- Failure patterns: resource limits different from assumptions, hidden retries in proxies, timeouts enforced outside app code

**RG-4: Runtime Behavior vs Static Intent**
- Logs vs code paths, metrics vs expectations
- Observability coverage gaps, disabled instrumentation
- Failure patterns: dead code paths that are actually live, code never exercised in tests but hot in prod, silent failure paths

**RG-5: Operational Overrides & Human Actions**
- Hotfix mechanisms, manual scripts, admin endpoints
- One-off migrations, emergency patches
- Failure patterns: undocumented operational workflows, scripts with production authority, manual fixes that bypass safeguards
- This is where tribal knowledge hides

### Reality Gap Agent Outputs

1. Assumed vs Actual Behavior Table
2. Code Paths Active Only in Production
3. Flags & Configs That Change Control Flow
4. Invisible Dependencies (proxies, retries, meshes)
5. Highest-Risk Mismatches

Reality Gap findings are encoded using the same 7-layer epistemic schema. Uniform representation enables powerful synthesis.

---

## Language-Specific Failure Models

Each language/runtime has unique ways to fail that generic analysis will never catch. AEGIS detects the project's language(s) and applies ecosystem-specific failure pattern catalogs.

**Core principle:** Every runtime lies to you in a different way.

### JVM (Java / Kotlin / Scala)

Hidden failures: GC pressure from object churn, thread pool exhaustion, blocking calls inside async/reactive flows, memory leaks via static references, classloader leaks, poor equals/hashCode implementations, overuse of synchronized vs fine-grained locks.

Audit questions: Are allocations proportional to request volume? Are thread pools bounded and observable? Are blocking I/O calls hidden in async paths? Are caches unbounded?

### Python

Hidden failures: GIL-induced throughput collapse, async code that isn't actually async, silent exception swallowing, mutable default arguments, heavy reliance on global state, memory leaks via reference cycles, CPU-bound work in request threads.

Audit questions: Is concurrency real or illusionary? Are asyncio boundaries respected? Is CPU work isolated? Are retries idempotent?

### JavaScript / TypeScript (Node, Browser)

Hidden failures: Event loop blocking, unhandled promise rejections, inconsistent async error handling, memory leaks via closures, excessive JSON serialization, dependency bloat (supply chain risk), TypeScript "any" erosion.

Audit questions: Can one slow request stall all others? Are async errors centrally handled? Is type safety enforced or aspirational? Are libraries pinned and audited?

### Go

Hidden failures: Goroutine leaks, context cancellation ignored, channel deadlocks, unbounded fan-out, hidden blocking syscalls, overuse of global state.

Audit questions: Are all goroutines bounded? Is context propagated everywhere? Are channels closed correctly? Is backpressure implemented?

### Rust

Hidden failures: Unsafe blocks without justification, overly complex lifetimes (maintainability risk), panic paths in prod, blocking calls in async runtimes, premature optimization.

Audit questions: Why is unsafe needed here? Are panics recoverable? Is async runtime respected? Is complexity justified?

### Databases (Cross-Cutting)

Hidden failures: N+1 queries, lock contention, missing indexes, overloaded migrations, weak isolation assumptions.

### Distributed Systems (Cross-Language)

Hidden failures: Clock skew, partial failures, retry storms, cascading timeouts, eventual consistency violations.

---

## Tooling Stack

### Must-Have (Core)

| Tool | What It Does | Domains Served | Cost |
|---|---|---|---|
| **SonarQube** | Code smells, bugs, maintainability, duplication, complexity analysis | 3, 7, 9 | Free (Community Edition) |
| **Semgrep** | Security-focused SAST — XSS, SQL injection, IDOR, hardcoded secrets, business logic vulnerabilities. 20,000+ rules, 30+ languages, 10-second median scan | 3, 4 | Free (OSS) / Paid (Pro) |
| **Trivy** | All-in-one security scanner — OS packages, app dependencies, IaC files, license compliance | 4, 5 | Free |
| **Gitleaks** | Secrets detection — scans git history for API keys, passwords, tokens. 160+ secret patterns | 4 | Free |

### High Value

| Tool | What It Does | Domains Served | Cost |
|---|---|---|---|
| **CodeScene** | Hotspot analysis, code churn + complexity correlation, author concentration, change coupling, knowledge distribution, CodeHealth score (25+ factors) | 1, 9, 11, 12 | ~EUR 18/mo/author |
| **Checkov** | IaC security scanner — Terraform, CloudFormation, K8s, Helm, Dockerfiles. 3,000+ policies covering CIS benchmarks | 5, 8, Reality Gap | Free |
| **Syft + Grype** | SBOM generation (Syft) + vulnerability scanning (Grype). Complete package inventory across all ecosystems | 4 (supply chain) | Free |

### Useful

| Tool | What It Does | Domains Served | Cost |
|---|---|---|---|
| **OpenSSF Scorecard** | Scores open source projects 0-10 on security heuristics (branch protection, dependency pinning, CI tests, vulnerability disclosure). Scans top 1M projects weekly | 4, 12 | Free |
| **depcruise / Madge** | JavaScript/TypeScript dependency graph visualization and validation | 1 | Free |
| **Language linters** | ESLint (JS/TS), Pylint (Python), RuboCop (Ruby), Clippy (Rust), staticcheck (Go), SpotBugs (JVM) | 3, 9 | Free |

### Deferred (Tier 3)

| Tool | What It Does | Notes |
|---|---|---|
| **Structure101 / Lattix** | Architecture visualization and dependency management | Enterprise-licensed, expensive. Claude can do much of this analysis directly for codebases under 100k LOC |
| **CodeClimate** | Automated code review for maintainability | Overlaps significantly with SonarQube |
| **Snyk** | Full platform (SAST, SCA, container, IaC) | Enterprise SaaS. Trivy covers most use cases for free |

### Custom (Build These)

**Signal Normalization Layer**
Tools speak different languages. The system must convert all findings into: severity, confidence, blast radius, domain relevance.

**Cross-Signal Correlation Engine**
Where the system becomes exceptional:
- High churn + low tests = change risk
- Async code + blocking calls = latent perf bug
- PII fields + logs = compliance risk

**Git Log Mining Scripts**
Extract from git history: file churn rates, author concentration, bug density over time, file age vs modification frequency.

---

## Output Format

Every AEGIS run produces:

1. **Executive Risk Summary** — One-page overview for leadership
2. **Architecture Narrative** — How the system is built and why
3. **Findings by Domain (Severity-Ranked)** — All 14 domains, each with epistemic-schema-structured findings
4. **Cross-Validation Notes** — All disagreements, their root causes, and the Principal's resolutions
5. **Remediation Roadmap** — Prioritized action plan
6. **Long-Term Structural Risks** — What degrades over time
7. **"What Would Break First at 10x Scale"** — Predictive failure analysis

---

## Signal Categories

Phase 1 gathers evidence across six orthogonal dimensions:

1. **Structure** — Static code analysis, architecture patterns, dependency graphs
2. **Behavior** — Performance profiles, async analysis, flamegraphs
3. **History** — Git churn, file age, author concentration, bug density over time
4. **Dependencies** — Vulnerability scans, SBOM, supply chain health scores
5. **Runtime Characteristics** — OpenAPI/gRPC schemas, backward compatibility checks
6. **Policy Posture** — IaC compliance, secrets exposure, governance policies

---

## Related Reading

The original design conversation that shaped AEGIS is preserved as reference material:

**[`reference/original-design-conversation.md`](reference/original-design-conversation.md)**

This is a multi-turn conversation exploring the audit domain, agent personas, epistemic schema, reality gap framework, and disagreement visualization model. It is NOT the source of truth (this README is), but is useful for understanding the reasoning behind design decisions and for gleaning ideas that haven't yet been formalized into the system.
