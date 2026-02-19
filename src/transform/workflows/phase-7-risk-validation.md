<purpose>
Orchestrates change risk validation by invoking the Change Risk Modeler to score every proposed change across 4 risk dimensions, then the Guardrail Generator to produce machine-enforceable constraints from audit patterns — completing the risk-aware remediation pipeline.
</purpose>

<phase_context>
Phase: 7 — Change Risk Validation
Prior phase output: Phase 6 remediation playbooks (remediation/playbooks/), cross-cutting patterns (remediation/patterns/), remediation summary (remediation/REMEDIATION-SUMMARY.md)
Agents invoked: change-risk-modeler (first), guardrail-generator (second) — sequential, not parallel
Output: execution/risk-scores.yaml (dimensional risk profiles), remediation/guardrails/ (machine-enforceable constraints), risk assessment report
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/signals/git-history.md
@.aegis/findings/*.md (for guardrail context)
@remediation/playbooks/*.md (Phase 6 output)
@remediation/patterns/*.md (cross-cutting patterns)
@~/.claude/aegis/transform/agents/change-risk-modeler.md
@~/.claude/aegis/transform/agents/guardrail-generator.md
@~/.claude/aegis/transform/schemas/change-risk.md
@~/.claude/aegis/transform/schemas/playbook.md
@~/.claude/aegis/transform/schemas/intervention-level.md
@~/.claude/aegis/transform/rules/safety-governance.md
@~/.claude/aegis/transform/rules/change-risk-rules.md
@~/.claude/aegis/transform/workflows/transform-safety.md
@~/.claude/aegis/domains/11-*.md (change risk domain)
@~/.claude/aegis/tools/git-history.md (tool adapter)
@~/.claude/aegis/tools/semgrep.md (tool adapter for guardrail format)
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md shows Phase 6 (Remediation Synthesis) complete:
   a. Check phase_6_complete: true
   b. Check remediation/playbooks/ contains at least one playbook
   c. Check remediation/REMEDIATION-SUMMARY.md exists
2. If Phase 6 is not complete:
   a. Halt with error: "Phase 6 (Remediation Synthesis) not complete. Run phase-6-remediation workflow first."
   b. Do not proceed.
3. Load Phase 6 output metrics from .aegis/STATE.md.
4. Update .aegis/STATE.md:
   a. current_phase: 7
   b. phase_status: in_progress
</step>

<step name="load_risk_context" priority="blocking">
1. Load all Phase 6 playbooks from remediation/playbooks/.
2. Load git-history signals from .aegis/signals/git-history.md:
   a. Change frequency per file/module
   b. Co-change coupling data
   c. Contributor patterns
3. Load codebase structure map (from Phase 0 context).
4. Load test coverage signals if available.
5. Build a change inventory:
   a. Every proposed modification from every playbook
   b. Affected files, modules, and interfaces per change
   c. Dependencies between proposed changes
6. Record change inventory metrics in .aegis/STATE.md.
</step>

<step name="invoke_change_risk_modeler" priority="blocking">
1. Load agent manifest from src/transform/agents/change-risk-modeler.md.
2. Resolve all component references:
   a. Persona: src/transform/personas/change-risk-modeler.md
   b. Domains: src/domains/11-*.md (change risk domain)
   c. Tools: src/tools/git-history.md
   d. Schemas: src/transform/schemas/change-risk.md, src/transform/schemas/intervention-level.md
   e. Rules: src/transform/rules/safety-governance.md, src/transform/rules/change-risk-rules.md
3. Provide playbooks + git history + codebase structure as input.
4. Instruct agent to:
   a. Score every proposed change across 4 risk dimensions (blast radius, coupling, regression probability, architectural tension)
   b. Present risk as dimensional profiles, never single aggregate scores
   c. Flag changes where ANY dimension exceeds "high" threshold
   d. Identify compound risk where multiple changes target the same module
5. Validate all risk scores against src/transform/schemas/change-risk.md.
6. Record change-risk-modeler session completion in .aegis/STATE.md.
</step>

<step name="validate_risk_thresholds" priority="blocking">
1. Invoke transform-safety workflow (src/transform/workflows/transform-safety.md):
   a. Pass all risk-scored changes with their dimensional profiles
   b. Pass current intervention level for each affected playbook
2. Safety workflow validates:
   a. Risk threshold check: any dimension exceeding "high" → force intervention level downgrade to Suggesting
   b. Confidence gating re-check with risk context
   c. Refusal conditions check (risk exceeds bounds, insufficient test coverage)
3. Apply any downgrades or refusals:
   a. Record original and adjusted intervention levels
   b. Record any refused changes with refusal reasons
4. Establish final risk-adjusted priority ordering:
   a. Order changes by combined risk profile (lowest risk first for conservative sequencing)
   b. Respect dependency ordering from Phase 6 playbooks
5. Record safety validation results in .aegis/STATE.md.
</step>

<step name="invoke_guardrail_generator" priority="blocking">
1. Load agent manifest from src/transform/agents/guardrail-generator.md.
2. Resolve component references:
   a. Persona: src/transform/personas/guardrail-generator.md
   b. Tools: src/tools/semgrep.md (rule format reference)
   c. Schemas: src/transform/schemas/playbook.md
   d. Rules: src/transform/rules/safety-governance.md, src/transform/rules/change-risk-rules.md
3. Provide playbooks + risk scores + original findings as input.
4. Instruct agent to:
   a. Identify failure patterns that warrant structural prevention
   b. Produce machine-enforceable constraints organized by mechanism:
      - CLAUDE.md rules (AI coding assistant constraints)
      - .cursorrules (IDE-level enforcement)
      - Custom linter configurations
      - Pre-commit hook specifications
      - Custom Semgrep rules (using Semgrep rule format from tool adapter)
   c. Include failure mode rationale and invalidation conditions per constraint
   d. Evaluate each constraint against false guardrail test
5. Validate guardrail output conforms to playbook schema (guardrails are a playbook subtype).
6. Record guardrail-generator session completion in .aegis/STATE.md.
</step>

<step name="persist_and_finalize" priority="blocking">
1. Write risk scores to execution/risk-scores.yaml:
   a. Dimensional risk profile per proposed change
   b. Final intervention level (post-safety-validation)
   c. Risk-adjusted priority ordering
   d. Compound risk warnings
2. Write guardrail files to remediation/guardrails/:
   a. Organized by enforcement mechanism
   b. Each includes failure mode rationale and invalidation conditions
3. Generate risk assessment report.
4. Update .aegis/STATE.md:
   a. current_phase: 7
   b. phase_status: complete
   c. phase_7_complete: true
   d. changes_scored, high_risk_count, downgrades_applied, guardrails_generated
   e. next_phase: 8
   f. timestamp
</step>

</process>

<output>
Artifacts created:
- execution/risk-scores.yaml — Dimensional risk profiles per proposed change with final intervention levels
- remediation/guardrails/{mechanism-type}.md — Machine-enforceable constraints organized by enforcement mechanism
- Risk assessment report (in .aegis/reports/ or execution/)
- .aegis/STATE.md — Updated with Phase 7 completion and risk metrics

All risk scores conform to src/transform/schemas/change-risk.md.
All guardrails conform to src/transform/schemas/playbook.md (guardrail subtype).
All intervention levels validated by transform-safety workflow.
</output>

<error_handling>
- **Phase 6 not complete:** Halt immediately. Display: "Phase 6 (Remediation Synthesis) must complete before risk validation. Run phase-6-remediation workflow first." Do not proceed.
- **Risk scoring fails for a change:** Default to maximum risk across all 4 dimensions. Flag for human review. Do not assign low risk by default — unknown risk is treated as high risk.
- **Git history signals unavailable:** Proceed with reduced evidence for coupling and change frequency dimensions. Change Risk Modeler's confidence vectors should reflect limited signal diversity. Blast radius and architectural tension can still be assessed from static structure.
- **Risk threshold forces intervention level downgrade:** Apply downgrade. This is correct behavior. Record original level, downgraded level, and which dimension triggered the downgrade.
- **Guardrail generation fails for a pattern:** Record as "unguarded" with reason. Proceed with remaining patterns. A missing guardrail is noted in the output but does not block Phase 7 completion.
- **False guardrail detected during validation:** Remove the constraint. A constraint that does not actually prevent its target failure mode is worse than no constraint. Log removal with analysis.
- **Refusal condition met:** Safety workflow refuses to generate remediation for affected findings. Record refusal with specific condition. This is the correct safety behavior — not an error to recover from.
</error_handling>
