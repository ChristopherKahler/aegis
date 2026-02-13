---
phase: 02-schemas-and-rules
plan: 03
subsystem: schemas, rules
tags: [transform, remediation-playbook, change-risk, intervention-level, verification-plan, safety-governance, confidence-gating]

requires:
  - phase: 02-schemas-and-rules
    provides: Core schemas (finding, disagreement, confidence, signal, report-section) and Core rules (epistemic-hygiene, disagreement-protocol, agent-boundaries)
provides:
  - Remediation playbook schema (src/transform/schemas/playbook.md)
  - Change risk assessment schema (src/transform/schemas/change-risk.md)
  - Intervention level governance schema (src/transform/schemas/intervention-level.md)
  - Verification plan schema (src/transform/schemas/verification-plan.md)
  - Safety governance rules — 5 rules (src/transform/rules/safety-governance.md)
  - Change risk rules — 5 rules (src/transform/rules/change-risk-rules.md)
affects: [phase-05-personas (Transform persona designs reference these schemas), phase-06-agents (Transform agent manifests consume these schemas/rules), phase-06-workflows (Transform workflows enforce these rules)]

tech-stack:
  added: []
  patterns: [4-layer-transformation-model, intervention-level-escalation, conservative-bias-gating, unsafe-context-circuit-breaker, risk-recommendation-alignment]

key-files:
  created:
    - src/transform/schemas/playbook.md
    - src/transform/schemas/change-risk.md
    - src/transform/schemas/intervention-level.md
    - src/transform/schemas/verification-plan.md
    - src/transform/rules/safety-governance.md
    - src/transform/rules/change-risk-rules.md

key-decisions:
  - "Playbook IDs use PB-{DD}-{NNN} format, matching domain from source finding"
  - "Change-risk overall_risk derivation: highest-scoring dimension dominates (not averaged) — mirrors conservative confidence derivation"
  - "Intervention levels carry liability posture: advisor (suggesting/planning) vs architectural_actor (authorizing/executing)"
  - "Unsafe context circuit breaker: any risk dimension ≥4 forces downgrade to Suggesting — non-overridable"
  - "Intervention level immutability after approval: upgrading requires full re-assessment, downgrading is always permitted"
  - "Safety rules organized into 2 files: governance (intervention/execution boundaries) + change-risk (assessment rigor)"

patterns-established:
  - "Transform schema cross-references use same @schema:{id} syntax as Core schemas"
  - "Risk dimension scoring anchored 1-5 with concrete descriptions per anchor point"
  - "Every risk score requires paired evidence — score without evidence is invalid"
  - "Intervention level thresholds are hard gates, not recommendations"
  - "DO/DON'T examples in Transform rules include realistic scenarios with specific evidence citations"

duration: ~15min
started: 2026-02-13
completed: 2026-02-13
---

# Phase 2 Plan 03: Transform Schemas + Safety Rules — Summary

**Four Transform schemas (playbook, change-risk, intervention-level, verification-plan) and two Transform safety rule files (10 rules total) governing remediation planning, risk assessment, intervention governance, and safety constraints.**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~15 min |
| Started | 2026-02-13 |
| Completed | 2026-02-13 |
| Tasks | 3 completed |
| Files created | 6 |
| Total lines | 859 |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Transform Schema Completeness | Pass | All 4 schemas have frontmatter, Purpose, Template, Field Reference, Validation Rules (7-10 per schema), and worked Examples. intervention-level.md includes all 4 tier definitions. |
| AC-2: Core-to-Transform Cross-References | Pass | playbook→finding (finding_ref), change-risk→finding (finding_refs), verification-plan→change-risk (change_id), intervention-level→confidence (minimum thresholds). All use @schema:{id} syntax. |
| AC-3: Transform Safety Rules Completeness | Pass | 2 rule files with 5 rules each. All 6 safety categories from standards covered: Conservative Bias, Confidence Gating, Unsafe Context Flagging, No Auto-Execution, Change Risk, Liability. Both files have Purpose, Rules, DO, DON'T. |
| AC-4: Rule Enforcement Mechanisms | Pass | All 10 rules have concrete enforcement mechanisms referencing specific schema fields (@schema:playbook, @schema:change-risk, @schema:intervention-level) and validation steps. No vague guidance. |

## Accomplishments

- Transform schemas define the complete data contract for Layers B and C — from finding-level remediation (playbook) through risk assessment (change-risk) to governance (intervention-level) and verification (verification-plan)
- Intervention level schema establishes the single source of truth for the 4-tier governance model with hard-gated confidence thresholds, liability postures, and risk constraints per tier
- 10 Transform safety rules across 2 files create non-overridable enforcement boundaries: no auto-execution, confidence gating, unsafe context circuit breaker, mandatory blast radius assessment, regression evidence requirements

## Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `src/transform/schemas/playbook.md` | 205 | Remediation playbook — 4-layer transformation model, risk metadata, verification steps |
| `src/transform/schemas/change-risk.md` | 139 | Multi-dimensional change risk assessment — 4 risk dimensions with evidence |
| `src/transform/schemas/intervention-level.md` | 207 | Governance tier definitions — suggesting/planning/authorizing/executing with thresholds |
| `src/transform/schemas/verification-plan.md` | 134 | Pre/post/regression checks and rollback procedures for proposed changes |
| `src/transform/rules/safety-governance.md` | 87 | 5 rules: no auto-execution, conservative bias, confidence gating, liability escalation, level immutability |
| `src/transform/rules/change-risk-rules.md` | 87 | 5 rules: blast radius assessment, coupling analysis, regression evidence, unsafe context downgrade, risk-recommendation alignment |

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## Next Phase Readiness

**Ready:**
- Phase 2 (Schemas & Rules) fully complete — all Core + Transform schemas and rules delivered
- 9 schema files total: 5 Core (src/schemas/) + 4 Transform (src/transform/schemas/)
- 5 rule files total: 3 Core (src/rules/) + 2 Transform (src/transform/rules/)
- Phase 3 (Domain Knowledge) can proceed — domains reference these schemas for output contracts
- Phase 4 (Tool Integration) can proceed — tools normalize into signal schema
- Phase 5 (Personas) can proceed — personas reference rules for behavioral constraints

**Concerns:**
- None

**Blockers:**
- None

---
*Phase: 02-schemas-and-rules, Plan: 03*
*Completed: 2026-02-13*
