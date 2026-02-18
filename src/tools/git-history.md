---
id: git-history
name: Git History Miner
type: history_mining
domains_fed: ["11", "12"]
install_required: false
install_command: "N/A — uses git, assumed present in any development environment"
---

## Purpose

Mines git repository history using native git commands to produce signals about change patterns, ownership concentration, code churn, file age, hotspot detection, and knowledge distribution. Feeds Change Risk & Evolvability (11) and Team, Ownership & Knowledge Risk (12) — the two domains most dependent on longitudinal evidence rather than point-in-time static analysis.

Unlike every other AEGIS tool, Git History Miner requires no installation. Git is assumed present in any development environment where AEGIS is run. Analysis is performed entirely with standard git CLI commands (`git log`, `git shortlog`, `git diff --stat`, `git blame`).

This tool is the primary signal source for AEGIS Transform's Change Risk Modeler. It produces four Transform-specific inputs: blast radius (via churn), regression probability (via bus factor), coupling risk (via dependency count), and architectural tension (via complexity proxy). The change-risk normalization section is mandatory for AEGIS Transform integration.

Signals are NOT findings. Git History Miner produces evidence that agents interpret within domain context.

## Configuration

### Time Window Parameters

Git history analysis is time-window-sensitive. Shorter windows surface recent velocity; longer windows surface structural patterns. Configure per analysis goal:

| Window | Use Case | Command Flag |
|--------|----------|-------------|
| 3 months | Sprint-level churn, recent instability | `--since="3 months ago"` |
| 6 months | Default for most audits | `--since="6 months ago"` |
| 1 year | Structural ownership patterns | `--since="1 year ago"` |
| All time | Full history bus factor, total churn | Omit `--since` entirely |

**Default configuration for AEGIS audits:** 6-month window for churn analysis, all-time for bus factor and ownership.

### Exclusion Patterns

Exclude noise-generating paths before computing churn metrics:

```bash
# Recommended exclusions via pathspec (append to git log commands)
-- ':!package-lock.json' ':!yarn.lock' ':!*.lock' ':!dist/' ':!build/' ':!vendor/' ':!node_modules/' ':!*.min.js' ':!*.min.css'
```

Lock files and generated build artifacts produce false churn signals and must be excluded from hotspot analysis.

### Churn Thresholds

Configure thresholds per repository size. Defaults assume a medium-sized codebase (20k-100k LOC, 1-5 years of history):

| Metric | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| File modification count (6mo) | <10 | 10-30 | 31-60 | >60 |
| Unique authors per file (all time) | ≥4 | 3 | 2 | 1 |
| Co-change coupling ratio | <0.2 | 0.2-0.4 | 0.4-0.7 | >0.7 |
| Days since last modification | <30 | 30-180 | 181-365 | >365 |

Adjust thresholds for large monorepos (higher churn is normal) and new codebases (shorter history reduces confidence).

### Output Directory

```bash
# Create output directory before running
mkdir -p {target_path}/.aegis/signals/git-history/
```

## Execution

### Prerequisites

Git History Miner uses only native git commands. No installation is required beyond git itself.

**Verify git availability:**
```bash
git --version
# Required: git 2.20 or later (for --format=format: support and pathspec exclusions)
```

**Verify repository access:**
```bash
git -C {target_path} log --oneline -1
# Must return at least one commit. Bare repositories are not supported.
```

### Primary Execution Commands

**Mode 1: File Churn Analysis**

Counts how many times each file was modified in the past 6 months. High-churn files are hotspot candidates.

```bash
git -C {target_path} log \
  --format=format: \
  --name-only \
  --since="6 months ago" \
  -- ':!package-lock.json' ':!yarn.lock' ':!*.lock' ':!dist/' ':!build/' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -50 \
  > {output_dir}/churn-by-file.txt
```

**Mode 2: Author Concentration Per File (Bus Factor)**

Counts unique authors who have touched each file across all history. Single-author files are knowledge silos.

```bash
# Run per file — pipe file list from churn analysis or directory scan
git -C {target_path} log \
  --format='%aN' \
  -- {file_path} \
  | sort \
  | uniq -c \
  | sort -rn \
  > {output_dir}/authors-{file_slug}.txt
```

