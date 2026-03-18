---
id: playbook
name: Remediation Playbook
version: 1.0.0
used_by:
  - remediation-architect
  - pedagogy-agent
  - guardrail-generator
---

## Purpose

A Playbook is the atomic unit of Transform output — a structured remediation plan for a single finding. Where a Finding (@schema:finding) describes what is wrong and why it matters, a Playbook describes how to fix it, why the fix is correct, what risks the fix introduces, and how to verify the fix works.

Playbooks bridge the gap between diagnosis and action through the 4-layer transformation model. Each layer refines the remediation from abstract principle ("externalize secrets") through framework-specific guidance ("use dotenv with validation") to project-specific implementation ("replace lines 12-14 of config/database.py with os.environ lookups"). This layered approach prevents the most common failure mode in AI-generated fixes: context-free suggestions that are technically correct but architecturally wrong for the target codebase.

Every Playbook is governed by an intervention level (@schema:intervention-level) that constrains what Transform is permitted to recommend. A Playbook at the Suggesting level is informational. A Playbook at the Authorizing level is a full change specification with risk assessment and verification plan. The intervention level is not a quality indicator — it is a governance gate that reflects the confidence and evidence behind the remediation.

Playbooks are Layer B (remediation knowledge) output. They are the primary input to the Layer C execution pipeline and, when at Authorizing or Executing level, to PAUL for human-supervised change orchestration.

## Template

```markdown
### {playbook_id}

**Finding:** {finding_ref}
**Intervention Level:** {intervention_level}

---

#### Transformation Layers

##### Layer 1 — Abstract Pattern

{abstract_pattern}

##### Layer 2 — Framework Mapping

{framework_mapping}

##### Layer 3 — Language Mapping

{language_mapping}

##### Layer 4 — Project Context

{project_context}

---

#### Before (Anti-Pattern)

```{language}
{before_example}
```

#### After (Correct Pattern)

```{language}
{after_example}
```

---

#### Verification Steps

{verification_steps}

---

#### Risk Metadata

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Blast Radius | {blast_radius_score}/5 | {blast_radius_evidence} |
| Coupling Risk | {coupling_risk_score}/5 | {coupling_risk_evidence} |
| Regression Probability | {regression_probability_score}/5 | {regression_probability_evidence} |
| Architectural Tension | {architectural_tension_score}/5 | {architectural_tension_evidence} |

---

#### Educational Context

{educational_context}
```

