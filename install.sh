#!/usr/bin/env bash
set -euo pipefail

# ════════════════════════════════════════
# AEGIS Install Script
# ════════════════════════════════════════
#
# Two install modes:
#   Remote:  curl -sSL https://raw.githubusercontent.com/OWNER/aegis/main/install.sh | bash
#   Local:   bash install.sh  (from cloned repo)
#
# Installs AEGIS framework, commands, and OSS analysis tools.

# ── Configuration ─────────────────────

AEGIS_REPO="ChristopherKahler/aegis"
AEGIS_BRANCH="feature/v1-implementation"
AEGIS_HOME="$HOME/.claude/aegis"
AEGIS_COMMANDS="$HOME/.claude/commands/aegis"
AEGIS_VERSION="0.2.0"

# ── Color helpers ──────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()  { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }
bold()  { echo -e "${BOLD}$1${NC}"; }
dim()   { echo -e "${DIM}$1${NC}"; }
header() {
    echo ""
    echo -e "${BOLD}════════════════════════════════════════${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${BOLD}════════════════════════════════════════${NC}"
    echo ""
}

prompt_yn() {
    local msg="$1"
    local default="${2:-n}"
    local reply
    if [[ "$default" == "y" ]]; then
        read -rp "$msg [Y/n]: " reply < /dev/tty
        reply="${reply:-y}"
    else
        read -rp "$msg [y/N]: " reply < /dev/tty
        reply="${reply:-n}"
    fi
    [[ "$reply" =~ ^[Yy]$ ]]
}

# Track tool install results
declare -a TOOLS_INSTALLED=()
declare -a TOOLS_SKIPPED=()
declare -a TOOLS_FAILED=()
SONARQUBE_MODE=""

# ── Detect install mode ───────────────

# AEGIS_SOURCE will point to the directory containing src/ and commands/
AEGIS_SOURCE=""
CLEANUP_DIR=""

detect_mode() {
    # Check if running from a cloned repo (src/ and commands/ exist relative to script)
    local script_dir
    # When piped via curl|bash, BASH_SOURCE[0] is empty or "bash"
    if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "bash" ]]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [[ -d "$script_dir/src" ]] && [[ -d "$script_dir/commands" ]]; then
            AEGIS_SOURCE="$script_dir"
            info "Local repo detected — installing from $script_dir"
            return
        fi
    fi

    # Remote mode — download from GitHub
    echo "Downloading AEGIS v${AEGIS_VERSION} from GitHub..."
    echo ""

    if ! command -v curl &>/dev/null; then
        err "curl is required but not found."
        exit 1
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    CLEANUP_DIR="$tmp_dir"

    local tarball_url="https://github.com/${AEGIS_REPO}/archive/refs/heads/${AEGIS_BRANCH}.tar.gz"

    if ! curl -sSL "$tarball_url" | tar xz -C "$tmp_dir" 2>/dev/null; then
        err "Failed to download AEGIS from GitHub."
        echo "  URL: $tarball_url"
        echo ""
        echo "  Alternatives:"
        echo "    git clone https://github.com/${AEGIS_REPO}.git && cd aegis && bash install.sh"
        rm -rf "$tmp_dir"
        exit 1
    fi

    # tar extracts to {repo}-{branch}/ directory
    local extracted_dir
    extracted_dir="$(ls -d "$tmp_dir"/*/ 2>/dev/null | head -1)"

    if [[ -z "$extracted_dir" ]] || [[ ! -d "$extracted_dir/src" ]]; then
        err "Download succeeded but expected files not found."
        rm -rf "$tmp_dir"
        exit 1
    fi

    AEGIS_SOURCE="$extracted_dir"
    info "Downloaded AEGIS v${AEGIS_VERSION}"
}

cleanup() {
    if [[ -n "$CLEANUP_DIR" ]] && [[ -d "$CLEANUP_DIR" ]]; then
        rm -rf "$CLEANUP_DIR"
    fi
}
trap cleanup EXIT

# ── 1. Pre-flight checks ──────────────

header "AEGIS Installer v${AEGIS_VERSION}"

echo "This script installs the AEGIS codebase auditing framework."
echo ""

# Check Claude Code directory
if [[ ! -d "$HOME/.claude" ]]; then
    err "~/.claude/ directory not found."
    echo "  Claude Code must be installed first."
    echo "  Visit: https://claude.ai/code"
    exit 1