For bulk bus factor analysis across top files:

```bash
# Generate per-file author counts for top 50 files by churn
git -C {target_path} log \
  --format='%aN %H' \
  --name-only \
  --since="1 year ago" \
  | awk '/^$/{next} /^[a-f0-9]{40}/{author=$1; next} {print author, $0}' \
  | sort -k2 \
  | uniq \
  | awk '{counts[$2]++} END {for(f in counts) print counts[f], f}' \
  | sort -rn \
  > {output_dir}/bus-factor-all-files.txt
```

**Mode 3: Commit Frequency by File (All Time)**

Top 50 most-committed files regardless of recency — surfaces structurally volatile files.

```bash
git -C {target_path} log \
  --pretty=format: \
  --name-only \
  -- ':!package-lock.json' ':!yarn.lock' ':!*.lock' ':!dist/' ':!build/' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -50 \
  > {output_dir}/commit-frequency-all-time.txt
```

**Mode 4: Code Age (Last Modified Date Per File)**

Identifies stale files (not touched in >1 year) that may contain outdated logic, deprecated patterns, or forgotten technical debt.

```bash
# Last modification date for every tracked file
git -C {target_path} ls-files \
  | while read f; do
      last_mod=$(git -C {target_path} log -1 --format="%ai" -- "$f" 2>/dev/null)
      echo "$last_mod $f"
    done \
  | sort \
  > {output_dir}/file-age.txt
```

**Mode 5: Change Coupling (Co-Change Analysis)**

Files modified together in the same commit more than a threshold percentage of the time are implicitly coupled. High coupling between distant files signals hidden dependencies.

```bash
# Extract per-commit file sets (last 6 months)
git -C {target_path} log \
  --format='COMMIT:%H' \
  --name-only \
  --since="6 months ago" \
  -- ':!package-lock.json' ':!yarn.lock' ':!dist/' ':!build/' \
  > {output_dir}/per-commit-files.txt

# Post-process in Python to compute pair co-change frequency
python3 - <<'EOF'
from collections import defaultdict
from itertools import combinations

commits = []
current = []

with open("{output_dir}/per-commit-files.txt") as f:
    for line in f:
        line = line.strip()
        if line.startswith("COMMIT:"):
            if current:
                commits.append(current)
            current = []
        elif line:
            current.append(line)
    if current:
        commits.append(current)

pair_counts = defaultdict(int)
file_counts = defaultdict(int)

for files in commits:
    for f in files:
        file_counts[f] += 1
    for a, b in combinations(sorted(files), 2):
        pair_counts[(a, b)] += 1

results = []
for (a, b), count in pair_counts.items():
    min_appearances = min(file_counts[a], file_counts[b])
    if min_appearances > 0:
        coupling = count / min_appearances
        if coupling >= 0.3 and count >= 3:
            results.append((coupling, count, a, b))

results.sort(reverse=True)
for coupling, count, a, b in results[:30]:
    print(f"{coupling:.2f}\t{count}\t{a}\t{b}")
EOF
```

**Mode 6: Bus Factor Score Per Directory**

Aggregates unique contributor counts at directory level for team ownership mapping.

```bash
git -C {target_path} log \
  --format='%aN' \
  --name-only \
  --since="1 year ago" \
  -- ':!package-lock.json' ':!yarn.lock' ':!dist/' ':!build/' \
  | awk '
    /^$/ { next }
    /^[A-Z]/ { author=$0; next }
    { print $0, author }
  ' \
  | awk '{dir=$1; sub(/\/[^\/]*$/, "", dir); print dir, $2}' \
  | sort -u \
  | awk '{counts[$1]++} END {for(d in counts) print counts[d], d}' \
  | sort -rn \
  > {output_dir}/bus-factor-by-directory.txt
```

### Docker Execution Variant

For containerized or CI environments where git is not available in the execution context, mount the repository into a minimal Alpine image with git installed:

