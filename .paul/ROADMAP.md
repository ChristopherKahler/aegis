# Roadmap: AEGIS

## Overview

AEGIS is a two-system architecture: **AEGIS Core** (diagnosis) and **AEGIS Transform** (controlled evolution). Both systems are built component-by-component through the same phases — foundation standards first, then building blocks (schemas, rules, domains, tools, personas), then assembly (agents, workflows), then user-facing commands, and finally end-to-end validation.

Each phase produces artifacts for both systems where applicable. Core artifacts handle diagnostic analysis (Layer A output). Transform artifacts handle remediation knowledge (Layer B) and change orchestration (Layer C). All artifacts conform to the Foundation Standards conventions established in Phase 1.

## Current Milestone

**v0.1 Initial Release** (v0.1.0)
Status: In progress
Phases: 6 of 8 complete

## Phases

| Phase | Name | Plans | Component Types | Status | Completed |
|-------|------|-------|-----------------|--------|-----------|
| 1 | Foundation Standards | 2 | (standards docs) | Complete | 2026-02-13 |
| 2 | Schemas & Rules | 3 | schemas, rules | Complete | 2026-02-13 |
| 3 | Domain Knowledge | 2 | domains | Complete | 2026-02-15 |
| 4 | Tool Integration | 2 | tools | Complete | 2026-02-18 |
| 5 | Personas | 3 | personas | Complete | 2026-02-18 |
| 6 | Agent Assembly & Workflows | 3 | agents, workflows | Complete | 2026-02-19 |
| 7 | Commands & UX | 2 | commands | Not started | - |
| 8 | End-to-End Validation | 1 | (validation) | Not started | - |

**Parallelization note:** Phases 3, 4, and 5 depend only on Phase 1 conventions (not on each other). They can be developed in any order or interleaved. Phase 2 (schemas/rules) should come first among them since schemas define the output contracts that domains reference and tools normalize into.

**Two-system note:** Each phase builds both Core and Transform artifacts for its component types. Transform artifacts require Core equivalents as foundation (diagnosis informs remediation). The 5 Transform agent personas (Remediation Architect, Change Risk Modeler, Pedagogy Agent, Guardrail Generator, Execution Validator) are built in Phase 5 alongside Core personas.

## Phase Details

### Phase 1: Foundation Standards

**Goal:** Define the complete AEGIS framework architecture, directory structure, and file type conventions for all 8 component types. Establish the "constitution" that governs how every subsequent artifact is structured, named, cross-referenced, and versioned.
**Depends on:** Nothing (first phase)
**Component types produced:** None (standards documentation only)
**Research:** Unlikely

**Scope:**
- Master architecture document (directory structure, component model, relationships, cross-referencing, naming, versioning)
- Convention specifications for all 8 component types (personas, domains, schemas, rules, tools, agents, workflows, commands)
- Runtime and versioning specification (.aegis/ operational state, archival output, version-locking manifest, audit lifecycle)

**Plans:**
- [x] 01-01: Architecture document + 8 component type conventions + runtime/versioning spec
- [x] 01-02: Expand foundation standards for AEGIS Transform two-system architecture

**Post-phase:** Roadmap audited and overhauled against foundation standards (completed during planning). Transform expansion completed — all conventions, architecture, and runtime specs updated for two-system architecture.

### Phase 2: Schemas & Rules

**Goal:** Create the output format contracts (schemas) and epistemic governance constraints (rules) for both Core diagnosis and Transform evolution. These are the data contracts and behavioral constraints that make both systems composable, epistemically rigorous, and safe.
**Depends on:** Phase 1 (conventions define how schema and rule files are structured)
**Component types produced:** schemas, rules
**Research:** Unlikely (designed in README.md)

**Scope — Core (Layer A):**
- 7-layer epistemic finding schema (finding template + worked example)
- Disagreement record schema (positions, root cause taxonomy, status states, resolution models)
- Confidence vector schema (4 dimensions, 1-5 scales)
- Signal normalization schema (unified tool output format — severity, confidence, blast radius, domain relevance)
- Report section schemas (executive summary, domain findings, disagreements, remediation roadmap)
- Epistemic hygiene rules (5 rules from README)
- Disagreement anti-pattern rules (no auto-resolving, no averaging, no forcing consensus)
- Agent behavior constraint rules (persona boundaries, domain boundaries)

**Scope — Transform (Layers B & C):**
- Remediation template schema (abstract → framework → language → project layers)
- Change risk model schema (risk dimensions, mitigation strategies, confidence thresholds)
- Guardrail specification schema (constraint type, enforcement level, validation rules)
- Execution plan schema (PAUL-consumable change orchestration format)
- Transform safety rules (conservative bias, confidence gating, no auto-execution)
- Intervention level rules (Suggesting → Planning → Authorizing → Executing constraints)

