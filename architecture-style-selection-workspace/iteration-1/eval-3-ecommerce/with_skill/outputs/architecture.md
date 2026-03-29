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

## Selected Architecture Style

**Style:** Service-Based
**Partitioning:** domain
**Cost Category:** $$

### Selection Rationale
- Driving characteristics: Evolvability (★5), Maintainability (★5), Scalability (★4)
- Fit score: 14/15
- Microservices scored 15/15 but at $$$$$ cost — the 1-point scalability gap doesn't justify 2.5x cost
- Service-Based supports gradual strangler fig migration from the existing monolith (key requirement)
- 3 teams map naturally to 4-6 coarse-grained domain services
- Service-Based preserves simplicity (3/5 vs microservices 1/5) while delivering on team independence

### Tradeoffs Accepted
- Scalability: Rated 4/5 — mitigated by selectively extracting checkout into microservices for Black Friday spikes
- Simplicity: Rated 3/5 — coarser services are simpler to operate than fine-grained microservices

### Evolution Path
- Phase 1: Strangler Fig migration — extract 4-6 domain services (catalog, checkout, fulfillment, user)
- Phase 2: Stabilize service boundaries, each team owns their service independently
- Phase 3: Selectively decompose high-traffic services (checkout) into finer-grained microservices
- Phase 4: Add event-driven patterns for async workflows (order events, inventory sync, notifications)

## Architecture Drivers
- 3 autonomous teams: catalog, checkout, fulfillment
- Legacy monolith: gradual migration, not big-bang
- High stakes: revenue-critical, downtime = lost sales

## Architecture Decisions
- Service-Based architecture selected based on Architecture Styles Worksheet scoring
- Gradual strangler fig migration preferred over big-bang rewrite
- Selective microservices extraction planned for Phase 3 (checkout scaling)

## Changelog
- 2026-03-29: Initial architecture assessment
- 2026-03-29: Selected Service-Based architecture (fit score 14/15, $$)
