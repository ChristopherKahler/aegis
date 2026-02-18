---
id: gitleaks
name: Gitleaks
type: secrets_detection
domains_fed: ["04", "05"]
install_required: true
install_command: "See Installation section — go install, GitHub releases, brew, apt, or Docker"
---

## Purpose

Scans git repositories for hardcoded secrets, API keys, tokens, passwords, and credentials. Covers both current working state and full git history (commits, branches). Critical signal source for Security (04 — secrets exposure, credential management) and Compliance (05 — sensitive data in source control, audit trail for secret exposure).

Gitleaks uses regex patterns and entropy analysis to detect over 100 types of secrets including AWS keys, GitHub tokens, private keys, database connection strings, JWT secrets, and custom patterns. History scanning reveals secrets that were committed then removed — which may still be exposed in git history.

Signals are NOT findings. Gitleaks produces evidence that agents interpret.

## Configuration

Gitleaks uses a `.gitleaks.toml` configuration file to customize detection behavior:

- **Custom allowlist rules**: Known safe patterns, test fixtures, documentation examples
- **Path exclusions**: Test fixtures, documentation with example keys, vendor directories
- **Entropy threshold tuning**: Default works well for most repos (5.0 for base64, 3.5 for hex)
- **Custom regex patterns**: Organization-specific secret formats
- **Extend default rules**: Add to built-in detection rather than replacing

**Realistic .gitleaks.toml example:**

```toml
title = "AEGIS Gitleaks Configuration"

# Extend default Gitleaks config instead of replacing
[extend]
useDefault = true

# Custom rules for organization-specific secrets
[[rules]]
id = "custom-internal-api-key"
description = "Internal API Key Pattern"
regex = '''(?i)internal[_-]?api[_-]?key[:\s=]+['"]?([a-z0-9]{32})['"]?'''
keywords = ["internal_api_key", "internal-api-key"]

[[rules]]
id = "custom-service-token"
description = "Service Authentication Token"
regex = '''(?i)service[_-]?token[:\s=]+['"]?([A-Za-z0-9+/]{40,})['"]?'''
keywords = ["service_token", "service-token"]

# Allowlist for known false positives
[allowlist]
description = "Approved exceptions and test fixtures"

# Exclude test directories with intentional fake secrets
paths = [
  '''tests/fixtures/.*''',
  '''test/data/.*''',
  '''.*_test\.go''',
  '''.*\.test\.ts''',
  '''examples/.*''',
  '''docs/.*\.md''',
]

# Regex patterns for known safe values
regexes = [
  '''sk-test-[a-zA-Z0-9]{32}''',  # Example/test Stripe keys in docs
  '''xoxb-000000000000-.*''',     # Example Slack tokens in docs
  '''AKIAIOSFODNN7EXAMPLE''',     # AWS documentation example key
  '''wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY''',  # AWS docs secret
  '''[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}''',  # UUIDs
]

# Specific commits to ignore (e.g., initial test data commit)
commits = [
  # "abc123def456...",
]

# Stopwords to reduce false positives
stopwords = [
  '''example''',
  '''sample''',
  '''placeholder''',
  '''your-key-here''',
  '''replace-me''',
]
```

**Configuration placement:**
- Project root: `.gitleaks.toml` (repository-specific rules)
- Home directory: `~/.gitleaks.toml` (user-wide defaults)
- Priority: Project config overrides user config overrides defaults

## Execution

### Installation Options

**Go install** (cross-platform, requires Go):
```bash
go install github.com/gitleaks/gitleaks/v8@latest
```

**GitHub Releases** (download pre-built binary):
```bash
# Visit: https://github.com/gitleaks/gitleaks/releases
# Download appropriate binary for your OS/architecture
# Example for Linux:
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.1/gitleaks_8.18.1_linux_x64.tar.gz
tar -xzf gitleaks_8.18.1_linux_x64.tar.gz
sudo mv gitleaks /usr/local/bin/
```

**Homebrew** (macOS):
```bash
brew install gitleaks
```

**APT/Debian** (Linux):
```bash
# Available via package managers on some distributions
sudo apt install gitleaks
```

**Docker** (no local installation):
```bash
docker pull zricethezav/gitleaks:latest
```

### Scan Commands

**Primary (current working state):**
```bash
gitleaks detect \
  --source {target_path} \
  --report-format json \
  --report-path {output_dir}/gitleaks-results.json \
  --verbose
```

