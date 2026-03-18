---
id: sonarqube
name: SonarQube
type: code_quality
domains_fed: ["01", "03", "06", "09"]
install_required: true
install_command: "See Installation section — sonar-scanner CLI + SonarQube server required"
---

# SonarQube Tool Adapter

## Purpose

Code quality platform producing signals for complexity, duplication, code smells, bug patterns, and coverage metrics. Covers cognitive complexity, cyclomatic complexity, duplicated blocks/lines, bug detection patterns, code smell taxonomy, and test coverage gaps.

Feeds domains:
- **Architecture (01)**: Coupling indicators, complexity metrics
- **Correctness (03)**: Bug detection patterns, potential defects
- **Testing (06)**: Coverage metrics, test quality signals
- **Maintainability (09)**: Code smells, duplication, complexity trends

Also feeds Transform agents:
- Complexity metrics → `architectural_tension_input`
- Duplication metrics → `coupling_risk_input`
- Coverage metrics → `regression_probability_input` (inverse)

**Important**: Signals are NOT findings. SonarQube produces evidence that agents interpret within domain context.

---

## Configuration

SonarQube requires both a server instance and scanner CLI for analysis.

### Server Options

**Option 1: SonarQube Community Edition (Self-Hosted)**
- Free and open source
- Docker: `docker run -d --name sonarqube -p 9000:9000 sonarqube:community`
- Direct download: https://www.sonarqube.org/downloads/
- Supports 15+ languages including Java, JavaScript, Python, C#, Go, PHP

**Option 2: SonarCloud (Hosted SaaS)**
- Free for public repositories
- No server installation required
- Access via https://sonarcloud.io
- Configure sonar.host.url=https://sonarcloud.io

### Project Configuration File

Create `sonar-project.properties` in project root:

```properties
# Project identification
sonar.projectKey=my-project-key
sonar.projectName=My Project
sonar.projectVersion=1.0

# Source configuration
sonar.sources=src
sonar.tests=tests
sonar.sourceEncoding=UTF-8

# Server connection
sonar.host.url=http://localhost:9000
sonar.token=${SONAR_TOKEN}

# Language-specific settings (optional)
sonar.java.binaries=target/classes
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.python.coverage.reportPaths=coverage.xml

# Exclusions (optional)
sonar.exclusions=**/vendor/**,**/node_modules/**,**/*.test.js
```

### Quality Profiles

- **Sonar Way** (default): Balanced ruleset for each language
- **Custom profiles**: Configure via SonarQube UI at Administration > Quality Profiles
- Language-specific analyzers with severity levels: BLOCKER, CRITICAL, MAJOR, MINOR, INFO

### Quality Gates

Configure pass/fail thresholds at Project Settings > Quality Gate:
- Coverage < 80%
- Duplicated Lines > 3%
- Maintainability Rating worse than A
- Reliability Rating worse than A
- Security Rating worse than A

---

## Execution

### Installation Options

**Option 1: NPM (Recommended for Node.js projects)**
```bash
npm install -g sonarqube-scanner
```

**Option 2: Docker (Platform-agnostic)**
```bash
# No installation required, run directly
docker run --rm -v $(pwd):/usr/src sonarsource/sonar-scanner-cli
```

**Option 3: Direct Download**
```bash
# Download from https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
# Extract and add bin/ directory to PATH
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856.zip
unzip sonar-scanner-cli-4.8.0.2856.zip
export PATH=$PATH:$PWD/sonar-scanner-4.8.0.2856/bin
```

### Running Analysis

**Primary Command (sonar-scanner CLI)**
```bash
sonar-scanner \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=$SONAR_TOKEN
```

**Docker Variant**
```bash
docker run --rm \
  -e SONAR_HOST_URL="http://host.docker.internal:9000" \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli \
  -Dsonar.projectKey=my-project
```

**With Coverage Reports**
```bash
sonar-scanner \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src \
  -Dsonar.tests=tests \
  -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=$SONAR_TOKEN
```

### Parameters Reference

| Parameter | Description | Required |
|-----------|-------------|----------|
| `sonar.projectKey` | Unique project identifier | Yes |
| `sonar.sources` | Comma-separated source directories | Yes |
| `sonar.host.url` | SonarQube server URL | Yes |
| `sonar.token` | Authentication token (generate in SonarQube UI) | Yes |
| `sonar.tests` | Test source directories | No |
| `sonar.exclusions` | Files to exclude from analysis | No |
| `sonar.java.binaries` | Compiled class files (Java projects) | Conditional |
| `sonar.python.coverage.reportPaths` | Coverage report path (Python) | No |
| `sonar.javascript.lcov.reportPaths` | LCOV coverage report (JavaScript) | No |

**Runtime**: 2-15 minutes depending on project size, language analyzers, and server performance.

