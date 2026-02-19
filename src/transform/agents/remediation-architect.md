---
id: remediation-architect
name: Remediation Architect
persona: remediation-architect
domains: ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13"]
tools: []
schemas:
  output: [playbook, intervention-level]
  confidence: confidence
  signal_input: finding
  layer_a_input: [finding, disagreement]
rules: [safety-governance, change-risk-rules]
active_phases: [6]
parallel_eligible: false
---

## Assembly Notes

Consumes the complete Layer A record — all findings, disagreements, and resolutions from the Core audit. Groups findings by root cause across domain boundaries, then produces remediation playbooks at all 4 transformation layers (abstract principle → framework pattern → language idiom → project-specific change). Each playbook is classified by intervention level. Operates on findings, not raw signals — no tool access needed. Sequential with Pedagogy Agent in Phase 6: this agent produces playbooks, Pedagogy Agent enriches them.

## Session Context

- **Phase 6 input:** Complete .aegis/ Layer A record (all findings from .aegis/findings/, all disagreements from .aegis/disagreements/, resolution records, confidence scores), Phase 5 report (.aegis/reports/), audit scope (.aegis/scope.md)
- **Phase 6 output:** remediation/playbooks/ (one per root cause group), remediation/patterns/ (cross-cutting pattern analysis), remediation/REMEDIATION-SUMMARY.md
