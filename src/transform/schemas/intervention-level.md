---
id: intervention-level
name: Intervention Level
version: 1.0.0
used_by:
  - remediation-architect
  - change-risk-modeler
  - execution-validator
---

## Purpose

An Intervention Level defines a governance tier that controls what Transform is permitted to do for a given remediation. The four tiers — Suggesting, Planning, Authorizing, Executing — form an escalation ladder where each level requires stronger evidence, higher confidence, and lower risk than the one below it.

Intervention levels exist because remediation carries liability. A suggestion ("consider externalizing secrets") carries minimal risk — if it is wrong, the developer ignores it. An execution plan handed to PAUL for implementation carries substantial risk — if it is wrong, the codebase is damaged. The governance tiers ensure that the level of Transform's involvement is proportional to the strength of evidence supporting the remediation.

The key design principle is conservative escalation: Transform defaults to the lowest level that serves the user, and escalation requires explicit evidence justification. A finding with medium confidence cannot produce an Authorizing-level playbook regardless of severity — confidence gates intervention, not severity. This prevents the most dangerous failure mode: high-confidence-sounding remediation built on weak evidence.

Each level also carries a liability posture. At Suggesting and Planning levels, AEGIS is an Advisor — it provides information and recommendations. At Authorizing and Executing levels, AEGIS is an Architectural Actor — it produces artifacts intended to be applied to the codebase, which requires explicit disclaimers and higher evidence thresholds.

This schema is the single source of truth for governance tiers. Safety rules (@rules in `src/transform/rules/`) enforce constraints against these tier definitions. Playbooks (@schema:playbook) declare which tier they operate at. The verification pipeline (@schema:verification-plan) is required for Authorizing and Executing tiers.

## Template

```markdown
### Level: {level}

**Liability Posture:** {liability_posture}
**Requires Human Approval:** {requires_human_approval}
**Requires Disclaimer:** {requires_disclaimer}

---

#### Confidence Requirements

**Minimum Finding Confidence:** {minimum_finding_confidence}
**Minimum Evidence Sources:** {minimum_evidence_sources}

#### Risk Constraints

**Allowed When Risk High:** {allowed_when_risk_high}

#### Description

{level_description}

#### Permitted Outputs

{permitted_outputs}
```

## Field Reference

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `level` | enum | yes | The intervention tier. Each tier represents an escalation in Transform's involvement and the evidence required to justify it. | `suggesting`, `planning`, `authorizing`, `executing` |
| `liability_posture` | enum | yes | The legal/professional posture AEGIS assumes at this level. Determines disclaimer requirements and confidence thresholds. | `advisor` (suggesting, planning), `architectural_actor` (authorizing, executing) |
| `requires_human_approval` | boolean | yes | Whether a human must explicitly approve before output at this level can be acted upon. | `false` (suggesting, planning), `true` (authorizing, executing) |
| `requires_disclaimer` | boolean | yes | Whether output at this level must include an explicit confidence statement and liability disclaimer. | `false` (suggesting), `false` (planning), `true` (authorizing), `true` (executing) |
| `minimum_finding_confidence` | enum | yes | Minimum confidence (@schema:confidence overall derivation) a finding must have for a playbook at this level. Findings below this threshold are rejected regardless of severity. | `low` (suggesting), `medium` (planning), `high` (authorizing), `high` (executing) |
| `minimum_evidence_sources` | integer | yes | Minimum number of independent evidence sources required. Evidence sources are distinct tool signals, code analysis observations, or documentation references — not repetitions of the same source. | 1 (suggesting), 2 (planning), 3 (authorizing), 3 (executing) |
| `allowed_when_risk_high` | boolean | yes | Whether this intervention level is permitted when any change-risk dimension (@schema:change-risk) exceeds a score of 4. High-risk changes are automatically constrained to lower tiers. | `true` (suggesting), `true` (planning), `false` (authorizing), `false` (executing) |
| `level_description` | string | yes | Human-readable description of what this level means, what Transform produces at this level, and what the user should expect. | Free-form, 2-4 sentences. |
| `permitted_outputs` | string | yes | What Transform is allowed to produce at this level. Each higher level includes all outputs from lower levels plus additional artifacts. | Free-form, bulleted list. |

## Validation Rules

