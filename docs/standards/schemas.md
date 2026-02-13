# Schema Convention

## Purpose

Schemas define **HOW** agents produce output. They are the data contracts of the AEGIS framework — specifying field names, types, enums, validation rules, and structural constraints that make agent output composable, validatable, and machine-parseable.

Without schemas, agent output drifts. One agent describes severity as "high", another as "H", another as "3". One agent includes a confidence score, another omits it. Schemas eliminate this drift by enforcing a single structural contract that all agents must conform to.

AEGIS uses approximately 5 schema files, each defining a reusable data structure consumed by agents and workflows.

## Location

```
src/schemas/
```

## Naming

**Pattern:** `{kebab-name}.md`

**Examples:**
- `finding.md`
- `disagreement.md`
- `confidence.md`
- `signal.md`
- `report-section.md`

## Required Structure

Every schema file consists of YAML frontmatter followed by 4 mandatory sections.

### Frontmatter (Required)

```yaml
---
id: {kebab-name}
name: [Schema Name]
version: [semver]
used_by: [which agents/workflows consume this schema]
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Kebab-case identifier, must match filename without extension |
| `name` | string | yes | Human-readable schema name |
| `version` | string | yes | Semantic version (e.g., `1.0.0`). Increment on breaking changes. |
| `used_by` | list of strings | yes | Agent IDs and/or workflow names that consume this schema |

### Body Sections (All Required)

| Section | Header | Purpose |
|---------|--------|---------|
| Purpose | `## Purpose` | What this schema represents, why it exists, when it's used. |
| Template | `## Template` | The actual template in a fenced code block with typed placeholders. |
| Field Reference | `## Field Reference` | Complete field documentation table. |
| Validation Rules | `## Validation Rules` | Numbered list of constraints that must hold for a valid instance. |
| Examples | `## Examples` | One or more correctly filled instances demonstrating proper usage. |

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| Referenced BY | Agent assembly manifests (`src/agents/`) | `schemas.output`, `schemas.confidence`, `schemas.signal_input` fields |
| Referenced BY | Workflows (`src/workflows/`) | For output validation steps |
| Does NOT reference | Personas, domains, tools | Schemas are universal contracts, independent of who fills them or what data feeds them |

## Example Skeleton

````markdown
---
id: finding
name: Finding
version: 1.0.0
used_by: [security-engineer, principal-engineer, sre, data-engineer, api-designer]
---

## Purpose

[What this schema represents and when it's used.

Example: "A Finding is a single identified issue, risk, or observation produced by
an agent during domain audit phases. Findings are the primary unit of agent output —
every concern an agent raises must be expressed as a Finding. Findings feed into
disagreement resolution, severity calibration, and final report generation."]

## Template

```markdown
### {finding_id}

**Domain:** {domain_number} — {domain_name}
**Agent:** {agent_id}
**Severity:** [critical | high | medium | low | informational]
**Confidence:** [high | medium | low]

**Title:** [One-line finding title — specific and descriptive]

**Description:**
[What was found. Factual description of the issue, pattern, or observation.
Two to four sentences.]

**Evidence:**
[Concrete evidence supporting this finding. File paths, code snippets,
tool signals, configuration excerpts. Must be verifiable.]

**Impact:**
[What could go wrong. Business and technical consequences if this
issue is not addressed.]

**Recommendation:**
[Suggested remediation. Specific, actionable, and scoped to the finding.]

**References:**
- [CWE/CVE/standard reference, if applicable]
- [Related findings by ID, if applicable]
```

## Field Reference

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `finding_id` | string | yes | Unique identifier. Format: `F-{DD}-{NNN}` where DD is domain number and NNN is sequence. | Pattern: `F-\d{2}-\d{3}` |
| `domain_number` | string | yes | Two-digit domain number this finding belongs to. | `00` through `13` |
| `domain_name` | string | yes | Human-readable domain name. | Must match domain file's `name` field |
| `agent_id` | string | yes | ID of the agent that produced this finding. | Must match an agent file's `id` field |
| `severity` | enum | yes | Assessed severity of the finding. | `critical`, `high`, `medium`, `low`, `informational` |
| `confidence` | enum | yes | Agent's confidence in the finding's accuracy. | `high`, `medium`, `low` |
| `title` | string | yes | One-line descriptive title. | Max 120 characters |
| `description` | string | yes | Factual description of the issue. | 2-4 sentences |
| `evidence` | string | yes | Verifiable proof. File paths, code, tool output. | Must reference concrete artifacts |
| `impact` | string | yes | Consequences if unaddressed. | Business and/or technical impact |
| `recommendation` | string | yes | Actionable remediation guidance. | Specific to this finding |
| `references` | list of strings | no | CWE, CVE, standard refs, or related finding IDs. | Free-form but should use standard identifiers |

## Validation Rules

1. `finding_id` must be unique across the entire audit. No two findings may share an ID.
2. `domain_number` must reference an existing domain (00-13).
3. `agent_id` must reference an agent that has the specified domain in its `domains` list.
4. `severity` must be one of the five enumerated values. No other values are valid.
5. `confidence` must be one of the three enumerated values.
6. `evidence` must contain at least one concrete reference (file path, code snippet, or tool signal ID). Assertions without evidence are invalid.
7. `title` must not exceed 120 characters.
8. [Additional validation rules specific to this schema.]

## Examples

### Example: High-Severity Security Finding

```markdown
### F-04-001

**Domain:** 04 — Security
**Agent:** security-engineer
**Severity:** critical
**Confidence:** high

**Title:** Hardcoded database credentials in application configuration

**Description:**
Production database credentials are stored as plaintext strings in
`config/database.py`. The username, password, and host are directly
embedded in source code rather than injected via environment variables
or a secrets manager.

**Evidence:**
File: `config/database.py`, lines 12-14:
\```python
DB_USER = "admin"
DB_PASS = "pr0d_s3cret_2024"
DB_HOST = "prod-db.internal.company.com"
\```
Corroborated by gitleaks signal: `GL-047` (high-entropy secret detected).

**Impact:**
Anyone with repository access has production database credentials.
Credential rotation requires a code change and deployment. If the
repository is compromised, the database is immediately accessible.

**Recommendation:**
Move credentials to environment variables or a secrets manager (e.g.,
AWS Secrets Manager, HashiCorp Vault). Remove plaintext values from
source code and rotate the exposed credentials immediately.

**References:**
- CWE-798: Use of Hard-coded Credentials
- Related: F-04-003 (missing secrets scanning in CI)
```
````

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Embedding interpretation guidance | "If severity is critical, the agent should escalate..." is workflow logic, not schema definition. Schemas define structure; rules and workflows define behavior. |
| Including persona-specific fields | A field like `security_impact` that only one agent type would fill breaks universality. If a field isn't meaningful for all consumers listed in `used_by`, it doesn't belong in the schema. |
| Loose field definitions | "`description`: any text" is not a definition. Specify what belongs in the field, how long it should be, and what constitutes valid content. Precision prevents drift. |
| Missing enum values | Every enum field must list ALL valid values explicitly. "severity: one of several levels" is incomplete. "severity: critical, high, medium, low, informational" is complete. |
| No validation rules | A schema without validation rules is just a template. Validation rules make schemas enforceable — they define what "correct" means. |
| Version not updated on changes | Breaking changes to a schema (adding required fields, changing enum values, renaming fields) must increment the version. Consumers depend on the contract; changing it silently breaks the system. |
