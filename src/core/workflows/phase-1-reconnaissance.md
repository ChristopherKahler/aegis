<purpose>
Executes automated signal gathering by running all configured analysis tools against the target codebase, normalizing their output to the AEGIS signal schema, and persisting results for consumption by domain audit agents in Phase 2.
</purpose>

<phase_context>
Phase: 1 — Automated Signal Gathering
Prior phase output: Phase 0 audit scope (.aegis/scope.md), threat model (.aegis/threat-model.md), initialized .aegis/STATE.md
Agents invoked: None — this phase is pure tool orchestration, no reasoning agents. Tools execute mechanically per their adapter specifications.
Output: Normalized signal files (.aegis/signals/{tool-id}.md per tool), signal summary with domain-tagged counts
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/scope.md
@src/schemas/signal.md
@src/tools/sonarqube.md
@src/tools/semgrep.md
@src/tools/trivy.md
@src/tools/gitleaks.md
@src/tools/checkov.md
@src/tools/syft.md
@src/tools/grype.md
@src/tools/git-history.md
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md exists and shows Phase 0 complete:
   a. Check phase_0_complete: true
   b. Check .aegis/scope.md exists and is non-empty
   c. Check .aegis/threat-model.md exists
2. If Phase 0 is not complete:
   a. Halt with error: "Phase 0 (Context & Threat Modeling) not complete. Run phase-0-context workflow first."
   b. Do not proceed.
3. Read .aegis/scope.md to extract:
   a. Scan targets (directories, file patterns)
   b. Exclusions (vendored code, generated files, test fixtures)
   c. Technology stack (determines which tools and rule sets apply)
   d. Any scope overrides from audit configuration
4. Update .aegis/STATE.md:
   a. current_phase: 1
   b. phase_status: in_progress
</step>

<step name="configure_tool_execution" priority="blocking">
1. Read .aegis/MANIFEST.md to determine which tools are enabled for this audit.
2. For each enabled tool, load its adapter specification from src/tools/{tool-id}.md.
3. Configure each tool based on scope:
   a. SonarQube: project key, quality profile, language plugins
   b. Semgrep: rule sets matching detected languages/frameworks
   c. Trivy: scan mode (filesystem vs image), severity thresholds
   d. Gitleaks: custom config if secrets patterns specified in scope
   e. Checkov: framework detection (terraform, cloudformation, k8s, dockerfile)
   f. Syft: output format (SPDX/CycloneDX), scan target
   g. Grype: vulnerability database update, severity thresholds
   h. git-history: date range, file filters, author grouping
4. Record tool configuration in .aegis/STATE.md for reproducibility.
5. Determine execution order:
   a. Syft MUST run before Grype (Grype consumes Syft SBOM output)
   b. All other tools are independent and can run in parallel
</step>

<step name="execute_tools" priority="blocking">
1. Execute all independent tools (can run in parallel):
   a. SonarQube — static analysis via MCP server or CLI
   b. Semgrep — pattern-based analysis with configured rule sets
   c. Trivy — vulnerability and misconfiguration scanning
   d. Gitleaks — secrets detection across repository history
   e. Checkov — infrastructure-as-code policy scanning
   f. git-history — change frequency, author concentration, file age analysis
2. Execute SBOM pipeline (sequential):
   a. Syft — generate software bill of materials
   b. Grype — scan Syft output for known vulnerabilities
3. For each tool execution:
   a. Record start time
   b. Capture raw output
   c. Record completion time and exit status
   d. If tool fails: log error, mark tool as "failed" in STATE.md, continue with remaining tools
4. Update .aegis/STATE.md with tool execution status after each completes.
</step>

<step name="normalize_signals" priority="blocking">
1. For each tool that produced output:
   a. Load the tool's adapter specification from src/tools/{tool-id}.md
   b. Apply the normalization mapping defined in the adapter:
      - Map tool-native severity to AEGIS severity scale
      - Map tool-native confidence to AEGIS confidence dimensions
      - Calculate blast radius from tool context
      - Tag with domain relevance per the adapter's domain_mapping
   c. Produce normalized signal records conforming to src/schemas/signal.md