fi
info "Claude Code directory found"

# Detect local vs remote and set AEGIS_SOURCE
detect_mode

# Verify source has what we need
if [[ ! -d "$AEGIS_SOURCE/src" ]] || [[ ! -d "$AEGIS_SOURCE/commands" ]]; then
    err "AEGIS source missing src/ or commands/ directory."
    exit 1
fi
info "AEGIS source verified"

# Check for existing installation
SKIP_FRAMEWORK=false
SKIP_COMMANDS=false
if [[ -d "$AEGIS_HOME" ]] || [[ -d "$AEGIS_COMMANDS" ]]; then
    echo ""
    warn "Existing AEGIS installation detected."
    [[ -d "$AEGIS_HOME" ]] && dim "  Framework: $AEGIS_HOME"
    [[ -d "$AEGIS_COMMANDS" ]] && dim "  Commands:  $AEGIS_COMMANDS"
    echo ""
    bold "  What would you like to do?"
    echo ""
    echo "  [1] Update everything (framework + commands + tool setup)"
    echo "  [2] Just run tool setup (skip framework/commands)"
    echo "  [3] Cancel"
    echo ""
    read -rp "  Choose [1/2/3]: " reinstall_choice < /dev/tty
    case "$reinstall_choice" in
        1)
            echo ""
            info "Updating framework and commands, then running tool setup."
            ;;
        2)
            SKIP_FRAMEWORK=true
            SKIP_COMMANDS=true
            echo ""
            info "Skipping framework/commands — jumping to tool setup."
            ;;
        *)
            echo "Installation cancelled."
            exit 0
            ;;
    esac
    echo ""
fi

# ── 2. Framework installation ─────────

if [[ "$SKIP_FRAMEWORK" == "false" ]]; then
    header "Installing Framework"

    mkdir -p "$AEGIS_HOME"
    cp -r "$AEGIS_SOURCE/src/"* "$AEGIS_HOME/"

    FRAMEWORK_COUNT=$(find "$AEGIS_HOME" -type f | wc -l | tr -d ' ')
    info "Copied $FRAMEWORK_COUNT framework files to ~/.claude/aegis/"
