---
id: semgrep
name: Semgrep
type: static_analysis
domains_fed: ["01", "03", "04", "05", "06", "09"]
install_required: true
install_command: "See Installation section — pip, brew, or Docker"
---

## Purpose

Pattern-matching static analysis tool producing signals for injection flaws, authentication weaknesses, insecure cryptography, code quality anti-patterns, framework-specific issues, and compliance-relevant patterns. Broadest domain coverage of any AEGIS tool — feeds 6 domains: Architecture (01), Correctness (03), Security (04), Compliance (05), Testing (06), Maintainability (09).

Semgrep matches AST-level patterns, not text — making it more precise than grep-based approaches but limited to pattern-based detection (no data flow analysis in free tier).

**Signals are NOT findings. Semgrep produces evidence that agents interpret.**

## Configuration

### Rule Packs

Configure `.semgrep.yml` with appropriate rule packs for target codebase:

```yaml
rules:
  - id: security-audit
    patterns: p/security-audit
  - id: owasp-top-ten
    patterns: p/owasp-top-ten
  - id: secrets
    patterns: p/secrets
  - id: default
    patterns: p/default
```

**Language-Specific Packs:**
- `p/python` — Python security and quality patterns
- `p/javascript` — JavaScript/Node.js patterns
- `p/typescript` — TypeScript-specific patterns
- `p/java` — Java enterprise patterns
- `p/go` — Go idioms and security
- `p/ruby` — Ruby/Rails patterns

### Filtering and Performance

**Severity Filter:** `--severity ERROR WARNING` (exclude INFO for noise reduction)

**Timeout Settings:** `--timeout 300` for large repos (5 minute timeout per file)

**Exclude Patterns:**
```bash
--exclude test/
--exclude vendor/
--exclude node_modules/
--exclude .venv/
--exclude dist/
--exclude build/
```

**Custom Rules:** Place organization-specific patterns in `.semgrep/` directory at repository root.

### Semgrep Pro vs OSS

**OSS (free tier):**
- Pattern-only matching (single-file AST analysis)
- Public rule packs
- Local execution only

**Pro (paid):**
- Cross-file data flow analysis
- Taint tracking across function boundaries
- Custom rule management platform
- CI/CD integration with policy enforcement

**AEGIS uses OSS tier by default.** Pro-tier signals require explicit configuration.

## Execution

### Installation Options

**pip (cross-platform):**
```bash
pip install semgrep
```

**Homebrew (macOS/Linux):**
```bash
brew install semgrep
```

**Docker (all platforms):**
```bash
docker pull semgrep/semgrep:latest
```

### Primary Command

```bash
semgrep scan \
  --config auto \
  --json \
  --output {output_dir}/semgrep-results.json \
  --severity ERROR WARNING \
  --timeout 300 \
  --exclude test/ \
  --exclude vendor/ \
  --exclude node_modules/ \
  {target_path}
```

### Docker Variant

```bash
docker run --rm \
  -v {target_path}:/src \
  semgrep/semgrep \
  semgrep scan \
    --config auto \
    --json \
    --output /src/.aegis/signals/semgrep-results.json \
    --severity ERROR WARNING \
    --timeout 300 \
    /src
```

### Specific Rule Packs

```bash
semgrep scan \
  --config p/security-audit \
  --config p/owasp-top-ten \
  --config p/secrets \
  --json \
  --output {output_dir}/semgrep-results.json \
  {target_path}
```

### Parameters

| Flag | Description | Default |
|------|-------------|---------|
| `--config` | Rule pack or config file (auto, p/security-audit, .semgrep.yml) | auto |
| `--json` | Output in JSON format | text |
| `--output` | Path to output file | stdout |
| `--severity` | Filter by severity (ERROR, WARNING, INFO) | all |
| `--timeout` | Max seconds per file | 30 |
| `--exclude` | Glob patterns to exclude | none |
| `--max-memory` | Memory limit in MB | 5000 |
| `--jobs` | Parallel jobs (0 = auto) | 0 |
| `--verbose` | Detailed progress output | false |
| `--metrics off` | Disable anonymous telemetry | on |

### Runtime Expectations

- **Small repos (<10k lines):** 30-60 seconds
- **Medium repos (10k-100k lines):** 2-5 minutes
- **Large repos (100k-500k lines):** 5-15 minutes
- **Monorepos (500k+ lines):** 15-30+ minutes

Runtime scales linearly with code size and rule count. Use `--jobs` flag to parallelize on multi-core systems.

