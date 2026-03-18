# Runtime & Versioning Specification

## Purpose

Defines the per-audit runtime state structure, archival output format, version-locking manifest, audit lifecycle, and state document format. This spec governs what gets created in the target codebase during an audit and how audit outputs are preserved.

## Per-Audit Operational State (.aegis/)

When an AEGIS audit is initiated on a target codebase, a `.aegis/` directory is created with this structure:

```
.aegis/
├── STATE.md                    # Current audit position
├── MANIFEST.md                 # Version-locked component references
│
│   ── Layer A: Diagnostic Artifacts (Phases 0-5) ──
│
├── context/                    # Phase 0 output
│   ├── scope.md                # Audit scope and non-goals
│   └── threat-model.md         # Risk profile and threat model
├── signals/                    # Phase 1 output
│   └── {tool-id}/              # Per-tool normalized signals
│       └── signals.md          # Normalized signal data
├── findings/                   # Phase 2-3 output
│   └── {agent-id}/             # Per-agent finding files
│       ├── finding-001.md
│       └── finding-NNN.md
├── review/                     # Phase 4 output
│   └── devils-advocate.md      # Adversarial review critique
├── report/                     # Phase 5 output
│   ├── executive-summary.md
│   ├── findings-by-domain.md
│   ├── disagreements.md
│   └── remediation-roadmap.md
│
│   ── Layer B: Remediation Knowledge (Phases 6-7) ──
│
├── remediation/                # Layer B root
│   ├── REMEDIATION-SUMMARY.md  # Overview of all remediation
│   ├── playbooks/              # Per-finding remediation playbooks
│   │   ├── {finding-id}.md     # Human-readable playbook
│   │   └── {finding-id}.yaml   # Machine-consumable playbook
│   ├── patterns/               # Best practice patterns applied
│   │   └── {pattern-id}.md     # Correct pattern documentation
│   └── guardrails/             # Generated project rules
│       ├── claude-md-rules.md  # Rules for .claude/CLAUDE.md
│       └── cursorrules.md      # Rules for .cursorrules
│
│   ── Layer C: Change Orchestration (Phase 8) ──
│
└── execution/                  # Layer C root
    ├── change-graph.yaml       # Dependency-ordered change plan
    ├── risk-scores.yaml        # Per-change risk assessment
    ├── verification-plan.md    # How to verify all changes
    └── paul-project/           # PAUL-ready project artifacts
        ├── PROJECT.md          # PAUL project definition
        ├── ROADMAP.md          # Phased remediation plan
        └── phases/             # Pre-planned PAUL phases
```

### Operational State Structure

#### Layer A — Diagnostic Artifacts (Phases 0-5)

| Directory/File | Created By | Created During | Purpose |
|----------------|------------|----------------|---------|
| `.aegis/` | System | Audit initialization | Root operational directory for active audit |
| `STATE.md` | System | Audit initialization | Tracks current phase, progress, and resume information |
| `MANIFEST.md` | System | Audit initialization | Version-locks all AEGIS components used in this audit |
| `context/` | Principal Engineer | Phase 0 | Stores scope definition and threat model |
| `context/scope.md` | Principal Engineer | Phase 0 | Documents audit scope, boundaries, and explicit non-goals |
| `context/threat-model.md` | Principal Engineer | Phase 0 | Risk profile, attack surface, and threat scenarios |
| `signals/` | Tool runners | Phase 1 | Container for all automated tool outputs |
| `signals/{tool-id}/` | Tool runner | Phase 1 | Isolated directory per tool (semgrep, bandit, etc.) |
| `signals/{tool-id}/signals.md` | Tool runner | Phase 1 | Normalized signal data from tool execution |
| `findings/` | Domain agents | Phases 2-3 | Container for all agent-generated findings |
| `findings/{agent-id}/` | Agent | Phases 2-3 | Isolated directory per agent (security, auth, etc.) |
| `findings/{agent-id}/finding-NNN.md` | Agent | Phases 2-3 | Individual finding documents following schema |
| `review/` | Devil's Advocate | Phase 4 | Adversarial review outputs |
| `review/devils-advocate.md` | Devil's Advocate | Phase 4 | Challenges, confidence attacks, and critique |
| `report/` | Principal Engineer | Phase 5 | Final synthesis and deliverables |
| `report/executive-summary.md` | Principal Engineer | Phase 5 | High-level findings for technical leadership |
| `report/findings-by-domain.md` | Principal Engineer | Phase 5 | Organized view of all findings |
| `report/disagreements.md` | Principal Engineer | Phase 5 | Documented agent disagreements and resolutions |
| `report/remediation-roadmap.md` | Principal Engineer | Phase 5 | Prioritized action plan with timelines |

