---
id: domain-06
number: "06"
name: Testing Strategy & Verification
owner_agents: [test-engineer]
---

## Overview

This domain addresses test pyramid shape, determinism, coverage gaps, mutation resistance, contract testing, and failure path coverage. Senior engineers recognize that tests are the primary defense against regressions and the most reliable form of system documentation. The central question is: "Would these tests catch the most expensive failures?" This domain does NOT cover code correctness implementation details (domain 03), security vulnerability scanning (domain 04), or deployment verification and operational monitoring (domain 10).

## Audit Questions

- Does the test suite follow the test pyramid principle (many unit tests, fewer integration tests, minimal E2E tests)?
- Are tests deterministic and free from flakiness, or do they exhibit intermittent failures due to timing, concurrency, or external dependencies?
- What critical user flows, edge cases, or error paths are NOT covered by existing tests?
- Does the codebase include mutation testing or property-based testing to verify test effectiveness beyond line coverage?
- Are contract tests in place for external API integrations, microservice boundaries, or third-party dependencies?
- Do tests serve as executable documentation, clearly communicating expected behavior to future maintainers?
- Are failure paths (error handling, timeouts, invalid inputs) tested as rigorously as success paths?
- How is test data managed—does it rely on brittle fixtures, or are factories and builders used for flexible test setup?
- Are tests isolated from each other, or do they share state that causes order-dependent failures?
- Can the test suite run in parallel without race conditions or resource contention?
- Are slow tests (>1s for unit, >10s for integration) identified and optimized or moved to appropriate test layers?
- Does the CI pipeline fail fast on test failures with clear error messages and reproducible failure artifacts?

## Failure Patterns

### Inverted Test Pyramid
- **Description:** Test suite contains disproportionately more end-to-end or integration tests than unit tests, leading to slow feedback loops, brittle tests, and high maintenance costs. The test pyramid (Fowler) recommends a broad base of fast unit tests with fewer higher-level tests.
- **Indicators:**
  - Test execution time exceeds 10 minutes for a full run, with most time spent in browser automation or API integration tests
  - Test count ratio shows more E2E tests than unit tests (e.g., 200 E2E, 50 unit tests)
  - Test files primarily use frameworks like Selenium, Cypress, or Playwright rather than unit testing frameworks (Jest, pytest, JUnit)
  - Business logic embedded in controllers, views, or API handlers is untested in isolation
  - Developers skip running full test suite locally due to time constraints, relying solely on CI
- **Severity Tendency:** high

### Flaky Tests
- **Description:** Tests exhibit intermittent failures unrelated to code changes, caused by timing issues, race conditions, external service dependencies, or shared state. Flaky tests erode trust and force developers to re-run CI pipelines repeatedly.
- **Indicators:**
  - Test suite failures occur in CI but pass when re-run without code changes
  - Tests use `sleep()`, `setTimeout()`, or fixed delays instead of explicit waits for asynchronous operations
  - Tests depend on external services (third-party APIs, staging databases) without mocking or stubbing
  - Test execution order affects outcomes—tests pass individually but fail when run as a suite
  - Tests rely on system clock, random number generators, or filesystem state without deterministic seeding
- **Severity Tendency:** medium

### Missing Failure Path Tests
- **Description:** Test suite validates success paths (happy paths) but omits error handling, edge cases, invalid inputs, timeouts, and exception scenarios. Production failures occur in untested error paths.
- **Indicators:**
  - Code coverage reports show high line coverage but low branch coverage (missing else/catch blocks)
  - Error handling blocks (`try/except`, `catch`, `if err != nil`) lack corresponding test cases
  - API tests only verify HTTP 200 responses, ignoring 400/401/403/404/500 error conditions
  - Timeout and retry logic in HTTP clients, database connections, or message queues is untested
  - Validation logic for user inputs or API payloads lacks test cases for malformed, missing, or boundary-exceeding values
- **Severity Tendency:** high

### Tautological Tests
- **Description:** Tests verify implementation details rather than behavior, or pass trivially by asserting the same logic as production code. These tests provide false confidence and fail to catch regressions when refactoring.
- **Indicators:**
  - Tests directly inspect private methods, internal state, or implementation-specific data structures
  - Test assertions duplicate production logic (e.g., `assert result == calculate_tax(input)` where `calculate_tax` is the function under test)
  - Mocks or stubs return hardcoded values that match expected outputs without verifying logic correctness
  - Tests pass even after intentionally introducing bugs (mutation testing would reveal ineffective assertions)
  - Refactoring code without changing behavior causes test failures due to tightly coupled test-implementation binding
- **Severity Tendency:** medium

