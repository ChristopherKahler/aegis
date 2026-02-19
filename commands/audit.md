---
name: aegis:audit
description: Run a full or targeted AEGIS diagnostic audit on a codebase
argument-hint: "[path-to-repo]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion]
---

<objective>
Initiates a new AEGIS diagnostic audit on a target codebase. This is the primary entry point for all Core audit operations. Guides the user through scope selection, domain targeting, tool configuration, and confirmation before delegating to the Phase 0 workflow.

If an existing audit is detected (.aegis/ directory present), routes to /aegis:resume instead of starting fresh.

Produces: initialized .aegis/ directory with STATE.md and MANIFEST.md, then begins Phase 0 (Context & Threat Modeling).
</objective>

<execution_context>
@~/.claude/aegis/core/workflows/phase-0-context.md
@~/.claude/aegis/core/workflows/phase-1-reconnaissance.md
@~/.claude/aegis/core/workflows/phase-2-domain-audits.md
@~/.claude/aegis/core/workflows/phase-3-cross-domain.md
@~/.claude/aegis/core/workflows/phase-4-adversarial-review.md
@~/.claude/aegis/core/workflows/phase-5-report.md
@~/.claude/aegis/core/workflows/session-handoff.md
@~/.claude/aegis/core/workflows/disagreement-resolution.md
</execution_context>

<context>
$ARGUMENTS
@.aegis/STATE.md
@.aegis/MANIFEST.md
</context>

<process>

## Step 1: Determine Target Repository

Check if $ARGUMENTS contains a repository path:
- If YES: use the provided path as the audit target
- If NO: use the current working directory

Validate the target:
- Confirm the path exists and is a directory
- Check for .git/ (warn if absent — not required but informative)
- Display target path for user confirmation

## Step 2: Check for Existing Audit

Check if .aegis/STATE.md exists in the target repository:

- If YES: An audit is already in progress.
  ```
  ════════════════════════════════════════
  EXISTING AUDIT DETECTED
  ════════════════════════════════════════

  Target: [path]
  Current Phase: [from STATE.md]
  Status: [from STATE.md]
  Findings so far: [count]

  [1] Resume existing audit (recommended) → runs /aegis:resume
  [2] Start fresh (WARNING: deletes existing .aegis/ state)
  [3] Cancel
  ════════════════════════════════════════
  ```
  - If [1]: delegate to /aegis:resume
  - If [2]: proceed to Step 3 (confirm deletion first)
  - If [3]: exit

- If NO: proceed to Step 3

## Step 3: Repository Analysis

Analyze the target repository and display:
```
════════════════════════════════════════
TARGET REPOSITORY
════════════════════════════════════════

Path: [absolute path]
Languages: [detected from file extensions]
Frameworks: [detected from config files — package.json, requirements.txt, go.mod, etc.]
Repository size: [file count estimate]
Last commit: [if git repo — short hash + date]
════════════════════════════════════════
```

## Step 4: Select Audit Scope

Present audit scope options:
```
════════════════════════════════════════
AUDIT SCOPE
════════════════════════════════════════

[1] Full audit — all phases (0-5), all 14 domains (recommended for first run)
[2] Targeted audit — select specific domains to include
[3] Quick scan — Phases 0-2 only (context + signals + domain audits, no synthesis/adversarial)
[4] Cancel
════════════════════════════════════════
```

If [2] (Targeted) selected, present domain checklist:
```
Select domains to include:

[ ] 00 — Context & Intent
[ ] 01 — Architecture & System Design
[ ] 02 — Data & State Integrity
[ ] 03 — Correctness & Logic
[ ] 04 — Security
[ ] 05 — Compliance, Privacy & Governance
[ ] 06 — Testing Strategy & Verification
[ ] 07 — Reliability & Resilience
[ ] 08 — Scalability & Performance
[ ] 09 — Maintainability & Code Health
[ ] 10 — Operability & Developer Experience
[ ] 11 — Change Risk & Evolvability
[ ] 12 — Team, Ownership & Knowledge Risk
[ ] 13 — Risk Synthesis & Forecasting

Enter domain numbers (comma-separated), "all" for full audit, or "back" to return to scope selection:
```

Note: Domain 00 (Context) is always included regardless of selection — it is required for scope establishment.

## Step 5: Audit Configuration

Present optional configuration:
```
════════════════════════════════════════
AUDIT CONFIGURATION
════════════════════════════════════════

Tool selection (all enabled by default):
  [x] SonarQube — code quality, complexity, duplication
  [x] Semgrep — pattern-based security/correctness scanning
  [x] Trivy — vulnerability and misconfiguration scanning
  [x] Gitleaks — secrets detection
  [x] Checkov — infrastructure-as-code scanning
  [x] Syft + Grype — SBOM generation + CVE matching
  [x] git-history — churn, author concentration, change frequency

Toggle tools? Enter tool names to disable, "ok" to continue, or "back" to return to scope selection:
════════════════════════════════════════
```

If the target has no IaC files, note that Checkov will be skipped automatically.
If no .git/ directory, note that git-history and Gitleaks will have limited output.

## Step 6: Confirm and Execute

Display the audit plan for confirmation:
```
════════════════════════════════════════
AUDIT PLAN
════════════════════════════════════════

Target: [path]
Scope: [Full / Targeted / Quick]
Phases: [0-5 or 0-2]
Domains: [count] of 14 [list if targeted]
Tools: [count] enabled [list any disabled]
Estimated sessions: [count based on scope — full ~8-10, quick ~4-5]

[1] Start audit (recommended)
[2] Modify scope
[3] Cancel
════════════════════════════════════════
```

If [1] selected:
1. Initialize .aegis/ directory structure per runtime specification
2. Create .aegis/STATE.md with Phase 0 pending status
3. Create .aegis/MANIFEST.md with version-locked component references
4. Record audit scope, domain selection, and tool configuration in .aegis/STATE.md
5. Delegate to phase-0-context workflow to begin the audit

If [2]: return to Step 4
If [3]: exit without creating any files

</process>

<success_criteria>
- [ ] Target repository identified and validated
- [ ] Audit scope clearly defined and confirmed by user
- [ ] Tool configuration confirmed (defaults or user-modified)
- [ ] .aegis/ directory initialized with STATE.md and MANIFEST.md
- [ ] Phase 0 workflow delegation begins successfully
- [ ] User receives clear feedback on what will happen next
- [ ] Cancellation available at every decision point
</success_criteria>
