---
name: aegis:remediate
description: Generate remediation plans for all findings or a specific domain
argument-hint: "[domain-number]"
---

<objective>
Generates remediation knowledge (Layer B) from diagnostic findings, optionally scoped to a specific domain. Can continue through the full Transform pipeline (Phases 6-8) or stop after playbook generation.

If remediation already exists, offers options to view, extend, or regenerate.

Produces: playbooks in .aegis/remediation/playbooks/, patterns in .aegis/remediation/patterns/, and optionally risk scores and execution plans.
</objective>

<execution_context>
@src/transform/workflows/phase-6-remediation.md
@src/transform/workflows/phase-7-risk-validation.md
@src/transform/workflows/phase-8-execution-planning.md
@src/transform/workflows/transform-safety.md
</execution_context>

<context>
$ARGUMENTS
@.aegis/STATE.md
@.aegis/report/
@.aegis/findings/
@.aegis/remediation/
</context>

<process>

## Step 1: Check Prerequisites

Check if .aegis/report/ exists with completed Core audit:

- If Layer A incomplete:
  ```
  ════════════════════════════════════════
  CORE AUDIT INCOMPLETE
  ════════════════════════════════════════

  Remediation requires a completed Layer A record (all Core phases 0-5).

  [1] Resume audit → runs /aegis:resume
  [2] Cancel
  ════════════════════════════════════════
  ```

- If Layer A complete: proceed to Step 2

## Step 2: Determine Scope

Check $ARGUMENTS:
- If domain number provided: scope to that domain's findings only
  - Validate domain number (0-13)
  - Count findings for that domain
  - If no findings for domain: report and exit
- If no arguments: scope to all findings

Display scope:
```
════════════════════════════════════════
REMEDIATION SCOPE
════════════════════════════════════════

Scope: [All findings / Domain NN — {domain name}]
Findings in scope: [N]
Severity: Critical [N], High [N], Medium [N], Low [N], Info [N]
════════════════════════════════════════
```

## Step 3: Check Existing Remediation

Check if .aegis/remediation/ exists:

- If remediation exists:
  ```
  ════════════════════════════════════════
  EXISTING REMEDIATION FOUND
  ════════════════════════════════════════

  Playbooks: [N] in .aegis/remediation/playbooks/
  Patterns: [N] in .aegis/remediation/patterns/

  [1] View existing playbooks
  [2] Generate missing playbooks only (skip already-generated findings)
  [3] Regenerate all playbooks (overwrites existing)
  [4] Cancel
  ════════════════════════════════════════
  ```

- If no remediation exists: proceed to Step 4

## Step 4: Safety Confirmation

Display intervention level information:
```
════════════════════════════════════════
SAFETY REVIEW
════════════════════════════════════════

Remediation will produce playbooks at these intervention levels:

  Suggesting:  [N] findings — advisory remediation
  Planning:    [N] findings — specific change proposals
  Authorizing: [N] findings — execution-ready plans

Low-confidence findings ([N]) will be capped at Suggesting level.

IMPORTANT: No changes will be applied to your codebase.

[1] Confirm — generate remediation (recommended)
[2] Cancel
════════════════════════════════════════
```

## Step 5: Execute Remediation

1. Delegate to phase-6-remediation workflow (scoped to selected findings)
2. After Phase 6 completes, offer continuation:

```
════════════════════════════════════════
REMEDIATION GENERATED
════════════════════════════════════════

Playbooks: [N] created in .aegis/remediation/playbooks/
Patterns: [N] identified in .aegis/remediation/patterns/

Continue the pipeline?

[1] Continue to risk validation (Phase 7) + execution planning (Phase 8)
[2] Continue to risk validation only (Phase 7)
[3] Stop here — review playbooks first
[4] Cancel
════════════════════════════════════════
```

If [1]: delegate to phase-7-risk-validation, then phase-8-execution-planning
If [2]: delegate to phase-7-risk-validation only
If [3]: exit with playbook locations displayed
If [4]: exit

</process>

<success_criteria>
- [ ] Layer A prerequisite validated
- [ ] Scope correctly determined (all findings or domain-specific)
- [ ] Existing remediation detected and options presented
- [ ] Intervention levels displayed before any output
- [ ] Explicit confirmation obtained before proceeding
- [ ] Phase 6 workflow delegated to with correct scope
- [ ] Pipeline continuation options presented after Phase 6
- [ ] Cancellation available at every decision point
</success_criteria>
