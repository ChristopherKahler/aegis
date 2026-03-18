# Schema Convention

## Purpose

Schemas define **HOW** agents produce output. They are the data contracts of the AEGIS framework — specifying field names, types, enums, validation rules, and structural constraints that make agent output composable, validatable, and machine-parseable.

Without schemas, agent output drifts. One agent describes severity as "high", another as "H", another as "3". One agent includes a confidence score, another omits it. Schemas eliminate this drift by enforcing a single structural contract that all agents must conform to.

Transform extends the schema set with remediation and change-risk schemas, while Core schemas remain shared across both Core and Transform systems.

AEGIS uses approximately 9 schema files (5 Core + 4 Transform), each defining a reusable data structure consumed by agents and workflows.

## Location

```
src/schemas/             (Core — shared by both systems)
src/transform/schemas/   (Transform-specific)
```

## Naming

**Pattern:** `{kebab-name}.md`

**Examples:**
- `finding.md`
- `disagreement.md`
- `confidence.md`
- `signal.md`
- `report-section.md`
- `playbook.md`
- `change-risk.md`
- `intervention-level.md`
- `verification-plan.md`

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
| Referenced BY | Transform workflows (`src/transform/workflows/`) | Transform workflows reference Transform schemas for output validation |
| Does NOT reference | Personas, domains, tools | Schemas are universal contracts, independent of who fills them or what data feeds them. **Exception:** Transform schemas may reference Core schemas (e.g., playbook schema references finding schema's `finding_id` format) |

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
| Playbook without intervention level | Every remediation must be classified. A playbook with no intervention level is ungoverned. |
| Risk assessment without evidence | Scores without evidence are opinions. Every risk dimension requires supporting evidence. |

## Transform Schema Definitions

Transform introduces 4 additional schemas that live in `src/transform/schemas/`. These schemas govern remediation planning, change-risk assessment, intervention governance, and verification procedures. They build on top of Core schemas — particularly the finding schema — and are consumed exclusively by Transform agents and workflows.

### Remediation Playbook (`playbook.md`)

The playbook schema defines a structured remediation plan for a single finding. Each playbook maps a finding through transformation layers (abstract pattern to project-specific fix) and includes risk metadata and verification steps.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `finding_ref` | string | yes | Finding ID being remediated (e.g., `F-04-001`). Must match a valid finding ID from the Core finding schema. |
| `intervention_level` | enum | yes | Governance level for this remediation. Valid values: `suggesting`, `planning`, `authorizing`, `executing`. |
| `transformation_layers` | object | yes | Contains: `abstract_pattern` (string), `framework_mapping` (string), `language_mapping` (string), `project_context` (string). Each layer refines the remediation from general principle to project-specific guidance. |
| `before_example` | string | yes | Code showing the anti-pattern as it exists in the target codebase. |
| `after_example` | string | yes | Code showing the correct pattern after remediation. |
| `verification_steps` | list of strings | yes | Ordered steps to verify the fix works. Each step must be concrete and executable. |
| `risk_metadata` | object | yes | Contains: `blast_radius` (1-5), `coupling_risk` (1-5), `regression_probability` (1-5), `architectural_tension` (1-5). Each dimension scored with justification. |
| `educational_context` | string | no | Pedagogical explanation for AI-assisted developers. Explains *why* the anti-pattern is harmful and *why* the remediation is preferred. |

### Change Risk Assessment (`change-risk.md`)

The change-risk schema captures a multi-dimensional risk evaluation for a proposed change. Every change that Transform considers must be assessed across four risk dimensions, each backed by evidence, before a recommendation is issued.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `change_id` | string | yes | Unique change identifier. |
| `finding_refs` | list of strings | yes | Finding IDs this change addresses. Each must match a valid finding ID. |
| `blast_radius` | object | yes | Contains: `score` (integer, 1-5), `evidence` (string), `affected_files` (list of strings). How widely the change ripples through the codebase. |
| `coupling_risk` | object | yes | Contains: `score` (integer, 1-5), `evidence` (string), `new_dependencies` (list of strings). Whether the change introduces or tightens coupling. |
| `regression_probability` | object | yes | Contains: `score` (integer, 1-5), `evidence` (string), `test_coverage_pct` (number). Likelihood the change breaks existing functionality. |
| `architectural_tension` | object | yes | Contains: `score` (integer, 1-5), `evidence` (string), `design_conflicts` (list of strings). Whether the change conflicts with the codebase's architectural direction. |
| `overall_risk` | enum | yes | Aggregate risk classification. Valid values: `low`, `medium`, `high`, `critical`. |
| `recommendation` | enum | yes | Action recommendation based on risk assessment. Valid values: `proceed`, `proceed_with_caution`, `human_review_required`, `reject`. |

### Intervention Level (`intervention-level.md`)

The intervention-level schema defines the governance tiers that control what Transform is permitted to do. Each level sets thresholds for finding confidence, evidence requirements, and high-risk behavior.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `level` | enum | yes | The intervention tier. Valid values: `suggesting`, `planning`, `authorizing`, `executing`. |
| `minimum_finding_confidence` | enum | no | Minimum confidence a finding must have for this level to apply. Valid values: `low`, `medium`, `high`. |
| `minimum_evidence_sources` | integer | no | Minimum number of independent evidence sources required. |
| `allowed_when_risk_high` | boolean | no | Whether this intervention level is permitted when the change risk exceeds "high". |

### Verification Plan (`verification-plan.md`)

The verification-plan schema defines the checks that must be performed before, after, and in regression testing of a change. It also specifies rollback criteria and procedures, ensuring every Transform change is reversible.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `change_id` | string | yes | The change this verification plan covers. Must match a change-risk assessment's `change_id`. |
| `pre_change_checks` | list of objects | yes | Each object contains: `check_name` (string), `command_or_instruction` (string), `expected_result` (string). Checks to run before applying the change. |
| `post_change_checks` | list of objects | yes | Each object contains: `check_name` (string), `command_or_instruction` (string), `expected_result` (string). Checks to run after applying the change. |
| `regression_checks` | list of objects | yes | Each object contains: `check_name` (string), `command_or_instruction` (string), `expected_result` (string). Checks to confirm no existing functionality is broken. |
| `rollback_criteria` | list of strings | yes | Conditions under which rollback is required. Each criterion must be specific and observable. |
| `rollback_procedure` | string | yes | How to undo the change. Must be a concrete, step-by-step procedure. |
