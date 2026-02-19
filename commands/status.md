---
name: aegis:status
description: Display current AEGIS audit state and progress
allowed-tools: [Read, Glob, Grep]
---

<objective>
Displays the current state of an AEGIS diagnostic audit without modifying anything. Shows phase-by-phase progress, finding counts, disagreement status, and suggests the next action.

This is a read-only command — it never modifies .aegis/ state or audit artifacts.

If no active audit exists, reports that and suggests /aegis:audit.
</objective>

<execution_context>
<!-- Read-only command: no workflow delegation required -->
</execution_context>

<context>
@.aegis/STATE.md
</context>

<process>

## Step 1: Check for Active Audit

Check if .aegis/STATE.md exists:

- If NO:
  ```
  ════════════════════════════════════════
  NO ACTIVE AUDIT
  ════════════════════════════════════════

  No .aegis/ directory found in the current repository.

  To start an audit, run: /aegis:audit
  ════════════════════════════════════════
  ```
  Exit.

- If YES: proceed to Step 2

## Step 2: Read Audit State

Read .aegis/STATE.md and extract all fields:
- Audit info: target, started, current phase, status
- Phase progress: per-phase status, agents, finding counts, timestamps
- Summary: total findings, disagreements (open/resolved), domains covered
- Resume info: last action, next action

Also check the filesystem for additional context:
- Count files in .aegis/findings/*/ for actual finding counts
- Count files in .aegis/signals/*/ for signal counts
- Check .aegis/report/ existence for report status
- Check .aegis/review/ existence for adversarial review status

## Step 3: Display Full Status

```
════════════════════════════════════════
AEGIS AUDIT STATUS
════════════════════════════════════════

Target: [repository path]
Started: [timestamp]
Status: [in_progress / paused / complete]
AEGIS Version: [from MANIFEST.md]

────────────────────────────────────────
PHASE PROGRESS
────────────────────────────────────────

┌───────┬──────────────────────────────┬──────────┬──────────┬──────────┬───────────┐
│ Phase │ Name                         │ Status   │ Agents   │ Findings │ Completed │
├───────┼──────────────────────────────┼──────────┼──────────┼──────────┼───────────┤
│   0   │ Context & Threat Modeling    │ [status] │ [count]  │ -        │ [time]    │
│   1   │ Automated Signal Gathering   │ [status] │ (tools)  │ -        │ [time]    │
│   2   │ Deep Domain Audits           │ [status] │ [n of m] │ [count]  │ [time]    │
│   3   │ Cross-Domain Synthesis       │ [status] │ [n of m] │ [count]  │ [time]    │
│   4   │ Adversarial Review           │ [status] │ [count]  │ [count]  │ [time]    │
│   5   │ Synthesis & Report           │ [status] │ [count]  │ -        │ [time]    │
└───────┴──────────────────────────────┴──────────┴──────────┴──────────┴───────────┘

────────────────────────────────────────
SUMMARY
────────────────────────────────────────

Total findings: [N]
  - Critical: [N]  High: [N]  Medium: [N]  Low: [N]  Info: [N]
Disagreements: [N] total (open: [N], resolved: [N])
Domains covered: [N] of 14

────────────────────────────────────────
```

## Step 4: Suggest Next Action

Based on the current state, suggest exactly one next action:

| State | Suggestion |
|-------|------------|
| All phases complete, no report | "Run /aegis:report to generate the final audit report." |
| All phases complete, report exists | "Core audit complete. Run /aegis:transform to start the remediation pipeline." |
| A phase is active (in progress) | "Resume with /aegis:resume to continue Phase [N]." |
| A phase is pending (next in sequence) | "Resume with /aegis:resume to start Phase [N]." |
| Audit paused | "Resume with /aegis:resume to continue from [last action]." |

```
────────────────────────────────────────
NEXT ACTION
────────────────────────────────────────

▶ [suggested command and description]

════════════════════════════════════════
```

</process>

<success_criteria>
- [ ] .aegis/STATE.md read successfully
- [ ] Phase progress displayed with accurate counts
- [ ] Finding summary displayed with severity breakdown
- [ ] Disagreement status displayed
- [ ] Exactly one next action suggested based on current state
- [ ] No state files modified (read-only command)
</success_criteria>
