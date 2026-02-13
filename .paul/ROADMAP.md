# Roadmap: AEGIS

## Overview

AEGIS is built component-by-component: architecture standards first, then the building blocks (schemas, rules, domains, tools, personas) independently, then assembly (agents, workflows) that composes those blocks, then the user-facing layer (commands), and finally end-to-end validation. Each phase produces artifacts conforming to the Foundation Standards conventions.

## Current Milestone

**v0.1 Initial Release** (v0.1.0)
Status: In progress
Phases: 1 of 8 complete

## Phases

| Phase | Name | Plans | Component Types | Status | Completed |
|-------|------|-------|-----------------|--------|-----------|
| 1 | Foundation Standards | 1 | (standards docs) | Complete | 2026-02-12 |
| 2 | Schemas & Rules | 2 | schemas, rules | Not started | - |
| 3 | Domain Knowledge | 2 | domains | Not started | - |
| 4 | Tool Integration | 2 | tools | Not started | - |
| 5 | Personas | 2 | personas | Not started | - |
| 6 | Agent Assembly & Workflows | 2 | agents, workflows | Not started | - |
| 7 | Commands & UX | 1 | commands | Not started | - |
| 8 | End-to-End Validation | 1 | (validation) | Not started | - |

**Parallelization note:** Phases 3, 4, and 5 depend only on Phase 1 conventions (not on each other). They can be developed in any order or interleaved. Phase 2 (schemas/rules) should come first among them since schemas define the output contracts that domains reference and tools normalize into.

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

**Post-phase:** Roadmap audited and overhauled against foundation standards (completed during planning)

### Phase 2: Schemas & Rules

**Goal:** Create the output format contracts (schemas) and epistemic governance constraints (rules) that ALL agents must conform to. These are the data contracts and behavioral constraints that make the system composable and epistemically rigorous.
**Depends on:** Phase 1 (conventions define how schema and rule files are structured)
**Component types produced:** schemas, rules
**Research:** Unlikely (designed in README.md)

**Scope:**
- 7-layer epistemic finding schema (finding template + worked example)
- Disagreement record schema (positions, root cause taxonomy, status states, resolution models)
- Confidence vector schema (4 dimensions, 1-5 scales)
- Signal normalization schema (unified tool output format — severity, confidence, blast radius, domain relevance)
- Report section schemas (executive summary, domain findings, disagreements, remediation roadmap)
- Epistemic hygiene rules (5 rules from README)
- Disagreement anti-pattern rules (no auto-resolving, no averaging, no forcing consensus)
- Agent behavior constraint rules (persona boundaries, domain boundaries)

**Plans:**
- [ ] 02-01: Core schemas — epistemic finding, disagreement record, confidence vector, worked examples
- [ ] 02-02: Signal schema, report schemas, epistemic rules, behavior rules

### Phase 3: Domain Knowledge

**Goal:** Create the 14 standalone domain knowledge modules (Domains 0-13). Each captures failure patterns, audit questions, red flags, tool affinities, and relevant standards — neutral, structured, independent of any persona.
**Depends on:** Phase 1 (domain file convention)
**Component types produced:** domains
**Research:** Unlikely (domain content designed in README.md)

**Scope:**
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
- [ ] 03-01: Infrastructure domains — 00 Context, 01 Architecture, 02 Data, 07 Reliability, 08 Performance, 10 Operability
- [ ] 03-02: Application & synthesis domains — 03 Correctness, 04 Security, 05 Compliance, 06 Testing, 09 Maintainability, 11 Change Risk, 12 Team Risk, 13 Risk Synthesis

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
- [ ] 04-01: Core tool adapters — SonarQube, Semgrep, Trivy, Gitleaks
- [ ] 04-02: Extended tool adapters — Checkov, Syft+Grype, git history mining

### Phase 5: Personas

**Goal:** Create the 12 core persona files — each encoding identity, risk philosophy, thinking style, mental models, confidence calibration, disagreement triggers, and "must never" constraints. Personas must be STRONG and DISTINCT to prevent dilution when composed with domain modules.
**Depends on:** Phase 1 (persona file convention)
**Component types produced:** personas
**Research:** Unlikely (persona designs in README.md)

**Scope:**
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

**Plans:**
- [ ] 05-01: Core audit personas — Principal Engineer, Architect, Data Engineer, Security Engineer, Compliance Officer, Senior App Engineer
- [ ] 05-02: Operations & synthesis personas — SRE, Performance Engineer, Test Engineer, Staff Engineer, Reality Gap Analyst, Devil's Advocate

### Phase 6: Agent Assembly & Workflows

**Goal:** Create the 12 agent assembly manifests (thin composition files declaring persona + domains + tools + schemas + rules) and the 6+ orchestration workflows (one per AEGIS execution phase + utility flows like session handoff and disagreement resolution).
**Depends on:** Phase 2 (schemas/rules exist), Phase 3 (domains exist), Phase 4 (tools exist), Phase 5 (personas exist)
**Component types produced:** agents, workflows
**Research:** Unlikely

**Scope:**
- 12 agent assembly manifests (one per persona, declaring component composition)
- Phase 0 workflow: Context & Threat Modeling (Principal Engineer session)
- Phase 1 workflow: Automated Signal Gathering (tool orchestration)
- Phase 2 workflow: Deep Domain Audits (parallel agent sessions)
- Phase 3 workflow: Change Risk, Team Risk & Reality Gap (synthesis sessions)
- Phase 4 workflow: Adversarial Review (Devil's Advocate session)
- Phase 5 workflow: Synthesis & Report Generation (Principal Engineer session)
- Session handoff workflow (how findings pass between agent sessions)
- Disagreement resolution workflow (how Principal responds to Devil's Advocate)

**Plans:**
- [ ] 06-01: Agent assembly manifests (all 12) + session handoff workflow
- [ ] 06-02: Phase orchestration workflows (Phases 0-5) + disagreement resolution workflow

### Phase 7: Commands & UX

**Goal:** Create the user-facing slash commands that provide the guided wizard experience — entry points that delegate to workflows, present options, and guide users through the audit process.
**Depends on:** Phase 6 (workflows must exist for commands to delegate to)
**Component types produced:** commands
**Research:** Unlikely

**Scope:**
- `/aegis:audit` — Master command: initiates a full audit (guided wizard flow)
- `/aegis:resume` — Resume an interrupted audit
- `/aegis:status` — Show current audit position and next action
- `/aegis:report` — Generate or regenerate the final report
- Audit run configuration (which agents to include, which tools to run, scope overrides)

**Plans:**
- [ ] 07-01: All commands (/aegis:audit, /aegis:resume, /aegis:status, /aegis:report) + audit configuration

### Phase 8: End-to-End Validation

**Goal:** Run a complete AEGIS audit on a real codebase. Validate that all components compose correctly, agents produce well-formed findings conforming to schemas, disagreement resolution works, and the final report is coherent and actionable. Refine any component based on results.
**Depends on:** Phase 7 (full system must be assembled and commandable)
**Component types produced:** None (validation + refinement)
**Research:** Unlikely (execution, not exploration)

**Scope:**
- Select target codebase for validation (candidate: an existing apps/ project)
- Execute full audit (all 6 AEGIS execution phases)
- Evaluate: schema conformance, persona distinctness, domain coverage, tool signal quality, disagreement quality, report coherence
- Identify refinements needed per component type
- Document lessons learned
- Version-lock the validated component set

**Plans:**
- [ ] 08-01: Full end-to-end audit on real codebase with evaluation and refinement

---
*Roadmap created: 2026-02-12*
*Last updated: 2026-02-12 — Overhauled to align with 8-component-type architecture*
