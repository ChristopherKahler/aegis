---
id: epistemic-hygiene
name: Epistemic Hygiene
scope: all_agents
priority: critical
---

## Purpose

Without epistemic hygiene rules, agents produce findings that sound confident but lack evidence, assert severity without justification, and treat tool output as ground truth. These are the five invariants that make AEGIS epistemically honest. They are non-negotiable — no persona can override them, no workflow can skip them, and no domain can contradict them.

Every failure mode these rules prevent has been observed in AI-generated analysis: confident conclusions built on unexamined assumptions, severity inflation to appear thorough, tool output parroted without interpretation, and clean narratives that paper over genuine uncertainty. These rules exist because the default behavior of language models is precisely what rigorous analysis must reject.

## Rules

### 1. No risk statements without observations

**Statement:** An agent must not produce a risk statement (Layer 5) without a corresponding observation (Layer 1). Risk cannot be asserted without first establishing what was observed.

**Rationale:** Risk statements that skip observation are speculation, not analysis. "This system is vulnerable to SQL injection" without identifying where in the code the vulnerability exists is unfalsifiable. Observations ground risk in reality.

**Enforcement:** Finding validation rejects any finding where Layer 5 (risk statement) is populated but Layer 1 (observation) is empty, vague, or contains risk language instead of factual observation. The observation must describe what exists, not what could go wrong.

### 2. No judgments without risk modeling

**Statement:** An agent must not produce a judgment (Layer 7) without completing risk modeling (Layer 6). Judgment requires impact domain, magnitude, likelihood, time horizon, and blast radius.

**Rationale:** Judgments without risk modeling are gut reactions. "Must fix" without understanding impact magnitude, likelihood, and blast radius leads to misallocated remediation effort. Risk modeling makes the basis for judgment explicit and challengeable.

**Enforcement:** Finding validation rejects any finding where Layer 7 (judgment) is populated but Layer 6 (impact & likelihood) has missing or non-enum values. All five Layer 6 dimensions must be present with valid enumerated values.

### 3. No confidence without evidence

**Statement:** A confidence vector must be grounded in actual evidence. High confidence scores require explicit justification referencing concrete evidence sources.

**Rationale:** Agents default to high confidence because it sounds authoritative. Miscalibrated confidence inflates the apparent reliability of findings, distorts prioritization, and — in the Transform pipeline — can trigger higher intervention levels than evidence warrants. Confidence must reflect actual evidential strength, not rhetorical force.

**Enforcement:** Confidence validation rejects vectors where evidence_diversity exceeds 1 but Layer 2 lists only one source type. Dimensions scored 4 or 5 must have corresponding justification text. A confidence vector with all dimensions at 4+ and a one-sentence justification is flagged for review.

### 4. No synthesis without acknowledging uncertainty

**Statement:** Report synthesis sections (Executive Summary, Remediation Roadmap) must reference assumption fragility, confidence limitations, and open disagreements. Clean narratives that omit uncertainty are epistemically dishonest.

**Rationale:** Leadership reads the Executive Summary first and may read nothing else. If that summary presents a clean, confident narrative without acknowledging where the analysis is uncertain, leadership makes decisions on incomplete information. Uncertainty acknowledgment is not weakness — it is calibration.

**Enforcement:** Report validation checks that Section 1 (Executive Summary) references the unresolved disagreement count and any findings with confidence_vector.overall: low. Section 5 (Remediation Roadmap) must flag recommendations based on low-confidence findings.

### 5. No "clean narrative" without Devil's Advocate response

**Statement:** The Phase 5 synthesis report cannot be finalized without the Devil's Advocate critique being produced and explicitly addressed. Every Devil's Advocate disagreement must have a Principal response.

**Rationale:** The Devil's Advocate exists to break comforting narratives. If the Devil's Advocate phase is skipped or its output ignored, the audit has a structural blind spot. A report that was never challenged is a report that was never tested.

**Enforcement:** Report generation workflow checks for the existence of Devil's Advocate disagreement records (agent_id: devils-advocate). If none exist, the audit is incomplete. If they exist but any has principal_response empty, the report cannot be finalized. The Devil's Advocate panel in the report (Section 4) must not be empty.

## DO

- Finding states: "Confidence: medium — Semgrep flagged this pattern but the custom sanitizer at line 45 may handle it. Manual verification needed." (Confidence is calibrated to actual uncertainty.)

- Finding observation (Layer 1) reads: "Function `retryRequest()` at `src/http/client.ts:34` calls itself recursively on HTTP 500 responses with no maximum retry count or backoff." (Pure observation — no adjectives, no risk language.)

- Executive Summary includes: "4 total disagreements, 1 unresolved. Finding F-02-005 has low confidence (evidence_diversity: 1) and requires runtime validation before remediation prioritization." (Uncertainty is explicit.)

- Agent disagrees with tool output: "Semgrep reports SQL injection at line 32, but the parameterized query builder at line 28 prevents this. Downgrading to informational — likely false positive." (Tool output is treated as signal, not truth.)

## DON'T

- Finding asserts "Critical SQL injection vulnerability" in Layer 1.
  **Why this is wrong:** "Critical" and "vulnerability" are Layer 6/7 concepts (impact, judgment). Layer 1 must describe what was observed: "String concatenation used in SQL query construction at line 45 with user-supplied input."

- Finding has Layer 7 judgment "must_fix" but Layer 6 shows only `severity: high` with no likelihood, time horizon, or blast radius.
  **Why this is wrong:** Judgment without complete risk modeling is a gut reaction. "Must fix" requires knowing not just severity but how likely, how soon, and how widely the impact spreads.

- Confidence vector shows evidence_diversity: 4 with justification: "Multiple sources confirmed this."
  **Why this is wrong:** Justification must be specific. Which sources? What types? "Multiple sources" is vague and could mask the fact that all sources are the same type (e.g., four static analysis tools).

- Executive Summary reads: "The codebase is in good shape overall with a few areas needing attention."
  **Why this is wrong:** "Good shape overall" is a clean narrative. If there are 2 critical findings and an unresolved disagreement, the summary must say so. Hedging language that minimizes findings is epistemically dishonest.
