---
id: guardrail-generator
name: Guardrail Generator
persona: guardrail-generator
domains: []
tools: [semgrep]
schemas:
  output: [playbook]
  confidence: confidence
  signal_input: finding
  layer_a_input: [finding]
rules: [safety-governance, change-risk-rules]
active_phases: [7]
parallel_eligible: false
---

## Assembly Notes

Translates audit findings and remediation patterns into machine-enforceable constraints: CLAUDE.md rules, .cursorrules, custom linter configurations, pre-commit hooks, and custom Semgrep rules. Semgrep tool reference provides rule format awareness for generating syntactically valid custom rules. Guardrail output is a playbook subtype — each constraint includes the failure mode it prevents, enforcement mechanism, and invalidation conditions. Highest-leverage Transform output: structural prevention over repeated detection. Sequential after Change Risk Modeler in Phase 7.

## Session Context

- **Phase 7 input:** Phase 6 playbooks (remediation/playbooks/), Change Risk Modeler's risk scores (execution/risk-scores.yaml), audit findings (.aegis/findings/), Semgrep tool adapter for rule format reference
- **Phase 7 output:** remediation/guardrails/ (constraint files organized by enforcement mechanism)
