<purpose>
Executes cross-domain synthesis audits by invoking the Staff Engineer (change risk and team ownership analysis) followed by the Reality Gap Analyst (code-vs-runtime divergence detection) — both drawing on Phase 2 findings and specialized signal sources.
</purpose>

<phase_context>
Phase: 3 — Change Risk, Team Risk & Reality Gap
Prior phase output: Phase 2 domain findings (.aegis/findings/*.md from 8 agents), Phase 1 signals (.aegis/signals/*.md), Phase 0 scope (.aegis/scope.md)
Agents invoked: staff-engineer (sequential first), reality-gap-analyst (sequential second). Sequential because Reality Gap Analyst benefits from Staff Engineer's change risk findings.
Output: .aegis/findings/staff-engineer.md, .aegis/findings/reality-gap-analyst.md, additional .aegis/disagreements/*.md if any, updated .aegis/STATE.md
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/scope.md
@.aegis/findings/*.md (all Phase 2 agent finding files)
@.aegis/signals/git-history.md
@.aegis/signals/checkov.md
@.aegis/signals/sonarqube.md
@~/.claude/aegis/core/agents/staff-engineer.md
@~/.claude/aegis/core/agents/reality-gap-analyst.md
@~/.claude/aegis/schemas/finding.md
@~/.claude/aegis/schemas/disagreement.md
@~/.claude/aegis/schemas/confidence.md
@~/.claude/aegis/rules/epistemic-hygiene.md
@~/.claude/aegis/rules/disagreement-protocol.md
@~/.claude/aegis/rules/agent-boundaries.md
@~/.claude/aegis/core/workflows/session-handoff.md
@~/.claude/aegis/core/workflows/disagreement-resolution.md
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md shows Phase 2 complete:
   a. Check phase_2_complete: true
   b. Check .aegis/findings/ directory contains Phase 2 agent finding files
   c. Verify at least 6 of 8 domain agents produced findings (allow partial coverage)
2. If Phase 2 is not complete:
   a. Halt with error: "Phase 2 (Domain Audits) not complete. Run phase-2-domain-audits workflow first."
   b. Do not proceed.
3. Check for any unresolved disagreements from Phase 2:
   a. Read .aegis/disagreements/*.md for status: open
   b. Note count — these may be resolved during or after Phase 3
4. Update .aegis/STATE.md:
   a. current_phase: 3
   b. phase_status: in_progress
   c. agents_remaining: [staff-engineer, reality-gap-analyst]
</step>

<step name="prepare_staff_engineer_context" priority="blocking">
1. Load staff-engineer agent manifest from src/core/agents/staff-engineer.md.
2. Resolve component references:
   a. Persona: src/core/personas/staff-engineer.md
   b. Domains: src/domains/11-change-risk.md, src/domains/12-team-risk.md
   c. Tools: git-history, sonarqube, semgrep, syft, grype
   d. Schemas: finding, disagreement, confidence, signal
   e. Rules: epistemic-hygiene, disagreement-protocol, agent-boundaries
3. Collect input context:
   a. ALL Phase 2 findings from .aegis/findings/*.md — Staff Engineer synthesizes across domains
   b. .aegis/signals/git-history.md — primary signal source for change risk and ownership analysis
   c. .aegis/signals/sonarqube.md — code health metrics
   d. .aegis/signals/semgrep.md — pattern detection
   e. .aegis/signals/syft.md and .aegis/signals/grype.md — dependency risk signals
   f. .aegis/scope.md — audit boundaries
   g. .aegis/STATE.md — audit position and Phase 2 metrics
4. Build context bundle (priority order: persona > rules > domains > Phase 2 findings > signals > state).
5. Staff Engineer is active in phases [2, 3] — in Phase 3, the role is SYNTHESIS over Phase 2 findings, not independent signal gathering.
</step>

<step name="invoke_staff_engineer" priority="blocking">
1. Invoke staff-engineer session with prepared context:
   a. Phase 3 instructions: synthesize change risk and team ownership patterns from Phase 2 findings + git history
   b. Produce findings for Domain 11 (Change Risk & Evolvability) and Domain 12 (Team, Ownership & Knowledge Risk)
   c. Each finding must reference the Phase 2 findings that informed it (cross-reference by finding ID)
   d. Confidence vectors must reflect the synthesis nature — evidence_diversity depends on how many Phase 2 agents' findings support the conclusion
2. Session produces:
   a. Change risk findings — code areas most likely to cause regression, highest churn, dependency bottlenecks
   b. Team ownership findings — bus factor analysis, knowledge concentration, orphaned code areas
   c. Evolvability assessment — how resistant the codebase is to safe change
3. On session completion:
   a. Invoke session-handoff workflow (src/core/workflows/session-handoff.md)
   b. Update .aegis/STATE.md: agents_completed += [staff-engineer]
4. On session failure:
   a. Log failure, mark staff-engineer as failed
   b. Proceed to reality-gap-analyst (independent value even without change risk findings)
</step>

<step name="prepare_reality_gap_analyst_context" priority="blocking">
1. Load reality-gap-analyst agent manifest from src/core/agents/reality-gap-analyst.md.
2. Resolve component references:
   a. Persona: src/core/personas/reality-gap-analyst.md
   b. Focus domains: src/domains/00-context.md, src/domains/01-architecture.md, src/domains/07-reliability.md, src/domains/10-operability.md
   c. Tools: checkov, git-history, sonarqube
   d. Schemas: finding, disagreement, confidence, signal
   e. Rules: epistemic-hygiene, disagreement-protocol, agent-boundaries
3. Collect input context:
   a. ALL Phase 2 findings from .aegis/findings/*.md — Reality Gap Analyst is cross-domain by nature
   b. Staff Engineer findings from .aegis/findings/staff-engineer.md (if available — produced in previous step)
   c. .aegis/signals/checkov.md — infrastructure-as-code policy signals (code-vs-config divergence)
   d. .aegis/signals/git-history.md — change patterns revealing drift
   e. .aegis/signals/sonarqube.md — code quality signals
   f. .aegis/scope.md and .aegis/threat-model.md — deployment context is critical for gap analysis
   g. .aegis/STATE.md
4. Build context bundle (priority order: persona > rules > focus domains > Phase 2+3 findings > signals > state).
5. Note: Reality Gap Analyst has 4 focus domains but can reference ANY domain's findings to detect cross-domain divergence patterns.
</step>

<step name="invoke_reality_gap_analyst" priority="blocking">
1. Invoke reality-gap-analyst session with prepared context:
   a. Phase 3 instructions: detect divergence between code-as-written and system-as-run
   b. Focus areas: deployment configuration vs code assumptions, documented architecture vs actual structure, reliability claims vs operational evidence, developer experience claims vs tooling reality
   c. Produce findings that identify WHERE the codebase's self-description diverges from its actual behavior
   d. Each finding must cite specific evidence of the gap (not theoretical concerns)
2. Session produces:
   a. Reality gap findings — concrete instances where code and runtime diverge
   b. Cross-domain divergence patterns — gaps that span multiple audit domains
   c. Configuration drift findings — deployment configs that don't match code expectations
3. On session completion:
   a. Invoke session-handoff workflow (src/core/workflows/session-handoff.md)
   b. Update .aegis/STATE.md: agents_completed += [reality-gap-analyst]
</step>

<step name="detect_phase_3_disagreements" priority="blocking">
1. Compare Phase 3 findings against Phase 2 findings for conflicts:
   a. Staff Engineer's change risk assessment vs individual agent severity ratings
   b. Reality Gap Analyst's divergence findings vs domain agents' assumptions
   c. Any Phase 3 finding that directly contradicts a Phase 2 finding
2. For each disagreement:
   a. Create record per src/schemas/disagreement.md
   b. Assign ID: D-{NNN} (continuing from Phase 2 sequence)
   c. Set status: open
   d. Write to .aegis/disagreements/{disagreement-id}.md
3. If new disagreements detected:
   a. Queue disagreement-resolution workflow
   b. Record count in .aegis/STATE.md
</step>

<step name="update_state_phase_complete" priority="blocking">
1. Update .aegis/STATE.md:
   a. current_phase: 3
   b. phase_status: complete
   c. phase_3_complete: true
   d. agents_completed: [staff-engineer, reality-gap-analyst] (or partial list if any failed)
   e. total_findings: updated cumulative count
   f. phase_3_findings: N
   g. disagreements_total: updated cumulative count
   h. next_phase: 4
   i. timestamp: completion time
2. Record Phase 3 metrics:
   a. Duration (total and per-agent)
   b. New findings produced
   c. Cross-domain patterns identified
   d. New disagreements detected
</step>

</process>

<output>
Artifacts created:
- .aegis/findings/staff-engineer.md — Change risk, team ownership, and evolvability findings
- .aegis/findings/reality-gap-analyst.md — Code-vs-runtime divergence findings
- .aegis/disagreements/{disagreement-id}.md — New cross-phase disagreement records (if any)
- .aegis/STATE.md — Updated with Phase 3 completion and cumulative metrics

All finding files conform to src/schemas/finding.md.
All disagreement records conform to src/schemas/disagreement.md.
</output>

<error_handling>
- **Phase 2 not complete:** Halt immediately. Display: "Phase 2 (Domain Audits) must complete before cross-domain synthesis. Run phase-2-domain-audits first." Do not proceed.
- **Staff Engineer session failure:** Log failure. Proceed to Reality Gap Analyst — the two agents are independent enough that Reality Gap analysis has standalone value. Record missing change risk coverage in STATE.md.
- **Reality Gap Analyst session failure:** Log failure. Phase 3 can complete with Staff Engineer findings only, but flag reduced cross-domain coverage. Record in STATE.md.
- **Both agents fail:** Mark Phase 3 as failed. Phase 4 (Adversarial Review) can still proceed with Phase 2 findings alone, but warn user of significant synthesis gap.
- **Excessive disagreements with Phase 2:** If Phase 3 agents disagree with >50% of Phase 2 findings, flag as potential systematic issue (scope mismatch, signal quality problem, or genuine paradigm conflict). Do not auto-resolve — present to user and queue for disagreement-resolution.
- **Missing git-history signals:** Staff Engineer depends heavily on git history for change risk and ownership analysis. If .aegis/signals/git-history.md is missing, warn that change risk and team ownership findings will have reduced confidence. Agent should set evidence_diversity dimension low in confidence vectors.
</error_handling>
