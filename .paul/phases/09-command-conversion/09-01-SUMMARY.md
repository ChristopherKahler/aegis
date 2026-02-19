---
phase: 09-command-conversion
plan: 01
subsystem: commands
tags: [claude-code, slash-commands, install-structure]

requires:
  - phase: 08-validation
    provides: 90 validated spec files with @src/ references
provides:
  - 8 installable slash commands with allowed-tools and @~/.claude/aegis/ paths
  - 12 workflow files with rewritten @~/.claude/aegis/ references
  - Clean install mapping: commands/ → ~/.claude/commands/aegis/, src/ → ~/.claude/aegis/
affects: [10-install-system, 13-getting-started]

tech-stack:
  added: []
  patterns: [install-target directory layout, allowed-tools frontmatter convention]

key-files:
  created: []
  modified:
    - commands/*.md (8 files — moved from src/, rewritten, allowed-tools added)
    - src/core/workflows/*.md (8 files — @src/ refs rewritten)
    - src/transform/workflows/*.md (4 files — @src/ refs rewritten)

key-decisions:
  - "Flat commands/ directory at repo root — mirrors PAUL install pattern"
  - "allowed-tools per command based on actual process requirements"

patterns-established:
  - "Install mapping: commands/ → ~/.claude/commands/aegis/, src/ → ~/.claude/aegis/"
  - "@~/.claude/aegis/ as the canonical installed path prefix"

duration: ~15min
completed: 2026-02-19
---

# Phase 9 Plan 01: Command Conversion Summary

**8 commands relocated to flat commands/ directory, all 20 files rewritten from @src/ to @~/.claude/aegis/, allowed-tools frontmatter added to all commands.**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~15min |
| Completed | 2026-02-19 |
| Tasks | 3 completed |
| Files modified | 20 |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Commands relocated to commands/ | Pass | 8 files in flat commands/, old dirs deleted |
| AC-2: @src/ refs rewritten in commands | Pass | 0 @src/ refs remaining in commands/ |
| AC-3: @src/ refs rewritten in workflows | Pass | 103 refs rewritten across 12 workflows, 0 remaining in src/ |
| AC-4: allowed-tools added to all commands | Pass | 8/8 commands have allowed-tools frontmatter |
| AC-5: Install mapping is clean | Pass | commands/ → ~/.claude/commands/aegis/, src/ → ~/.claude/aegis/ |

## Accomplishments

- Restructured repo: commands separated from framework files into flat `commands/` directory
- Rewrote 103+ `@src/` references across 20 files to `@~/.claude/aegis/` install paths
- Added `allowed-tools` to all 8 commands with role-appropriate tool sets (read-only for status, full toolset for audit/transform)

## Files Created/Modified

| File | Change | Purpose |
|------|--------|---------|
| `commands/audit.md` | Moved + modified | Core entry point — added allowed-tools, rewritten refs |
| `commands/resume.md` | Moved + modified | Resume command — added allowed-tools, rewritten refs |
| `commands/status.md` | Moved + modified | Read-only status — added allowed-tools: [Read, Glob, Grep] |
| `commands/report.md` | Moved + modified | Report generation — added allowed-tools, rewritten refs |
| `commands/transform.md` | Moved + modified | Transform pipeline entry — added allowed-tools, rewritten refs |
| `commands/remediate.md` | Moved + modified | Remediation command — added allowed-tools, rewritten refs |
| `commands/playbook.md` | Moved + modified | Playbook generation — added allowed-tools, rewritten refs |
| `commands/guardrails.md` | Moved + modified | Guardrail generation — added allowed-tools, rewritten refs |
| `src/core/workflows/*.md` | Modified (8 files) | Rewritten @src/ → @~/.claude/aegis/ (73 refs) |
| `src/transform/workflows/*.md` | Modified (4 files) | Rewritten @src/ → @~/.claude/aegis/ (30 refs) |
| `README.md` | Modified | Updated commands location, added v0.2 section |

## Decisions Made

| Decision | Rationale | Impact |
|----------|-----------|--------|
| Flat commands/ at repo root | Mirrors PAUL pattern (~/.claude/commands/paul/ is flat) | Install script can simple-copy commands/ → ~/.claude/commands/aegis/ |
| allowed-tools per command role | Status is read-only (3 tools), audit/transform need full toolset (8 tools) | Commands declare their own permissions |
| README v0.2 section added | Documents install structure and phase progress | Users can see what's coming |

## Deviations from Plan

### Summary

| Type | Count | Impact |
|------|-------|--------|
| Scope additions | 1 | README update (user-requested, not in original plan) |

**Total impact:** Minor scope addition, no plan changes needed.

### Scope Addition

**1. README update**
- **Found during:** Post-APPLY, user requested
- **Change:** Updated commands location in v0.1 table, added v0.2 section with install directory structure
- **Files:** README.md

## Issues Encountered

None.

## Next Phase Readiness

**Ready:**
- All files reference `@~/.claude/aegis/` paths — ready for install script to copy
- Clean two-directory mapping established for Phase 10
- Commands have allowed-tools — ready for Claude Code installation

**Concerns:**
- None

**Blockers:**
- None

---
*Phase: 09-command-conversion, Plan: 01*
*Completed: 2026-02-19*
