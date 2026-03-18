---
id: syft
name: Syft
type: sbom
domains_fed: ["04", "05"]
install_required: true
install_command: "See Installation section — curl, brew, or Docker"
---

## Purpose

SBOM (Software Bill of Materials) generation tool from Anchore. Catalogs all packages, dependencies, and licenses present in a codebase or container image — producing a complete component inventory. Feeds Security (04) and Compliance (05) domains.

Syft is an **inventory tool**, not a vulnerability scanner. It enumerates what is installed: package names, versions, types, file locations, and license identifiers. It does not assess whether any component is vulnerable. That assessment is the responsibility of Grype (a separate tool) and AEGIS agents, both of which consume Syft SBOM output for downstream analysis.

Syft detects packages from: language package managers (npm, pip, Maven, Go modules, RubyGems, NuGet, Cargo), OS package managers (dpkg, rpm, apk), container image layers, and binary analysis (CPE extraction from compiled executables).

**Signals are component records, not vulnerability findings.** Syft produces inventory evidence that agents interpret. Severity is license-driven; confidence reflects the determinism of package detection, not exploit likelihood.

## Configuration

Syft supports configuration via `.syft.yaml` at the repository root and command-line flags:

**Configuration File** (`.syft.yaml`):
```yaml
output:
  - "syft-json"
file:
  metadata:
    digests:
      - "sha256"
catalogers:
  enabled:
    - "python-package-cataloger"
    - "javascript-package-cataloger"
    - "go-module-binary-cataloger"
    - "java-pom-cataloger"
    - "dpkg-db-cataloger"
    - "rpm-db-cataloger"
  disabled: []
log:
  level: "warn"
```

**Key Configuration Options**:
- **Output Format**: `syft-json` (native, richest), `spdx-json` (SPDX 2.3 standard), `cyclonedx-json` (CycloneDX 1.4 standard), `table` (human-readable). AEGIS prefers `syft-json` for normalization; `spdx-json` or `cyclonedx-json` for compliance deliverables.
- **Cataloger Selection**: Individual catalogers can be enabled or disabled to scope the scan. Disable catalogers irrelevant to the target stack to reduce noise and runtime.
- **Scope**: `--scope squashed` (default) merges layers and deduplicates; `--scope all-layers` preserves per-layer package records (container image scanning only).
- **Exclude Patterns**: `--exclude ./vendor --exclude ./node_modules/.cache` to skip vendored or generated directories.

**Cataloger Reference** (common catalogers relevant to AEGIS scans):

| Cataloger | Detects |
|-----------|---------|
| `javascript-package-cataloger` | npm, yarn (package.json, lock files) |
| `python-package-cataloger` | pip, poetry, pipenv (site-packages, requirements, pyproject.toml) |
| `go-module-binary-cataloger` | Go module metadata embedded in compiled binaries |
| `go-module-file-cataloger` | go.mod, go.sum |
| `java-pom-cataloger` | Maven pom.xml, JAR/WAR manifests |
| `dotnet-deps-cataloger` | NuGet .deps.json, packages.lock.json |
| `ruby-gemspec-cataloger` | Gemfile.lock, .gemspec |
| `rust-cargo-lock-cataloger` | Cargo.lock |
| `dpkg-db-cataloger` | Debian/Ubuntu system packages (/var/lib/dpkg/status) |
| `rpm-db-cataloger` | RHEL/CentOS system packages (/var/lib/rpm) |

## Execution

### Installation Options

**1. Installation Script (Linux/macOS — recommended for local use):**
```bash
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

**2. Homebrew (macOS/Linux):**
```bash
brew install syft
```

**3. Docker (all platforms — recommended for CI/CD and consistency):**
```bash
docker pull anchore/syft:latest
```

**4. Binary Download (all platforms):**
Download from [GitHub Releases](https://github.com/anchore/syft/releases) and place in `$PATH`.

**Verify Installation:**
```bash
syft version
```

### Primary Execution Commands

**Filesystem Scan** (AEGIS primary use case — native JSON format):
```bash
syft scan {target_path} \
  --output syft-json={output_dir}/syft-sbom.json \
  --exclude ./vendor \
  --exclude ./node_modules/.cache
