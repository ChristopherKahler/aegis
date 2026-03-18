---
id: principal-engineer
name: Principal Engineer
persona: principal-engineer
domains: []
tools: []
schemas:
  output: [finding, disagreement, report-section]
  confidence: confidence
  signal_input: signal
rules: [epistemic-hygiene, disagreement-protocol, agent-boundaries]
active_phases: [0, 5]
parallel_eligible: false
---

## Assembly Notes

Meta-reasoner with no domain ownership and no tool signals. In Phase 0, operates on raw repository context to establish audit scope and threat model. In Phase 5, consumes the complete analytical record — all agent findings, disagreement records, and Devil's Advocate critique — to synthesize the final report. Must explicitly respond to every disagreement; silence is not allowed. Produces report-section schema output in addition to standard finding and disagreement schemas.

## Session Context

- **Phase 0 input:** Repository structure, README, deployment configs, business context documents, .aegis/STATE.md
- **Phase 5 input:** All .aegis/findings/{agent-id}.md files, all .aegis/disagreements/*.md records, Devil's Advocate critique, .aegis/STATE.md with full phase metrics
