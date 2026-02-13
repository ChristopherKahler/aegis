# Domain Convention

## Purpose

Domains define **WHAT** to audit. They encode failure patterns, audit questions, red flags, tool affinities, and relevant standards for a specific area of technical concern. A domain is a structured knowledge base — neutral, factual, and independent of any persona's reasoning style.

Domains are the *subject matter* that agents apply their personas against. The security persona applies its attacker mindset to the security domain's failure patterns. The SRE persona applies its reliability thinking to the observability domain's red flags. The domain supplies the knowledge; the persona supplies the reasoning.

Domains also supply the best-practice pattern knowledge that Transform agents use when producing remediation. A domain that only describes failures without corresponding correct patterns cannot feed the Transform pipeline.

AEGIS uses 14 domain files, numbered 00-13, covering the full surface area of a codebase audit.

## Location

```
src/domains/
```

## Naming

**Pattern:** `{DD}-{kebab-name}.md`

The two-digit prefix (`DD`) establishes canonical ordering and serves as the domain's numeric identifier across the framework.

**Examples:**
- `00-context.md`
- `01-architecture.md`
- `04-security.md`
- `07-testing.md`
- `13-risk-synthesis.md`

## Required Structure

Every domain file consists of YAML frontmatter followed by 7 markdown-headed sections.

### Frontmatter (Required)

```yaml
---
id: domain-{DD}
number: {DD}
name: [Domain Name]
owner_agents: [list of agent IDs that cover this domain]
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | `domain-` prefix followed by two-digit number |
| `number` | string | yes | Two-digit domain number (e.g., `00`, `04`, `13`) |
| `name` | string | yes | Human-readable domain name |
| `owner_agents` | list of strings | yes | Agent IDs (from `src/agents/`) responsible for this domain |

### Body Sections (All Required)

Sections use standard markdown headers (`##`), not XML tags. Order matters.

| Section | Header | Purpose |
|---------|--------|---------|
| Overview | `## Overview` | What this domain covers and why it matters to an audit. |
| Audit Questions | `## Audit Questions` | Specific questions an agent should answer about this domain. Bulleted list. |
| Failure Patterns | `## Failure Patterns` | Known failure modes. Each with: pattern name, description, indicators, severity tendency. |
| Best Practice Patterns | `## Best Practice Patterns` | Correct patterns that correspond to each failure pattern. Required for Transform remediation. |
| Red Flags | `## Red Flags` | Quick indicators that something is wrong. Bulleted list of observable signals. |
| Tool Affinities | `## Tool Affinities` | Which tools produce signals relevant to this domain. Structured table. |
| Standards & Frameworks | `## Standards & Frameworks` | Relevant industry standards. Bulleted list with brief relevance notes. |
| Metrics | `## Metrics` | Quantifiable measurements. Structured table with healthy ranges. |

## Cross-References

| Direction | What | How |
|-----------|------|-----|
| Referenced BY | Agent assembly manifests (`src/agents/`) | `domains: [{DD}, {DD}]` field in agent frontmatter |
| References | Tool IDs (`src/tools/`) | In the Tool Affinities section table |
| Does NOT reference | Personas, schemas, rules | Domain knowledge is neutral; persona reasoning is applied at runtime |
| Referenced BY | Transform agents (`src/transform/agents/`) | Transform agents consume domain best-practice patterns for remediation context |

## Example Skeleton

````markdown
---
id: domain-04
number: "04"
name: [Security]
owner_agents: [security-engineer]
---

## Overview

