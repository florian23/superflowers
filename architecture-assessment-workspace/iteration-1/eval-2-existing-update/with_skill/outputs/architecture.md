# Architecture Characteristics

## Last Updated: 2026-03-28

## Top 3 Priority Characteristics
1. Performance — API <200ms p95
2. Security — No known CVEs, PII encrypted at rest
3. Testability — >80% coverage

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Performance | Critical | API <200ms p95 | Yes - load test |
| Availability | Important | 99.9% uptime | Yes - health check |
| Scalability | Nice-to-have | Handle 1000 concurrent users | No |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Testability | Critical | >80% coverage | Yes - coverage gate |
| Modularity | Important | No circular dependencies | Yes - dependency check |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Security | Critical | No known CVEs, PII encrypted | Yes - vulnerability scan |
| Compliance | Important | GDPR compliant | No |

## Architecture Drivers
- Healthcare domain: PII data requires strong security and GDPR compliance
- Public-facing API: Performance and availability are user-facing concerns

## Architecture Decisions
- PDF Export endpoint may use a separate SLA (e.g., <2s) but this is a feature-level concern, not an architecture change. The overall API performance target of <200ms p95 applies to standard endpoints.

## Changelog
- 2026-03-15: Initial architecture assessment
- 2026-03-28: Reviewed for PDF Export feature — no changes to characteristics needed. Architecture remains stable. Added note about PDF endpoint SLA as an architecture decision.
