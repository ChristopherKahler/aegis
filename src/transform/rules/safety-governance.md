---
id: safety-governance
name: Safety Governance
scope: transform_agents
priority: critical
---

## Purpose

Without safety governance rules, Transform agents produce overconfident remediation plans, escalate intervention levels without evidence, bypass confidence requirements when findings feel important, and — most dangerously — blur the boundary between producing plans and executing changes. These are the hard boundaries of the Transform system.

Safety governance prevents the failure mode that makes AI-assisted remediation dangerous: well-structured, authoritative-sounding change plans built on insufficient evidence. A playbook that reaches Authorizing level with medium-confidence findings is not "slightly optimistic" — it is a change specification that a human reviewer may trust because the system presented it at a high governance tier. The tier itself becomes a false signal of evidence strength.

These rules are non-negotiable. Unlike Core epistemic rules where a quality violation degrades output, a Transform safety violation can cause damage to the target codebase. A playbook that bypasses confidence gating and reaches PAUL for execution planning has passed through every safety gate and acquired a veneer of legitimacy. If the underlying evidence was insufficient, the damage is amplified by the system's own authority.

Every rule in this file has `priority: critical`. Violations invalidate the output.

## Rules

### 1. No Auto-Execution

**Statement:** AEGIS Transform NEVER applies changes to the target codebase. Transform produces plans, assessments, and verification procedures. It does not modify source files, configuration files, database schemas, infrastructure definitions, or any artifact in the target project's working tree. PAUL mediates all codebase modifications with human oversight.

**Rationale:** The separation between diagnosis/planning and execution is a hard architectural boundary, not a configurable preference. If Transform could execute changes, a single miscalibrated confidence score or an incorrect risk assessment would result in codebase damage with no human checkpoint. The execution boundary exists because the cost of a false positive in planning (a bad plan that gets rejected) is negligible, while the cost of a false positive in execution (a bad change that gets applied) can be severe.

**Enforcement:** No Transform workflow includes file-modification steps outside `.aegis/` operational directory. If a Transform agent produces output that includes write operations to the target codebase (file creation, file modification, file deletion), the output is a critical violation and must be rejected at workflow validation. There is no trusted mode, no bypass flag, no override mechanism. This is enforced at the workflow definition level — Transform workflows simply do not have write access to the target tree.

### 2. Conservative Bias

**Statement:** Transform agents must default to the lowest intervention level that serves the user's needs. When uncertain about the appropriate intervention level, agents must downgrade — Authorizing becomes Planning, Planning becomes Suggesting. Escalation beyond the default requires explicit evidence justification citing specific sources.

**Rationale:** The default behavior of language models is to present recommendations with high confidence and strong language. In the context of remediation planning, this natural tendency maps to intervention level inflation — a suggestion becomes a plan, a plan becomes an authorization. Conservative bias corrects for this by requiring agents to actively justify escalation rather than passively assuming it. The asymmetry is deliberate: under-escalation wastes a developer's time reading a suggestion when they could have had a plan. Over-escalation risks codebase damage from an insufficiently-evidenced change.

**Enforcement:** Every playbook's intervention level must include an escalation justification when the level is Planning or above. The justification must cite: (1) the finding confidence that gates this level, (2) the number and type of evidence sources, and (3) for Authorizing/Executing, the change-risk assessment score. Playbooks without escalation justification are capped at Suggesting. Workflow validation checks that the justification references exist and are consistent with the claimed level.

### 3. Confidence Gating

**Statement:** The intervention level of a playbook is hard-gated by the source finding's confidence (@schema:confidence overall derivation). The minimum thresholds are: Suggesting requires any confidence (low, medium, or high); Planning requires medium or high confidence with at least 2 independent evidence sources; Authorizing requires high confidence with at least 3 cross-validated evidence sources; Executing requires high confidence with at least 3 cross-validated evidence sources. No mechanism exists to override these thresholds.

**Rationale:** Confidence gating prevents the most dangerous scenario: a high-intervention remediation plan built on weak evidence. Without gating, a Transform agent could observe a single Semgrep signal, assess it as critical severity, and produce an Authorizing-level playbook — creating a change specification that carries the system's authority but rests on a single tool output. Confidence gating ensures that the evidence bar rises with the intervention level. Severity does not override confidence: a critical-severity finding with low confidence is still capped at Suggesting.

**Enforcement:** Schema validation at @schema:playbook rejects any playbook where the declared intervention level exceeds the confidence gate. Validation checks: (1) finding's confidence overall meets or exceeds the level's minimum, (2) the number of distinct evidence sources in the finding meets or exceeds the level's minimum, (3) for Authorizing/Executing, at least one evidence source must corroborate another (cross-validation). Evidence source counting uses @schema:finding Layer 2 (evidence sourcing) — each distinct source type (tool signal, manual observation, documentation reference, test result) counts as one source regardless of how many instances of that type exist.

### 4. Liability Escalation