**Full git history scan:**
```bash
gitleaks detect \
  --source {target_path} \
  --report-format json \
  --report-path {output_dir}/gitleaks-history-results.json \
  --log-opts="--all" \
  --verbose
```

**Docker variant (current state):**
```bash
docker run --rm \
  -v {target_path}:/target \
  zricethezav/gitleaks:latest detect \
  --source /target \
  --report-format json \
  --report-path /target/.aegis/signals/gitleaks-results.json \
  --verbose
```

**Docker variant (full history):**
```bash
docker run --rm \
  -v {target_path}:/target \
  zricethezav/gitleaks:latest detect \
  --source /target \
  --report-format json \
  --report-path /target/.aegis/signals/gitleaks-history-results.json \
  --log-opts="--all" \
  --verbose
```

**Pre-commit hook mode** (prevents new secrets):
```bash
gitleaks protect --staged --verbose
```

### Parameters

| Parameter | Purpose | Required | Default |
|-----------|---------|----------|---------|
| `--source` | Path to repository to scan | Yes | Current directory |
| `--report-format` | Output format (json, csv, sarif) | No | json |
| `--report-path` | Output file path | No | stdout |
| `--config` | Path to .gitleaks.toml | No | Auto-detect or defaults |
| `--verbose` | Detailed logging output | No | false |
| `--log-opts` | Git log options (e.g., "--all" for full history) | No | HEAD only |
| `--redact` | Redact secrets in output | No | true (always on v8+) |
| `--no-git` | Scan directory without requiring .git | No | false |
| `--baseline-path` | Ignore findings in baseline file | No | None |

### Runtime Expectations

- **Current state scan**: <1 minute for typical repositories
- **Full history scan**: 5-30 minutes depending on:
  - Repository age (years of commit history)
  - Total commits (hundreds vs. thousands)
  - Number of files and branches
  - Disk I/O performance

**Performance notes:**
- History scans are I/O intensive (reading all commit objects)
- Docker adds ~10-20% overhead vs. native binary
- Large monorepos (>10k commits) may require 30+ minutes for full history

## Output Format

Gitleaks outputs a JSON array of findings. Each finding contains detailed context about the detected secret, including git history metadata.

**Example output structure:**

```json
[
  {
    "Description": "AWS Access Key",
    "StartLine": 23,
    "EndLine": 23,
    "StartColumn": 15,
    "EndColumn": 35,
    "Match": "AKIA****************",
    "Secret": "AKIA****************",
    "File": "src/config/aws.ts",
    "SymlinkFile": "",
    "Commit": "a3f8d92c1e5b4a6d7f8e9c0b1a2d3e4f5a6b7c8d",
    "Entropy": 3.8954,
    "Author": "developer@example.com",
    "Email": "developer@example.com",
    "Date": "2025-11-15T14:32:10Z",
    "Message": "Add AWS configuration for S3 uploads",
    "Tags": [],
    "RuleID": "aws-access-token",
    "Fingerprint": "a3f8d92c1e5b4a6d7f8e9c0b1a2d3e4f5a6b7c8d:src/config/aws.ts:aws-access-token:23"
  },
  {
    "Description": "Generic API Key",
    "StartLine": 8,
    "EndLine": 8,
    "StartColumn": 18,
    "EndColumn": 68,
    "Match": "api_key = \"sk_live_********************\"",
    "Secret": "sk_live_********************",
    "File": "backend/payments/stripe.py",
    "SymlinkFile": "",
    "Commit": "b7e4f1a9d8c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9",
    "Entropy": 4.2156,
    "Author": "backend-dev",
    "Email": "backend@example.com",
    "Date": "2025-09-22T09:17:43Z",
    "Message": "Integrate Stripe payment processing",
    "Tags": [],
    "RuleID": "generic-api-key",
    "Fingerprint": "b7e4f1a9d8c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9:backend/payments/stripe.py:generic-api-key:8"
  },
  {
    "Description": "Private Key",
    "StartLine": 1,
    "EndLine": 27,
    "StartColumn": 1,
    "EndColumn": 64,
    "Match": "-----BEGIN RSA PRIVATE KEY-----\nMIIE...",
    "Secret": "-----BEGIN RSA PRIVATE KEY-----\nMIIE...",
    "File": "deploy/ssh/id_rsa",
    "SymlinkFile": "",
    "Commit": "2c8f9e1b3a7d4c6f8e0a9b1c2d3e4f5a6b7c8d9e",
    "Entropy": 5.1234,
    "Author": "devops",
    "Email": "devops@example.com",
    "Date": "2024-03-10T11:45:22Z",
    "Message": "Add deployment keys (REMOVED IN LATER COMMIT)",
    "Tags": [],
    "RuleID": "private-key",
    "Fingerprint": "2c8f9e1b3a7d4c6f8e0a9b1c2d3e4f5a6b7c8d9e:deploy/ssh/id_rsa:private-key:1"
  }
]
```

