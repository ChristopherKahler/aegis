# Roadmap: AEGIS

## Overview

AEGIS is a two-system architecture: **AEGIS Core** (diagnosis) and **AEGIS Transform** (controlled evolution). Both systems are built component-by-component through the same phases — foundation standards first, then building blocks (schemas, rules, domains, tools, personas), then assembly (agents, workflows), then user-facing commands, and finally end-to-end validation.

Each phase produces artifacts for both systems where applicable. Core artifacts handle diagnostic analysis (Layer A output). Transform artifacts handle remediation knowledge (Layer B) and change orchestration (Layer C). All artifacts conform to the Foundation Standards conventions established in Phase 1.

## Milestones

### v0.1 Initial Release (v0.1.0) — Complete

Status: Complete
Phases: 8 of 8 complete

### v0.2 Installation & Runtime — In progress

Status: In progress
Phases: 3 of 5 complete

## v0.2 Phases

| Phase | Name | Plans | Focus | Status | Completed |
|-------|------|-------|-------|--------|-----------|
| 9 | Command Conversion | 1 | Rewrite command specs into installable Claude Code commands | Complete | 2026-02-19 |
| 10 | Install System | 1 | Install script, interactive tool setup, framework placement | Complete | 2026-02-20 |
| 11 | Project Init & Validation | 1 | /aegis:init + /aegis:validate commands | Complete | 2026-02-20 |
| 12 | Multi-Session UX | TBD | Checkpoints, handoffs, session management | Not started | - |
| 13 | Getting Started | TBD | User documentation, setup guide | Not started | - |

## v0.2 Phase Details

### Phase 9: Command Conversion

**Goal:** Convert the 8 existing command spec files into actual installable Claude Code slash commands. Restructure framework files from `src/` repo layout to `~/.claude/aegis/` installable layout. Rewrite all `@` references from `@src/...` to `@~/.claude/aegis/...`.
**Depends on:** v0.1 (all spec files exist)
**Research:** Unlikely

**Scope:**
- Define installable directory structure: `~/.claude/aegis/` (framework) + `~/.claude/commands/aegis/` (commands)
- Rewrite 8 command files with correct `@` paths, `allowed-tools`, and Claude Code command conventions
- Restructure framework files (personas, domains, schemas, rules, tools, agents, workflows) into `~/.claude/aegis/` layout
- Ensure commands load workflows which load personas/domains/schemas correctly via `@` references

### Phase 10: Install System

**Goal:** Create an interactive installation process that sets up AEGIS for a user — places framework files, installs commands, and walks through OSS tool installation with Y/N per tool.
**Depends on:** Phase 9 (installable file structure must exist)
**Research:** Likely (tool installation methods per platform, dependency requirements)

**Scope:**
- Install script that copies framework to `~/.claude/aegis/` and commands to `~/.claude/commands/aegis/`
- Interactive tool installer: Y/N per OSS tool (SonarQube, Semgrep, Trivy, Gitleaks, Checkov, Syft, Grype)
- For each Y: install the tool + dependencies to a location AEGIS personas can access
- Post-install tool accessibility test (can Claude Code invoke each tool?)
- Clear output: what installed, what skipped, any issues

### Phase 11: Project Init & Validation

**Goal:** Create `/aegis:init` (project setup) and `/aegis:validate` (tool testing) commands. Init creates `.aegis/` in a target project for reports and state. Validate tests all installed tools and troubleshoots blockers.
**Depends on:** Phase 10 (install system must exist to have tools to validate)

**Scope:**
- `/aegis:init` command: creates `.aegis/` directory in target repo with STATE.md, MANIFEST.md, output directories
- `/aegis:validate` command: tests each installed tool, reports pass/fail, troubleshoots common issues
- Init should detect existing `.aegis/` and offer resume vs fresh start
- Validate should be runnable anytime (not just at install)

### Phase 12: Multi-Session UX

**Goal:** Ensure the multi-session audit experience is smooth — automatic checkpoints between phases, easy handoff generation, set-and-forget between agent sessions, clear resume flow.
**Depends on:** Phase 9 (commands must be installable)

**Scope:**
- Automatic checkpoints between AEGIS execution phases (0-5 Core, 6-8 Transform)
- Handoff generation at every checkpoint (user can walk away, come back later)
- Resume flow: pick up from last completed phase without re-reading everything
- Session state management in `.aegis/STATE.md`
- Progress visibility: what's done, what's next, estimated remaining sessions

