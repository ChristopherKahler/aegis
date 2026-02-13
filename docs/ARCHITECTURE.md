# AEGIS Architecture

**Automated Epistemic Governance & Intelligence System**

Multi-agent codebase audit framework with decomposed components and forensic-grade traceability.

---

## 1. Directory Structure

| Directory | Purpose |
|-----------|---------|
| `src/commands/` | User entry points — slash commands that invoke workflows (`/aegis:audit`, `/aegis:resume`) |
| `src/personas/` | Identity definitions — 12 core personas defining how agents think, argue, and calibrate confidence |
| `src/domains/` | Knowledge modules — 14 domain-specific failure patterns, questions, and red flags (00-13) |
| `src/schemas/` | Output contracts — Finding structure, disagreement records, confidence vectors, signal format, report sections |
| `src/rules/` | Epistemic governance — Behavioral constraints applied universally to all agents |
| `src/tools/` | Tool integrations — Adapter configs and output normalizers for semgrep, trivy, syft/grype, etc. |
| `src/agents/` | Assembly manifests — Composition definitions specifying which persona + domains + tools + schemas form each agent |
| `src/workflows/` | Phase orchestration — Step-by-step execution logic for each audit phase |
| `docs/` | Documentation root — Architecture, standards, getting started, user guide |
| `docs/standards/` | Convention specifications — Per-component-type standards (persona standard, domain standard, etc.) |
| `.aegis-template/` | Audit workspace scaffold — Copied into target repo at audit start, contains STATE.md, MANIFEST.md, output directories |
| `.aegis-template/context/` | Phase 0 outputs — Codebase understanding signals |
| `.aegis-template/signals/` | Phase 1 outputs — Raw tool execution results normalized to signal schema |
| `.aegis-template/findings/` | Phase 2 outputs — Domain-specific audit findings from individual agents |
| `.aegis-template/review/` | Phase 3 outputs — Cross-agent disagreement resolution and confidence calibration |
| `.aegis-template/report/` | Phase 4 outputs — Final audit report and executive summary |

---

## 2. Component Model

### Component Types

| Type | Count | Purpose | Defines | Referenced By |
|------|-------|---------|---------|---------------|
| **Personas** | 12 | WHO — identity, risk philosophy, thinking style | How an agent thinks, argues, calibrates confidence | Agent assembly manifests |
| **Domains** | 14 | WHAT — failure patterns, questions, red flags | What to audit, what to look for, what matters | Agent assembly manifests, tool affinities |
| **Schemas** | ~5 | HOW — output format contracts | Finding structure, disagreement records, confidence vectors, signal format, report sections | All agents (output), workflows (validation) |
| **Rules** | few | CONSTRAINTS — epistemic governance | Behavioral constraints that apply to ALL agents | All agents (enforcement) |
| **Tools** | 7+ | INPUTS — signal sources + normalization | How to run tools, parse output, normalize to signal schema | Domain affinities, workflow orchestration |
| **Agents** | 12 | ASSEMBLY — composition manifests | Which persona + domains + tools + schemas + rules compose each agent | Workflows (invocation) |
| **Workflows** | ~8 | ORCHESTRATION — phase sequencing | Step-by-step execution logic for each audit phase | Commands (delegation) |
| **Commands** | ~4 | ENTRY — user-facing slash commands | Guided wizard UX entry points | Users (invocation) |

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
Load the persona: @src/personas/security-engineer.md
```

Files are read when needed, not preloaded.

### Assembly References (Component IDs)

Used in agent manifests to reference components by ID:

```yaml
persona: security-engineer
```

Resolved at runtime to `src/personas/security-engineer.md` based on component ID in frontmatter.

### Domain Mapping (Numeric IDs)

Used in agent manifests to reference domains by number:

```yaml
domains: [04, 05, 06]
```

Maps to `src/domains/04-security.md`, `src/domains/05-dependencies.md`, `src/domains/06-secrets.md`.

### Tool Affinity (Tool IDs)

Used in domain files to declare preferred tools:

```yaml
tool_affinities: [semgrep, trivy, syft-grype]
```

References tool IDs defined in `src/tools/{tool-id}.md`.

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
| **Workflow file naming** | `phase-{N}-{kebab-name}.md` | `phase-0-context.md`, `phase-2-domain-audits.md` |
| **Command file naming** | `{kebab-name}.md` | `audit.md`, `resume.md` |

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

---

**See Also:**

- `README.md` — Source of truth for AEGIS design philosophy
- `docs/GETTING-STARTED.md` — Quickstart guide
- `docs/USER-GUIDE.md` — Command reference and workflows
- `docs/standards/` — Per-component-type conventions and specifications
