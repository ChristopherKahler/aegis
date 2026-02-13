# Workflow Convention

## Purpose

Workflows define **ORCHESTRATION** — step-by-step execution logic for AEGIS audit phases and utility processes. A workflow specifies *what happens*, *in what order*, *with which agents*, and *how sessions hand off context*.

Workflows are the operational backbone of AEGIS. They handle multi-session agent invocation, session boundary management, disagreement resolution sequencing, and artifact creation. Workflows do not analyze code, interpret signals, or render judgments — that is agent work. Workflows ensure agents are invoked correctly, receive the right context, produce output in the right format, and that phase transitions happen cleanly.

AEGIS uses approximately 8 workflow files: one per audit phase plus utility workflows for cross-cutting concerns.

## Location

```
src/workflows/
```

## Naming

**Pattern:**
- Phase workflows: `phase-{N}-{kebab-name}.md`
- Utility workflows: `{kebab-name}.md`

**Examples:**
- `phase-0-context.md`
- `phase-1-reconnaissance.md`
- `phase-2-domain-audits.md`
- `phase-3-cross-domain.md`
- `phase-4-severity-calibration.md`
- `phase-5-report.md`
- `session-handoff.md`
- `disagreement-resolution.md`

## Required Structure

Workflow files use **XML tags** (not YAML frontmatter, not markdown headers). This matches the workflow convention used in the PAUL framework and provides clear structural boundaries for each section.

Workflows have no YAML frontmatter. They are loaded by explicit reference from commands and other workflows, not discovered by metadata scan.

### Sections (All Required)

| Section | Tag | Purpose |
|---------|-----|---------|
| Purpose | `<purpose>` | One-sentence description of what this workflow does. |
| Phase Context | `<phase_context>` | Phase number, what this phase receives, which agents run, what it produces. |
| Required Input | `<required_input>` | `@` references to files and artifacts this workflow needs loaded. |
| Process | `<process>` | Ordered steps using `<step>` tags with named, prioritized instructions. |
| Output | `<output>` | What artifacts are created and where they go in `.aegis/`. |
| Error Handling | `<error_handling>` | Failure scenarios and how the workflow responds. |

### Step Structure

Steps within `<process>` use this format:

```xml
<step name="{snake_case_name}" priority="{first|blocking|optional}">
[Detailed numbered instructions for this step]
</step>
```

| Attribute | Required | Values | Description |
|-----------|----------|--------|-------------|
| `name` | yes | snake_case string | Unique step identifier within this workflow |
| `priority` | yes | `first`, `blocking`, `optional` | `first`: must execute before all others. `blocking`: must complete before next step. `optional`: can be skipped without invalidating the workflow. |

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| References | Agent manifests (`src/agents/`) | By agent ID for invocation |
| References | Schemas (`src/schemas/`) | For output validation |
| References | `.aegis/` state files | For runtime state management |
| Referenced BY | Commands (`src/commands/`) | Delegation from user-facing entry points |
| Referenced BY | Other workflows | For sub-workflow invocation (e.g., disagreement-resolution called by phase-3) |

## Example Skeleton