#### Layer B — Remediation Knowledge (Phases 6-7)

| Directory/File | Created By | Created During | Purpose |
|----------------|------------|----------------|---------|
| `remediation/` | System | Phase 6 initialization | Root directory for all remediation artifacts |
| `remediation/REMEDIATION-SUMMARY.md` | Remediation Architect | Phase 6 | Overview of all remediation: finding count, playbook count, intervention level distribution |
| `remediation/playbooks/` | Remediation Architect + Pedagogy Agent | Phase 6 | Container for per-finding remediation playbooks |
| `remediation/playbooks/{finding-id}.md` | Remediation Architect + Pedagogy Agent | Phase 6 | Human-readable playbook: explanation, rationale, before/after examples, educational context |
| `remediation/playbooks/{finding-id}.yaml` | Remediation Architect | Phase 6 | Machine-consumable playbook: file targets, change instructions, verification steps, risk metadata, intervention level |
| `remediation/patterns/` | Pedagogy Agent | Phase 6 | Best-practice patterns extracted during remediation |
| `remediation/patterns/{pattern-id}.md` | Pedagogy Agent | Phase 6 | Correct pattern documentation at all 4 transformation layers |
| `remediation/guardrails/` | Guardrail Generator | Phase 7 | Generated project rules for future AI usage |
| `remediation/guardrails/claude-md-rules.md` | Guardrail Generator | Phase 7 | Rules formatted for `.claude/CLAUDE.md` |
| `remediation/guardrails/cursorrules.md` | Guardrail Generator | Phase 7 | Rules formatted for `.cursorrules` |

#### Layer C — Change Orchestration (Phase 8)

| Directory/File | Created By | Created During | Purpose |
|----------------|------------|----------------|---------|
| `execution/` | System | Phase 8 initialization | Root directory for execution planning artifacts |
| `execution/change-graph.yaml` | Remediation Architect | Phase 8 | Dependency-ordered graph of all proposed changes |
| `execution/risk-scores.yaml` | Change Risk Modeler | Phase 7-8 | Per-change risk assessment (blast radius, coupling, regression, architectural tension) |
| `execution/verification-plan.md` | Execution Validator | Phase 8 | Consolidated verification plan for all changes |
| `execution/paul-project/` | System | Phase 8 | PAUL-ready project directory |
| `execution/paul-project/PROJECT.md` | System | Phase 8 | PAUL project definition referencing AEGIS audit |
| `execution/paul-project/ROADMAP.md` | System | Phase 8 | Phased remediation plan with dependency ordering |
| `execution/paul-project/phases/` | System | Phase 8 | Pre-planned PAUL phases with risk-scored tasks |

## Archival Output Structure

After audit completion, the operational state is archived:

- **Location**: Configurable, default `audits/{YYYY-MM-DD}-{short-hash}/`
- **Short-hash format**: First 8 characters of the target repository's HEAD commit
- **Contents**: Complete copy of `.aegis/` directory at audit completion
- **Immutability**: Archived outputs are NEVER modified after creation
- **Cleanup**: The `.aegis/` operational directory can be cleaned up after archival

### Example Archive Path

```
audits/2026-02-12-a3f7b9c1/
└── [complete copy of .aegis/ contents]
```

The archive preserves the forensic record of the audit, enabling:
- Point-in-time comparison between audits
- Regulatory compliance and audit trails
- Reproduction of audit results given the same inputs

## Version-Locking Manifest

The `MANIFEST.md` file locks all AEGIS components to specific versions via cryptographic hashes. This enables audit reproducibility and forensic integrity.

### MANIFEST.md Template

