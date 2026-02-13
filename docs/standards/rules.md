# Rule Convention

## Purpose

Rules define **CONSTRAINTS** — epistemic governance that applies to all agents uniformly. They are the non-negotiable invariants of the AEGIS system: principles that no persona can override, no workflow can skip, and no domain can contradict.

Rules exist because multi-agent systems are prone to epistemic drift. Without explicit constraints, agents fabricate confidence, suppress disagreement, anchor on tool output, and produce findings that sound authoritative but lack evidence. Rules prevent these failure modes by codifying the behavioral boundaries that keep agent output honest, calibrated, and defensible.

AEGIS uses a small number of rule files. Fewer rules with higher enforcement rigor is preferable to many rules with spotty compliance.

## Location

```
src/rules/
```

## Naming

**Pattern:** `{kebab-name}.md`

**Examples:**
- `epistemic-hygiene.md`
- `disagreement-protocol.md`
- `agent-boundaries.md`

## Required Structure

Every rule file consists of YAML frontmatter followed by 4 mandatory sections.

### Frontmatter (Required)

```yaml
---
id: {kebab-name}
name: [Rule Name]
scope: [which component types this rule applies to]
priority: [critical | quality | guidance]
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Kebab-case identifier, must match filename without extension |
| `name` | string | yes | Human-readable rule name |
| `scope` | string or list | yes | What this rule applies to: `all_agents`, `personas`, `workflows`, `schemas`, or a combination |
| `priority` | enum | yes | `critical` (violation invalidates output), `quality` (violation degrades output), `guidance` (best practice, not enforced) |

### Body Sections (All Required)

| Section | Header | Purpose |
|---------|--------|---------|
| Purpose | `## Purpose` | Why this rule exists. What specific failure mode it prevents. What goes wrong without it. |
| Rules | `## Rules` | Numbered list of rules, each with statement, rationale, and enforcement mechanism. |
| DO | `## DO` | Concrete examples of conforming behavior. |
| DON'T | `## DON'T` | Concrete examples of violations with explanation of why each is wrong. |

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| Referenced BY | Agent assembly manifests (`src/agents/`) | `rules: [{rule-id}, ...]` field in agent frontmatter |
| Referenced BY | Workflows (`src/workflows/`) | For enforcement during execution |
| Does NOT reference | Specific domains, personas, tools | Rules are universal; they don't depend on specific component instances |

## Example Skeleton

````markdown
---
id: epistemic-hygiene
name: Epistemic Hygiene
scope: all_agents
priority: critical
---

## Purpose

[Why this rule exists and what goes wrong without it.

Example: "Without epistemic hygiene rules, agents produce findings that sound
confident but lack evidence, assert severity without justification, and treat
tool output as ground truth. This rule ensures that every agent claim is
grounded in verifiable evidence, every confidence assessment is calibrated
to actual certainty, and every severity judgment includes explicit reasoning."]

## Rules

### 1. [Rule Statement — e.g., "Every finding must include verifiable evidence"]

**Rationale:** [Why this rule matters. What failure mode it prevents.
Example: "Findings without evidence are unfalsifiable assertions. They cannot
be verified, challenged, or acted upon with confidence. Evidence grounds
findings in observable reality."]

**Enforcement:** [How this rule is checked. Example: "Workflow validation
step rejects findings where the evidence field contains no file paths,
code snippets, or signal references."]

### 2. [Rule Statement — e.g., "Confidence must reflect actual certainty, not rhetorical force"]

**Rationale:** [Why this rule matters.
Example: "Agents default to 'high confidence' because it sounds more
authoritative. Miscalibrated confidence leads to misallocated remediation
effort — teams fix 'high confidence' issues first, even if the confidence
was inflated."]

**Enforcement:** [How this rule is checked. Example: "Agents must provide
a one-sentence justification for any confidence rating of 'high'. Confidence
of 'high' without justification is automatically downgraded to 'medium'."]

### 3. [Rule Statement — e.g., "Tool output is signal, not truth"]

**Rationale:** [Why this rule matters.]

**Enforcement:** [How this rule is checked.]

[Additional rules. Aim for 3-7 per rule file. More than 10 indicates the
file should be split.]

## DO

- [Conforming example 1 — e.g., "Finding states: 'Confidence: medium — Semgrep
  flagged this pattern but the custom sanitizer at line 45 may handle it.
  Manual verification needed.'"]
- [Conforming example 2 — e.g., "Finding severity is 'high' with explicit
  reasoning: 'Unauthenticated endpoint exposes PII. Impact is data breach
  of user records. Exploitability is trivial — no authentication required.'"]
- [Conforming example 3 — e.g., "Agent disagrees with tool output: 'Semgrep
  reports SQL injection at line 32, but the parameterized query builder at
  line 28 prevents this. Downgrading to informational — false positive.'"]
- [Additional examples of correct behavior]

## DON'T

- [Violation 1 — e.g., "Finding states 'Confidence: high' with no justification."]
  **Why this is wrong:** [Explanation — "Unsubstantiated high confidence inflates
  the apparent reliability of the finding and distorts prioritization."]

- [Violation 2 — e.g., "Finding repeats Semgrep output verbatim as its description
  and evidence."]
  **Why this is wrong:** [Explanation — "Tool output is a signal, not an analysis.
  The agent's job is to interpret, contextualize, and validate — not to parrot."]

- [Violation 3 — e.g., "Agent assigns 'critical' severity to every finding
  'to be safe'."]
  **Why this is wrong:** [Explanation — "Severity inflation is the opposite of
  safety. When everything is critical, nothing is. Teams learn to ignore severity
  ratings, defeating the purpose of risk prioritization."]

- [Additional violations with explanations]
````

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Rules that are actually domain knowledge | "Always check for SQL injection" is domain knowledge (belongs in `src/domains/`). Rules govern *how agents behave*, not *what they look for*. A rule like "every finding must have evidence" governs behavior universally. |
| Rules that are persona traits | "Be conservative about risk" is a persona characteristic (belongs in `src/personas/`). Different personas *should* have different risk postures. Rules apply equally to all agents regardless of persona. |
| Unenforceable rules | "Write good findings" is unenforceable because "good" is undefined. Every rule must have a concrete enforcement mechanism — a validation check, a required field, a measurable criterion. If you can't describe how to detect a violation, the rule is too vague. |
| Too many rules | Governance fatigue is real. When agents are loaded with 50 rules, they effectively follow zero. Keep rule files few (3-5 files) and keep rules per file focused (3-7 rules). Every rule should justify its existence by preventing a specific, documented failure mode. |
| Rules without rationale | A rule without a "why" is an arbitrary constraint. Agents (and the humans maintaining AEGIS) need to understand the reasoning. If you can't articulate why a rule exists, it probably shouldn't. |
| Rules that duplicate schema validation | "Severity must be one of: critical, high, medium, low, informational" is schema validation (belongs in `src/schemas/`). Rules govern behavior and reasoning quality, not data format compliance. |
