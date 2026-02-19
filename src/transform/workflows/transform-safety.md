<purpose>
Validates Transform output against the safety framework — enforcing confidence gating, risk thresholds, intervention level integrity, the no-auto-execution boundary, and refusal conditions. Invoked as a utility workflow by phase workflows at every safety checkpoint.
</purpose>

<phase_context>
Phase: N/A — Utility workflow invoked by Phase 6, 7, and 8 workflows
Prior phase output: Varies by invocation point — playbooks (Phase 6), risk-scored changes (Phase 7), PAUL project (Phase 8)
Agents invoked: None — this is a validation gate, not an agent orchestration workflow
Output: Safety validation result (pass/fail per item), intervention level adjustments, refusal records
</phase_context>

<required_input>
@~/.claude/aegis/transform/rules/safety-governance.md
@~/.claude/aegis/transform/rules/change-risk-rules.md
@~/.claude/aegis/transform/schemas/intervention-level.md
@~/.claude/aegis/schemas/confidence.md
@~/.claude/aegis/transform/schemas/change-risk.md
Items to validate (passed by invoking workflow):
- Playbooks with intervention level classifications
- Finding confidence scores
- Risk dimensional profiles (when available)
- PAUL project artifacts (Phase 8)
</required_input>

<process>

<step name="confidence_gating" priority="first">
1. For each item being validated (playbook, change, or PAUL task):
   a. Retrieve the declared intervention level
   b. Retrieve the confidence score of the underlying finding(s)
   c. Check against confidence thresholds:
      - Suggesting: requires Low confidence minimum (1 source)
      - Planning: requires Medium confidence minimum (2 independent sources)
      - Authorizing: requires High confidence minimum (3+ independent sources)
      - Executing: requires High confidence minimum (3+ independent sources with cross-validation)
   d. If confidence is insufficient for declared level:
      - Downgrade to the highest level the confidence supports
      - Record: original level, downgraded level, confidence score, reason
      - Example: "Downgraded from Authorizing to Planning — confidence has 2 sources, Authorizing requires 3+"
2. Any confidence dimension rated 1 (lowest) caps overall confidence at Low regardless of other dimensions.
3. Confidence vectors are immutable — do not modify the original finding's confidence, only the intervention level classification.
</step>

<step name="risk_threshold_check" priority="blocking">
1. For each item with risk scores (available after Phase 7):
   a. Check all 4 risk dimensions:
      - Blast radius
      - Coupling coefficient
      - Regression probability
      - Architectural tension
   b. If ANY single dimension exceeds "high" threshold:
      - Force intervention level downgrade to Suggesting
      - Record: which dimension triggered, score value, original level
      - This is the "unsafe context circuit breaker" — non-negotiable
   c. If multiple dimensions are elevated but none exceed "high":
      - Flag for heightened scrutiny but do not auto-downgrade
      - Record: elevated dimensions and combined risk profile
2. Risk-based downgrades override confidence-based levels:
   a. Even if confidence supports Authorizing, a high-risk dimension forces Suggesting
   b. Risk check is the more conservative gate
3. For items without risk scores (Phase 6 invocation before risk scoring):
   a. Skip dimensional risk check
   b. Apply confidence gating only
   c. Note: full risk validation occurs in Phase 7
</step>

<step name="intervention_level_enforcement" priority="blocking">
1. Verify final intervention level integrity:
   a. No playbook or change claims a higher level than its evidence warrants
   b. Levels reflect the MORE restrictive of confidence gating and risk threshold checks
   c. Intervention levels are immutable after approval — once set, they cannot be escalated
2. Validate intervention level semantics:
   a. Suggesting: advisory only, no structural commitments, developer decides
   b. Planning: structured remediation plan, human approval required before any action
   c. Authorizing: approved plan with verification gates, still requires human execution
   d. Executing: approved + verified plan with automated verification — but Transform NEVER reaches this level (see no-auto-execution boundary)
3. Record final intervention level for each item.
</step>

<step name="no_auto_execution_boundary" priority="blocking">
1. Scan all Transform output for execution violations:
   a. Direct file modification commands (write, edit, delete, move, rename)
   b. Shell commands that modify the codebase (git commit, npm install, etc.)
   c. Automated deployment triggers
   d. Bypass mechanisms ("skip safety check", "override intervention level", "auto-apply")
   e. Any instruction framed as imperative action rather than proposed plan
