# Architecture Characteristics
## Last Updated: 2026-03-29
## Top 3 Priority Characteristics
1. Evolvability — Independent feature evolution across 3 teams
2. Maintainability — Each team owns their domain independently
3. Scalability — Black Friday: 50x checkout, 10x catalog

## Architecture Drivers
- 3 autonomous teams: catalog, checkout, fulfillment
- Legacy monolith: gradual migration preferred
- Revenue-critical

## Selected Architecture Style

**Style:** Service-Based Architecture
**Partitioning:** Domain
**Cost Category:** $$

### Selection Rationale
- Driving characteristics: Evolvability (★5), Maintainability (★5), Scalability (★4)
- Fit score: 14/15
- Only 1 point below microservices (15/15), but at a fraction of the cost ($$ vs $$$$$)
- Domain partitioning maps directly to 3 autonomous teams: catalog service, checkout service, fulfillment service
- Shared database provides strong transactional guarantees for revenue-critical checkout flows
- Natural fit for gradual monolith migration via Strangler Fig pattern — extract coarse domain services one at a time
- Team size of 4-6 devs per team is well-suited to owning a coarse-grained service without microservices operational overhead
- Kubernetes experience enables container-based deployment of services without requiring full service mesh complexity

### Tradeoffs Accepted
- **Scalability:** Rated 4/5 — One point below microservices. Mitigated by the ability to independently scale the checkout service during peak load (Black Friday). If 50x checkout exceeds service-based capacity, the checkout service can be decomposed further.
- **Elasticity:** Rated 3/5 — Burst scaling is coarser-grained than microservices. Mitigated by K8s horizontal pod autoscaling at the service level. Acceptable because extreme elasticity is needed only for checkout during Black Friday, not system-wide.
- **Simplicity:** Rated 3/5 — More complex than a monolith but significantly simpler than microservices. Acceptable tradeoff given the need for team autonomy and independent evolution.

### Evolution Path
- **Phase 1 (now):** Extract 3 domain services from the monolith using Strangler Fig pattern. Each team owns one service. Shared database with schema-per-service boundaries.
- **Phase 2 (as needed):** Introduce event-driven patterns between services (e.g., order-placed events from checkout to fulfillment) to decouple synchronous dependencies.
- **Phase 3 (if scaling demands grow):** Decompose the checkout service into finer-grained microservices (payment, cart, pricing) if Black Friday load exceeds single-service scalability. Other services remain coarse-grained unless similar pressure emerges.
- **Key principle:** Evolve toward microservices only where the pain is real, not predicted. Service-based is the long-term target for most of the system.

## Changelog
- 2026-03-29: Initial assessment
- 2026-03-29: Selected Service-Based Architecture (fit score 14/15, $$) — domain-partitioned with evolution path toward selective microservices
