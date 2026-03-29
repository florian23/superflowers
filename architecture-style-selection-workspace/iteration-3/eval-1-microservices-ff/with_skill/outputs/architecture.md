# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics

1. Evolvability — Independent feature evolution across 3 teams
2. Maintainability — Each team owns their domain independently
3. Scalability — Black Friday: 50x checkout, 10x catalog

## Architecture Drivers

- 3 autonomous teams, K8s experience, gradual monolith migration

## Selected Architecture Style

**Style:** Microservices
**Partitioning:** domain
**Cost Category:** $$$$$

### Selection Rationale

- Driving characteristics: Evolvability (★5), Maintainability (★5), Scalability (★5)
- Fit score: 15/15
- Perfect alignment with all three driving characteristics — no other style achieves this
- 3 autonomous teams justify the coordination cost of independent services
- Existing Kubernetes experience significantly mitigates operational complexity
- Black Friday 50x checkout / 10x catalog scaling requires per-service independent scaling that shared-database architectures cannot deliver
- Gradual monolith migration aligns with incremental service extraction

### Tradeoffs Accepted

- Simplicity: Rated 1/5 — Accepted because team has K8s experience and distributed systems are justified by 3-team autonomy requirement. Mitigated through standardized service templates and platform team practices.
- Cost: $$$$$ — Accepted because K8s infrastructure is already in place and 3 autonomous teams distribute the operational burden. The alternative (service-based at $$) would compromise independent scaling needed for Black Friday.
- Responsiveness: Rated 2/5 — Mitigated through API gateway caching, CDN for catalog reads, and async event patterns for non-critical paths.

### Evolution Path

- Phase 1: Extract checkout, catalog, and user account domains from monolith as independent microservices (one per team)
- Phase 2: Decompose further within domains as complexity warrants (e.g., payment as sub-service of checkout)
- Phase 3: Introduce event-driven patterns between services for async workflows (order events, inventory updates)

### Architecture Style Fitness Functions

These fitness functions enforce the selected style's structural invariants. They are mandatory and immutable — if the implementation violates them, the implementation must change, not the fitness function.

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No shared database | Each service has its own database/schema, no shared tables | DB connection config analysis |
| Independent deployability | Each service can be built and deployed independently | Build pipeline check |
| API contract compliance | Services communicate only via defined API contracts (REST/gRPC/events) | Contract testing (Pact, Spring Cloud Contract) |
| No shared libraries with business logic | Shared code limited to infrastructure concerns (logging, auth), not domain logic | Dependency analysis on shared packages |
| Service size bounds | Each service stays within defined LOC/complexity limits | Code metrics |

## Changelog

- 2026-03-29: Initial assessment
- 2026-03-29: Selected Microservices architecture style (fit score 15/15)