else
    FRAMEWORK_COUNT=$(find "$AEGIS_HOME" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# ── 3. Commands installation ──────────

if [[ "$SKIP_COMMANDS" == "false" ]]; then
    header "Installing Commands"

    mkdir -p "$AEGIS_COMMANDS"
    cp "$AEGIS_SOURCE/commands/"*.md "$AEGIS_COMMANDS/"

    COMMAND_COUNT=$(find "$AEGIS_COMMANDS" -name "*.md" -type f | wc -l | tr -d ' ')
    info "Installed $COMMAND_COUNT slash commands to ~/.claude/commands/aegis/"
    dim "  Commands available: /aegis:audit, /aegis:resume, /aegis:status, /aegis:report"
    dim "  Transform:          /aegis:transform, /aegis:remediate, /aegis:playbook, /aegis:guardrails"
else
    COMMAND_COUNT=$(find "$AEGIS_COMMANDS" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# ── 4. Tool installation (interactive) ─

header "Tool Installation"

echo "AEGIS uses 7 OSS analysis tools for comprehensive auditing."
echo "Each tool is optional — install what you need now, add more later."
echo ""
info "git-history uses built-in git commands — always available."
echo ""
echo "────────────────────────────────────────"
echo ""

# ── Helper: try install methods in order ──

try_install() {
    local name="$1"
    shift
    local methods=("$@")

    for method in "${methods[@]}"; do
        local cmd="${method%%:*}"
        local install_cmd="${method#*:}"

        if command -v "$cmd" &>/dev/null; then
            echo "  Installing via $cmd..."
            local output
            if output=$(eval "$install_cmd" 2>&1); then
                echo "$output" | tail -3
                return 0
            else
                echo "$output" | tail -3
                warn "  $cmd install failed, trying next method..."
            fi
        fi
    done

    err "  No suitable install method found for $name."
    echo "  Try: pipx, brew, or check the tool's documentation."
    return 1
}

# ── SonarQube (special handling) ──

# Scanner CLI installer (shared by Docker and Cloud paths)
install_sonar_scanner() {
    echo "  Installing sonar-scanner CLI..."
    if command -v npm &>/dev/null; then
        if npm install -g sonar-scanner 2>&1 | tail -2; then
            info "sonar-scanner installed via npm"
            return 0
        fi
    fi
    if command -v brew &>/dev/null; then
        if brew install sonar-scanner 2>&1 | tail -2; then
            info "sonar-scanner installed via brew"
            return 0
        fi
    fi
    err "Failed to install sonar-scanner CLI. Need npm or brew."
    return 1
}

# Server choice — extracted so "changed mind" path can skip the disclaimer
sonarqube_server_choice() {
    bold "  SonarQube server options:"
    echo ""
    echo "  [1] Docker (local)"
    echo "      Runs sonarqube:community on localhost:9000"
    echo "      Requires Docker installed and running"
    echo "      ~800MB image download"
    echo "      Server must be running during audits"
    echo ""
    echo "  [2] SonarQube Cloud"
    echo "      Uses sonarcloud.io (free for public repos)"
    echo "      Requires account + authentication token"
    echo "      No local server needed"
    echo "      Token configuration guided after install"
    echo ""

    local choice
    read -rp "  Choose [1/2]: " choice < /dev/tty

    case "$choice" in
        1)
            SONARQUBE_MODE="docker"
            echo ""
            if ! command -v docker &>/dev/null; then
                err "Docker not found. Install Docker first, then re-run install.sh."
                TOOLS_FAILED+=("sonarqube")
                return
            fi
            if ! docker info &>/dev/null 2>&1; then
                err "Docker daemon not running. Start Docker, then re-run install.sh."
                TOOLS_FAILED+=("sonarqube")
                return
            fi

            echo "  Pulling SonarQube Community image..."
            if ! docker pull sonarqube:community; then
                err "Failed to pull SonarQube image."
                TOOLS_FAILED+=("sonarqube")
                return
            fi
            info "SonarQube server image pulled"

            if ! install_sonar_scanner; then
                TOOLS_FAILED+=("sonarqube")
                return
            fi

            echo ""
            info "SonarQube (Docker local) installed"
            dim "  Start server: docker run -d --name sonarqube -p 9000:9000 sonarqube:community"
            dim "  Server must be running before AEGIS audit."
            dim "  Default credentials: admin / admin"
            dim "  Dashboard: http://localhost:9000"
            TOOLS_INSTALLED+=("sonarqube")
            ;;
        2)
            SONARQUBE_MODE="cloud"
            echo ""
            if ! install_sonar_scanner; then
                TOOLS_FAILED+=("sonarqube")
                return
            fi

            echo ""
            info "SonarQube (Cloud) — scanner CLI installed"
            echo ""
            bold "  To configure SonarQube Cloud:"
            echo "  1. Create account at https://sonarcloud.io"
            echo "  2. Generate token at https://sonarcloud.io/account/security"
            echo "  3. Set environment variable: export SONAR_TOKEN=your-token"
            echo "  4. Create sonar-project.properties in your target project"
            dim "  Run /aegis:validate after setup to verify connection."
            TOOLS_INSTALLED+=("sonarqube")
            ;;
        *)
            warn "Invalid choice. Skipping SonarQube."
            TOOLS_SKIPPED+=("sonarqube")
            ;;
    esac
}

