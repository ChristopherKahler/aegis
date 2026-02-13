# Tool Convention

## Purpose

Tools define **INPUTS** — how to run external analysis tools, parse their output, and normalize it into the AEGIS signal format. Tools are the bridge between raw scanner output and structured agent input.

In AEGIS, tools produce **signals**; agents **interpret** them. A tool file never says what a finding means — it only says how to run the scanner, what the raw output looks like, and how to map that output into a normalized signal schema that agents can consume. The interpretation, severity assessment, and contextual judgment all happen at the agent layer.

Some tools produce signals consumed by both Core diagnostic agents and Transform intervention agents. Additionally, Transform introduces a new category of tool usage: change-risk analysis tooling that feeds the Change Risk Modeler.

AEGIS uses 7 or more tool files, one per external analysis tool.

## Location

```
src/tools/
```

## Naming

**Pattern:** `{kebab-name}.md`

One tool per file, even when tools are commonly used together (e.g., Syft and Grype are separate files despite being complementary).

**Examples:**
- `semgrep.md`
- `trivy.md`
- `gitleaks.md`
- `syft.md`
- `grype.md`
- `git-history.md`
- `checkov.md`

## Required Structure

Every tool file consists of YAML frontmatter followed by 6 mandatory sections.

### Frontmatter (Required)

```yaml
---
id: {kebab-name}
name: [Tool Display Name]
type: [static_analysis | vulnerability_scan | secrets_detection | iac_scan | sbom | history_mining | code_quality]
domains_fed: [list of domain numbers this tool produces signals for]
install_required: [true | false]
install_command: [command to install, if required]
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Kebab-case identifier, must match filename without extension |
| `name` | string | yes | Human-readable tool name (e.g., "Semgrep", "Trivy") |
| `type` | enum | yes | Tool category. One of: `static_analysis`, `vulnerability_scan`, `secrets_detection`, `iac_scan`, `sbom`, `history_mining`, `code_quality`, `change_risk_analysis` |
| `domains_fed` | list of strings | yes | Two-digit domain numbers this tool produces signals for |
| `install_required` | boolean | yes | Whether the tool requires explicit installation |
| `install_command` | string | conditional | Required if `install_required` is `true`. Exact command to install the tool. |

### Body Sections (All Required)

| Section | Header | Purpose |
|---------|--------|---------|
| Purpose | `## Purpose` | What this tool does and what types of signals it produces. |
| Configuration | `## Configuration` | How to configure the tool for AEGIS use. Config files, rule sets, policies. |
| Execution | `## Execution` | Exact commands to run the tool. Input parameters, expected runtime characteristics. |
| Output Format | `## Output Format` | What raw tool output looks like. Representative example snippet. |
| Normalization | `## Normalization` | How to transform raw output into AEGIS signal schema. Field mapping table. |
| Limitations | `## Limitations` | What the tool cannot detect. Known false positive/negative patterns. |

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| Referenced BY | Domain files (`src/domains/`) | In the Tool Affinities section |
| Referenced BY | Agent assembly manifests (`src/agents/`) | `tools: [{tool-id}, ...]` field |
| Referenced BY | Workflows (`src/workflows/`) | For tool execution steps |
| References | Signal schema (`src/schemas/signal.md`) | Normalization target format |

## Example Skeleton

````markdown
---
id: semgrep
name: Semgrep
type: static_analysis
domains_fed: ["04", "01", "06"]
install_required: true
install_command: pip install semgrep
---

## Purpose

