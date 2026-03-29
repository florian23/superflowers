# Quality Scenarios

Generated from architecture.md quality goals using ATAM.

## Last Updated: 2026-03-29

## Scenario Summary

| ID | Characteristic | Scenario | Test Type | Priority |
|----|---------------|----------|-----------|----------|
| QS-001 | Simplicity | New developer onboarding within 1 week | manual-review | Critical |
| QS-002 | Simplicity | Module has self-contained README and runnable example | manual-review | Critical |
| QS-003 | Testability | Single module test suite runs independently | fitness-function | Critical |
| QS-004 | Testability | Test setup requires no external services | unit-test | Critical |
| QS-005 | Maintainability | Code change in one module requires no changes in others | integration-test | Critical |
| QS-006 | Maintainability | New developer finds and fixes a bug within 2 hours | manual-review | Critical |
| QS-007 | Security | Unauthorized user denied access to protected endpoint | integration-test | Important |
| QS-008 | Security | Every data access operation produces audit log entry | integration-test | Important |
| QS-009 | Availability | System available during business hours under normal load | integration-test | Nice-to-have |

## Test Type Distribution

| Test Type | Count | Scenarios |
|-----------|-------|-----------|
| unit-test | 1 | QS-004 |
| integration-test | 4 | QS-005, QS-007, QS-008, QS-009 |
| load-test | 0 | — |
| chaos-test | 0 | — |
| fitness-function | 1 | QS-003 |
| manual-review | 3 | QS-001, QS-002, QS-006 |

## Scenarios

### Simplicity

#### QS-001: New Developer Onboarding
- **Characteristic:** Simplicity
- **Source:** New developer joining the team
- **Stimulus:** Developer clones repo, reads docs, attempts first task
- **Environment:** Fresh development machine, no prior project knowledge
- **Artifact:** Project documentation, module structure, dev setup scripts
- **Response:** Developer completes setup and delivers first small change
- **Response Measure:** First productive contribution within 5 working days
- **Test Type:** manual-review

#### QS-002: Module Self-Documentation
- **Characteristic:** Simplicity
- **Source:** Developer unfamiliar with a specific module
- **Stimulus:** Developer needs to understand module purpose and API
- **Environment:** Normal development, no access to original author
- **Artifact:** Each module's public API and documentation
- **Response:** Developer understands module purpose and can use its API correctly
- **Response Measure:** Each module has a README with purpose, public API description, and at least one usage example
- **Test Type:** manual-review

### Testability

> Note: The coverage gate fitness function (>90% coverage) is already defined in architecture.md. No duplicate scenario created.

#### QS-003: Independent Module Test Suites
- **Characteristic:** Testability
- **Source:** CI pipeline
- **Stimulus:** Run test suite for a single module
- **Environment:** CI environment, only the target module's dependencies available
- **Artifact:** Each module's test suite
- **Response:** Tests pass without requiring other modules to be loaded or running
- **Response Measure:** Every module's test suite executes successfully in isolation (0 cross-module test dependencies)
- **Test Type:** fitness-function

#### QS-004: No External Service Dependencies in Unit Tests
- **Characteristic:** Testability
- **Source:** Developer running tests locally
- **Stimulus:** Execute unit test suite
- **Environment:** Local development machine, no Docker, no external services
- **Artifact:** Unit test suite
- **Response:** All unit tests pass without network calls or external service dependencies
- **Response Measure:** Unit test suite runs in <30 seconds with zero network calls
- **Test Type:** unit-test

### Maintainability

> Note: The complexity check fitness function (no function >50 lines, cyclomatic complexity <10) is already defined in architecture.md. No duplicate scenario created.

#### QS-005: Module Change Isolation
- **Characteristic:** Maintainability
- **Source:** Developer making a change to internal module logic
- **Stimulus:** Internal implementation change within one module (not public API)
- **Environment:** Normal development
- **Artifact:** Module internals, cross-module integration points
- **Response:** Change requires no modifications in other modules
- **Response Measure:** Internal change to module X causes 0 test failures in modules Y, Z
- **Test Type:** integration-test

#### QS-006: Bug Diagnosis Speed
- **Characteristic:** Maintainability
- **Source:** Developer investigating a reported bug
- **Stimulus:** Bug report with reproduction steps
- **Environment:** Normal development, existing codebase
- **Artifact:** Application code, logs, module boundaries
- **Response:** Developer locates root cause and implements fix
- **Response Measure:** Average time from bug report to fix under 2 hours for non-complex bugs
- **Test Type:** manual-review

### Security

> Note: The auth test fitness function is already defined in architecture.md for basic RBAC checks.

#### QS-007: RBAC Enforcement on Protected Endpoints
- **Characteristic:** Security
- **Source:** Authenticated user with insufficient role
- **Stimulus:** HTTP request to endpoint requiring higher privilege
- **Environment:** Normal operation, authentication system active
- **Artifact:** API endpoints with role-based access control
- **Response:** System returns 403 Forbidden, logs the access attempt
- **Response Measure:** 100% of protected endpoints return 403 for unauthorized roles; 0 data leakage
- **Test Type:** integration-test

#### QS-008: Audit Log Completeness
- **Characteristic:** Security
- **Source:** Any authenticated user performing data operations
- **Stimulus:** CREATE, READ, UPDATE, or DELETE operation on compliance data
- **Environment:** Normal operation
- **Artifact:** Audit logging subsystem, database
- **Response:** System writes audit log entry with user ID, timestamp, operation type, and affected record
- **Response Measure:** 100% of data access operations produce an audit log entry; audit log contains user, timestamp, action, and record ID
- **Test Type:** integration-test

### Availability

#### QS-009: Business Hours Availability
- **Characteristic:** Availability
- **Source:** Internal users accessing the compliance tool
- **Stimulus:** Standard HTTP requests during business hours (Mon-Fri 08:00-18:00)
- **Environment:** Normal load (~50 concurrent users)
- **Artifact:** Application health endpoint, full application stack
- **Response:** System responds successfully
- **Response Measure:** 99% of requests return successful response (2xx) during business hours, measured weekly
- **Test Type:** integration-test

## Tradeoffs and Sensitivity Points

### Tradeoff: Audit Logging vs. Simplicity
- **Tension:** Security (QS-008 — audit log for all data access) vs. Simplicity (QS-001 — new dev productive quickly)
- **Scenarios affected:** QS-001, QS-008
- **Decision needed:** Audit logging adds cross-cutting complexity. Use a simple aspect/middleware pattern to keep it invisible to module developers. Avoid requiring developers to manually add audit calls — that kills simplicity and creates coverage gaps.

### Tradeoff: Testability Isolation vs. Audit Log Coverage
- **Tension:** Testability (QS-004 — no external dependencies in unit tests) vs. Security (QS-008 — audit log completeness)
- **Scenarios affected:** QS-004, QS-008
- **Decision needed:** Audit logging needs a persistence layer (DB or file), which unit tests should not depend on. Solution: audit logger should be injectable/mockable in unit tests but verified with real persistence in integration tests.

### Sensitivity Point: Module Boundary Granularity
- **Parameter:** Number and size of modules in the monolith
- **Affects:** QS-003 (too many small modules = more isolation overhead), QS-005 (too few large modules = changes ripple internally), QS-002 (each module needs documentation)
- **Current setting:** Not yet defined — the team should target 3-7 modules for a 2-person team to keep documentation and testing overhead manageable.