**Plans:**
- [x] 02-01: Core schemas — epistemic finding, disagreement record, confidence vector, worked examples
- [x] 02-02: Signal schema, report schemas, epistemic rules, behavior rules
- [x] 02-03: Transform schemas — remediation template, change risk model, guardrail spec, execution plan + Transform safety/intervention rules

### Phase 3: Domain Knowledge

**Goal:** Create the 14 standalone domain knowledge modules (Domains 0-13). Each captures failure patterns, audit questions, red flags, tool affinities, relevant standards, AND best-practice patterns for Transform remediation — neutral, structured, independent of any persona. Domains serve both Core (diagnostic signals) and Transform (remediation knowledge).
**Depends on:** Phase 1 (domain file convention)
**Component types produced:** domains
**Research:** Unlikely (domain content designed in README.md)

**Scope per domain (Core + Transform):**
- Failure patterns, audit questions, red flags, tool affinities (Core — Layer A)
- Best-practice patterns, remediation strategies, exemplar approaches (Transform — Layer B)

**Domains:**
- Domain 00: Context & Intent
- Domain 01: Architecture & System Design
- Domain 02: Data & State Integrity
- Domain 03: Correctness & Logic
- Domain 04: Security
- Domain 05: Compliance, Privacy & Governance
- Domain 06: Testing Strategy & Verification
- Domain 07: Reliability & Resilience
- Domain 08: Scalability & Performance
- Domain 09: Maintainability & Code Health
- Domain 10: Operability & Developer Experience
- Domain 11: Change Risk & Evolvability
- Domain 12: Team, Ownership & Knowledge Risk
- Domain 13: Risk Synthesis & Forecasting

**Plans:**
- [x] 03-01: Infrastructure domains — 00 Context, 01 Architecture, 02 Data, 07 Reliability, 08 Performance, 10 Operability
- [x] 03-02: Application & synthesis domains — 03 Correctness, 04 Security, 05 Compliance, 06 Testing, 09 Maintainability, 11 Change Risk, 12 Team Risk, 13 Risk Synthesis

### Phase 4: Tool Integration

**Goal:** Create tool adapter specifications for each analysis tool — what it does, how to run it, output format, normalization to AEGIS signal schema, and which domains it feeds.
**Depends on:** Phase 1 (tool file convention), Phase 2 (signal normalization schema)
**Component types produced:** tools
**Research:** Likely (Semgrep rules, Trivy output formats, Checkov policies, Gitleaks config)
**Research topics:** Semgrep rule sets for target languages, Trivy JSON output structure, Gitleaks config customization, Checkov policy packs

**Scope:**
- SonarQube adapter (via existing MCP server)
- Semgrep adapter (installation, rule config, output normalization)
- Trivy adapter (scan config, output normalization)
- Gitleaks adapter (secrets detection config)
- Checkov adapter (IaC scanning)
- Syft + Grype adapter (SBOM generation + vulnerability scanning)
- Git history mining adapter (churn, author concentration, file age, change frequency)

**Plans:**
- [x] 04-01: Core tool adapters — SonarQube, Semgrep, Trivy, Gitleaks
- [x] 04-02: Extended tool adapters — Checkov, Syft, Grype, git history mining

### Phase 5: Personas

**Goal:** Create the 12 Core diagnostic personas and 5 Transform evolution personas. Each encodes identity, risk philosophy, thinking style, mental models, confidence calibration, disagreement triggers, and "must never" constraints. Personas must be STRONG and DISTINCT to prevent dilution when composed with domain modules.
**Depends on:** Phase 1 (persona file convention)
**Component types produced:** personas
**Research:** Unlikely (persona designs in README.md)

**Scope — Core (12 personas):**
- Principal Engineer persona (epistemic governor — Phase 0 + Phase 5 active)
- Architect persona (Domain 1)
- Data Engineer persona (Domain 2)
- Security Engineer persona (Domain 4)
- Compliance Officer persona (Domain 5)
- Senior Application Engineer persona (Domains 3, 9)
- SRE persona (Domains 7, 10)
- Performance Engineer persona (Domain 8)
- Test Engineer persona (Domain 6)
- Staff Engineer / Tech Lead persona (Domains 11, 12)
- Reality Gap Analyst persona (cross-domain — code vs. runtime divergence)
- Devil's Advocate Reviewer persona (adversarial — hunts blind spots)

**Scope — Transform (5 personas):**
- Remediation Architect (designs fix strategies across the 4-layer transformation model)
- Change Risk Modeler (quantifies risk of proposed changes, blast radius analysis)
- Pedagogy Agent (generates human-readable explanations, teaches why fixes matter)
- Guardrail Generator (produces constraints, validation rules, safety boundaries)
- Execution Validator (verifies proposed changes maintain system invariants)

