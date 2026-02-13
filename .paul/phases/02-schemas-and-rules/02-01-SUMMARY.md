---
phase: 02-schemas-and-rules
plan: 01
subsystem: schemas
tags: [epistemic-finding, disagreement, confidence-vector, 7-layer-schema, data-contracts]

requires:
  - phase: 01-foundation-standards
    provides: Schema convention spec (docs/standards/schemas.md), directory structure (src/schemas/)
provides:
  - 7-layer epistemic finding schema (src/schemas/finding.md)
  - Disagreement record schema with closed taxonomies (src/schemas/disagreement.md)
  - Confidence vector schema with 4-dimension scoring (src/schemas/confidence.md)
affects: [phase-02-plan-02 (signal/report schemas reference these), phase-02-plan-03 (Transform schemas reference finding), phase-03-domains, phase-05-personas, phase-06-agents]

tech-stack:
  added: []
  patterns: [7-layer-epistemic-decomposition, confidence-as-vector, closed-taxonomy-enforcement, conservative-confidence-derivation]

key-files:
  created:
    - src/schemas/finding.md
    - src/schemas/disagreement.md
    - src/schemas/confidence.md

key-decisions:
  - "Confidence overall derivation uses min(evidence_diversity, signal_freshness) as primary factor — weakest evidential dimension dominates"
  - "Any single dimension scoring 1 caps overall at low — no compensation from other dimensions"
  - "Confidence vectors are immutable once attached to a finding — revisions require new finding version"
  - "Disagreement principal_response is ALWAYS required regardless of status — even open disagreements need acknowledgment"

patterns-established:
  - "Schema cross-references use @schema:{id} syntax for inter-schema references"
  - "ID formats: F-{DD}-{NNN} for findings, D-{NNN} for disagreements"
  - "Every enum field lists ALL valid values explicitly — no open-ended enums"
  - "Validation rules are concrete and enforceable — each describes a detectable violation"
  - "Worked examples demonstrate realistic scenarios, not toy examples"

duration: ~15min
started: 2026-02-13
completed: 2026-02-13
---

# Phase 2 Plan 01: Core Schemas — Summary

**Three foundational data contracts created: 7-layer epistemic finding schema, structured disagreement record with closed taxonomies, and 4-dimension confidence vector with conservative derivation formula.**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~15 min |
| Started | 2026-02-13 |
| Completed | 2026-02-13 |
| Tasks | 3 completed |
| Files created | 3 |
| Total lines | 710 |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Finding Schema Completeness | Pass | Frontmatter, all 5 body sections, 7 epistemic layers in template, comprehensive field reference covering all fields with types/enums, 13 validation rules, one complete worked example (hardcoded credentials) |
| AC-2: Disagreement Schema Completeness | Pass | All fields from README structure, 7-entry root cause taxonomy (closed), 5 resolution models, 5 status states, principal_response always required, full worked example with resolution lifecycle |
| AC-3: Confidence Vector Completeness | Pass | 4 dimensions with anchored 1-5 scales, conservative overall derivation formula, justification required, two contrasting worked examples (high-confidence and low-confidence) |
| AC-4: Cross-Reference Consistency | Pass | finding.md references confidence.md via @schema:confidence, disagreement.md references finding.md via F-{DD}-{NNN} format, all ID formats consistent across schemas |

## Accomplishments

- Finding schema enforces epistemic decomposition through 7 mandatory layers — agents cannot jump from observation to judgment, preventing confident conclusions built on unexamined assumptions
- Confidence vector replaces scalar confidence with 4-dimension profile, enabling nuanced statements and gating Transform intervention levels on specific dimensions
- Disagreement schema makes disagreements first-class objects with closed taxonomies (7 root causes, 5 resolution models) and mandatory Principal response — no silent disappearance

## Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `src/schemas/finding.md` | 287 | 7-layer epistemic finding — atomic unit of agent diagnostic output |
| `src/schemas/disagreement.md` | 238 | Structured disagreement record with positions, root cause taxonomy, resolution models |
| `src/schemas/confidence.md` | 185 | 4-dimension confidence vector with conservative derivation formula |

## Decisions Made

| Decision | Rationale | Impact |
|----------|-----------|--------|
| Conservative confidence formula: min(evidence, freshness) dominates | A finding is only as trustworthy as its weakest evidential link — high evidence diversity can't compensate for stale signals | Transform confidence gating uses overall, so conservative derivation prevents poorly-evidenced findings from reaching higher intervention levels |
| Any dimension = 1 caps overall at low | Single catastrophic weakness in evidence invalidates aggregate confidence | Prevents inflation where 3 strong dimensions mask 1 fatal weakness |
| Immutable confidence vectors | Changing confidence after submission breaks audit trail integrity | Findings requiring updated confidence must be reissued with version suffix (F-04-001v2) |
| principal_response always required | Even open disagreements need acknowledgment — silence is an anti-pattern | Enforces that every disagreement is explicitly seen and addressed by the epistemic governor |

## Deviations from Plan

None — plan executed exactly as written. All 3 tasks completed autonomously with all acceptance criteria satisfied.

## Issues Encountered

None.

## Next Phase Readiness

**Ready:**
- Core output contracts are in place — agents can now be designed to produce schema-conformant findings
- Cross-reference patterns established (ID formats, @schema: syntax) for use in remaining schemas
- Confidence vector ready for Transform intervention level gating (Plan 02-03)

**Concerns:**
- None

**Blockers:**
- None

---
*Phase: 02-schemas-and-rules, Plan: 01*
*Completed: 2026-02-13*
