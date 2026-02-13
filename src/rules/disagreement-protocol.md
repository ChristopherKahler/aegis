---
id: disagreement-protocol
name: Disagreement Protocol
scope: all_agents
priority: critical
---

## Purpose

Multi-agent systems are prone to false consensus. Without explicit protocol rules, disagreements get auto-resolved (silently discarded), averaged (split the difference), or hidden (buried in footnotes). These failure modes are catastrophic because disagreements are where risk hides — the high-severity, high-disagreement quadrant is precisely where leadership attention is most needed.

These rules ensure that every disagreement is a first-class object that must be explicitly raised, structurally recorded, categorized by root cause, and resolved by the Principal Engineer through a named reasoning model. The goal is not consensus — it is epistemic transparency.

## Rules

### 1. No auto-resolving disagreements

**Statement:** A disagreement cannot transition from `open` to any resolved status without the Principal Engineer's explicit response. No agent, workflow, or automated process may resolve a disagreement.

**Rationale:** Auto-resolution is the most dangerous anti-pattern because it is invisible. If an automated process decides two positions are "close enough" and marks the disagreement resolved, the audit record shows consensus where none existed. Risk is hidden, not reduced.

**Enforcement:** @schema:disagreement validation rejects any disagreement where `status` is not `open` and `principal_response` is empty or null. The workflow that transitions disagreement status must verify `principal_response` is substantive (not a placeholder like "acknowledged" or "noted").

### 2. No averaging opinions

**Statement:** The Principal Engineer's resolution must not split the difference between positions. "Severity is between high and medium" is not a resolution — it is an abdication of judgment.

**Rationale:** Averaging creates a false middle ground that no agent actually holds. If one agent says "critical" and another says "low", the answer is not "medium". The answer is a reasoned judgment about which evidence and which threat model is more compelling, using a named resolution model.

**Enforcement:** Principal response text is checked for averaging patterns: "somewhere between", "compromise at", "split the difference", "partially agree with both". These phrases trigger a review flag. The resolution must name a resolution model (evidence_dominance, risk_asymmetry, reversibility, time_to_failure, blast_radius) and explain how it was applied.

### 3. No forcing consensus language

**Statement:** A resolution must not claim that agents now agree when their positions have not changed. Agents do not need to agree — the Principal decides, and dissenting positions are preserved.

**Rationale:** Forced consensus language ("after discussion, all agents agree...") falsifies the epistemic record. If the Security Engineer assessed critical severity and the resolution is medium, the Security Engineer's original position must remain in the record. The Principal's resolution overrides for decision-making purposes, but does not retroactively change what agents assessed.

**Enforcement:** Resolution records that claim consensus must show updated position entries from the agents involved. If no positions were updated, consensus language is a validation error. Dissenting positions are preserved permanently in @schema:disagreement regardless of final status.

### 4. No hiding disagreements in footnotes

**Statement:** Every disagreement referenced in a finding must have a corresponding @schema:disagreement record. Disagreements must appear in Report Section 4 (Cross-Validation Notes), not buried in finding footnotes or appendices.

**Rationale:** A finding that mentions "some agents disagree on severity" without a formal disagreement record is unresolvable. There is no record of who disagreed, why, or how it was resolved. The disagreement becomes gossip instead of structured analysis.

**Enforcement:** Cross-reference validation checks that every finding mentioning disagreement or conflicting assessment has a corresponding D-{NNN} disagreement record. Report validation checks that Section 4 contains all @schema:disagreement instances from the audit. Orphaned references (finding mentions disagreement but no record exists) are validation errors.

### 5. No treating Devil's Advocate as optional

**Statement:** The Devil's Advocate review (Phase 4) must produce at least one disagreement record for every audit. If the Devil's Advocate finds nothing to challenge, the audit's epistemic diversity is suspect. Dismissing Devil's Advocate disagreements as `out_of_scope` without substantive rationale is a violation.

**Rationale:** The Devil's Advocate exists to stress-test the analysis. An audit where everyone agrees is an audit where something was missed or the Devil's Advocate was not sufficiently adversarial. The cost of false positives from the Devil's Advocate (challenges that turn out to be unfounded) is far lower than the cost of false negatives (risks that were never challenged).

**Enforcement:** Report generation checks for disagreement records where `agents_involved` includes `devils-advocate`. If zero such records exist, the audit is flagged as incomplete. Disagreements from `devils-advocate` resolved as `out_of_scope` must have `principal_rationale` explaining why the challenge is outside the audit's scope — a brief dismissal is insufficient.

## DO

- Principal responds to a disagreement: "Evidence dominance favors the security engineer's position. Three independent tools flagged this pattern, and the application engineer's mitigation (input validation) does not address the underlying architectural vulnerability. Downgrading severity from critical to high based on the existing mitigation, but recommending parameterized queries as the durable fix." (Named model, specific reasoning, preserved positions.)

- Devil's Advocate raises challenge: "Finding F-01-003 assumes circular dependencies will cause deployment failures, but the current deployment pipeline deploys as a monolith. The circular dependency is an architectural smell, not an operational risk until the team attempts to decompose into services." (Substantive challenge with specific reasoning.)

- Disagreement record preserves both positions even after resolution, with the Security Engineer's original `confidence: high` and the Application Engineer's original `confidence: medium` both visible in the final record.

## DON'T

- Disagreement resolved by workflow: "Both agents' findings were similar enough. Auto-resolved as mitigated."
  **Why this is wrong:** No agent or workflow may resolve disagreements. Only the Principal Engineer can transition status. "Similar enough" is averaging, not resolution.

- Principal response: "I've reviewed both positions and they're both valid, so the severity is medium-high."
  **Why this is wrong:** "Medium-high" is not an AEGIS severity value. This is averaging. The Principal must choose a severity from the enum and explain why using a named resolution model.

- Resolution states: "After careful consideration, all agents now agree this is a medium-severity issue."
  **Why this is wrong:** Unless the agents actually revised their positions (with updated position records), this is forced consensus. The original positions must be preserved even if the resolution disagrees with them.

- Devil's Advocate disagreement D-007 resolved as: "Out of scope — not relevant."
  **Why this is wrong:** "Not relevant" is not a substantive rationale. The Principal must explain specifically why the Devil's Advocate's challenge falls outside the audit scope. If it is relevant but the Principal disagrees, the correct status is `mitigated` or `accepted_risk`, not `out_of_scope`.