### Retrieving Results via Web API

After analysis completes, fetch results using SonarQube REST API:

**1. Issues Endpoint**
```bash
curl -u "$SONAR_TOKEN:" \
  "http://localhost:9000/api/issues/search?componentKeys=my-project&severities=BLOCKER,CRITICAL,MAJOR&ps=500"
```

**2. Measures Endpoint**
```bash
curl -u "$SONAR_TOKEN:" \
  "http://localhost:9000/api/measures/component?component=my-project&metricKeys=complexity,cognitive_complexity,duplicated_lines_density,coverage,bugs,code_smells,vulnerabilities"
```

**3. Quality Gate Status**
```bash
curl -u "$SONAR_TOKEN:" \
  "http://localhost:9000/api/qualitygates/project_status?projectKey=my-project"
```

**Authentication**: Use `SONAR_TOKEN` environment variable (generate at User > My Account > Security > Generate Tokens)

---

## Output Format

### Issues Endpoint Response

```json
{
  "total": 247,
  "p": 1,
  "ps": 500,
  "paging": {
    "pageIndex": 1,
    "pageSize": 500,
    "total": 247
  },
  "issues": [
    {
      "key": "AYcX3mKJQZ8vK4pQxY6L",
      "rule": "javascript:S3776",
      "severity": "CRITICAL",
      "component": "my-project:src/services/paymentProcessor.js",
      "project": "my-project",
      "line": 47,
      "hash": "8b6f3c21a4d5e9f1",
      "textRange": {
        "startLine": 47,
        "endLine": 132,
        "startOffset": 0,
        "endOffset": 5
      },
      "flows": [],
      "status": "OPEN",
      "message": "Refactor this function to reduce its Cognitive Complexity from 42 to the 15 allowed.",
      "effort": "1h30min",
      "debt": "1h30min",
      "author": "john.doe@example.com",
      "tags": ["brain-overload"],
      "type": "CODE_SMELL",
      "scope": "MAIN",
      "creationDate": "2026-02-10T14:23:11+0000",
      "updateDate": "2026-02-10T14:23:11+0000"
    },
    {
      "key": "AYcX3mKJQZ8vK4pQxY6M",
      "rule": "javascript:S1854",
      "severity": "MAJOR",
      "component": "my-project:src/utils/formatter.js",
      "project": "my-project",
      "line": 89,
      "hash": "c7d2a8e4f1b9c5d3",
      "textRange": {
        "startLine": 89,
        "endLine": 89,
        "startOffset": 8,
        "endOffset": 23
      },
      "flows": [],
      "status": "OPEN",
      "message": "Remove this useless assignment to local variable 'tempResult'.",
      "effort": "5min",
      "debt": "5min",
      "author": "jane.smith@example.com",
      "tags": ["unused"],
      "type": "CODE_SMELL",
      "scope": "MAIN",
      "creationDate": "2026-02-10T14:23:11+0000",
      "updateDate": "2026-02-10T14:23:11+0000"
    },
    {
      "key": "AYcX3mKJQZ8vK4pQxY6N",
      "rule": "javascript:S2583",
      "severity": "BLOCKER",
      "component": "my-project:src/controllers/userController.js",
      "project": "my-project",
      "line": 156,
      "hash": "f3e8d9c2b1a7e4d6",
      "textRange": {
        "startLine": 156,
        "endLine": 156,
        "startOffset": 12,
        "endOffset": 42
      },
      "flows": [],
      "status": "OPEN",
      "message": "Change this condition so that it does not always evaluate to 'true'.",
      "effort": "15min",
      "debt": "15min",
      "author": "alice.jones@example.com",
      "tags": ["bug"],
      "type": "BUG",
      "scope": "MAIN",
      "creationDate": "2026-02-10T14:23:11+0000",
      "updateDate": "2026-02-10T14:23:11+0000"
    },
    {
      "key": "AYcX3mKJQZ8vK4pQxY6O",
      "rule": "javascript:S4829",
      "severity": "CRITICAL",
      "component": "my-project:src/api/authHandler.js",
      "project": "my-project",
      "line": 234,
      "hash": "a9c8f7e6d5b4c3d2",
      "textRange": {
        "startLine": 234,
        "endLine": 234,
        "startOffset": 15,
        "endOffset": 58
      },
      "flows": [],
      "status": "OPEN",
      "message": "Make sure that this logger's configuration is safe.",
      "effort": "30min",
      "debt": "30min",
      "author": "bob.wilson@example.com",
      "tags": ["cwe", "owasp-a9", "privacy"],
      "type": "VULNERABILITY",
      "scope": "MAIN",
      "creationDate": "2026-02-10T14:23:11+0000",
      "updateDate": "2026-02-10T14:23:11+0000"
    }
  ],
  "components": [
    {
      "key": "my-project:src/services/paymentProcessor.js",
      "enabled": true,
      "qualifier": "FIL",
      "name": "paymentProcessor.js",
      "longName": "src/services/paymentProcessor.js",
      "path": "src/services/paymentProcessor.js"
    },
    {
      "key": "my-project:src/utils/formatter.js",
      "enabled": true,
      "qualifier": "FIL",
      "name": "formatter.js",
      "longName": "src/utils/formatter.js",
      "path": "src/utils/formatter.js"
    }
  ],
  "rules": [
    {
      "key": "javascript:S3776",
      "name": "Cognitive Complexity of functions should not be too high",
      "lang": "js",
      "status": "READY",
      "langName": "JavaScript"
    },
    {
      "key": "javascript:S1854",
      "name": "Unused assignments should be removed",
      "lang": "js",
      "status": "READY",
      "langName": "JavaScript"
    }
  ]
}
```

