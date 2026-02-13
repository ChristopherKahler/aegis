# Command Convention

## Purpose

Commands define **ENTRY** — user-facing slash commands that provide a guided wizard UX for interacting with AEGIS. Commands are thin wrappers around workflows. They present options, collect user input, validate prerequisites, and delegate execution to the appropriate workflow.

Commands are the only part of AEGIS that users interact with directly. Everything else — personas, domains, tools, schemas, rules, agents, workflows — operates behind the command layer. A well-designed command makes AEGIS feel like a guided experience rather than a raw framework.

AEGIS uses approximately 8 command files: 4 for Core audit operations and 4 for Transform remediation operations.

## Location

```
src/core/commands/      (Core audit commands)
src/transform/commands/ (Transform remediation commands)
```

## Naming

**Pattern:** `{kebab-name}.md`

**Core examples:**
- `audit.md`
- `resume.md`
- `status.md`
- `report.md`

**Transform examples:**
- `transform.md`
- `playbook.md`
- `remediate.md`
- `guardrails.md`

Commands are invoked by users as `aegis:{kebab-name}` (e.g., `/aegis:audit`).

## Required Structure

Every command file consists of YAML frontmatter followed by XML-tagged sections.

### Frontmatter (Required)

```yaml
---
name: aegis:{kebab-name}
description: [One-line description]
argument-hint: "[optional-arg]"
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Command invocation name. Format: `aegis:{kebab-name}` |
| `description` | string | yes | One-line description shown in command help |
| `argument-hint` | string | no | Hint for optional arguments (e.g., `"[path-to-repo]"`, `"[phase-number]"`) |

### Body Sections (All Required)

| Section | Tag | Purpose |
|---------|-----|---------|
| Objective | `<objective>` | What the command does, when to use it, what it produces. |
| Execution Context | `<execution_context>` | `@` references to workflows and framework resources the command needs. |
| Context | `<context>` | Runtime context: arguments, state files, configuration. |
| Process | `<process>` | Guided wizard flow with numbered options and clear routing to workflows. |
| Success Criteria | `<success_criteria>` | Measurable outcomes. Checklist of what "done" looks like. |

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| References | Core Workflows (`src/core/workflows/`) | By path in `<execution_context>` |
| References | Transform Workflows (`src/transform/workflows/`) | By path in `<execution_context>` |
| References | `.aegis/` state files | For prerequisite checking and state display |
| Referenced BY | Users | Slash command invocation (e.g., `/aegis:audit`, `/aegis:transform`) |

Commands are the **entry points** of the dependency graph. Users invoke commands; commands invoke workflows; workflows invoke agents.

## Example Skeleton

````markdown
---
name: aegis:audit
description: Run an AEGIS audit on a codebase
argument-hint: "[path-to-repo]"
---

<objective>
[What this command does, when to use it, what the user gets.

Example: "Runs a full or partial AEGIS audit on a target codebase. This is the
primary entry point for starting a new audit, resuming an interrupted audit, or
re-running specific phases. Produces a structured audit report with findings,
severity assessments, and remediation recommendations."]
</objective>

<execution_context>
@src/workflows/phase-0-context.md
@src/workflows/phase-1-reconnaissance.md
@src/workflows/phase-2-domain-audits.md
@src/workflows/phase-3-cross-domain.md
@src/workflows/phase-4-severity-calibration.md
@src/workflows/phase-5-report.md
@src/workflows/session-handoff.md
[Additional workflow references as needed]
</execution_context>

<context>
$ARGUMENTS
@.aegis/STATE.md
@.aegis/MANIFEST.md
</context>

<process>

## Step 1: Determine Audit Scope

Check if $ARGUMENTS contains a repository path. If not, use the current working
directory.

Check if .aegis/STATE.md exists:
- If YES: An audit is in progress. Present resume options (Step 2).
- If NO: This is a new audit. Present initialization options (Step 3).

## Step 2: Resume Existing Audit

Display current audit state from .aegis/STATE.md:
- Last completed phase
- Finding count so far
- Any unresolved disagreements
- Any errors or incomplete phases

Present options:
```
[1] Resume from last checkpoint (recommended)
[2] Re-run phase {N} (last completed phase)
[3] Re-run from phase {N} (specific phase)
[4] Start fresh (WARNING: deletes existing .aegis/ state)
[5] Cancel
```

Route to appropriate workflow based on selection.

## Step 3: Initialize New Audit

Display target repository information:
- Path
- Detected languages/frameworks
- Repository size estimate

Present audit scope options:
```
[1] Full audit — all phases, all domains (recommended for first run)
[2] Targeted audit — select specific domains
[3] Quick scan — phase 0-2 only (reconnaissance + domain audits, no synthesis)
[4] Cancel
```

If [2] selected, present domain checklist:
```
[ ] 00 — Context
[ ] 01 — Architecture
[ ] 02 — Code Quality
...
[ ] 13 — Risk Synthesis
```

After selection, delegate to phase-0-context workflow to begin.

## Step 4: Confirm and Execute

Display audit plan:
- Scope (full / targeted / quick)
- Phases to execute
- Estimated session count
- Domains included

```
[1] Start audit (recommended)
[2] Modify scope
[3] Cancel
```

If [1] selected, delegate to first workflow in sequence.

</process>

<success_criteria>
- [ ] Audit scope is clearly defined and confirmed by user
- [ ] All prerequisite checks pass (tools installed, repository accessible)
- [ ] Workflow delegation begins successfully
- [ ] .aegis/ directory is initialized with STATE.md and MANIFEST.md
- [ ] User receives clear feedback on what will happen next
</success_criteria>
````

## Transform Command Conventions

Transform commands are entry points to the remediation pipeline. They follow the same structural conventions as Core commands (frontmatter + XML sections) but include Transform-specific safety requirements.

**The 4 Transform commands:**

| Command | Invocation | Purpose |
|---------|-----------|---------|
| Transform | `/aegis:transform` | Initiate Transform pipeline on a completed audit |
| Playbook | `/aegis:playbook {finding-id}` | Generate remediation playbook for a specific finding |
| Remediate | `/aegis:remediate` | Generate full remediation plan (all findings) |
| Guardrails | `/aegis:guardrails` | Generate project rules from audit findings |

**Safety requirement:** All Transform commands must display intervention level and confidence information before proceeding with any output generation. The user must confirm before Transform produces output at Planning level or above.

**Example Transform command flow:**

```
/aegis:transform