```bash
docker run --rm \
  -v {target_path}:/repo:ro \
  -v {output_dir}:/output \
  alpine/git:latest \
  sh -c '
    cd /repo &&
    echo "=== CHURN ANALYSIS ===" &&
    git log --format=format: --name-only --since="6 months ago" \
      -- ":!package-lock.json" ":!yarn.lock" ":!dist/" ":!build/" \
      | sort | uniq -c | sort -rn | head -50 > /output/churn-by-file.txt &&
    echo "=== COMMIT FREQUENCY ALL TIME ===" &&
    git log --pretty=format: --name-only \
      -- ":!package-lock.json" ":!yarn.lock" ":!dist/" ":!build/" \
      | sort | uniq -c | sort -rn | head -50 > /output/commit-frequency-all-time.txt &&
    echo "=== FILE AGE ===" &&
    git ls-files | while read f; do
      last=$(git log -1 --format="%ai" -- "$f" 2>/dev/null); echo "$last $f"
    done | sort > /output/file-age.txt &&
    echo "Done."
  '
```

Note: The co-change coupling analysis (Mode 5) requires Python and is not included in the Docker variant above. Run it separately or use a Python-enabled image (`python:3.11-slim` with git installed).

### Execution Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--since` | Start of analysis window | "6 months ago" |
| `--until` | End of analysis window | HEAD (current) |
| `--format` | Output format for log | varies by mode |
| `--name-only` | Include file names in log | required for churn modes |
| `head -N` | Limit results to top N files | 50 |
| Coupling threshold | Minimum co-change ratio to report | 0.3 |
| Coupling min-count | Minimum shared commits to report | 3 |
| Bus factor threshold | Author count considered a silo | 1 |

### Runtime Characteristics

- **File churn (6 months):** 5-30 seconds for most repositories
- **File age (all files):** 30 seconds-5 minutes depending on file count (one git command per file)
- **Bus factor (per-file):** 10-60 seconds per file; 5-20 minutes for bulk all-files analysis
- **Co-change coupling:** 30 seconds-3 minutes for the git extraction; Python processing adds 5-30 seconds
- **Large monorepos (>500k commits):** All modes scale linearly with commit count; full history bus factor may take 30+ minutes

**Performance note:** File age analysis (Mode 4) runs one `git log -1` per tracked file. For repositories with tens of thousands of files, pipe through `xargs` with parallel execution or limit scope to a subdirectory.

## Output Format

Git history commands produce plain text. AEGIS normalizes raw command output into aggregated JSON signal records for consumption by domain agents. The following structure represents the canonical aggregated output after all six analysis modes complete:

