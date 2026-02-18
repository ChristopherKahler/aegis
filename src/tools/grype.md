---
id: grype
name: Grype
type: vulnerability_scan
domains_fed: ["04", "05"]
install_required: true
install_command: "See Installation section — curl, brew, or Docker"
---

## Purpose

Vulnerability scanner from the Anchore ecosystem that matches cataloged packages against known CVE databases. Operates in two distinct modes: direct filesystem or container image scanning, and SBOM-input mode (consuming a Syft-generated SBOM as stdin). The SBOM-input mode makes Grype the natural complement to Syft — Syft catalogs, Grype finds vulnerabilities. Feeds Security (04) and Compliance (05) domains.

In AEGIS workflows, both modes are valid. Direct scanning is faster for one-shot audits. SBOM-input mode is preferred when Syft has already been run, enabling reuse of the package catalog without re-traversal. Grype maintains its own vulnerability database (grype-db), independent of Trivy's database, providing a second opinion on the same dependency surface.

Signals are NOT findings. Grype produces evidence that agents interpret.

## Configuration

Grype supports configuration via a `.grype.yaml` file placed at the project root or in the user home directory:

**Configuration File** (`.grype.yaml`):
```yaml
output: json
file: ""
db:
  cache-dir: ~/.cache/grype/db
  update-url: https://toolbox-data.anchore.io/grype/databases/listing.json
  auto-update: true
  validate-by-hash-on-start: false
dev:
  profile-cpu: false
log:
  structured: false
  level: warn
fail-on-severity: ""
only-fixed: false
only-notfixed: false
ignore:
  - vulnerability: CVE-2024-12345
    reason: "Vendored with backported patch"
  - vulnerability: CVE-2024-67890
    reason: "No exploitable code path in our usage"
```

**Key Configuration Options**:
- **Severity Filtering**: `--fail-on-severity critical` exits non-zero when findings meet threshold, useful for CI gates
- **Fixed/Unfixed Filtering**: `--only-fixed` restricts output to vulnerabilities with a known fix, reducing noise
- **DB Auto-Update**: Automatic grype-db refresh on each run (configurable); first run downloads ~50MB
- **Ignore List**: Per-project `ignore` entries with required `reason` field for audit trails
- **Output Format**: json, table, cyclonedx, sarif, template

**Environment Variables**:
- `GRYPE_DB_CACHE_DIR`: Override default database cache location
- `GRYPE_DB_UPDATE_URL`: Custom vulnerability database mirror for air-gapped environments
- `GRYPE_CHECK_FOR_APP_UPDATE`: Disable Grype's self-update check (`false` for CI)

## Execution

### Installation Options

**Platform-Agnostic Methods**:

1. **Installation Script** (Linux/macOS — recommended):
   ```bash
   curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
   ```

2. **Homebrew** (macOS):
   ```bash
   brew tap anchore/grype
   brew install grype
   ```

3. **Docker** (recommended for CI/CD and consistency):
   ```bash
   docker pull anchore/grype:latest
   ```