**Plans:**
- [x] 05-01: Core audit personas — Principal Engineer, Architect, Data Engineer, Security Engineer, Compliance Officer, Senior App Engineer
- [x] 05-02: Operations & synthesis personas — SRE, Performance Engineer, Test Engineer, Staff Engineer, Reality Gap Analyst, Devil's Advocate
- [x] 05-03: Transform personas — Remediation Architect, Change Risk Modeler, Pedagogy Agent, Guardrail Generator, Execution Validator

### Phase 6: Agent Assembly & Workflows

**Goal:** Create the 17 agent assembly manifests (12 Core + 5 Transform, each a thin composition file declaring persona + domains + tools + schemas + rules) and the orchestration workflows for both diagnostic and evolution pipelines.
**Depends on:** Phase 2 (schemas/rules exist), Phase 3 (domains exist), Phase 4 (tools exist), Phase 5 (personas exist)
**Component types produced:** agents, workflows
**Research:** Unlikely

**Scope — Core agents & workflows:**
- 12 Core agent assembly manifests (one per diagnostic persona)
- Phase 0 workflow: Context & Threat Modeling (Principal Engineer session)
- Phase 1 workflow: Automated Signal Gathering (tool orchestration)
- Phase 2 workflow: Deep Domain Audits (parallel agent sessions)
- Phase 3 workflow: Change Risk, Team Risk & Reality Gap (synthesis sessions)
- Phase 4 workflow: Adversarial Review (Devil's Advocate session)
- Phase 5 workflow: Synthesis & Report Generation (Principal Engineer session)
- Session handoff workflow (how findings pass between agent sessions)
- Disagreement resolution workflow (how Principal responds to Devil's Advocate)

**Scope — Transform agents & workflows:**
- 5 Transform agent assembly manifests (one per Transform persona)
- Layer B pipeline workflow: Diagnosis → Remediation Knowledge generation
- Layer C pipeline workflow: Remediation → Execution Plan generation (PAUL integration)
- Transform safety workflow: Confidence gating, intervention level enforcement

**Plans:**
- [x] 06-01: Core agent assembly manifests (all 12) + session handoff workflow
- [x] 06-02: Core phase orchestration workflows (Phases 0-5) + disagreement resolution workflow
- [x] 06-03: Transform agent manifests (all 5) + Layer B/C pipeline workflows + safety workflow

### Phase 7: Commands & UX

**Goal:** Create the user-facing slash commands for both diagnostic audits and Transform evolution — guided wizard experiences that delegate to workflows, present options, and manage the full audit-to-remediation pipeline.
**Depends on:** Phase 6 (workflows must exist for commands to delegate to)
**Component types produced:** commands
**Research:** Unlikely

**Scope — Core commands:**
- `/aegis:audit` — Master command: initiates a full diagnostic audit (guided wizard flow)
- `/aegis:resume` — Resume an interrupted audit
- `/aegis:status` — Show current audit position and next action
- `/aegis:report` — Generate or regenerate the final diagnostic report

**Scope — Transform commands:**
- `/aegis:remediate` — Generate remediation knowledge (Layer B) from diagnostic findings
- `/aegis:transform` — Generate execution plans (Layer C) from remediation knowledge
- Audit run configuration (which agents to include, which tools to run, scope overrides, intervention level)

**Plans:**
- [ ] 07-01: Core commands (/aegis:audit, /aegis:resume, /aegis:status, /aegis:report) + audit configuration
- [ ] 07-02: Transform commands (/aegis:remediate, /aegis:transform) + intervention level configuration

### Phase 8: End-to-End Validation

**Goal:** Run a complete AEGIS audit AND Transform pipeline on a real codebase. Validate that all components compose correctly — Core agents produce well-formed diagnostic findings, Transform agents generate valid remediation knowledge and execution plans, safety constraints hold, and the full A→B→C pipeline produces coherent, actionable output. Refine any component based on results.
**Depends on:** Phase 7 (full system must be assembled and commandable)
**Component types produced:** None (validation + refinement)
**Research:** Unlikely (execution, not exploration)

**Scope:**
- Select target codebase for validation (candidate: an existing apps/ project)
- Execute full diagnostic audit (all 6 AEGIS Core execution phases)
- Execute Transform pipeline (Layer B remediation generation, Layer C execution planning)
- Evaluate: schema conformance, persona distinctness, domain coverage, tool signal quality, disagreement quality, report coherence, remediation quality, safety constraint enforcement
- Identify refinements needed per component type
- Document lessons learned
- Version-lock the validated component set

**Plans:**
- [ ] 08-01: Full end-to-end audit + Transform pipeline on real codebase with evaluation and refinement

---
*Roadmap created: 2026-02-12*
*Last updated: 2026-02-19 — Phase 6 complete, all 17 agents + 12 workflows delivered (Core + Transform)*
