<purpose>
Initializes the AEGIS audit by establishing scope, threat model, and risk profile through a Principal Engineer session — the foundational context that all subsequent phases depend on.
</purpose>

<phase_context>
Phase: 0 — Context & Threat Modeling
Prior phase output: None — this is the first phase. Input is the raw target repository and any available business context.
Agents invoked: principal-engineer (Phase 0 role — scope establishment, not synthesis)
Output: Audit scope document (.aegis/scope.md), threat model (.aegis/threat-model.md), risk profile, explicit non-goals, initialized .aegis/STATE.md
</phase_context>

<required_input>
@src/core/agents/principal-engineer.md
@src/core/personas/principal-engineer.md
@src/schemas/finding.md
@src/schemas/confidence.md
@src/rules/epistemic-hygiene.md
@src/rules/agent-boundaries.md
Target repository: structure, README, deployment configs, CI/CD pipelines, business context documents
</required_input>

<process>

<step name="initialize_aegis_state" priority="first">
1. Create the .aegis/ directory structure for this audit:
   - .aegis/STATE.md — Audit state tracker
   - .aegis/findings/ — Per-agent finding directories
   - .aegis/disagreements/ — Disagreement records
   - .aegis/signals/ — Normalized tool output
   - .aegis/report/ — Final report sections
2. Initialize .aegis/STATE.md with:
   - audit_id: Generated unique identifier
   - target_repository: Path to the codebase under audit
   - started_at: Timestamp
   - current_phase: 0
   - current_agent: principal-engineer
   - phase_status: in_progress
   - agents_completed: []
   - agents_remaining: [principal-engineer]
3. Create .aegis/MANIFEST.md with:
   - AEGIS version reference
   - Component versions (SHA-256 hashes of all loaded personas, domains, schemas, rules, tools)
   - Audit configuration (which agents to include, tool settings, scope overrides)
4. Verify all files created successfully before proceeding.
</step>

<step name="gather_repository_context" priority="blocking">
1. Scan the target repository to collect:
   a. Directory structure (top 3 levels)
   b. README.md and any documentation files
   c. Package manifests (package.json, requirements.txt, go.mod, Cargo.toml, etc.)
   d. Deployment configurations (Dockerfile, docker-compose, k8s manifests, terraform, etc.)
   e. CI/CD pipeline definitions (.github/workflows, .gitlab-ci, Jenkinsfile, etc.)
   f. Configuration files (.env.example, config/, settings files)
   g. Test structure and coverage indicators
2. Collect any available business context:
   a. Architecture decision records (ADRs)
   b. API documentation (OpenAPI specs, GraphQL schemas)
   c. Security policies or compliance requirements
3. Estimate total codebase size and primary language(s).
4. Record collected context inventory in .aegis/STATE.md.
</step>

<step name="invoke_principal_engineer" priority="blocking">
1. Load the principal-engineer agent manifest from src/core/agents/principal-engineer.md.
2. Resolve component references:
   a. Persona: src/core/personas/principal-engineer.md
   b. Schemas: finding, disagreement, report-section, confidence, signal
   c. Rules: epistemic-hygiene, disagreement-protocol, agent-boundaries
   d. Domains: none (meta-reasoner — no domain ownership)
   e. Tools: none (meta-reasoner — no tool signals)
3. Assemble session context:
   a. Persona specification (full)
   b. All applicable rules
   c. Repository context gathered in previous step
   d. .aegis/STATE.md for audit awareness
4. Invoke principal-engineer session with Phase 0 instructions:
   a. Establish audit scope: what is being audited and to what depth
   b. Define explicit non-goals: what is NOT being audited
   c. Build threat model: primary threat categories for this codebase type
   d. Assess risk profile: business criticality, data sensitivity, exposure surface
   e. Identify technology-specific audit priorities
   f. Flag any areas requiring special attention or domain expertise
5. Session produces structured output conforming to finding schema where applicable.
</step>

<step name="validate_phase_0_output" priority="blocking">
1. Verify the Principal Engineer session produced:
   a. Audit scope document — defines boundaries, depth, and focus areas
   b. Threat model — categorized threats relevant to this codebase
   c. Risk profile — business criticality assessment
   d. Explicit non-goals — what the audit will NOT cover
2. Validate any findings produced conform to src/schemas/finding.md.
3. Validate confidence vectors conform to src/schemas/confidence.md.
4. If output is incomplete:
   a. Identify which required sections are missing
   b. If session is still available: return to agent with specific gaps
   c. If session has ended: flag as partial in .aegis/STATE.md
</step>

<step name="persist_phase_0_artifacts" priority="blocking">
1. Write audit scope to .aegis/scope.md.
2. Write threat model to .aegis/threat-model.md.
3. Write any findings to .aegis/findings/principal-engineer.md.
4. Invoke session-handoff workflow (src/core/workflows/session-handoff.md):
   a. Capture session output
   b. Validate against schemas
   c. Persist to .aegis/ directory
   d. Update .aegis/STATE.md
5. Verify all writes completed successfully.
</step>

<step name="update_state_phase_complete" priority="blocking">
1. Update .aegis/STATE.md:
   a. current_phase: 0
   b. phase_status: complete
   c. agents_completed: [principal-engineer]
   d. agents_remaining: []
   e. phase_0_complete: true
   f. phase_0_artifacts: [scope.md, threat-model.md]
   g. next_phase: 1
   h. timestamp: completion time
2. Record Phase 0 metrics:
   a. Duration
   b. Artifacts produced
   c. Key scope decisions
</step>

</process>

<output>
Artifacts created:
- .aegis/STATE.md — Initialized and updated with Phase 0 completion
- .aegis/MANIFEST.md — Version-locked component manifest for this audit
- .aegis/scope.md — Audit scope document (boundaries, depth, focus areas, non-goals)
- .aegis/threat-model.md — Categorized threat model for the target codebase
- .aegis/findings/principal-engineer.md — Any Phase 0 findings (if produced)

All output files conform to their respective schemas.
</output>

<error_handling>
- **Target repository not accessible:** Halt immediately. Report path and permission details. Cannot proceed without repository access.
- **Principal Engineer session failure:** Save any partial output to .aegis/STATE.md with status "interrupted". Present error to user. Offer retry or manual scope definition.
- **Incomplete scope definition:** If audit scope is too vague to guide Phase 1 tool execution, flag to user. Phase 1 requires concrete scan targets — an under-specified scope produces unfocused signal gathering.
- **.aegis/ directory already exists:** Check if a prior audit is in progress. Present options: resume existing audit, archive and start fresh, or abort. Do not silently overwrite.
- **Business context unavailable:** Proceed with reduced context. Note in .aegis/STATE.md that threat model is based on code-only analysis without business context. Flag as a coverage limitation in the final report.
</error_handling>
