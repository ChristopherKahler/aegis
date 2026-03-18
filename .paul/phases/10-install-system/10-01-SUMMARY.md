---
phase: 10-install-system
plan: 01
subsystem: infra
tags: [bash, installer, curl, venv, docker, sonarqube, semgrep, trivy, gitleaks, checkov, syft, grype]

requires:
  - phase: 09-command-conversion
    provides: installable command files with @~/.claude/aegis/ paths
provides:
  - Interactive install script (local + curl|bash remote)
  - OSS tool installation with smart detection
  - Post-install verification
affects: [11-project-init-validation, 13-readme-update]

tech-stack:
  added: [bash, venv]
  patterns: [curl|bash remote install, venv-based Python tools, binary curl to ~/.local/bin]

key-files:
  created: [install.sh]
  modified: []

key-decisions:
  - "curl|bash as public install method — zero deps, industry standard"
  - "Python venv over pipx/pip — PEP 668 compatibility"
  - "Binary tools install to ~/.local/bin — no sudo required"
  - "Smart SonarQube detection — Docker image + container + localhost"
  - "Auto-skip already-installed tools on re-run"
  - "AEGIS_BRANCH = feature/v1-implementation for testing"

patterns-established:
  - "Dual-mode install: local repo (bash install.sh) + remote (curl|bash)"
  - "venv pattern for Python CLI tools in user-space"
  - "Docker-aware tool detection (image exists even without native CLI)"

duration: ~4h (multi-session)
started: 2026-02-19
completed: 2026-02-20
---

# Phase 10 Plan 01: Install System Summary

**Interactive install script with dual-mode support (local + curl|bash), venv-based Python tools, and smart SonarQube detection across Docker/localhost/CLI**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~4 hours (across 2 sessions) |
| Started | 2026-02-19 |
| Completed | 2026-02-20 |
| Tasks | 1 completed |
| Files created | 1 (install.sh — 711 lines) |
| Commits | 14 (iterative testing + fixes) |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Framework Files Placed | Pass | `src/` copied to `~/.claude/aegis/` preserving structure |
| AC-2: Commands Placed | Pass | `commands/*.md` copied to `~/.claude/commands/aegis/` |
| AC-3: Interactive Tool Installation | Pass | Y/N prompts for all 7 tools with smart install methods |
| AC-4: Post-Install Verification | Pass | Each installed tool tested; 7/7 verified successfully |
| AC-5: Idempotent and Safe | Pass | Detects existing install, offers [1] Update [2] Tool-setup-only [3] Cancel |

## Accomplishments

- Created `install.sh` (711 lines) — production-quality interactive installer
- Dual-mode support: local repo execution AND remote `curl | bash` from GitHub
- All 7 OSS tools install and verify successfully
- Smart SonarQube detection handles Docker scanner image, Docker server container, and localhost:9000
- Auto-skip already-installed tools on re-run (idempotent)

## Task Commits

Each commit represents an iterative fix discovered during live testing:

| Task | Commit | Type | Description |
|------|--------|------|-------------|
| Initial script | `500c36c` | feat | Interactive install script with curl\|bash support |
| SonarQube fix | `86513a3` | fix | Fix SonarQube recursive loop + refactor scanner install |
| Re-install flow | `62bdd6c` | fix | Better re-install flow — update, tool-setup-only, or cancel |
| tty fix | `4eeb609` | fix | Read from /dev/tty so curl\|bash prompts work |
| Exit codes | `430c01e` | fix | Use pipx for Python tools, fix exit code detection |
| Prereq check | `dd7938e` | fix | Check python3 not pipx for prerequisite detection |
| pipx bootstrap | `bd84ca1` | fix | Bootstrap pipx with --break-system-packages for PEP 668 |
| venv migration | `9996f8f` | fix | Use venv for Python tools — bypasses PEP 668 entirely |
| Gitleaks version | `fbc6857` | fix | Dynamic gitleaks version + platform detection |
| Auto-skip | `8029809` | feat | Auto-skip already-installed tools |
| SonarQube smart | `7239ea0` | feat | Smart SonarQube detection — Docker, localhost, scanner CLI |
| Docker scanner | `5cb4893` | feat | Detect Docker-based sonar-scanner-cli image |
| Docker verify | `203589f` | fix | Verify Docker scanner image when no native CLI exists |

## Files Created/Modified

| File | Change | Purpose |
|------|--------|---------|
| `install.sh` | Created | Interactive installer — dual-mode, 7 OSS tools, verification |

## Decisions Made

