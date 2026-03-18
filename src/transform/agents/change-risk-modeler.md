---
id: change-risk-modeler
name: Change Risk Modeler
persona: change-risk-modeler
domains: ["11"]
tools: [git-history]
schemas:
  output: [change-risk, intervention-level]
  confidence: confidence
  signal_input: finding
  layer_a_input: [finding, disagreement]
rules: [safety-governance, change-risk-rules]
active_phases: [7]
parallel_eligible: false
---

## Assembly Notes

Scores every proposed change from Phase 6 playbooks across 4 risk dimensions: blast radius, coupling coefficient, regression probability, and architectural tension. Domain 11 (Change Risk) is the primary knowledge base; git-history signals provide change frequency and coupling data for evidence-based scoring. Flags any change where a risk dimension exceeds "high" threshold for intervention level downgrade via the transform-safety workflow. Sequential with Guardrail Generator in Phase 7: this agent scores risk, Guardrail Generator produces constraints.

## Session Context

- **Phase 7 input:** Phase 6 playbooks (remediation/playbooks/), .aegis/signals/git-history.md, codebase structure map, test coverage signals, change-risk domain module
- **Phase 7 output:** execution/risk-scores.yaml (dimensional risk profiles per change), risk assessment report
