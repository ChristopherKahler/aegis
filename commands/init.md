---
name: aegis:init
description: Initialize AEGIS in a target project
argument-hint: "[path-to-repo]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion]
---

<objective>
Initializes AEGIS in a target project by creating the `.aegis/` directory structure with state tracking and framework manifest. This is the project setup command — run once per repository before auditing.

If an existing `.aegis/` is detected, offers resume, fresh start, or cancel.

This command does NOT start an audit — it prepares the project. Run `/aegis:audit` after init to begin.
</objective>

<execution_context>
<!-- Standalone command: no workflow delegation required -->
</execution_context>

<context>
$ARGUMENTS
@.aegis/STATE.md
</context>

<process>

## Step 1: Determine Target Repository

Check if $ARGUMENTS contains a repository path:
- If YES: use the provided path as the audit target
- If NO: use the current working directory

Validate the target:
- Confirm the path exists and is a directory
- Check for `.git/` directory
- If no `.git/`: warn "This directory is not a git repository. AEGIS works best with git repos (git-history analysis, Gitleaks). Continue anyway? [y/N]"
- Display target path for confirmation

## Step 2: Check for Existing .aegis/

Check if `.aegis/STATE.md` exists in the target repository:

- If YES: An AEGIS project already exists.
  ```
  ════════════════════════════════════════
  EXISTING AEGIS PROJECT DETECTED
  ════════════════════════════════════════

  Target: [path]
  Status: [from STATE.md — initialized / in_progress / complete]
  Current Phase: [from STATE.md]
  Initialized: [from STATE.md timestamp]

  [1] Resume existing audit → /aegis:resume
  [2] Fresh start (archives current .aegis/ to .aegis-backup-{YYYYMMDD-HHMMSS}/)
  [3] Cancel
  ════════════════════════════════════════
  ```
  - If [1]: inform user to run `/aegis:resume` and exit
  - If [2]: rename `.aegis/` to `.aegis-backup-{timestamp}/`, then proceed to Step 3
  - If [3]: exit

- If NO `.aegis/`: proceed to Step 3

## Step 3: Create .aegis/ Directory Structure

Create the following structure:

```
.aegis/
├── STATE.md         # Audit state tracking
├── MANIFEST.md      # Version-locked framework references
└── findings/        # Output directory for phase findings
```

## Step 4: Initialize STATE.md

Create `.aegis/STATE.md` with:

```markdown
# AEGIS Audit State

## Target

Repository: {repo-name (directory basename)}
Path: {absolute-path}
Initialized: {ISO 8601 timestamp}

## Status

Overall: initialized
Current Phase: none (run /aegis:audit to begin)

## Phases

| Phase | Name | Status | Findings |
|-------|------|--------|----------|
| 0 | Context & Threat Modeling | pending | - |
| 1 | Automated Signal Gathering | pending | - |
| 2 | Deep Domain Audits | pending | - |
| 3 | Change Risk & Reality Gap | pending | - |
| 4 | Adversarial Review | pending | - |
| 5 | Synthesis & Report | pending | - |

## Tool Configuration

Configured by /aegis:audit at audit start.

## Resume Info

Last action: Project initialized
Next action: Run /aegis:audit to begin diagnostic audit
```

## Step 5: Initialize MANIFEST.md

Create `.aegis/MANIFEST.md` with:

```markdown
# AEGIS Manifest

## Framework

Version: {read from ~/.claude/aegis/ if available, else "unknown"}
Framework path: ~/.claude/aegis/
Commands path: ~/.claude/commands/aegis/
Initialized: {ISO 8601 timestamp}

## Installed Tools

| Tool | Status | Location |
|------|--------|----------|
| SonarQube | {detected/not found} | {path or "n/a"} |
| Semgrep | {detected/not found} | {path — CLI or venv} |
| Trivy | {detected/not found} | {path} |
| Gitleaks | {detected/not found} | {path} |
| Checkov | {detected/not found} | {path — CLI or venv} |
| Syft | {detected/not found} | {path} |
| Grype | {detected/not found} | {path} |
| Git | {detected/not found} | {path} |

## Notes

Run /aegis:validate for detailed tool verification and troubleshooting.
```

To detect each tool:
- Try `command -v {tool}` first (checks PATH)
- For Python tools, also check `~/.local/share/aegis/venvs/{tool}/bin/{tool}`
- For SonarQube, also check `docker image inspect sonarsource/sonar-scanner-cli 2>/dev/null`
- For git, use `command -v git`

## Step 6: Update .gitignore

Check if `.gitignore` exists in the target repository:
- If YES: check if it contains `.aegis/` (or `.aegis`)
  - If already present: do nothing
  - If not present: append `\n# AEGIS audit state (generated)\n.aegis/\n`
- If NO .gitignore: create one with:
  ```
  # AEGIS audit state (generated)
  .aegis/
  ```

Report what was done.

## Step 7: Display Summary

```
════════════════════════════════════════
AEGIS Project Initialized
════════════════════════════════════════

Target:    {repo-name} ({absolute-path})
State:     .aegis/STATE.md
Manifest:  .aegis/MANIFEST.md
Tools:     {X}/8 detected

.aegis/ added to .gitignore ✓

────────────────────────────────────────
Next steps:
  /aegis:validate  — verify tool installation
  /aegis:audit     — begin diagnostic audit
════════════════════════════════════════
```

</process>

<success_criteria>
- [ ] Target repository identified and validated
- [ ] Existing .aegis/ handled (resume/fresh/cancel)
- [ ] .aegis/ directory created with STATE.md, MANIFEST.md, findings/
- [ ] Tool inventory detected and recorded in MANIFEST.md
- [ ] .aegis/ added to .gitignore
- [ ] User informed of next steps
</success_criteria>
