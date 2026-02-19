<purpose>
Executes parallel deep domain audits by invoking 8 specialist agents — each analyzing their assigned domains using Phase 1 signals as evidence, producing independent findings using the formal epistemic schema, and detecting cross-agent disagreements.
</purpose>

<phase_context>
Phase: 2 — Deep Domain Audits
Prior phase output: Phase 0 scope (.aegis/scope.md), Phase 1 normalized signals (.aegis/signals/*.md), signal summary (.aegis/signals/SUMMARY.md)
Agents invoked: architect, data-engineer, security-engineer, compliance-officer, senior-app-engineer, sre, performance-engineer, test-engineer (8 agents, all parallel-eligible)
Output: Per-agent finding sets (.aegis/findings/{agent-id}.md), disagreement records (.aegis/disagreements/*.md if any), updated .aegis/STATE.md
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/scope.md
@.aegis/signals/SUMMARY.md
@.aegis/signals/*.md (all signal files)
@src/core/agents/architect.md
@src/core/agents/data-engineer.md
@src/core/agents/security-engineer.md
@src/core/agents/compliance-officer.md
@src/core/agents/senior-app-engineer.md
@src/core/agents/sre.md
@src/core/agents/performance-engineer.md
@src/core/agents/test-engineer.md
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
1. Verify .aegis/STATE.md shows Phase 1 complete:
   a. Check phase_1_complete: true
   b. Check .aegis/signals/ directory contains at least one signal file
   c. Check .aegis/signals/SUMMARY.md exists
2. If Phase 1 is not complete:
   a. Halt with error: "Phase 1 (Signal Gathering) not complete. Run phase-1-reconnaissance workflow first."
   b. Do not proceed.
3. Read signal summary to understand available evidence:
   a. Which tools produced signals
   b. Which domains have signal coverage
   c. Any coverage gaps to note
4. Update .aegis/STATE.md:
   a. current_phase: 2
   b. phase_status: in_progress
   c. agents_remaining: [architect, data-engineer, security-engineer, compliance-officer, senior-app-engineer, sre, performance-engineer, test-engineer]
</step>

<step name="prepare_agent_contexts" priority="blocking">
1. For each of the 8 domain audit agents:
   a. Load agent manifest from src/core/agents/{agent-id}.md
   b. Resolve all component references:
      - Persona: src/core/personas/{persona-id}.md
      - Domains: src/domains/{DD}-*.md for each domain in the manifest
      - Schemas: src/schemas/{schema-id}.md for each declared schema
      - Rules: src/rules/{rule-id}.md for each declared rule
   c. Collect relevant signals:
      - Load .aegis/signals/{tool-id}.md for each tool declared in the agent manifest
      - Filter signals to those tagged with the agent's domain IDs
   d. Include shared context:
      - .aegis/scope.md (audit boundaries and focus areas)
      - .aegis/STATE.md (audit position awareness)
   e. Include the agent manifest's "Session Context" section for phase-specific instructions

2. Build per-agent context bundles ordered by priority:
   a. Persona specification (first — defines identity and reasoning approach)
   b. Rules (second — constraints on behavior)
   c. Domain modules (third — knowledge base)
   d. Relevant signals (fourth — evidence to analyze)
   e. Scope and state (fifth — situational awareness)

3. Verify each context bundle fits within session budget:
   a. Estimate token count per bundle
   b. If exceeding budget: prioritize persona > rules > primary domain > signals > secondary domains
   c. Log any trimmed context in .aegis/STATE.md

4. Record agent invocation plan in .aegis/STATE.md.
</step>

<step name="invoke_domain_agents" priority="blocking">
1. All 8 agents are parallel-eligible (no inter-dependencies within Phase 2).
2. Invoke agents with their prepared context bundles:
   a. Each agent receives: persona + domains + signals + schemas + rules + scope
   b. Each agent produces findings ONLY for their assigned domains
   c. Each finding must conform to src/schemas/finding.md (7 epistemic layers)
   d. Each finding must include confidence vector per src/schemas/confidence.md
3. For each agent session:
   a. Record session start time in .aegis/STATE.md
   b. Monitor for session completion or timeout
   c. On completion: invoke session-handoff workflow (src/core/workflows/session-handoff.md)
   d. On timeout: mark as interrupted in .aegis/STATE.md, continue with remaining agents
4. Track completion across all agents:
   a. Update agents_completed and agents_remaining in .aegis/STATE.md after each
   b. Phase 2 continues until all agents complete or fail
</step>

<step name="validate_all_outputs" priority="blocking">
1. For each agent's finding set (validated individually by session-handoff):
   a. Confirm findings reference only the agent's declared domains
   b. Confirm no agent produced findings outside their domain boundaries (per agent-boundaries rules)
   c. Confirm confidence vectors are complete (all 4 dimensions rated)
   d. Confirm evidence fields are populated (not asserted without support)
2. Aggregate validation results:
   a. Total findings produced across all agents
   b. Findings per domain
   c. Findings per severity level
   d. Any findings that failed validation (quarantined by session-handoff)
3. Check domain coverage:
   a. Which domains received findings
   b. Which domains have zero findings (potential blind spots)
   c. Record coverage analysis in .aegis/STATE.md
</step>

<step name="detect_disagreements" priority="blocking">
1. Compare findings across agents for overlapping concerns:
   a. Agents with shared domains (e.g., senior-app-engineer domains [03,09] may overlap with architect domain [01] on structural concerns)
   b. Same code area assessed differently by different agents
   c. Same pattern receiving different severity ratings
   d. Contradictory recommendations for the same issue
2. For each detected disagreement:
   a. Create disagreement record conforming to src/schemas/disagreement.md
   b. Identify the epistemic layer disputed (interpretation, assumptions, impact, likelihood, judgment)
   c. Record both agent positions with their evidence and confidence
   d. Assign disagreement ID: D-{NNN}
   e. Set status: open
   f. Set principal_response: pending (to be filled by disagreement resolution)
3. Write disagreement records to .aegis/disagreements/{disagreement-id}.md.
4. If disagreements exist:
   a. Queue disagreement-resolution workflow (src/core/workflows/disagreement-resolution.md)
   b. Record disagreement count in .aegis/STATE.md
   c. Note: disagreement resolution may occur between Phase 2 and Phase 3, or be deferred to Phase 5
</step>

<step name="update_state_phase_complete" priority="blocking">
1. Update .aegis/STATE.md:
   a. current_phase: 2
   b. phase_status: complete
   c. phase_2_complete: true
   d. agents_completed: [list of all agents that completed successfully]
   e. agents_failed: [list of any agents that failed, with reasons]
   f. total_findings: N
   g. findings_per_agent: {agent-id: count}
   h. findings_per_domain: {domain_id: count}
   i. disagreements_detected: N
   j. disagreements_resolved: N (may be 0 if deferred)
   k. next_phase: 3
   l. timestamp: completion time
2. Record Phase 2 metrics:
   a. Duration (total and per-agent)
   b. Finding volumes and severity distribution
   c. Domain coverage completeness
   d. Disagreement summary
</step>

</process>

<output>
Artifacts created:
- .aegis/findings/architect.md — Architecture domain findings
- .aegis/findings/data-engineer.md — Data & state integrity findings
- .aegis/findings/security-engineer.md — Security domain findings
- .aegis/findings/compliance-officer.md — Compliance & governance findings
- .aegis/findings/senior-app-engineer.md — Correctness & maintainability findings
- .aegis/findings/sre.md — Reliability & operability findings
- .aegis/findings/performance-engineer.md — Performance & scalability findings
- .aegis/findings/test-engineer.md — Testing strategy findings
- .aegis/disagreements/{disagreement-id}.md — Cross-agent disagreement records (if any)
- .aegis/STATE.md — Updated with Phase 2 completion, finding metrics, disagreement counts

All finding files conform to src/schemas/finding.md.
All disagreement records conform to src/schemas/disagreement.md.
</output>

<error_handling>
- **Phase 1 not complete:** Halt immediately. Display: "Phase 1 (Signal Gathering) must complete before domain audits. Run phase-1-reconnaissance first." Do not proceed.
- **No signals available for an agent's domains:** Invoke the agent anyway — agents can analyze code structure and patterns without tool signals. Note reduced evidence base in .aegis/STATE.md. Agent's confidence vectors should reflect limited signal diversity.
- **Agent session failure:** Log failure in .aegis/STATE.md. Skip failed agent and continue with remaining agents. Record which domains lost coverage. Warn user that audit has gaps. Do not retry automatically.
- **Agent produces findings outside declared domains:** Reject the out-of-scope findings (per agent-boundaries rules). Log boundary violation in .aegis/STATE.md. Accept valid in-scope findings from the same session.
- **Schema validation failure (finding malformed):** Handled by session-handoff workflow — quarantine invalid findings, accept valid ones. If ALL findings from an agent fail validation, mark agent session as "validation-failed" and flag for re-run.
- **Context budget exceeded for an agent:** Trim signals by relevance (keep signals tagged for agent's primary domain, drop secondary domain signals). Never trim persona or rules. Log trimmed context. Agent's findings should note limited evidence base.
- **All agents fail:** Halt phase. Record failure in STATE.md. Phase 3 cannot proceed without Phase 2 findings. Present to user for diagnosis.
- **Disagreement detection produces false positives:** Accept over-detection. False positives are resolved by the Principal Engineer in the disagreement-resolution workflow. Under-detection is worse — it hides risk.
</error_handling>
