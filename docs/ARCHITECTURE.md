# AEGIS Architecture

**Automated Epistemic Governance & Intelligence System**

Multi-agent codebase audit framework with decomposed components and forensic-grade traceability.

---

## 1. Directory Structure

### Two-System Layout

AEGIS is organized as two systems sharing common infrastructure:

```
aegis/
├── src/
│   ├── core/                       # AEGIS Core (Diagnosis Engine)
│   │   ├── commands/               # Core user entry points (/aegis:audit, /aegis:resume)
│   │   ├── personas/               # 12 Core audit personas
│   │   ├── agents/                 # 12 Core agent assemblies
│   │   └── workflows/              # Core phase orchestration (Phases 0-5)
│   ├── transform/                  # AEGIS Transform (Controlled Evolution Engine)
│   │   ├── commands/               # Transform entry points (/aegis:transform, /aegis:remediate)
│   │   ├── personas/               # 5 Transform personas
│   │   ├── schemas/                # Transform-specific schemas (playbook, change-risk, verification)
│   │   ├── rules/                  # Safety & liability rules
│   │   ├── agents/                 # 5 Transform agent assemblies
│   │   ├── workflows/              # Transform phase orchestration (Phases 6-8)
│   │   └── patterns/               # Pattern corpus (accumulated over time)
│   ├── domains/                    # Shared — 14 domain knowledge modules (Core + Transform)
│   ├── schemas/                    # Shared — Core output contracts (finding, disagreement, signal, etc.)
│   ├── rules/                      # Shared — Epistemic governance (applies to all agents)
│   └── tools/                      # Shared — Tool adapters and output normalizers
├── docs/
│   ├── ARCHITECTURE.md             # This file
│   ├── standards/                  # Per-component-type conventions
│   └── ...
└── .aegis-template/                # Audit workspace scaffold
    ├── context/                    # Phase 0 outputs
    ├── signals/                    # Phase 1 outputs
    ├── findings/                   # Phase 2-3 outputs
    ├── review/                     # Phase 4 outputs
    ├── report/                     # Phase 5 outputs
    ├── remediation/                # Phase 6-7 outputs (Layer B)
    └── execution/                  # Phase 8 outputs (Layer C)
```

### Component Directory Reference

| Directory | System | Purpose |
|-----------|--------|---------|
| `src/core/commands/` | Core | User entry points — slash commands that invoke Core workflows |
| `src/core/personas/` | Core | Identity definitions — 12 Core personas defining how agents think, argue, and calibrate confidence |
| `src/core/agents/` | Core | Assembly manifests — 12 Core agent compositions |
| `src/core/workflows/` | Core | Phase orchestration — Execution logic for Phases 0-5 |
| `src/transform/commands/` | Transform | User entry points — slash commands that invoke Transform workflows |
| `src/transform/personas/` | Transform | Identity definitions — 5 Transform personas for intervention specialists |
| `src/transform/schemas/` | Transform | Transform-specific output contracts (playbook, change-risk, verification-plan) |
| `src/transform/rules/` | Transform | Safety & liability rules (confidence gating, conservative bias, no auto-execution) |
| `src/transform/agents/` | Transform | Assembly manifests — 5 Transform agent compositions |
| `src/transform/workflows/` | Transform | Phase orchestration — Execution logic for Phases 6-8 |
| `src/transform/patterns/` | Transform | Pattern corpus — Accumulated anti-pattern/remediation pairs |
| `src/domains/` | Shared | Knowledge modules — 14 domain-specific failure patterns, questions, and red flags |
| `src/schemas/` | Shared | Core output contracts — Finding, disagreement, confidence, signal, report schemas |
| `src/rules/` | Shared | Epistemic governance — Behavioral constraints applied to all agents |
| `src/tools/` | Shared | Tool integrations — Adapter configs and output normalizers |
| `docs/` | — | Documentation root — Architecture, standards, guides |
| `docs/standards/` | — | Convention specifications — Per-component-type standards |
| `.aegis-template/` | — | Audit workspace scaffold — Copied into target repo at audit start |

---

## 2. Component Model

### Component Types

