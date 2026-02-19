<purpose>
Manages the transfer of context between agent sessions — persisting findings, disagreements, and state after each session completes, and assembling the input context for the next session to begin.
</purpose>

<phase_context>
Phase: Utility — invoked at every session boundary across all AEGIS Core phases (0-5)
Prior phase output: Varies by phase — each agent session produces findings, disagreements, and updated state
Agents invoked: None directly — this workflow is invoked BY phase orchestration workflows after each agent session completes
Output: Validated session artifacts in .aegis/, updated .aegis/STATE.md, assembled context bundle for next session
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@~/.claude/aegis/schemas/finding.md
@~/.claude/aegis/schemas/disagreement.md
@~/.claude/aegis/schemas/confidence.md
@~/.claude/aegis/schemas/signal.md
@~/.claude/aegis/core/agents/{agent-id}.md (the agent that just completed)
</required_input>

<process>

<step name="capture_session_output" priority="first">
1. Identify the agent that just completed its session from .aegis/STATE.md current_agent field.
2. Collect all output artifacts from the completed session:
   a. Finding files — structured per src/schemas/finding.md
   b. Disagreement records — structured per src/schemas/disagreement.md
   c. Any partial report sections (Phase 5 only) — per src/schemas/report-section.md
3. Assign unique IDs to any findings or disagreements that lack them:
   - Findings: F-{DD}-{NNN} where DD is the domain number and NNN is sequential
   - Disagreements: D-{NNN} where NNN is sequential across the audit
4. Tag each artifact with session metadata:
   - agent_id: which agent produced it
   - phase: which AEGIS phase this was produced in
   - timestamp: session completion time
</step>

<step name="validate_against_schemas" priority="blocking">
1. For each finding produced:
   a. Validate all 7 epistemic layers are present per src/schemas/finding.md
   b. Validate confidence vector has all 4 dimensions per src/schemas/confidence.md
   c. Verify severity rating is justified by evidence (not asserted without support)
   d. Check that domain_id matches one of the producing agent's declared domains
2. For each disagreement record:
   a. Validate structure per src/schemas/disagreement.md
   b. Verify both positions reference valid finding IDs
   c. Verify root_cause_taxonomy uses valid categories
3. Record validation results:
   - VALID: artifact passes all checks
   - INVALID: artifact fails — log specific field-level errors
4. For INVALID artifacts:
   a. If the originating session is still available: return to agent with errors for correction
   b. If the originating session has ended: flag as "unvalidated" in .aegis/STATE.md and mark for manual review
   c. Do not write invalid artifacts to the canonical .aegis/ directory
</step>

<step name="persist_to_aegis_directory" priority="blocking">
1. Write validated findings to .aegis/findings/{agent-id}.md:
   - One file per agent containing all findings from that session
   - Append to existing file if agent has run in multiple phases
   - Preserve finding IDs for cross-reference stability
2. Write disagreement records to .aegis/disagreements/{disagreement-id}.md:
   - One file per disagreement for independent tracking
3. Update .aegis/signals/ if the session produced normalized signal data (Phase 1 only):
   - One file per tool: .aegis/signals/{tool-id}.md
4. Verify all writes completed:
   - Confirm file existence
   - Confirm file is non-empty
   - Confirm no write errors
</step>

<step name="update_state" priority="blocking">
1. Update .aegis/STATE.md with:
   a. Session completion record:
      - agent_id, phase, timestamp, status (complete/partial/failed)
   b. Artifact counts:
      - findings_produced: N
      - findings_validated: N
      - findings_invalid: N
      - disagreements_produced: N
   c. Phase progress:
      - agents_completed: N of M for current phase
      - agents_remaining: list of agent IDs not yet run in this phase
   d. Next session:
      - next_agent_id (or "phase_complete" if all agents in phase have run)
2. If all agents in the current phase have completed:
   a. Mark phase as complete in .aegis/STATE.md
   b. Set phase_status to "complete"
   c. Record phase-level metrics (total findings, total disagreements, domain coverage)
