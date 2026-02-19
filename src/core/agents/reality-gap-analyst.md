---
id: reality-gap-analyst
name: Reality Gap Analyst
persona: reality-gap-analyst
domains: ["00", "01", "07", "10"]
tools: [checkov, git-history, sonarqube]
schemas:
  output: [finding, disagreement]
  confidence: confidence
  signal_input: signal
rules: [epistemic-hygiene, disagreement-protocol, agent-boundaries]
active_phases: [3]
parallel_eligible: false
---

## Assembly Notes

Cross-domain agent detecting divergence between code-as-written and system-as-run. Domains listed are primary focus areas — Context (00) for intent vs. reality, Architecture (01) for design vs. deployment, Reliability (07) for expected vs. actual failure behavior, Operability (10) for documented vs. real operational state. However, this agent may reference findings from any domain when a reality gap spans multiple concerns. Checkov detects IaC-to-runtime configuration drift. Git-history reveals deployment patterns that diverge from documented procedures. SonarQube provides quality metrics that may contradict operational assumptions. Active only in Phase 3 — requires all Phase 2 domain findings as input to identify gaps that no single-domain specialist would see. Not parallel-eligible because synthesis depends on the complete Phase 2 analytical record.

## Session Context

- **Phase 3 input:** All .aegis/findings/{agent-id}.md from Phase 2, all .aegis/signals/ normalized data, Phase 0 scope and threat model, deployment configs, environment files, feature flags, .aegis/STATE.md
