# Architecture Characteristics

## Last Updated: 2026-03-31

## Top 3 Priority Characteristics
1. Reliability — Zero payment data loss, alle Writes in DB-Transaktionen, kein Payment ohne Terminal-Status innerhalb 60s
2. Security — Verschlüsselung, Auth, Input Validation, keine bekannten CVEs
3. Availability — 99.9%+ Uptime

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Availability | Critical | 99.9%+ Uptime | Yes - health check + uptime monitoring | Nightly |
| Performance | Important | API < 200ms p95 | Yes - load test | Holistic (PR) |
| Scalability | Important | 1000–5000 req/s | Yes - load test | Holistic (PR) |
| Reliability | Critical | Zero payment data loss. No orphaned payments (terminal state within 60s). All writes in DB transactions. | Yes - integration test with failure injection | Holistic (PR) |
| Fault Tolerance | Important | Recovery time < 30s after downstream failure. Circuit breaker opens after 5 consecutive failures, half-opens after 10s. | Yes - circuit breaker test | Holistic (PR) |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Modularity | Important | No circular dependencies, clean layer separation | Yes - dependency check (ArchUnit) | Atomic (commit) |
| Testability | Important | >70% coverage, Unit + Integration Tests | Yes - coverage gate | Atomic (commit) |
| Deployability | Important | Zero-Downtime Deployments (Blue/Green or Rolling) | Yes - deployment smoke test | Holistic (PR) |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Vulnerability Management | Critical | No known CVEs in dependencies | Yes - dependency vulnerability scan | Atomic (commit) |
| Data Encryption | Critical | All PII encrypted at rest (AES-256) and in transit (TLS 1.2+) | Yes - encryption config verification | Holistic (PR) |
| Authentication | Critical | All endpoints (except /health) require valid JWT, rate limiting per user | Yes - auth integration test | Holistic (PR) |
| Input Validation | Important | All API inputs validated against schema, no injection vectors | Yes - schema validation + OWASP ZAP scan | Holistic (PR) |
| GDPR Data Retention | Important | PII deleted after 36 months of inactivity. Right to Erasure endpoint functional. | Yes - automated deletion job verification | Nightly |
| Audit Logging | Important | All write operations logged (who, what, when, result). Append-only, 7-year retention. | Yes - audit log presence + immutability check | Holistic (PR) |
| Observability | Important | Structured logging, distributed tracing, metrics dashboards, alerting | Yes - log format validation + trace ID presence check | Atomic (commit) |

## Open Items
- PCI-DSS (COMP-003): Muss geklärt werden ob Kartendaten selbst verarbeitet oder an externen PSP delegiert werden. Projekt-Constraints noch nicht eingerichtet — `superflowers:project-constraints` ausführen.

## Architecture Drivers
- Payment domain: Financial transactions require highest reliability and data consistency
- PII handling: Card numbers, IBAN, cardholder names require encryption at rest and in transit
- Regulatory environment: GDPR and audit requirements drive compliance characteristics
- Business criticality: Payment downtime directly impacts revenue

## Architecture Decisions
- Spring Boot 3.2 with Kotlin as primary framework and language
- PostgreSQL as primary datastore for transactional consistency
- Layered architecture: Controller → Service → Repository

## Changelog
- 2026-03-31: Initial architecture assessment for Payment Service
- 2026-03-31: Review fixes — Split Security into 4 rows (Vulnerability Management, Data Encryption, Authentication, Input Validation). Split Compliance into GDPR Data Retention + Audit Logging. Downgraded non-Top-3 from Critical to Important. Made Fault Tolerance and Reliability goals measurable. Added PCI-DSS as open item.
