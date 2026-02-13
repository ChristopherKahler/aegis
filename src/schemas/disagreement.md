---
id: disagreement
name: Disagreement Record
version: 1.0.0
used_by:
  - principal-engineer
  - devils-advocate
  - architect
  - data-engineer
  - security-engineer
  - compliance-officer
  - senior-app-engineer
  - sre
  - performance-engineer
  - test-engineer
  - staff-engineer
  - reality-gap-analyst
---

## Purpose

A Disagreement is a first-class object in AEGIS — not a footnote, not a comment, not something to be quietly resolved. When two or more agents reach different conclusions about the same finding, that divergence is signal. It reveals where understanding is weakest relative to risk.

Disagreements happen because agents carry different threat models, different time horizons, different failure memories, and different risk tolerances. AEGIS surfaces these differences through structured records that identify what is disputed, why agents disagree, and how the Principal Engineer resolves the tension.

Every disagreement must be explicitly acknowledged, classified by root cause, resolved through a named model, and signed off by the Principal. Silent disappearance of disagreements is a critical anti-pattern — it destroys trust in the entire audit.

## Template

```markdown
### {disagreement_id}

**Finding:** {finding_id}
**Epistemic layer disputed:** {epistemic_layer_disputed}
**Agents involved:** {agents_involved}
**Status:** {status}

---

#### Positions

##### Position: {agent_id_1}

**Claim:** {claim_1}

**Evidence:**
{evidence_1}

**Assumptions:**
- {assumption_1a}

**Confidence:** {confidence_1}

##### Position: {agent_id_2}

**Claim:** {claim_2}

**Evidence:**
{evidence_2}

**Assumptions:**
- {assumption_2a}

**Confidence:** {confidence_2}

---

#### Root Cause Analysis

**Root cause:** {root_cause}
**Explanation:** {root_cause_explanation}

#### Resolution

**Resolution model:** {resolution_model_applied}
**Model application:** {how_model_was_applied}

#### Principal Response

**Response:** {principal_response}
**Rationale:** {principal_rationale}
**Follow-up:** {follow_up_action}

---

**Final status:** {status}
**Resolved by:** {resolver_agent_id}
**Resolution date:** {resolution_timestamp}
```

## Field Reference

### Top-Level Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `disagreement_id` | string | yes | Unique identifier across the entire audit. | Pattern: `D-{NNN}` where NNN is three-digit sequence (001-999). Example: `D-001` |
| `finding_id` | string | yes | The finding under dispute. | Must match a valid finding ID. Pattern: `F-{DD}-{NNN}`. |
| `epistemic_layer_disputed` | enum | yes | Which layer of the 7-layer epistemic stack is in dispute. | `observation`, `evidence_source`, `interpretation`, `assumptions`, `risk_statement`, `impact_likelihood`, `judgment` |
| `agents_involved` | list of strings | yes | Agent IDs participating in the disagreement. | At least 2 agent IDs. Each must match an agent assembly manifest's `id` field. |
| `status` | enum | yes | Current state of the disagreement. | `open`, `mitigated`, `accepted_risk`, `deferred`, `out_of_scope` |

### Position Fields (Array — one per agent)

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `agent_id` | string | yes | Which agent holds this position. | Must be one of the `agents_involved`. |
| `claim` | string | yes | What the agent asserts about the disputed layer. | 1-3 sentences. Specific, not vague. |
| `evidence` | string | yes | Evidence supporting the claim. | Must reference concrete artifacts — file paths, tool signals, metrics, or code snippets. Evidence-free claims are invalid. |
| `assumptions` | list of strings | yes | Assumptions underlying this position. | At least one assumption. Each must be a concrete, testable statement. |
| `confidence` | enum | yes | Agent's confidence in this position. | `high`, `medium`, `low` |

### Root Cause Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `root_cause` | enum | yes | Why the agents disagree. From the closed taxonomy. | `threat_model_mismatch`, `time_horizon_mismatch`, `evidence_availability_mismatch`, `risk_tolerance_mismatch`, `domain_boundary_mismatch`, `optimism_pessimism_bias`, `tool_trust_bias` |
| `root_cause_explanation` | string | yes | How this root cause manifests in this specific disagreement. | 1-3 sentences connecting the taxonomy entry to the specific positions. |

### Resolution Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `resolution_model_applied` | enum | conditional | Which resolution model was used to resolve the disagreement. Required when status is not `open`. | `evidence_dominance`, `risk_asymmetry`, `reversibility`, `time_to_failure`, `blast_radius` |
| `how_model_was_applied` | string | conditional | How the chosen model was applied to this specific case. Required when resolution_model_applied is present. | 2-4 sentences describing the reasoning. |

### Principal Response Fields

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `principal_response` | string | **always** | The Principal Engineer's explicit response. Silence is never valid. | 2-5 sentences. Must acknowledge the disagreement, state a position, and provide rationale. Null or empty is a validation error. |
| `principal_rationale` | string | **always** | Why the Principal reached this conclusion. | Must reference evidence, resolution model, or explicit reasoning. |
| `follow_up_action` | string | no | Any follow-up required after resolution. | Specific action (e.g., "Validate assumption X with runtime data") or "None required". |

### Resolution Metadata

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `resolver_agent_id` | string | conditional | Agent that resolved the disagreement. Required when status is not `open`. | Typically `principal-engineer`. |
| `resolution_timestamp` | string | conditional | When the disagreement was resolved. Required when status is not `open`. | ISO 8601 format or audit-relative timestamp. |

## Validation Rules