### No Contract Tests
- **Description:** System lacks contract tests for external API integrations, microservice boundaries, or third-party dependencies. Schema changes or breaking API updates cause production failures without advance warning.
- **Indicators:**
  - No consumer-driven contract tests (Pact, Spring Cloud Contract) for microservice interactions
  - API integration tests mock external services without verifying mock responses match real API behavior
  - OpenAPI/Swagger schemas are not validated against live API responses in tests
  - Database schema migrations lack rollback tests or compatibility verification with existing application code
  - Third-party SDK version upgrades cause runtime errors despite passing test suite
- **Severity Tendency:** high

### Untested Critical Paths
- **Description:** Core business logic, revenue-generating flows, or safety-critical functionality lacks comprehensive test coverage. High-impact failures occur in features assumed to be reliable.
- **Indicators:**
  - Payment processing, checkout flows, or subscription management lack end-to-end test coverage
  - Authentication, authorization, or access control logic is tested only manually or via ad-hoc scripts
  - Data migration scripts, batch processing jobs, or cron tasks have no automated tests
  - Admin tools, internal dashboards, or operational scripts bypass test suite due to "internal use only" rationale
  - Features flagged as "critical" in incident postmortems lack corresponding test coverage improvements
- **Severity Tendency:** critical

### Shallow Mocking
- **Description:** Tests over-mock dependencies, isolating units to the point of testing trivial logic while ignoring integration failures. Mocks do not verify realistic interactions or return representative data.
- **Indicators:**
  - Every external dependency (database, HTTP client, file system) is mocked in all tests, with no integration tests
  - Mocks return empty arrays, null values, or unrealistic stub data that would never occur in production
  - Mock verification checks call counts (`verify(mock, times(1)).method()`) without asserting argument correctness
  - Tests pass with all dependencies mocked, but integration tests or staging deployments reveal compatibility issues
  - Refactoring internal method calls causes widespread test failures despite no behavior changes
- **Severity Tendency:** medium

## Best Practice Patterns

### Balanced Test Pyramid
- **Replaces Failure Pattern:** Inverted Test Pyramid
- **Abstract Pattern:** Structure test suite with a broad base of fast, isolated unit tests (70%), moderate integration tests (20%), and minimal end-to-end tests (10%). Optimize feedback speed while maintaining confidence in system behavior.
- **Framework Mappings:**
  - **Jest (JavaScript/TypeScript):** Write unit tests with `jest.fn()` mocks for dependencies, integration tests using `supertest` for API routes, and E2E tests with Playwright for critical user flows.
  - **pytest (Python):** Use `pytest` with `unittest.mock` for unit tests, `pytest-flask` or `httpx` for integration tests, and `playwright-pytest` for E2E validation.
  - **JUnit 5 (Java):** Apply `@Test` annotations for unit tests with Mockito, `@SpringBootTest` for integration tests, and Selenium/TestContainers for E2E scenarios.
- **Language Patterns:**
  - **TypeScript:** Separate test files by layer (`*.unit.test.ts`, `*.integration.test.ts`, `*.e2e.test.ts`) with distinct Jest configurations for parallelization and timeouts.
  - **Python:** Use pytest markers (`@pytest.mark.unit`, `@pytest.mark.integration`) to selectively run test subsets in CI stages.
  - **Go:** Leverage `testing` package with build tags (`//go:build integration`) to separate unit tests from integration tests.

### Deterministic Test Design
- **Replaces Failure Pattern:** Flaky Tests
- **Abstract Pattern:** Eliminate non-determinism by mocking external dependencies, using explicit waits for async operations, seeding random generators, and isolating test state. Ensure tests produce identical results on every run.
- **Framework Mappings:**
  - **Cypress:** Use `cy.intercept()` to stub network requests, `cy.wait('@alias')` for explicit asynchronous waits, and `cy.clock()` to control time-dependent behavior.
  - **pytest:** Apply `freezegun` to mock `datetime.now()`, `responses` or `httpx_mock` for HTTP requests, and `pytest-randomly` with fixed seeds for reproducible test order.
  - **Testcontainers:** Use containerized databases (PostgreSQL, MongoDB) with `@Container` annotations to ensure clean state per test run without relying on external services.
- **Language Patterns:**
  - **JavaScript:** Use `jest.useFakeTimers()` to control async callbacks, `nock` for HTTP mocking, and `uuid.v4 = jest.fn(() => 'fixed-uuid')` for deterministic ID generation.
  - **Python:** Apply `unittest.mock.patch()` to replace `random.choice`, `uuid.uuid4`, or `requests.get` with deterministic stubs.
  - **Java:** Use `@MockBean` in Spring Boot tests to inject mocked dependencies, `WireMock` for HTTP service stubs, and `Clock.fixed()` for time-dependent logic.

