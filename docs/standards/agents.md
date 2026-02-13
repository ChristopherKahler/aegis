# Agent Convention

## Purpose

Agents define **ASSEMBLY** — thin composition manifests that declare which persona, domains, tools, schemas, and rules compose each runtime agent. An agent file is not a prompt. It is not an identity description. It is not domain knowledge. It is a bill of materials: a declaration of which components are assembled together to create a functioning audit agent.

The agent manifest is intentionally thin. Identity lives in the persona file. Domain knowledge lives in domain files. Tool execution lives in tool files. Output structure lives in schema files. Behavioral constraints live in rule files. The agent file simply says: "compose these components together, and here are the assembly notes."

AEGIS uses 12 agent files, one per agent identity, mirroring the persona set. AEGIS Transform adds 5 agent files for intervention specialists, bringing the total to 17.

## Location

```
src/core/agents/      (12 Core agent assemblies)
src/transform/agents/ (5 Transform agent assemblies)
```

## Naming

**Pattern:** `{kebab-name}.md`

Agent filenames match their corresponding persona filenames. The kebab-name is the shared identifier.

**Examples:**
- `security-engineer.md`
- `principal-engineer.md`
- `sre.md`
- `devils-advocate.md`
- `data-engineer.md`
- `api-designer.md`

## Required Structure

Agent files are **primarily frontmatter**. The body is minimal — assembly notes and session context only.

### Frontmatter (Required)

```yaml
---
id: {kebab-name}
name: [Agent Display Name]
persona: {persona-id}
domains: [{DD}, {DD}]
tools: [{tool-id}, {tool-id}]
schemas:
  output: [finding, disagreement]
  confidence: confidence
  signal_input: signal
rules: [epistemic-hygiene, disagreement-protocol]
active_phases: [{N}, {N}]
parallel_eligible: [true | false]
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Kebab-case identifier, must match filename without extension |
| `name` | string | yes | Human-readable agent display name |
| `persona` | string | yes | ID of the persona file this agent uses (from `src/personas/`) |
| `domains` | list of strings | yes | Two-digit domain numbers this agent covers (from `src/domains/`) |
| `tools` | list of strings | yes | Tool IDs this agent consumes signals from (from `src/tools/`) |
| `schemas.output` | list of strings | yes | Schema IDs for output format (from `src/schemas/`) |
| `schemas.confidence` | string | yes | Schema ID for confidence assessment format |
| `schemas.signal_input` | string | yes | Schema ID for incoming signal format |
| `rules` | list of strings | yes | Rule IDs this agent must comply with (from `src/rules/`) |
| `active_phases` | list of integers | yes | AEGIS phases (0-5 for Core, 6-8 for Transform) where this agent is invoked |
| `parallel_eligible` | boolean | yes | Whether this agent can run concurrently with others in the same phase |

### Body Sections (Minimal)

The body must contain exactly 2 sections. Keep them short.

| Section | Header | Purpose |
|---------|--------|---------|
| Assembly Notes | `## Assembly Notes` | Special composition instructions not captured by the component references alone. |
| Session Context | `## Session Context` | What context this agent receives at session start — prior phase outputs, signals, schemas to enforce. |

**Critical constraint:** If the body exceeds 20 lines of content (excluding headers and blank lines), content is being duplicated from persona or domain files. Refactor it back to the source.

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| References | One persona (`src/personas/`) | `persona: {id}` |
| References | Multiple domains (`src/domains/`) | `domains: [{DD}, {DD}]` |
| References | Multiple tools (`src/tools/`) | `tools: [{id}, {id}]` |
| References | Multiple schemas (`src/schemas/`) | `schemas.output`, `schemas.confidence`, `schemas.signal_input` |
| References | Multiple rules (`src/rules/`) | `rules: [{id}, {id}]` |
| Referenced BY | Workflows (`src/workflows/`) | Agent invocation by ID |

Agents are the **hub** of the dependency graph — they reference almost everything and are referenced by workflows.

## Example Skeleton

````markdown
---
id: security-engineer
name: Security Engineer
persona: security-engineer
domains: ["04", "06"]
tools: [semgrep, gitleaks, trivy, grype]
schemas:
  output: [finding, disagreement]
  confidence: confidence
  signal_input: signal
rules: [epistemic-hygiene, disagreement-protocol, agent-boundaries]
active_phases: [1, 2, 3, 4]
parallel_eligible: true
---

## Assembly Notes