| Type | Count | System | Purpose | Defines | Referenced By |
|------|-------|--------|---------|---------|---------------|
| **Personas** | 12 + 5 | Core / Transform | WHO — identity, risk philosophy, thinking style | How an agent thinks, argues, calibrates confidence | Agent assembly manifests |
| **Domains** | 14 | Shared | WHAT — failure patterns, questions, red flags, best practices | What to audit, what to look for, what matters | Agent assembly manifests, tool affinities |
| **Schemas** | ~5 + ~4 | Shared / Transform | HOW — output format contracts | Finding, disagreement, confidence, signal, report (Core) + playbook, change-risk, intervention-level, verification-plan (Transform) | All agents (output), workflows (validation) |
| **Rules** | few + few | Shared / Transform | CONSTRAINTS — epistemic governance + safety governance | Behavioral constraints for all agents (Core) + safety rules for Transform agents | All agents (enforcement) |
| **Tools** | 7+ | Shared | INPUTS — signal sources + normalization | How to run tools, parse output, normalize to signal schema | Domain affinities, workflow orchestration |
| **Agents** | 12 + 5 | Core / Transform | ASSEMBLY — composition manifests | Which persona + domains + tools + schemas + rules compose each agent | Workflows (invocation) |
| **Workflows** | ~8 + ~4 | Core / Transform | ORCHESTRATION — phase sequencing | Step-by-step execution logic for each phase | Commands (delegation) |
| **Commands** | ~4 + ~4 | Core / Transform | ENTRY — user-facing slash commands | Guided wizard UX entry points | Users (invocation) |

### Decomposed Agent Architecture

**Core Design Principle:**

```
Agent = Persona + Domains[] + Schemas + Rules + Tool Interfaces
```

**Three-Layer Model:**

1. **Core Persona (strong/distinct)** — Unique identity, risk philosophy, argumentation style
2. **Domain Modules (neutral/structured)** — Pluggable knowledge modules defining what to audit
3. **Execution Envelope (shared contracts)** — Common schemas, rules, and tool interfaces

**Why Monolithic Agents Are Wrong:**

- **Many-to-many relationships:** 14 domains ≠ 12 agents. A security engineer covers 3-4 domains. A frontend specialist covers 2-3 different domains. Monolithic agents force artificial 1:1 mapping.
- **Independent auditability:** Domain knowledge (e.g., "what makes authentication weak") must be auditable, versioned, and testable independently of any specific agent's persona.
- **Independent evolution:** Domains evolve based on industry standards and CVE databases. Personas evolve based on role archetypes. Tool mappings evolve based on tooling ecosystem changes. These three axes are orthogonal.
- **Version-locked compositions:** A reproducible audit requires locking specific versions of persona, domains, schemas, rules, and tools. This is impossible with monolithic agents where all components are entangled in a single file.
- **Reusability:** The same domain (e.g., "05-dependencies") is used by multiple agents (Security Engineer, SRE, Principal Engineer). Duplication creates maintenance burden and version drift.

### Two-System Model

AEGIS operates as two complementary systems sharing common infrastructure.

**Shared components** (used by both Core and Transform):
- **Domains** (`src/domains/`) — Transform agents consume domain knowledge to contextualize remediation. The same failure patterns that Core agents detect are the patterns Transform agents remediate.
- **Core schemas** (`src/schemas/`) — Transform agents consume Layer A outputs (findings, disagreements, confidence) as input. The schemas that define these structures are shared.
- **Core rules** (`src/rules/`) — Epistemic governance applies to all agents. Transform agents must meet the same evidence and confidence standards.
- **Tool adapters** (`src/tools/`) — Some tools produce signals consumed by both systems (e.g., git history mining feeds both change risk analysis and remediation context).

**Separate components** (system-specific):
- **Personas** — Core personas are domain experts optimized for finding truth. Transform personas are intervention specialists optimized for producing safe, actionable change. These are fundamentally different cognitive profiles.
- **Agents** — Core agents work independently (decentralized diagnosis). Transform agents coordinate (centralized intervention). Different assembly patterns.
- **Workflows** — Core workflows orchestrate Phases 0-5. Transform workflows orchestrate Phases 6-8. Different execution models (parallel vs sequential).
- **Commands** — Core commands start and manage audits. Transform commands initiate remediation pipelines.
- **Transform schemas** — Playbook, change-risk, verification-plan schemas are Transform-specific. Core has no use for them.
- **Transform rules** — Safety and liability rules (confidence gating, conservative bias, no auto-execution) apply only to Transform agents.

**Why separation matters:** Diagnosis and intervention have different cognitive requirements. A diagnostic agent should be aggressive about finding problems — false negatives are worse than false positives. A Transform agent should be conservative about proposing changes — a bad fix is worse than no fix. Mixing these postures in a single system produces mediocre diagnosis and reckless intervention.