1. **Unique ID:** `disagreement_id` must be unique across the audit. No two disagreements may share an ID.
2. **Valid finding reference:** `finding_id` must reference an existing finding in the audit's finding set.
3. **Valid epistemic layer:** `epistemic_layer_disputed` must be one of the 7 enumerated layers.
4. **Minimum positions:** `positions` array must have at least 2 entries. A disagreement requires at least two perspectives — a single position is not a disagreement.
5. **Evidence-backed positions:** Every position must include evidence referencing concrete artifacts. A position with `evidence: "I believe this is true"` is invalid.
6. **Closed root cause taxonomy:** `root_cause` must be from the 7-entry closed taxonomy. No ad-hoc categories. If the root cause doesn't fit, the disagreement classification needs refinement, not a new category.
7. **Resolution model required for resolved:** `resolution_model_applied` is required when `status` is any value other than `open`. You cannot resolve a disagreement without naming the reasoning model.
8. **Principal response mandatory:** `principal_response` is ALWAYS required regardless of status. An open disagreement still requires the Principal to acknowledge it. Null, empty string, or omission is a validation error.
9. **Forward-only status transitions:** Status transitions must move forward: `open` -> {`mitigated`, `accepted_risk`, `deferred`, `out_of_scope`}. Resolved disagreements cannot revert to `open`.
10. **Anti-pattern detection:** The following patterns are validation failures:
    - **Auto-resolution:** Both positions marked as "resolved" without Principal response.
    - **Averaging:** Principal response that averages the positions (e.g., "severity is between high and medium").
    - **Forced consensus:** Resolution that claims agents now agree when positions have not changed.
    - **Hidden disagreement:** Disagreement referenced in a finding but no corresponding disagreement record exists.
    - **Devil's Advocate dismissal:** Disagreement from devils-advocate resolved as `out_of_scope` without substantive rationale.

## Examples

### Example: Security vs Application Engineer — SQL Injection Risk

```markdown
### D-001

**Finding:** F-04-007
**Epistemic layer disputed:** interpretation
**Agents involved:** security-engineer, senior-app-engineer
**Status:** mitigated

---

#### Positions

##### Position: security-engineer

**Claim:** The dynamic query construction at `src/api/users.py:45` using string concatenation is a SQL injection vector. User-supplied `sort_by` parameter is interpolated directly into the ORDER BY clause without parameterization or allowlist validation.

**Evidence:**
Semgrep rule `python.security.sql-injection.string-concat-query` flags `src/api/users.py:45`. The code reads:
```python
query = f"SELECT * FROM users ORDER BY {request.args['sort_by']}"
```
No parameterization. No sanitization function call between request input and query construction.

**Assumptions:**
- The `sort_by` parameter is reachable from external HTTP requests (not internal-only).
- No middleware or framework layer sanitizes the parameter before it reaches this code.

**Confidence:** high

##### Position: senior-app-engineer

**Claim:** The `sort_by` parameter passes through the `ValidatedRequest` middleware at `src/middleware/validation.py:28`, which restricts values to a hardcoded allowlist of column names (`["name", "email", "created_at", "updated_at"]`). String concatenation is used, but the input space is constrained to known-safe values.

**Evidence:**
File `src/middleware/validation.py:28-35` shows:
```python
ALLOWED_SORT_FIELDS = ["name", "email", "created_at", "updated_at"]
if request.args.get('sort_by') not in ALLOWED_SORT_FIELDS:
    raise ValidationError("Invalid sort field")
```
Route `src/api/routes.py:12` applies `ValidatedRequest` middleware to the `/users` endpoint.

**Assumptions:**
- The middleware is correctly applied to this route and cannot be bypassed.
- The allowlist is maintained as new columns are added.
- No other code path reaches `users.py:45` without passing through the middleware.

**Confidence:** medium

---

#### Root Cause Analysis

**Root cause:** evidence_availability_mismatch
**Explanation:** The security engineer's analysis focused on the query construction site in isolation (the direct code path from input to SQL). The application engineer had additional context about the middleware layer that restricts the input space. Both analyses are correct within their evidence scope — the disagreement arises because one agent had visibility into the defense layer and the other did not.

#### Resolution

**Resolution model:** evidence_dominance
**Model application:** The application engineer's evidence (middleware allowlist) directly addresses the security engineer's concern (unrestricted input). The middleware evidence is independently verifiable — the route configuration and validation logic are concrete code. However, the security engineer's concern about defense-in-depth remains valid: relying solely on middleware for SQL injection prevention is fragile. The finding should be downgraded from "injection vulnerability" to "defense-in-depth gap" with reduced severity.

#### Principal Response

**Response:** The SQL injection claim is mitigated by the allowlist middleware, but the underlying pattern (string concatenation in SQL construction) is still a maintenance risk. If a future developer adds a route to this handler without the middleware, or adds a new sort field without updating the allowlist, the injection vector reopens. The finding should be reclassified from critical (active injection) to medium (defense-in-depth gap) with a recommendation to use parameterized queries regardless of upstream validation.

**Rationale:** Evidence dominance favors the application engineer's position — the middleware demonstrably constrains the input. But the security engineer's architectural concern (string concatenation creates a latent vulnerability) is valid under the time-to-failure model. The compromise: acknowledge the current mitigation, flag the architectural weakness, and recommend parameterized queries as the durable fix.

**Follow-up:** Verify that all routes reaching `users.py:45` pass through `ValidatedRequest` middleware. Check for any route that bypasses middleware (e.g., internal API, admin endpoints, test harnesses).

---

**Final status:** mitigated
**Resolved by:** principal-engineer
**Resolution date:** 2026-02-15T14:30:00Z
```