[Any special composition instructions. Keep this brief — only document behavior
that isn't captured by the persona + domain combination.

Example: "This agent has primary ownership of domain 04 (Security) and secondary
review responsibility for domain 06 (Infrastructure). For domain 06, this agent
focuses exclusively on security-relevant infrastructure concerns (IAM, network
exposure, secrets in IaC) and defers operational concerns to the SRE agent.

When this agent and the SRE agent both produce findings for domain 06, the
disagreement resolution workflow arbitrates based on the finding's primary
concern (security vs. operational)."]

## Session Context

[What this agent receives at session start. Be explicit about which artifacts
from prior phases are loaded into context.

Example:
- **Phase 1 input:** Repository structure map, technology inventory, .aegis/STATE.md
- **Phase 2 input:** All normalized signals from tools listed in `tools` field,
  prior agents' findings for domains listed in `domains` field
- **Phase 3 input:** Cross-domain findings that reference this agent's domains,
  disagreement records involving this agent
- **Phase 4 input:** Consolidated finding set for final severity calibration]
````

## Transform Agent Conventions

Transform agents follow a different assembly pattern than Core agents, reflecting the centralized intervention model.

**Core Design Principle:** *Diagnosis is decentralized. Intervention is centralized.*

**Key architectural differences:**

| Aspect | Core Agent | Transform Agent |
|--------|-----------|-----------------|
| Domain scope | 1-3 specific domains | ALL domains (full finding access) |
| Execution model | Parallel (independent) | Sequential (coordinated pipeline) |
| Input source | Tool signals + prior phase findings | Complete Layer A record (all findings, disagreements, reports) |
| Output target | findings/{agent-id}/ | remediation/ or execution/ |
| Rule set | Epistemic governance | Epistemic governance + safety rules |

**Transform agent assembly:**

```yaml
---
id: remediation-architect
name: Remediation Architect
persona: remediation-architect
domains: ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13"]
tools: [git-history]
schemas:
  output: [playbook, change-risk]
  confidence: confidence
  signal_input: finding
  layer_a_input: [finding, disagreement, report-section]
rules: [epistemic-hygiene, safety-governance, conservative-bias]
active_phases: [6, 8]
parallel_eligible: false
---
```

Note the differences from Core assembly:
- `domains` includes ALL 14 domains (Transform agents see everything)
- `schemas.signal_input` is `finding` (consumes Layer A findings, not raw tool signals)
- `schemas.layer_a_input` — new field for Transform agents specifying which Core schemas they consume
- `rules` includes safety-specific rules alongside shared epistemic rules
- `parallel_eligible: false` — Transform agents execute sequentially in a coordinated pipeline

**Transform agents consume ALL Core findings,** not just domain-scoped subsets. This is because remediation requires holistic understanding — a security fix may have architectural implications, a performance fix may have testing implications.

**Transform agents share a common intervention pipeline** — they execute sequentially within each phase, not in parallel. Phase 6: Remediation Architect → Pedagogy Agent. Phase 7: Change Risk Modeler → Guardrail Generator. Phase 8: Execution Validator.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Duplicating persona content | Identity, mental models, risk philosophy, triggers — all of this belongs in `src/personas/`. If the agent body describes *who* the agent is, that content should be in the persona file instead. The agent manifest just references it. |
| Duplicating domain knowledge | Failure patterns, audit questions, red flags — all domain knowledge belongs in `src/domains/`. If the agent body lists what to look for, move it to the appropriate domain file. |
| Large body content | The body should be under 20 lines. Agent files are thin manifests. If you find yourself writing paragraphs, you are putting content in the wrong layer. Ask: "Does this describe identity (persona), knowledge (domain), structure (schema), constraint (rule), or assembly (agent)?" |
| Missing component references | Every agent must reference at least: one persona, one or more domains, one or more tools, output and confidence schemas, and at least one rule. An agent without rules is ungoverned. An agent without tools has no signal input. Incomplete manifests produce broken agents. |
| Persona-agent ID mismatch | The agent `id` and `persona` field should align. The agent named `security-engineer` should reference the persona `security-engineer`. Mismatches create confusion about which identity drives which agent. |
| Embedding prompt instructions | Agent manifests are not prompts. "You are a security expert who should..." is prompt engineering. The persona file handles identity. The workflow handles invocation. The agent file just assembles the pieces. |
| Transform agent with domain-scoped input | Transform agents must see all findings, not just findings from their 'assigned' domains. Remediation that ignores cross-domain effects produces fixes that create new problems. |
| Parallel-eligible Transform agents | Transform agents must execute sequentially. The Pedagogy Agent needs the Remediation Architect's output. The Guardrail Generator needs the Change Risk Modeler's scores. Parallelism breaks the intervention pipeline. |
