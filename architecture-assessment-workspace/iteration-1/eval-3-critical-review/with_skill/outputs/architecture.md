# Architecture Characteristics

## Last Updated: 2026-03-28

## Top 3 Priority Characteristics
1. Security — No known CVEs, PII encrypted at rest
2. Fault Tolerance — System operates during partial failures; no data loss on device disconnect
3. Performance — API <200ms p95, IoT ingestion <500ms p95

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Performance | Critical | API <200ms p95, IoT ingestion <500ms p95 | Yes - load test |
| Availability | Important | 99.9% uptime | Yes - health check |
| Scalability | Important | Handle 1000 concurrent users + 10,000 connected IoT devices | No |
| Fault Tolerance | Critical | No data loss on device disconnect; graceful degradation during partial outages; message buffer ≥ 24h offline | Yes - chaos testing |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Testability | Important | >80% coverage | Yes - coverage gate |
| Modularity | Important | No circular dependencies; IoT subsystem decoupled from core API | Yes - dependency check |
| Extensibility | Important | New IoT device types addable without core changes | No |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Security | Critical | No known CVEs, PII encrypted at rest and in transit; IoT device authentication via mTLS or equivalent | Yes - vulnerability scan |
| Compliance | Important | GDPR compliant; IoT data retention policies enforced | No |
| Observability | Important | Device connectivity status visible; anomaly detection on IoT data streams | No |

## Architecture Drivers
- Healthcare domain: PII data requires strong security and GDPR compliance
- Public-facing API: Performance and availability are user-facing concerns
- IoT device support: Unreliable networks and intermittent connectivity demand fault tolerance, message buffering, and device authentication

## Architecture Decisions
- Fault Tolerance strategy: Message buffering with store-and-forward for IoT data to prevent data loss during connectivity gaps
- IoT subsystem isolation: IoT ingestion layer decoupled from core API to prevent fault propagation
- Security expansion: IoT devices require device-level authentication (mTLS or equivalent) in addition to existing API security

## Changelog
- 2026-03-15: Initial architecture assessment
- 2026-03-28: IoT support — Added Fault Tolerance as Critical (Top 3). Expanded Performance goal to cover IoT ingestion. Added Extensibility and Observability as Important. Expanded Security to include IoT device authentication. Upgraded Scalability to Important. Testability moved out of Top 3 but remains Important. Rejected PO request to drop Performance — IoT reinforces need for Performance, not diminishes it.