````xml
<purpose>
[One sentence describing what this workflow does.
Example: "Executes parallel domain audits by invoking specialist agents against
their assigned domains with normalized tool signals as input."]
</purpose>

<phase_context>
Phase: [N] — [Phase Name]
Prior phase output: [What this phase receives from the previous phase.
  Example: "Repository structure map, technology inventory, normalized
  tool signals (.aegis/signals/), STATE.md"]
Agents invoked: [Which agents run in this phase.
  Example: "security-engineer, principal-engineer, sre, data-engineer,
  api-designer (parallel-eligible agents run concurrently)"]
Output: [What this phase produces.
  Example: "Per-agent finding sets (.aegis/findings/{agent-id}.md),
  disagreement records (.aegis/disagreements/), updated STATE.md"]
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@src/schemas/finding.md
@src/schemas/signal.md
@src/rules/epistemic-hygiene.md
[Additional @ references to required files]
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md exists and shows prior phase completed successfully.
2. Verify all required signal files exist in .aegis/signals/.
3. Verify all agents listed in phase_context are defined in .aegis/MANIFEST.md.
4. If any prerequisite is missing, halt with error: "[prerequisite] not found.
   Run phase [N-1] first."
</step>

<step name="prepare_agent_context" priority="blocking">
1. For each agent invoked in this phase:
   a. Load agent manifest from src/agents/{agent-id}.md.
   b. Resolve all component references: persona, domains, tools, schemas, rules.
   c. Collect normalized signals from .aegis/signals/ matching the agent's tool list.
   d. Collect findings from prior phases that reference the agent's domains.
2. Bundle context into agent session input.
3. Record agent invocation plan in .aegis/STATE.md.
</step>

<step name="invoke_agents" priority="blocking">
1. Identify parallel-eligible agents (those with `parallel_eligible: true`).
2. Invoke parallel-eligible agents concurrently.
3. Invoke remaining agents sequentially.
4. For each agent invocation:
   a. Provide: persona + domains + signals + schemas + rules.
   b. Instruct agent to produce findings conforming to the finding schema.
   c. Validate output against schema before accepting.
   d. If validation fails, return to agent with specific field-level errors.
5. Collect all agent outputs.
</step>

<step name="validate_outputs" priority="blocking">
1. For each agent's finding set:
   a. Validate every finding against src/schemas/finding.md.
   b. Validate confidence ratings against src/schemas/confidence.md.
   c. Check epistemic hygiene rules: evidence present, confidence justified,
      severity reasoned.
2. Flag findings that fail validation for agent revision.
3. Record validated finding counts in .aegis/STATE.md.
</step>

<step name="detect_disagreements" priority="blocking">
1. Compare findings across agents for the same domains.
2. Identify conflicts: same code area, different severity; same pattern,
   different assessment; contradictory recommendations.
3. For each disagreement:
   a. Create disagreement record conforming to src/schemas/disagreement.md.
   b. Write to .aegis/disagreements/{disagreement-id}.md.
4. If disagreements exist, queue disagreement-resolution workflow.
</step>

<step name="update_state" priority="blocking">
1. Update .aegis/STATE.md with:
   - Phase [N] completion status.
   - Finding counts by agent and domain.
   - Disagreement count and resolution status.
   - Timestamp.
2. Write finding files to .aegis/findings/{agent-id}.md.
</step>

</process>

<output>
Artifacts created:
- .aegis/findings/{agent-id}.md — Per-agent finding sets (one file per agent)
- .aegis/disagreements/{disagreement-id}.md — Disagreement records (if any)
- .aegis/STATE.md — Updated with phase completion and metrics

All output files must conform to their respective schemas.
</output>

<error_handling>
- **Missing prerequisites:** Halt immediately. Display which prerequisite is missing
  and which prior phase must be run.
- **Agent invocation failure:** Log failure, skip agent, continue with remaining agents.
  Record skipped agent in STATE.md. Warn user that coverage is incomplete.
- **Schema validation failure:** Return finding to agent with field-level errors.
  Allow up to 2 retry attempts. On third failure, log finding as "unvalidated"
  and flag for manual review.
- **Session timeout:** Save partial state to .aegis/STATE.md with status "interrupted".
  Allow resume from last completed step via session-handoff workflow.
- **All agents fail:** Halt phase. Record failure in STATE.md. Do not proceed to
  next phase.
</error_handling>
````

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Embedding domain knowledge | Workflows orchestrate; they do not analyze. "Check for SQL injection in the user input handlers" is domain knowledge that belongs in `src/domains/`. Workflows invoke agents who apply domain knowledge. |
| Embedding persona behavior | Workflows invoke agents; they do not define how agents think. "Apply an attacker mindset to this step" is persona content that belongs in `src/personas/`. Workflows specify *which* agent to invoke, not *how* it should reason. |
| Vague steps | "Analyze the codebase" is not a workflow step. Workflow steps must be specific and mechanical: load these files, invoke this agent, validate against this schema, write to this path. If a step requires judgment, it should be delegated to an agent, not described vaguely. |
| Missing session handoff specs | Multi-session workflows must explicitly define what passes between sessions. What state is persisted? What context is reloaded? What is lost? Without handoff specs, session boundaries become data loss boundaries. |
| Hardcoded agent lists | Workflows should reference agents via the manifest or phase configuration, not hardcode names. "Invoke security-engineer, then principal-engineer" breaks when agents are added or removed. Reference the set of agents assigned to this phase. |
| Missing error handling | Every workflow step that can fail must have a defined failure response. "If step fails, stop" is insufficient. What state is saved? Can the user resume? What diagnostic information is provided? |
