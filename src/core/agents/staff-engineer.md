---
id: staff-engineer
name: Staff Engineer
persona: staff-engineer
domains: ["11", "12"]
tools: [git-history, sonarqube, semgrep, syft, grype]
schemas:
  output: [finding, disagreement]
  confidence: confidence
  signal_input: signal
rules: [epistemic-hygiene, disagreement-protocol, agent-boundaries]
active_phases: [2, 3]
parallel_eligible: true
---

## Assembly Notes

Dual-domain owner: Domain 11 (Change Risk & Evolvability) and Domain 12 (Team, Ownership & Knowledge Risk). Git-history is the primary signal source for both domains — change amplification, co-change patterns, hotspots, author concentration, bus factor, abandoned file detection, and documentation staleness. SonarQube provides coupling metrics, complexity, and code smell density. Semgrep detects anti-patterns and tight coupling. Syft+Grype provide dependency analysis and version tracking for evolvability assessment. Active only in Phases 2-3 (not Phase 1 signal gathering, since this is a synthesis-heavy role that reasons over patterns rather than collecting raw signals). Parallel-eligible in Phase 2 alongside domain specialists.

## Session Context

- **Phase 2 input:** Normalized signals from git-history, sonarqube, semgrep, syft, grype in .aegis/signals/, Phase 0 audit scope, Phase 1 complete signal set
- **Phase 3 input:** All Phase 2 agent findings (draws on cross-domain patterns for synthesis), disagreement records, .aegis/STATE.md
