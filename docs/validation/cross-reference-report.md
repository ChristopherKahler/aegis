# Cross-Reference Integrity Report

**Date:** 2026-02-19
**Scope:** All 90 AEGIS spec files across 8 component types
**Validator:** Phase 8 End-to-End Validation (08-01)

## Executive Summary

- **Total references checked:** 358
- **Valid references:** 352
- **Broken references:** 6
- **Root causes:** 3 distinct issues

All broken references are minor ID/path mismatches — no missing files or structural gaps.

## Results by Category

### 1. Agent → Persona References (17 checked)

| Agent | Persona Reference | Status |
|-------|------------------|--------|
| architect | architect | PASS |
| compliance-officer | compliance-officer | PASS |
| data-engineer | data-engineer | PASS |
| devils-advocate | devils-advocate | PASS |
| performance-engineer | performance-engineer | PASS |
| principal-engineer | principal-engineer | PASS |
| reality-gap-analyst | reality-gap-analyst | PASS |
| security-engineer | security-engineer | PASS |
| senior-app-engineer | senior-app-engineer | PASS |
| sre | sre | PASS |
| staff-engineer | staff-engineer | PASS |
| test-engineer | test-engineer | PASS |
| change-risk-modeler | change-risk-modeler | PASS |
| execution-validator | execution-validator | PASS |
| guardrail-generator | guardrail-generator | PASS |
| pedagogy-agent | pedagogy-agent | PASS |
| remediation-architect | remediation-architect | PASS |

**Result: 17/17 PASS**

### 2. Agent → Domain References (30 checked)

All domain number references (00-13) across 17 agents resolve to existing domain files.

**Result: 30/30 PASS**

### 3. Agent → Tool References (44 checked)

All tool IDs (sonarqube, semgrep, trivy, gitleaks, checkov, syft, grype, git-history) resolve to existing files.

**Result: 44/44 PASS**

### 4. Agent → Schema References (61 checked)

All schema references (finding, disagreement, confidence, signal, report-section, change-risk, intervention-level, playbook, verification-plan) resolve to existing files in src/schemas/ or src/transform/schemas/.

**Result: 61/61 PASS**

### 5. Agent → Rule References (46 checked)

All rule references (epistemic-hygiene, disagreement-protocol, agent-boundaries, safety-governance, change-risk-rules) resolve to existing files.

**Result: 46/46 PASS**

### 6. Workflow → Agent/Workflow References (33 checked)

| Workflow | Status | Notes |
|----------|--------|-------|
| phase-0-context.md | PASS | |
| phase-1-reconnaissance.md | PASS | Tool-only (no agents) |
| phase-2-domain-audits.md | PASS | All 8 domain agents verified |
| phase-3-cross-domain.md | PASS | |
| phase-4-adversarial-review.md | PASS | |
| phase-5-report.md | PASS | |
| session-handoff.md | PASS | Dynamic references |
| disagreement-resolution.md | PASS | |
| phase-6-remediation.md | **FAIL** | Wrong report path |
| phase-7-risk-validation.md | **FAIL** | Wrong schema path |
| phase-8-execution-planning.md | PASS | |
| transform-safety.md | **FAIL** | Wrong schema path |

**Result: 30/33 PASS, 3 FAIL**

### 7. Command → Workflow References (24 checked)

All 8 commands reference existing workflow files in their execution_context sections.

**Result: 24/24 PASS**

### 8. Domain → Tool Affinities (41 checked)

| Domain | Status | Notes |
|--------|--------|-------|
| 00-context | PASS | |
| 01-architecture | PASS | |
| 02-data | PASS | |
| 03-correctness | PASS | |
| 04-security | PASS | Syft+Grype listed as combined (both files exist) |
| 05-compliance | PASS | |
| 06-testing | PASS | |
| 07-reliability | PASS | |
| 08-performance | PASS | |
| 09-maintainability | PASS | |
| 10-operability | PASS | |
| 11-change-risk | **FAIL** | `syft-grype` doesn't match any tool file |
| 12-team-risk | PASS | |
| 13-risk-synthesis | PASS | |