```json
{
  "analysis_metadata": {
    "repository": "/srv/projects/payments-api",
    "analysis_date": "2026-02-18T09:14:33Z",
    "git_commit_head": "a7f3d91c4e2b58da0f6c9e3b1a4d7f2e5c8b0a3d",
    "history_window_churn": "6 months",
    "history_window_ownership": "all time",
    "total_commits_analyzed": 2847,
    "total_files_tracked": 1423,
    "excluded_patterns": ["package-lock.json", "yarn.lock", "*.lock", "dist/", "build/"]
  },
  "churn_hotspots": [
    {
      "file": "src/services/paymentProcessor.ts",
      "modification_count_6mo": 87,
      "modification_count_all_time": 234,
      "risk_tier": "critical"
    },
    {
      "file": "src/api/handlers/orderHandler.ts",
      "modification_count_6mo": 63,
      "modification_count_all_time": 181,
      "risk_tier": "high"
    },
    {
      "file": "src/utils/validation.ts",
      "modification_count_6mo": 41,
      "modification_count_all_time": 97,
      "risk_tier": "high"
    },
    {
      "file": "src/models/user.ts",
      "modification_count_6mo": 22,
      "modification_count_all_time": 58,
      "risk_tier": "medium"
    }
  ],
  "bus_factor_analysis": [
    {
      "file": "src/services/paymentProcessor.ts",
      "unique_authors": 1,
      "primary_author": "marcus.chen@example.com",
      "author_commit_share": 1.0,
      "bus_factor_score": "critical",
      "last_non_primary_commit": null
    },
    {
      "file": "src/core/authEngine.ts",
      "unique_authors": 2,
      "primary_author": "sarah.okonkwo@example.com",
      "author_commit_share": 0.89,
      "bus_factor_score": "high",
      "last_non_primary_commit": "2025-04-12T11:22:00Z"
    },
    {
      "file": "src/utils/validation.ts",
      "unique_authors": 4,
      "primary_author": "team-wide",
      "author_commit_share": null,
      "bus_factor_score": "low",
      "last_non_primary_commit": null
    }
  ],
  "ownership_by_directory": [
    {
      "directory": "src/services/",
      "unique_contributors_1yr": 2,
      "primary_owner": "marcus.chen@example.com",
      "ownership_concentration": 0.84,
      "bus_factor_score": "critical"
    },
    {
      "directory": "src/api/handlers/",
      "unique_contributors_1yr": 5,
      "primary_owner": null,
      "ownership_concentration": 0.31,
      "bus_factor_score": "low"
    }
  ],
  "change_coupling_pairs": [
    {
      "file_a": "src/services/paymentProcessor.ts",
      "file_b": "src/models/transaction.ts",
      "shared_commits": 52,
      "coupling_ratio": 0.79,
      "risk_tier": "critical",
      "interpretation": "Modified together in 79% of commits — implicit structural coupling"
    },
    {
      "file_a": "src/api/handlers/orderHandler.ts",
      "file_b": "src/services/inventoryService.ts",
      "shared_commits": 28,
      "coupling_ratio": 0.44,
      "risk_tier": "high",
      "interpretation": "Frequent co-change suggests hidden dependency not reflected in imports"
    },
    {
      "file_a": "src/config/database.ts",
      "file_b": "src/models/user.ts",
      "shared_commits": 11,
      "coupling_ratio": 0.31,
      "risk_tier": "medium",
      "interpretation": "Moderate co-change, may reflect schema migration coupling"
    }
  ],
  "stale_files": [
    {
      "file": "src/legacy/xmlParser.ts",
      "last_modified": "2022-11-03T08:44:12Z",
      "days_since_modified": 837,
      "risk_tier": "high",
      "interpretation": "Not modified in 27+ months — possible abandoned code or fossilized dependency"
    },
    {
      "file": "src/utils/legacyCrypto.ts",
      "last_modified": "2023-03-15T14:22:55Z",
      "days_since_modified": 705,
      "risk_tier": "high",
      "interpretation": "Crypto utility not updated in 23+ months — verify algorithm currency"
    }
  ],
  "summary_metrics": {
    "total_hotspot_files": 4,
    "single_author_files": 23,
    "two_author_files": 41,
    "high_coupling_pairs": 8,
    "stale_files_over_1yr": 17,
    "knowledge_silo_risk_score": "high"
  }
}
```

## Normalization

### Standard Signal Normalization

AEGIS transforms aggregated git history output into normalized signal records using the following field mapping:

| Raw Git Metric | AEGIS Field | Transformation |
|----------------|-------------|----------------|
| File modification count (6mo) | `source_rule` | `"churn-hotspot"` for high churn, `"churn-normal"` for low |
| File + modification count | `location` | `{file_path}` (file-level signal, no line number) |
| Churn count + bus factor combined | `raw_output` | JSON object with all computed metrics for the file |
| — | `source_tool` | Static: `"git-history"` |
| — | `signal_id` | Pattern: `S-GH-{NNN}` (sequential) |

**Severity mapping** (based on primary risk indicator):

| Condition | Severity |
|-----------|----------|
| Single-author file (bus factor = 1) | high |
| High churn (>30 modifications/6mo) + low test coverage correlation | high |
| High coupling ratio (>0.5) between non-adjacent modules | high |
| File stale >1 year + in critical path | high |
| Two-author file with 80%+ ownership concentration | medium |
| Moderate churn (10-30 modifications/6mo) | medium |
| File stale 6mo-1yr | medium |
| Low churn (<10 modifications/6mo), distributed authorship | low |

**Confidence estimate mapping** (based on history depth):

| History Available | Confidence | Rationale |
|-------------------|------------|-----------|
| >1 year of commits for this file | high | Sufficient sample to establish pattern |
| 6 months-1 year of commits | medium | Pattern visible but may be incomplete |
| <6 months of commits | low | Insufficient history — new codebase or file |
| File added in last 30 days | low | No meaningful history baseline |

**Blast radius mapping** (based on import graph and coupling):

| File Characteristics | Blast Radius |
|----------------------|--------------|
| Highly imported by many modules (import graph indicates hub) | widespread |
| High change-coupling ratio with critical-path files | widespread |
| Internal-only module, low coupling, limited dependents | localized |
| Shared utility, library, or middleware | moderate |
| Configuration files with cross-system impact | widespread |

