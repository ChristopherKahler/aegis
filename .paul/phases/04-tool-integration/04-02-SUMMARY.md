---
phase: 04-tool-integration
plan: 02
subsystem: tools
tags: [tool-adapters, checkov, syft, grype, git-history, iac-scan, sbom, vulnerability-scan, history-mining, change-risk]

requires:
  - phase: 01-foundation
    provides: Tool convention specification (docs/standards/tools.md)
  - phase: 02-schemas-rules
    provides: Signal schema (src/schemas/signal.md) — normalization target
  - phase: 04-tool-integration/plan-01
    provides: Tool adapter pattern (multi-platform install, Docker variants, signal normalization)
provides:
  - 4 extended tool adapter specifications (Checkov, Syft, Grype, git-history)
  - IaC scanning coverage for security and compliance domains
  - SBOM generation + vulnerability scanning pipeline (Syft → Grype)
  - Git history mining with change-risk normalization for Transform integration
affects: [06-agents, 06-workflows, transform-change-risk-modeler]

tech-stack:
  added: []
  patterns: [sbom-pipeline-pattern, change-risk-normalization, inventory-vs-scanner-distinction]

key-files:
  created:
    - src/tools/checkov.md
    - src/tools/syft.md
    - src/tools/grype.md
    - src/tools/git-history.md
  modified: []

key-decisions:
  - "Syft and Grype are separate files despite being complementary — convention requires one tool per file"
  - "git-history uses native git commands (no external install) — only tool with install_required: false"
  - "git-history includes dual normalization: standard signal + change-risk mapping for Transform"

patterns-established:
  - "SBOM pipeline: Syft (inventory) → Grype (vulnerability matching) — Syft output is Grype input"
  - "Inventory tool normalization: severity derived from license risk, not vulnerability severity"
  - "Change-risk normalization: 4 Transform dimensions mapped from git metrics with concrete thresholds"

duration: ~8min
started: 2026-02-18
completed: 2026-02-18
---

# Phase 4 Plan 02: Extended Tool Adapters Summary

**4 extended tool adapter specifications completing the AEGIS 8-tool analysis stack — IaC scanning, SBOM pipeline, and git history mining with Transform change-risk integration.**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~8 minutes |
| Started | 2026-02-18 |
| Completed | 2026-02-18 |
| Tasks | 2 completed |
| Files created | 4 |
| Total lines | 2,194 |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Tool Structure Conformance | Pass | All 4 files have YAML frontmatter with all required fields and all 6 body sections in correct order |
| AC-2: Execution Commands Complete | Pass | All tools have runnable CLI commands, Docker variants, multiple install methods, and runtime expectations |
| AC-3: Output Format Examples | Pass | All tools include realistic JSON output snippets with multiple example entries |
| AC-4: Normalization Maps to Signal Schema | Pass | All tools have complete field mapping tables with signal ID patterns (S-CHK, S-SYF, S-GRP, S-GH) |
| AC-5: Limitations Documented | Pass | All tools document cannot-detect (6-7 items), false positives (5), false negatives (5-6) |
| AC-6: Git-History Change-Risk Normalization | Pass | git-history includes change-risk mapping with all 4 Transform dimensions and concrete thresholds |

## Accomplishments

- Created 4 extended tool adapters completing Phase 4's full tool stack (8 total files across both plans)
- Established SBOM pipeline pattern: Syft generates inventory, Grype consumes it for vulnerability matching
- git-history includes dual normalization — standard signal dimensions AND change-risk dimensions for Transform Change Risk Modeler
- Checkov covers IaC scanning across 6 frameworks (Terraform, CloudFormation, Kubernetes, Dockerfile, Helm, ARM)
- Verification: 61/61 convention compliance checks passed across all 4 files

## Files Created

| File | Lines | Type | Domains Fed |
|------|-------|------|-------------|
| `src/tools/checkov.md` | 463 | iac_scan | 04, 05 |
| `src/tools/syft.md` | 539 | sbom | 04, 05 |
| `src/tools/grype.md` | 611 | vulnerability_scan | 04, 05 |
| `src/tools/git-history.md` | 581 | history_mining | 11, 12 |
| **Total** | **2,194** | | |

## Decisions Made

| Decision | Rationale | Impact |
|----------|-----------|--------|
| Separate Syft/Grype files | Convention: one tool per file, even for complementary tools | Clean separation, each can be independently referenced |
| git-history install_required: false | Uses native git commands — no external dependency | Simplest tool to deploy, works everywhere git exists |
| Dual normalization for git-history | Feeds both Core domains (11, 12) and Transform (Change Risk Modeler) | First tool with explicit Transform integration |
| Inventory vs scanner distinction for Syft | Syft severity based on license risk (not CVEs) since it catalogs, not scans | Prevents confusion — Grype handles vulnerability severity |

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## Next Phase Readiness

**Ready:**
- All 8 tool adapters available for agent assembly (Phase 6)
- Signal normalization patterns established for all tool types
- SBOM pipeline pattern documented (Syft → Grype)
- Change-risk normalization ready for Transform agent integration
- Phase 4 complete — tool integration fully delivered

**Concerns:**
- None

**Blockers:**
- None

---
*Phase: 04-tool-integration, Plan: 02*
*Completed: 2026-02-18*
