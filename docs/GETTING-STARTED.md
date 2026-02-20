# Getting Started with AEGIS

**From zero to first audit in 10 minutes.**

AEGIS is a multi-agent codebase audit system built on Claude Code. This guide walks you through installation, setup, and running your first audit. For architecture details, see the [README](../README.md).

---

## 1. Prerequisites

**Required:**

- **Claude Code CLI** — AEGIS runs as Claude Code slash commands
  ```bash
  claude --version   # Verify Claude Code is installed
  ```
- **git** — Required for repository analysis and git-history scanning

**Optional:**

- **Docker** — Only needed if you want a local SonarQube server for code quality analysis. All other tools install without Docker.

AEGIS installs its own analysis tools (Semgrep, Trivy, Gitleaks, Checkov, Syft, Grype). You do not need to pre-install them.

---

## 2. Install AEGIS

**One-command install (recommended):**

```bash
curl -sSL https://raw.githubusercontent.com/ChristopherKahler/aegis/main/install.sh | bash
```

**Or clone and install locally:**

```bash
git clone https://github.com/ChristopherKahler/aegis.git
cd aegis
bash install.sh
```

The installer is interactive. It copies framework files, installs slash commands, then walks you through each analysis tool:

```
AEGIS Installer
================

[1/2] Installing framework files...
  Copied 82 files to ~/.claude/aegis/
  Installed 10 commands to ~/.claude/commands/aegis/

[2/2] Tool installation
  Install Semgrep? (code pattern scanning) [Y/n]: y
    Installing Semgrep via venv... done
  Install Trivy? (vulnerability scanning) [Y/n]: y
    Installing Trivy... done
  ...

Summary: 7/7 tools installed, 0 skipped
```

Re-running the installer is safe — it skips tools already installed and updates framework files.

---

## 3. Verify Installation

Open Claude Code and run:

```
/aegis:validate
```

This tests every installed tool and reports pass/fail:

```
AEGIS VALIDATION REPORT
========================

Framework:
  ~/.claude/aegis/           82 files    pass
  ~/.claude/commands/aegis/  10 commands pass

Tools:
  Semgrep       pass   ~/.local/share/aegis/venvs/semgrep/bin/semgrep
  Trivy         pass   ~/.local/bin/trivy
  Gitleaks      pass   ~/.local/bin/gitleaks
  Checkov       pass   ~/.local/share/aegis/venvs/checkov/bin/checkov
  Syft          pass   ~/.local/bin/syft
  Grype         pass   ~/.local/bin/grype
  SonarQube     pass   Docker image: sonarsource/sonar-scanner-cli
  Git           pass   /usr/bin/git
```

If a tool shows "not found":
- Re-run `bash install.sh` and select Y for that tool
- Check that `~/.local/bin` is in your PATH
- For Python tools, check `~/.local/share/aegis/venvs/{tool}/bin/`

---

## 4. Initialize a Project

Navigate to the repository you want to audit, then run:

```
/aegis:init
```

This creates the `.aegis/` workspace for audit state and findings:

```
AEGIS Project Initialized
==========================

Target:    my-app (/home/user/projects/my-app)
State:     .aegis/STATE.md
Manifest:  .aegis/MANIFEST.md
Tools:     7/8 detected

.aegis/ added to .gitignore

Next steps:
  /aegis:validate  -- verify tool installation
  /aegis:audit     -- begin diagnostic audit
```

Init is separate from auditing — you can init a project now and audit it later. If `.aegis/` already exists, you will be offered the choice to resume, start fresh, or cancel.

---

## 5. Run Your First Audit

In the same repository, run:

```
/aegis:audit
```

The audit wizard walks you through configuration:

1. **Scope selection** — Choose Full (recommended for first run), Targeted (specific domains), or Quick (phases 0-2 only)
2. **Tool selection** — All installed tools enabled by default; toggle any off if needed
3. **Confirmation** — Review the audit plan and confirm

```
AUDIT PLAN
===========

Target: my-app
Scope:  Full audit
Phases: 0-5
Domains: 14 of 14
Tools: 7 enabled
Estimated sessions: 8-13

[1] Start audit
[2] Modify scope
[3] Cancel
```