# Main SonarQube flow — disclaimer + install or skip-with-confirmation
install_sonarqube() {
    echo -e "${BOLD}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}│  SONARQUBE — Important Context                      │${NC}"
    echo -e "${BOLD}│${NC}                                                     ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  Unlike other AEGIS tools, SonarQube requires TWO   ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  components:                                        ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}                                                     ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  1. ${BOLD}Scanner CLI${NC} — analyzes your code                ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  2. ${BOLD}Server${NC} — stores rules, runs analysis, serves    ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}     results via API                                 ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}                                                     ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  The scanner ${RED}CANNOT${NC} work without a server.          ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  Server options: Docker (local) or SonarQube Cloud. ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}                                                     ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  SonarQube uniquely provides:                       ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  ${GREEN}•${NC} Code complexity metrics (cyclomatic, cognitive)  ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  ${GREEN}•${NC} Duplication detection                            ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  ${GREEN}•${NC} Code smell classification                        ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  ${GREEN}•${NC} Quality gate enforcement                         ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  ${GREEN}•${NC} Technical debt estimation                        ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}                                                     ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  These are ${YELLOW}NOT covered${NC} by any other AEGIS tool.     ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  Semgrep covers security/correctness overlap, but   ${BOLD}│${NC}"
    echo -e "${BOLD}│${NC}  NOT complexity, duplication, or debt metrics.       ${BOLD}│${NC}"
    echo -e "${BOLD}└─────────────────────────────────────────────────────┘${NC}"
    echo ""

    if prompt_yn "Install SonarQube?"; then
        echo ""
        sonarqube_server_choice
    else
        echo ""
        echo -e "  ${YELLOW}⚠ Skipping SonarQube means AEGIS loses:${NC}"
        echo "    • Code complexity analysis (cyclomatic, cognitive)"
        echo "    • Duplication detection across codebase"
        echo "    • Code smell classification and debt estimation"
        echo "    • Quality gate enforcement"
        echo ""
        echo "  Domains 01 (Architecture), 03 (Correctness), 06 (Testing),"
        echo "  09 (Maintainability) will have REDUCED signal coverage."
        echo "  Semgrep still covers security and pattern-based analysis."
        echo ""
        dim "  You can install SonarQube later by re-running install.sh."
        echo ""

        if prompt_yn "  Are you sure you want to skip SonarQube?"; then
            TOOLS_SKIPPED+=("sonarqube")
            dim "  SonarQube skipped."
        else
            echo ""
            echo "  OK — let's set up SonarQube."
            echo ""
            sonarqube_server_choice
        fi
    fi
}

# ── Standard tool installer ──

install_tool() {
    local name="$1"
    local description="$2"
    shift 2
    local methods=("$@")

    echo ""
    bold "  $name"
    dim "  $description"
    echo ""

    if prompt_yn "  Install $name?"; then
        echo ""
        if try_install "$name" "${methods[@]}"; then
            info "$name installed"
            TOOLS_INSTALLED+=("$name")
        else
            TOOLS_FAILED+=("$name")
        fi
    else
        TOOLS_SKIPPED+=("$name")
        dim "  $name skipped."
    fi
}

# ── Run tool installations ──

install_sonarqube

echo ""
echo "────────────────────────────────────────"

# ── Helper: install Python CLI tool via venv ──
# Creates ~/.local/share/aegis/venvs/{tool}/ with isolated Python env
# Symlinks the binary to ~/.local/bin/{tool}
# Works on any system with python3 — no pip, pipx, or special flags needed

AEGIS_VENVS="$HOME/.local/share/aegis/venvs"
LOCAL_BIN="$HOME/.local/bin"

ensure_local_bin() {
    mkdir -p "$LOCAL_BIN"
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
        export PATH="$LOCAL_BIN:$PATH"
    fi
}

install_python_tool() {
    local tool="$1"
    ensure_local_bin
    mkdir -p "$AEGIS_VENVS"

    echo "  Creating isolated Python environment..."
    if ! python3 -m venv "$AEGIS_VENVS/$tool" 2>&1; then
        err "Failed to create venv. Is python3-venv installed?"
        echo "  Try: sudo apt install python3-venv"
        return 1
    fi

    echo "  Installing $tool (this may take a moment)..."
    if "$AEGIS_VENVS/$tool/bin/pip" install "$tool" 2>&1 | tail -3; then
        # Symlink the binary to ~/.local/bin
        ln -sf "$AEGIS_VENVS/$tool/bin/$tool" "$LOCAL_BIN/$tool"
        if command -v "$tool" &>/dev/null; then
            return 0
        fi
    fi

    err "Failed to install $tool in venv."
    rm -rf "$AEGIS_VENVS/$tool"
    return 1
}

install_tool "semgrep" \
    "Static analysis — security, correctness, code quality patterns (6 domains)" \
    "python3:install_python_tool semgrep" \
    "brew:brew install semgrep"

echo ""
echo "────────────────────────────────────────"

install_tool "trivy" \
    "Vulnerability scanner — OS packages, dependencies, containers, IaC (2 domains)" \
    "curl:ensure_local_bin && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b $LOCAL_BIN" \
    "brew:brew install trivy"

echo ""
echo "────────────────────────────────────────"

