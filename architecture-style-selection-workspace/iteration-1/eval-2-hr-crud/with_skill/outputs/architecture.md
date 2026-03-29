# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics
1. Simplicity — Small team (2 devs), must be easy to understand and maintain
2. Testability — Full test coverage required, HR data is sensitive
3. Deployability — Weekly releases to internal server, must be low-risk

## All Characteristics

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Simplicity | Critical | New dev productive within 1 week | No | - |
| Testability | Critical | >90% test coverage | Yes - coverage gate | Atomic (commit) |
| Deployability | Critical | <30min deploy, rollback in <5min | Yes - deploy check | Atomic (commit) |
| Maintainability | Important | No function >50 lines | Yes - complexity check | Atomic (commit) |

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Availability | Nice-to-have | 99% uptime (business hours only) | No | - |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Security | Critical | RBAC, audit log for all data access | Yes - auth test | Atomic (commit) |

## Selected Architecture Style

**Style:** Microkernel
**Partitioning:** domain
**Cost Category:** $

### Selection Rationale
- Driving characteristics: Simplicity (★5), Testability (★3), Deployability (★3)
- Fit score: 11/15
- Three styles tied at 11/15 (Microkernel, Service-Based, Microservices) but Microkernel wins on cost ($) and simplicity (5/5)
- Service-Based drops simplicity to 3/5 — conflicts with #1 priority
- Microservices costs $$$$$ — unjustifiable for 50-user internal tool with 2 developers
- Core + plugins model fits CRUD well: core = HR domain, plugins = reports/exports/integrations

### Tradeoffs Accepted
- Testability: Rated 3/5 — adequate for the use case, mitigated by plugin isolation enabling focused unit tests
- Deployability: Rated 3/5 — single deployable unit, weekly release cadence makes this sufficient

### Evolution Path
- Start with Microkernel: core HR module + plugin slots for reports, exports, integrations
- If complexity grows significantly, consider migrating to Modular Monolith (cleaner module boundaries)
- Distributed architectures (service-based, microservices) only warranted if user base grows 100x+ or multiple teams are added

## Architecture Drivers
- Small team: 2 developers, limited operational capacity
- Internal tool: No external users, no scaling concerns
- Budget: Minimal infrastructure budget

## Architecture Decisions
- Microkernel architecture selected based on Architecture Styles Worksheet scoring
- Distributed architectures explicitly rejected (premature distribution red flag)

## Changelog
- 2026-03-29: Initial architecture assessment
- 2026-03-29: Selected Microkernel architecture (fit score 11/15, $)
