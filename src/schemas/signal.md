---
id: signal
name: Signal
version: 1.0.0
used_by:
  - tool-adapters
  - principal-engineer
  - architect
  - data-engineer
  - security-engineer
  - compliance-officer
  - senior-app-engineer
  - sre
  - performance-engineer
  - test-engineer
  - staff-engineer
  - reality-gap-analyst
  - devils-advocate
---

## Purpose

A Signal is a normalized tool output — the bridge between heterogeneous analysis tools and structured agent reasoning. Tools speak different severity languages: SonarQube uses "blocker/critical/major/minor/info", Semgrep uses "ERROR/WARNING/INFO", Trivy uses "CRITICAL/HIGH/MEDIUM/LOW/UNKNOWN", Gitleaks uses "match/no-match". Without normalization, agents cannot compare or correlate signals across tools.

The signal schema converts all tool output into four normalized dimensions (severity, confidence estimate, blast radius, domain relevance) while preserving the original tool output for audit trail integrity. Signals are Phase 1 output — raw evidence gathered before any agent reasoning begins. Agents consume signals as input to their domain audits, producing @schema:finding instances as output.

Signals are NOT findings. A signal is evidence. A finding is a reasoned conclusion built on evidence. The separation is fundamental to AEGIS's epistemic architecture.

## Template

```markdown
### {signal_id}

**Source tool:** {source_tool}
**Source rule:** {source_rule}
**Location:** {location}
**Category:** {signal_category}

#### Normalized Dimensions

| Dimension | Value |
|-----------|-------|
| Severity | {severity} |
| Confidence estimate | {confidence_estimate} |
| Blast radius | {blast_radius} |
| Domain relevance | {domain_relevance} |

#### Raw Output

**Raw severity:** {raw_severity}
**Raw output ref:** {raw_output_ref}
**Normalization notes:** {normalization_notes}
```

## Field Reference

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `signal_id` | string | yes | Unique identifier across the audit. | Pattern: `S-{TTT}-{NNN}` where TTT is 2-4 character tool abbreviation, NNN is three-digit sequence. Examples: `S-SMG-001` (Semgrep), `S-SQ-001` (SonarQube), `S-TRV-001` (Trivy), `S-GL-001` (Gitleaks), `S-CHK-001` (Checkov), `S-GRP-001` (Grype), `S-GIT-001` (git mining) |
| `source_tool` | enum | yes | Tool that produced this signal. | `sonarqube`, `semgrep`, `trivy`, `gitleaks`, `checkov`, `syft`, `grype`, `git-mining`, `manual-review` |
| `source_rule` | string | yes | The specific rule, check, or policy that fired. | Tool-specific rule identifier. Examples: `python.security.sql-injection` (Semgrep), `S2068` (SonarQube), `CVE-2024-1234` (Trivy/Grype). |
| `location` | string | yes | Where the signal was detected. | File path + line range, container image + layer, dependency name + version, or config path. Must be specific enough to locate. |
| `signal_category` | enum | yes | Which of the 6 evidence dimensions this signal belongs to. | `structure`, `behavior`, `history`, `dependencies`, `policy_posture`, `runtime_contracts` |
| `severity` | enum | yes | Normalized AEGIS severity. | `critical`, `high`, `medium`, `low`, `informational` |
| `confidence_estimate` | enum | yes | Tool-level confidence in the signal's accuracy. This is a rough estimate, not the full @schema:confidence vector (agents compute that during analysis). | `high`, `medium`, `low` |
| `blast_radius` | enum | yes | Estimated scope of impact if this signal represents a real issue. | `localized`, `service_level`, `systemic`, `org_wide` |
| `domain_relevance` | list of strings | yes | Domain numbers this signal is relevant to. | At least one value. Each must be a two-digit domain number `00` through `13`. |
| `raw_severity` | string | yes | The original severity string from the tool, preserved verbatim. | Free text — exact value the tool reported. |
| `raw_output_ref` | string | yes | Path to the raw tool output file. | File path within the `.aegis/signals/` directory. |
| `normalization_notes` | string | no | Context about how raw values were mapped to AEGIS values. | Useful when mapping is ambiguous (e.g., SonarQube "blocker" maps to AEGIS "critical" but with context-dependent confidence). |

## Validation Rules

1. **Unique ID:** `signal_id` must be unique across the entire audit.
2. **Valid tool:** `source_tool` must match a configured tool adapter in the AEGIS installation.
3. **AEGIS severity values:** `severity` must use the 5-value AEGIS enum. Raw tool severities are preserved in `raw_severity` but never used directly by agents.
4. **Domain relevance required:** `domain_relevance` must contain at least one valid domain number (00-13).
5. **Raw preservation:** `raw_severity` must be preserved exactly as the tool reported it. Discarding raw values breaks audit trail integrity.
6. **Signal is not finding:** Signals must not contain interpretation, risk statements, or judgment. These are Layer 1 (observation) + Layer 2 (evidence source) content only. If a signal contains reasoning, it has been contaminated by agent logic.
7. **Category alignment:** `signal_category` must match the tool's evidence type. Static analysis tools produce `structure` or `policy_posture` signals, not `behavior` signals.

## Examples

### Example: Semgrep SQL Injection Signal

```markdown
### S-SMG-001

**Source tool:** semgrep
**Source rule:** python.security.sql-injection.string-concat-query
**Location:** src/api/users.py:45
**Category:** policy_posture

#### Normalized Dimensions

| Dimension | Value |
|-----------|-------|
| Severity | high |
| Confidence estimate | medium |
| Blast radius | service_level |
| Domain relevance | 04, 03 |

#### Raw Output

**Raw severity:** ERROR
**Raw output ref:** .aegis/signals/semgrep/run-001.json
**Normalization notes:** Semgrep ERROR maps to AEGIS high (not critical) because Semgrep does not distinguish between exploitable and theoretical vulnerabilities. Confidence is medium because Semgrep is pattern-based without data flow analysis — the match may be a false positive if input is sanitized upstream. Domain 04 (Security) is primary; Domain 03 (Correctness) is secondary because string concatenation in SQL is also a correctness issue.
```
