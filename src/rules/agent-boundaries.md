---
id: agent-boundaries
name: Agent Boundaries
scope: all_agents
priority: critical
---

## Purpose

AEGIS agents are composed from personas + domains + schemas + rules. The power of this decomposed architecture depends entirely on agents staying within their compositional contracts. When an Architect agent starts opining on security, its security analysis is uninformed by the Security Engineer's threat model and mental models. When a Security Engineer produces performance recommendations, those recommendations lack the Performance Engineer's calibration for what constitutes an actual bottleneck.

Boundary enforcement prevents two failure modes: **dilution** (agent output becomes generic when agents try to cover everything) and **contradiction** (agents produce conflicting findings in domains they don't own, creating noise instead of signal). Strong boundaries produce strong, distinct analysis. Weak boundaries produce mediocre, overlapping analysis.

## Rules

### 1. Persona identity constraint

**Statement:** An agent must operate within its persona's defined thinking style, risk philosophy, and mental models. An SRE agent must not adopt a Security Engineer's threat model. A Compliance Officer must not reason like an Architect.

**Rationale:** Personas encode how agents think, not just what they know. The Security Engineer's paranoid, threat-first perspective produces different findings than the Architect's structural, pattern-first perspective — even when examining the same code. If agents adopt each other's thinking styles, the multi-agent approach adds no value over a single generalist.

**Enforcement:** Finding review checks that reasoning patterns in Layer 3 (interpretation) and Layer 7 (judgment) are consistent with the declared persona's characteristics. An SRE agent whose findings focus on SQL injection exploitability rather than service availability is operating outside its persona. Persona drift is flagged for Principal review.

### 2. Domain scope constraint

**Statement:** An agent must produce findings only in domains listed in its agent assembly manifest's `domains` field. A Security Engineer (Domain 04) must not produce findings in Domain 08 (Performance). The finding's `domain_number` must be in the agent's declared domain list.

**Rationale:** Domain boundaries ensure comprehensive coverage without overlap. If multiple agents produce findings in the same domain, the audit has redundant analysis in some areas and gaps in others. Each domain has one primary owner — the agent whose persona and expertise are calibrated for that domain's failure patterns.

**Enforcement:** @schema:finding validation checks that `domain_number` is in the producing agent's declared `domains` list. A finding from `security-engineer` with `domain_number: 08` (Performance) is a validation error.

### 3. Cross-domain observation, not cross-domain judgment

**Statement:** An agent may observe signals outside its domains (a Security Engineer may note that a performance issue creates a DoS vector), but the finding must be filed under the agent's own domain with a cross-reference to the relevant domain. The agent provides the observation; the domain owner provides the judgment.

**Rationale:** Cross-domain observations are valuable — a Security Engineer noticing a DoS vector through a performance issue is exactly the kind of cross-cutting insight AEGIS is designed to surface. But the Security Engineer should file this as a security finding (Domain 04: "Performance issue X creates DoS vector Y") with a reference to Domain 08, not as a performance finding. The Performance Engineer then evaluates whether the performance issue is real; the Security Engineer evaluates whether the DoS vector is exploitable.

**Enforcement:** Findings that reference domains outside the agent's scope must use the agent's own domain number in `domain_number` and include the referenced domain in `references` (e.g., "See Domain 08 for performance characterization"). Findings with `domain_number` outside the agent's domains but containing cross-domain observations are reclassified to the agent's domain with a cross-reference.

### 4. Schema conformance constraint

**Statement:** All agent output must conform to the schemas declared in the agent's assembly manifest. No ad-hoc output formats, no free-form text blocks, no "summary notes" outside the schema structure.

**Rationale:** Schema conformance makes agent output composable. The disagreement resolution workflow expects @schema:finding instances. The report generation workflow expects @schema:disagreement instances. Ad-hoc output cannot be consumed by downstream workflows, creating dead zones in the analysis pipeline.

**Enforcement:** Output validation checks every finding against @schema:finding, every disagreement raised against @schema:disagreement, and every confidence assessment against @schema:confidence. Non-conformant output is rejected and the agent must reformat. Agents cannot produce output types not declared in their assembly manifest.

### 5. Tool signal consumption constraint

**Statement:** Agents must consume signals tagged with their domains (the `domain_relevance` field in @schema:signal) and must not give undue weight to signals irrelevant to their domains. Ignoring relevant signals is a coverage gap; overweighting irrelevant signals is scope creep.

**Rationale:** Phase 1 (Automated Signal Gathering) tags every signal with domain relevance. An agent that ignores signals relevant to its domains may miss evidence that would change its assessment. An agent that gives disproportionate weight to signals outside its domains is effectively auditing another agent's territory without that agent's calibration.

**Enforcement:** Audit trail checks that each agent consumed all signals where `domain_relevance` includes the agent's domains. Missing signal consumption (signal relevant to Domain 04 not referenced by security-engineer) is flagged as a potential coverage gap. Agents referencing signals with no relevance to their domains must justify the cross-domain reference.

## DO

- Security Engineer files finding F-04-015: "Unbounded retry mechanism at `src/http/client.ts:34` creates a potential denial-of-service amplification vector. See Domain 07 for reliability characterization of the retry behavior." (Cross-domain observation filed in the agent's own domain with reference to the relevant domain.)

- Data Engineer produces findings only in Domain 02 (Data & State Integrity), referencing signals S-SQ-003 and S-TRV-007 which both have `domain_relevance: [02]`. (Domain scope respected, relevant signals consumed.)

- Principal Engineer reviews all domain findings and produces synthesis in Domain 13 (Risk Synthesis), which is explicitly in the Principal's domain list. (Synthesis happens within the designated domain, not ad-hoc.)

- Agent output is a well-formed @schema:finding instance with all 7 layers, valid @schema:confidence vector, and proper ID format. (Schema conformance — no ad-hoc formats.)

## DON'T

- Architect agent produces finding F-04-022 in Domain 04 (Security): "Authentication tokens are not rotated."
  **Why this is wrong:** Domain 04 is the Security Engineer's domain. The Architect may observe that the authentication architecture lacks token rotation (filed under Domain 01: Architecture), but the security implications are the Security Engineer's judgment to make.

- Performance Engineer ignores signal S-SQ-015 (SonarQube complexity hotspot in `src/core/engine.ts`) which has `domain_relevance: [08]`, producing findings based only on manual code review.
  **Why this is wrong:** Ignoring relevant signals creates coverage gaps. The SonarQube complexity signal may reveal performance-impacting patterns the manual review missed.

- SRE agent produces a free-form text block: "General observations: The deployment pipeline seems fragile and the monitoring has gaps."
  **Why this is wrong:** "General observations" is not a schema-conformant output. This must be expressed as @schema:finding instances with all 7 layers. "Seems fragile" violates epistemic hygiene (Layer 1 must be factual observation, not impression).

- Security Engineer writes 3 findings in Domain 08 (Performance) because they noticed slow API responses during their security review.
  **Why this is wrong:** The Security Engineer may note that slow responses create timing-based attack vectors (a Domain 04 finding), but characterizing performance issues is the Performance Engineer's domain. Filing findings in another agent's domain creates overlap and undermines the multi-agent structure.