```markdown
# AEGIS Audit Manifest

## Audit Metadata

| Field | Value |
|-------|-------|
| Date | [YYYY-MM-DD HH:MM UTC] |
| Target | [repository path or URL] |
| Target Commit | [full SHA] |
| AEGIS Version | [version or commit hash] |

## Component Versions

| Type | File | SHA-256 |
|------|------|---------|
| persona | src/personas/principal-engineer.md | [hash] |
| persona | src/personas/architect.md | [hash] |
| persona | src/personas/security-engineer.md | [hash] |
| persona | src/personas/staff-engineer.md | [hash] |
| persona | src/personas/devils-advocate.md | [hash] |
| domain | src/domains/00-context.md | [hash] |
| domain | src/domains/01-security.md | [hash] |
| domain | src/domains/02-authentication.md | [hash] |
| domain | src/domains/03-authorization.md | [hash] |
| domain | src/domains/04-data-integrity.md | [hash] |
| domain | src/domains/05-crypto.md | [hash] |
| domain | src/domains/06-input-validation.md | [hash] |
| domain | src/domains/07-error-handling.md | [hash] |
| domain | src/domains/08-state-management.md | [hash] |
| domain | src/domains/09-dependency-management.md | [hash] |
| domain | src/domains/10-configuration.md | [hash] |
| domain | src/domains/11-observability.md | [hash] |
| domain | src/domains/12-architecture.md | [hash] |
| domain | src/domains/13-change-risk.md | [hash] |
| domain | src/domains/14-reality-gap.md | [hash] |
| schema | src/schemas/finding.md | [hash] |
| schema | src/schemas/signal.md | [hash] |
| schema | src/schemas/disagreement.md | [hash] |
| rule | src/rules/epistemic-hygiene.md | [hash] |
| rule | src/rules/confidence-calibration.md | [hash] |
| rule | src/rules/evidence-standards.md | [hash] |
| tool | src/tools/semgrep.md | [hash] |
| tool | src/tools/bandit.md | [hash] |
| tool | src/tools/trivy.md | [hash] |
| agent | src/agents/security-engineer.md | [hash] |
| agent | src/agents/auth-specialist.md | [hash] |
| agent | src/agents/data-engineer.md | [hash] |
| agent | src/agents/crypto-specialist.md | [hash] |
| agent | src/agents/input-validation-specialist.md | [hash] |
| agent | src/agents/error-handling-specialist.md | [hash] |
| agent | src/agents/state-engineer.md | [hash] |
| agent | src/agents/dependency-analyst.md | [hash] |
| agent | src/agents/config-specialist.md | [hash] |
| agent | src/agents/observability-engineer.md | [hash] |
| agent | src/agents/architect.md | [hash] |
| agent | src/agents/staff-engineer.md | [hash] |
| agent | src/agents/reality-gap-analyst.md | [hash] |
| agent | src/agents/devils-advocate.md | [hash] |
| workflow | src/workflows/phase-0-context.md | [hash] |
| workflow | src/workflows/phase-1-signals.md | [hash] |
| workflow | src/workflows/phase-2-domain-audit.md | [hash] |
| workflow | src/workflows/phase-3-synthesis.md | [hash] |
| workflow | src/workflows/phase-4-adversarial-review.md | [hash] |
| workflow | src/workflows/phase-5-report.md | [hash] |
```

### Purpose

The manifest enables audit reproduction. Given the same codebase state (target commit) and the same component versions (manifest hashes), the audit produces equivalent results. This supports:

- **Forensic integrity**: Prove which component versions were used
- **Reproducibility**: Re-run audit with identical inputs
- **Debugging**: Isolate component changes that affect audit behavior
- **Compliance**: Demonstrate audit methodology was unchanged

## Dual Format Specification

Transform artifacts (Layers B and C) carry both human-readable and machine-consumable representations. This is a convention, not optional.

### Human-Readable Format (`.md`)

Contains:
- Explanation and rationale for the remediation
- Before/after code examples
- Educational context (why this pattern matters)
- Best-practice references
- Verification instructions in prose

### Machine-Consumable Format (`.yaml`)

Contains:
- File targets (paths and line numbers)
- Change instructions (structured diffs or transformation rules)
- Verification steps (executable checks)
- Risk metadata (blast radius, coupling, regression probability, architectural tension scores)
- Intervention level classification
- Finding references (which Layer A findings this remediates)
- Dependency references (which other changes must happen first)

### Convention

- Every Layer B playbook has both `{finding-id}.md` and `{finding-id}.yaml`
- Layer C artifacts are primarily `.yaml` (operational data) with `.md` summaries for human review
- The `.yaml` representation is the authoritative source for machine consumption (PAUL, AI assistants)
- The `.md` representation is the authoritative source for human understanding
- Neither representation is derived from the other — both are produced by the same agent during the same phase

