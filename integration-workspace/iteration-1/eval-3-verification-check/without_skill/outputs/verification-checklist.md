# Verification Checklist

An agent claims: "Implementation is complete. All tests pass."

Before accepting this claim, every check below must be verified with the stated evidence.

---

## 1. BDD Scenario Coverage (features/booking.feature)

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 1.1 | All 5 BDD scenarios have passing step definitions | Test runner output (e.g., Cucumber, Behave) showing 5 scenarios, 0 failures, 0 pending, 0 undefined |
| 1.2 | No steps are marked pending or undefined | Zero "pending" or "undefined" steps in the test output |
| 1.3 | Step definition files exist for every step in the 5 scenarios | Source files in a step_definitions directory with matching step patterns for each Given/When/Then |
| 1.4 | Scenarios exercise actual implementation code, not stubs | Step definitions call real service/domain code, not hardcoded return values or no-op stubs |

---

## 2. Quality Scenario Test Execution (quality-scenarios.md)

### 2a. Unit Tests (3 scenarios)

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 2.1 | All 3 unit-test quality scenarios have corresponding test files | Three identifiable test files or test classes, each traceable to a quality scenario |
| 2.2 | All 3 unit tests pass | Test runner output showing 3 passing unit tests with names matching the quality scenarios |
| 2.3 | Tests assert the quality attribute, not just functionality | Assertions target response time thresholds, error rates, resource limits, or other non-functional measures stated in the scenarios |

### 2b. Integration Tests (4 scenarios)

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 2.4 | All 4 integration-test quality scenarios have corresponding test files | Four identifiable integration test files or test classes, each traceable to a quality scenario |
| 2.5 | All 4 integration tests pass | Test runner output showing 4 passing integration tests with names matching the quality scenarios |
| 2.6 | Integration tests exercise real component boundaries | Tests interact with actual databases, APIs, or service layers -- not mocked-out replacements for the integration points under test |
| 2.7 | Test infrastructure is documented or scripted | A docker-compose.yml, test configuration, or README explaining how to run integration tests reproducibly |

### 2c. Load Tests (2 scenarios)

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 2.8 | All 2 load-test quality scenarios have corresponding test scripts | Two load test scripts (e.g., k6, Gatling, Locust, JMeter) each traceable to a quality scenario |
| 2.9 | Load tests were actually executed | Load test result files with timestamps, showing throughput, latency percentiles, and error rates |
| 2.10 | Load test results meet the thresholds stated in quality-scenarios.md | Numeric evidence that measured values (e.g., p95 latency, requests/sec) satisfy scenario thresholds |
| 2.11 | Load test parameters match scenario definitions | Concurrent users, duration, and ramp-up match what quality-scenarios.md specifies |

### 2d. Manual Review (1 scenario)

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 2.12 | The manual-review scenario has a documented review procedure | A checklist or runbook describing what to inspect and acceptance criteria |
| 2.13 | The manual review was performed and recorded | A signed-off review document or log entry with reviewer name, date, findings, and pass/fail verdict |

---

## 3. Architecture Fitness Functions (architecture.md)

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 3.1 | Every fitness function defined in architecture.md has an automated check | One executable test or script per fitness function, runnable from the command line |
| 3.2 | All fitness function checks pass | Test runner or script output showing each fitness function evaluated with a pass result |
| 3.3 | Fitness functions are integrated into CI or a run script | A CI pipeline config or Makefile/script target that executes all fitness functions together |
| 3.4 | Fitness function thresholds match architecture.md definitions | The threshold values in test code exactly match those documented in architecture.md |

---

## 4. Traceability

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 4.1 | Every quality scenario maps to at least one test | A traceability matrix or naming convention linking each of the 10 quality scenarios to its test(s) |
| 4.2 | Every BDD scenario maps to implemented functionality | Each of the 5 booking.feature scenarios exercises a code path in the production codebase |
| 4.3 | Fitness functions trace back to quality attributes in architecture.md | Each fitness function references the architectural decision or quality attribute it guards |

---

## 5. Build and Environment

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 5.1 | The project builds without errors from a clean checkout | Output of a clean build command (e.g., `npm install && npm run build`, `mvn clean package`) with zero errors |
| 5.2 | All test suites can be run with a single command or documented steps | A `npm test`, `make test`, or equivalent that executes unit + integration + BDD tests and reports results |
| 5.3 | No tests are skipped, ignored, or commented out | Test output shows zero skipped; grep for `@Ignore`, `skip`, `xit`, `xdescribe`, `.skip`, `pending` returns no hits in test files |
| 5.4 | No hardcoded test passes (e.g., `assert(true)`, empty test bodies) | Code review of test files confirms every test contains meaningful assertions against production behavior |

---

## 6. Completeness Cross-Check

| # | Check | Expected Evidence |
|---|-------|-------------------|
| 6.1 | Total test count matches expectations | At minimum: 5 BDD scenarios + 3 unit tests + 4 integration tests + 2 load tests + 1 manual review = 15 verification points |
| 6.2 | No quality scenario is unaddressed | Each of the 10 quality scenarios in quality-scenarios.md has a corresponding verification artifact |
| 6.3 | No fitness function is unaddressed | Each fitness function in architecture.md has a corresponding automated check |

---

## Summary

**Minimum artifacts required to accept the claim:**

1. Test runner output proving 5/5 BDD scenarios pass with zero undefined/pending steps
2. Test runner output proving 3/3 unit-test quality scenarios pass
3. Test runner output proving 4/4 integration-test quality scenarios pass
4. Load test result reports for 2/2 load-test scenarios with threshold comparisons
5. Signed manual review record for 1/1 manual-review scenario
6. Fitness function execution output showing all pass
7. Clean build from scratch with zero errors and zero skipped tests

If any of these artifacts are missing or show failures, the claim "Implementation is complete. All tests pass." cannot be accepted.