4. **Binary Download** (all platforms):
   Download from [GitHub Releases](https://github.com/anchore/grype/releases)

### Primary Execution Commands

**Direct Filesystem Scanning** (AEGIS primary use case, Mode 1):
```bash
grype dir:{target_path} --output json --file {output_dir}/grype-results.json
```

**SBOM-Input Mode** (Mode 2 — consumes Syft output, preferred when Syft already ran):
```bash
syft {target_path} -o syft-json | grype --output json --file {output_dir}/grype-results.json
```

**SBOM from File** (Mode 2 variant — when Syft output is already saved to disk):
```bash
grype sbom:{output_dir}/syft-sbom.json --output json --file {output_dir}/grype-results.json
```

**Docker Variant** (direct scan):
```bash
docker run --rm \
  -v {target_path}:/target \
  -v ~/.cache/grype:/root/.cache/grype \
  anchore/grype:latest \
  dir:/target \
  --output json \
  --file /target/.aegis/signals/grype-results.json
```

**Container Image Scanning**:
```bash
grype {image_name}:{tag} --output json --file {output_dir}/grype-image-results.json
```

### Execution Parameters

| Parameter | Purpose | Values | Default |
|-----------|---------|--------|---------|
| `--output` | Output format | json, table, cyclonedx, sarif, template | table |
| `--file` | Output file path | file path | stdout |
| `--fail-on-severity` | Exit non-zero at threshold | critical, high, medium, low, negligible | "" (disabled) |
| `--only-fixed` | Suppress unfixed findings | boolean | false |
| `--only-notfixed` | Show only unfixed findings | boolean | false |
| `--add-cpes-if-none` | Attempt CPE generation when missing | boolean | false |
| `--by-cve` | Group results by CVE rather than package | boolean | false |
| `--config` | Custom config file path | file path | .grype.yaml |
| `--quiet` | Suppress all non-essential output | boolean | false |

### Runtime Characteristics

- **First Run**: 30-60 seconds (includes ~50MB vulnerability database download)
- **Subsequent Runs**: 5-15 seconds (database cached, fast matcher)
- **SBOM-Input Mode**: Slightly faster than direct scan — skips package cataloging
- **Database Updates**: Automatic on each run by default (configurable to manual)
- **Resource Usage**: Low CPU and memory; minimal disk I/O once DB is cached
- **Network Requirements**: Initial DB download only; `--db.auto-update=false` for air-gapped use

## Output Format

Grype produces structured JSON output with a flat matches array (unlike Trivy's per-target nesting):

```json
{
  "matches": [
    {
      "vulnerability": {
        "id": "CVE-2024-45590",
        "dataSource": "https://nvd.nist.gov/vuln/detail/CVE-2024-45590",
        "namespace": "npm:advisory",
        "severity": "High",
        "urls": [
          "https://nvd.nist.gov/vuln/detail/CVE-2024-45590",
          "https://github.com/expressjs/express/security/advisories/GHSA-qw6h-vgh9-j6wx"
        ],
        "description": "Express.js static file serving middleware allows path traversal attacks via specially crafted requests with encoded path separators, enabling unauthorized access to files outside the intended directory.",
        "cvss": [
          {
            "version": "3.1",
            "vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N",
            "metrics": {
              "baseScore": 7.5,
              "exploitabilityScore": 3.9,
              "impactScore": 3.6
            },
            "vendorMetadata": {}
          }
        ],
        "fix": {
          "versions": ["4.19.2"],
          "state": "fixed"
        },
        "advisories": [
          {
            "id": "GHSA-qw6h-vgh9-j6wx",
            "link": "https://github.com/expressjs/express/security/advisories/GHSA-qw6h-vgh9-j6wx"
          }
        ]
      },
      "relatedVulnerabilities": [
        {
          "id": "GHSA-qw6h-vgh9-j6wx",
          "dataSource": "https://github.com/advisories/GHSA-qw6h-vgh9-j6wx",
          "namespace": "github:language:javascript",
          "severity": "High",
          "urls": ["https://github.com/advisories/GHSA-qw6h-vgh9-j6wx"],
          "description": "Express.js path traversal vulnerability in static file serving",
          "cvss": [],
          "fix": {
            "versions": ["4.19.2"],
            "state": "fixed"
          },
          "advisories": []
        }
      ],
      "matchDetails": [
        {
          "type": "exact-indirect-match",
          "matcher": "javascript-matcher",
          "searchedBy": {
            "language": "javascript",
            "namespace": "npm:advisory",
            "package": {
              "name": "express",
              "version": "4.17.1"
            }
          },
          "found": {
            "versionConstraint": "< 4.19.2 (unknown)",
            "vulnerabilityID": "CVE-2024-45590"
          }
        }
      ],
      "artifact": {
        "id": "a1b2c3d4e5f60001",
        "name": "express",
        "version": "4.17.1",
        "type": "npm",
        "locations": [
          {
            "path": "/package-lock.json",
            "layerID": ""
          }
        ],
        "language": "javascript",
        "licenses": ["MIT"],
        "cpes": [
          "cpe:2.3:a:expressjs:express:4.17.1:*:*:*:*:node.js:*:*"
        ],
        "purl": "pkg:npm/express@4.17.1",
        "upstreams": []
      }
    },
    {
      "vulnerability": {
        "id": "CVE-2024-43796",
        "dataSource": "https://nvd.nist.gov/vuln/detail/CVE-2024-43796",
        "namespace": "npm:advisory",
        "severity": "Critical",
        "urls": [
          "https://nvd.nist.gov/vuln/detail/CVE-2024-43796",
          "https://github.com/axios/axios/issues/6463"
        ],
        "description": "Axios library allows Server-Side Request Forgery (SSRF) attacks via URL parsing inconsistencies when handling user-controlled URLs with CRLF injection, potentially enabling attackers to bypass allow-lists and access internal resources.",
        "cvss": [
          {
            "version": "3.1",
            "vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N",
            "metrics": {
              "baseScore": 9.3,
              "exploitabilityScore": 3.9,
              "impactScore": 5.8
            },
            "vendorMetadata": {}
          }
        ],
        "fix": {
          "versions": ["1.7.4"],
          "state": "fixed"
        },
        "advisories": []
      },
      "relatedVulnerabilities": [],
      "matchDetails": [
        {
          "type": "exact-direct-match",
          "matcher": "javascript-matcher",
          "searchedBy": {
            "language": "javascript",
            "namespace": "npm:advisory",
            "package": {
              "name": "axios",
              "version": "0.21.1"
            }
          },
          "found": {
            "versionConstraint": "< 1.7.4 (unknown)",
            "vulnerabilityID": "CVE-2024-43796"
          }
        }
      ],
      "artifact": {
        "id": "b2c3d4e5f6a70002",
        "name": "axios",
        "version": "0.21.1",
        "type": "npm",
        "locations": [
          {
            "path": "/package-lock.json",
            "layerID": ""
          }
        ],
        "language": "javascript",
        "licenses": ["MIT"],
        "cpes": [
          "cpe:2.3:a:axios-http:axios:0.21.1:*:*:*:*:node.js:*:*"
        ],
        "purl": "pkg:npm/axios@0.21.1",
        "upstreams": []
      }
    },
    {
      "vulnerability": {
        "id": "CVE-2023-26136",
        "dataSource": "https://nvd.nist.gov/vuln/detail/CVE-2023-26136",
        "namespace": "npm:advisory",
        "severity": "Medium",
        "urls": [
          "https://nvd.nist.gov/vuln/detail/CVE-2023-26136",
          "https://github.com/salesforce/tough-cookie/issues/282"
        ],
        "description": "The tough-cookie package before 4.1.3 for Node.js allows prototype pollution via cookie values, which could enable arbitrary property injection and potential denial of service.",
        "cvss": [
          {
            "version": "3.1",
            "vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:N/I:L/A:L",
            "metrics": {
              "baseScore": 4.8,
              "exploitabilityScore": 2.2,
              "impactScore": 2.5
            },
            "vendorMetadata": {}
          }
        ],
        "fix": {
          "versions": ["4.1.3"],
          "state": "fixed"
        },
        "advisories": []
      },
      "relatedVulnerabilities": [],
      "matchDetails": [
        {
          "type": "exact-indirect-match",
          "matcher": "javascript-matcher",
          "searchedBy": {
            "language": "javascript",
            "namespace": "npm:advisory",
            "package": {
              "name": "tough-cookie",
              "version": "2.5.0"
            }
          },
          "found": {
            "versionConstraint": "< 4.1.3 (unknown)",
            "vulnerabilityID": "CVE-2023-26136"
          }
        }
      ],
      "artifact": {
        "id": "c3d4e5f6a7b80003",
        "name": "tough-cookie",
        "version": "2.5.0",
        "type": "npm",
        "locations": [
          {
            "path": "/package-lock.json",
            "layerID": ""
          }
        ],
        "language": "javascript",
        "licenses": ["BSD-3-Clause"],
        "cpes": [
          "cpe:2.3:a:salesforce:tough-cookie:2.5.0:*:*:*:*:node.js:*:*"
        ],
        "purl": "pkg:npm/tough-cookie@2.5.0",
        "upstreams": []
      }
    },
    {
      "vulnerability": {
        "id": "CVE-2024-35195",
        "dataSource": "https://nvd.nist.gov/vuln/detail/CVE-2024-35195",
        "namespace": "pypi:advisory",
        "severity": "Medium",
        "urls": [
          "https://nvd.nist.gov/vuln/detail/CVE-2024-35195",
          "https://github.com/psf/requests/security/advisories/GHSA-9wx4-h78v-vm56"
        ],
        "description": "The requests library for Python does not strip the Proxy-Authorization header when handling cross-origin redirects, potentially leaking proxy credentials to third-party servers.",
        "cvss": [
          {
            "version": "3.1",
            "vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N",
            "metrics": {
              "baseScore": 5.9,
              "exploitabilityScore": 2.2,
              "impactScore": 3.6
            },
            "vendorMetadata": {}
          }
        ],
        "fix": {
          "versions": ["2.32.0"],
          "state": "fixed"
        },
        "advisories": [
          {
            "id": "GHSA-9wx4-h78v-vm56",
            "link": "https://github.com/psf/requests/security/advisories/GHSA-9wx4-h78v-vm56"
          }
        ]
      },
      "relatedVulnerabilities": [],
      "matchDetails": [
        {
          "type": "exact-direct-match",
          "matcher": "python-matcher",
          "searchedBy": {
            "language": "python",
            "namespace": "pypi:advisory",
            "package": {
              "name": "requests",
              "version": "2.28.0"
            }
          },
          "found": {
            "versionConstraint": "< 2.32.0 (unknown)",
            "vulnerabilityID": "CVE-2024-35195"
          }
        }
      ],
      "artifact": {
        "id": "d4e5f6a7b8c90004",
        "name": "requests",
        "version": "2.28.0",
        "type": "python",
        "locations": [
          {
            "path": "/requirements.txt",
            "layerID": ""
          }
        ],
        "language": "python",
        "licenses": ["Apache-2.0"],
        "cpes": [
          "cpe:2.3:a:python-requests:requests:2.28.0:*:*:*:*:python:*:*"
        ],
        "purl": "pkg:pypi/requests@2.28.0",
        "upstreams": []
      }
    }
  ],
  "source": {
    "type": "directory",
    "target": {
      "path": "/home/user/project"
    }
  },
  "distro": {
    "name": "",
    "version": "",
    "idLike": []
  },
  "descriptor": {
    "name": "grype",
    "version": "0.74.3",
    "configuration": {
      "output": ["json"],
      "file": "",
      "distro": "",
      "add-cpes-if-none": false,
      "output-template-file": "",
      "quiet": false,
      "check-for-app-update": true,
      "only-fixed": false,
      "only-notfixed": false,
      "fail-on-severity": "",
      "registry": {
        "insecure-skip-tls-verify": false,
        "insecure-use-http": false,
        "auth": []
      },
      "ignore": [],
      "db": {
        "cache-dir": "/root/.cache/grype/db",
        "update-url": "https://toolbox-data.anchore.io/grype/databases/listing.json",
        "ca-cert": "",
        "auto-update": true,
        "validate-by-hash-on-start": false
      }
    },
    "db": {
      "built": "2026-02-15T01:16:13Z",
      "schemaVersion": 5,
      "location": "/root/.cache/grype/db/5",
      "checksum": "sha256:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2",
      "error": null
    }
  }
}
```

**Key Output Fields**:
- `matches[]`: Flat array of vulnerability match objects (one entry per CVE+package combination)
  - `vulnerability.id`: CVE identifier (e.g., CVE-2024-45590)
  - `vulnerability.severity`: Critical, High, Medium, Low, Negligible
  - `vulnerability.cvss[].metrics.baseScore`: CVSS v3 base score
  - `vulnerability.fix.versions[]`: Version(s) containing the fix
  - `vulnerability.fix.state`: "fixed", "not-fixed", "wont-fix", "unknown"
  - `matchDetails[].type`: Match confidence indicator — `exact-direct-match`, `exact-indirect-match`, `cpe-match`
  - `artifact.name`: Affected package name
  - `artifact.version`: Installed version
  - `artifact.type`: Package ecosystem (npm, python, go, java, etc.)
  - `artifact.locations[].path`: File containing the package declaration
  - `artifact.purl`: Package URL for unambiguous package identification
- `source`: Scanned target details (directory, image, SBOM file)
- `descriptor.db.built`: Timestamp of the vulnerability database used

## Normalization

Grype raw output requires normalization to AEGIS signal format:

| Grype Field | AEGIS Signal Field | Transformation Logic |
|-------------|-------------------|----------------------|
| `vulnerability.id` | `source_rule` | Direct mapping (e.g., CVE-2024-45590) |
| Auto-generated | `signal_id` | Pattern: `S-GRP-{NNN}` (sequential numbering) |
| Fixed value | `source_tool` | Always "grype" |
| `artifact.locations[0].path` + `artifact.name` | `file_path` | Combine: `{path}:{name}` (e.g., "/package-lock.json:express") |
| `vulnerability.description` + `artifact.version` + `vulnerability.fix.versions[0]` | `context` | Enriched: "{description} Found: {version}, Fixed: {fixVersion}" |
| `vulnerability.severity` | `severity` | Map: Critical→critical, High→high, Medium→medium, Low→low, Negligible→informational |
| `matchDetails[].type` | `confidence_estimate` | Match-type-based: exact-direct-match→high, exact-indirect-match→medium, cpe-match→low |
| Derived from `artifact.type` + package role | `blast_radius` | Core dependency→widespread, dev dependency→localized, transitive→moderate |
| Derived from CVE type + CWE classification | `domain_relevance` | Most CVEs→["04"], data/crypto CVEs→["04","05"] |
| `vulnerability.fix.state` + `vulnerability.fix.versions` | Signal enrichment | "fixed" with versions→actionable, "not-fixed"→informational flag |

### Normalization Rules

**Severity Mapping**:
- Critical → `severity: "critical"`
- High → `severity: "high"`
- Medium → `severity: "medium"`
- Low → `severity: "low"`
- Negligible → `severity: "informational"` (track but do not escalate)

**Confidence Estimation** (based on `matchDetails[].type`):
- `exact-direct-match` → `confidence_estimate: "high"` (package version directly confirmed in DB)
- `exact-indirect-match` → `confidence_estimate: "medium"` (matched via constraint range, not exact version)
- `cpe-match` → `confidence_estimate: "low"` (CPE-based lookup, higher false positive risk)
- Multiple match details present → use highest confidence type
- No match details → `confidence_estimate: "medium"` (default for known CVEs)

**Blast Radius Derivation**:
- Core/production dependency (present in `dependencies` or `install_requires`) → `blast_radius: "widespread"`
- Dev/test dependency (present in `devDependencies`, `[dev-packages]`, or `[test]` extras) → `blast_radius: "localized"`
- Transitive dependency (not in top-level manifest, appears only in lock file) → `blast_radius: "moderate"`
- Determine via cross-referencing `artifact.locations[].path` against direct vs. transitive dependency lists

**Domain Relevance Assignment**:
- Default → `domain_relevance: ["04"]` (Security domain)
- Data exposure CVEs (CWE-200, CWE-312, CWE-359) → `domain_relevance: ["04", "05"]`
- Cryptographic CVEs (CWE-295, CWE-327, CWE-338) → `domain_relevance: ["04", "05"]`
- Authentication/credential CVEs (CWE-287, CWE-522) → `domain_relevance: ["04", "05"]`
- Compliance-referenced CVEs (HIPAA, PCI-DSS adjacent) → `domain_relevance: ["04", "05"]`

**Deduplication Strategy**:
- Same CVE affecting the same package version in multiple locations → Single signal with aggregated locations
- Key: `{vulnerability.id}:{artifact.name}:{artifact.version}`
- Merge `artifact.locations` entries: `["/package-lock.json:axios", "/yarn.lock:axios"]`
- When Grype and Trivy both detect the same CVE, prefer the higher-confidence match detail; note both tools in `context`

**Special Cases**:
- `fix.state: "wont-fix"` → Flag as accepted upstream risk; lower escalation priority but do not suppress
- `fix.state: "not-fixed"` → Mark as "unfixed", track for future remediation cycles
- Negligible severity → Emit as informational signal only; do not contribute to severity scoring
- `cpe-match` type with no CVSS score → Flag for manual triage; emit signal with `confidence_estimate: "low"`
- SBOM-input mode produces identical output format — normalization logic is mode-agnostic

## Limitations

### Cannot Detect

1. **Custom/Proprietary Vulnerabilities**: Only identifies vulnerabilities present in Anchore's grype-db, which aggregates NVD, GitHub Advisory Database, and vendor-specific advisories. Internal or unpublished vulnerabilities are invisible until they receive a public CVE assignment.

2. **Business Logic and Application Vulnerabilities**: Cannot identify logic flaws, broken access control, or injection vulnerabilities in first-party application code. Grype evaluates third-party component versions, not code behavior.

3. **Zero-Day Exploits**: Undisclosed vulnerabilities without CVE identifiers are absent from grype-db. Detection is contingent on public disclosure and database ingestion, which introduces a lag of hours to days.

4. **Vendored or Manually Copied Dependencies**: Source code copied directly into the repository without package manager metadata (no `package.json`, `go.sum`, etc.) is invisible to Grype. Detection requires a package manifest or lock file entry.

5. **Runtime-Only Misconfigurations**: Insecure environment variable handling, exposed secrets, or misconfigured TLS settings that do not correspond to a CVE in a versioned package are outside Grype's scope.

6. **Vulnerabilities in Build-Time Tooling**: Compilers, bundlers, linters, and CI/CD tooling that appear only in developer environments and not in production manifests are not evaluated.

7. **Interpreted Scripts and Shell Utilities**: Shell scripts and utility scripts installed outside of a tracked package manager (e.g., curl-installed binaries in CI) do not produce catalog entries and are therefore not matched.

### False Positives

1. **OS Packages with Backported Patches**: Linux distribution packages (rpm, deb) frequently backport security fixes without incrementing the upstream version number. Grype may flag these as vulnerable based on version comparison when the patch is already applied.

2. **CPE-Match Overreach**: When Grype falls back to CPE-based matching (`cpe-match` type), it may associate a package with vulnerabilities from a similarly named but distinct product, particularly for packages with generic names (e.g., `log`, `util`, `crypto`).

3. **Unused or Optional Dependencies**: Packages declared in manifests but never imported in production code paths are flagged at the same severity as actively executed dependencies, inflating risk assessments for dead code.

4. **Dev/Test-Only Dependencies at Production Severity**: Development and test tooling (e.g., `jest`, `pytest`, `eslint`) that never reaches production runtime are reported alongside production dependencies without automatic severity downgrade.

5. **Version Constraint Ambiguity**: `exact-indirect-match` results represent constraint-range matches rather than confirmed version matches. A package resolved to a version that falls within a vulnerable range may not actually be exploitable if the specific vulnerable code path was introduced in a later patch.

### False Negatives

1. **Transitive Dependencies Absent from Lock Files**: Packages resolved at runtime or installed via non-standard mechanisms that do not produce lock file entries are not cataloged by Grype or Syft, and therefore cannot be matched.

2. **Recently Published CVEs**: grype-db is updated daily, but the window between CVE publication and database availability creates a gap. Very recent disclosures may not appear until the next scheduled database refresh.

3. **Custom Forks of Open Source Packages**: Internally maintained forks that diverge from the upstream vulnerability surface (e.g., a fork with unpatched vulnerabilities that the upstream has since fixed) are matched against the upstream version's vulnerability record, which may not reflect the fork's actual state.

4. **Compiled Binaries and Embedded SDKs**: Pre-compiled `.whl`, `.jar`, `.aar`, or SDK bundles embedded in the repository without accompanying manifest metadata cannot be matched without CPE data, and CPE coverage is incomplete.

5. **Packages with Incorrect or Missing PURLs**: Packages that lack valid Package URLs in the SBOM (when using SBOM-input mode) may fail to match against the vulnerability database if the package ecosystem or name does not resolve to a known namespace.

6. **Vulnerabilities Affecting Specific Configurations**: CVEs that only manifest under specific compile flags, platform targets, or optional feature sets are reported as absent if the package version falls outside the vulnerable range for the general case, even if the specific build configuration is affected.