```

**Docker Variant**:
```bash
docker run --rm \
  -v {target_path}:/target \
  anchore/syft:latest \
  scan /target \
    --output syft-json=/target/.aegis/signals/syft-sbom.json \
    --exclude /target/vendor
```

**SPDX Format Output (for compliance deliverables)**:
```bash
syft scan {target_path} \
  --output spdx-json={output_dir}/syft-sbom.spdx.json
```

**CycloneDX Format Output (for Grype or other consumers)**:
```bash
syft scan {target_path} \
  --output cyclonedx-json={output_dir}/syft-sbom.cdx.json
```

**Container Image Scan**:
```bash
syft scan {image_name}:{tag} \
  --output syft-json={output_dir}/syft-image-sbom.json \
  --scope squashed
```

**Multiple Output Formats Simultaneously**:
```bash
syft scan {target_path} \
  --output syft-json={output_dir}/syft-sbom.json \
  --output spdx-json={output_dir}/syft-sbom.spdx.json
```

### Execution Parameters

| Parameter | Purpose | Values | Default |
|-----------|---------|--------|---------|
| `--output` | Output format and destination | `{format}={path}` (repeatable) | table to stdout |
| `--scope` | Layer handling for container images | `squashed`, `all-layers` | squashed |
| `--exclude` | Glob patterns to skip | path glob | none |
| `--select-catalogers` | Override cataloger set | cataloger name list | all applicable |
| `--config` | Config file path | file path | `.syft.yaml` |
| `--quiet` | Suppress progress output | boolean flag | false |
| `--verbose` | Increase log verbosity | boolean flag | false |
| `--from` | Source override (oci-dir, docker, etc.) | scheme string | auto-detect |

### Runtime Characteristics

- **Filesystem Scans**: 5-30 seconds for typical application repositories. Scales with number of packages, not lines of code.
- **Container Image Scans**: 10-60 seconds depending on image size and layer count.
- **No Network Required**: Syft operates entirely offline — no vulnerability database downloads. All detection is local.
- **Resource Usage**: Low CPU and memory. Disk I/O proportional to node_modules or similar large dependency trees.
- **Idempotent**: Same source produces identical output (deterministic catalog).

## Output Format

Syft produces structured JSON (syft-json schema) with package entries as the primary payload:

```json
{
  "schema": {
    "version": "16.0.9",
    "url": "https://raw.githubusercontent.com/anchore/syft/main/schema/json/schema-16.0.9.json"
  },
  "artifacts": [
    {
      "id": "8f3a2c1d4e9b7f05",
      "name": "express",
      "version": "4.18.2",
      "type": "npm",
      "foundBy": "javascript-package-cataloger",
      "locations": [
        {
          "path": "/app/node_modules/express/package.json",
          "accessPath": "/app/node_modules/express/package.json"
        }
      ],
      "licenses": [
        {
          "value": "MIT",
          "spdxExpression": "MIT",
          "type": "declared",
          "urls": [],
          "locations": [
            {
              "path": "/app/node_modules/express/package.json"
            }
          ]
        }
      ],
      "language": "javascript",
      "cpes": [
        "cpe:2.3:a:expressjs:express:4.18.2:*:*:*:*:node.js:*:*"
      ],
      "purl": "pkg:npm/express@4.18.2",
      "metadataType": "NpmPackage",
      "metadata": {
        "name": "express",
        "version": "4.18.2",
        "author": "TJ Holowaychuk <tj@vision-media.ca>",
        "licenses": ["MIT"],
        "homepage": "https://expressjs.com/",
        "description": "Fast, unopinionated, minimalist web framework",
        "files": []
      }
    },
    {
      "id": "2b7e4f9a0c3d8e16",
      "name": "lodash",
      "version": "4.17.21",
      "type": "npm",
      "foundBy": "javascript-package-cataloger",
      "locations": [
        {
          "path": "/app/node_modules/lodash/package.json",
          "accessPath": "/app/node_modules/lodash/package.json"
        }
      ],
      "licenses": [
        {
          "value": "MIT",
          "spdxExpression": "MIT",
          "type": "declared",
          "urls": [],
          "locations": [
            {
              "path": "/app/node_modules/lodash/package.json"
            }
          ]
        }
      ],
      "language": "javascript",
      "cpes": [
        "cpe:2.3:a:lodash:lodash:4.17.21:*:*:*:*:node.js:*:*"
      ],
      "purl": "pkg:npm/lodash@4.17.21",
      "metadataType": "NpmPackage",
      "metadata": {
        "name": "lodash",
        "version": "4.17.21",
        "author": "John-David Dalton <john.david.dalton@gmail.com>",
        "licenses": ["MIT"],
        "homepage": "https://lodash.com/",
        "description": "Lodash modular utilities.",
        "files": []
      }
    },
    {
      "id": "5c9f1e3a7b2d0f48",
      "name": "requests",
      "version": "2.31.0",
      "type": "python",
      "foundBy": "python-package-cataloger",
      "locations": [
        {
          "path": "/usr/lib/python3/dist-packages/requests-2.31.0.dist-info/METADATA",
          "accessPath": "/usr/lib/python3/dist-packages/requests-2.31.0.dist-info/METADATA"
        }
      ],
      "licenses": [
        {
          "value": "Apache-2.0",
          "spdxExpression": "Apache-2.0",
          "type": "declared",
          "urls": [],
          "locations": [
            {
              "path": "/usr/lib/python3/dist-packages/requests-2.31.0.dist-info/METADATA"
            }
          ]
        }
      ],
      "language": "python",
      "cpes": [
        "cpe:2.3:a:python-requests:requests:2.31.0:*:*:*:*:python:*:*"
      ],
      "purl": "pkg:pypi/requests@2.31.0",
      "metadataType": "PythonPackage",
      "metadata": {
        "name": "requests",
        "version": "2.31.0",
        "author": "Kenneth Reitz",
        "license": "Apache 2.0",
        "sitePackagesRootPath": "/usr/lib/python3/dist-packages"
      }
    },
    {
      "id": "9a0d6b4c2e8f1730",
      "name": "org.springframework:spring-core",
      "version": "5.3.27",
      "type": "java-archive",
      "foundBy": "java-pom-cataloger",
      "locations": [
        {
          "path": "/app/pom.xml",
          "accessPath": "/app/pom.xml"
        }
      ],
      "licenses": [
        {
          "value": "Apache-2.0",
          "spdxExpression": "Apache-2.0",
          "type": "declared",
          "urls": ["https://www.apache.org/licenses/LICENSE-2.0"],
          "locations": [
            {
              "path": "/app/pom.xml"
            }
          ]
        }
      ],
      "language": "java",
      "cpes": [
        "cpe:2.3:a:springsource:spring_framework:5.3.27:*:*:*:*:*:*:*"
      ],
      "purl": "pkg:maven/org.springframework/spring-core@5.3.27",
      "metadataType": "JavaArchive",
      "metadata": {
        "virtualPath": "org.springframework:spring-core",
        "pomArtifactID": "spring-core",
        "pomGroupID": "org.springframework",
        "manifestName": "",
        "archiveDigests": []
      }
    },
    {
      "id": "e3f7c2a9b5d0841c",
      "name": "gpl-licensed-utility",
      "version": "2.1.0",
      "type": "npm",
      "foundBy": "javascript-package-cataloger",
      "locations": [
        {
          "path": "/app/node_modules/gpl-licensed-utility/package.json",
          "accessPath": "/app/node_modules/gpl-licensed-utility/package.json"
        }
      ],
      "licenses": [
        {
          "value": "GPL-3.0-or-later",
          "spdxExpression": "GPL-3.0-or-later",
          "type": "declared",
          "urls": [],
          "locations": [
            {
              "path": "/app/node_modules/gpl-licensed-utility/package.json"
            }
          ]
        }
      ],
      "language": "javascript",
      "cpes": [],
      "purl": "pkg:npm/gpl-licensed-utility@2.1.0",
      "metadataType": "NpmPackage",
      "metadata": {
        "name": "gpl-licensed-utility",
        "version": "2.1.0",
        "licenses": ["GPL-3.0-or-later"],
        "description": "Utility library distributed under GPL-3.0",
        "files": []
      }
    }
  ],
  "artifactRelationships": [
    {
      "parent": "8f3a2c1d4e9b7f05",
      "child": "2b7e4f9a0c3d8e16",
      "type": "dependency-of"
    }
  ],
  "source": {
    "type": "directory",
    "target": {
      "path": "/app"
    }
  },
  "distro": {
    "name": "ubuntu",
    "version": "22.04",
    "idLike": ["debian"]
  }
}
```

**Key Output Fields**:
- `schema.version`: Syft JSON schema version — used to detect breaking changes between Syft releases
- `artifacts[]`: Array of discovered package/component records — the primary payload
  - `id`: Syft-internal stable identifier for the artifact (used in relationship graph)
  - `name`: Package name as declared by the package manager
  - `version`: Installed version string
  - `type`: Package ecosystem (`npm`, `python`, `java-archive`, `deb`, `rpm`, `go-module`, etc.)
  - `foundBy`: Cataloger that discovered the package — indicates detection method and confidence
  - `locations[]`: File paths where the package was discovered
  - `licenses[]`: License declarations with SPDX expression where parseable
  - `language`: Programming language ecosystem (`javascript`, `python`, `java`, `go`, etc.)
  - `cpes[]`: CPE identifiers (used by Grype for vulnerability matching)
  - `purl`: Package URL (standard package identifier, used by Grype and SPDX consumers)
  - `metadata`: Package-type-specific metadata (author, description, archive digests, etc.)
- `artifactRelationships[]`: Dependency graph edges between artifacts (parent/child, dependency-of)
- `source`: Scanned target descriptor (directory path, image reference, etc.)
- `distro`: OS distribution detected (relevant for OS package catalogers)

## Normalization

Syft signals are **component inventory records**, not vulnerability findings. Normalization maps package attributes to AEGIS signal fields using license risk as the primary severity driver.

| Syft Field | AEGIS Signal Field | Transformation Logic |
|------------|--------------------|----------------------|
| Derived (sequential) | `signal_id` | Pattern: `S-SYF-{NNN}` (one signal per artifact) |
| Fixed value | `source_tool` | Always "syft" |
| `artifacts[].id` | `source_rule` | Syft artifact ID — stable deduplication key |
| `artifacts[].locations[0].path` | `file_path` | First discovered location path |
| `artifacts[].name` + `artifacts[].version` + `artifacts[].type` | `context` | Format: "{name}@{version} ({type}) — {license_spdx_expression}" |
| Derived from `licenses[].spdxExpression` | `severity` | License risk mapping (see Severity Mapping below) |
| Derived from `foundBy` | `confidence_estimate` | Detection method reliability (see Confidence Mapping below) |
| Derived from `artifactRelationships` depth | `blast_radius` | Dependency depth mapping (see Blast Radius below) |
| Derived from license + package type | `domain_relevance` | License issues → ["05"], dependency tracking → ["04", "05"] |

### Severity Mapping (License-Driven)

Syft severity is determined by license risk, not by vulnerability score. This is the fundamental difference from scanner tool normalization.

| License Category | Examples | Severity |
|-----------------|----------|----------|
| Strong copyleft | GPL-2.0, GPL-3.0, AGPL-3.0 | `high` — potential license compliance obligation |
| Weak copyleft | LGPL-2.1, LGPL-3.0, MPL-2.0, EUPL-1.2 | `medium` — copyleft with limited scope |
| Permissive | MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC | `low` — minimal obligation, attribution only |
| Unknown / missing | (no license declared, NOASSERTION) | `medium` — requires legal review; cannot confirm permissive |
| Proprietary | Proprietary, Commercial, UNLICENSED | `high` — requires explicit rights verification |
| Public domain | Unlicense, CC0-1.0 | `informational` — no restriction |

**Multiple licenses:** Use the highest-risk license in the set.

**No license field:** Treat as `medium` (unknown). Do not assume permissive.

### Confidence Mapping (Detection Method)

Confidence reflects how certain Syft is that the package record is accurate — not how certain a vulnerability assessment is.

| `foundBy` Value | Confidence | Rationale |
|-----------------|------------|-----------|
| `javascript-package-cataloger` | `high` | Lock file or package.json — declarative and exact |
| `python-package-cataloger` | `high` | dist-info/egg-info — installed package metadata |
| `go-module-file-cataloger` | `high` | go.sum — cryptographically verified |
| `java-pom-cataloger` | `high` | pom.xml — declarative dependency manifest |
| `rust-cargo-lock-cataloger` | `high` | Cargo.lock — exact resolved versions |
| `dpkg-db-cataloger` | `high` | System package database — authoritative |
| `rpm-db-cataloger` | `high` | RPM database — authoritative |
| `go-module-binary-cataloger` | `medium` | Binary analysis — reliable but version may lack patch segment |
| `java-archive-cataloger` | `medium` | JAR manifest analysis — may lack pom metadata |
| `binary-cataloger` | `low` | Heuristic binary matching — CPE-based, may misidentify |

### Blast Radius Mapping (Dependency Depth)

Derive blast radius from `artifactRelationships` graph depth and package location:

| Condition | Blast Radius | Rationale |
|-----------|--------------|-----------|
| No parent in relationship graph (direct dependency) | `localized` | Single declared dependency; one change to update |
| One level of indirection (transitive, depth 2) | `moderate` | Removing requires upstream package change |
| Two or more levels of indirection (depth 3+) | `moderate` | Deep transitive; harder to surface and remediate |
| Package appears as parent to many children (hub package) | `widespread` | Changing version impacts many downstream packages |
| Relationship data unavailable | `localized` | Conservative default |

**Hub Package Heuristic**: If an artifact appears as `parent` in 5 or more `artifactRelationships` entries, classify as `widespread` regardless of depth.

### Domain Relevance Assignment

| Signal Condition | Domain Relevance |
|-----------------|-----------------|
| License is copyleft or unknown | `["05"]` (Compliance — license obligation tracking) |
| License is permissive | `["04", "05"]` (Security inventory + Compliance attribution) |
| OS package (type: deb, rpm, apk) | `["04", "05"]` (Attack surface + compliance baseline) |
| No license declared | `["05"]` (Compliance — missing license is a compliance gap) |
| Proprietary license | `["05"]` (Compliance — rights verification required) |

### Deduplication Strategy

- **Key**: `{artifacts[].name}:{artifacts[].version}:{artifacts[].type}`
- **Same package in multiple locations** (e.g., hoisted vs nested in node_modules): Single signal, merge `locations[]` array.
- **Syft artifact ID** (`artifacts[].id`) is stable across runs for the same package — use as dedup key when available.

### Special Cases

- **No license declared**: Do not emit `severity: "informational"`. Emit `severity: "medium"` and flag in `context` as "no license declared — legal review required."
- **NOASSERTION / LicenseRef-scancode-unknown**: Treat same as no license — `severity: "medium"`.
- **Multi-license packages** (e.g., `MIT OR GPL-3.0`): Apply the highest-risk license to severity. Record full expression in `context`.
- **OS packages from distro catalogers**: These represent the runtime environment, not application dependencies. Still emit signals; agents use these to assess attack surface exposure (domain 04).
- **CPE present but purl absent**: Acceptable — CPE enables Grype matching. Note in `context`.
- **Grype integration note**: Syft SBOM output (cyclonedx-json or syft-json) is passed directly to Grype for vulnerability enrichment. AEGIS agents should correlate Syft `purl` values with Grype findings using `PkgIdentifier.PURL` for cross-tool signal linkage.

## Limitations

### Cannot Detect

1. **Unlisted Dependencies Loaded at Runtime**: Packages fetched dynamically (via `require()` with a computed string, `importlib.import_module()` with a variable, or `dlopen()`), plugin systems that load packages by name from configuration, and lazy-loading patterns that bypass static manifest declaration are invisible to Syft catalogers.

2. **Dependencies Installed Outside Package Manager**: Libraries installed via system commands, custom build scripts, or `make install` that do not register with dpkg, rpm, or a language package manager leave no metadata for Syft to discover.

3. **Embedded or Vendored Source Code**: Third-party code copied directly into the repository as source files (not as a package) is not detected. There is no manifest or dist-info; Syft sees only files, not a package record.

4. **Obfuscated or Compressed Binaries**: Pre-built binary blobs where version and provenance information has been stripped or obfuscated cannot be matched to known package identifiers, even by the binary cataloger.

5. **Custom Internal Packages Without Standard Metadata**: Internally developed libraries distributed as tarballs or copied directories without a valid `package.json`, `setup.py`, `pom.xml`, or equivalent manifest are not cataloged.

6. **License Text Not in Standard Locations**: Licenses embedded only in source file headers, custom license files with non-standard names, or licenses inherited from parent projects without local declaration may not be detected or may surface as NOASSERTION.

7. **Runtime Configuration of License Terms**: Some packages ship with multiple license options (dual-licensed) where the applicable license is selected at build or deploy time. Syft catalogs the declared options but cannot determine which license is in effect for a given deployment.

### Known False Positives

1. **Development and Test Dependencies Treated as Production Risk**: Syft catalogs all packages regardless of whether they appear in `devDependencies`, test fixtures, or build tooling. License risk flags on test-only packages overstate the compliance exposure for production deployments.

2. **Multiple Copies of the Same Package at Different Versions**: Node.js dependency hoisting failures produce multiple `node_modules` subtrees with different versions of the same library. Syft emits a record for each, creating duplicate-looking signals that represent the same logical dependency.

3. **OS Package Duplicates from Layer Analysis**: When scanning container images in `all-layers` mode, packages installed and then modified or replaced in later layers appear multiple times. Use `squashed` scope to collapse layer duplicates.

4. **CPE Misidentification by Binary Cataloger**: The binary cataloger uses heuristic pattern matching against CPE dictionaries. Version strings embedded in binaries may match multiple CPE entries, producing false package identity attributions for compiled artifacts.

5. **Vendored Copies Reporting Stale Versions**: Some projects vendor dependencies and patch them locally without updating the version string in the manifest. Syft catalogs the declared version (which may be several patches behind), producing records that Grype will flag as vulnerable even though the patch is already applied in the vendored copy.

### Known False Negatives

1. **Transitive Dependencies Not Resolved in Manifest**: Lock files for some ecosystems (particularly pip without a pinned lockfile, or Maven without a dependency:tree export) do not include all transitive dependencies. Syft catalogs only what is resolvable from present manifests — unresolved transitive packages are absent from the SBOM.

2. **Packages Installed After Image Build (Sideloaded)**: Dependencies installed into a running container at runtime (e.g., via a startup script or init container that calls `apt-get install` or `pip install`) are not present in the image layers Syft scans and will not appear in the SBOM.

3. **Go Binaries Built Without Module Information**: Go binaries compiled with `-trimpath` and no embedded build info strip the module metadata that the `go-module-binary-cataloger` relies on. These binaries appear opaque to Syft.

4. **npm Packages Without a Lock File**: Projects using npm without a committed `package-lock.json` or `yarn.lock` are cataloged from `package.json` alone. Nested transitive dependencies that only appear in the lock file are absent.

5. **License Inheritance From Parent Projects**: Many packages declare their license only at the monorepo or parent pom level, with individual submodules inheriting it implicitly. If the submodule manifest omits the license field, Syft records NOASSERTION for that submodule even though a license exists at the parent level.

6. **Packages Declared in Non-Standard Manifest Formats**: Some build systems use custom manifest formats (Bazel BUILD files, Pants targets, Buck BUCK files) that Syft has no cataloger for. Dependencies managed exclusively through these systems will not appear in the SBOM.
