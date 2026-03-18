---
id: change-risk-rules
name: Change Risk Rules
scope: transform_agents
priority: critical
---

## Purpose

Without change-risk rules, Transform agents produce remediation plans that ignore the collateral damage of fixes. A technically correct fix that touches 30 files, introduces 3 new dependencies, and modifies untested code paths is not a good fix — it is a new source of risk that may exceed the original finding's impact. These rules enforce that every remediation is assessed for its own risk, not just for its correctness.

Change-risk rules prevent two specific failure modes. First, optimistic risk assessment — agents that claim "low blast radius" without actually tracing the dependency chain, or "low regression risk" without checking test coverage. Second, risk-intervention disconnect — agents that produce high-risk change plans at high intervention levels, creating authoritative-sounding remediation that is actually dangerous to apply.

Every risk claim must be backed by evidence. "This change is isolated" is not a risk assessment — it is an assertion. "This change modifies `config/database.py` which is imported by `config/__init__.py` and consumed by 3 modules (`app.py`, `workers/sync.py`, `scripts/migrate.py`)" is a risk assessment. The difference is that the second statement is falsifiable — someone can verify the import chain.

Every rule in this file has `priority: critical`. Violations invalidate the output.

## Rules

### 1. Mandatory Blast Radius Assessment

**Statement:** Every remediation playbook must include a blast radius assessment with a score (1-5), evidence citing specific files and dependency chains, and a complete list of affected files. No playbook may claim "this change is isolated" or "low blast radius" without enumerating what the change touches and tracing at least one level of downstream consumers.

**Rationale:** Blast radius is the most commonly under-estimated risk dimension because it requires tracing dependencies, which is tedious. Agents naturally default to "this is a small change" without verifying the claim. A one-line change to a utility function imported by 40 modules has a blast radius of 40, not 1. Without mandatory enumeration, blast radius assessments are wishes, not measurements.

**Enforcement:** Playbook schema validation (@schema:playbook) rejects any playbook where `blast_radius_evidence` is empty or contains no file path references. The `affected_files` list in the corresponding change-risk assessment (@schema:change-risk) must contain at least one entry. If the blast radius score is 1 or 2, the evidence must explain why downstream impact is limited (e.g., "no downstream consumers" or "interface unchanged, only internal implementation modified"). Low scores without explanation are flagged for review.

### 2. Coupling Analysis Before Structural Changes

**Statement:** Any remediation that adds, removes, or modifies dependencies between modules, packages, services, or external systems must include a coupling analysis. New dependencies must be justified — why this dependency is necessary, what alternatives were considered, and what happens if the dependency fails or is removed. Changes that tighten coupling (increase the dependency count or create bidirectional dependencies) must acknowledge this in the risk metadata.

**Rationale:** The most dangerous remediation patterns are those that "fix" a finding by introducing a new dependency. Externalizing configuration into a secrets manager fixes hardcoded credentials but introduces a runtime dependency on an external service. This is often the right tradeoff — but it must be an acknowledged, assessed tradeoff, not an invisible side effect. Without coupling analysis, Transform optimizes for finding resolution at the expense of system simplicity.

**Enforcement:** Change-risk assessment validation (@schema:change-risk) checks that `new_dependencies` is populated (even if empty, indicating no new dependencies). If `new_dependencies` contains any entries and `coupling_risk_score` is below 3, the evidence must explain why the new dependency does not significantly increase coupling. The coupling risk evidence must reference the specific interfaces or import relationships affected.

### 3. Regression Probability with Evidence

**Statement:** Every change-risk assessment must state the regression probability with evidence grounded in test coverage data. If test coverage data is available, cite the coverage percentage for the affected files. If test coverage data is unavailable, state this explicitly — "no test coverage data available" is valid evidence; "low regression risk" without data is not. Changes to files with zero test coverage must include an explicit warning: "UNTESTED CODE PATH — no existing tests cover this modification."

**Rationale:** Regression probability without test coverage data is speculation. An agent that claims "low regression risk" for a change to an untested module is not being conservative — it is being dishonest about its knowledge. The presence or absence of tests is the single strongest predictor of whether a change will introduce regressions. Requiring evidence forces agents to check rather than assume.

**Enforcement:** Change-risk assessment validation (@schema:change-risk) checks that `regression_probability_evidence` contains either a coverage percentage reference or an explicit "no coverage data" statement. If `test_coverage_pct` is 0 and `regression_probability_score` is below 3, the evidence must justify why zero test coverage does not indicate elevated regression risk (e.g., "generated file, not executed directly"). If `test_coverage_pct` is 0 and no justification is provided, the minimum valid `regression_probability_score` is 3 (medium risk).

### 4. Unsafe Context Downgrade

**Statement:** If any single risk dimension in a change-risk assessment scores 4 or higher (out of 5), the change is flagged as unsafe and automatically downgraded to Suggesting intervention level regardless of finding confidence or severity. The unsafe flag must identify which dimension triggered it and provide the specific evidence. A change can only exit unsafe status through re-assessment that brings all dimensions below 4.

