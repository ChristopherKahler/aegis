---
id: finding
name: Epistemic Finding
version: 1.0.0
used_by:
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

A Finding is the atomic unit of agent output in AEGIS — a single identified issue, risk, or observation produced by an agent during domain audit phases. Every concern an agent raises must be expressed as a Finding. Findings feed into disagreement resolution, severity calibration, and final report generation.

The 7-layer epistemic structure enforces decomposition of reasoning. Agents cannot jump from observation to judgment — they must pass through evidence sourcing, interpretation, assumption surfacing, risk modeling, and impact assessment first. This prevents the most common failure mode in AI-generated analysis: confident conclusions built on unexamined assumptions.

Findings are Layer A (diagnostic) output. They are the primary input to disagreement resolution, the Transform remediation pipeline, and the final report.

## Template

```markdown
### {finding_id}

**Domain:** {domain_number} — {domain_name}
**Agent:** {agent_id}
**Severity:** {severity}

#### Confidence Vector
@schema:confidence — {confidence_vector}

---

#### Layer 1 — Observation (Raw Signal)

{observation}

**Source signals:**
- {signal_reference_1}
- {signal_reference_2}

#### Layer 2 — Evidence Source

| Attribute | Value |
|-----------|-------|
| Source type | {source_type} |
| Tool or artifact | {tool_or_artifact} |
| Location | {location} |
| Freshness | {freshness} |
| Additional sources | {additional_sources} |

#### Layer 3 — Interpretation (Mechanism)

{interpretation}

**Causal mechanism:** {causal_mechanism}

**Alternative interpretations:**
- {alternative_1}

#### Layer 4 — Assumptions

What must be true for the interpretation to hold:

1. {assumption_1}
2. {assumption_2}

**Falsifiability:** {how_assumptions_could_be_disproved}

#### Layer 5 — Risk Statement

If {interpretation_summary}, then {failure_mode}, impacting {asset}.

#### Layer 6 — Impact & Likelihood

| Dimension | Assessment |
|-----------|------------|
| Impact domain | {impact_domain} |
| Impact magnitude | {impact_magnitude} |
| Likelihood | {likelihood} |
| Time horizon | {time_horizon} |
| Blast radius | {blast_radius} |

**Reasoning:** {impact_reasoning}

#### Layer 7 — Judgment (Decision-Oriented)

**Action:** {action}
**Owning agent:** {judgment_owner}
**Rationale:** {judgment_rationale}

---

**References:**
- {reference_1}
- {reference_2}
```

## Field Reference

### Metadata Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `finding_id` | string | yes | Unique identifier across the entire audit. | Pattern: `F-{DD}-{NNN}` where DD is two-digit domain number (00-13), NNN is three-digit sequence (001-999). Example: `F-04-001` |
| `domain_number` | string | yes | Two-digit domain number this finding belongs to. | `00` through `13` |
| `domain_name` | string | yes | Human-readable domain name. | Must match the domain file's `name` field |
| `agent_id` | string | yes | ID of the agent that produced this finding. | Must match an agent assembly manifest's `id` field. Agent must have the specified domain in its `domains` list. |
| `severity` | enum | yes | Assessed severity of the finding. | `critical`, `high`, `medium`, `low`, `informational` |
| `confidence_vector` | object | yes | Multi-dimensional confidence assessment. | Must conform to @schema:confidence. Contains: evidence_diversity (1-5), signal_freshness (1-5), assumption_fragility (1-5), historical_precedent (1-5), overall (low/medium/high), justification (string). |

### Layer 1 — Observation Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `observation` | string | yes | What exists independently of interpretation. Factual description of what was observed. | No adjectives. No risk language. No value judgments. Tool outputs live here. 1-4 sentences. |
| `signal_references` | list of strings | yes | IDs or descriptions of signals that produced this observation. | At least one signal reference. Can be tool signal IDs, file paths, or configuration excerpts. |

### Layer 2 — Evidence Source Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `source_type` | enum | yes | Category of evidence. | `static_analysis`, `config_file`, `runtime_metric`, `log`, `commit_history`, `manual_review`, `dependency_scan`, `iac_scan`, `secrets_scan` |
| `tool_or_artifact` | string | yes | Which tool or artifact produced the evidence. | Tool name (e.g., "Semgrep", "SonarQube") or artifact name (e.g., "Dockerfile", "terraform/main.tf") |
| `location` | string | yes | Where the evidence was found. | File path + line number, environment name, config key, or API endpoint. Must be specific enough to locate. |
| `freshness` | enum | yes | Temporal relevance of the evidence. | `static` (code as-written), `historical` (git history, past data), `recent` (recent config/deploy), `live` (current runtime data) |
| `additional_sources` | list of objects | no | Additional corroborating sources beyond the primary. | Each object: {source_type, tool_or_artifact, location, freshness}. Strengthens evidence_diversity in confidence vector. |