2. If ANY execution violation detected:
   a. Flag as CRITICAL safety violation
   b. Remove the violating content
   c. Record: what was found, where, what was removed
   d. This boundary is absolute — Transform produces plans, never executes them
3. Verify output framing:
   a. All changes described as "proposed" or "recommended", never "will be applied"
   b. All plans include human approval gates
   c. All PAUL tasks defer execution to the user's AI assistant operating under PAUL framework
4. The no-auto-execution boundary exists because:
   a. Transform output has not been verified against the actual current codebase state
   b. Transform agents may lack context about in-flight changes
   c. Automated application of changes at audit scale carries unacceptable risk
   d. Human oversight at the execution boundary is the final safety layer
</step>

<step name="refusal_conditions_check" priority="blocking">
1. Check all 5 refusal conditions. If ANY condition is met, refuse to generate or approve remediation for the affected item:

   a. **Confidence insufficient:** Finding confidence is too low to support any intervention level above Suggesting, AND the proposed action requires Planning or higher. Refuse the action; the finding needs more evidence before remediation can proceed.

   b. **Risk exceeds bounds:** Risk dimensional profile shows one or more dimensions at maximum severity with no viable mitigation strategy. The proposed change is too dangerous to recommend in any form. Refuse; flag for human architectural review.

   c. **Insufficient test coverage:** The blast radius of the proposed change extends into code with no test coverage, making regression verification structurally impossible. Refuse until test coverage is extended to cover the blast radius OR the change is rescoped to stay within tested boundaries.

   d. **Unresolved high-severity disagreements:** The finding being remediated is subject to an unresolved disagreement with severity "high" or "critical" where no principal_response has been recorded. Refuse; the epistemic basis for the remediation is contested and the contest has not been resolved.

   e. **Changes outside audit scope:** The proposed remediation modifies code, modules, or systems that were not included in the original audit scope (.aegis/scope.md). Refuse; Transform cannot safely intervene in areas it has not analyzed.

2. For each refusal:
   a. Record: which condition was met, which item was refused, specific evidence
   b. Refusals are NOT errors — they are the safety system working correctly
   c. Refused items are excluded from the final output with their refusal reason preserved
   d. The invoking workflow must handle refused items appropriately (record, report, do not force)
</step>

<step name="record_safety_audit" priority="blocking">
1. Compile safety audit record:
   a. Total items validated
   b. Items passed without adjustment
   c. Items with confidence-based downgrades (list with reasons)
   d. Items with risk-based downgrades (list with triggering dimensions)
   e. Items refused (list with refusal conditions)
   f. Execution boundary violations detected and removed (list with details)
2. Return safety validation result to invoking workflow:
   a. Per-item pass/fail/downgrade/refuse status
   b. Adjusted intervention levels
   c. Refusal records
   d. Safety audit summary
3. This record is preserved in .aegis/STATE.md and included in the final Transform output for audit trail purposes.
</step>

</process>

<output>
Returned to invoking workflow:
- Per-item validation result: pass (no changes), downgrade (level adjusted), refuse (item excluded)
- Adjusted intervention levels with downgrade rationale
- Refusal records with specific condition and evidence
- Safety audit summary (counts, details, boundary checks)

No artifacts created directly — the invoking workflow persists results.
Safety audit trail preserved in .aegis/STATE.md for each invocation.
</output>

<error_handling>
- **Safety violations are NOT errors:** A downgrade, a refusal, or an execution boundary violation detection is the safety system working correctly. These are expected outcomes, not failures to recover from.
- **Missing confidence data:** If a finding lacks a confidence score, treat as confidence = unknown. Unknown confidence caps intervention level at Suggesting. Record as: "Confidence data missing — defaulting to Suggesting."
- **Missing risk data:** If invoked before risk scoring (Phase 6), skip risk threshold check. Note in safety audit that risk validation was not performed at this checkpoint. Full risk validation occurs in Phase 7.
- **Conflicting safety signals:** If confidence gating and risk thresholds produce different intervention levels, use the MORE restrictive (lower) level. Safety errs conservative.
- **Invoking workflow ignores safety result:** This workflow cannot enforce compliance — it can only report. If an invoking workflow proceeds despite a refusal, the safety audit trail preserves the record. This is a process failure to be flagged in the Transform output summary, not a runtime error.
</error_handling>