**Field descriptions:**

- **Description**: Human-readable rule name (e.g., "AWS Access Key", "GitHub Token")
- **File**: Relative path to file containing the secret
- **StartLine/EndLine**: Line numbers where secret appears
- **StartColumn/EndColumn**: Character positions within the line
- **Match**: Redacted preview of the matched pattern (shows context, not full secret)
- **Secret**: Redacted secret value (always redacted in v8+)
- **Commit**: Git SHA of commit that introduced the secret
- **Author/Email**: Commit author information
- **Date**: Timestamp of the commit
- **Message**: Git commit message
- **RuleID**: Internal rule identifier for the detection pattern
- **Entropy**: Shannon entropy score (measures randomness, higher = more likely real secret)
- **Fingerprint**: Unique identifier for deduplication (commit:file:rule:line)

**Historical vs. current findings:**
- Findings with commits matching current HEAD: Present in working state
- Findings with older commits not in HEAD: Historical exposure (removed but in git history)

## Normalization

AEGIS transforms Gitleaks output into normalized signals for agent consumption.

### Field Mapping

| AEGIS Field | Source | Transformation |
|-------------|--------|----------------|
| `signal_id` | Generated | `S-GL-{NNN}` (sequential numbering) |
| `source_tool` | Static | `gitleaks` |
| `source_rule` | `RuleID` | Direct mapping (e.g., "aws-access-token") |
| `location` | `File`, `StartLine`, `EndLine` | `{File}:{StartLine}-{EndLine}` |
| `severity` | `RuleID` | Rule-based mapping (see table below) |
| `confidence_estimate` | `Entropy`, `RuleID` | Detection method heuristic (see below) |
| `blast_radius` | `RuleID` | Secret type inference (see below) |
| `domain_relevance` | `RuleID`, `File` | All → "04", context-dependent → also "05" |
| `raw_output` | Full finding | Complete JSON object preserved |
| `enrichment` | `Commit`, `Date` | Historical exposure flag, commit metadata |

### Severity Mapping

All Gitleaks findings map to high or critical severity — secrets are inherently high-risk.

| Secret Type | Severity | Examples |
|-------------|----------|----------|
| Cloud provider keys | critical | AWS keys, GCP service accounts, Azure storage keys |
| Database credentials | critical | PostgreSQL passwords, MongoDB connection strings, Redis auth |
| Private keys | critical | RSA/SSH private keys, TLS certificates, JWT signing keys |
| API tokens | high | GitHub PATs, Stripe API keys, Slack tokens, generic API keys |
| Generic passwords | high | Hardcoded passwords, basic auth credentials |
| Service secrets | high | JWT secrets, session secrets, encryption keys |

### Confidence Estimate

Based on detection method and entropy:

| Condition | Confidence | Rationale |
|-----------|------------|-----------|
| Regex match + entropy ≥ 4.5 | high | Strong pattern + high randomness |
| Regex match + entropy 3.5-4.5 | high | Pattern match with moderate randomness |
| Regex match + entropy < 3.5 | medium | Pattern match but low entropy (possible placeholder) |
| Entropy-only detection | low | High randomness without pattern (likely false positive) |
| Known secret format (e.g., "sk_live_") | high | Recognizable vendor-specific prefix |

### Blast Radius

Derived from secret type to estimate potential impact scope:

| Secret Type | Blast Radius | Rationale |
|-------------|--------------|-----------|
| Cloud provider keys | widespread | Full infrastructure access, multi-service permissions |
| Database credentials | widespread | Access to all stored data, potential PII exposure |
| API tokens (third-party) | moderate | Service-level access, limited to vendor API scope |
| Generic passwords | localized | Unknown scope, likely single-service or user account |
| Private keys (deployment) | widespread | Server access, potential lateral movement |
| JWT secrets | moderate | Session hijacking, authentication bypass |

### Enrichment Fields

Additional context added during normalization:

- **historical_exposure**: Boolean flag — `true` if secret detected in git history but not in current HEAD
- **first_seen**: Date of earliest commit containing the secret
- **last_seen**: Date of latest commit (current HEAD date if still present)
- **commit_count**: Number of commits where secret appears (if same secret in multiple commits)
- **author_email**: Commit author email (for accountability, not blame)
- **removal_status**: `"active"` (in HEAD), `"removed"` (history only), or `"modified"` (changed between commits)

