<purpose>
Manages the structured resolution of disagreements between agents by classifying root causes, applying canonical resolution models, and obtaining the Principal Engineer's mandatory response — ensuring no disagreement is silently dismissed or auto-resolved.
</purpose>

<phase_context>
Phase: Utility — invoked by phase-2-domain-audits, phase-3-cross-domain, and phase-4-adversarial-review workflows when disagreements are detected. Also invoked as a prerequisite gate before phase-5-report to ensure all disagreements have principal_response.
Prior phase output: Varies — disagreement records from .aegis/disagreements/, the findings they reference from .aegis/findings/
Agents invoked: principal-engineer (for resolution judgment — no other agent resolves disagreements)
Output: Updated disagreement records in .aegis/disagreements/ with principal_response, resolution_model_applied, and updated status
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/disagreements/*.md (all disagreement records with status: open)
@.aegis/findings/*.md (findings referenced by disagreements)
@~/.claude/aegis/core/agents/principal-engineer.md
@~/.claude/aegis/core/personas/principal-engineer.md
@~/.claude/aegis/schemas/disagreement.md
@~/.claude/aegis/schemas/finding.md
@~/.claude/aegis/schemas/confidence.md
@~/.claude/aegis/rules/disagreement-protocol.md
@~/.claude/aegis/rules/epistemic-hygiene.md
</required_input>

<process>

<step name="collect_unresolved_disagreements" priority="first">
1. Read all files in .aegis/disagreements/.
2. Filter to disagreements with status: open (not yet resolved).
3. If no open disagreements found:
   a. Log: "No unresolved disagreements. Disagreement resolution not needed."
   b. Return — no action required.
4. For each open disagreement:
   a. Load the disagreement record
   b. Load the referenced finding(s) from .aegis/findings/
   c. Identify the agents involved
   d. Note the epistemic layer disputed
5. Sort disagreements by severity impact:
   a. Disagreements involving critical/high severity findings first
   b. Disagreements spanning multiple domains second
   c. Remaining disagreements in ID order
6. Record count and IDs of unresolved disagreements in .aegis/STATE.md.
</step>

<step name="classify_root_causes" priority="blocking">
1. For each open disagreement, classify the root cause using the closed taxonomy:
   a. **Threat model mismatch** — agents assume different threat actors or attack surfaces
   b. **Time horizon mismatch** — one agent considers immediate risk, another considers long-term
   c. **Evidence availability mismatch** — agents had access to different signals or weighted them differently
   d. **Risk tolerance mismatch** — agents apply different risk acceptance thresholds
   e. **Domain boundary mismatch** — disagreement arises from overlapping domain ownership
   f. **Optimism vs pessimism bias** — one agent defaults to "probably fine," another to "assume the worst"
   g. **Tool trust bias** — agents weight automated tool findings differently
2. If the root cause is not immediately clear:
   a. Examine the evidence cited by each position
   b. Compare confidence vectors — divergent dimensions reveal the disagreement source
   c. Check if agents applied the same epistemic rules differently
3. Record root_cause classification in each disagreement record.
4. Do NOT auto-assign root cause if genuinely ambiguous — present to Principal Engineer with analysis.
</step>

<step name="select_resolution_models" priority="blocking">
1. For each classified disagreement, identify the applicable resolution model(s):

   a. **Model 1 — Evidence Dominance:**
      "Which claim is better supported by independent signals?"
      Apply when: evidence_availability_mismatch or tool_trust_bias
      Weight: number of corroborating tools, signal diversity, historical precedent

   b. **Model 2 — Risk Asymmetry:**
      "If we're wrong, who pays and how badly?"
      Apply when: risk_tolerance_mismatch or threat_model_mismatch
      Weight: security and data risks override performance disagreements

   c. **Model 3 — Reversibility:**
      "How hard is it to undo this decision?"
      Apply when: the disputed finding involves architectural or data decisions
      Weight: irreversible decisions get stricter scrutiny

   d. **Model 4 — Time-to-Failure:**
      "Which concern manifests first?"
      Apply when: time_horizon_mismatch
      Weight: near-term risks outrank theoretical long-term ones

   e. **Model 5 — Blast Radius:**
      "How much breaks if this is wrong?"
      Apply when: domain_boundary_mismatch or optimism_vs_pessimism_bias
      Weight: localized risk < systemic risk

2. Multiple models may apply — rank by relevance to the specific disagreement.
3. Prepare model recommendation with rationale for Principal Engineer review.
</step>

<step name="present_to_principal_engineer" priority="blocking">
1. For each disagreement, present to the Principal Engineer:
   a. Disagreement ID and finding reference(s)
   b. The two (or more) positions with their evidence and confidence vectors
   c. Root cause classification
   d. Recommended resolution model(s) with rationale
   e. Potential resolution outcomes and their implications
2. The Principal Engineer MUST provide for each disagreement:
   a. **Explicit acknowledgment** — cannot ignore or defer without explanation
   b. **Chosen resolution model** — which of the 5 models applies and why
   c. **Rationale** — reasoned explanation for the resolution direction
   d. **Follow-up assignment** (if needed) — e.g., "needs additional signal gathering" or "deferred pending production monitoring data"
3. The Principal Engineer's response is recorded as principal_response in the disagreement record.
4. principal_response MUST be non-empty. An empty response is a validation failure.
</step>

<step name="update_disagreement_records" priority="blocking">
1. For each resolved disagreement, update the record in .aegis/disagreements/{disagreement-id}.md:
   a. root_cause: classified root cause from the closed taxonomy
   b. resolution_model_applied: which of the 5 models was used
   c. principal_response: full text of the Principal Engineer's response
   d. status: one of the following (no other values allowed):
      - **mitigated** — disagreement resolved by evidence, positions reconciled
      - **accepted_risk** — disagreement acknowledged, risk accepted with rationale
      - **deferred** — disagreement deferred pending additional information (must specify what)
      - **out_of_scope** — disagreement outside audit boundaries (must cite scope document)
   e. resolution_timestamp: when the resolution was recorded
2. Validate each updated record against src/schemas/disagreement.md.
3. Write updated records back to .aegis/disagreements/.
4. Verify principal_response is populated for every resolved disagreement.
</step>

<step name="enforce_anti_patterns" priority="blocking">
1. After all resolutions recorded, verify NONE of the following anti-patterns occurred:

   a. **No auto-resolving:** No disagreement was resolved without Principal Engineer judgment.
      Check: Every resolved disagreement has a non-empty, substantive principal_response.

   b. **No averaging opinions:** No resolution splits the difference between positions.
      Check: Resolution takes a clear position, not "partly A and partly B."

   c. **No forcing consensus language:** No resolution rewrites positions to appear to agree.
      Check: Original positions preserved in the disagreement record.

   d. **No hiding disagreements in footnotes:** No disagreement was downgraded to a minor note.
      Check: All disagreements maintain their original severity context in the record.

   e. **No treating Devil's Advocate as optional:** If Devil's Advocate raised disagreements, they received the same resolution rigor as inter-agent disagreements.
      Check: Devil's Advocate disagreements have full principal_response.

2. If any anti-pattern is detected:
   a. Flag the specific violation
   b. Identify which disagreement record violated the pattern
   c. Return to Principal Engineer for correction
   d. Do NOT mark as resolved until anti-pattern is cleared
</step>

<step name="update_state" priority="blocking">
1. Update .aegis/STATE.md:
   a. disagreements_resolved: updated count
   b. disagreements_remaining: count still open (should be 0 after full resolution)
   c. resolution_models_used: distribution of which models were applied
   d. anti_pattern_violations: 0 (or count if detected and corrected)
   e. timestamp: resolution completion
2. If all disagreements now resolved:
   a. Record: "All disagreements resolved — Phase 5 prerequisite satisfied"
3. If some disagreements remain open (status: deferred):
   a. Record: "N disagreements deferred — will be noted in final report"
   b. Deferred disagreements must still have principal_response explaining the deferral
</step>

</process>

<output>
Artifacts updated:
- .aegis/disagreements/{disagreement-id}.md — Each updated with root_cause, resolution_model_applied, principal_response, and resolved status
- .aegis/STATE.md — Updated with resolution metrics and Phase 5 readiness status

All disagreement records conform to src/schemas/disagreement.md after resolution.
</output>

<error_handling>
- **No Principal Engineer available:** Cannot resolve disagreements without Principal Engineer judgment. Queue for next Principal Engineer session. Do not auto-resolve under any circumstance.
- **Principal Engineer provides empty response:** Reject. Return disagreement with message: "principal_response is required. Silence is not allowed per disagreement protocol." Re-present the disagreement for response.
- **Principal Engineer attempts to auto-resolve (pattern response):** Flag if responses appear formulaic or identical across multiple disagreements. Each disagreement requires individual reasoning. Present concern and request substantive response.
- **Root cause doesn't fit taxonomy:** If a disagreement genuinely doesn't fit any of the 7 root cause categories, record as "unclassified" with explanation. Present to Principal Engineer with note that the taxonomy may need extension. Do not block resolution — the Principal can still apply resolution models.
- **Anti-pattern detected after resolution:** Return the affected disagreement record to the Principal Engineer with the specific violation identified. Do not overwrite the original response — request a corrected response that avoids the anti-pattern.
- **Disagreement references deleted/modified finding:** If a finding was modified or removed after the disagreement was created, flag the inconsistency. The disagreement still stands — it should be resolved based on the finding as it existed when the disagreement was raised.
- **Excessive deferral (>50% of disagreements deferred):** Flag as concerning — excessive deferral may indicate avoidance rather than genuine information gaps. Present to user. Do not block, but record the pattern.
</error_handling>
