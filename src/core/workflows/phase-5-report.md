<purpose>
Executes the final synthesis and report generation by invoking the Principal Engineer to consume the complete analytical record — all findings, all disagreements, and the Devil's Advocate critique — producing the definitive AEGIS audit report with mandatory response to every disagreement.
</purpose>

<phase_context>
Phase: 5 — Synthesis & Report Generation
Prior phase output: Complete .aegis/ analytical record — Phase 2 domain findings, Phase 3 synthesis findings, Phase 4 Devil's Advocate critique, all disagreement records with principal_response
Agents invoked: principal-engineer (Phase 5 role — synthesis and report generation, not scope establishment)
Output: Final AEGIS report sections in .aegis/report/, completed .aegis/STATE.md marking audit as complete
</phase_context>

<required_input>
@.aegis/STATE.md
@.aegis/MANIFEST.md
@.aegis/scope.md
@.aegis/threat-model.md
@.aegis/findings/*.md (ALL finding files from ALL phases)
@.aegis/disagreements/*.md (ALL disagreement records — must all have principal_response)
@src/core/agents/principal-engineer.md
@src/core/personas/principal-engineer.md
@src/schemas/finding.md
@src/schemas/disagreement.md
@src/schemas/confidence.md
@src/schemas/report-section.md
@src/rules/epistemic-hygiene.md
@src/rules/disagreement-protocol.md
@src/rules/agent-boundaries.md
@src/core/workflows/session-handoff.md
</required_input>

<process>

<step name="validate_prerequisites" priority="first">
1. Verify .aegis/STATE.md shows Phase 4 complete:
   a. Check phase_4_complete: true
   b. Check .aegis/findings/devils-advocate.md exists
2. CRITICAL CHECK — Verify ALL disagreements have principal_response:
   a. Read every file in .aegis/disagreements/
   b. For each disagreement record:
      - Verify principal_response field is present AND non-empty
      - Verify status is not "open" (must be: mitigated, accepted_risk, deferred, or out_of_scope)
   c. If ANY disagreement lacks principal_response:
      - HALT. Do not proceed to Phase 5.
      - Display: "Cannot synthesize report: N disagreements lack Principal Engineer response."
      - List the unresolved disagreement IDs
      - Route to disagreement-resolution workflow first
3. If all prerequisites met:
   a. Update .aegis/STATE.md: current_phase: 5, phase_status: in_progress
</step>

<step name="assemble_complete_record" priority="blocking">
1. Load the complete analytical record:
   a. Phase 0: .aegis/scope.md, .aegis/threat-model.md
   b. Phase 1: .aegis/signals/SUMMARY.md (signal summary only — full signals not needed for synthesis)
   c. Phase 2: .aegis/findings/ from all 8 domain agents
   d. Phase 3: .aegis/findings/staff-engineer.md, .aegis/findings/reality-gap-analyst.md
   e. Phase 4: .aegis/findings/devils-advocate.md
   f. All disagreements: .aegis/disagreements/*.md (with resolutions)
   g. .aegis/STATE.md with full cumulative metrics
2. Organize by synthesis priority:
   a. Critical/high severity findings first
   b. Findings with associated disagreements grouped together
   c. Cross-domain patterns (findings referenced by multiple agents)
   d. Devil's Advocate critiques paired with the findings they challenge
3. Estimate context size — Phase 5 has the SECOND largest context need (after Phase 4).
4. If context exceeds budget:
   a. Include ALL high/critical findings in full
   b. Summarize medium/low findings by domain
   c. Include ALL disagreements in full (resolutions are critical for the report)
   d. Include ALL Devil's Advocate critiques in full
   e. Log trimming decisions
</step>

<step name="invoke_principal_engineer" priority="blocking">
1. Load principal-engineer agent manifest from src/core/agents/principal-engineer.md.
2. Resolve component references:
   a. Persona: src/core/personas/principal-engineer.md
   b. Domains: none (meta-reasoner — synthesizes across all domains)
   c. Tools: none (operates on analytical record)
   d. Schemas: finding, disagreement, report-section, confidence, signal
   e. Rules: epistemic-hygiene, disagreement-protocol, agent-boundaries
3. Invoke principal-engineer session with Phase 5 instructions:
   a. Synthesize the complete analytical record into the final AEGIS report
   b. For every disagreement: verify the resolution is sound and the rationale holds under the full record
   c. Identify cross-domain patterns that individual agents couldn't see
   d. Calibrate severity across domains — ensure consistent severity scale
   e. Produce a narrative that a technical leader can act on
4. Session produces the 7 report sections:
   a. Executive Risk Summary — top-line risk assessment for leadership
   b. Architecture Narrative — structural health story
   c. Findings by Domain — severity-ranked findings per domain (all 14 domains)
   d. Cross-Validation Notes — disagreements and their resolutions with rationale
   e. Remediation Roadmap — prioritized action plan
   f. Long-Term Structural Risks — risks that compound over time
   g. "What Would Break First at 10x Scale" — growth stress analysis
5. Each report section must conform to src/schemas/report-section.md.
</step>

<step name="validate_report_output" priority="blocking">
1. Verify all 7 report sections were produced:
   a. Check each section exists and is non-empty
   b. Validate each against src/schemas/report-section.md
2. Verify disagreement coverage:
   a. Every disagreement ID that exists in .aegis/disagreements/ must appear in the Cross-Validation Notes section
   b. No disagreement may be silently omitted — this is the core anti-pattern "hiding disagreements in footnotes"
3. Verify severity calibration:
   a. No finding severity was silently changed without explanation
   b. If the Principal Engineer adjusted severity, the rationale is documented
4. Verify cross-domain coherence:
   a. The Architecture Narrative is consistent with the Findings by Domain section
   b. The Remediation Roadmap addresses the highest-severity findings
   c. The Executive Summary accurately reflects the detailed findings
5. If validation fails:
   a. If session is still available: return with specific gaps
   b. If session ended: flag incomplete sections in STATE.md
</step>

<step name="persist_report" priority="blocking">
1. Write report sections to .aegis/report/:
   a. .aegis/report/01-executive-summary.md
   b. .aegis/report/02-architecture-narrative.md
   c. .aegis/report/03-findings-by-domain.md
   d. .aegis/report/04-cross-validation-notes.md
   e. .aegis/report/05-remediation-roadmap.md
   f. .aegis/report/06-long-term-risks.md
   g. .aegis/report/07-scale-analysis.md
2. Generate combined report:
   a. Assemble all sections into .aegis/report/AEGIS-REPORT.md
   b. Include table of contents
   c. Include audit metadata (scope, timeline, agent roster, tool versions)
3. Invoke session-handoff workflow for final time:
   a. Capture Principal Engineer session output
   b. Persist any final findings to .aegis/findings/principal-engineer.md (append to Phase 0 findings)
   c. Update STATE.md
4. Verify all report files written successfully.
</step>

<step name="finalize_audit" priority="blocking">
1. Update .aegis/STATE.md:
   a. current_phase: 5
   b. phase_status: complete
   c. audit_status: complete
   d. phase_5_complete: true
   e. report_sections: 7
   f. total_findings_all_phases: N
   g. total_disagreements: N
   h. disagreements_resolved: N (should equal total)
   i. completion_timestamp: time
2. Record final audit metrics:
   a. Total duration (Phase 0 start to Phase 5 end)
   b. Findings by severity: critical, high, medium, low, info
   c. Domain coverage: which domains produced findings
   d. Agent participation: which agents completed successfully
   e. Disagreement resolution rate: 100% required
3. Mark .aegis/MANIFEST.md as final:
   a. Add report hash for integrity verification
   b. Lock manifest — no further modifications to this audit
4. Present audit completion summary to user:
   a. Report location: .aegis/report/AEGIS-REPORT.md
   b. Key statistics
   c. If Transform pipeline is configured: note readiness for Layer B/C generation
</step>

</process>

<output>
Artifacts created:
- .aegis/report/01-executive-summary.md — Executive Risk Summary
- .aegis/report/02-architecture-narrative.md — Architecture health narrative
- .aegis/report/03-findings-by-domain.md — Severity-ranked findings per domain
- .aegis/report/04-cross-validation-notes.md — Disagreements and resolutions
- .aegis/report/05-remediation-roadmap.md — Prioritized action plan
- .aegis/report/06-long-term-risks.md — Compounding structural risks
- .aegis/report/07-scale-analysis.md — "What breaks at 10x scale" analysis
- .aegis/report/AEGIS-REPORT.md — Combined final report
- .aegis/findings/principal-engineer.md — Updated with Phase 5 findings (appended)
- .aegis/STATE.md — Finalized with audit_status: complete

All report sections conform to src/schemas/report-section.md.
</output>

<error_handling>
- **Phase 4 not complete:** Halt immediately. Display: "Phase 4 (Adversarial Review) must complete before synthesis. Run phase-4-adversarial-review first." Do not proceed.
- **Unresolved disagreements:** CRITICAL BLOCK. Phase 5 MUST NOT proceed if any disagreement lacks principal_response. Route to disagreement-resolution workflow. This is non-negotiable — silence on disagreements destroys audit trust.
- **Principal Engineer session failure:** This is a CRITICAL failure — the audit cannot produce a report without Phase 5. Record failure. Present to user with strong recommendation to retry. Do not produce a partial report automatically.
- **Incomplete report (missing sections):** If fewer than 7 sections produced, flag which sections are missing. If session is available, request completion. If not, mark audit as "partial" in STATE.md and note which sections are absent.
- **Context budget exceeded:** Phase 5 has large context needs. Trimming strategy: (a) keep ALL disagreements in full, (b) keep ALL critical/high findings in full, (c) summarize medium/low by domain, (d) keep Devil's Advocate critiques in full, (e) summarize signal summary. Never trim persona or rules.
- **Report inconsistency detected:** If validation finds the Executive Summary contradicts detailed findings, or the Remediation Roadmap doesn't address highest-severity issues: flag specific inconsistencies. If session available, return for correction. If not, annotate the report with consistency warnings.
</error_handling>
