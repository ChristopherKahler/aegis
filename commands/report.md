---
name: aegis:report
description: Generate or view the AEGIS diagnostic audit report
argument-hint: "[section]"
allowed-tools: [Read, Write, Glob, Grep]
---

<objective>
Generates, regenerates, or displays the final AEGIS diagnostic report from a completed Core audit. Verifies that all Core phases (0-5) are complete before allowing report generation, and delegates to the Phase 5 report workflow for actual generation.

If the report already exists, offers options to view specific sections or regenerate.

Produces: report files in .aegis/report/ (executive-summary.md, findings-by-domain.md, disagreements.md, remediation-roadmap.md).
</objective>

<execution_context>
@~/.claude/aegis/core/workflows/phase-5-report.md
</execution_context>

<context>
$ARGUMENTS
@.aegis/STATE.md
@.aegis/report/
</context>

<process>

## Step 1: Check Prerequisites

Check if .aegis/STATE.md exists:

- If NO:
  ```
  ════════════════════════════════════════
  NO ACTIVE AUDIT
  ════════════════════════════════════════

  No .aegis/ directory found. Start an audit first with /aegis:audit.

  [1] Start new audit → runs /aegis:audit
  [2] Cancel
  ════════════════════════════════════════
  ```
  Route based on selection.

- If YES: read STATE.md and check phase completion

## Step 2: Verify Phase Completion

Read .aegis/STATE.md phase progress. Check if Phases 0-4 are all complete. Phase 5 (Report) is the phase this command triggers, so it does not need to be complete as a prerequisite.

If any prerequisite phase (0-4) is incomplete:
```
════════════════════════════════════════
AUDIT INCOMPLETE
════════════════════════════════════════

Report generation requires all prerequisite Core phases (0-4) to be complete.

Current progress:
  Phase 0 (Context): [status]
  Phase 1 (Signals): [status]
  Phase 2 (Domain Audits): [status]
  Phase 3 (Cross-Domain): [status]
  Phase 4 (Adversarial Review): [status]
  Phase 5 (Report): [status]

Incomplete phases: [list]

[1] Resume audit to complete remaining phases → runs /aegis:resume
[2] Cancel
════════════════════════════════════════
```

If all phases 0-4 complete: proceed to Step 3

## Step 3: Check Existing Report

Check if .aegis/report/ directory exists and contains report files:

- If report exists:
  ```
  ════════════════════════════════════════
  EXISTING REPORT FOUND
  ════════════════════════════════════════

  Report generated: [timestamp from file modification]
  Sections:
    - executive-summary.md [exists/missing]
    - findings-by-domain.md [exists/missing]
    - disagreements.md [exists/missing]
    - remediation-roadmap.md [exists/missing]

  [1] View report (display in terminal)
  [2] View specific section
  [3] Regenerate report (overwrites existing)
  [4] Cancel
  ════════════════════════════════════════
  ```

  If [1]: display all report sections in sequence
  If [2]: present section selector:
    ```
    Select section:
    [1] Executive Summary
    [2] Findings by Domain
    [3] Disagreements
    [4] Remediation Roadmap
    [5] Back
    ```
    Display the selected section.
  If [3]: proceed to Step 4 (regeneration)
  If [4]: exit

- If no report exists: proceed to Step 4

## Step 4: Generate Report

If $ARGUMENTS contains a section name (e.g., "executive-summary"), generate only that section. Otherwise generate all sections.

```
════════════════════════════════════════
REPORT GENERATION
════════════════════════════════════════

Scope: [Full report / Single section]
Findings to synthesize: [total count across all phases]
Disagreements to resolve: [count] (open: [count])
Domains covered: [count] of 14

[1] Generate report (recommended)
[2] Cancel
════════════════════════════════════════
```

If [1]: delegate to phase-5-report workflow for generation
If [2]: exit

## Step 5: Report Complete

After generation completes:
```
════════════════════════════════════════
REPORT GENERATED
════════════════════════════════════════

Location: .aegis/report/

Files:
  - executive-summary.md
  - findings-by-domain.md
  - disagreements.md
  - remediation-roadmap.md

Next steps:
  - Review the report in .aegis/report/
  - Run /aegis:transform to generate remediation plans (Layer B)
  - Archive the audit when satisfied

════════════════════════════════════════
```

</process>

<success_criteria>
- [ ] Prerequisites validated (active audit, phases complete)
- [ ] Existing report detected and options presented (view/regenerate)
- [ ] Phase 5 workflow delegated to for report generation
- [ ] Report files created in .aegis/report/
- [ ] Next steps clearly communicated (Transform pipeline, archival)
- [ ] Cancellation available at every decision point
</success_criteria>
