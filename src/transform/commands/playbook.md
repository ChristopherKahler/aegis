---
name: aegis:playbook
description: Generate a remediation playbook for a specific finding
argument-hint: "<finding-id>"
---

<objective>
Generates a remediation playbook for a single specific finding. This is the most targeted Transform operation — produces both human-readable (.md) and machine-consumable (.yaml) playbook files for one finding.

If the playbook already exists, offers options to view or regenerate.

Produces: .aegis/remediation/playbooks/{finding-id}.md and .aegis/remediation/playbooks/{finding-id}.yaml.
</objective>

<execution_context>
@src/transform/workflows/phase-6-remediation.md
@src/transform/workflows/transform-safety.md
</execution_context>

<context>
$ARGUMENTS
@.aegis/STATE.md
@.aegis/findings/
@.aegis/remediation/playbooks/
</context>

<process>

## Step 1: Check Prerequisites

Check if .aegis/report/ exists with completed Core audit:

- If Layer A incomplete:
  ```
  ════════════════════════════════════════
  CORE AUDIT INCOMPLETE
  ════════════════════════════════════════

  Playbook generation requires a completed Layer A record.

  [1] Resume audit → runs /aegis:resume
  [2] Cancel
  ════════════════════════════════════════
  ```

- If Layer A complete: proceed to Step 2

## Step 2: Validate Finding ID

Check $ARGUMENTS for a finding ID:

- If no finding ID provided:
  ```
  ════════════════════════════════════════
  FINDING ID REQUIRED
  ════════════════════════════════════════

  Usage: /aegis:playbook <finding-id>

  Example: /aegis:playbook F-04-001

  To see all findings, run /aegis:status.

  [1] List all finding IDs
  [2] Cancel
  ════════════════════════════════════════
  ```

  If [1]: list all finding IDs with severity and domain, then prompt for selection.

- If finding ID provided: validate it exists in .aegis/findings/
  - Search across all agent directories: .aegis/findings/*/{finding-id}*
  - If not found: report error with suggestions (list similar IDs)

## Step 3: Display Finding Context

```
════════════════════════════════════════
FINDING DETAILS
════════════════════════════════════════

Finding: [finding-id]
Domain: [domain name]
Severity: [severity]
Agent: [agent that produced it]
Confidence: [overall confidence score]

Summary: [first line or title of finding]
════════════════════════════════════════
```

## Step 4: Check Existing Playbook

Check if .aegis/remediation/playbooks/{finding-id}.md exists:

- If playbook exists:
  ```
  ════════════════════════════════════════
  EXISTING PLAYBOOK FOUND
  ════════════════════════════════════════

  Playbook: .aegis/remediation/playbooks/[finding-id].md
  YAML: .aegis/remediation/playbooks/[finding-id].yaml

  [1] View playbook
  [2] Regenerate (overwrites existing)
  [3] Cancel
  ════════════════════════════════════════
  ```

- If no playbook exists: proceed to Step 5

## Step 5: Safety Confirmation

```
════════════════════════════════════════
SAFETY REVIEW
════════════════════════════════════════

Finding: [finding-id]
Confidence: [score] → Intervention level: [Suggesting / Planning / Authorizing]

Playbook will contain:
  - Root cause analysis
  - Remediation strategy (4-layer: abstract → framework → language → project)
  - Before/after examples
  - Educational context
  - Verification steps

No changes will be applied to your codebase.

[1] Generate playbook (recommended)
[2] Cancel
════════════════════════════════════════
```

## Step 6: Generate Playbook

1. Delegate to phase-6-remediation workflow scoped to single finding
2. Transform safety validation runs automatically during generation

## Step 7: Playbook Complete

```
════════════════════════════════════════
PLAYBOOK GENERATED
════════════════════════════════════════

Human-readable: .aegis/remediation/playbooks/[finding-id].md
Machine-consumable: .aegis/remediation/playbooks/[finding-id].yaml

Intervention level: [level]

Next steps:
  - Review the playbook
  - Generate more playbooks: /aegis:playbook <finding-id>
  - Generate all playbooks: /aegis:remediate
  - Generate guardrails: /aegis:guardrails

════════════════════════════════════════
```

</process>

<success_criteria>
- [ ] Layer A prerequisite validated
- [ ] Finding ID validated (exists in .aegis/findings/)
- [ ] Finding context displayed (domain, severity, confidence)
- [ ] Existing playbook detected and options presented
- [ ] Intervention level displayed before generation
- [ ] Explicit confirmation obtained
- [ ] Phase 6 workflow delegated to (scoped to single finding)
- [ ] Both .md and .yaml playbook locations communicated
- [ ] Cancellation available at every decision point
</success_criteria>