## Field Reference

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `playbook_id` | string | yes | Unique identifier. Format: `PB-{DD}-{NNN}` where DD is the domain number from the source finding and NNN is sequence. | Pattern: `PB-\d{2}-\d{3}` |
| `finding_ref` | string | yes | The finding this playbook remediates. Must match a valid finding ID from @schema:finding. | Pattern: `F-\d{2}-\d{3}` (e.g., `F-04-001`) |
| `intervention_level` | enum | yes | Governance tier for this remediation. Determines what Transform is permitted to recommend and what evidence is required. | `suggesting`, `planning`, `authorizing`, `executing` |
| `abstract_pattern` | string | yes | Layer 1 — The general remediation principle independent of any language, framework, or project. Describes the pattern to apply and why it is correct. | Free-form, 2-4 sentences. Must not reference project-specific files or frameworks. |
| `framework_mapping` | string | yes | Layer 2 — How the abstract pattern maps to the target project's framework. References framework conventions, idioms, and standard approaches. | Free-form, 2-4 sentences. Must reference the specific framework. |
| `language_mapping` | string | yes | Layer 3 — Language-specific implementation guidance. Covers syntax, standard library usage, language idioms, and common pitfalls. | Free-form, 2-4 sentences. Must reference the specific language. |
| `project_context` | string | yes | Layer 4 — Project-specific implementation. References actual files, existing patterns in the codebase, and integration points. This is the most concrete layer. | Free-form, 2-4 sentences. Must reference specific files in the target codebase. |
| `before_example` | string | yes | Code showing the anti-pattern as it exists in the target codebase. Must be actual code from the codebase, not a generic example. | Fenced code block with language tag. |
| `after_example` | string | yes | Code showing the correct pattern after remediation. Must be compilable/runnable and follow the project's existing code style. | Fenced code block with language tag. |
| `verification_steps` | list of strings | yes | Ordered steps to verify the fix works. Each step must be concrete and executable — a command to run, a condition to check, or a behavior to observe. | Minimum 2 steps. Each must be actionable (not "make sure it works"). |
| `blast_radius_score` | integer | yes | How widely the change ripples through the codebase. | 1 (single file, no dependents) to 5 (cross-system, multiple services affected) |
| `blast_radius_evidence` | string | yes | Justification for the blast radius score. Must reference specific files, modules, or dependency chains. | Free-form. Must cite concrete artifacts. |
| `coupling_risk_score` | integer | yes | Whether the change introduces or tightens coupling between components. | 1 (no new coupling) to 5 (creates hard dependency on external system) |
| `coupling_risk_evidence` | string | yes | Justification for the coupling risk score. Must reference specific interfaces, imports, or dependency relationships. | Free-form. Must cite concrete artifacts. |
| `regression_probability_score` | integer | yes | Likelihood the change breaks existing functionality. | 1 (change is additive, no existing behavior modified) to 5 (modifies core logic with no test coverage) |
| `regression_probability_evidence` | string | yes | Justification for the regression probability score. Must reference test coverage data or lack thereof. | Free-form. Must cite test files or coverage metrics. |
| `architectural_tension_score` | integer | yes | Whether the change conflicts with the codebase's architectural direction. | 1 (aligns with existing patterns) to 5 (contradicts established architecture, requires migration) |
| `architectural_tension_evidence` | string | yes | Justification for the architectural tension score. Must reference architectural patterns or design decisions in the codebase. | Free-form. Must cite concrete patterns. |
| `educational_context` | string | no | Pedagogical explanation for AI-assisted developers. Explains why the anti-pattern is harmful and why the remediation is preferred. Written for a developer learning the concept, not an expert. | Free-form, 3-6 sentences. If present, must explain the "why" not just the "what". |

## Validation Rules

1. `playbook_id` must be unique across the entire audit. No two playbooks may share an ID. Format must match `PB-{DD}-{NNN}`.
2. `finding_ref` must reference an existing finding ID from the current audit. A playbook without a valid source finding is orphaned and invalid.
3. `intervention_level` must be one of the four enumerated values. The level must be justified by the source finding's confidence — see @schema:intervention-level for minimum confidence thresholds per level.
4. All four transformation layers must be populated. Layer 1 must not reference project-specific details. Layer 4 must reference project-specific files. If any layer simply repeats another layer's content, the playbook is invalid — each layer must add specificity.
5. `before_example` and `after_example` must both be non-empty fenced code blocks with a language tag. The before example must show actual code from the target codebase (not a generic illustration). The after example must be syntactically valid in the target language.
6. `verification_steps` must contain at least 2 concrete steps. Each step must be actionable — a command to run, a file to check, a behavior to observe. "Verify it works" is not a valid step.
7. All four `risk_metadata` dimensions must have both a score (integer 1-5) and evidence (non-empty string). A score without evidence is an unsupported assertion. Evidence must reference concrete artifacts (files, tests, dependencies), not general claims.
8. If `educational_context` is present, it must explain why the anti-pattern is harmful (not just what to do instead). A restatement of the after_example in prose is not educational context.
9. A playbook at `intervention_level: authorizing` or `executing` must have a corresponding verification plan (@schema:verification-plan) and change risk assessment (@schema:change-risk). Playbooks at `suggesting` or `planning` levels do not require these.
10. The `before_example` and `after_example` must address the same code location. A before example from `config/database.py` paired with an after example from `lib/secrets.py` without explaining the relocation is invalid.

## Examples

