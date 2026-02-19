<purpose>
Orchestrates execution planning by invoking the Execution Validator to define verification steps for every proposed change, build a dependency graph, and generate PAUL-compatible project artifacts — producing the complete Layer C execution plan without ever applying changes.
</purpose>

<phase_context>
Phase: 8 — Execution Planning
Prior phase output: Risk-scored change plan (execution/risk-scores.yaml), Phase 6 playbooks (remediation/playbooks/), Phase 7 guardrails (remediation/guardrails/), risk assessment report
Agents invoked: execution-validator (single agent)
Output: execution/change-graph.yaml (dependency graph), execution/verification-plan.md (verification steps per change), execution/paul-project/ (PAUL-compatible project artifacts)
CRITICAL: AEGIS Transform NEVER applies changes. This workflow produces a plan only.
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/findings/*.md (for traceability)
@execution/risk-scores.yaml (Phase 7 output)
@remediation/playbooks/*.md (Phase 6 output)
@remediation/guardrails/*.md (Phase 7 output)
@src/transform/agents/execution-validator.md
@src/transform/schemas/verification-plan.md
@src/transform/schemas/intervention-level.md
@src/transform/schemas/change-risk.md
@src/transform/rules/safety-governance.md
@src/transform/rules/change-risk-rules.md
@src/transform/workflows/transform-safety.md
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md shows Phase 7 (Change Risk Validation) complete:
   a. Check phase_7_complete: true
   b. Check execution/risk-scores.yaml exists
   c. Check remediation/guardrails/ contains at least one file
2. If Phase 7 is not complete:
   a. Halt with error: "Phase 7 (Change Risk Validation) not complete. Run phase-7-risk-validation workflow first."
   b. Do not proceed.
3. Load Phase 7 output metrics from .aegis/STATE.md.
4. Update .aegis/STATE.md:
   a. current_phase: 8
   b. phase_status: in_progress
</step>

<step name="load_execution_context" priority="blocking">
1. Load risk-scored change plan from execution/risk-scores.yaml:
   a. All proposed changes with dimensional risk profiles
   b. Final intervention levels (post-safety-validation)
   c. Risk-adjusted priority ordering
2. Load Phase 6 playbooks for remediation detail:
   a. Transformation layers (abstract → project-specific)
   b. Educational context from Pedagogy Agent
3. Load Phase 7 guardrails for constraint integration.
4. Load test infrastructure inventory and deployment configuration if available.
5. Build complete change manifest:
   a. Every change with its risk profile, intervention level, playbook reference, and guardrail references
   b. Dependencies between changes (from Remediation Architect's ordering)
6. Record execution context metrics in .aegis/STATE.md.
</step>

<step name="invoke_execution_validator" priority="blocking">
1. Load agent manifest from src/transform/agents/execution-validator.md.
2. Resolve all component references:
   a. Persona: src/transform/personas/execution-validator.md
   b. Schemas: src/transform/schemas/verification-plan.md, src/transform/schemas/intervention-level.md, src/transform/schemas/change-risk.md
   c. Rules: src/transform/rules/safety-governance.md, src/transform/rules/change-risk-rules.md
3. Provide complete change manifest as input.
4. Instruct agent to:
   a. Define verification steps for every proposed change:
      - Pre-change baseline observation
      - Post-change acceptance criteria (traced to original finding)
      - Regression verification (what was working, confirm it still is)
      - Rollback criteria (conditions that trigger reverting the change)
   b. Build dependency graph for change sequencing:
      - Explicit dependencies (change A must precede change B)
      - Implicit dependencies (shared code paths, behavioral contracts)
      - Parallel-eligible change groups (independent changes that can proceed concurrently)
   c. Generate PAUL-compatible project artifacts:
      - PROJECT.md (project definition with AEGIS audit reference)
      - ROADMAP.md (phased plan with dependency ordering and verification gates)
      - Per-phase PLAN.md files with tasks, acceptance criteria, and risk metadata per task
   d. Embed risk metadata in PAUL task definitions:
      - Intervention level per task
      - Change risk scores per task
      - Finding confidence reference per task
      - Verification plan reference per task
5. Validate verification plan against src/transform/schemas/verification-plan.md.
6. Record execution-validator session completion in .aegis/STATE.md.
</step>

<step name="final_safety_validation" priority="blocking">
1. Invoke transform-safety workflow for final validation:
   a. Pass complete PAUL project structure
   b. Pass all verification plans
2. Safety workflow validates:
   a. No-auto-execution boundary: PAUL project contains plans only — no execution commands, no direct file modifications, no bypass mechanisms
   b. All 5 refusal conditions re-checked against final plan
   c. Every task carries appropriate intervention level and risk metadata
   d. Verification gates exist at every phase boundary
3. If safety violations detected:
   a. This is the last safety gate before handoff — violations must be resolved
   b. Adjust PAUL project to comply
   c. Re-validate until clean
4. Record final safety validation results in .aegis/STATE.md.
</step>

<step name="persist_and_finalize" priority="blocking">
1. Write change dependency graph to execution/change-graph.yaml:
   a. Nodes: proposed changes with risk profiles
   b. Edges: dependency relationships (explicit and implicit)
   c. Groups: parallel-eligible change sets
2. Write verification plan to execution/verification-plan.md:
   a. Per-change verification steps (pre-change, post-change, regression, rollback)
   b. Evidence chain from each verification criterion back to original finding
3. Write PAUL project to execution/paul-project/:
   a. PROJECT.md
   b. ROADMAP.md
   c. Per-phase PLAN.md files
   d. All files carry risk metadata and verification references
4. Generate handoff summary:
   a. Total changes planned, by intervention level
   b. Estimated phases and dependencies
   c. Key risks and mitigation strategies
   d. Guardrails to install before execution begins
5. Update .aegis/STATE.md:
   a. current_phase: 8
   b. phase_status: complete
   c. phase_8_complete: true
   d. transform_complete: true
   e. paul_project_generated: true
   f. total_changes, changes_by_intervention_level, phases_in_paul_project
   g. timestamp
6. Mark Transform pipeline complete.
</step>

</process>

<output>
Artifacts created:
- execution/change-graph.yaml — Dependency graph of all proposed changes
- execution/verification-plan.md — Verification steps per change with evidence chains to original findings
- execution/paul-project/PROJECT.md — PAUL project definition with AEGIS audit reference
- execution/paul-project/ROADMAP.md — Phased plan with dependency ordering and verification gates
- execution/paul-project/phases/{NN}-*/PLAN.md — Per-phase plans with risk metadata per task
- .aegis/STATE.md — Updated with Phase 8 and Transform pipeline completion

