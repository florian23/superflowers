# Architecture Style Selection Analysis

## Context
Internal HR CRUD tool for ~50 users, built and maintained by a team of 2 developers. Weekly releases to an internal server, minimal infrastructure budget, no external users, no scaling concerns.

## Candidate Architecture Styles

The following styles were evaluated against the documented architecture characteristics:

1. **Layered Monolith** -- Traditional layers (Presentation, Business Logic, Data Access) in a single deployable unit.
2. **Modular Monolith** -- Single deployable unit with well-defined internal modules (e.g., per domain: Employees, Leave, Payroll), each with clear boundaries.
3. **Microservices** -- Independently deployable services per domain.
4. **Service-Based Architecture** -- A few coarse-grained services (e.g., HR-API + Auth-Service).

## Evaluation Against Priority Characteristics

### 1. Simplicity (Critical)

| Style | Rating | Rationale |
|---|---|---|
| Layered Monolith | 5/5 | Minimal concepts, single codebase, well-understood pattern |
| Modular Monolith | 4/5 | Slightly more structure to learn (module boundaries), but still one codebase |
| Service-Based | 2/5 | Multiple deployables, inter-service communication, overkill for 2 devs |
| Microservices | 1/5 | Massive operational overhead, completely inappropriate for team size |

### 2. Testability (Critical)

| Style | Rating | Rationale |
|---|---|---|
| Layered Monolith | 3/5 | Testable but layers tend to become coupled over time, making unit tests harder |
| Modular Monolith | 5/5 | Module boundaries enforce separation, each module independently testable, integration tests straightforward in single process |
| Service-Based | 4/5 | Services testable in isolation, but integration testing across services adds complexity |
| Microservices | 3/5 | Unit tests easy per service, but end-to-end testing is complex |

### 3. Deployability (Critical)

| Style | Rating | Rationale |
|---|---|---|
| Layered Monolith | 5/5 | Single artifact, simple deploy script, trivial rollback |
| Modular Monolith | 5/5 | Same single artifact, same simple deployment |
| Service-Based | 3/5 | Multiple artifacts to coordinate, rollback more complex |
| Microservices | 2/5 | Many artifacts, requires orchestration, overkill for weekly internal releases |

### 4. Security (Critical)

| Style | Rating | Rationale |
|---|---|---|
| Layered Monolith | 4/5 | RBAC and audit logging achievable via middleware/interceptors in a single process |
| Modular Monolith | 5/5 | Cross-cutting security module can enforce RBAC and audit consistently, module boundaries help isolate sensitive data |
| Service-Based | 4/5 | Centralized auth service possible, but audit trail spans services |
| Microservices | 3/5 | Distributed security is harder, requires API gateway or sidecar |

### 5. Maintainability (Important)

| Style | Rating | Rationale |
|---|---|---|
| Layered Monolith | 3/5 | Tends toward "big ball of mud" over time without discipline |
| Modular Monolith | 5/5 | Module boundaries prevent cross-domain coupling, enforces clean structure |
| Service-Based | 4/5 | Service boundaries enforce separation, but operational maintenance overhead |
| Microservices | 3/5 | Code is clean per service, but operational maintenance is high |

## Summary Scorecard

| Style | Simplicity (Critical) | Testability (Critical) | Deployability (Critical) | Security (Critical) | Maintainability (Important) | Weighted Total |
|---|---|---|---|---|---|---|
| Layered Monolith | 5 | 3 | 5 | 4 | 3 | 16.5 |
| **Modular Monolith** | **4** | **5** | **5** | **5** | **5** | **20.5** |
| Service-Based | 2 | 4 | 3 | 4 | 4 | 13.0 |
| Microservices | 1 | 3 | 2 | 3 | 3 | 9.5 |

*Weighted: Critical characteristics count 1x each, Important counts 0.5x.*

## Recommendation: Modular Monolith

**The Modular Monolith is the best fit for this system.** Here is why:

1. **Simplicity stays high.** It is still a single codebase and a single deployable -- the team of 2 can manage it easily. The small overhead of defining module boundaries is far outweighed by the benefits.

2. **Testability is maximized.** Module boundaries create natural test seams. Each module (e.g., Employees, Leave Management, Audit) can be tested independently while integration tests run in a single process -- no network mocking needed.

3. **Deployability is identical to a simple monolith.** One artifact, one deploy, one rollback. The weekly release cycle to the internal server is trivially supported.

4. **Security benefits from structure.** A dedicated security/audit module can enforce RBAC and audit logging as a cross-cutting concern. Module boundaries prevent accidental data leakage between domains.

5. **Maintainability is the key differentiator vs. a plain layered monolith.** For an HR system that will grow (new modules for payroll, performance reviews, etc.), the modular structure prevents the codebase from degrading into a tangled mess -- critical when only 2 developers maintain it.

### Why not a plain Layered Monolith?

A layered monolith would also work initially, but HR tools tend to accumulate features over time. Without module boundaries, the codebase will become increasingly coupled and harder to maintain. The modular monolith provides a natural upgrade path -- if a module ever needs to be extracted into a separate service, the boundaries are already defined.

### Suggested Module Structure

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

### Trade-offs Accepted
- Slightly more upfront structure than a plain layered monolith
- All modules share a single database (acceptable for 50 users, no scaling concerns)
- Team must maintain module boundary discipline (enforce via build tooling or linting)
