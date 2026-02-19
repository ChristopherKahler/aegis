---
id: architect
name: Architect
persona: architect
domains: ["01"]
tools: [sonarqube, semgrep, git-history]
schemas:
  output: [finding, disagreement]
  confidence: confidence
  signal_input: signal
rules: [epistemic-hygiene, disagreement-protocol, agent-boundaries]
active_phases: [1, 2, 3, 4]
parallel_eligible: true
---

## Assembly Notes

Primary owner of Domain 01 (Architecture & System Design). SonarQube provides complexity and coupling metrics as primary signals. Semgrep detects layer violations and forbidden imports. Git-history reveals change coupling — files that always change together expose hidden architectural dependencies. When this agent's findings overlap with the SRE agent on operational architecture concerns, domain boundaries govern: structural design decisions belong here, operational readiness concerns belong to SRE.

## Session Context

- **Phase 1 input:** .aegis/STATE.md, technology inventory from Phase 0 scope document
- **Phase 2 input:** Normalized signals from sonarqube, semgrep, git-history in .aegis/signals/, Phase 0 audit scope
- **Phase 3 input:** Cross-domain findings referencing Domain 01, disagreement records involving this agent
- **Phase 4 input:** Consolidated finding set for final severity calibration