## Pipeline Flow

Data flows through AEGIS in a strict derivation chain across three layers.

```
Phase 0-5 (Core)          Phase 6-7 (Transform)       Phase 8 (Transform)
┌──────────────────┐      ┌──────────────────┐         ┌──────────────────┐
│    Layer A        │ ───▶ │    Layer B        │ ──────▶ │    Layer C        │
│  Diagnostic       │      │  Remediation      │         │  Change           │
│  Artifacts        │      │  Knowledge        │         │  Orchestration    │
│                   │      │                   │         │                   │
│  findings/        │      │  remediation/     │         │  execution/       │
│  review/          │      │    playbooks/     │         │    change-graph   │
│  report/          │      │    patterns/      │         │    risk-scores    │
│  signals/         │      │    guardrails/    │         │    paul-project/  │
│  context/         │      │                   │         │                   │
└──────────────────┘      └──────────────────┘         └──────────────────┘
     Immutable               Derived from A              Derived from B
```

### Derivation Rules

1. **Layer B cannot exist without Layer A.** Transform cannot run without a completed Core audit.
2. **Layer C cannot exist without Layer B.** Execution planning cannot run without remediation knowledge.
3. **Layer A is never mutated by Transform.** Findings remain as produced by Core agents. Transform may reference them but never modifies them.
4. **Layer B artifacts reference Layer A findings.** Every playbook links to the finding(s) it remediates.
5. **Layer C artifacts reference Layer B playbooks.** Every execution plan links to the remediation knowledge it implements.

## Audit Lifecycle

State flows through AEGIS execution phases sequentially, with parallelization opportunities within phases.

### Core Phases (Layer A)

| Phase | Name | Creates | Agent(s) | Description |
|-------|------|---------|----------|-------------|
| 0 | Context & Threat Modeling | `context/` | Principal Engineer | Scope, threat model, non-goals |
| 1 | Automated Signal Gathering | `signals/` | (tool runners) | Run tools, normalize output |
| 2 | Deep Domain Audits | `findings/{agent}/` | 8 domain agents | Independent domain analysis |
| 3 | Change Risk, Team Risk & Reality Gap | `findings/{agent}/` | Staff Engineer, Reality Gap Analyst | Synthesis-heavy analysis |
| 4 | Adversarial Review | `review/` | Devil's Advocate | Challenge assumptions, attack confidence |
| 5 | Synthesis & Report | `report/` | Principal Engineer | Final report, disagreement resolution |

### Transform Phases (Layers B & C)

| Phase | Name | Creates | Agent(s) | Description |
|-------|------|---------|----------|-------------|
| 6 | Remediation Synthesis | `remediation/playbooks/`, `remediation/patterns/` | Remediation Architect, Pedagogy Agent | Produce playbooks at all 4 transformation layers |
| 7 | Change Risk Validation | `remediation/guardrails/`, `execution/risk-scores.yaml` | Change Risk Modeler, Guardrail Generator | Score change risk, generate guardrails |
| 8 | Execution Planning | `execution/` | Execution Validator | Verification plans, PAUL project generation |

### Completion

| Step | Name | Creates | Actor | Description |
|------|------|---------|-------|-------------|
| Complete | Archival | `audits/{date}-{hash}/` | (system) | Archive `.aegis/` to immutable record |

### Execution Model

- **Sequential phases**: Phases execute in order (0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → Complete)
- **Parallel agents**: Phase 2 agents can run in parallel within the phase
- **Transform is optional**: Phases 6-8 only run when Transform is explicitly initiated after Core completion
- **Resumability**: Audit can pause and resume at any phase boundary
- **State persistence**: `STATE.md` tracks progress and enables resume

### Phase Dependencies

- Phase 1 depends on Phase 0 (scope and threat model inform tool selection)
- Phase 2 depends on Phase 1 (signals inform domain audits)
- Phase 3 depends on Phase 2 (findings inform synthesis)
- Phase 4 depends on Phases 2-3 (all findings must exist for review)
- Phase 5 depends on Phase 4 (adversarial feedback informs final report)
- Phase 6 depends on Phase 5 (complete Layer A record required for remediation)
- Phase 7 depends on Phase 6 (playbooks must exist for risk scoring)
- Phase 8 depends on Phase 7 (risk-scored plan required for execution planning)

