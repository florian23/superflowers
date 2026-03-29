# Superseding Cascade Analysis: ADR-001 (Service-Based) -> ADR-005 (Microservices)

## 1. ADR Changes

| ADR | Before | After |
|-----|--------|-------|
| ADR-001 | Status: Accepted | Status: Superseded by ADR-005 |
| ADR-005 | (did not exist) | Status: Accepted -- "Use Microservices architecture" |

Only the Status line of ADR-001 changes. Context, Decision, and Consequences remain untouched (ADR immutability).

## 2. Fitness Functions REMOVED (referenced ADR-001)

These fitness functions enforced Service-Based structural invariants. Because ADR-001 is now superseded, they are no longer valid and must be removed from architecture.md:

| Fitness Function | What it checks | Tool/Approach | ADR |
|---|---|---|---|
| Service boundary alignment | Services align with domain | Dir check | ADR-001 |
| Limited service count | 4-12 services | Registry | ADR-001 |
| No service chatter | <5 calls/request | Tracing | ADR-001 |
| DB sharing discipline | Own tables per service | SQL analysis | ADR-001 |

**Why removal is legitimate:** Per the fitness-functions skill, FF immutability has an explicit exception -- when the ADR that justifies the FF has been superseded by a new ADR. The superseding ADR (ADR-005) exists with status "Accepted" and ADR-001's status is "Superseded by ADR-005". This satisfies the verification check.

## 3. Fitness Functions ADDED (Microservices style, referencing ADR-005)

These fitness functions are sourced from `references/style-fitness-functions.md` under the Microservices section. All reference ADR-005:

| Fitness Function | What it checks | Tool/Approach | ADR |
|---|---|---|---|
| No shared database | Each service has its own database/schema, no shared tables | DB connection config analysis | ADR-005 |
| Independent deployability | Each service can be built and deployed independently | Build pipeline check | ADR-005 |
| API contract compliance | Services communicate only via defined API contracts (REST/gRPC/events) | Contract testing (Pact, Spring Cloud Contract) | ADR-005 |
| No shared libraries with business logic | Shared code limited to infrastructure concerns (logging, auth), not domain logic | Dependency analysis on shared packages | ADR-005 |
| Service size bounds | Each service stays within defined LOC/complexity limits | Code metrics | ADR-005 |

## 4. Fitness Function Diff Summary

| # | Old FF (REMOVED) | New FF (ADDED) | Key difference |
|---|---|---|---|
| 1 | Service boundary alignment | (covered implicitly by independent deployability) | Microservices enforce boundaries through deployment independence, not just directory structure |
| 2 | Limited service count (4-12) | Service size bounds | Constraint inverts: instead of limiting total services, each service is bounded in size/complexity |
| 3 | No service chatter (<5 calls/request) | API contract compliance | Focus shifts from limiting calls to ensuring all calls go through defined contracts |
| 4 | DB sharing discipline (own tables) | No shared database | Stricter: each service gets its own database/schema, not just its own tables in a shared DB |
| 5 | -- | Independent deployability | New: Service-Based did not require independent deployment |
| 6 | -- | No shared libraries with business logic | New: prevents coupling through shared domain code |

## 5. Impact on quality-scenarios.md

Per the architecture-decisions skill cascade table, when an Architecture Style is superseded, quality scenarios must be re-evaluated for affected scenarios. The following impacts apply:

### Scenarios that need re-evaluation

**Performance/Latency scenarios:**
- Service-Based architecture assumed in-process or low-hop communication. Microservices introduce network hops between every service boundary. Any quality scenario with latency thresholds (e.g., "API response < 200ms p95") must be re-evaluated -- the added network latency from service-to-service calls may require adjusting thresholds or adding caching strategies.

**Availability scenarios:**
- Microservices improve fault isolation (one service down does not bring down others), so availability scenarios may improve. However, scenarios that depend on multiple services completing successfully now require explicit resilience patterns (circuit breakers, retries, fallbacks).

**Data consistency scenarios:**
- Any scenario assuming transactional consistency across what were previously parts of the same service must be re-evaluated. Microservices require eventual consistency patterns (sagas, event sourcing). Quality scenarios involving "immediate consistency" across domain boundaries are likely no longer achievable and need new acceptance criteria.

**Scalability scenarios:**
- These likely improve. Scenarios with scaling targets can now be met per-service rather than scaling entire coarse-grained services.

### Recommended actions for quality-scenarios.md

1. Review every scenario that references inter-service communication and adjust latency budgets
2. Add new scenarios for distributed failure modes (partial availability, circuit breaker behavior)
3. Replace transactional consistency scenarios with eventual consistency equivalents where services span domain boundaries
4. Add contract testing scenarios (what happens when a service deploys a breaking API change?)

## 6. Impact on architecture.md

The following sections of architecture.md must be updated:

1. **Selected Architecture Style** -- change from Service-Based to Microservices, update rationale, cost, and tradeoffs
2. **Architecture Style Fitness Functions** -- replace the entire table (remove 4 old FFs, add 5 new FFs)
3. **Architecture Decisions reference** -- add ADR-005, mark ADR-001 as superseded
4. **Current Architecture at a Glance** (in ADR index) -- replace ADR-001 entry with ADR-005

## 7. Cascade Sequence (execution order)

```
1. Write ADR-005 (status: Accepted)
2. Update ADR-001 status to "Superseded by ADR-005"
3. Update ADR index "Current Architecture at a Glance" (remove ADR-001 row, add ADR-005 row)
4. Remove old style FFs from architecture.md (4 FFs referencing ADR-001)
5. Add new style FFs to architecture.md (5 FFs referencing ADR-005)
6. Re-evaluate quality-scenarios.md for affected scenarios
7. Update architecture.md "Selected Architecture Style" section
8. Commit all changes together
```