## Output Format

Semgrep produces JSON output with the following structure:

```json
{
  "results": [
    {
      "check_id": "python.django.security.injection.sql.sql-injection-using-raw",
      "path": "app/views/user.py",
      "start": {
        "line": 42,
        "col": 12,
        "offset": 1024
      },
      "end": {
        "line": 42,
        "col": 58,
        "offset": 1070
      },
      "extra": {
        "message": "Detected SQL statement that is tainted by user input. This could lead to SQL injection if variables in the SQL statement are not properly sanitized.",
        "severity": "ERROR",
        "metadata": {
          "cwe": ["CWE-89: SQL Injection"],
          "owasp": ["A03:2021 - Injection"],
          "category": "security",
          "technology": ["django"],
          "confidence": "HIGH",
          "likelihood": "HIGH",
          "impact": "HIGH",
          "references": [
            "https://owasp.org/www-community/attacks/SQL_Injection",
            "https://docs.djangoproject.com/en/4.0/topics/security/#sql-injection-protection"
          ]
        },
        "fingerprint": "e7d2f5a8_1",
        "lines": "    results = User.objects.raw(f\"SELECT * FROM users WHERE username='{username}'\")"
      }
    },
    {
      "check_id": "python.flask.security.audit.hardcoded-secret-key",
      "path": "config/settings.py",
      "start": {
        "line": 18,
        "col": 1,
        "offset": 456
      },
      "end": {
        "line": 18,
        "col": 52,
        "offset": 507
      },
      "extra": {
        "message": "Hardcoded Flask SECRET_KEY detected. This is a security risk because the key is visible in source code.",
        "severity": "WARNING",
        "metadata": {
          "cwe": ["CWE-798: Use of Hard-coded Credentials"],
          "owasp": ["A02:2021 - Cryptographic Failures"],
          "category": "security",
          "technology": ["flask"],
          "confidence": "MEDIUM",
          "likelihood": "MEDIUM",
          "impact": "HIGH",
          "references": [
            "https://flask.palletsprojects.com/en/2.0.x/config/#SECRET_KEY"
          ]
        },
        "fingerprint": "a3c9d1b2_1",
        "lines": "app.config['SECRET_KEY'] = 'my-super-secret-key-12345'"
      }
    },
    {
      "check_id": "python.lang.correctness.useless-eqeq.useless-eqeq",
      "path": "utils/validators.py",
      "start": {
        "line": 67,
        "col": 8,
        "offset": 2048
      },
      "end": {
        "line": 67,
        "col": 20,
        "offset": 2060
      },
      "extra": {
        "message": "Comparison using 'is' instead of '==' for value comparison. Use '==' for value equality checks.",
        "severity": "WARNING",
        "metadata": {
          "category": "correctness",
          "technology": ["python"],
          "confidence": "HIGH",
          "likelihood": "MEDIUM",
          "impact": "LOW",
          "references": [
            "https://docs.python.org/3/reference/expressions.html#is-not"
          ]
        },
        "fingerprint": "f8e4b6c3_1",
        "lines": "    if value is True:"
      }
    }
  ],
  "errors": [],
  "paths": {
    "scanned": [
      "app/",
      "config/",
      "utils/"
    ],
    "_comment": "paths/scanned not used in normalization"
  },
  "version": "1.45.0"
}
```

## Normalization

AEGIS normalizes Semgrep results into standardized signal records using the following field mapping:

| Semgrep Field | AEGIS Field | Transformation |
|---------------|-------------|----------------|
| `check_id` | `source_rule` | Direct copy |
| `path` | `file_path` | Prepend repo root if relative |
| `start.line` + `end.line` | `location` | Format: "L{start}-L{end}" or "L{start}" if single line |
| `extra.message` | `raw_output` | Direct copy |
| `extra.severity` | `severity` | ERROR→high, WARNING→medium, INFO→low |
| `extra.metadata.confidence` | `confidence_estimate` | HIGH→high, MEDIUM→medium, LOW→low, null→medium |
| `extra.metadata.cwe` | `references.cwe` | Extract first CWE-NNN value |
| `extra.metadata.owasp` | `references.owasp` | Direct copy |
| `extra.fingerprint` | `dedup_key` | Combine with check_id: "{check_id}:{fingerprint}" |
| — | `source_tool` | Static: "semgrep" |
| — | `signal_id` | Pattern: "S-SMG-{NNN}" (sequential) |