## State Document Format

The `STATE.md` file tracks audit progress and enables resumption after interruption.

### STATE.md Template

```markdown
# AEGIS Audit State

## Audit Info

| Field | Value |
|-------|-------|
| Target | [repository] |
| Started | [timestamp] |
| Current Phase | [0-5] |
| Status | [in_progress / paused / complete] |

## Phase Progress

| Phase | Status | Agent(s) | Findings | Started | Completed |
|-------|--------|----------|----------|---------|-----------|
| 0 | [pending/active/complete] | principal-engineer | - | [time] | [time] |
| 1 | [pending/active/complete] | (tools) | - | | |
| 2 | [pending/active/complete] | [list] | [count] | | |
| 3 | [pending/active/complete] | [list] | [count] | | |
| 4 | [pending/active/complete] | devils-advocate | [count] | | |
| 5 | [pending/active/complete] | principal-engineer | - | | |
| 6 | [pending/active/complete/skipped] | remediation-architect, pedagogy-agent | [playbook count] | | |
| 7 | [pending/active/complete/skipped] | change-risk-modeler, guardrail-generator | [risk scores] | | |
| 8 | [pending/active/complete/skipped] | execution-validator | [PAUL artifacts] | | |

## Summary

- Total findings: [N]
- Disagreements: [N] (open: [N], resolved: [N])
- Domains covered: [N] of 14

## Resume Info

Last action: [what was happening]
Next action: [what to do next]
```

### State Values

- **Status values**: `pending`, `active`, `complete`, `skipped` (Transform phases only — `skipped` when Transform is not run)
- **Current Phase**: Integer 0-8, or "complete" after archival
- **Agent list**: Comma-separated agent IDs for phases with multiple agents
- **Findings count**: Number of finding files created by agents in that phase

### Resume Semantics

The "Resume Info" section enables graceful continuation after interruption:
- **Last action**: Human-readable description of what was executing when paused
- **Next action**: Specific instruction for what should happen on resume
- Example: "Last action: Completed 6 of 8 domain audits. Next action: Run crypto-specialist agent."

## Two-Tier State Model

AEGIS maintains audit state in two distinct tiers with different mutability and lifecycle properties.

### Operational Tier (`.aegis/`)

- **Location**: Inside target repository (`.aegis/`)
- **Mutability**: Mutable during audit execution
- **Lifecycle**: Created at audit start, deleted after archival
- **Purpose**: Support incremental progress and resumption
- **Access pattern**: Read-write by AEGIS runtime

### Archival Tier (`audits/`)

- **Location**: Outside target repository (configurable path)
- **Mutability**: Immutable after creation
- **Lifecycle**: Created at audit completion, never modified
- **Purpose**: Forensic record with version-locked components
- **Access pattern**: Write-once by AEGIS runtime, read-only for analysis

### Benefits of Separation

This two-tier model enables:

1. **Re-audits against same codebase**: Compare archival outputs from different audit runs to track security posture over time
2. **Audit reproducibility**: Manifest + target commit = deterministic inputs for equivalent results
3. **Clean target repositories**: Operational state is ephemeral and can be deleted after archival
4. **Regulatory compliance**: Immutable audit trail proves what was found and when
5. **Parallel development**: Multiple audits can run against different versions without state collision
6. **Git-friendly workflow**: Operational state can be gitignored, archives can be stored separately

### Archival Process

When audit reaches completion:

1. System validates all phases are complete
2. System generates archive path: `audits/{YYYY-MM-DD}-{short-hash}/`
3. System copies entire `.aegis/` directory to archive path
4. System marks archive as immutable (filesystem permissions or object storage policy)
5. System updates `STATE.md` to status "complete"
6. (Optional) System removes `.aegis/` from target repository

### Audit Comparison

Comparing two audits of the same codebase:

```bash
diff -r audits/2026-02-12-a3f7b9c1/ audits/2026-03-15-a3f7b9c1/
```

If the target commit is identical (`a3f7b9c1`), differences indicate:
- Non-deterministic tool behavior (investigate)
- AEGIS component changes (check manifests)
- Audit configuration differences (compare STATE.md)

If the target commit differs, differences indicate:
- Security posture changes in codebase
- New vulnerabilities introduced
- Previous findings remediated

This enables tracking security health over time with forensic precision.