1. `level` must be one of the four enumerated values. No intermediate levels, no custom levels, no "between planning and authorizing."
2. `liability_posture` must match the level: suggesting and planning are always `advisor`; authorizing and executing are always `architectural_actor`. There is no configuration that makes an Authorizing-level playbook carry Advisor liability — the liability follows the level.
3. `minimum_finding_confidence` must be enforced as a hard gate: a finding with confidence `low` cannot produce a playbook at `planning` level or above. A finding with confidence `medium` cannot produce a playbook at `authorizing` level or above. Violations are rejected at schema validation, not treated as warnings.
4. `minimum_evidence_sources` must count independent sources. The same Semgrep rule cited three times is 1 source, not 3. A Semgrep signal plus a manual code review observation plus a test coverage gap is 3 sources.
5. `allowed_when_risk_high` is a hard constraint: if any dimension in the change-risk assessment scores 4 or 5 and `allowed_when_risk_high` is `false`, the playbook must be downgraded to a level where this constraint is `true`. There is no override mechanism.
6. `requires_disclaimer` at `true` means the playbook must include a confidence statement ("Based on [N] evidence sources with overall confidence [level]") and a liability acknowledgment ("This remediation plan should be reviewed by a qualified engineer before application"). Missing disclaimers at Authorizing/Executing levels are validation errors.
7. Intervention levels are monotonically escalating: a playbook can be downgraded (Authorizing → Planning) at any time without re-assessment, but upgrading (Planning → Authorizing) requires meeting the higher level's thresholds and producing the additional required artifacts (verification plan, change-risk assessment).

## Examples

### Tier Definitions

#### Suggesting

```markdown
### Level: suggesting

**Liability Posture:** advisor
**Requires Human Approval:** false
**Requires Disclaimer:** false

---

#### Confidence Requirements

**Minimum Finding Confidence:** low
**Minimum Evidence Sources:** 1

#### Risk Constraints

**Allowed When Risk High:** true

#### Description

The lowest intervention level. AEGIS identifies a potential improvement and describes it at a high level. No structured plan, no code examples, no risk assessment. The output is informational — "you might want to look at this." Suitable for low-confidence findings, exploratory observations, and cases where the evidence is suggestive but not conclusive.

#### Permitted Outputs

- Finding reference with brief remediation description
- Abstract pattern recommendation (Layer 1 only)
- No code examples, no risk metadata, no verification steps
```

#### Planning

```markdown
### Level: planning

**Liability Posture:** advisor
**Requires Human Approval:** false
**Requires Disclaimer:** false

---

#### Confidence Requirements

**Minimum Finding Confidence:** medium
**Minimum Evidence Sources:** 2

#### Risk Constraints

**Allowed When Risk High:** true

#### Description

Transform produces a structured remediation plan with all four transformation layers, before/after code examples, and risk metadata. The output is a complete playbook that a developer could follow to implement the fix. However, AEGIS is still in Advisor posture — the plan is a recommendation, not an instruction. Planning-level playbooks do not require a formal verification plan or change-risk assessment, though they include inline risk metadata.

#### Permitted Outputs

- Full playbook with all four transformation layers
- Before/after code examples
- Inline risk metadata (4 dimensions with scores and evidence)
- Verification steps (how to confirm the fix works)
- Educational context (optional)
```

#### Authorizing

```markdown
### Level: authorizing

**Liability Posture:** architectural_actor
**Requires Human Approval:** true
**Requires Disclaimer:** true

---

#### Confidence Requirements

**Minimum Finding Confidence:** high
**Minimum Evidence Sources:** 3

#### Risk Constraints

**Allowed When Risk High:** false

#### Description

Transform produces a fully specified change package: playbook, formal change-risk assessment, and verification plan with pre/post/regression checks and rollback procedure. At this level, AEGIS is an Architectural Actor — the output is intended to be applied to the codebase, contingent on human approval. The higher evidence requirements (3+ independent sources, high confidence) and risk constraints (no high-risk changes) ensure that only well-evidenced, low-to-medium-risk remediations reach this level. Human review is mandatory.

#### Permitted Outputs

- Full playbook (all Planning outputs)
- Formal change-risk assessment (@schema:change-risk)
- Verification plan with pre/post/regression checks (@schema:verification-plan)
- Rollback procedure
- Confidence statement and liability disclaimer (required)
```

#### Executing

```markdown
### Level: executing

**Liability Posture:** architectural_actor
**Requires Human Approval:** true
**Requires Disclaimer:** true

---

#### Confidence Requirements

**Minimum Finding Confidence:** high
**Minimum Evidence Sources:** 3

#### Risk Constraints

**Allowed When Risk High:** false

#### Description

The highest intervention level. Transform produces all Authorizing-level artifacts plus a PAUL-consumable execution plan. The output is designed to be handed to PAUL for human-supervised change orchestration — PAUL breaks the change into steps, executes them with human checkpoints, and runs the verification plan. AEGIS Transform never executes changes directly; PAUL mediates all codebase modifications. The same evidence and risk thresholds as Authorizing apply — Executing is Authorizing plus the PAUL integration layer.

#### Permitted Outputs

- All Authorizing outputs
- PAUL-consumable execution plan (phased steps with checkpoints)
- Execution ordering and dependency specification
- Integration metadata for PAUL's planning workflow
```
