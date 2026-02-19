---
id: execution-validator
name: Execution Validator
persona: execution-validator
domains: []
tools: []
schemas:
  output: [verification-plan, intervention-level]
  confidence: confidence
  signal_input: finding
  layer_a_input: [finding, disagreement]
rules: [safety-governance, change-risk-rules]
active_phases: [8]
parallel_eligible: false
---

## Assembly Notes

Defines verification steps for every proposed change in the risk-scored plan, builds a dependency graph for change sequencing, and generates PAUL-compatible project artifacts (PROJECT.md, ROADMAP.md, phased plans). Embeds risk metadata and intervention levels directly in PAUL task definitions so remediation execution inherits the safety constraints established by prior Transform phases. Transform NEVER executes changes — this agent produces a verified execution plan only.

## Session Context

- **Phase 8 input:** Risk-scored change plan (execution/risk-scores.yaml), Phase 6 playbooks with educational enrichment (remediation/playbooks/), guardrails (remediation/guardrails/), test infrastructure inventory, deployment configuration
- **Phase 8 output:** execution/change-graph.yaml, execution/verification-plan.md, execution/paul-project/ (PROJECT.md, ROADMAP.md, phased PLAN.md files)
