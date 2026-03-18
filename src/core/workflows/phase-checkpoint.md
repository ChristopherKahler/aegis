<purpose>
Provides a structured checkpoint between AEGIS audit phases — displaying phase completion summary, cumulative progress, and offering the user a clear continue/pause/abort decision point. Invoked by the audit command after each phase workflow completes.
</purpose>

<phase_context>
Phase: Utility — invoked between every phase transition during Core audit execution (0→1, 1→2, 2→3, 3→4, 4→5)
Prior phase output: Completed phase findings, signals, and updated .aegis/STATE.md
Agents invoked: None — this workflow presents information and captures user intent
Output: Updated .aegis/STATE.md with checkpoint record, user decision (continue/pause/abort)
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
</required_input>

<process>

<step name="capture_phase_completion" priority="first">
1. Read .aegis/STATE.md to identify which phase just completed.
2. Extract from STATE.md:
   - completed_phase: the phase number (0-5) that just finished
   - phase_status: confirm it is "complete"
   - agents_completed: list of agents that ran in this phase
   - findings_produced: count of findings from this phase
   - disagreements_produced: count of disagreements from this phase (if any)
3. Count actual finding files in .aegis/findings/ for this phase:
   - Cross-reference agent IDs from completed phase against finding files
   - Tally by severity: critical, high, medium, low, info
4. Record phase completion timestamp in .aegis/STATE.md if not already set.
5. Increment session tracking counters in .aegis/STATE.md:
   - Increment Sessions count
   - Update Last session timestamp
   - Set Started timestamp if this is the first checkpoint
</step>

<step name="display_phase_summary" priority="blocking">
Display the completed phase summary:

```
════════════════════════════════════════
PHASE [N] COMPLETE — [Phase Name]
════════════════════════════════════════

Agents completed: [count] ([agent-id list])
Findings produced: [count]
  Critical: [N]  High: [N]  Medium: [N]  Low: [N]
Disagreements: [N] detected

────────────────────────────────────────
CUMULATIVE PROGRESS
────────────────────────────────────────

[██████████░░░░░░░░░░] Phase [N] of 5 complete

| Phase | Name                       | Status   | Findings |
|-------|----------------------------|----------|----------|
|   0   | Context & Threat Modeling  | complete | -        |
|   1   | Signal Gathering           | complete | -        |
|   2   | Deep Domain Audits         | [status] | [count]  |
|   3   | Cross-Domain Synthesis     | [status] | [count]  |
|   4   | Adversarial Review         | [status] | [count]  |
|   5   | Synthesis & Report         | [status] | -        |

Total findings so far: [N]
Total disagreements: [N] (resolved: [N])
Sessions used: [N]
════════════════════════════════════════
```

Phase names reference:
- Phase 0: Context & Threat Modeling
- Phase 1: Automated Signal Gathering
- Phase 2: Deep Domain Audits
- Phase 3: Change Risk & Reality Gap
- Phase 4: Adversarial Review
- Phase 5: Synthesis & Report
</step>

<step name="preview_next_phase" priority="blocking">
If completed_phase < 5 (more phases remain):

1. Determine next phase number: completed_phase + 1
2. Look up next phase details:

   | Phase | Agents | Estimated Sessions | Description |
   |-------|--------|--------------------|-------------|
   | 1     | (tools) | 1 session        | Automated tool scanning — SonarQube, Semgrep, Trivy, etc. |
   | 2     | 8      | 1-8 sessions      | Domain specialist agents analyze findings in parallel |
   | 3     | 2      | 1-2 sessions      | Staff Engineer + Reality Gap Analyst (sequential) |
   | 4     | 1      | 1 session          | Devil's Advocate challenges all findings |
   | 5     | 1      | 1 session          | Principal Engineer synthesizes final report |

3. Display preview:
   ```
   ────────────────────────────────────────
   NEXT: Phase [N] — [Name]
   ────────────────────────────────────────

   [Description]
   Agents: [count or "tools"]
   Estimated sessions: [range]
   Prerequisites: Phase [N-1] complete ✓
   ────────────────────────────────────────
   ```