**Domain relevance mapping:**

| Signal Type | Domain Relevance |
|-------------|-----------------|
| File churn, change coupling, stale code | ["11"] (Change Risk & Evolvability) |
| Bus factor, ownership concentration, knowledge silos | ["12"] (Team, Ownership & Knowledge Risk) |
| High-churn single-author file (both dimensions) | ["11", "12"] |
| Change coupling between non-obvious modules | ["11"] |

### Change-Risk Normalization

This section is required because Git History Miner is the primary data source for AEGIS Transform's Change Risk Modeler. The following table maps raw git signals to the four Transform change-risk input dimensions.

| Raw Signal | Change Risk Signal | Transformation |
|------------|-------------------|----------------|
| File modification frequency (churn) | `blast_radius_input` | High churn = file is frequently changed = many dependents affected across each change cycle. Churn >60/6mo → blast_radius_input: high. Churn 20-60 → medium. Churn <20 → low. |
| Author count per file (bus factor) | `regression_probability_input` | Single author = knowledge silo = higher probability of regression when that author is unavailable or makes a change in unfamiliar territory after gap. 1 author → regression_probability_input: high. 2 authors with 80%+ concentration → medium. ≥3 authors distributed → low. |
| Import/dependency count (coupling to file) | `coupling_risk_input` | More modules importing a file = more downstream breakage potential per change. Determined via static analysis cross-reference or co-change coupling ratio. Coupling ratio >0.5 → coupling_risk_input: high. 0.2-0.5 → medium. <0.2 → low. |
| Cyclomatic complexity proxy (file size + churn) | `architectural_tension_input` | Large files (>500 LOC proxy via git diff --stat) that also have high churn are harder to change safely — the file contains too much logic and is modified too often for confident refactoring. Files in top 10% by both size and churn → architectural_tension_input: high. Top 25% on either dimension → medium. Below both thresholds → low. |

**Change-risk normalization rules:**

1. **Blast radius input from churn** is computed per file over the 6-month window. Files excluded from the churn analysis (lock files, build artifacts) receive a blast_radius_input of `null` — they are excluded from Transform modeling.

2. **Regression probability input from bus factor** uses all-time history, not the 6-month window. Ownership patterns change slowly; recent-only data understates silo risk for mature files.

3. **Coupling risk input** is a two-source signal. Prefer static import graph data (from SonarQube or Semgrep) when available. Fall back to co-change coupling ratio from git history when static analysis is not available. When both are available, take the higher of the two for conservative risk estimation.

4. **Architectural tension input** is a proxy metric. Git history does not provide actual cyclomatic complexity — use `git diff --stat` to extract approximate line-count per file as a size proxy, then cross with churn frequency. This is intentionally conservative: a large frequently-changed file warrants investigation regardless of actual complexity.

5. **Transform agents consuming these inputs** should treat all four dimensions as directional signals, not precise measurements. The purpose is risk-ranking candidate files for change-safety assessment, not absolute scoring.

**Change-risk output signal format:**

```json
{
  "signal_id": "S-GH-017",
  "source_tool": "git-history",
  "source_rule": "churn-hotspot-silo",
  "file_path": "src/services/paymentProcessor.ts",
  "severity": "high",
  "confidence_estimate": "high",
  "blast_radius": "widespread",
  "domain_relevance": ["11", "12"],
  "change_risk_inputs": {
    "blast_radius_input": "high",
    "regression_probability_input": "high",
    "coupling_risk_input": "high",
    "architectural_tension_input": "high"
  },
  "raw_output": {
    "modification_count_6mo": 87,
    "unique_authors_all_time": 1,
    "primary_author": "marcus.chen@example.com",
    "author_commit_share": 1.0,
    "coupling_ratio_max": 0.79,
    "coupled_file": "src/models/transaction.ts",
    "approx_loc_proxy": 847,
    "history_depth_days": 712
  }
}
```

## Limitations

### Cannot Detect

1. **Intent behind changes**: High churn means frequent modification — it does not indicate whether those changes were improvements, regressions, or panic fixes. Churn is a risk proxy, not a quality verdict. Agent interpretation of surrounding context (PR descriptions, commit messages) is required.

