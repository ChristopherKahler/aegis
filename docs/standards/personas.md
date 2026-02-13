# Persona Convention

## Purpose

Personas define **WHO** an agent is. They encode identity, risk philosophy, thinking style, mental models, confidence calibration, and hard behavioral constraints. A persona is the cognitive fingerprint of an agent — it determines *how* the agent reasons, *what* it prioritizes, and *where* it draws lines.

Personas must be **strong and distinct**. When composed with domain modules at assembly time, a weak persona gets diluted — its reasoning style flattens into generic analysis. A strong persona maintains its character regardless of which domains it operates across. The security engineer should *think differently* from the principal engineer even when examining the same code.

AEGIS uses 12 persona files, one per agent identity.

## Location

```
src/personas/
```

## Naming

**Pattern:** `{kebab-name}.md`

**Examples:**
- `principal-engineer.md`
- `security-engineer.md`
- `sre.md`
- `devils-advocate.md`
- `data-engineer.md`
- `api-designer.md`

The kebab-name becomes the persona's `id` and is used as the reference key across the framework.

## Required Structure

Every persona file consists of YAML frontmatter followed by exactly 8 XML-tagged sections.

### Frontmatter (Required)

```yaml
---
id: {kebab-name}
name: [Display Name]
role: [One-line role description]
active_phases: [list of AEGIS phases 0-5 where this persona is active]
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Kebab-case identifier, must match filename without extension |
| `name` | string | yes | Human-readable display name |
| `role` | string | yes | One-line description of what this agent is responsible for |
| `active_phases` | list of integers | yes | AEGIS phases (0-5) where this persona participates |

### Body Sections (All Required)

Each section uses XML tags. Order matters — maintain the sequence below.

| Section | Tag | Purpose |
|---------|-----|---------|
| Identity | `<identity>` | Who this agent is. Role, core responsibility, what they are accountable for. |
| Mental Models | `<mental_models>` | How they think. Bulleted list of reasoning patterns and frameworks. |
| Risk Philosophy | `<risk_philosophy>` | Stance on risk. Conservative vs aggressive, what they worry about, what they deliberately ignore. |
| Thinking Style | `<thinking_style>` | Problem-solving approach. Deductive/inductive, depth-first/breadth-first, structured/exploratory. |
| Triggers | `<triggers>` | What raises concern. Specific patterns, signals, or absences that compel deeper investigation. |
| Argumentation | `<argumentation>` | How they argue and present findings. Communication style, evidence standards, rhetorical approach. |
| Confidence Calibration | `<confidence_calibration>` | Self-assessment methodology. When they are certain, when they hedge, how they express uncertainty. |
| Constraints | `<constraints>` | "Must never" rules. Hard, non-negotiable boundaries on this persona's behavior. |

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| Referenced BY | Agent assembly manifests (`src/agents/`) | `persona: {id}` field in agent frontmatter |
| Does NOT reference | Domains, tools, schemas, rules | Those are composed at assembly time, not baked into identity |

Personas are **leaf nodes** in the dependency graph. They reference nothing; they are only referenced.

## Example Skeleton

````markdown
---
id: security-engineer
name: Security Engineer
role: Identifies vulnerabilities, threat vectors, and security architecture weaknesses
active_phases: [1, 2, 3, 4]
---

<identity>
[Define who this agent is. What they are responsible for. What outcomes they own.
Be specific — not "reviews security" but "identifies exploitable vulnerabilities,
evaluates threat models, and assesses whether security controls match the
application's risk profile."]
</identity>

<mental_models>
- [Mental model 1 — e.g., "Attacker mindset: always asks 'how would I break this?'"]
- [Mental model 2 — e.g., "Defense in depth: single controls are insufficient"]
- [Mental model 3 — e.g., "Least privilege: every permission is a potential attack surface"]
- [Additional models as appropriate for this persona]
</mental_models>

<risk_philosophy>
[Describe this persona's relationship with risk. Are they conservative or aggressive?
What categories of risk keep them up at night? What do they deliberately deprioritize?
Example: "Treats any unauthenticated endpoint as critical regardless of data sensitivity.
Willing to accept performance trade-offs for security guarantees. Ignores cosmetic
code quality issues unless they mask security concerns."]
</risk_philosophy>

<thinking_style>
[How does this persona approach a problem? Do they enumerate attack surfaces
systematically or follow intuition to high-risk areas? Do they work from
the perimeter inward or from sensitive data outward? Are they exhaustive
or targeted?]
</thinking_style>

<triggers>
- [Trigger 1 — e.g., "Any use of `eval()`, `exec()`, or dynamic code execution"]
- [Trigger 2 — e.g., "Authentication logic that isn't centralized"]
- [Trigger 3 — e.g., "Absence of rate limiting on public endpoints"]
- [Trigger 4 — e.g., "Secrets or credentials adjacent to source code"]
- [Additional triggers specific to this persona's concerns]
</triggers>

<argumentation>
[How does this persona present findings? Do they lead with impact or evidence?
Do they use formal severity frameworks or narrative risk descriptions?
Example: "Leads with exploitability — always demonstrates a plausible attack
path before discussing remediation. Cites CWE/CVE identifiers when applicable.
Distinguishes between theoretical and practical risk."]
</argumentation>

<confidence_calibration>
[When is this persona highly confident? When do they hedge? How do they
communicate uncertainty?
Example: "High confidence when a known CVE matches an exact dependency version.
Medium confidence on architectural weaknesses that require specific deployment
conditions. Low confidence on business logic flaws outside their security domain.
Always states assumptions explicitly when confidence is below high."]
</confidence_calibration>

<constraints>
- [Constraint 1 — e.g., "Must never dismiss a finding based on 'it's only internal'"]
- [Constraint 2 — e.g., "Must never assume network segmentation exists without evidence"]
- [Constraint 3 — e.g., "Must never recommend 'security through obscurity' as a control"]
- [Additional hard boundaries]
</constraints>
````

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Embedding domain-specific failure patterns | Failure patterns belong in `src/domains/` files. A persona defines *how* an agent thinks, not *what* it knows about specific failure modes. Mixing these makes personas impossible to compose with different domain sets. |
| Listing specific tools or their outputs | Tool knowledge belongs in `src/tools/` files. Personas should not know or care which tools exist. They interpret signals; they don't operate scanners. |
| Including output format specifications | Output structure belongs in `src/schemas/` files. A persona reasons; a schema structures the output of that reasoning. |
| Making the persona so generic it could be any agent | If you can swap two persona files and behavior wouldn't change, the personas are too weak. Each persona must have a *distinctive* reasoning fingerprint — different mental models, different triggers, different risk stances. |
| Describing what the persona does instead of who they are | "Analyzes code for security issues" is a job description. "Thinks like an attacker, assumes every input is hostile, traces data flow from entry to storage" is an identity. Write identity, not job descriptions. |
| Overlapping constraints between personas | Constraints that apply to ALL agents belong in `src/rules/`, not in individual personas. Persona constraints are unique to that persona's boundaries. |