**How they connect:** Core Layer A outputs feed Transform Layer B/C inputs. The connection point is the `.aegis/` directory — specifically the `findings/`, `review/`, and `report/` directories that Transform reads as input.

### Output Layer Architecture

AEGIS produces three output layers with a strict derivation chain:

```
Layer A (Phases 0-5)  →  Layer B (Phases 6-7)  →  Layer C (Phase 8)
Diagnostic artifacts     Remediation knowledge     Change orchestration
Immutable               Derived from A             Derived from B
```

**Layer A → Layer B:** Findings + domain knowledge + confidence scores → remediation playbooks, best-practice patterns, educational context, guardrails.

**Layer B → Layer C:** Playbooks + risk scores → dependency-ordered execution plans, verification steps, PAUL project artifacts.

**Dual format specification:** Every Layer B and Layer C artifact has two representations:
- **Human-readable** (`.md`) — Explanations, rationale, before/after examples, educational context
- **Machine-consumable** (`.yaml`) — Structured data with file targets, change instructions, verification steps, risk metadata, intervention level

This dual format ensures that both human developers and AI assistants can consume Transform output effectively.

---

## 3. Component Relationships

| Relationship | Type | Description |
|-------------|------|-------------|
| **Agents → Personas** | one-to-one | Each agent references exactly one persona defining its identity and thinking style |
| **Agents → Domains** | one-to-many | Each agent covers 1-3 domains depending on role scope |
| **Domains → Tools** | many-to-many | Multiple tools feed multiple domains (e.g., semgrep feeds security and code quality) |
| **Agents → Schemas** | many-to-shared | All agents use the same schema contracts for findings, disagreements, signals, reports |
| **Rules → Agents** | global | Rules constrain all agent behavior universally (epistemic hygiene applies to all) |
| **Workflows → Agents** | invocation | Workflows assemble and invoke agents per phase (e.g., Phase 2 invokes all domain agents) |
| **Commands → Workflows** | delegation | Commands delegate to workflows for execution (e.g., `/aegis:audit` → `phase-0-context.md`) |

---

## 4. Cross-Referencing Patterns

### @-References (Lazy-Load)

Used in workflows and commands to lazy-load files at execution time:

```markdown
Load the persona: @src/core/personas/security-engineer.md
Load the Transform persona: @src/transform/personas/remediation-architect.md
Load the shared domain: @src/domains/04-security.md
```

Files are read when needed, not preloaded. Note: system prefix (`core/` or `transform/`) is required for system-specific components. Shared components use root `src/` paths.

### Assembly References (Component IDs)

Used in agent manifests to reference components by ID:

```yaml
persona: security-engineer
```

Resolved at runtime to the appropriate system path based on which system the agent belongs to.

### Domain Mapping (Numeric IDs)

Used in agent manifests to reference domains by number:

```yaml
domains: [04, 05, 06]
```

Maps to `src/domains/04-security.md`, `src/domains/05-dependencies.md`, `src/domains/06-secrets.md`. Domains are shared — the same path works for both Core and Transform agents.

### Tool Affinity (Tool IDs)

Used in domain files to declare preferred tools:

```yaml
tool_affinities: [semgrep, trivy, syft-grype]
```

References tool IDs defined in `src/tools/{tool-id}.md`.

### Transform Cross-References

Transform agents reference Core outputs:

```markdown
# In a Transform workflow or agent context:
@.aegis/findings/{agent-id}/finding-NNN.md    # Reference specific Core finding
@.aegis/report/findings-by-domain.md           # Reference Core synthesis
@src/domains/04-security.md                     # Reference shared domain knowledge
```

Remediation playbooks reference both findings and domain best practices:

```yaml
# In a Layer B playbook:
finding_ref: F-04-001                           # Core finding being remediated
domain_ref: domain-04                           # Domain providing best-practice context
intervention_level: planning                    # Intervention classification
```

Layer C plans reference Layer B evidence:

```yaml
# In a Layer C execution plan:
playbook_ref: playbook-F-04-001                # Layer B playbook being executed
risk_assessment_ref: risk-F-04-001             # Change risk assessment
verification_ref: verify-F-04-001              # Verification plan
```

---

## 5. Naming Conventions

