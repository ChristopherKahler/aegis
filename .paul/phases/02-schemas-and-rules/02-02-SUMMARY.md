---
phase: 02-schemas-and-rules
plan: 02
subsystem: schemas, rules
tags: [signal-normalization, report-structure, epistemic-hygiene, disagreement-protocol, agent-boundaries]

requires:
  - phase: 02-schemas-and-rules
    provides: Core schemas from Plan 02-01 (finding, disagreement, confidence)
provides:
  - Signal normalization schema (src/schemas/signal.md)
  - Report section schema for 7-section Layer A report (src/schemas/report-section.md)
  - Epistemic hygiene rules — 5 invariants (src/rules/epistemic-hygiene.md)
  - Disagreement protocol rules — 5 anti-pattern enforcement (src/rules/disagreement-protocol.md)
  - Agent boundary rules — 5 boundary constraints (src/rules/agent-boundaries.md)
affects: [phase-02-plan-03 (Transform schemas/rules reference these), phase-03-domains, phase-04-tools (signal schema defines tool output contract), phase-05-personas, phase-06-agents]

tech-stack:
  added: []
  patterns: [signal-normalization-dimensions, report-section-ordering, rule-enforcement-mechanisms]

key-files:
  created:
    - src/schemas/signal.md
    - src/schemas/report-section.md
    - src/rules/epistemic-hygiene.md
    - src/rules/disagreement-protocol.md
    - src/rules/agent-boundaries.md

key-decisions:
  - "Signal confidence_estimate is a simplified scalar (high/medium/low), not the full confidence vector — agents compute full vectors during analysis"
  - "Report sections are fixed order (1-7), all required — no optional sections"
  - "All 3 rule files set to priority: critical — violations invalidate output"
  - "Cross-domain observation allowed but must be filed under agent's own domain with reference"

patterns-established:
  - "Signal IDs use S-{TTT}-{NNN} format (TTT = tool abbreviation)"
  - "Report audit IDs use AEGIS-{YYYYMMDD}-{NNN} format"
  - "Every rule has three parts: statement, rationale, enforcement mechanism"
  - "DO/DON'T sections use concrete examples with explanations of why each is right/wrong"

duration: ~12min
started: 2026-02-13
completed: 2026-02-13
---

# Phase 2 Plan 02: Signal/Report Schemas + Core Rules — Summary

**Signal normalization schema, 7-section Layer A report schema, and three Core rule files (epistemic hygiene, disagreement protocol, agent boundaries) with 15 total enforceable rules.**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~12 min |
| Started | 2026-02-13 |
| Completed | 2026-02-13 |
| Tasks | 3 completed |
| Files created | 5 |
| Total lines | 490 |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Signal Schema Completeness | Pass | 6 signal categories, 4 normalization dimensions, 12 fields with types/enums, 7 validation rules, Semgrep worked example |
| AC-2: Report Section Schema Completeness | Pass | All 7 Layer A sections defined with content requirements, data sources, audiences. Section content rules. Executive Risk Summary worked example |
| AC-3: Epistemic Hygiene Rules | Pass | 5 rules matching README invariants, each with statement/rationale/enforcement. 4 DO examples, 4 DON'T examples with explanations |
| AC-4: Disagreement Protocol Rules | Pass | 5 rules encoding all README anti-patterns, enforcement mechanisms reference @schema:disagreement validation. 3 DO examples, 4 DON'T examples |
| AC-5: Agent Boundary Rules | Pass | 5 rules covering persona, domain, cross-domain, schema conformance, and signal consumption. Concrete enforcement for each. 4 DO, 4 DON'T examples |

## Accomplishments

- Signal schema normalizes heterogeneous tool output to 4 AEGIS dimensions while preserving raw tool output for audit trail integrity
- Report schema structures the 7-section Layer A report with fixed ordering, data source traceability, and audience targeting per section
- 15 enforceable rules across 3 files define the behavioral invariants that prevent epistemic drift, false consensus, and boundary violation

## Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `src/schemas/signal.md` | 108 | Unified tool output normalization — severity, confidence, blast radius, domain relevance |
| `src/schemas/report-section.md` | 150 | 7-section Layer A diagnostic report structure |
| `src/rules/epistemic-hygiene.md` | 78 | 5 non-negotiable epistemic invariants |
| `src/rules/disagreement-protocol.md` | 76 | 5 disagreement anti-pattern enforcement rules |
| `src/rules/agent-boundaries.md` | 78 | 5 agent compositional boundary constraints |

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## Next Phase Readiness

**Ready:**
- All Core schemas complete (5 files in src/schemas/)
- All Core rules complete (3 files in src/rules/)
- Plan 02-03 (Transform schemas + safety rules) can proceed — all Core schemas it references exist

**Concerns:**
- None

**Blockers:**
- None

---
*Phase: 02-schemas-and-rules, Plan: 02*
*Completed: 2026-02-13*
