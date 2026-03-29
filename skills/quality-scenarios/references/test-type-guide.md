# Test Type Decision Guide

How to classify a quality scenario into the right test type.

## Decision Tree

```
Does this scenario test a STRUCTURAL invariant
(dependency direction, module boundaries, code metrics)?
  → Yes: fitness-function
  → No: ↓

Does this scenario need a RUNNING SYSTEM to test?
  → No: Can it be tested with a single component in isolation?
    → Yes: unit-test
    → No: fitness-function (static analysis)
  → Yes: ↓

Does this scenario test behavior under VOLUME or STRESS?
  → Yes: Is it about failure/resilience?
    → Yes: chaos-test
    → No: load-test
  → No: ↓

Does this scenario cross component/service BOUNDARIES?
  → Yes: integration-test
  → No: ↓

Does this scenario require HUMAN JUDGMENT?
  → Yes: manual-review
  → No: integration-test (default for running-system scenarios)
```

## Examples Per Characteristic

### Performance
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| API < 200ms p95 | 1000 users hit /search concurrently | load-test | Needs running system under volume |
| DB query < 50ms | Single query with 1M rows | integration-test | Needs real DB but not volume stress |
| Algorithm O(n log n) | Sort 100k items in < 100ms | unit-test | Single component, no dependencies |

### Availability
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| 99.9% uptime | Health check returns 200 every 30s | integration-test | Needs running system |
| Survives node failure | Kill 1 of 3 replicas, system continues | chaos-test | Resilience under failure |
| Graceful degradation | External API timeout, return cached data | integration-test | Cross-component behavior |

### Security
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| No known CVEs | Dependency scan finds 0 critical CVEs | fitness-function | Static analysis, no running system |
| RBAC enforced | Unauthorized user gets 403 | integration-test | Needs auth system running |
| Input validation | SQL injection attempt is rejected | unit-test | Single component validation |
| Penetration test | OWASP Top 10 audit | manual-review | Requires expert judgment |

### Scalability
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| Handle 100k concurrent | Ramp from 1k to 100k users | load-test | Volume stress |
| Horizontal scaling | Add 3 nodes, throughput increases linearly | load-test + chaos-test | Volume + infrastructure |
| No single point of failure | Any single component can fail | chaos-test | Resilience |

### Testability
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| > 80% coverage | Coverage report shows > 80% | fitness-function | Static metric |
| All modules testable independently | Each module has standalone test suite | fitness-function | Structural check |
| Integration tests exist for all APIs | Every API endpoint has at least 1 test | fitness-function | Structural check |

### Maintainability
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| Cyclomatic complexity < 10 | No function exceeds threshold | fitness-function | Static analysis |
| No function > 50 lines | LOC check per function | fitness-function | Static analysis |
| New dev productive in 1 week | Developer onboarding review | manual-review | Subjective |

### Data Integrity
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| No data loss during failures | Kill DB during write, verify all data persists | chaos-test | Resilience |
| Consistent across replicas | Write to primary, read from replica within 5s | integration-test | Cross-component |
| Referential integrity | Delete parent, verify cascade/reject | unit-test or integration-test | Depends on where enforced |

### Usability / Accessibility
| Goal | Scenario | Test Type | Why |
|------|----------|-----------|-----|
| WCAG 2.1 AA | Automated accessibility scan | fitness-function (partial) + manual-review | Automated catches ~30%, human catches the rest |
| Mobile responsive | All pages render correctly on 375px viewport | integration-test | Needs running UI |
| Screen reader compatible | Full screen reader walkthrough | manual-review | Requires human + assistive technology |

## Language-Specific Tooling

| Test Type | JS/TS | Java/Kotlin | Python | Go |
|-----------|-------|-------------|--------|-----|
| unit-test | Jest, Vitest | JUnit 5 | pytest | go test |
| integration-test | Supertest, Playwright | Spring Boot Test, Testcontainers | pytest + httpx, Testcontainers | go test + testcontainers |
| load-test | k6, autocannon | Gatling, JMH | locust, pytest-benchmark | go test -bench, k6 |
| chaos-test | Chaos Mesh, toxiproxy | Chaos Mesh, Testcontainers | toxiproxy, chaos-toolkit | toxiproxy, chaos-mesh |
| fitness-function | ESLint, dependency-cruiser | ArchUnit, SonarQube | import-linter, pylint, radon | go vet, staticcheck |
