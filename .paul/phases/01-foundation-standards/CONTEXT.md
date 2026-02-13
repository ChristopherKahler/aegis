# Phase Context

**Phase:** 01 — Foundation Standards
**Generated:** 2026-02-12
**Status:** Ready for planning

## Goals

- Goal 1: Define AEGIS directory structure — where each of the 8 component types lives in the framework
- Goal 2: Define syntax conventions for all 8 component types — each type gets its own documented specification with tags, structure, frontmatter patterns, and naming rules
- Goal 3: Define cross-referencing patterns — how components reference each other (assembly manifests, domain mappings, tool affinities)
- Goal 4: Define version-locking specification — how audit runs record component versions for reproducibility and forensic-grade traceability
- Goal 5: Define `.aegis-template/` runtime structure — per-audit operational state and archival output format

## Approach

- Conventions-first: no content (schemas, agents, prompts) created until architecture is locked
- All 8 component types specified before any content is written in later phases
- Produces standards documentation that every subsequent phase must conform to
- After this phase completes: audit the entire roadmap against foundation standards, then overhaul roadmap

### The 8 Component Types

| Type | Count | Purpose |
|------|-------|---------|
| Personas | 12 | WHO — identity, risk philosophy, thinking style, confidence calibration |
| Domains | 14 | WHAT — failure patterns, questions, red flags, standards |
| Schemas | ~5 | HOW — output format contracts (finding, disagreement, confidence, signal, report) |
| Rules | few | CONSTRAINTS — epistemic hygiene, behavior governance |
| Tools | 7+ | INPUTS — adapter configs + normalization specs |
| Agents | 12 | ASSEMBLY — composition manifests (persona + domains + tools + schemas + rules) |
| Workflows | ~6 | ORCHESTRATION — phase sequencing, handoffs, resolution |
| Commands | ~4 | ENTRY — user-facing slash commands |

### Core Architectural Principle: Decomposed Agents

Agents are NOT monolithic prompt files. An agent is a runtime assembly:

```
Agent = Persona + Domains[] + Schemas + Rules + Tool Interfaces
```

This enables:
- Domain knowledge auditable independently
- Domains evolve independently of personas
- Tool mappings change independently of both
- Cross-agent reasoning consistency
- Versionable epistemic components

### Three-Layer Agent Design

- **Layer 1: Core Persona** — Identity, risk philosophy, thinking style, disagreement triggers, confidence calibration. Must be strong and distinct.
- **Layer 2: Domain Modules** — Structured knowledge bases. Failure patterns, audit questions, red flags, tool affinities, standards. Must be neutral and structured.
- **Layer 3: Execution Envelope** — Output schema, required evidence, confidence scoring, disagreement format, citation expectations. Shared contracts.

### Per-Audit Runtime: Two-Tier State

- `.aegis/` inside target repo — ephemeral operational state (resumption, current position)
- `audits/<timestamp>/` archival — immutable outputs with version-locked component references

### Version-Locked Compositions

Each audit run records:
- Persona version
- Domain version
- Tool config version
- Schema version
- Rules version

Enables reproducible, forensic-grade review artifacts.

## Constraints

- This phase produces architecture and conventions only — zero implementation content
- Must be framework-agnostic (AEGIS audits any codebase, any language)
- Must support the guided wizard UX pattern (users need entry points, not directory knowledge)
- Must be suitable for public GitHub repo (community-shared, well-documented)
- Standards must be concrete enough that a new Claude session can produce conforming files without ambiguity

## Open Questions

- Exact syntax choices per component type (derived during plan creation — study what each type needs structurally)
- Whether conventions are documented in a single standards file, per-type spec files, or both
- Whether to include example/skeleton files alongside convention docs
- Naming conventions for component files (kebab-case? numbered? domain-coded?)

## Additional Context

### What AEGIS Is

A reusable, installable, project-agnostic multi-agent codebase audit framework for Claude Code. Deploys 12 senior engineering personas across 14 audit domains with formal epistemic rigor, adversarial cross-validation, and structured disagreement resolution.

### Why Foundation Standards First

The original roadmap started with "Schemas & Data Contracts" but treated all artifacts as flat markdown. This discussion identified that AEGIS has 8 distinct component types, each requiring its own syntax conventions — like how PAUL framework distinguishes rules, workflows, references, templates, and commands with different structural patterns. Without this foundation, subsequent phases would produce inconsistent artifacts.

### Post-Phase Action

After this phase completes, the entire roadmap (Phases 2-7) gets audited against these standards and overhauled so every phase and plan specifies which component types it produces and conforms to the conventions defined here.

### Previous Plan 01-01

The original Plan 01-01 (core schemas: finding, disagreement, confidence) is obsolete. Schema content moves to a later phase after architecture is defined. The file remains in the phase directory for reference but will be superseded.

---

*This file is temporary. It informs planning but is not required.*
*Created by /paul:discuss, consumed by /paul:plan.*