| Element | Convention | Examples |
|---------|-----------|----------|
| **Files** | kebab-case.md | `security-engineer.md`, `finding.md` |
| **Directories** | kebab-case | `src/personas/`, `docs/standards/` |
| **Component IDs** | kebab-case in frontmatter | `id: security-engineer`, `id: domain-04` |
| **Domain numbering** | DD format (00-13) | `00-context.md`, `04-security.md` |
| **Domain file naming** | `{DD}-{kebab-name}.md` | `00-context.md`, `13-risk-synthesis.md` |
| **Persona file naming** | `{kebab-name}.md` | `principal-engineer.md`, `sre.md` |
| **Agent file naming** | `{kebab-name}.md` (matches persona) | `security-engineer.md` |
| **Tool file naming** | `{kebab-name}.md` | `semgrep.md`, `syft-grype.md` |
| **Schema file naming** | `{kebab-name}.md` | `finding.md`, `disagreement.md` |
| **Rule file naming** | `{kebab-name}.md` | `epistemic-hygiene.md` |
| **Workflow file naming** | `phase-{N}-{kebab-name}.md` | `phase-0-context.md`, `phase-2-domain-audits.md`, `phase-6-remediation.md` |
| **Command file naming** | `{kebab-name}.md` | `audit.md`, `resume.md`, `transform.md`, `remediate.md` |
| **Playbook file naming** | `playbook-{finding-id}.md/yaml` | `playbook-F-04-001.md`, `playbook-F-04-001.yaml` |
| **Risk assessment naming** | `risk-{finding-id}.yaml` | `risk-F-04-001.yaml` |
| **Verification plan naming** | `verify-{finding-id}.md` | `verify-F-04-001.md` |

**Conventions:**

- All filenames use lowercase with hyphens (kebab-case)
- Component IDs in frontmatter match filename without extension
- Domains use zero-padded two-digit prefixes (00-13)
- Workflows use phase number prefix (phase-0, phase-1, etc.)
- No spaces, underscores, or special characters in filenames

---

## 6. Version-Locking

### Purpose

Forensic-grade traceability and reproducibility. Given the same codebase state and the same MANIFEST.md, the audit results are reproducible.

### Mechanism

Each audit run creates a `MANIFEST.md` in `.aegis/` recording:

1. **Audit Metadata:**
   - Audit start timestamp
   - Target repository path and git commit hash
   - AEGIS version and git commit hash

2. **Component Versions Table:**

| Component Type | File Path | SHA-256 Hash |
|---------------|-----------|--------------|
| Persona | `src/personas/security-engineer.md` | `a1b2c3d4...` |
| Domain | `src/domains/04-security.md` | `e5f6g7h8...` |
| Schema | `src/schemas/finding.md` | `i9j0k1l2...` |
| Rule | `src/rules/epistemic-hygiene.md` | `m3n4o5p6...` |
| Tool | `src/tools/semgrep.md` | `q7r8s9t0...` |
| Agent | `src/agents/security-engineer.md` | `u1v2w3x4...` |
| Workflow | `src/workflows/phase-2-domain-audits.md` | `y5z6a7b8...` |

### Lifecycle

- **Created:** At audit start (Phase 0 initialization)
- **Updated:** As each component is loaded and used during execution
- **Finalized:** At audit completion with final checksums
- **Archived:** Stored permanently with audit outputs in `.aegis/`

### Use Cases

- **Reproducibility:** Re-run the same audit with the same component versions
- **Debugging:** Identify which component version caused a specific finding
- **Compliance:** Provide audit trail for security or regulatory requirements
- **Regression Testing:** Verify that component changes don't alter audit behavior unexpectedly

---

## Design Principles

1. **Separation of Concerns:** Identity (personas), knowledge (domains), contracts (schemas), constraints (rules), and execution (workflows) are separate components.
2. **Composability:** Agents are assembled from reusable components, not monolithic files.
3. **Traceability:** Every component is versioned and locked at audit runtime.
4. **Auditability:** Domain knowledge is independently testable and versionable.
5. **Flexibility:** Components evolve independently on orthogonal axes (personas, domains, tools, schemas).
6. **Reproducibility:** Same codebase + same manifest = same audit results.
7. **Two-System Separation:** Diagnosis (Core) and intervention (Transform) have separate personas, agents, and workflows. Shared infrastructure (domains, core schemas, rules, tools) prevents duplication.
8. **Dual Format Output:** Transform artifacts carry both human-readable markdown and machine-consumable structured data.
9. **Conservative Intervention:** Transform defaults to the lowest intervention level. Escalation requires evidence, not confidence.

---

**See Also:**

- `README.md` — Source of truth for AEGIS design philosophy
- `docs/GETTING-STARTED.md` — Quickstart guide
- `docs/USER-GUIDE.md` — Command reference and workflows
- `docs/standards/` — Per-component-type conventions and specifications