### Comprehensive Failure Path Coverage
- **Replaces Failure Pattern:** Missing Failure Path Tests
- **Abstract Pattern:** Explicitly test error handling, timeouts, retries, invalid inputs, and exception scenarios. Verify that failure modes degrade gracefully and produce actionable error messages.
- **Framework Mappings:**
  - **pytest:** Use `pytest.raises(ExceptionType)` to assert expected exceptions, `pytest.mark.parametrize` for boundary value testing, and `pytest-timeout` to verify timeout handling.
  - **Jest:** Apply `.rejects.toThrow()` for promise rejections, `expect(fn).toThrow(ErrorClass)` for synchronous errors, and `jest.advanceTimersByTime()` to trigger timeout logic.
  - **JUnit 5:** Use `@Test(expected = Exception.class)` or `assertThrows()` for exception validation, `@ParameterizedTest` for edge cases, and `@Timeout` for performance boundaries.
- **Language Patterns:**
  - **Python:** Test exception paths with `with pytest.raises(ValueError, match="expected message"):` and parametrize edge cases (`@pytest.mark.parametrize("input", [None, "", -1, sys.maxsize])`).
  - **TypeScript:** Validate error responses with `expect(response.status).toBe(400)` and assert error payloads match API schema definitions.
  - **Go:** Use `if err != nil` assertions in tests, table-driven tests for invalid inputs, and `context.WithTimeout()` to verify timeout handling.

### Behavioral Test Assertions
- **Replaces Failure Pattern:** Tautological Tests
- **Abstract Pattern:** Test observable behavior and contracts rather than implementation details. Assert on outputs, side effects, and interactions without depending on internal state or private methods.
- **Framework Mappings:**
  - **RSpec (Ruby):** Use `expect(result).to eq(expected_value)` rather than inspecting private instance variables, and `have_received(:method).with(args)` for interaction verification.
  - **pytest:** Apply `assert` statements on public API outputs, `mock.assert_called_once_with(args)` for behavior verification, and `capsys` to validate stdout/stderr.
  - **Jest:** Use `.toHaveBeenCalledWith(args)` for mock verification, snapshot testing for complex output structures, and `.toMatchObject()` for partial assertion flexibility.
- **Language Patterns:**
  - **Python:** Test public methods with `assert service.process(input) == expected_output` rather than `assert service._internal_state == value`.
  - **JavaScript:** Verify API responses with `expect(response.body).toEqual({ key: "value" })` without asserting on controller internal variables.
  - **Java:** Use AssertJ fluent assertions (`assertThat(result).isNotNull().hasFieldOrPropertyWithValue("status", "success")`) focused on outcomes.

### Consumer-Driven Contract Testing
- **Replaces Failure Pattern:** No Contract Tests
- **Abstract Pattern:** Verify API contracts between services using consumer-driven tests or schema validation. Ensure producers and consumers agree on request/response formats, preventing integration failures.
- **Framework Mappings:**
  - **Pact (Polyglot):** Define consumer expectations with `pact.given().uponReceiving().withRequest().willRespondWith()`, publish contracts to Pact Broker, and verify provider compliance.
  - **Spring Cloud Contract:** Use Groovy DSL to define contracts in producer repos, generate WireMock stubs for consumers, and validate contracts in provider CI pipelines.
  - **OpenAPI Validator:** Apply `openapi-validator` or `schemathesis` to test live API responses against OpenAPI schemas in integration tests.
- **Language Patterns:**
  - **Python:** Use `pact-python` to define consumer expectations, publish to broker, and verify provider with `pytest-pact`.
  - **JavaScript:** Apply `@pact-foundation/pact` to generate consumer contracts, integrate with Jest, and validate provider endpoints in CI.
  - **Java:** Use `@PactTestFor` annotations with JUnit 5 to define consumer tests and `@Provider` to verify producer compliance.

### Critical Path Test Prioritization
- **Replaces Failure Pattern:** Untested Critical Paths
- **Abstract Pattern:** Identify high-impact business flows through risk analysis and ensure comprehensive test coverage for revenue-generating, safety-critical, or frequently used features. Prioritize test development based on failure cost.
- **Framework Mappings:**
  - **Cypress (E2E):** Create dedicated test suites for checkout, authentication, and payment flows with `describe("Critical: Checkout Flow")` naming conventions.
  - **pytest:** Use `@pytest.mark.critical` to tag high-priority tests, configure CI to fail fast on critical test failures, and track coverage separately for critical modules.
  - **Postman/Newman:** Maintain integration test collections for critical API endpoints, run in CI with `newman run critical-flows.json`, and alert on failures.