### Phase 13: Getting Started

**Goal:** Create user documentation that walks someone from zero to first audit — clone, install, validate, init, audit.
**Depends on:** Phases 9-12 (all runtime pieces must exist)

**Scope:**
- Getting Started guide (docs/GETTING-STARTED.md)
- Prerequisites section (Claude Code, git, Docker optional)
- Step-by-step: clone → install → validate → init → audit
- Expected output examples
- Troubleshooting common issues
- Update README.md with installation/usage sections

---

## v0.1 Phases (Complete)

| Phase | Name | Plans | Component Types | Status | Completed |
|-------|------|-------|-----------------|--------|-----------|
| 1 | Foundation Standards | 2 | (standards docs) | Complete | 2026-02-13 |
| 2 | Schemas & Rules | 3 | schemas, rules | Complete | 2026-02-13 |
| 3 | Domain Knowledge | 2 | domains | Complete | 2026-02-15 |
| 4 | Tool Integration | 2 | tools | Complete | 2026-02-18 |
| 5 | Personas | 3 | personas | Complete | 2026-02-18 |
| 6 | Agent Assembly & Workflows | 3 | agents, workflows | Complete | 2026-02-19 |
| 7 | Commands & UX | 2 | commands | Complete | 2026-02-19 |
| 8 | End-to-End Validation | 2 | (validation) | Complete | 2026-02-19 |

<details>
<summary>v0.1 Phase Details (collapsed)</summary>

### Phase 1: Foundation Standards

**Goal:** Define the complete AEGIS framework architecture, directory structure, and file type conventions for all 8 component types.
**Plans:**
- [x] 01-01: Architecture document + 8 component type conventions + runtime/versioning spec
- [x] 01-02: Expand foundation standards for AEGIS Transform two-system architecture

### Phase 2: Schemas & Rules

**Goal:** Create output format contracts (schemas) and epistemic governance constraints (rules) for both Core and Transform.
**Plans:**
- [x] 02-01: Core schemas — epistemic finding, disagreement record, confidence vector, worked examples
- [x] 02-02: Signal schema, report schemas, epistemic rules, behavior rules
- [x] 02-03: Transform schemas + safety/intervention rules

### Phase 3: Domain Knowledge

**Goal:** Create the 14 standalone domain knowledge modules (Domains 0-13).
**Plans:**
- [x] 03-01: Infrastructure domains (00, 01, 02, 07, 08, 10)
- [x] 03-02: Application & synthesis domains (03, 04, 05, 06, 09, 11, 12, 13)

### Phase 4: Tool Integration

**Goal:** Create tool adapter specifications for each analysis tool.
**Plans:**
- [x] 04-01: Core tool adapters — SonarQube, Semgrep, Trivy, Gitleaks
- [x] 04-02: Extended tool adapters — Checkov, Syft, Grype, git history mining

### Phase 5: Personas

**Goal:** Create the 12 Core diagnostic personas and 5 Transform evolution personas.
**Plans:**
- [x] 05-01: Core audit personas (6)
- [x] 05-02: Operations & synthesis personas (6)
- [x] 05-03: Transform personas (5)

### Phase 6: Agent Assembly & Workflows

**Goal:** Create 17 agent assembly manifests and orchestration workflows.
**Plans:**
- [x] 06-01: Core agent manifests (12) + session handoff workflow
- [x] 06-02: Core phase orchestration workflows (Phases 0-5) + disagreement resolution
- [x] 06-03: Transform agent manifests (5) + Layer B/C pipeline workflows + safety

### Phase 7: Commands & UX

**Goal:** Create user-facing slash commands for diagnostic and Transform pipelines.
**Plans:**
- [x] 07-01: Core commands (audit, resume, status, report) + audit configuration
- [x] 07-02: Transform commands (transform, remediate, playbook, guardrails) + safety prerequisites

### Phase 8: End-to-End Validation

**Goal:** Validate all components compose correctly.
**Plans:**
- [x] 08-01: Specification validation (cross-reference integrity, convention compliance, version-lock manifest)
- [x] 08-02: README alignment (section-by-section audit against delivered specs)

</details>

---
*Roadmap created: 2026-02-12*
*Last updated: 2026-02-20 — Phase 11 complete*