| Decision | Rationale | Impact |
|----------|-----------|--------|
| curl\|bash remote install | Zero deps, industry standard (syft/grype/trivy all use it) | Users can install without cloning repo |
| Python venv over pipx/pip | PEP 668 blocks pip install on modern Ubuntu/WSL2 | Reliable Python tool installs via `~/.local/share/aegis/venvs/` |
| Binary tools via curl to ~/.local/bin | No sudo, user-space, on default PATH | Clean installs without elevated privileges |
| Smart SonarQube detection | User's SonarQube runs via Docker MCP server, not native CLI | Detects 3 modes: Docker scanner image, Docker server, localhost |
| Auto-skip installed tools | Re-running should be fast and non-destructive | Idempotent — safe to re-run anytime |
| AEGIS_BRANCH = feature/v1-implementation | Testing branch; main not ready yet | Must change to `main` before public release |

## Deviations from Plan

### Summary

| Type | Count | Impact |
|------|-------|--------|
| Scope additions | 4 | Essential for real-world usability |
| Auto-fixed | 8 | Discovered through live testing |
| Deferred | 1 | Minor — CDN cache timing |

**Total impact:** Significant positive deviations — script is substantially more robust than planned. Every deviation came from live testing revealing real-world requirements.

### Scope Additions (Beyond Original Plan)

**1. Dual-mode install (local + curl|bash)**
- **Plan said:** Local `bash install.sh` only
- **Built:** Both local and remote `curl -sSL ... | bash` support
- **Why:** Industry standard for CLI tool distribution; GitHub repo is public
- **Impact:** Users can install without cloning — single command install

**2. venv-based Python tools**
- **Plan said:** `pip install` or `brew install`
- **Built:** Python tools install into dedicated venvs at `~/.local/share/aegis/venvs/`
- **Why:** PEP 668 on modern Ubuntu/WSL2 blocks `pip install` outside venvs
- **Impact:** Reliable Python tool installation on all modern Linux

**3. Smart SonarQube detection**
- **Plan said:** Check `sonar-scanner --version` and Docker image
- **Built:** Three-layer detection: Docker scanner image (`sonarsource/sonar-scanner-cli`), Docker server container, localhost:9000
- **Why:** User's SonarQube runs entirely via Docker (MCP server pattern), no native CLI
- **Impact:** Correctly detects SonarQube in Docker-based setups

**4. Auto-skip already-installed tools**
- **Plan said:** Prompt Y/N for all tools every time
- **Built:** Detects already-installed tools and auto-skips with notification
- **Why:** Re-running installer shouldn't re-install everything
- **Impact:** Idempotent, safe to re-run

### Auto-fixed Issues

All 8 fixes were discovered through iterative live testing:

1. **stdin pipe conflict** — `curl | bash` sends stdin through pipe; fixed with `/dev/tty` reads
2. **SonarQube recursive loop** — install function called itself; refactored scanner install
3. **PEP 668 pip failure** — modern Ubuntu blocks pip; migrated from pip → pipx → venv
4. **pipx bootstrap** — pipx itself needed `--break-system-packages` flag
5. **Exit code detection** — tool install exit codes not properly captured
6. **Gitleaks version hardcoding** — version URL broke; switched to dynamic GitHub API detection
7. **Platform detection** — binary downloads need arch-specific URLs (amd64 vs arm64)
8. **Docker scanner verification** — `sonar-scanner --version` fails when scanner is Docker-based; added image inspection fallback

### Deferred Items

- **CDN cache timing:** GitHub raw CDN may cache old `install.sh` briefly after push. Self-resolving; no action needed.
- **AEGIS_BRANCH:** Currently set to `feature/v1-implementation` — must change to `main` before release (tracked in STATE.md decisions).

## Issues Encountered

| Issue | Resolution |
|-------|------------|
| PEP 668 blocks pip install | Migrated through pip → pipx → venv (final solution) |
| curl\|bash stdin conflict | Read prompts from `/dev/tty` |
| Hardcoded gitleaks download URL | Dynamic version detection via GitHub API |
| SonarQube Docker-only setups | Three-layer detection: image + container + localhost |

## Next Phase Readiness

**Ready:**
- install.sh is complete and tested — all 7 tools install successfully
- Framework copies to `~/.claude/aegis/`, commands to `~/.claude/commands/aegis/`
- Foundation for Phase 11 (`/aegis:init` + `/aegis:validate`) is in place

**Concerns:**
- AEGIS_BRANCH must be changed to `main` before public release
- SonarQube Docker scanner verification depends on `sonar-scanner --version` vs Docker image — edge case handled but worth monitoring

**Blockers:**
- None

---
*Phase: 10-install-system, Plan: 01*
*Completed: 2026-02-20*