### Domain Relevance Mapping

Derive `domain_relevance` array from `check_id` prefix or metadata tags:

| Pattern | Domains |
|---------|---------|
| `*.security.*` or `category: security` | ["04"] (Security) |
| `*.audit.*` or `category: audit` | ["05"] (Compliance) |
| `*.correctness.*` or `category: correctness` | ["03"] (Correctness) |
| `*.performance.*` or `category: performance` | ["09"] (Maintainability) |
| `*.testing.*` or `category: testing` | ["06"] (Testing) |
| `*.architecture.*` or `category: design` | ["01"] (Architecture) |
| Multiple tags | Multiple domains |

### Blast Radius Estimation

Default to **"localized"** (single file impact), elevate based on file context:

- **"localized"**: Default for most findings (single file)
- **"moderate"**: Findings in shared utilities, libraries, middleware, base classes
- **"widespread"**: Findings in authentication, authorization, core framework configuration

Path-based heuristics:
- `**/auth/*`, `**/security/*`, `**/middleware/*` → moderate
- `**/config/*`, `**/settings/*`, `**/__init__.py` → moderate to widespread
- `**/lib/*`, `**/utils/*`, `**/helpers/*` → moderate

### Deduplication Rules

**Same signal:** `check_id` + `file_path` + `start.line` match

**Fingerprint collision:** Semgrep may assign same fingerprint to structurally identical issues in different locations. Use full dedup key: `{check_id}:{file_path}:{start.line}:{fingerprint}`.

### Severity Normalization Notes

Semgrep severity is **rule-relative**, not absolute:
- ERROR = rule author considers this high-impact
- WARNING = rule author considers this medium-impact
- INFO = rule author considers this low-impact or informational

AEGIS agents should consider context (blast radius, exploit difficulty) when elevating/downgrading severity during interpretation.

## Limitations

### Cannot Detect (Pattern-Only Analysis)

1. **Business logic flaws**: Semgrep matches code patterns, not business intent. Cannot detect authorization bypass via valid code paths or incorrect state machine transitions.

2. **Runtime-only vulnerabilities**: Race conditions, timing attacks, memory corruption, integer overflow (in untyped languages) require dynamic analysis.

3. **Data flow across ORMs**: Free tier cannot track taint through ORM query methods with custom SQL fragments or complex query builders.

4. **Cross-file data flow in complex call chains**: OSS tier is single-file only. Taint tracking stops at function boundaries unless Pro tier is enabled.

5. **Dynamically generated code**: Template strings, eval(), exec(), code generation frameworks produce patterns invisible to static AST analysis.

6. **Configuration-based vulnerabilities**: Cloud infrastructure misconfigurations, IAM policy errors, deployment configuration issues are outside Semgrep's scope.

### False Positives (Overcollection)

1. **Test fixtures with intentional vulnerabilities**: Security training code, test cases for vulnerability scanners, example exploit code flagged as real vulnerabilities.

2. **High-entropy non-secret constants**: UUIDs, cryptographic hashes, example data, placeholder values flagged by secrets detection rules.

3. **Documentation and comments**: Code examples in docstrings, commented-out legacy code, tutorial snippets embedded in comments.

4. **Dead code paths**: Unreachable branches, deprecated functions, feature-flagged code that contains flagged patterns but never executes in production.

5. **False taint propagation**: Variables reassigned to safe values after initial taint, sanitization via non-standard functions not recognized by rules.

### False Negatives (Undercollection)

1. **Indirect variable concatenation**: Injection via intermediate variable assignment across multiple functions: `x = user_input; y = "SELECT * FROM " + x; query(y)`.

2. **Custom authentication schemes**: Non-standard auth implementations, proprietary session management, custom JWT variants not matching known patterns.

3. **Unsupported languages/frameworks**: Semgrep coverage varies by ecosystem. Niche languages, internal frameworks, proprietary DSLs may have minimal rule coverage.

4. **Obfuscated or minified code**: Compressed JavaScript, obfuscated Python, compiled-then-decompiled code breaks AST pattern matching.

5. **Polymorphic vulnerabilities**: Same vulnerability expressed via different syntactic patterns (e.g., SQL injection via format strings, f-strings, %-formatting, or .format() — rules may not cover all variants).

6. **Context-dependent vulnerabilities**: Code safe in one context but dangerous in another (e.g., innerHTML assignment safe for static strings, dangerous for user input — pattern rules cannot distinguish without data flow).
