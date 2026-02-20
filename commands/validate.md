---
name: aegis:validate
description: Test AEGIS tool installation and framework integrity
allowed-tools: [Read, Bash, Glob, Grep]
---

<objective>
Tests the AEGIS installation by verifying framework files, slash commands, and each OSS analysis tool. Reports pass/fail per component with troubleshooting guidance for any failures.

This is a read-only command — it never modifies files or installs anything. Safe to run anytime.
</objective>

<execution_context>
<!-- Read-only command: no workflow delegation required -->
</execution_context>

<context>
@.aegis/STATE.md
</context>

<process>

## Step 1: Check Framework Installation

Verify the AEGIS framework is installed:

1. Check `~/.claude/aegis/` exists:
   - If YES: count files in key subdirectories (domains/, schemas/, rules/, tools/, core/, transform/)
   - If NO: report "Framework not installed" and suggest `install.sh`

2. Check `~/.claude/commands/aegis/` exists:
   - If YES: list command files, count them
   - If NO: report "Commands not installed" and suggest `install.sh`

Record results for summary.

## Step 2: Test Each OSS Tool

For each tool, run the appropriate version/detection command. Handle multiple installation methods (PATH, venv, Docker).

**Tool checks in order:**

### Semgrep
```bash
# Try PATH first
semgrep --version 2>/dev/null
# Fallback: check venv
~/.local/share/aegis/venvs/semgrep/bin/semgrep --version 2>/dev/null
```
- Pass: report version number and location (PATH or venv)
- Fail: "Semgrep not found. Re-run install.sh or: python3 -m venv ~/.local/share/aegis/venvs/semgrep && ~/.local/share/aegis/venvs/semgrep/bin/pip install semgrep"

### Trivy
```bash
trivy --version 2>/dev/null
```
- Pass: report version
- Fail: "Trivy not found. Re-run install.sh or visit https://aquasecurity.github.io/trivy"

### SonarQube
```bash
# Check 1: Native scanner CLI
sonar-scanner --version 2>/dev/null

# Check 2: Docker scanner image
docker image inspect sonarsource/sonar-scanner-cli >/dev/null 2>&1

# Check 3: Docker server container
docker ps --filter "ancestor=sonarqube:community" --format "{{.Names}}" 2>/dev/null

# Check 4: Localhost server
curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/api/system/status 2>/dev/null
```
- Pass if ANY check succeeds: report which mode detected (native CLI / Docker scanner / Docker server / localhost)
- Fail: "SonarQube not detected. Options: Docker (docker pull sonarqube:community) or SonarQube Cloud (sonarcloud.io). Re-run install.sh for guided setup."

### Gitleaks
```bash
gitleaks version 2>/dev/null
```
- Pass: report version
- Fail: "Gitleaks not found. Re-run install.sh or visit https://github.com/gitleaks/gitleaks"

### Checkov
```bash
# Try PATH first
checkov --version 2>/dev/null
# Fallback: check venv
~/.local/share/aegis/venvs/checkov/bin/checkov --version 2>/dev/null
```
- Pass: report version and location
- Fail: "Checkov not found. Re-run install.sh or: python3 -m venv ~/.local/share/aegis/venvs/checkov && ~/.local/share/aegis/venvs/checkov/bin/pip install checkov"

### Syft
```bash
syft version 2>/dev/null
```
- Pass: report version
- Fail: "Syft not found. Re-run install.sh or: curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ~/.local/bin"

### Grype
```bash
grype version 2>/dev/null
```
- Pass: report version
- Fail: "Grype not found. Re-run install.sh or: curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ~/.local/bin"

### Git (built-in)
```bash
git --version 2>/dev/null
```
- Pass: report version (should always pass)
- Fail: "Git not found — this is unexpected. Install git for your platform."

## Step 3: Check Project State (if applicable)

If `.aegis/STATE.md` exists in the current directory:
1. Read STATE.md
2. Report project status:
   ```
   Project: {repo-name}
   Status: {overall status}
   Phase: {current phase}
   ```
3. Note which tools the project's audit is configured to use (if audit has started)

If no `.aegis/`: skip this section silently.

## Step 4: Display Validation Report

```
════════════════════════════════════════
AEGIS Validation Report
════════════════════════════════════════

Framework:
  {✓/✗} ~/.claude/aegis/         ({N} files)
  {✓/✗} ~/.claude/commands/aegis/ ({M} commands)

Tools:
  {✓/✗} semgrep       {version}  {(venv) if applicable}
  {✓/✗} trivy          {version}
  {✓/✗} sonarqube      {mode: native/docker/localhost}
  {✓/✗} gitleaks       {version}
  {✓/✗} checkov        {version}  {(venv) if applicable}
  {✓/✗} syft           {version}
  {✓/✗} grype          {version}
  {✓/✗} git            {version}  (built-in)

Result: {pass_count}/{total} tools available

{If any failures:}
────────────────────────────────────────
Troubleshooting:

  {tool}: {specific fix instruction}
  {tool}: {specific fix instruction}

General: Re-run install.sh to fix most issues.
────────────────────────────────────────

{If .aegis/ exists:}
Project: {repo-name} — {status}

════════════════════════════════════════
```

</process>

<success_criteria>
- [ ] Framework installation verified (files + commands)
- [ ] All 7 OSS tools + git tested with version commands
- [ ] Venv-installed tools checked at both PATH and venv locations
- [ ] Docker-based SonarQube detected via image/container/localhost
- [ ] Clear pass/fail per tool with troubleshooting for failures
- [ ] Project state shown if .aegis/ exists
</success_criteria>