2. **Hidden external ownership**: Developers who review and approve changes without committing (reviewers, leads, pair-programming partners) are invisible in git history. Bus factor scores undercount actual knowledge distribution when review-heavy workflows are in use.

3. **Semantic coupling across repositories**: Change coupling detection is scoped to a single repository. Microservices that change together due to API contract updates, schema migrations, or shared library upgrades will not show coupling in per-repo analysis.

4. **Submodule and subtree contents**: Git history mining operates on the parent repository. Changes within git submodules or subtrees that are committed externally are not included in churn, bus factor, or coupling analysis unless the parent repository has its own commit log.

5. **Squash-merged history**: Teams using squash merges lose commit granularity — a single squash commit replacing 40 feature commits appears as one modification event. Churn metrics will be systematically underestimated in squash-heavy workflows.

6. **Automated commit attribution**: CI/CD bots, automated dependency update tools (Dependabot, Renovate), and code generation pipelines commit under service account identities. These inflate churn counts and dilute true human bus factor. Exclude bot authors from bus factor analysis by filtering known bot email patterns.

### Known False Positives

1. **Churn in actively developed new features**: A file under active feature development for 6 months will show extreme churn that correctly reflects current activity but does not indicate instability risk — it reflects normal development velocity. Churn signals should be downweighted for files with consistently increasing LOC (growth pattern vs. oscillating rewrites).

2. **Single-author files that are intentionally siloed**: Some modules (security-sensitive cryptographic implementations, compliance-critical data access layers) are deliberately maintained by one specialist. High bus factor risk score correctly fires but may not represent an actual knowledge-gap threat if the single author is the designated owner.

3. **High coupling in test files paired with their source**: Test files are expected to change with their corresponding source files. `src/services/paymentProcessor.ts` and `tests/services/paymentProcessor.test.ts` should co-change — this is correct behavior, not hidden coupling. Exclude `tests/` and `spec/` paths from coupling analysis or treat test-source pairs as expected coupling.

4. **Stale files that are deliberately stable**: Foundational modules (abstract base classes, core type definitions, constants) may not change for years precisely because they are stable and correct. Age alone is not a risk signal — cross-reference against churn in dependent files to distinguish stable foundations from forgotten code.

5. **Ownership concentration in small teams**: On a three-person team, every file will show high ownership concentration for one author. Bus factor thresholds calibrated for large teams will generate excessive high-severity signals in small-team contexts. Normalize bus factor expectations against team size when known.

### Known False Negatives

1. **Knowledge silos in pull request reviewers**: Developers who informally own a module by virtue of always reviewing and approving changes are not captured in commit history. The actual bus factor may be lower than git-measured bus factor if the sole committer is not the sole knowledge holder.

2. **Hidden coupling via shared data stores**: Two services that both write to the same database schema are implicitly coupled but will show no co-change signal if they are in separate repositories. Cross-repository coupling mediated by shared infrastructure is invisible to single-repo history mining.

3. **Coupling in configuration and infrastructure files**: Application code coupling is well-captured, but coupling between application code and deployment configuration (Helm charts, Terraform, CI pipelines) that lives in a separate infrastructure repository will not appear in change coupling analysis of the application repository.

4. **Risk in stable files with recent ownership turnover**: A file that has had 5 different owners historically but has only been touched by one new engineer in the last 3 months is a hidden knowledge silo — the all-time bus factor appears healthy but current effective bus factor is 1. The tool computes historical bus factor only; recency-weighted ownership concentration requires custom analysis.

5. **Complexity risk in low-churn high-complexity files**: A 3000-line file that has not been modified in 18 months will receive low churn-based risk scores. If that file is central to system operation and a future change is required, the accumulated complexity and unfamiliarity risk is severe. The architectural tension proxy (churn x size) misses frozen-but-fragile files. Cross-reference with SonarQube complexity metrics to surface these cases.

6. **Language-specific commit patterns**: Some language ecosystems (Jupyter notebooks, Protocol Buffers, generated gRPC stubs) produce commits that do not reflect human authorship patterns. Generated file commits inflate churn and distort bus factor measurements for the files that trigger regeneration.