CRITICAL: No execution artifacts. No file modifications. No change commands. AEGIS Transform produces plans only.
All verification plans conform to src/transform/schemas/verification-plan.md.
PAUL project validated by transform-safety workflow.
</output>

<error_handling>
- **Phase 7 not complete:** Halt immediately. Display: "Phase 7 (Change Risk Validation) must complete before execution planning. Run phase-7-risk-validation workflow first." Do not proceed.
- **Verification plan cannot be constructed for a change:** Record as "unverifiable" with specific gap (missing oracle, environment mismatch, untestable behavior). Include in handoff summary. An unverifiable change should not be included in the PAUL project without explicit risk acknowledgment.
- **PAUL project generation fails:** Produce a manual remediation plan as fallback — a structured document describing changes, ordering, and verification in human-readable format without PAUL project structure. Record fallback in STATE.md.
- **Final safety validation finds violations:** Resolve violations before persisting. This is the last gate — no bypass. If violations cannot be resolved, remove the violating changes from the PAUL project and record as "excluded by safety validation" with reasons.
- **Dependency graph has cycles:** Report cycle to user. Cycles in change dependencies indicate that changes cannot be sequenced safely — some manual intervention is needed to break the cycle. Do not force a topological ordering that ignores cycles.
- **No-auto-execution boundary violation detected:** This is a CRITICAL error. Remove any execution commands, file modification instructions, or bypass mechanisms. Re-validate. Transform NEVER executes changes under any circumstances.
</error_handling>
