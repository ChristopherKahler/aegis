---
name: aegis:guardrails
description: Generate project rules from audit findings for AI coding assistants
argument-hint: "[format]"
allowed-tools: [Read, Write, Glob, Grep, AskUserQuestion]
---

<objective>
Generates machine-enforceable project rules from audit findings and remediation knowledge. Produces rules formatted for AI coding assistants (CLAUDE.md, .cursorrules) that encode audit-derived best practices as persistent guardrails.

Requires both Layer A (diagnostic) and Layer B (remediation) to be complete — guardrails derive from remediation patterns, not raw findings.

Produces: rule files in .aegis/remediation/guardrails/ (claude-md-rules.md, cursorrules.md).
</objective>

<execution_context>
@~/.claude/aegis/transform/workflows/phase-7-risk-validation.md
@~/.claude/aegis/transform/workflows/transform-safety.md
</execution_context>

<context>
$ARGUMENTS
@.aegis/STATE.md
@.aegis/remediation/
@.aegis/remediation/guardrails/
</context>

<process>

## Step 1: Check Prerequisites

**Layer A check:** Verify .aegis/report/ exists (Core audit complete).

- If Layer A incomplete:
  ```
  ════════════════════════════════════════
  CORE AUDIT INCOMPLETE
  ════════════════════════════════════════

  Guardrail generation requires a completed Core audit.

  [1] Resume audit → runs /aegis:resume
  [2] Cancel
  ════════════════════════════════════════
  ```

**Layer B check:** Verify .aegis/remediation/playbooks/ exists (remediation knowledge generated).

- If Layer B incomplete:
  ```
  ════════════════════════════════════════
  REMEDIATION REQUIRED
  ════════════════════════════════════════

  Guardrails derive from remediation knowledge (Layer B).
  Remediation playbooks must be generated first.

  [1] Generate remediation first → runs /aegis:remediate
  [2] Cancel
  ════════════════════════════════════════
  ```

- If both layers complete: proceed to Step 2

## Step 2: Select Guardrail Format

Check $ARGUMENTS for format specification:
- If "claude" or "claude-md": pre-select Claude MD format
- If "cursor" or "cursorrules": pre-select Cursor rules format
- If no argument or unrecognized: present options

```
════════════════════════════════════════
GUARDRAIL FORMAT
════════════════════════════════════════

Select output format:

[1] Claude MD rules — for .claude/CLAUDE.md (recommended)
[2] Cursor rules — for .cursorrules
[3] Both formats
[4] Cancel
════════════════════════════════════════
```

## Step 3: Display Guardrail Scope

```
════════════════════════════════════════
GUARDRAIL SCOPE
════════════════════════════════════════

Source data:
  Playbooks: [N] remediation playbooks
  Patterns: [N] cross-cutting patterns identified
  Domains: [N] domains with findings

Guardrails will codify:
  - Architectural constraints from findings
  - Security rules from vulnerability patterns
  - Code quality standards from audit observations
  - Testing requirements from coverage gaps

Format: [selected format(s)]
════════════════════════════════════════
```

## Step 4: Safety Confirmation

```
════════════════════════════════════════
SAFETY REVIEW
════════════════════════════════════════

Guardrails will be generated at intervention level: Suggesting
(Guardrails are advisory rules — they suggest constraints but do not
enforce them. Enforcement depends on the AI assistant's behavior.)

Patterns being codified: [N] from [M] domains

No changes will be applied to your codebase. Guardrail files are
generated in .aegis/remediation/guardrails/ for your review before
copying to project root.

[1] Generate guardrails (recommended)
[2] Back to format selection
[3] Cancel
════════════════════════════════════════
```

## Step 5: Check Existing Guardrails

Check if .aegis/remediation/guardrails/ already contains files:

- If guardrails exist:
  ```
  ════════════════════════════════════════
  EXISTING GUARDRAILS FOUND
  ════════════════════════════════════════

  claude-md-rules.md: [exists / not found]
  cursorrules.md: [exists / not found]

  [1] View existing guardrails
  [2] Regenerate (overwrites existing)
  [3] Back to format selection
  [4] Cancel
  ════════════════════════════════════════
  ```

- If no guardrails exist: proceed to Step 6

## Step 6: Generate Guardrails

1. Delegate to phase-7-risk-validation workflow (guardrail-generator portion)
2. Transform safety validation runs automatically

## Step 7: Guardrails Complete

```
════════════════════════════════════════
GUARDRAILS GENERATED
════════════════════════════════════════

Generated files:
  - .aegis/remediation/guardrails/claude-md-rules.md
  - .aegis/remediation/guardrails/cursorrules.md

To apply guardrails to your project:
  - Review the generated rules
  - Copy relevant sections to your .claude/CLAUDE.md or .cursorrules
  - Customize rules for your project's specific needs

Next steps:
  - Run full Transform pipeline: /aegis:transform
  - Generate execution plan: continue with Phase 8 via /aegis:transform

════════════════════════════════════════
```

</process>

<success_criteria>
- [ ] Layer A prerequisite validated (Core audit complete)
- [ ] Layer B prerequisite validated (remediation playbooks exist)
- [ ] Guardrail format selected (Claude MD / Cursor / both)
- [ ] Guardrail scope displayed (pattern count, domain count)
- [ ] Intervention level displayed (Suggesting for guardrails)
- [ ] Explicit confirmation obtained before generation
- [ ] Existing guardrails detected and options presented
- [ ] Phase 7 workflow delegated to (guardrail-generator portion)
- [ ] Output file locations and usage instructions provided
- [ ] Cancellation available at every decision point
</success_criteria>