### Example: Planning-Level Playbook for Hardcoded Credentials

```markdown
### PB-04-001

**Finding:** F-04-001
**Intervention Level:** planning

---

#### Transformation Layers

##### Layer 1 — Abstract Pattern

Secrets must be externalized from source code into environment-injected configuration. This is the principle of separation of configuration from code — application behavior is defined in source, but deployment-specific values (credentials, endpoints, keys) are injected at runtime. Externalization ensures secrets are not version-controlled, are rotatable without code changes, and can differ per environment.

##### Layer 2 — Framework Mapping

In Python web applications using Flask or Django, the standard approach is environment variables loaded via `os.environ` with a `.env` file for local development (using `python-dotenv`). The framework's configuration system should be the single point of secret access — individual modules should not read environment variables directly. Django uses `settings.py`; Flask uses `app.config`.

##### Layer 3 — Language Mapping

Python's `os.environ` provides direct access to environment variables. For required secrets, use `os.environ["KEY"]` (raises `KeyError` if missing) rather than `os.environ.get("KEY")` (returns `None` silently). The `python-dotenv` package loads `.env` files into the environment for local development. Type coercion (e.g., `int(os.environ["PORT"])`) should happen at the configuration boundary, not at point of use.

##### Layer 4 — Project Context

Replace the hardcoded values in `config/database.py` (lines 12-14) with `os.environ["DB_USER"]`, `os.environ["DB_PASS"]`, and `os.environ["DB_HOST"]`. Add `python-dotenv` to `requirements.txt`. Create `.env.example` with placeholder keys (no values) for developer onboarding. Add `.env` to `.gitignore`. The existing `config/__init__.py` already imports from `database.py`, so no import changes are needed.

---

#### Before (Anti-Pattern)

```python
# config/database.py
DB_USER = "admin"
DB_PASS = "pr0d_s3cret_2024"
DB_HOST = "prod-db.internal.company.com"
```

#### After (Correct Pattern)

```python
# config/database.py
import os
from dotenv import load_dotenv

load_dotenv()

DB_USER = os.environ["DB_USER"]
DB_PASS = os.environ["DB_PASS"]
DB_HOST = os.environ["DB_HOST"]
```

---

#### Verification Steps

1. Run `grep -r "pr0d_s3cret\|admin\|prod-db.internal" config/` — must return no results (no hardcoded secrets remain)
2. Run `python -c "from config.database import DB_USER; print(DB_USER)"` with `.env` file present — must print the configured value without error
3. Run `python -c "from config.database import DB_USER"` without `.env` file or environment variables — must raise `KeyError` (fail-closed behavior)
4. Verify `.env` is listed in `.gitignore`
5. Verify `.env.example` exists with keys but no values

---

#### Risk Metadata

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Blast Radius | 2/5 | Change is confined to `config/database.py` and `requirements.txt`. One downstream consumer (`config/__init__.py`) imports these values but the interface (variable names) is unchanged. |
| Coupling Risk | 2/5 | Introduces dependency on `python-dotenv` package and on environment variable availability. Both are standard Python patterns with no lock-in. |
| Regression Probability | 2/5 | Existing tests in `tests/test_config.py` mock the database configuration. Tests will need `.env` file or environment variables set in test fixtures. Test coverage for config module is 78%. |
| Architectural Tension | 1/5 | Environment-based configuration aligns with the project's existing pattern in `config/api.py` (line 8) which already uses `os.environ` for the API key. This change makes the database config consistent with established practice. |

---

#### Educational Context

Hardcoded credentials in source code are one of the most common and dangerous security anti-patterns. When secrets are committed to version control, they persist in git history even after removal, they are accessible to anyone with repository access, and they cannot be rotated without a code change and deployment. Environment variable injection separates the secret lifecycle from the code lifecycle — secrets can be rotated, scoped per environment, and managed through dedicated secrets infrastructure without touching application code. The principle extends beyond credentials to any deployment-specific value: API endpoints, feature flags, rate limits.
```
