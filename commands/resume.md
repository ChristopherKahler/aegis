---
name: aegis:resume
description: Resume an interrupted AEGIS diagnostic audit
argument-hint: "[phase-number]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion]
---

<objective>
Resumes an interrupted AEGIS diagnostic audit from the last checkpoint or a specified phase. Reads .aegis/STATE.md to determine current position, displays progress, and routes to the appropriate phase workflow.

If no active audit exists, routes to /aegis:audit to start a new one.

Produces: continued audit execution from the resume point, updated .aegis/STATE.md.
</objective>

<execution_context>
@~/.claude/aegis/core/workflows/phase-0-context.md
@~/.claude/aegis/core/workflows/phase-1-reconnaissance.md
@~/.claude/aegis/core/workflows/phase-2-domain-audits.md
@~/.claude/aegis/core/workflows/phase-3-cross-domain.md
@~/.claude/aegis/core/workflows/phase-4-adversarial-review.md
@~/.claude/aegis/core/workflows/phase-5-report.md
@~/.claude/aegis/core/workflows/phase-checkpoint.md
</execution_context>

<context>
$ARGUMENTS
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

  No .aegis/ directory found. Start a new audit with /aegis:audit.

  [1] Start new audit → runs /aegis:audit
  [2] Cancel
  ════════════════════════════════════════
  ```
  Route based on selection.

- If YES: proceed to Step 2

## Step 2: Read Audit State

Read .aegis/STATE.md and extract:
- Target repository
- Audit start time
- Current phase (0-5)
- Overall status (in_progress / paused / complete)
- Per-phase status (pending / active / complete)
- Finding counts per phase
- Last action and next action from Resume Info
- Any unresolved disagreements
- Session tracking data:
  - Sessions: total session count so far
  - Last session: timestamp of last activity
  - Started: when the audit began
- Checkpoint History: list of phase completions with timestamps and decisions

If status is "complete":
```
════════════════════════════════════════
AUDIT COMPLETE
════════════════════════════════════════

This audit has already completed all phases.

[1] View status → runs /aegis:status
[2] Generate report → runs /aegis:report
[3] Start Transform pipeline → runs /aegis:transform
[4] Start fresh audit (WARNING: deletes current state) → runs /aegis:audit
[5] Cancel
════════════════════════════════════════
```

## Step 3: Display Progress

```
════════════════════════════════════════
AEGIS AUDIT — RESUME
════════════════════════════════════════

Target: [repository path]
Started: [timestamp]
Status: [in_progress / paused]
Session: [N] (last active: [relative time — e.g., "2 hours ago", "yesterday", "3 days ago"])

Phase Progress:
┌───────┬──────────────────────────────┬──────────┬──────────┬──────────┐
│ Phase │ Name                         │ Status   │ Agents   │ Findings │
├───────┼──────────────────────────────┼──────────┼──────────┼──────────┤
│   0   │ Context & Threat Modeling    │ complete │ 1        │ -        │
│   1   │ Automated Signal Gathering   │ complete │ (tools)  │ -        │
│   2   │ Deep Domain Audits           │ active   │ 6 of 8   │ 23       │
│   3   │ Cross-Domain Synthesis       │ pending  │ -        │ -        │
│   4   │ Adversarial Review           │ pending  │ -        │ -        │
│   5   │ Synthesis & Report           │ pending  │ -        │ -        │
└───────┴──────────────────────────────┴──────────┴──────────┴──────────┘

Cumulative: [N] findings (critical: [N], high: [N], medium: [N], low: [N])
Disagreements: [N] detected, [N] resolved

Checkpoint History:
- Phase 0 (Context & Threat Modeling) — [timestamp]
- Phase 1 (Signal Gathering) — [timestamp]
  [... one line per completed phase checkpoint]

Last action: [from STATE.md Resume Info]
Next action: [from STATE.md Resume Info]

════════════════════════════════════════
```

Note: Compute relative time from Last session timestamp (e.g., if last session was 2 hours ago, display "2 hours ago"). If Session Tracking section is missing from STATE.md (pre-Phase 12 audits), display "Session: 1 (no tracking data)" and omit Checkpoint History.

## Step 4: Present Resume Options

Check if $ARGUMENTS contains a phase number:
- If YES: validate the phase number (0-5), skip to delegation with that phase
- If NO: present options

```
[1] Resume from last checkpoint (recommended) — continues Phase [N+1] without re-reading completed phases
[2] Re-run Phase [N] — [last completed phase] (re-executes from scratch)
[3] Jump to Phase [N] — [specify phase number]
[4] Start fresh (WARNING: deletes .aegis/ and all findings)
[5] Cancel
```

If [1]: determine the correct resume point from STATE.md:
  - If a phase is "active" with partial completion: resume that phase at the next unfinished agent
  - If the last phase is "complete": start the next pending phase

If [2]: confirm re-run (warns that existing phase output will be overwritten), then delegate

If [3]: validate phase number, warn if skipping phases (findings may be incomplete), then delegate

If [4]: require explicit confirmation ("type DELETE to confirm"), then delegate to /aegis:audit

If [5]: exit

## Step 5: Delegate to Phase Workflow

Based on the selected resume point:
1. Update .aegis/STATE.md:
   - Resume Info: last action and next action
   - Session Tracking: increment Sessions count, update Last session timestamp
   - Overall status: in_progress (if was paused)
2. Delegate to the appropriate phase workflow (context loading is handled by the phase workflow and session-handoff — do NOT re-read completed phase outputs at the resume command level):
   - Phase 0 → phase-0-context workflow
   - Phase 1 → phase-1-reconnaissance workflow
   - Phase 2 → phase-2-domain-audits workflow
   - Phase 3 → phase-3-cross-domain workflow
   - Phase 4 → phase-4-adversarial-review workflow
   - Phase 5 → phase-5-report workflow

</process>

<success_criteria>
- [ ] .aegis/STATE.md read and current position identified
- [ ] Phase progress displayed clearly to user
- [ ] Resume point selected (automatic or user-chosen)
- [ ] Correct phase workflow delegated to
- [ ] .aegis/STATE.md updated with resume action
- [ ] Cancellation available at every decision point
</success_criteria>