### Deduplication Strategy

**Same secret in multiple commits** = single signal with metadata:
- Use earliest commit date as `first_seen`
- Use latest commit date as `last_seen`
- Increment `commit_count`
- List all affected commits in enrichment
- Primary `Fingerprint` uses earliest commit SHA

**Example deduplicated signal:**
```json
{
  "signal_id": "S-GL-042",
  "source_tool": "gitleaks",
  "source_rule": "aws-access-token",
  "location": "config/aws.js:15-15",
  "severity": "critical",
  "confidence_estimate": "high",
  "blast_radius": "widespread",
  "domain_relevance": ["04"],
  "enrichment": {
    "historical_exposure": false,
    "first_seen": "2024-08-12T10:23:45Z",
    "last_seen": "2025-11-15T14:32:10Z",
    "commit_count": 3,
    "commits": [
      "2c8f9e1b3a7d4c6f8e0a9b1c2d3e4f5a6b7c8d9e",
      "5a3d7f9c1e4b8a6d2f0e9c8b7a6f5e4d3c2b1a0",
      "a3f8d92c1e5b4a6d7f8e9c0b1a2d3e4f5a6b7c8d"
    ],
    "removal_status": "active"
  },
  "raw_output": { /* full Gitleaks finding */ }
}
```

### Critical Normalization Rule

**AEGIS signals MUST NEVER contain actual secret values.** Gitleaks automatically redacts secrets in v8+, but normalization layer must verify:
- `Match` field is redacted (asterisks or truncated)
- `Secret` field is redacted
- No raw secret values in `enrichment` metadata
- If unredacted output detected, apply additional redaction before signal creation

## Limitations

### Cannot Detect

Gitleaks is limited to scanning git-tracked text files and cannot detect secrets in:

1. **Compiled binaries or encrypted configuration files**: Secrets embedded in .class, .jar, .exe, .so, or encrypted vaults
2. **Environment variables not committed to source control**: Correctly externalized secrets (e.g., `export AWS_KEY=...` in shell, not in repo)
3. **External secret management systems**: HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager (these are correct practices, not gaps)
4. **Container images not in git**: Secrets baked into Docker images via layers not tracked in repository
5. **Non-git communication channels**: Secrets shared via Slack, email, wikis, Jira comments, documentation systems
6. **Runtime-generated secrets**: API keys fetched from services at application startup, temporary credentials
7. **Obfuscated or encoded secrets**: Base64/hex-encoded strings that don't match patterns, split across variables

### False Positives

Gitleaks may flag non-sensitive data that matches secret patterns:

1. **Example/documentation API keys**: README files with `"your-api-key-here"` or `"sk-test-xxxx"` placeholders
2. **High-entropy non-secrets**: UUIDs, SHA checksums, content hashes, base64-encoded images, cryptographic nonces
3. **Test fixture secrets**: Intentionally fake credentials in test suites (e.g., `"password123"`, `"fake-key-for-testing"`)
4. **Package lock file hashes**: npm/yarn integrity checksums, git submodule SHAs, vendor lock files
5. **Encoded binary data**: Serialized protocol buffers, msgpack data, compressed archives as text
6. **Random identifiers**: Transaction IDs, request IDs, session tokens that aren't reusable secrets

**Mitigation**: Use `.gitleaks.toml` allowlists to suppress known false positives while preserving detection coverage.

### False Negatives

Gitleaks may miss real secrets that evade detection patterns:

1. **Custom secret formats**: Organization-specific API key patterns not in default rules (requires custom regex rules)
2. **Secrets committed then removed**: Only caught with `--log-opts="--all"` full history scan (not default behavior)
3. **Split or obfuscated secrets**: String concatenation (`"sk_" + "live_" + key_suffix`), multi-variable composition
4. **Binary files**: Secrets in .zip, .pdf, .docx, images (Gitleaks scans text, skips binaries)
5. **Low-entropy secrets**: Simple passwords like `"admin123"` that don't trigger entropy thresholds
6. **Secrets in non-standard encodings**: ROT13, XOR-encoded, custom cipher text
7. **Comments with credentials**: Secrets in non-code contexts (SQL comments, HTML comments) if pattern doesn't match

**Mitigation**: Combine Gitleaks with code review, security training, and pre-commit hooks to catch secrets before they enter git history.