[What this tool does and what kinds of signals it produces.

Example: "Semgrep is a static analysis tool that pattern-matches source code
against a library of rules covering security vulnerabilities, code quality
issues, and framework-specific anti-patterns. It produces signals for
injection flaws, authentication weaknesses, insecure cryptography,
hardcoded secrets, and architectural pattern violations."]

## Configuration

[How to configure the tool for AEGIS use. Include actual config file contents
where applicable.]

### Config File

```yaml
# .semgrep.yml (place in target repository root or pass via --config)
rules:
  - p/security-audit
  - p/owasp-top-ten
  - p/secrets
  - [additional rule packs relevant to AEGIS domains]
```

### Rule Sets

- [Rule set 1 — e.g., "`p/security-audit` — broad security pattern matching"]
- [Rule set 2 — e.g., "`p/owasp-top-ten` — OWASP Top 10 coverage"]
- [Additional rule sets with brief description of what each covers]

### Configuration Notes

- [Note 1 — e.g., "Use `--severity ERROR WARNING` to exclude INFO-level noise"]
- [Note 2 — e.g., "Set `--timeout 300` for large repositories"]
- [Additional configuration guidance]

## Execution

### Primary Command

```bash
semgrep scan \
  --config auto \
  --json \
  --output {output_dir}/semgrep-results.json \
  --severity ERROR WARNING \
  --timeout 300 \
  {target_path}
```

### Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `{target_path}` | Path to repository root | Directory to scan |
| `{output_dir}` | `.aegis/signals/` | Where to write output |

### Runtime Expectations

- [Expected runtime — e.g., "2-10 minutes for repositories under 100k lines"]
- [Resource requirements — e.g., "Requires ~2GB RAM for large rule sets"]
- [Common failure modes — e.g., "Times out on generated code; exclude with --exclude"]

## Output Format

[Description of what the raw output looks like, followed by a representative snippet.]

```json
{
  "results": [
    {
      "check_id": "[rule.id — e.g., python.lang.security.injection.sql-injection]",
      "path": "[file path relative to scan root]",
      "start": { "line": 42, "col": 5 },
      "end": { "line": 42, "col": 68 },
      "extra": {
        "message": "[Human-readable description of the finding]",
        "severity": "[ERROR | WARNING | INFO]",
        "metadata": {
          "cwe": ["[CWE-89]"],
          "owasp": ["[A03:2021]"],
          "confidence": "[HIGH | MEDIUM | LOW]"
        }
      }
    }
  ]
}
```

## Normalization

Transform raw tool output into AEGIS signal schema format.

### Field Mapping

| Raw Field | Signal Field | Transformation |
|-----------|-------------|----------------|
| `check_id` | `rule_id` | Direct mapping |
| `path` | `file_path` | Prepend repository root if relative |
| `start.line` | `location.start_line` | Direct mapping |
| `end.line` | `location.end_line` | Direct mapping |
| `extra.message` | `description` | Direct mapping |
| `extra.severity` | `tool_severity` | Map: ERROR=high, WARNING=medium, INFO=low |
| `extra.metadata.cwe` | `references.cwe` | Direct mapping (array) |
| `extra.metadata.confidence` | `tool_confidence` | Map: HIGH=high, MEDIUM=medium, LOW=low |
| (generated) | `signal_id` | Generate: `{tool_id}-{sequential_number}` |
| (generated) | `source_tool` | Set to `{tool_id}` |

### Normalization Notes

- [Note 1 — e.g., "Semgrep severity is relative to its rule set, not absolute.
  Map to AEGIS signal severity but do not treat as final finding severity."]
- [Note 2 — e.g., "Deduplicate signals with identical check_id and file_path+line."]
- [Additional normalization guidance]

## Limitations

### Cannot Detect

- [Limitation 1 — e.g., "Business logic flaws — Semgrep matches patterns, not intent"]
- [Limitation 2 — e.g., "Runtime-only vulnerabilities (race conditions, timing attacks)"]
- [Limitation 3 — e.g., "Issues in dynamically generated code or templated strings"]

### Known False Positive Patterns

- [Pattern 1 — e.g., "Flags test fixtures that intentionally contain vulnerable patterns"]
- [Pattern 2 — e.g., "Reports 'hardcoded secret' on non-secret constants with high entropy"]
- [Additional false positive patterns agents should be aware of]

### Known False Negative Patterns

- [Pattern 1 — e.g., "Misses injection via indirect variable concatenation across functions"]
- [Pattern 2 — e.g., "Does not follow data flow through ORMs with custom query methods"]
- [Additional false negative patterns]
````

## Transform Tool Conventions

Transform agents consume tool signals differently from Core agents. Core agents interpret signals as evidence for findings. Transform agents use signals as input for change-risk modeling and remediation context.

**Tools that feed Transform (in addition to Core):**

| Tool Category | Purpose | Change Risk Dimension |
|--------------|---------|----------------------|
| Dependency graph analyzers | Map module coupling and dependency chains | Coupling risk |
| Test coverage mappers | Identify tested vs untested code paths | Regression probability |
| Change impact analyzers | Estimate blast radius of proposed changes | Blast radius |
| Git history miners | Identify change frequency, ownership, and churn patterns | All dimensions |

**Reused Core tools for Transform:**
- `git-history` tool signals feed both Core (Domain 11-12: change risk, ownership) and Transform (regression probability, blast radius estimation)
- `sonarqube` complexity metrics inform both Core (code health) and Transform (architectural tension estimation)

**Tool output normalization for change-risk signals:**

Transform-specific normalization adds a change-risk mapping in addition to the standard signal normalization:

| Raw Signal | Change Risk Signal | Transformation |
|-----------|-------------------|----------------|
| Test coverage percentage per file | `regression_probability_input` | Lower coverage = higher regression probability |
| Import/dependency count per module | `coupling_risk_input` | More dependencies = higher coupling risk |
| File modification frequency (churn) | `blast_radius_input` | High churn = many dependents = higher blast radius |
| Cyclomatic complexity | `architectural_tension_input` | High complexity = harder to change safely |

**New tool type: `change_risk_analysis`**

Tools in this category produce signals specifically for the Change Risk Modeler. They follow the same convention structure (Purpose, Configuration, Execution, Output Format, Normalization, Limitations) but their normalization section maps to change-risk dimensions rather than finding severity.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Embedding audit logic | "If this finding appears, it means the application is vulnerable" is interpretation — that's agent work. Tool files describe *what* the tool outputs and *how* to normalize it, not *what it means*. |
| Tool-specific severity scales without normalization guidance | Every tool has its own severity scale. Without explicit mapping to AEGIS signal schema severity, agents receive inconsistent input. The normalization section must include severity mapping. |
| Missing execution commands | A tool spec that doesn't include the exact command to run is incomplete. Workflows need to execute tools programmatically. If the command isn't here, it doesn't exist. |
| Combining multiple tools in one file | Syft and Grype are complementary but separate tools with separate execution, output formats, and signal types. One file per tool, always. Cross-reference via domain affinities if needed. |
| Omitting limitations | Every tool has blind spots. Failing to document what a tool *cannot* detect leads agents to assume absence of signals means absence of issues. Limitations are as important as capabilities. |
| Prescriptive interpretation of output | "A HIGH severity Semgrep finding should be treated as critical" is prescriptive interpretation. The tool file maps `HIGH` to the signal field `tool_severity: high`. The agent decides the actual finding severity using its persona and domain knowledge. |
| Tool that claims to assess change risk without evidence | A tool output that says 'high risk' without measurable data (coverage percentage, dependency count, churn rate) is not useful for Transform. Change risk must be grounded in quantifiable signals. |
| Conflating tool severity with change risk | A Semgrep finding with severity 'HIGH' does not mean the fix has high change risk. Tool severity describes the problem's impact. Change risk describes the danger of the fix. These are orthogonal dimensions. |