</step>

<step name="assemble_next_context" priority="blocking">
1. If next_agent_id is set (another agent runs in this phase or next phase):
   a. Read the next agent's manifest from src/core/agents/{next-agent-id}.md
   b. Resolve component references:
      - Load persona from src/core/personas/{persona-id}.md
      - Load domains from src/domains/{DD}-*.md for each domain in the manifest
      - Load schemas from src/schemas/{schema-id}.md for each declared schema
      - Load rules from src/rules/{rule-id}.md for each declared rule
   c. Collect input signals:
      - For Phase 2+ agents: load .aegis/signals/{tool-id}.md for each tool in the manifest
      - For Phase 3+ agents: load .aegis/findings/ from prior phases for declared domains
      - For Phase 4 (Devil's Advocate): load ALL .aegis/findings/ and .aegis/disagreements/
      - For Phase 5 (Principal Engineer): load complete .aegis/ analytical record
   d. Include session context from the agent manifest's "Session Context" section
   e. Include .aegis/STATE.md for audit position awareness
2. Bundle into a context package:
   - Ordered by priority: persona first, then rules, then domains, then signals/findings
   - Include a context manifest listing all loaded files and their roles
3. Verify context fits within session budget:
   - Estimate token count of assembled context
   - If exceeding budget: prioritize by agent manifest's declared dependencies
   - Log any context that was trimmed due to budget constraints
</step>

<step name="handle_interrupted_session" priority="optional">
1. If a session ended without producing complete output:
   a. Check for partial artifacts (incomplete findings, draft disagreements)
   b. If partial artifacts exist:
      - Validate whatever is complete
      - Mark incomplete fields in .aegis/STATE.md
      - Flag session as "interrupted" with resume point
   c. If no artifacts exist:
      - Mark session as "failed" in .aegis/STATE.md
      - Do not block phase progression — record the gap
2. To resume an interrupted session:
   a. Reload the same context bundle that was prepared for the original session
   b. Include .aegis/STATE.md showing the interruption point
   c. Include any partial artifacts that were saved
   d. Set resume_from field so the agent knows where to continue
</step>

</process>

<output>
Artifacts created or updated per invocation:
- .aegis/findings/{agent-id}.md — Validated finding set from completed session
- .aegis/disagreements/{disagreement-id}.md — Disagreement records (if any)
- .aegis/signals/{tool-id}.md — Normalized signals (Phase 1 sessions only)
- .aegis/STATE.md — Updated with session completion, metrics, and next agent
- Context bundle — Assembled input for the next agent session (in-memory, not persisted as a file)
</output>

<error_handling>
- **Session timeout (no output):** Mark session as "failed" in .aegis/STATE.md. Record which agent and phase. Allow phase to continue with remaining agents but log coverage gap. Do not retry automatically — present to user for decision.
- **Partial output (some findings valid, some invalid):** Accept valid findings. Quarantine invalid findings in .aegis/quarantine/{agent-id}-{timestamp}.md with validation errors. Update STATE.md with partial completion status. Allow phase to continue.
- **Schema validation failure (all output invalid):** Do not persist any artifacts. Mark session as "validation-failed" in STATE.md. Return full error report to user. Agent must re-run with corrected output before phase can complete.
- **State file corruption (.aegis/STATE.md unreadable):** Halt workflow. Attempt reconstruction from .aegis/findings/ and .aegis/disagreements/ file timestamps. Present reconstructed state to user for confirmation before proceeding.
- **Context budget exceeded (next session too large):** Log which components were trimmed. Prioritize: persona > rules > primary domain > signals > prior findings > secondary domains. Never trim persona or rules — these are non-negotiable. If persona + rules alone exceed budget, the audit configuration must be revised.
- **Write failure (disk/permission error):** Halt immediately. Do not proceed to next session. Present error with full path and permission details. Session artifacts exist only in memory until successfully written.
</error_handling>
