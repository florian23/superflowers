# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics
1. Simplicity — Small team (2 devs), must be easy to understand and maintain
2. Testability — Full test coverage required, HR data is sensitive
3. Deployability — Weekly releases to internal server, must be low-risk

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Availability | Nice-to-have | 99% uptime (business hours only) | No | - |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Simplicity | Critical | New dev productive within 1 week | No | - |
| Testability | Critical | >90% test coverage | Yes - coverage gate | Atomic (commit) |
| Deployability | Critical | <30min deploy, rollback in <5min | Yes - deploy check | Atomic (commit) |
| Maintainability | Important | No function >50 lines | Yes - complexity check | Atomic (commit) |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Security | Critical | RBAC, audit log for all data access | Yes - auth test | Atomic (commit) |

## Architecture Drivers
- Small team: 2 developers, limited operational capacity
- Internal tool: No external users, no scaling concerns
- Budget: Minimal infrastructure budget

## Changelog
- 2026-03-29: Initial architecture assessment
