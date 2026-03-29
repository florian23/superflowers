# Architecture Characteristics
## Last Updated: 2026-03-29
## Top 3 Priority Characteristics
1. Evolvability — Independent feature evolution across 3 teams
2. Maintainability — Each team owns their domain independently
3. Scalability — Black Friday: 50x checkout, 10x catalog

## Architecture Style Decision
**Selected: Microservices Architecture**

### Rationale
- 3 autonomous teams map directly to 3 domain services (Catalog, Checkout, Fulfillment)
- Black Friday scaling (50x checkout) requires independent per-service scaling
- Revenue-critical system demands fault isolation between domains
- Gradual migration from monolith supported via Strangler Fig pattern

### Trade-offs Accepted
- Higher operational complexity (mitigated by shared platform/infrastructure)
- Distributed data management (mitigated by domain-aligned service boundaries)
- Network latency between services (mitigated by async communication where possible)

### Alternatives Considered
- **Service-Based Architecture**: Close second; viable if team prefers fewer, coarser services initially
- **Modular Monolith**: Rejected as target state due to inability to scale checkout independently; useful as intermediate migration step

### Migration Strategy
Strangler Fig: Catalog (Phase 1) -> Checkout (Phase 2) -> Fulfillment (Phase 3)

## Architecture Drivers
- 3 autonomous teams: catalog, checkout, fulfillment
- Legacy monolith: gradual migration preferred
- Revenue-critical

## Changelog
- 2026-03-29: Initial assessment
- 2026-03-29: Architecture style selected — Microservices via Strangler Fig migration
