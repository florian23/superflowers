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

---

## Architecture Style Selection

### Selected Style: Modular Monolith

### Date: 2026-03-29

### Candidates Evaluated
| Style | Simplicity (Critical) | Testability (Critical) | Deployability (Critical) | Security (Critical) | Maintainability (Important) | Weighted Total |
|---|---|---|---|---|---|---|
| Layered Monolith | 5 | 3 | 5 | 4 | 3 | 16.5 |
| **Modular Monolith** | **4** | **5** | **5** | **5** | **5** | **20.5** |
| Service-Based | 2 | 4 | 3 | 4 | 4 | 13.0 |
| Microservices | 1 | 3 | 2 | 3 | 3 | 9.5 |

*Weighted scoring: Critical = 1x, Important = 0.5x*

### Rationale
The Modular Monolith scores highest across all critical characteristics:
- **Simplicity**: Single codebase, single deployable -- manageable by 2 developers
- **Testability**: Module boundaries create natural test seams; integration tests run in-process
- **Deployability**: One artifact to deploy and roll back, matching the weekly release cadence
- **Security**: Dedicated auth and audit modules enforce RBAC and logging as cross-cutting concerns
- **Maintainability**: Module boundaries prevent cross-domain coupling as the tool grows

### Trade-offs Accepted
- Slightly more upfront structure than a plain layered monolith
- All modules share a single database (acceptable for 50 users)
- Requires discipline to maintain module boundaries (enforce via build tooling)

### Module Structure
```
hr-tool/
  modules/
    employees/       -- Employee CRUD, profiles
    leave/           -- Leave requests, approvals
    auth/            -- RBAC, authentication
    audit/           -- Audit logging (cross-cutting)
  shared/
    database/        -- Shared DB access, migrations
    common/          -- Shared utilities, DTOs
```

### Runner-Up: Layered Monolith
A plain layered monolith would work initially but risks degrading into tightly coupled code over time. The modular monolith preserves simplicity while providing structural guardrails that a 2-person team needs to keep the codebase healthy long-term.

---

## Changelog
- 2026-03-29: Initial architecture assessment
- 2026-03-29: Architecture style selected -- Modular Monolith