**Rationale:** High-risk changes at high intervention levels are the most dangerous output Transform can produce. An Authorizing-level playbook with blast radius 4/5 is telling the system "this change is ready for execution" while simultaneously acknowledging that it ripples widely through the codebase. The unsafe context downgrade is a circuit breaker — it ensures that changes with any extreme risk dimension are constrained to informational output only, where the cost of a mistake is lowest.

**Enforcement:** Workflow validation checks all four risk dimensions in the change-risk assessment (@schema:change-risk). If any dimension's score is ≥4: (1) the playbook's intervention level is overridden to `suggesting`, (2) the playbook must include an unsafe context flag identifying the triggering dimension, score, and evidence, (3) the change-risk assessment's `recommendation` must be `human_review_required` or `reject`. This override is not optional and cannot be bypassed by the agent.

### 5. Risk-Recommendation Alignment

**Statement:** The `overall_risk` classification and `recommendation` in a change-risk assessment must be logically consistent. High or critical risk cannot produce a "proceed" recommendation. Low risk with a "reject" recommendation must be explicitly justified. The valid default mappings are: low→proceed, medium→proceed_with_caution, high→human_review_required, critical→reject. Deviations from these defaults require justification in the risk summary.

**Rationale:** Disconnects between risk assessment and recommendation undermine trust in the entire assessment. If an agent rates a change as "high risk" but recommends "proceed," the human reviewer must decide which signal to trust — the quantitative assessment or the qualitative recommendation. This ambiguity defeats the purpose of structured risk assessment. Risk-recommendation alignment ensures that the assessment's conclusion follows from its evidence, and deviations are conscious choices, not oversights.

**Enforcement:** Change-risk assessment validation (@schema:change-risk) checks that `recommendation` matches the default mapping for `overall_risk`. If the recommendation deviates from the default (e.g., medium risk with `proceed` instead of `proceed_with_caution`), the `risk_summary` must contain an explicit justification for the deviation. Assessments with misaligned risk and recommendation and no justification are validation errors.

## DO

- Change-risk assessment for a configuration change: "Blast radius 2/5 — change modifies `config/database.py` (3 lines). Downstream consumer: `config/__init__.py` imports `DB_USER`, `DB_PASS`, `DB_HOST`. Variable names unchanged, so `app.py`, `workers/sync.py`, `scripts/migrate.py` which import from `config` are unaffected at the interface level."

- Regression probability assessment with coverage data: "Regression probability 2/5 — `tests/test_config.py` covers 78% of `config/database.py`. 4 existing test cases will need environment variable fixtures after the change. No test-free code paths are being modified."

- Unsafe context downgrade applied: "Change-risk dimension blast_radius scores 4/5 (change modifies the base `HttpClient` class used by 47 modules). UNSAFE CONTEXT — downgrading to Suggesting intervention level. Blast radius evidence: `grep -r 'import.*HttpClient' src/` returns 47 unique files. This change requires human architectural review before any structured remediation plan."

- New dependency justified: "Coupling risk 2/5 — introduces `python-dotenv` (no transitive dependencies, 15M weekly downloads, MIT license). Alternative considered: manual `os.environ` without `.env` support. Rejected because local development requires `.env` file loading. If `python-dotenv` is unavailable, application still works — `load_dotenv()` is called but failure is non-fatal when environment variables are set directly."

- Low-coverage warning: "UNTESTED CODE PATH — `config/database.py` has 0% test coverage per coverage.py. No existing tests validate database configuration loading. Regression probability elevated to 4/5. Recommend writing tests before applying this remediation."

## DON'T

- Change-risk assessment with blast radius 1/5 and evidence: "This is a small change."
  **Why this is wrong:** "Small change" is a judgment, not evidence. Blast radius evidence must cite specific files and trace at least one level of downstream consumers. A one-line change to a utility function can have a blast radius of 5/5 if 50 modules import it.

- Regression probability 1/5 with no mention of test coverage.
  **Why this is wrong:** Regression probability without test coverage data is speculation. Score of 1 implies high confidence that no regressions will occur — this requires evidence (high test coverage, additive-only change, no behavior modification). Without coverage data, the minimum defensible score is 3 for any change that modifies existing behavior.

- Change-risk assessment with overall_risk: high and recommendation: proceed.
  **Why this is wrong:** High risk and "proceed" are contradictory. If the risk is high, the recommendation must be at least `human_review_required`. A "proceed" recommendation for a high-risk change tells the reviewer "go ahead" while the assessment says "this is dangerous" — the disconnect erodes trust in the entire assessment system.

- Playbook at Authorizing level with blast_radius score 4/5 in the change-risk assessment.
  **Why this is wrong:** Any risk dimension scoring 4+ triggers the unsafe context downgrade. The playbook must be constrained to Suggesting level. There is no mechanism to keep it at Authorizing — the circuit breaker is automatic and non-overridable.

- Coupling risk assessment: "No new dependencies" when the change adds `import redis` to a module that previously had no Redis dependency.
  **Why this is wrong:** Adding an import to a new package is a new dependency. The `new_dependencies` list must include `redis`. Coupling risk evidence must address the runtime dependency on a Redis server — what happens if Redis is unavailable, is there a fallback, does this change the deployment requirements?
