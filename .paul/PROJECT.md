# AEGIS

## What This Is

A multi-agent, multi-session codebase audit system built on Claude Code. AEGIS deploys a team of senior engineering personas — each an expert in a specific domain — to conduct comprehensive analysis of any application codebase. It uses a formal epistemic schema, adversarial cross-validation, and structured disagreement resolution to produce findings that match or exceed what an elite team of principal engineers would deliver.

## Core Value

Any codebase can be comprehensively audited to senior/principal engineer standards through a multi-agent system that produces epistemic-rigorous, severity-ranked findings across every critical domain — with adversarial cross-validation and actionable remediation.

## Current State

| Attribute | Value |
|-----------|-------|
| Version | 0.0.0 |
| Status | Design |
| Last Updated | 2026-02-15 |

## Requirements

### Validated (Shipped)

- Formal epistemic schema enforcement in agent outputs — Phase 2 (9 schema files: 5 Core + 4 Transform)
- Disagreement resolution protocol between agents — Phase 2 (disagreement schema + protocol rules)
- Signal normalization layer (tool output → unified format) — Phase 2 (signal schema)
- 14 audit domain knowledge modules with failure patterns and best practices — Phase 3 (14 domain files: 6 infrastructure + 8 application/synthesis)

### Active (In Progress)

- [ ] System design documented (README.md) — complete

### Planned (Next)

- [ ] PAUL-style agent prompt templates for all 12 personas
- [ ] Phase 0 (Context & Threat Modeling) session workflow
- [ ] Phase 1 (Signal Gathering) tool integration and automation
- [ ] Phase 2 (Deep Domain Audits) parallel agent sessions
- [ ] Phase 3 (Change Risk, Team Risk, Reality Gap) synthesis agents
- [ ] Phase 4 (Adversarial Review) Devil's Advocate session
- [ ] Phase 5 (Synthesis & Report) Principal Engineer final report
- ~~Formal epistemic schema enforcement~~ — Shipped Phase 2
- ~~Disagreement resolution protocol~~ — Shipped Phase 2
- ~~Signal normalization layer~~ — Shipped Phase 2
- [ ] Cross-signal correlation engine
- [ ] Tool integrations: SonarQube, Semgrep, Trivy, Gitleaks, Checkov, Syft+Grype, CodeScene

### Out of Scope

- GUI/dashboard (CLI-first, report output is markdown)
- Real-time monitoring (audit is point-in-time)
- Auto-remediation (AEGIS Transform produces plans; PAUL executes with human oversight)

## Target Users

**Primary:** Chris (internal use)
- Claude Code power user
- Auditing own projects and client codebases
- Needs senior engineering perspective he doesn't have from experience

**Secondary:** Client deliverable
- Audit reports for C&C Strategic Consulting clients
- Demonstrates technical depth and thoroughness

## Context

**Business Context:**
Built as a tool for Chris AI Systems / C&C Strategic Consulting. Can be used internally or as a value-add deliverable for client engagements. Architecture follows PAUL framework patterns (phased, multi-session, structured handoffs).

**Technical Context:**
- Built on Claude Code CLI with slash commands and agent personas
- Integrates with SonarQube (existing MCP server), Semgrep, Trivy, Gitleaks, Checkov, Syft+Grype
- CodeScene integration planned (high value for change risk and team ownership domains)
- Multi-session architecture — each agent persona runs in its own session
- Findings files passed between sessions as structured artifacts

## Constraints

### Technical Constraints
- Claude Code 200k token context window per session
- Each agent persona runs as a separate session
- Tool outputs must be normalized before agent consumption
- Must work on any codebase language/framework

### Business Constraints
- No enterprise-licensed tools required for core functionality (SonarQube Community, OSS tools)
- CodeScene is optional paid enhancement

## Key Decisions

| Decision | Rationale | Date | Status |
|----------|-----------|------|--------|
| Name: AEGIS | Automated Epistemic Governance & Intelligence System — captures protection + epistemic rigor | 2026-02-12 | Active |
| 14 audit domains (0-13) | Comprehensive coverage without gaps — validated through self-audit process | 2026-02-12 | Active |
| 12 agent personas | Minimal-complete set — removing any leaves blind spots | 2026-02-12 | Active |
| 7-layer epistemic schema | Forces structured reasoning, prevents opinion soup | 2026-02-12 | Active |
| Disagreements as first-class objects | Senior engineers surface disagreement, not hide it | 2026-02-12 | Active |
| Reality Gap as dedicated framework | Most incidents live in code-vs-runtime divergence | 2026-02-12 | Active |
| Strict 1:1 failure/best-practice mapping in domains | Convention requires each failure pattern has exactly one corresponding best practice — prevents many-to-one dilution | 2026-02-13 | Active |
| Synthesis domain pattern (Domain 13) | Synthesis domains describe process failures, not codebase failures — enables meta-analysis domains | 2026-02-15 | Active |

## Success Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Audit domains covered | 14 | 0 | Not started |
| Agent personas implemented | 12 | 0 | Not started |
| Tool integrations working | 7+ | 1 (SonarQube) | In progress |
| End-to-end audit on real repo | 1 | 0 | Not started |

## Tech Stack

| Layer | Technology | Notes |
|-------|------------|-------|
| Runtime | Claude Code CLI | Slash commands, agent personas |
| Framework | PAUL | Phased execution, handoffs |
| Analysis | SonarQube, Semgrep, Trivy, Gitleaks, Checkov, Syft+Grype | OSS core stack |
| Optional | CodeScene | Paid — change risk, team ownership |
| Output | Markdown | Structured reports |

## Links

| Resource | URL |
|----------|-----|
| README | apps/aegis/README.md |
| Reference | apps/aegis/reference/original-design-conversation.md |

---
*PROJECT.md — Updated when requirements or context change*
*Last updated: 2026-02-15 after Phase 3*