install_tool "gitleaks" \
    "Secrets detection — API keys, tokens, passwords in code and history (2 domains)" \
    "curl:ensure_local_bin && curl -sSfL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_8.21.2_linux_x64.tar.gz | tar xz -C $LOCAL_BIN gitleaks" \
    "brew:brew install gitleaks" \
    "go:go install github.com/gitleaks/gitleaks/v8@latest"

echo ""
echo "────────────────────────────────────────"

install_tool "checkov" \
    "Infrastructure-as-Code scanner — Terraform, CloudFormation, K8s (2 domains)" \
    "python3:install_python_tool checkov" \
    "brew:brew install checkov"

echo ""
echo "────────────────────────────────────────"

install_tool "syft" \
    "SBOM generator — software bill of materials for dependency inventory (2 domains)" \
    "curl:ensure_local_bin && curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b $LOCAL_BIN" \
    "brew:brew install syft"

echo ""
echo "────────────────────────────────────────"

install_tool "grype" \
    "Vulnerability scanner — CVE matching against SBOM inventory (2 domains)" \
    "curl:ensure_local_bin && curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b $LOCAL_BIN" \
    "brew:brew install grype"

# ── 5. Post-install verification ──────

header "Verification"

declare -a VERIFY_PASS=()
declare -a VERIFY_FAIL=()

verify_tool() {
    local name="$1"
    local cmd="$2"

    if eval "$cmd" &>/dev/null 2>&1; then
        info "$name — verified"
        VERIFY_PASS+=("$name")
    else
        err "$name — verification failed"
        VERIFY_FAIL+=("$name")
    fi
}

# Always verify git
verify_tool "git-history" "git --version"

# Verify installed tools
for tool in "${TOOLS_INSTALLED[@]}"; do
    case "$tool" in
        sonarqube)
            verify_tool "sonar-scanner" "sonar-scanner --version"
            if [[ "$SONARQUBE_MODE" == "docker" ]]; then
                verify_tool "sonarqube-image" "docker image inspect sonarqube:community"
            fi
            ;;
        semgrep)    verify_tool "semgrep" "semgrep --version" ;;
        trivy)      verify_tool "trivy" "trivy --version" ;;
        gitleaks)   verify_tool "gitleaks" "gitleaks version" ;;
        checkov)    verify_tool "checkov" "checkov --version" ;;
        syft)       verify_tool "syft" "syft version" ;;
        grype)      verify_tool "grype" "grype version" ;;
    esac
done

# ── 6. Summary ────────────────────────

header "AEGIS Installation Complete"

echo -e "  ${BOLD}Framework:${NC}  ~/.claude/aegis/ ($FRAMEWORK_COUNT files)"
echo -e "  ${BOLD}Commands:${NC}   ~/.claude/commands/aegis/ ($COMMAND_COUNT commands)"
echo ""
echo -e "  ${BOLD}Tools:${NC}"

# Show all tools with status
show_tool_status() {
    local name="$1"
    if printf '%s\n' "${TOOLS_INSTALLED[@]}" | grep -qx "$name" 2>/dev/null; then
        echo -e "    ${GREEN}✓${NC} $name (installed)"
    elif printf '%s\n' "${TOOLS_FAILED[@]}" | grep -qx "$name" 2>/dev/null; then
        echo -e "    ${RED}✗${NC} $name (failed)"
    elif printf '%s\n' "${TOOLS_SKIPPED[@]}" | grep -qx "$name" 2>/dev/null; then
        echo -e "    ${DIM}–${NC} $name (skipped)"
    fi
}

show_tool_status "sonarqube"
show_tool_status "semgrep"
show_tool_status "trivy"
show_tool_status "gitleaks"
show_tool_status "checkov"
show_tool_status "syft"
show_tool_status "grype"
echo -e "    ${GREEN}✓${NC} git-history (built-in)"

echo ""
echo "  Installed: ${#TOOLS_INSTALLED[@]}/7  Skipped: ${#TOOLS_SKIPPED[@]}/7  Failed: ${#TOOLS_FAILED[@]}/7"

if [[ ${#VERIFY_FAIL[@]} -gt 0 ]]; then
    echo ""
    warn "Some verifications failed. Run /aegis:validate for troubleshooting."
fi

echo ""
echo -e "  ${BOLD}Next:${NC} Run /aegis:init in your target project to start auditing."
echo ""
echo "════════════════════════════════════════"