### Measures Endpoint Response

```json
{
  "component": {
    "key": "my-project",
    "name": "My Project",
    "qualifier": "TRK",
    "measures": [
      {
        "metric": "complexity",
        "value": "1847",
        "bestValue": false
      },
      {
        "metric": "cognitive_complexity",
        "value": "1243",
        "bestValue": false
      },
      {
        "metric": "duplicated_lines_density",
        "value": "7.8",
        "bestValue": false
      },
      {
        "metric": "coverage",
        "value": "68.3",
        "bestValue": false
      },
      {
        "metric": "bugs",
        "value": "23",
        "bestValue": false
      },
      {
        "metric": "code_smells",
        "value": "187",
        "bestValue": false
      },
      {
        "metric": "vulnerabilities",
        "value": "5",
        "bestValue": false
      },
      {
        "metric": "security_hotspots",
        "value": "12",
        "bestValue": false
      },
      {
        "metric": "duplicated_blocks",
        "value": "34"
      },
      {
        "metric": "ncloc",
        "value": "15623"
      },
      {
        "metric": "reliability_rating",
        "value": "3.0"
      },
      {
        "metric": "security_rating",
        "value": "2.0"
      },
      {
        "metric": "sqale_rating",
        "value": "2.0"
      },
      {
        "metric": "sqale_index",
        "value": "1847"
      }
    ]
  }
}
```

---

## Normalization

Map SonarQube raw output to AEGIS signal schema for domain processing.

### Field Mapping Table

| AEGIS Signal Field | SonarQube Source | Mapping Logic |
|--------------------|------------------|---------------|
| `signal_id` | Generated | Pattern: `S-SQ-{NNN}` (sequential) |
| `source_tool` | Static | Always `"sonarqube"` |
| `raw_severity` | `issue.severity` | Preserve original: BLOCKER, CRITICAL, MAJOR, MINOR, INFO |
| `normalized_severity` | `issue.severity` | Map: BLOCKER→critical, CRITICAL→high, MAJOR→medium, MINOR→low, INFO→informational |
| `rule_id` | `issue.rule` | Direct copy (e.g., "javascript:S3776") |
| `category` | `issue.type` | Map: BUG→correctness, VULNERABILITY→security, CODE_SMELL→maintainability |
| `message` | `issue.message` | Direct copy |
| `file_path` | `issue.component` | Extract path portion after project key |
| `line_start` | `issue.textRange.startLine` | Direct copy (null if file-level issue) |
| `line_end` | `issue.textRange.endLine` | Direct copy (null if file-level issue) |
| `domain_relevance` | Derived from `issue.type` | BUG→[03], VULNERABILITY→[05], CODE_SMELL→[09,01] |
| `confidence_estimate` | `issue.type` + rule reliability | BUG→high, VULNERABILITY→medium, CODE_SMELL→medium (adjustable by rule) |
| `blast_radius` | `issue.textRange` + `issue.scope` | File-level→localized, Cross-file→moderate, Project-level→extensive |
| `effort_minutes` | `issue.effort` | Parse duration string (e.g., "1h30min" → 90) |
| `tags` | `issue.tags` | Direct copy as array |
| `metadata.project_key` | `issue.project` | Store for traceability |
| `metadata.issue_key` | `issue.key` | Store for traceability |
| `metadata.creation_date` | `issue.creationDate` | ISO 8601 timestamp |

### Severity Mapping

| SonarQube Severity | AEGIS Normalized Severity |
|--------------------|---------------------------|
| BLOCKER | critical |
| CRITICAL | high |
| MAJOR | medium |
| MINOR | low |
| INFO | informational |

### Issue Type to Domain Mapping