[What this domain covers. Scope boundaries — what's included and what's explicitly
excluded. Why this domain matters in the context of a codebase audit.

Example: "Covers application-layer security: authentication, authorization, input
validation, cryptography, secrets management, and dependency vulnerabilities.
Does NOT cover infrastructure/network security (that's domain-06) or compliance
frameworks (domain-12)."]

## Audit Questions

- [Question 1 — e.g., "Are all user inputs validated and sanitized before processing?"]
- [Question 2 — e.g., "Is authentication centralized or scattered across the codebase?"]
- [Question 3 — e.g., "Are secrets hardcoded, environment-injected, or vault-managed?"]
- [Question 4 — e.g., "Do dependencies have known CVEs at the versions in use?"]
- [Question 5 — e.g., "Is authorization checked at every access point or only at the perimeter?"]
- [Additional questions — aim for 8-15 per domain]

## Failure Patterns

### [Pattern Name — e.g., "Broken Authentication"]

- **Description:** [What this failure pattern is. One to two sentences.]
- **Indicators:** [Observable signals that this pattern may be present]
  - [Indicator 1 — e.g., "Custom authentication logic instead of framework-provided"]
  - [Indicator 2 — e.g., "Session tokens with predictable patterns"]
  - [Indicator 3 — e.g., "Missing account lockout after failed attempts"]
- **Severity Tendency:** [typical severity — critical | high | medium | low]

### [Pattern Name — e.g., "Injection Vulnerabilities"]

- **Description:** [What this failure pattern is.]
- **Indicators:**
  - [Indicator 1]
  - [Indicator 2]
- **Severity Tendency:** [typical severity]

[Repeat for each failure pattern. Aim for 5-10 per domain.]

## Best Practice Patterns

### [Pattern Name — e.g., "Centralized Authentication"]

- **Replaces Failure Pattern:** [Which failure pattern this corrects — e.g., "Broken Authentication"]
- **Abstract Pattern:** [Language-agnostic principle — e.g., "Authentication should be handled by a single, well-tested module that all request handlers delegate to"]
- **Framework Mappings:**
  - [Framework 1]: [Implementation — e.g., "Laravel: Use middleware guards with `auth:sanctum`"]
  - [Framework 2]: [Implementation — e.g., "Express: Use passport.js with centralized strategy configuration"]
  - [Framework 3]: [Implementation — e.g., "Spring Boot: Use Spring Security filter chain"]
- **Language Patterns:**
  - [Language 1]: [Pattern — e.g., "PHP: `Auth::check()` middleware, never inline credential comparison"]
  - [Language 2]: [Pattern — e.g., "Node.js: JWT verification middleware with centralized secret management"]

[Repeat for each best practice pattern. Every failure pattern should have a corresponding best practice.]

## Red Flags

- [Red flag 1 — e.g., "Any file named `password`, `secret`, or `key` in source tree"]
- [Red flag 2 — e.g., "HTTP endpoints accepting user input without validation middleware"]
- [Red flag 3 — e.g., "Commented-out authentication checks"]
- [Red flag 4 — e.g., "Use of MD5 or SHA1 for password hashing"]
- [Additional red flags — quick, observable signals]

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| [semgrep] | [Static analysis findings for injection, auth, crypto patterns] | [primary] |
| [gitleaks] | [Detected secrets and credentials in source] | [primary] |
| [trivy] | [Known CVEs in dependencies] | [supporting] |
| [syft-grype] | [SBOM-based vulnerability matching] | [supporting] |

Relevance levels: `primary` (core signal source), `supporting` (supplementary data), `contextual` (useful but not essential).

## Standards & Frameworks

- [OWASP Top 10 — application security risk taxonomy]
- [CWE/SANS Top 25 — most dangerous software weaknesses]
- [NIST SP 800-53 — security and privacy controls (relevant sections)]
- [Additional standards relevant to this domain]

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| [Critical CVE count] | [Number of critical-severity known vulnerabilities in dependencies] | [0] |
| [Secrets detected] | [Count of hardcoded secrets or credentials in source] | [0] |
| [Input validation coverage] | [Percentage of user-input endpoints with validation] | [95-100%] |
| [Auth centralization ratio] | [Percentage of auth logic in centralized modules vs scattered] | [>90% centralized] |
````

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Embedding persona reasoning style | Writing "A security engineer would think..." imports persona logic into domain knowledge. Domains are neutral knowledge bases. The persona applies its reasoning *to* the domain at runtime. |
| Including risk judgments or severity assessments | Severity tendency in failure patterns describes *typical* severity, not assessed severity. Actual severity assessment happens in phases 6-7 when agents apply judgment. Domains provide the raw patterns, not the verdict. |
| Making tool affinities prescriptive | "You MUST run Semgrep" is prescriptive. "Semgrep produces relevant signals for this domain" is descriptive. Workflows decide what runs; domains describe what's useful. |
| Opinion leaking into failure patterns | "This terrible pattern" or "developers often lazily..." introduces bias. Failure patterns are factual: here is the pattern, here are its indicators, here is its typical severity. No editorializing. |
| Mixing domain scopes | Each domain has clear boundaries. Security does not discuss testing strategy. Architecture does not discuss deployment. If a concern spans domains, each domain covers its slice and cross-references are handled at the agent level through multi-domain assignments. |
| Omitting the Tool Affinities section | Even if a domain has no direct tool signals, state that explicitly. An empty section with "No direct tool signals; this domain relies on manual analysis and agent reasoning" is better than a missing section. |
| Domains that only describe failures | A domain without best-practice patterns cannot feed Transform remediation. Anti-patterns without corresponding correct patterns produce diagnosis without treatment. |
| Generic best practices without framework mapping | A best practice that says "use authentication middleware" without framework-specific implementations is not actionable at Layers 2-4 of the transformation model. |