**Statement:** At Suggesting and Planning levels, AEGIS operates as an Advisor — it provides information and recommendations with no expectation that its output will be applied without independent verification. At Authorizing and Executing levels, AEGIS operates as an Architectural Actor — its output is intended to be applied to the codebase, and it must include explicit confidence statements and liability disclaimers. Higher liability postures require higher confidence and lower change risk.

**Rationale:** The liability distinction is not cosmetic. When a system produces a suggestion, the human reviewer treats it as input to their own decision-making process. When a system produces an authorization-level change specification, the human reviewer is more likely to trust the system's assessment and approve without deep review — the tier itself signals "this has been thoroughly vetted." If the vetting was insufficient, the tier becomes a vector for false authority. Liability escalation ensures that the output explicitly states its evidential basis and limitations at the levels where humans are most likely to defer to the system.

**Enforcement:** Authorizing and Executing-level playbooks must include a disclaimer section with: (1) confidence statement citing the finding's confidence and evidence source count, (2) risk statement citing the change-risk assessment's overall risk, (3) limitation acknowledgment identifying any evidence gaps or assumptions. Missing disclaimers are validation errors. The disclaimer must be a substantive assessment, not boilerplate — "This plan has been reviewed" is not a valid disclaimer.

### 5. Intervention Level Immutability After Approval

**Statement:** Once a playbook is assigned an intervention level and approved at that level by a human reviewer, the level cannot be upgraded without a full re-assessment including updated evidence review, confidence re-evaluation, and risk re-assessment. Downgrading is always permitted without re-assessment. This prevents post-approval escalation where a Planning-level playbook is silently upgraded to Authorizing after human review.

**Rationale:** Post-approval escalation is a subtle but dangerous failure mode. A human reviews a Planning-level playbook with the understanding that it is a recommendation. If the system later upgrades it to Authorizing without re-review, the human's approval — given at a lower tier — is retroactively applied to a higher tier. The human did not consent to Authorizing-level output. Immutability after approval ensures that escalation always triggers re-review.

**Enforcement:** Playbook metadata includes an `approved_at_level` field that records the level at which human approval was granted. Workflow validation rejects any execution at a level higher than `approved_at_level`. Downgrade workflows do not require re-approval. Upgrade workflows must reset `approved_at_level` to null and re-enter the approval pipeline.

## DO

- Playbook assigned Suggesting level with note: "Single Semgrep signal (S-SEM-047). No corroborating evidence from other tools or manual review. Confidence low. Capped at Suggesting per confidence gating rule."

- Playbook downgraded from Planning to Suggesting after re-assessment: "Initial assessment cited 2 evidence sources, but both are from the same Semgrep rule set — counting as 1 independent source. Downgrading to Suggesting. Planning requires 2 independent sources."

- Authorizing-level playbook includes disclaimer: "Based on 3 independent evidence sources (Semgrep signal S-SEM-047, manual code review observation, Gitleaks detection GL-012) with overall confidence high. Change risk assessment CR-001 rates overall risk as low. Limitation: test coverage for the affected module is 78% — regression probability score of 2/5 reflects this gap. This remediation plan should be reviewed by a qualified engineer before application."

- Agent produces Planning-level playbook for a critical-severity finding with medium confidence: "Finding F-04-001 is severity critical but confidence medium (2 evidence sources). Confidence gates intervention at Planning. Cannot escalate to Authorizing without a third independent evidence source achieving high confidence. Severity does not override confidence."

- Transform workflow produces playbooks and risk assessments as `.aegis/` artifacts without modifying target codebase files. All output written to `.aegis/transform/output/`.

## DON'T

- Playbook assigned Authorizing level for a finding with confidence medium.
  **Why this is wrong:** Authorizing requires high confidence with 3+ cross-validated evidence sources. Medium confidence is hard-capped at Planning. The severity of the finding is irrelevant to the confidence gate — a critical-severity finding with medium confidence is still capped at Planning.

- Transform agent modifies `src/config/database.py` directly to implement the remediation.
  **Why this is wrong:** Transform never modifies target codebase files. It produces plans; PAUL executes plans with human oversight. There is no "just this once" exception, no "it's a trivial change" bypass. The execution boundary is absolute.

- Playbook at Planning level with escalation justification: "This seems like it should be at least Planning level given the severity."
  **Why this is wrong:** "Seems like" is not evidence. Escalation justification must cite specific confidence levels and evidence source counts. Severity does not justify escalation — confidence does.

- Planning-level playbook approved by human, then silently upgraded to Authorizing by the system for inclusion in a PAUL execution plan.
  **Why this is wrong:** The human approved at Planning level — they consented to a recommendation, not an execution specification. Upgrading without re-review retroactively elevates the human's consent. Escalation requires re-assessment and re-approval.

- Authorizing-level playbook with disclaimer: "This plan has been thoroughly reviewed and is ready for implementation."
  **Why this is wrong:** This is boilerplate, not a substantive disclaimer. A valid disclaimer cites the specific confidence, evidence count, risk assessment, and limitations. "Thoroughly reviewed" is a conclusion, not an assessment.