[1] Check prerequisites:
    - Verify completed Core audit (.aegis/report/ exists)
    - Verify Layer A integrity (all phases 0-5 complete)

[2] Display Transform scope:
    - Finding count: N findings across M domains
    - Estimated playbook count: ~P
    - Maximum intervention level available: [based on confidence distribution]

[3] Select Transform scope:
    [1] Full Transform — all findings, all phases (6-8)
    [2] Selective — choose specific findings or domains
    [3] Playbooks only — Phase 6 only (no risk scoring or PAUL project)
    [4] Cancel

[4] Confirm and execute:
    - Display: "Transform will produce remediation at intervention levels: Suggesting (N), Planning (M), Authorizing (K)"
    - Require explicit confirmation before proceeding
```

**Transform commands delegate to Transform workflows** in `src/transform/workflows/`, following the same delegation pattern as Core commands.

**Prerequisite enforcement:** Transform commands MUST verify that Core audit is complete before allowing Transform to proceed. A Transform command that runs against an incomplete Layer A record produces unreliable remediation.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Embedding execution logic | Commands delegate to workflows; they do not execute audit logic themselves. "Run Semgrep on the codebase" is workflow/tool logic. Commands say "delegate to phase-1-reconnaissance workflow which handles tool execution." |
| Missing guided wizard options | Commands must present clear, numbered choices at every decision point. Dumping the user into a workflow without confirming scope, showing state, or offering alternatives is poor UX. The command layer exists specifically to provide guided interaction. |
| No success criteria | Without measurable outcomes, there is no way to verify the command worked. "Audit started" is not a success criterion. "STATE.md created with phase-0 status, MANIFEST.md lists all agents, tools installed and verified" is a success criterion. |
| Duplicating workflow steps | If the command's `<process>` section contains detailed analysis steps, those steps should be in a workflow file instead. The command guides the user to the right workflow and hands off. It does not replicate the workflow's internals. |
| Hardcoded paths or tool names | Commands should reference workflows and state files by their standard locations. Hardcoding tool names or specific file paths (beyond `.aegis/` conventions) makes commands brittle when the framework evolves. |
| Missing cancellation options | Every decision point must include a way to cancel or go back. Users should never feel trapped in a command flow. Always include a "Cancel" or "Pause" option. |
| Transform command without safety display | Every Transform command must show intervention levels and confidence before producing output. Generating remediation without user awareness of the intervention level violates the safety framework. |
| Transform command that skips prerequisite check | Transform requires a complete Layer A record. A command that allows Transform to run against an incomplete audit produces remediation based on partial information — potentially dangerous. |
