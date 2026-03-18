<purpose>
Orchestrates remediation synthesis by invoking the Remediation Architect to group Core findings by root cause and produce layered playbooks, then the Pedagogy Agent to enrich those playbooks with educational context — producing the complete Layer B remediation knowledge base.
</purpose>

<phase_context>
Phase: 6 — Remediation Synthesis
Prior phase output: Complete Core audit record — Phase 5 report (.aegis/report/), all findings (.aegis/findings/), all disagreements (.aegis/disagreements/), resolution records, confidence scores, audit scope (.aegis/scope.md)
Agents invoked: remediation-architect (first), pedagogy-agent (second) — sequential, not parallel
Output: remediation/playbooks/ (layered remediation plans), remediation/patterns/ (cross-cutting analysis), remediation/REMEDIATION-SUMMARY.md
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/scope.md
@.aegis/report/AEGIS-REPORT.md
@.aegis/findings/*.md (all agent finding sets)
@.aegis/disagreements/*.md (all disagreement records)
@~/.claude/aegis/transform/agents/remediation-architect.md
@~/.claude/aegis/transform/agents/pedagogy-agent.md
@~/.claude/aegis/transform/schemas/playbook.md
@~/.claude/aegis/transform/schemas/intervention-level.md
@~/.claude/aegis/transform/rules/safety-governance.md
@~/.claude/aegis/transform/rules/change-risk-rules.md
@~/.claude/aegis/transform/workflows/transform-safety.md
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md shows Phase 5 (Report Generation) complete:
   a. Check phase_5_complete: true
   b. Check .aegis/report/AEGIS-REPORT.md exists
   c. Verify all findings and disagreement records are present
2. If Phase 5 is not complete:
   a. Halt with error: "Phase 5 (Report Generation) not complete. Core audit must finish before Transform begins."
   b. Do not proceed.
3. Load audit scope to understand remediation boundaries.
4. Update .aegis/STATE.md:
   a. current_phase: 6
   b. phase_status: in_progress
</step>

<step name="load_layer_a_record" priority="blocking">
1. Load the complete Layer A record:
   a. All finding files from .aegis/findings/ (per-agent finding sets)
   b. All disagreement records from .aegis/disagreements/
   c. Resolution records and principal responses
   d. Confidence scores attached to each finding
   e. Phase 5 report for severity calibration context
2. Build a unified finding index:
   a. Total findings by domain, severity, and confidence level
   b. Cross-references between findings that share code paths or root causes
   c. Disagreements that affect remediation scope (unresolved high-severity disagreements block remediation for affected findings)
3. Record Layer A summary metrics in .aegis/STATE.md.
</step>

<step name="invoke_remediation_architect" priority="blocking">
1. Load agent manifest from src/transform/agents/remediation-architect.md.
2. Resolve all component references:
   a. Persona: src/transform/personas/remediation-architect.md
   b. Domains: all 14 domain modules (src/domains/00-*.md through src/domains/13-*.md)
   c. Schemas: src/transform/schemas/playbook.md, src/transform/schemas/intervention-level.md
   d. Rules: src/transform/rules/safety-governance.md, src/transform/rules/change-risk-rules.md
3. Provide the complete Layer A record as input.
4. Instruct agent to:
   a. Group findings by root cause across domain boundaries
   b. Produce playbooks at all 4 transformation layers (abstract → framework → language → project)
   c. Classify each playbook by intervention level
   d. Record unremediated findings with reasons (insufficient confidence, unclear root cause)
5. Validate all playbook output against src/transform/schemas/playbook.md.
6. Record remediation-architect session completion in .aegis/STATE.md.
</step>

<step name="validate_intervention_levels" priority="blocking">
1. Invoke transform-safety workflow (src/transform/workflows/transform-safety.md):
   a. Pass all playbooks with their intervention level classifications
   b. Pass finding confidence scores for each referenced finding
2. Safety workflow validates:
   a. Confidence gating: each playbook's intervention level matches its evidence base
   b. Risk threshold check (preliminary — full risk scoring happens in Phase 7)
   c. No-auto-execution boundary: playbooks contain plans only, no execution commands
3. Apply any downgrades returned by the safety workflow:
   a. Record original and downgraded intervention levels
   b. Add downgrade rationale to affected playbooks
4. Record safety validation results in .aegis/STATE.md.
</step>

<step name="invoke_pedagogy_agent" priority="blocking">
1. Load agent manifest from src/transform/agents/pedagogy-agent.md.
2. Resolve component references:
   a. Persona: src/transform/personas/pedagogy-agent.md
   b. Schemas: src/transform/schemas/playbook.md
   c. Rules: src/transform/rules/safety-governance.md
3. Provide Remediation Architect's playbook output + original findings.
4. Instruct agent to:
   a. Enrich each playbook with educational context at all 4 transformation layers
   b. Add before/after examples where applicable
   c. Add "why this matters" explanations grounding fixes in principles
   d. Add best-practice rationale for each remediation approach
   e. Surface pattern-level teaching (not just instance-level fixes)
5. Validate enriched playbooks still conform to playbook schema.
6. Record pedagogy-agent session completion in .aegis/STATE.md.
</step>

<step name="persist_and_finalize" priority="blocking">
1. Write all playbook files to remediation/playbooks/:
   a. One file per root cause group
   b. Each includes all 4 transformation layers + educational enrichment
   c. Each carries intervention level classification and confidence metadata
2. Write cross-cutting pattern analysis to remediation/patterns/:
   a. Patterns that span multiple root cause groups
   b. Systemic issues identified across domains
3. Generate remediation/REMEDIATION-SUMMARY.md:
   a. Total playbooks generated
   b. Playbooks by intervention level
   c. Unremediated findings with reasons
   d. Key patterns identified
4. Update .aegis/STATE.md:
   a. current_phase: 6
   b. phase_status: complete
   c. phase_6_complete: true
   d. playbook_count, unremediated_count, intervention_level_distribution
   e. next_phase: 7
   f. timestamp
</step>

</process>

<output>
Artifacts created:
- remediation/playbooks/{root-cause-group}.md — Layered remediation playbooks with educational enrichment (one per root cause group)
- remediation/patterns/{pattern-name}.md — Cross-cutting pattern analysis
- remediation/REMEDIATION-SUMMARY.md — Phase 6 summary with metrics and intervention level distribution
- .aegis/STATE.md — Updated with Phase 6 completion and remediation metrics

All playbook files conform to src/transform/schemas/playbook.md.
All intervention levels validated by transform-safety workflow.
</output>

<error_handling>
- **Phase 5 not complete:** Halt immediately. Display: "Core audit (Phases 0-5) must complete before Transform begins. Run phase-5-report workflow first." Do not proceed.
- **Finding cannot be remediated:** Record as "unremediated" with specific reason (insufficient confidence, unclear root cause, conflicting remediation approaches). Include in REMEDIATION-SUMMARY.md. Do not force remediation where evidence is insufficient.
- **Intervention level downgrade by safety workflow:** Apply downgrade, record rationale. This is correct behavior, not an error. A playbook that claims Authorizing but has Medium confidence MUST be downgraded to Planning.
- **Pedagogy Agent cannot enrich a playbook:** Mark playbook as "unenriched" with reason. Proceed with remaining playbooks. An unenriched playbook is still a valid remediation plan — it just lacks educational context.
- **Schema validation failure on playbook output:** Return to producing agent with specific field-level errors. Allow up to 2 retry attempts. On third failure, log playbook as "unvalidated" and flag for manual review.
- **Unresolved high-severity disagreement blocks remediation:** Do not produce remediation for findings affected by unresolved high-severity disagreements. Record as blocked with reference to disagreement ID. This is safety-correct behavior.
</error_handling>
