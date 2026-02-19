<purpose>
Executes the adversarial review by invoking the Devil's Advocate agent to challenge all prior findings — attacking confidence, exposing blind spots, and surfacing what was missed across the complete analytical record from Phases 2-3.
</purpose>

<phase_context>
Phase: 4 — Adversarial Review ("Fresh Eyes")
Prior phase output: Phase 2 domain findings (.aegis/findings/ from 8 agents), Phase 3 synthesis findings (staff-engineer, reality-gap-analyst), all disagreement records (.aegis/disagreements/*.md)
Agents invoked: devils-advocate (single agent, solo session)
Output: Devil's Advocate critique (.aegis/findings/devils-advocate.md), new disagreement records (.aegis/disagreements/*.md), updated .aegis/STATE.md
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/scope.md
@.aegis/findings/*.md (ALL finding files from Phases 2-3)
@.aegis/disagreements/*.md (ALL existing disagreement records)
@src/core/agents/devils-advocate.md
@src/core/personas/devils-advocate.md
@src/schemas/finding.md
@src/schemas/disagreement.md
@src/schemas/confidence.md
@src/rules/epistemic-hygiene.md
@src/rules/disagreement-protocol.md
@src/rules/agent-boundaries.md
@src/core/workflows/session-handoff.md
@src/core/workflows/disagreement-resolution.md
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md shows Phase 3 complete:
   a. Check phase_3_complete: true
   b. Check .aegis/findings/ contains Phase 2 AND Phase 3 agent finding files
2. If Phase 3 is not complete:
   a. Halt with error: "Phase 3 (Cross-Domain Synthesis) not complete. Run phase-3-cross-domain workflow first."
   b. Do not proceed.
3. Inventory the complete analytical record:
   a. Count total findings across all agents
   b. Count total disagreements (resolved and unresolved)
   c. Identify which domains have coverage and which have gaps
4. Update .aegis/STATE.md:
   a. current_phase: 4
   b. phase_status: in_progress
   c. agents_remaining: [devils-advocate]
</step>

<step name="assemble_complete_record" priority="blocking">
1. Load ALL finding files from .aegis/findings/:
   a. Phase 2 agents: architect, data-engineer, security-engineer, compliance-officer, senior-app-engineer, sre, performance-engineer, test-engineer
   b. Phase 3 agents: staff-engineer, reality-gap-analyst
   c. Note any agents that failed (gaps in record)
2. Load ALL disagreement records from .aegis/disagreements/:
   a. Both resolved and unresolved disagreements
   b. Include resolution rationale for resolved ones (the Devil's Advocate may challenge resolutions)
3. Load .aegis/STATE.md with full phase metrics:
   a. Finding counts per agent and domain
   b. Severity distribution
   c. Coverage gaps
   d. Disagreement resolution status
4. Load .aegis/scope.md for audit boundary awareness.
5. Estimate total context size — the Devil's Advocate receives the LARGEST context of any agent session.
</step>

<step name="prepare_devils_advocate_context" priority="blocking">
1. Load devils-advocate agent manifest from src/core/agents/devils-advocate.md.
2. Resolve component references:
   a. Persona: src/core/personas/devils-advocate.md
   b. Domains: none (empty — meta-reasoner operates on analytical record, not raw signals)
   c. Tools: none (empty — no tool signals, only findings and disagreements)
   d. Schemas: finding, disagreement, confidence
   e. Rules: epistemic-hygiene, disagreement-protocol, agent-boundaries
3. Build context bundle:
   a. Persona specification (first — adversarial identity is critical)
   b. Rules (second — especially disagreement protocol)
   c. Complete finding record (third — ALL findings from ALL agents)
   d. All disagreement records (fourth — including resolved ones)
   e. Audit state and metrics (fifth — coverage awareness)
   f. Scope document (sixth — boundary awareness)
4. If context exceeds session budget:
   a. Never trim persona or rules
   b. Prioritize: high-severity findings > medium > low
   c. Prioritize: unresolved disagreements > resolved ones
   d. Prioritize: findings from domains with highest signal density
   e. Log any trimmed content in .aegis/STATE.md
</step>

<step name="invoke_devils_advocate" priority="blocking">
1. Invoke devils-advocate session with the complete analytical record:
   a. Primary directive: INVALIDATE conclusions, not agree
   b. Challenge high-confidence claims that lack diverse evidence
   c. Attack clean narratives — look for suspiciously tidy conclusions
   d. Surface areas with little disagreement — consensus may hide blind spots
   e. Use inversion: "Under what conditions does this become unsafe?"
   f. Seek asymmetric failure: "What failure would be disproportionately damaging?"
2. Session produces:
   a. Critique findings — each challenges a specific prior finding or pattern
   b. New disagreement records — structured challenges to existing conclusions
   c. Blind spot identification — areas the audit may have missed entirely
   d. Confidence attacks — findings where confidence is higher than evidence warrants
3. All output must conform to schemas:
   a. Critiques as findings per src/schemas/finding.md
   b. Challenges as disagreements per src/schemas/disagreement.md
   c. Confidence assessments per src/schemas/confidence.md
4. On session completion:
   a. Invoke session-handoff workflow (src/core/workflows/session-handoff.md)
   b. Update .aegis/STATE.md: agents_completed += [devils-advocate]
</step>

<step name="process_adversarial_output" priority="blocking">
1. For each new disagreement raised by the Devil's Advocate:
   a. Validate against src/schemas/disagreement.md
   b. Verify it references valid finding IDs from prior phases
   c. Assign disagreement ID: D-{NNN} (continuing from previous sequence)
   d. Set status: open
   e. Set principal_response: pending (REQUIRED — will be filled in Phase 5)
   f. Write to .aegis/disagreements/{disagreement-id}.md
2. For each critique finding:
   a. Validate against src/schemas/finding.md
   b. Write to .aegis/findings/devils-advocate.md
3. Queue disagreement-resolution workflow for ALL open disagreements:
   a. This includes Phase 2 disagreements still unresolved
   b. Plus all new Phase 4 disagreements
   c. The Principal Engineer MUST respond to every disagreement before Phase 5 synthesis
</step>

<step name="update_state_phase_complete" priority="blocking">
1. Update .aegis/STATE.md:
   a. current_phase: 4
   b. phase_status: complete
   c. phase_4_complete: true
   d. agents_completed: [devils-advocate]
   e. devils_advocate_critiques: N (number of critique findings)
   f. new_disagreements_phase_4: N
   g. total_disagreements: updated cumulative count
   h. unresolved_disagreements: count of status: open
   i. next_phase: 5 (ONLY if all disagreements have principal_response, otherwise disagreement resolution first)
   j. timestamp: completion time
2. Determine next action:
   a. If unresolved disagreements exist: route to disagreement-resolution workflow BEFORE Phase 5
   b. If all disagreements resolved: route to Phase 5
   c. Record routing decision in STATE.md
</step>

</process>

<output>
Artifacts created:
- .aegis/findings/devils-advocate.md — Adversarial critique findings
- .aegis/disagreements/{disagreement-id}.md — New challenge records for each contested conclusion
- .aegis/STATE.md — Updated with Phase 4 completion, critique counts, and disagreement status

All finding files conform to src/schemas/finding.md.
All disagreement records conform to src/schemas/disagreement.md.
</output>

<error_handling>
- **Phase 3 not complete:** Halt immediately. Display: "Phase 3 (Cross-Domain Synthesis) must complete before adversarial review. Run phase-3-cross-domain first." Do not proceed.
- **Devil's Advocate session failure:** This is a CRITICAL failure — Phase 4 is not optional. The adversarial review is a core epistemic safeguard. Record failure in STATE.md. Present to user with strong recommendation to retry. Do not auto-skip to Phase 5.
- **Context budget exceeded:** The Devil's Advocate session has the largest context need. If the complete analytical record doesn't fit: (a) summarize low-severity findings instead of including full text, (b) include full text only for high/critical severity, (c) always include ALL disagreement records in full, (d) log what was summarized.
- **Devil's Advocate produces no disagreements:** This is suspicious — a thorough adversarial review almost always finds something to challenge. Flag as potential issue: (a) Agent may not have received sufficient adversarial persona activation, (b) Agent may have been too deferential. Record concern in STATE.md. Do not block Phase 5 but note the anomaly.
- **Excessive disagreements (>30% of findings challenged):** Not an error — a high challenge rate may indicate genuine issues. Record the volume. Do not auto-filter. All challenges go to the Principal Engineer for response.
- **Disagreement references invalid finding ID:** Reject the specific disagreement record. Log the invalid reference. Accept other valid disagreements from the same session.
</error_handling>