If completed_phase == 5 (Core audit complete):
   ```
   ────────────────────────────────────────
   CORE AUDIT COMPLETE
   ────────────────────────────────────────

   All 6 diagnostic phases finished.
   Total findings: [N]
   Disagreements resolved: [N] of [N]

   Next steps:
   - /aegis:report — generate the final audit report
   - /aegis:transform — start the remediation pipeline
   ────────────────────────────────────────
   ```
</step>

<step name="offer_checkpoint_options" priority="blocking">
If completed_phase < 5 (more phases remain):

Present exactly 3 options:
```
[1] Continue to Phase [N+1] (recommended)
[2] Pause here — safe to close this session
[3] Abort audit — preserves all work completed so far
```

Handle each response:

**If [1] "continue":**
- Update .aegis/STATE.md Resume Info:
  - Last action: "Phase [N] checkpoint — user chose continue"
  - Next action: "Phase [N+1] — [Name]"
- Return control to the audit command's phase loop to invoke the next phase workflow

**If [2] "pause":**
- Update .aegis/STATE.md:
  - Overall status: paused
  - Resume Info:
    - Last action: "Phase [N] checkpoint — user chose pause"
    - Next action: "Resume with /aegis:resume to start Phase [N+1]"
- Display:
  ```
  ════════════════════════════════════════
  AUDIT PAUSED
  ════════════════════════════════════════

  All progress saved to .aegis/STATE.md.
  [N] findings preserved across [N] phases.

  To continue later:
    /aegis:resume

  To check status anytime:
    /aegis:status
  ════════════════════════════════════════
  ```
- Stop execution (do not proceed to next phase)

**If [3] "abort":**
- Update .aegis/STATE.md:
  - Overall status: paused
  - Resume Info:
    - Last action: "Phase [N] checkpoint — user chose abort"
    - Next action: "Resume with /aegis:resume or start fresh with /aegis:audit"
- Display:
  ```
  ════════════════════════════════════════
  AUDIT STOPPED
  ════════════════════════════════════════

  All findings preserved. Nothing was deleted.
  Completed phases: 0 through [N]
  Findings: [count] total

  To resume later:  /aegis:resume
  To start fresh:   /aegis:audit (will offer to archive existing state)
  ════════════════════════════════════════
  ```
- Stop execution

If completed_phase == 5 (Core audit complete):
- No continue/pause/abort — just display completion info and suggest next steps
- Update .aegis/STATE.md: overall status to "complete"
</step>

<step name="update_state" priority="required">
Regardless of user choice, update .aegis/STATE.md:

1. Add to Checkpoint History section:
   ```markdown
   - Phase [N] ([Name]) — [timestamp] — [continue/pause/abort]
   ```

2. Update Session Tracking:
   - Increment Sessions count
   - Update Last session to current timestamp

3. Update phase completion timestamp in the Phases table if not already set.
</step>

</process>

<output>
- .aegis/STATE.md updated with checkpoint record, session tracking, and user decision
- User informed of progress and given clear next-step guidance
- If "continue": control returns to audit command for next phase
- If "pause" or "abort": execution stops cleanly with resume instructions
</output>

<error_handling>
- **STATE.md missing or unreadable:** Display error "Cannot read .aegis/STATE.md — audit state may be corrupted. Run /aegis:status to diagnose." Do not proceed.
- **Phase not actually complete:** If STATE.md shows phase still active (agents remaining), do not display checkpoint. Warn: "Phase [N] has [X] agents remaining. Complete the phase before checkpointing."
- **Session Tracking section missing:** If STATE.md was created before Phase 12 updates (no Session Tracking section), add it now with Sessions: 1, Last session: current timestamp, Started: current timestamp.
- **Checkpoint History section missing:** If missing, create it with the current checkpoint as the first entry.
</error_handling>