| SonarQube Type | Primary Domain(s) | Category |
|----------------|-------------------|----------|
| BUG | 03 (Correctness) | correctness |
| VULNERABILITY | 05 (Security) | security |
| CODE_SMELL | 09 (Maintainability), 01 (Architecture) | maintainability |
| SECURITY_HOTSPOT | 05 (Security) | security |

### Metric Signals (Measures Endpoint)

Create aggregate signals from measures endpoint for Transform agent consumption:

| Metric | Signal Type | Transform Input Mapping |
|--------|-------------|-------------------------|
| `complexity` | Complexity | `architectural_tension_input` |
| `cognitive_complexity` | Complexity | `architectural_tension_input` |
| `duplicated_lines_density` | Duplication | `coupling_risk_input` |
| `duplicated_blocks` | Duplication | `coupling_risk_input` |
| `coverage` | Coverage | `regression_probability_input` (inverse: low coverage = high risk) |
| `bugs` | Count | Inform Correctness domain (03) |
| `code_smells` | Count | Inform Maintainability domain (09) |
| `vulnerabilities` | Count | Inform Security domain (05) |

### Normalization Notes

1. **Deduplication**: SonarQube may report same issue across branches. Use `issue.hash` + `issue.component` for deduplication across analyses.

2. **Metric vs Issue Signals**:
   - Issue signals (from `/api/issues/search`) are specific, localized findings
   - Metric signals (from `/api/measures/component`) are aggregate, project-level indicators
   - Both feed domains differently: issues as evidence, metrics as context

3. **Confidence Estimation**:
   - BUG type: High confidence (static analysis proven patterns)
   - VULNERABILITY: Medium confidence (may require runtime context)
   - CODE_SMELL: Medium confidence (subjective, depends on context)
   - Adjust based on rule maturity and false positive history

4. **Transform Change-Risk Mapping**:
   - Complexity metrics (cognitive_complexity, complexity) feed architectural tension calculations
   - Duplication density feeds coupling risk estimation (duplicated code = implicit coupling)
   - Coverage feeds regression probability (inverse relationship: coverage < 70% = high regression risk)

---

## Limitations

### Cannot Detect

1. **Business Logic Errors**: SonarQube detects syntactic and structural issues, not semantic correctness. Cannot validate business rules, domain invariants, or workflow logic correctness.

2. **Runtime-Only Issues**: Cannot detect race conditions, deadlocks, memory leaks, performance bottlenecks, or resource exhaustion that only manifest during execution under specific loads.

3. **Deep Security Vulnerabilities**: Limited to pattern-based security rules. Cannot detect complex vulnerabilities like authentication bypasses, authorization flaws, or cryptographic weaknesses requiring semantic analysis. Use Semgrep or Trivy for deeper security coverage.

4. **Dynamically Generated Code**: Cannot analyze code generated at runtime, macro-expanded code, or template-generated sources that don't exist as static files during scan.

5. **Cross-Service Architectural Issues**: Analyzes single project in isolation. Cannot detect distributed system issues like service coupling, API contract violations, or inter-service dependency cycles.

6. **Configuration Issues**: Limited detection of infrastructure misconfigurations, deployment issues, or environment-specific problems.

### False Positives

1. **Intentional Complexity**: State machines, parsers, protocol implementations, and generated code may legitimately have high cyclomatic/cognitive complexity. Domain context required to distinguish justified complexity.

2. **Duplication in Test Fixtures**: Test data, mock objects, and configuration files often contain intentional duplication for clarity. SonarQube flags these as code smells without test-specific context.

3. **Legacy Code Stability**: Mature, well-tested legacy code with code smells may be low-risk to leave unchanged. SonarQube severity doesn't account for historical stability or cost-of-change.

4. **Language Idioms**: Idiomatic patterns in specific languages (e.g., Python's `__init__` methods, Go's error handling) may trigger generic rules designed for other languages.

### False Negatives

1. **Unsupported Languages**: Limited or no analyzer support for niche languages, DSLs, or newer language versions. JavaScript/TypeScript/Java have strong support; Rust, Elixir, Clojure have gaps.

2. **Logic Errors with Valid Syntax**: Type-safe code with incorrect business logic passes all checks. Example: `if (user.age > 18)` when requirement is `>= 18`.

3. **Multi-Repository Architectural Issues**: Cannot detect cross-repo coupling, duplicated logic across microservices, or inconsistent patterns across organizational boundaries.

4. **Performance Anti-Patterns**: Misses N+1 queries, inefficient algorithms with correct syntax, or resource-intensive operations that don't violate structural rules.

5. **Subtle Concurrency Issues**: Cannot detect most thread-safety issues, visibility problems, or lock contention patterns that require runtime analysis or formal verification.

6. **Context-Dependent Vulnerabilities**: Misses vulnerabilities that depend on deployment context, data flow across services, or runtime configuration values.
