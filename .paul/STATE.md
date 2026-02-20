# Project State

## Project Reference

See: .paul/PROJECT.md (updated 2026-02-21)

**Core value:** Comprehensive codebase auditing to senior/principal engineer standards through multi-agent epistemic-rigorous analysis — plus controlled evolution via AI-consumable transformation artifacts
**Current focus:** v0.2 Installation & Runtime — making AEGIS installable and usable

## Current Position

Milestone: v0.2 Installation & Runtime
Phase: 13 of 13 (Getting Started) — Ready to plan
Plan: Not started
Status: Ready to plan
Last activity: 2026-02-21 — Phase 12 complete, transitioned to Phase 13

Progress:
- v0.2: [████████░░] 80% (4/5 phases complete)
- Phase 13: [░░░░░░░░░░] 0% (not started)

## Loop Position

Current loop state:
```
PLAN ──▶ APPLY ──▶ UNIFY
  ○        ○        ○     [Ready for new PLAN]
```

## Accumulated Context

### Decisions
- AEGIS name and identity established
- 14 audit domains, 12 agent personas, 7-layer epistemic schema designed
- Tool stack selected: SonarQube, Semgrep, Trivy, Gitleaks, Checkov, Syft+Grype, CodeScene
- README.md written as comprehensive source of truth
- Phase 1 redefined: "Foundation Standards" replaces "Schemas & Data Contracts"
- 8 component types identified: personas, domains, schemas, rules, tools, agents, workflows, commands
- Decomposed agent architecture: Agent = Persona + Domains[] + Schemas + Rules + Tool Interfaces
- Three-layer agent design: Core Persona (strong/distinct) + Domain Modules (neutral/structured) + Execution Envelope (shared contracts)
- Version-locked audit compositions for reproducibility
- Two-tier runtime state: .aegis/ (operational) + audits/ (archival)
- All 8 component conventions defined upfront before any content creation
- Roadmap overhauled: 7→8 phases, organized by component type, dependencies corrected
- Convention meta-structure: 7 sections (Purpose, Location, Naming, Required Structure, Cross-References, Example Skeleton, Anti-Patterns)
- @-reference syntax for cross-component loading
- SHA-256 content hashing for version-locking manifests
- Two-system architecture — AEGIS Core (Diagnosis) + AEGIS Transform (Controlled Evolution)
- Three output layers — A (Diagnostic/Truth), B (Remediation Knowledge), C (Change Orchestration/PAUL)
- Four intervention levels — Suggesting, Planning, Authorizing, Executing
- 4-layer transformation model — Abstract → Framework → Language → Project
- 5 Transform agents — Remediation Architect, Change Risk Modeler, Pedagogy Agent, Guardrail Generator, Execution Validator
- "Diagnosis is decentralized. Intervention is centralized."
- Safety/liability framework — conservative bias, confidence gating, no auto-execution
- PAUL is the integration point for Layer C (execution planning)
- Two-system directory layout: src/core/ + src/transform/ + shared src/domains|schemas|rules|tools
- Dual format convention: Layer B/C artifacts have .md (human) + .yaml (machine) representations
- Transform safety rules are priority: critical by default
- Convention specs extended (not rewritten) with Transform sections
- Confidence overall derivation: min(evidence_diversity, signal_freshness) dominates — conservative by design
- Any confidence dimension = 1 caps overall at low — no compensation
- Confidence vectors immutable once attached to findings
- Disagreement principal_response always required regardless of status
- Schema cross-references use @schema:{id} syntax, IDs: F-{DD}-{NNN} for findings, D-{NNN} for disagreements
- **Phase 2 decisions:** Playbook IDs PB-{DD}-{NNN}, change-risk overall_risk uses highest-dimension-dominates derivation, intervention levels carry liability posture (advisor vs architectural_actor), unsafe context circuit breaker (risk dim ≥4 → force Suggesting), intervention level immutable after approval
- **Phase 3 decisions:** Strict 1:1 failure/best-practice mapping enforced as convention requirement, synthesis domain pattern established (Domain 13 describes process failures, not codebase failures), parallel subagent generation with post-hoc verification proven effective
- **Phase 4 decisions:** SBOM pipeline pattern (Syft inventory → Grype CVE matching), git-history dual normalization (Core + Transform change-risk), all tools platform-agnostic with Docker variants, Syft/Grype separate files per convention
- **Phase 5 decisions:** Cognitive fingerprint pattern (unique fear archetype per persona), identity-not-job-description approach, Transform triggers must be intervention-oriented (never diagnostic), all 17 personas verified distinct across fear archetypes/risk philosophies/mental models, Sonnet for content generation with Opus verification
- **Phase 6 decisions (06-01):** Meta-reasoners (Principal/Devil's Advocate) get empty domains[]/tools[] — consume findings not signals; Reality Gap Analyst cross-domain [00,01,07,10]; Staff Engineer phases [2,3] only (synthesis, not signal gathering); tool assignments derived from domain tool affinity tables (primary + key supporting)
- **Phase 6 decisions (06-02):** Phase 1 is pure tool orchestration (no reasoning agents); Phase 2 all 8 agents parallel-eligible; Phase 3 sequential (Staff→RGA) for synthesis quality; Phase 4 Devil's Advocate failure is CRITICAL (non-optional); Phase 5 hard gate on principal_response before synthesis; disagreement resolution is utility workflow (not phase)
- **Phase 6 decisions (06-03):** Transform agents use signal_input=finding (consume Layer A, not raw signals); intervention-level schema added to output of agents that classify intervention levels; transform-safety workflow invoked as utility by all phase workflows (not standalone); safety is per-item pass/downgrade/refuse pattern
- **Phase 7 decisions (07-01):** Audit configuration embedded in audit wizard (not separate command); report.md gates on Phases 0-4 only (it triggers Phase 5); read-only commands get empty execution_context with comment; wizard UX pattern: numbered options + cancel/back at every decision point
- **Phase 8 decisions (08-01):** Validation scoped to specification integrity (not live runtime execution — future milestone); 6 cross-ref fixes applied during validation (domain owner_agents ID mismatch, transform workflow paths, combined tool ID); subagent false-positive on workflow XML nesting caught and corrected via manual verification
- **v0.2 vision (user-defined):** Installation & Runtime milestone. Structure mirrors PAUL: `~/.claude/aegis/` (framework — all spec files), `~/.claude/commands/aegis/` (commands only). Interactive install script with Y/N per OSS tool, auto-installs dependencies, tests accessibility. New commands: `/aegis:init` (project setup, creates .aegis/ in target repo), `/aegis:validate` (test tools work, troubleshoot). Multi-session UX: frequent automatic checkpoints, easy handoff generation, set-and-forget between phases. Getting Started doc. Key gap: v0.1 command specs are not installable — `@` refs point to repo paths, need rewriting to `~/.claude/aegis/` absolute paths.
- **Phase 9 decisions (09-01):** Flat commands/ directory at repo root (mirrors PAUL pattern); allowed-tools per command based on actual process needs (status=read-only, audit/transform=full toolset); install mapping: commands/ → ~/.claude/commands/aegis/, src/ → ~/.claude/aegis/
- **Phase 10 decisions (10-01):** curl|bash as public install method (zero deps); Python tools via venv not pipx (PEP 668 compat); binary tools via curl to ~/.local/bin (no sudo); smart SonarQube detection (Docker scanner image + server container + localhost:9000); auto-skip already-installed tools; repo public at github.com/ChristopherKahler/aegis; AEGIS_BRANCH=feature/v1-implementation for testing (switch to main before release)
- **Phase 11 decisions (11-01):** Init separated from audit (project setup independent of audit execution); validate is read-only (safe to run anytime); audit delegates to init (no duplicate .aegis/ creation); .aegis-backup-{timestamp}/ archiving on fresh start; 10 total commands
- **Phase 12 decisions (12-01):** Checkpoint at phase boundary only (not agent boundary — session-handoff handles that); three checkpoint options (continue/pause/abort); session count estimates not time estimates; backward compatible for pre-Phase 12 STATE.md files

### Deferred Issues
None.

### Blockers/Concerns
None.

## Session Continuity

Last session: 2026-02-21
Stopped at: Phase 12 complete, ready to plan Phase 13
Next action: /paul:plan for Phase 13
Resume file: .paul/ROADMAP.md

---
*STATE.md — Updated after every significant action*
