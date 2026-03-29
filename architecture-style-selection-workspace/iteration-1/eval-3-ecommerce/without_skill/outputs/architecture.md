# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics
1. Evolvability — Must be able to evolve features independently across 3 teams
2. Maintainability — Each team must own and maintain their domain independently
3. Scalability — Black Friday traffic: 50x normal load on checkout, 10x on catalog

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Scalability | Critical | Handle 50x traffic on checkout during sales | Yes - load test | Nightly |
| Availability | Critical | 99.99% uptime | Yes - health check | Nightly |
| Performance | Important | Catalog search <100ms, checkout <500ms | Yes - benchmark | Holistic (PR) |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Evolvability | Critical | Independent deployments per team | Yes - dependency check | Atomic (commit) |
| Maintainability | Critical | No cross-team code ownership | Yes - ownership check | Atomic (commit) |
| Testability | Important | >80% per service | Yes - coverage gate | Atomic (commit) |
| Deployability | Important | Multiple deploys per day per team | Yes - deploy pipeline | Atomic (commit) |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Security | Critical | PCI-DSS compliance for payment | Yes - security scan | Atomic (commit) |
| Observability | Critical | Distributed tracing across all services | Yes - trace check | Atomic (commit) |

## Selected Architecture

**Style:** Microservices
**Rationale:** Best fit for 3 independent teams needing autonomous deployments and differential scaling (50x checkout). Strangler fig migration from monolith.

## Architecture Drivers
- 3 autonomous teams: catalog, checkout, fulfillment
- Legacy monolith: gradual migration, not big-bang
- High stakes: revenue-critical, downtime = lost sales

## Changelog
- 2026-03-29: Initial architecture assessment
- 2026-03-29: Selected Microservices architecture
