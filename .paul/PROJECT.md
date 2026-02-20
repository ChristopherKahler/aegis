# AEGIS

## What This Is

A multi-agent, multi-session codebase audit system built on Claude Code. AEGIS deploys a team of senior engineering personas — each an expert in a specific domain — to conduct comprehensive analysis of any application codebase. It uses a formal epistemic schema, adversarial cross-validation, and structured disagreement resolution to produce findings that match or exceed what an elite team of principal engineers would deliver.

## Core Value

Any codebase can be comprehensively audited to senior/principal engineer standards through a multi-agent system that produces epistemic-rigorous, severity-ranked findings across every critical domain — with adversarial cross-validation and actionable remediation.

## Current State

| Attribute | Value |
|-----------|-------|
| Version | 0.2.0-dev |
| Status | In Progress (installation & runtime) |
| Last Updated | 2026-02-20 |

## Requirements

### Validated (Shipped)

- Formal epistemic schema enforcement in agent outputs — Phase 2 (9 schema files: 5 Core + 4 Transform)
- Disagreement resolution protocol between agents — Phase 2 (disagreement schema + protocol rules)
- Signal normalization layer (tool output → unified format) — Phase 2 (signal schema)
- 14 audit domain knowledge modules with failure patterns and best practices — Phase 3 (14 domain files: 6 infrastructure + 8 application/synthesis)
- Tool integrations: SonarQube, Semgrep, Trivy, Gitleaks, Checkov, Syft, Grype, git-history — Phase 4 (8 tool adapter specifications, 4,008 total lines)
- 17 agent persona specifications (12 Core + 5 Transform) with distinct cognitive identities — Phase 5 (17 persona files, 1,829 total lines)
- 17 agent assembly manifests (12 Core + 5 Transform) — Phase 6 (thin composition manifests)
- 12 orchestration workflows (8 Core + 4 Transform) — Phase 6 (phase orchestration + utilities + safety governance)
- 8 user-facing slash commands (4 Core + 4 Transform) — Phase 7 (guided wizard UX with safety prerequisites, 1,371 total lines)
- Complete spec validation (cross-reference integrity, convention compliance, composition correctness) — Phase 8 (90/90 files validated, 6 cross-ref fixes)
- Version-lock manifest with SHA-256 content hashes for all 90 spec files — Phase 8 (traceability for reproducible audit compositions)
- Interactive install system with dual-mode tool setup — Phase 10 (install.sh, 711 lines, curl|bash public install)
- Project init (/aegis:init) and tool validation (/aegis:validate) commands — Phase 11 (10 total commands)
- Multi-session UX with phase checkpoints, session tracking, and estimated remaining work — Phase 12 (phase-checkpoint workflow + command enhancements)

### Active (In Progress)

- [ ] README.md alignment with delivered specs (written Phase 1, may have drifted through 7 phases of content creation)
- [ ] Getting Started documentation

### Planned (Next)

- ~~User-facing slash commands (/aegis:audit, /aegis:resume, /aegis:status, /aegis:report)~~ — Shipped Phase 7
- ~~Transform commands (/aegis:transform, /aegis:remediate, /aegis:playbook, /aegis:guardrails)~~ — Shipped Phase 7
- ~~Agent assembly manifests (12 Core + 5 Transform)~~ — Shipped Phase 6
- ~~Phase orchestration workflows (Phases 0-8)~~ — Shipped Phase 6
- ~~Formal epistemic schema enforcement~~ — Shipped Phase 2
- ~~Disagreement resolution protocol~~ — Shipped Phase 2
- ~~Signal normalization layer~~ — Shipped Phase 2
- [ ] Cross-signal correlation engine
- ~~Tool integrations: SonarQube, Semgrep, Trivy, Gitleaks, Checkov, Syft+Grype~~ — Shipped Phase 4
- [ ] CodeScene integration (optional paid enhancement)

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
| SBOM pipeline: Syft → Grype | Syft catalogs inventory, Grype scans for CVEs — separate tools, complementary pipeline | 2026-02-18 | Active |
| git-history dual normalization | Git history feeds both Core diagnosis (Domains 11, 12) and Transform change-risk modeling | 2026-02-18 | Active |
| Version-lock = traceability, not immutability | Specs evolve as real usage reveals gaps; manifest tracks which versions produced which audit results — the audit system must itself be auditable | 2026-02-19 | Active |
| v0.1 = validated specs, runtime = future milestone | Live execution (orchestrating Claude Code sessions on real codebases) requires implementation beyond specification | 2026-02-19 | Active |
| curl\|bash public install method | Zero deps, industry standard — remote install without cloning | 2026-02-20 | Active |
| Python venv over pipx/pip | PEP 668 blocks pip on modern Ubuntu/WSL2; venv always works | 2026-02-20 | Active |
| Smart SonarQube detection | Three-layer: Docker scanner image + Docker server + localhost:9000 | 2026-02-20 | Active |

## Success Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Audit domains covered | 14 | 14 | Complete |
| Agent personas implemented | 17 | 17 | Complete |
| Tool integrations working | 7+ | 8 (all OSS tools) | Complete |
| Spec validation (cross-ref + convention) | 90 files | 90/90 pass | Complete |
| Version-lock manifest | 1 | 1 (SHA-256) | Complete |
| Install script (framework + tools) | 1 | 1 (install.sh) | Complete |
| End-to-end audit on real repo | 1 | 0 | Future milestone |

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
*Last updated: 2026-02-21 after Phase 12 — Multi-Session UX complete*