2. For each normalized signal:
   a. Assign signal ID: S-{TOOL}-{NNN}
   b. Tag with source_tool, timestamp, domain_ids
   c. Preserve raw tool reference for traceability
3. Validate all normalized signals against src/schemas/signal.md:
   a. Required fields present
   b. Severity within valid range
   c. Domain tags reference valid domain IDs (00-13)
4. Record normalization results:
   a. Total signals per tool
   b. Signals per domain
   c. Any signals that failed normalization (quarantine with reason)
</step>

<step name="persist_signals" priority="blocking">
1. Write normalized signals to .aegis/signals/{tool-id}.md:
   a. One file per tool containing all normalized signals from that tool
   b. Files: sonarqube.md, semgrep.md, trivy.md, gitleaks.md, checkov.md, syft.md, grype.md, git-history.md
   c. Only create files for tools that produced output
2. Generate signal summary:
   a. Total signal count across all tools
   b. Signal count per tool
   c. Signal count per domain (aggregated across tools)
   d. Severity distribution (critical, high, medium, low, info)
   e. Tools that failed or produced no output
3. Write signal summary to .aegis/signals/SUMMARY.md.
4. Verify all writes completed:
   a. Confirm each file exists and is non-empty
   b. Confirm signal counts match expected totals
</step>

<step name="update_state_phase_complete" priority="blocking">
1. Update .aegis/STATE.md:
   a. current_phase: 1
   b. phase_status: complete
   c. phase_1_complete: true
   d. tools_executed: [list of tools that ran successfully]
   e. tools_failed: [list of tools that failed, with reasons]
   f. total_signals: N
   g. signals_per_domain: {domain_id: count}
   h. next_phase: 2
   i. timestamp: completion time
2. Record Phase 1 metrics:
   a. Duration
   b. Tool execution times
   c. Signal volumes
   d. Coverage gaps (domains with zero signals)
</step>

</process>

<output>
Artifacts created:
- .aegis/signals/sonarqube.md — Normalized SonarQube signals
- .aegis/signals/semgrep.md — Normalized Semgrep signals
- .aegis/signals/trivy.md — Normalized Trivy signals
- .aegis/signals/gitleaks.md — Normalized Gitleaks signals
- .aegis/signals/checkov.md — Normalized Checkov signals
- .aegis/signals/syft.md — Normalized Syft SBOM signals
- .aegis/signals/grype.md — Normalized Grype vulnerability signals
- .aegis/signals/git-history.md — Normalized git history signals
- .aegis/signals/SUMMARY.md — Aggregated signal summary with domain counts
- .aegis/STATE.md — Updated with Phase 1 completion and signal metrics

All signal files conform to src/schemas/signal.md.
</output>

<error_handling>
- **Phase 0 not complete:** Halt immediately. Display: "Phase 0 (Context & Threat Modeling) must complete before signal gathering. Run phase-0-context first." Do not proceed.
- **Tool not installed:** Log missing tool in .aegis/STATE.md. Skip tool and continue with remaining tools. Record coverage gap — domains served only by the missing tool will have reduced signal diversity.
- **Tool execution failure (non-zero exit):** Capture error output. Record failure reason in STATE.md. Continue with remaining tools. Do not retry automatically — present failure to user for decision (retry, skip, or abort phase).
- **Tool produces no output:** Record as "no findings" (distinct from failure). Some tools legitimately find nothing. Do not treat empty output as an error.
- **Normalization failure (signal doesn't conform to schema):** Quarantine the raw signal in .aegis/signals/quarantine/{tool-id}-{timestamp}.md. Record normalization error. Continue with remaining signals. Report quarantined count in summary.
- **All tools fail:** Halt phase. Record failure in STATE.md. Phase 2 cannot proceed without signals. Present to user for diagnosis.
- **Syft/Grype pipeline break:** If Syft fails, Grype cannot run. Record both as failed. Other tools continue independently.
- **Scope too broad (excessive signal volume):** If total signals exceed a reasonable threshold, log warning. Phase 2 agents may need signal filtering by relevance. Record in STATE.md for downstream awareness.
</error_handling>
