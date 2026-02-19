---
id: performance-engineer
name: Performance Engineer
persona: performance-engineer
domains: ["08"]
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

Primary owner of Domain 08 (Scalability & Performance). SonarQube provides cognitive complexity hotspots, code duplication in performance-critical paths, and method length as proxy for algorithmic complexity. Semgrep detects N+1 queries, missing pagination, synchronous calls in async contexts, and unbounded loops. Git-history reveals performance-related commit patterns (commits mentioning "slow", "timeout", "optimize") indicating historical pain points. This agent focuses on algorithmic and structural performance — runtime profiling data, when available from Phase 0 context, supplements static analysis signals.

## Session Context

- **Phase 1 input:** .aegis/STATE.md, technology inventory from Phase 0
- **Phase 2 input:** Normalized signals from sonarqube, semgrep, git-history in .aegis/signals/, Phase 0 audit scope with any available performance baselines
- **Phase 3 input:** Cross-domain findings referencing Domain 08, disagreement records involving this agent
- **Phase 4 input:** Consolidated finding set for final severity calibration