After confirmation, Phase 0 (Context & Threat Modeling) starts automatically.

---

## 6. Multi-Session Workflow

AEGIS audits span multiple Claude Code sessions. A full audit runs through 6 phases:

| Phase | Name | Sessions |
|-------|------|----------|
| 0 | Context & Threat Modeling | 1 |
| 1 | Automated Signal Gathering | 1 |
| 2 | Deep Domain Audits | 1-8 |
| 3 | Change Risk & Reality Gap | 1-2 |
| 4 | Adversarial Review | 1 |
| 5 | Synthesis & Report | 1 |

**After each phase completes**, you see a checkpoint:

```
PHASE 1 COMPLETE -- Automated Signal Gathering
================================================

Agents completed: (tools)
Findings produced: 0
Signals gathered: 247

CUMULATIVE PROGRESS
[████░░░░░░░░░░░░░░░░] Phase 1 of 5 complete

NEXT: Phase 2 -- Deep Domain Audits
  8 domain specialist agents
  Estimated sessions: 1-8

[1] Continue to Phase 2 (recommended)
[2] Pause here -- safe to close this session
[3] Abort audit -- preserves all work so far
```

**If you pause**, your progress is saved. Come back anytime and run:

```
/aegis:resume
```

Resume shows what was completed, findings so far, and picks up at the next phase.

**Check progress anytime** (read-only, safe to run mid-audit):

```
/aegis:status
```

---

## 7. Viewing Results

After Phase 5 completes, generate the final audit report:

```
/aegis:report
```

The report is written to `.aegis/report/AEGIS-REPORT.md` — a structured markdown document with:
- Executive summary
- Findings by domain and severity
- Disagreements and their resolutions
- Risk assessment and recommendations

**Optional next steps:**

- `/aegis:transform` — Start the remediation pipeline (generates fix plans from findings)
- `/aegis:guardrails` — Generate project rules for AI coding assistants based on findings

---

## 8. Command Reference

| Command | Description |
|---------|-------------|
| `/aegis:audit` | Start a new diagnostic audit (wizard-guided) |
| `/aegis:resume` | Resume a paused audit from last checkpoint |
| `/aegis:status` | View audit progress and findings summary (read-only) |
| `/aegis:report` | Generate the final audit report |
| `/aegis:init` | Initialize AEGIS in a project (creates .aegis/) |
| `/aegis:validate` | Test tool installation and troubleshoot |
| `/aegis:transform` | Start the remediation pipeline on completed audit |
| `/aegis:remediate` | Generate remediation plans for findings |
| `/aegis:playbook` | Create a remediation playbook for a specific finding |
| `/aegis:guardrails` | Generate project rules from audit findings |

---

## 9. Troubleshooting

**"Tool X not found" during validate**
- Re-run `bash install.sh` and select Y for that tool
- For binary tools: check `~/.local/bin` is in your PATH (`echo $PATH`)
- For Python tools: check the venv exists at `~/.local/share/aegis/venvs/{tool}/`

**"Permission denied" during install**
- AEGIS never requires sudo. All tools install to `~/.local/bin/` or `~/.local/share/aegis/`
- Check file permissions: `ls -la ~/.local/bin/`

**"Docker not running" (SonarQube)**
- Start Docker: `sudo systemctl start docker` or open Docker Desktop
- SonarQube is optional — all other tools work without Docker
- Skip SonarQube during install if you don't need code quality metrics

**"Context window exceeded" during audit**
- Audit phases are designed for the 200k token context window
- If hitting limits: use Targeted audit with fewer domains, or Quick scan (phases 0-2 only)
- Each agent session is independent — context resets between sessions

**".aegis/ already exists"**
- `/aegis:init` detects existing state and offers: resume, fresh start (archives old state), or cancel
- Old state is preserved in `.aegis-backup-{timestamp}/` if you choose fresh start

**"How do I update AEGIS?"**
- Re-run the install script — it overwrites framework files and preserves tool installations
- Your `.aegis/` project state is not affected by framework updates

---

*For architecture details, audit domains, and the epistemic framework, see the [README](../README.md).*