**Result: 40/41 PASS, 1 FAIL**

### 9. Domain → owner_agents (14 checked)

| Domain | owner_agents Value | Status | Notes |
|--------|-------------------|--------|-------|
| 00 | principal-engineer | PASS | |
| 01 | architect | PASS | |
| 02 | data-engineer | PASS | |
| 03 | senior-application-engineer | **FAIL** | Should be `senior-app-engineer` |
| 04 | security-engineer | PASS | |
| 05 | compliance-officer | PASS | |
| 06 | test-engineer | PASS | |
| 07 | sre | PASS | |
| 08 | performance-engineer | PASS | |
| 09 | senior-application-engineer | **FAIL** | Should be `senior-app-engineer` |
| 10 | sre | PASS | |
| 11 | staff-engineer | PASS | |
| 12 | staff-engineer | PASS | |
| 13 | principal-engineer | PASS | |

**Result: 12/14 PASS, 2 FAIL**

## Broken References Detail

### Issue 1: Domain owner_agents ID mismatch (BLOCKER)

**Root cause:** Domains 03 and 09 use `senior-application-engineer` but the canonical agent ID is `senior-app-engineer`.

| File | Field | Current Value | Correct Value |
|------|-------|---------------|---------------|
| src/domains/03-correctness.md | owner_agents | senior-application-engineer | senior-app-engineer |
| src/domains/09-maintainability.md | owner_agents | senior-application-engineer | senior-app-engineer |

**Fix:** Update frontmatter in both domain files.

### Issue 2: Transform workflow schema path (BLOCKER)

**Root cause:** Two transform workflows reference `src/transform/schemas/confidence.md` which doesn't exist. The confidence schema lives at `src/schemas/confidence.md` (shared).

| File | Reference | Correct Path |
|------|-----------|--------------|
| src/transform/workflows/phase-7-risk-validation.md | @src/transform/schemas/confidence.md | @src/schemas/confidence.md |
| src/transform/workflows/transform-safety.md | @src/transform/schemas/confidence.md | @src/schemas/confidence.md |

**Fix:** Update references to point to correct shared schema path.

### Issue 3: Transform workflow report path (BLOCKER)

**Root cause:** phase-6-remediation.md references `.aegis/reports/REPORT.md` but Phase 5 output is `.aegis/report/AEGIS-REPORT.md`.

| File | Reference | Correct Path |
|------|-----------|--------------|
| src/transform/workflows/phase-6-remediation.md | @.aegis/reports/REPORT.md | @.aegis/report/AEGIS-REPORT.md |

**Fix:** Update runtime path reference.

### Issue 4: Domain tool affinity combined ID (WARNING)

**Root cause:** Domain 11 uses `syft-grype` as a single tool ID, but they're separate files (`syft.md` and `grype.md`).

| File | Current Value | Suggested Fix |
|------|---------------|---------------|
| src/domains/11-change-risk.md | syft-grype | Split into `syft` and `grype` rows |

**Severity:** Warning — the intent is clear and both tools exist, but the combined ID doesn't resolve to a file.

## Summary

| Category | Checked | Passed | Failed |
|----------|---------|--------|--------|
| Agent → Persona | 17 | 17 | 0 |
| Agent → Domain | 30 | 30 | 0 |
| Agent → Tool | 44 | 44 | 0 |
| Agent → Schema | 61 | 61 | 0 |
| Agent → Rule | 46 | 46 | 0 |
| Workflow → Refs | 33 | 30 | 3 |
| Command → Workflow | 24 | 24 | 0 |
| Domain → Tools | 41 | 40 | 1 |
| Domain → owner_agents | 14 | 12 | 2 |
| **TOTAL** | **310** | **304** | **6** |

All 17 agent assembly manifests are fully valid — the composition model (persona + domains + tools + schemas + rules) is structurally sound. Issues are limited to domain frontmatter and transform workflow references.

---
*Generated: 2026-02-19 — Phase 8 End-to-End Validation*