### Layer 3 — Interpretation Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `interpretation` | string | yes | What this observation means in context. | Must explain a causal mechanism. No value judgment. 2-4 sentences. |
| `causal_mechanism` | string | yes | The specific mechanism by which this observation could lead to a problem. | One sentence describing cause-and-effect. |
| `alternative_interpretations` | list of strings | no | Other valid interpretations of the same observation. | Each entry is a plausible alternative. Presence indicates epistemic honesty; absence is acceptable only when interpretation is unambiguous. |

### Layer 4 — Assumptions Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `assumptions` | list of strings | yes | What must be true for the interpretation to hold. | At least one falsifiable assumption. Each must be a concrete, testable statement. |
| `falsifiability` | string | yes | How the assumptions could be disproved. | Description of what evidence would invalidate the interpretation. |

### Layer 5 — Risk Statement Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `risk_statement` | string | yes | Structured risk assertion. | Must follow format: "If [interpretation], then [failure mode], impacting [asset]." All three components required. |

### Layer 6 — Impact & Likelihood Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `impact_domain` | enum | yes | Which domain of impact this finding affects. | `security`, `data_integrity`, `availability`, `compliance`, `velocity` |
| `impact_magnitude` | enum | yes | How severe the impact would be if the risk materializes. | `low`, `moderate`, `high`, `critical`, `existential` |
| `likelihood` | enum | yes | How likely the risk is to materialize. | `rare`, `unlikely`, `possible`, `likely`, `frequent` |
| `time_horizon` | enum | yes | When the risk is expected to manifest. | `immediate`, `near_term`, `long_term`, `hypothetical` |
| `blast_radius` | enum | yes | How widely the impact would spread. | `localized`, `service_level`, `systemic`, `org_wide` |
| `impact_reasoning` | string | yes | Explicit reasoning for the impact and likelihood assessments. | 2-4 sentences connecting evidence to impact dimensions. No "vibes" — must reference specific evidence. |

### Layer 7 — Judgment Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `action` | enum | yes | Recommended action. | `must_fix`, `should_fix`, `accept_risk`, `monitor`, `out_of_scope` |
| `judgment_owner` | string | yes | Agent responsible for the final judgment. | Typically `principal-engineer` for final judgments. Originating agent for initial recommendations. |
| `judgment_rationale` | string | yes | Why this action is recommended. | 1-3 sentences. Must reference Layer 6 assessments. Judgment is explicitly separated from facts. |

### Reference Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `references` | list of strings | no | External standards, related findings, or documentation. | CWE IDs, CVE IDs, standard references, or related finding IDs (F-{DD}-{NNN} format). |

## Validation Rules

1. **Unique ID:** `finding_id` must be unique across the entire audit. No two findings may share an ID.
2. **Valid domain:** `domain_number` must reference an existing domain (00-13).
3. **Agent-domain alignment:** `agent_id` must reference an agent that has the specified domain in its `domains` list.
4. **Observation purity:** Layer 1 (`observation`) must contain no adjectives, risk language, or value judgments. It describes what exists, not what it means. Phrases like "dangerous", "poor", "inadequate" in Layer 1 are validation failures.
5. **Evidence grounding:** Layer 2 must contain at least one concrete source reference (file path, tool signal ID, or configuration excerpt). Assertions without evidence are invalid.
6. **Mechanistic interpretation:** Layer 3 (`interpretation`) must explain a causal mechanism. Restating the observation is not interpretation. "Function retries on 500" (observation) vs "Unbounded retries can amplify load during partial outages" (interpretation).
7. **Falsifiable assumptions:** Layer 4 must list at least one falsifiable assumption. Tautologies ("the code does what it does") are not assumptions.
8. **Risk statement structure:** Layer 5 must follow "If [interpretation], then [failure mode], impacting [asset]" structure. All three components are required.
9. **Enumerated values:** All Layer 6 fields must use their enumerated values. No other values are valid.
10. **Valid judgment:** Layer 7 `action` must be one of the five enumerated values.
11. **Confidence vector conformance:** `confidence_vector` must be a valid instance of @schema:confidence. All four dimensions required, all scoring within 1-5 range.
12. **Severity-confidence consistency:** A finding with `severity: critical` and `confidence_vector.overall: low` must include explicit justification in Layer 7 explaining why a critical severity is warranted despite low confidence. The combination triggers mandatory review by the Principal Engineer.
13. **Cross-reference validity:** Any finding ID referenced in `references` must exist in the audit's finding set.

