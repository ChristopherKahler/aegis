---
name: aegis:transform
description: Initiate the full AEGIS Transform pipeline on a completed audit
---

<objective>
Initiates the full AEGIS Transform pipeline (Phases 6-8) on a completed Core audit. Guides the user through scope selection, displays intervention level distribution and confidence information, and requires explicit confirmation before producing any Transform output.

This is the master entry point for all Transform operations. For targeted operations, use /aegis:remediate, /aegis:playbook, or /aegis:guardrails instead.

Produces: Layer B remediation knowledge (playbooks, patterns, guardrails) and Layer C execution plans (change graph, risk scores, PAUL project).
</objective>

<execution_context>
@src/transform/workflows/phase-6-remediation.md
@src/transform/workflows/phase-7-risk-validation.md
@src/transform/workflows/phase-8-execution-planning.md
@src/transform/workflows/transform-safety.md
</execution_context>

<context>
@.aegis/STATE.md
@.aegis/report/
@.aegis/findings/
</context>

<process>

## Step 1: Check Prerequisites

Check if .aegis/report/ exists with completed Core audit:

- If .aegis/ does not exist:
  ```
  ════════════════════════════════════════
  NO ACTIVE AUDIT
  ════════════════════════════════════════

  No .aegis/ directory found. A completed Core audit is required
  before Transform can run.

  [1] Start new audit → runs /aegis:audit
  [2] Cancel
  ════════════════════════════════════════
  ```

- If .aegis/ exists but .aegis/report/ is missing or incomplete:
  ```
  ════════════════════════════════════════
  CORE AUDIT INCOMPLETE
  ════════════════════════════════════════

  Transform requires a completed Layer A record (all Core phases 0-5).

  Current progress:
    Phase 0 (Context): [status]
    Phase 1 (Signals): [status]
    Phase 2 (Domain Audits): [status]
    Phase 3 (Cross-Domain): [status]
    Phase 4 (Adversarial Review): [status]
    Phase 5 (Report): [status]

  [1] Resume audit to complete remaining phases → runs /aegis:resume
  [2] Cancel
  ════════════════════════════════════════
  ```

- If Layer A complete: proceed to Step 2

## Step 2: Analyze Transform Scope

Read all findings from .aegis/findings/ and compute:
- Total finding count across all domains
- Finding distribution by severity (critical/high/medium/low/info)
- Confidence distribution across findings
- Estimated playbook count
- Maximum intervention level available (based on confidence distribution)

Display:
```
════════════════════════════════════════
AEGIS TRANSFORM — PIPELINE OVERVIEW
════════════════════════════════════════

Core Audit: Complete
Findings: [N] across [M] domains

Severity distribution:
  Critical: [N]  High: [N]  Medium: [N]  Low: [N]  Info: [N]

Confidence distribution:
  High (4-5): [N] findings
  Medium (3): [N] findings
  Low (1-2): [N] findings

Estimated playbook count: ~[N]
Maximum intervention level: [Suggesting / Planning / Authorizing]
════════════════════════════════════════
```

## Step 3: Select Transform Scope

```
════════════════════════════════════════
TRANSFORM SCOPE
════════════════════════════════════════

[1] Full Transform — all findings, all phases (6-8) (recommended)
[2] Selective — choose specific domains or severity levels
[3] Playbooks only — Phase 6 only (remediation knowledge, no risk scoring or execution planning)
[4] Cancel
════════════════════════════════════════
```

If [2] (Selective) selected, present filter options:
```
Filter by:

[1] Domain — select specific domains to remediate
[2] Severity — minimum severity threshold (e.g., high and above)
[3] Back
```

If domain filter: present domain checklist with finding counts per domain.
If severity filter: present threshold selector (critical only / high+ / medium+ / all).

## Step 4: Safety Confirmation

Display intervention level information and require explicit confirmation:
```
════════════════════════════════════════
SAFETY REVIEW
════════════════════════════════════════

Transform will produce remediation at these intervention levels:

  Suggesting:  [N] findings — advisory only, no changes proposed
  Planning:    [N] findings — specific changes proposed, human review required
  Authorizing: [N] findings — changes ready for execution with approval

Confidence summary:
  [N] findings have high confidence (reliable remediation)
  [N] findings have medium confidence (review recommended)
  [N] findings have low confidence (will be capped at Suggesting level)

IMPORTANT: AEGIS Transform produces plans only. No changes will
be applied to your codebase without explicit execution through PAUL.

[1] Confirm — proceed with Transform (recommended)
[2] Modify scope
[3] Cancel
════════════════════════════════════════
```

If [1]: proceed to Step 5
If [2]: return to Step 3
If [3]: exit

## Step 5: Execute Transform Pipeline

1. Update .aegis/STATE.md with Transform initiation
2. Delegate to phase-6-remediation workflow (Layer B: playbooks + patterns)
3. After Phase 6 completes:
   - If scope includes Phases 7-8: delegate to phase-7-risk-validation workflow
   - If playbooks-only scope: skip to Step 6
4. After Phase 7 completes: delegate to phase-8-execution-planning workflow (Layer C)
5. Transform safety workflow is invoked automatically by each phase workflow at safety checkpoints

## Step 6: Transform Complete

```
════════════════════════════════════════
TRANSFORM COMPLETE
════════════════════════════════════════

Layer B — Remediation Knowledge:
  Playbooks: [N] in .aegis/remediation/playbooks/
  Patterns: [N] in .aegis/remediation/patterns/
  Guardrails: .aegis/remediation/guardrails/

Layer C — Execution Planning:
  Change graph: .aegis/execution/change-graph.yaml
  Risk scores: .aegis/execution/risk-scores.yaml
  PAUL project: .aegis/execution/paul-project/

Next steps:
  - Review playbooks in .aegis/remediation/playbooks/
  - Review guardrails in .aegis/remediation/guardrails/
  - Execute remediation via PAUL using .aegis/execution/paul-project/

════════════════════════════════════════
```

</process>

<success_criteria>
- [ ] Layer A prerequisite validated (Core audit complete)
- [ ] Transform scope selected and confirmed by user
- [ ] Intervention levels and confidence displayed before any output
- [ ] Explicit user confirmation obtained before Transform proceeds
- [ ] Transform workflows delegated to in correct sequence (6 → 7 → 8)
- [ ] Transform output locations clearly communicated
- [ ] Cancellation available at every decision point
</success_criteria>