- **Language Patterns:**
  - **Python:** Apply coverage reports with `--cov-report=html --cov-fail-under=90` specifically for critical modules (e.g., `payment/`, `auth/`).
  - **TypeScript:** Use custom Jest reporters to highlight coverage gaps in critical paths, integrated with PR comments via CI.
  - **Go:** Leverage `go test -coverprofile` with manual review of untested lines in critical packages (`auth`, `billing`, `encryption`).

### Realistic Integration Testing
- **Replaces Failure Pattern:** Shallow Mocking
- **Abstract Pattern:** Balance unit tests (isolated with mocks) and integration tests (real dependencies) to verify component interactions. Use test doubles that accurately represent production behavior.
- **Framework Mappings:**
  - **Testcontainers:** Spin up ephemeral Docker containers (PostgreSQL, Redis, Kafka) for integration tests, ensuring realistic database queries and message queue interactions.
  - **Spring Boot `@DataJpaTest`:** Use embedded H2 or Testcontainers PostgreSQL for repository layer tests with real SQL execution and transaction management.
  - **SuperTest (Node.js):** Test Express/Fastify routes with real middleware and database connections, mocking only external third-party APIs.
- **Language Patterns:**
  - **Python:** Use `pytest-docker` or `testcontainers-python` to provision databases, apply real ORM queries (SQLAlchemy, Django ORM), and validate transaction rollback.
  - **Java:** Apply `@SpringBootTest(webEnvironment = RANDOM_PORT)` with Testcontainers for full integration tests, verifying Hibernate entity mappings and transaction boundaries.
  - **Go:** Use `dockertest` to start PostgreSQL containers, run migrations with `golang-migrate`, and execute integration tests with real `database/sql` connections.

## Red Flags

- Test suite execution exceeds 10 minutes with majority of time in browser automation or E2E tests
- CI pipelines frequently re-run due to intermittent test failures without code changes
- Code coverage reports show high line coverage (>80%) but low branch coverage (<50%)
- Error handling blocks (`try/catch`, `if err != nil`) lack corresponding test files
- No tests for authentication, payment processing, or data migration scripts
- Mocks return empty arrays, `null`, or hardcoded stubs without realistic data
- Tests depend on external staging environments or third-party APIs without fallback stubs
- Test files import production code private methods or internal modules
- No contract tests for microservice boundaries or external API integrations
- Developers skip running tests locally due to flakiness or execution time, relying solely on CI

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| SonarQube | Test coverage metrics, branch coverage, code duplication in tests | primary |
| git-history | Test file churn, deleted tests without replacement, coverage trends over time | supporting |
| Semgrep | Insecure test patterns (hardcoded credentials, disabled SSL verification) | contextual |
| Trivy | Vulnerabilities in test dependencies (vulnerable test frameworks, outdated mocking libraries) | contextual |

## Standards & Frameworks

- **Test Pyramid (Martin Fowler):** Broad base of unit tests, moderate integration tests, minimal E2E tests for fast feedback and maintainability
- **Testing Trophy (Kent C. Dodds):** Emphasizes integration tests as the most cost-effective layer, with supporting unit and E2E tests
- **Test-Driven Development (TDD):** Red-green-refactor cycle ensuring tests drive design and validate behavior before implementation
- **Property-Based Testing:** Hypothesis (Python), fast-check (JavaScript), QuickCheck (Haskell) for generative testing of invariants
- **Mutation Testing:** Stryker (JavaScript), mutmut (Python), PIT (Java) to verify test suite effectiveness by introducing code mutations
- **Behavior-Driven Development (BDD):** Cucumber/Gherkin for specification by example, linking user stories to executable tests
- **Consumer-Driven Contracts:** Pact, Spring Cloud Contract for verifying API compatibility across service boundaries

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Test Coverage (Line) | Percentage of codebase executed during test runs | ≥80% for critical paths, ≥70% overall |
| Test Coverage (Branch) | Percentage of conditional branches (if/else) covered by tests | ≥75% |
| Test-to-Code Ratio | Lines of test code divided by lines of production code | 1:1 to 2:1 (varies by domain) |
| Test Execution Time | Duration of full test suite run (unit + integration + E2E) | <5 minutes for unit, <10 minutes total |
| Flaky Test Rate | Percentage of tests with intermittent failures over 30-day period | <1% |
| Mutation Score | Percentage of introduced code mutations detected by test suite (mutation testing) | ≥75% |
| Critical Path Coverage | Percentage of revenue-generating or safety-critical features with comprehensive test coverage | 100% |
| Test Pyramid Ratio | Distribution of tests (unit:integration:E2E) | 70:20:10 or 60:30:10 |