## Examples

### Example: Critical Security Finding — Hardcoded Credentials

```markdown
### F-04-001

**Domain:** 04 — Security
**Agent:** security-engineer
**Severity:** critical

#### Confidence Vector
@schema:confidence
- Evidence diversity: 4 (static analysis + secrets scan + config review + commit history)
- Signal freshness: 2 (static analysis only, no runtime confirmation)
- Assumption fragility: 5 (credentials are plaintext in source — self-evident)
- Historical precedent: 5 (CWE-798 is among the most documented credential failures)
- Overall: high
- Justification: Four independent evidence sources confirm plaintext credentials in source code. This is a well-documented failure mode (CWE-798) with extensive incident history. Signal freshness is limited to static analysis, but the finding does not require runtime validation — the credentials are visible in the code.

---

#### Layer 1 — Observation (Raw Signal)

File `config/database.py` lines 12-14 contain three string literals assigned to variables named `DB_USER`, `DB_PASS`, and `DB_HOST`. The values are `"admin"`, `"pr0d_s3cret_2024"`, and `"prod-db.internal.company.com"` respectively.

**Source signals:**
- Gitleaks signal GL-047: high-entropy secret detected in config/database.py
- Semgrep rule python.security.hardcoded-credentials: match at config/database.py:12-14
- SonarQube hotspot S2068: credentials should not be hard-coded

#### Layer 2 — Evidence Source

| Attribute | Value |
|-----------|-------|
| Source type | static_analysis |
| Tool or artifact | Gitleaks v8.x |
| Location | config/database.py, lines 12-14 |
| Freshness | static |
| Additional sources | Semgrep (static_analysis, config/database.py:12), SonarQube (static_analysis, S2068 hotspot), git log (commit_history, credentials present since initial commit a1b2c3d, 2024-03-15) |

#### Layer 3 — Interpretation (Mechanism)

Production database credentials stored as plaintext strings in source code are accessible to anyone with repository read access. The credentials are not injected at runtime via environment variables or a secrets manager — they are embedded directly in the application configuration module.

**Causal mechanism:** Repository access grants database access because credentials are not externalized from the codebase.

**Alternative interpretations:**
- The values could be development-only defaults overridden by environment variables at runtime. However, no environment variable lookup or override mechanism exists in the file.

#### Layer 4 — Assumptions

What must be true for the interpretation to hold:

1. The `config/database.py` file is used in production deployments (not just local development).
2. No runtime override mechanism (environment variable, secrets manager injection) supersedes these values before the database connection is established.
3. The repository is accessible to individuals who should not have production database credentials.

**Falsifiability:** If a deployment script or container entrypoint injects environment variables that override these values before `config/database.py` is loaded, the plaintext values would never be used in production. Review of deployment configuration (Dockerfile, docker-compose.yml, CI/CD pipeline) would confirm or refute this.

#### Layer 5 — Risk Statement

If production database credentials are embedded in source code without runtime override, then anyone with repository access can connect directly to the production database, impacting data confidentiality, integrity, and availability.

#### Layer 6 — Impact & Likelihood

| Dimension | Assessment |
|-----------|------------|
| Impact domain | security |
| Impact magnitude | critical |
| Likelihood | likely |
| Time horizon | immediate |
| Blast radius | systemic |

**Reasoning:** The credentials are plaintext and have been in the repository since the initial commit (11 months). Any developer, CI system, or third-party integration with repository access has had production database credentials for nearly a year. The blast radius is systemic because database compromise affects all application data and all services that depend on this database. Credential rotation requires a code change and redeployment.

#### Layer 7 — Judgment (Decision-Oriented)

**Action:** must_fix
**Owning agent:** security-engineer
**Rationale:** Plaintext production credentials in source code are an immediate, systemic risk with critical impact magnitude. The finding has high confidence across all dimensions. Remediation is well-understood (externalize to environment variables or secrets manager) and low-risk. There is no defensible reason to accept this risk.

---

**References:**
- CWE-798: Use of Hard-coded Credentials
- F-04-003 (related: missing secrets scanning in CI pipeline)
- OWASP Top 10 A07:2021 — Identification and Authentication Failures
```
