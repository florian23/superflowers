# Architecture Characteristics
## Last Updated: 2026-03-29
## Top 3 Priority Characteristics
1. Workflow — Complex multi-step business processes spanning multiple services
2. Configurability — Must support per-tenant configuration and white-labeling
3. Interoperability — Must integrate with 12+ external partner APIs

## Architecture Drivers
- B2B SaaS platform for logistics
- Multi-tenant with per-customer configuration
- Heavy integration with shipping carriers, customs, ERP systems

## Selected Architecture Style

**Style:** Service-Based (with event-driven workflow orchestration and microkernel configuration pattern)
**Partitioning:** Domain
**Cost Category:** $$

### Selection Rationale
- Driving characteristics: Workflow (★★★★), Configurability (★★★), Interoperability (★★)
- Fit score: 9/15 (pure), enhanced by hybrid patterns
- Service-Oriented scored highest (13/15) but at $$$$ cost with heavy governance — disproportionate for a growing B2B SaaS
- Microservices scored 11/15 but at $$$$$ — highest cost, justified only at scale
- Service-Based provides the best cost-to-benefit ratio at $$, with a clear evolution path
- Domain partitioning aligns with multi-tenant SaaS requirements
- Coarse-grained services (4-12) are manageable for a growing team while providing meaningful service boundaries

### Hybrid Pattern Details
- **Workflow orchestration:** Event-driven mediator topology within the service-based architecture handles complex multi-step logistics workflows (pickup → customs → routing → delivery → settlement)
- **Configurability:** Microkernel pattern within the configuration/tenant service enables per-tenant plugins for white-labeling, carrier-specific rules, and custom workflows
- **Interoperability:** Dedicated integration service(s) with adapter pattern for 12+ partner APIs (carriers, customs, ERP systems)

### Tradeoffs Accepted
- **Interoperability**: Rated 2/5 for pure service-based — mitigated by dedicated integration services with adapter/anti-corruption layers for each external partner
- **Configurability**: Rated 3/5 for pure service-based — mitigated by embedding a microkernel pattern in the tenant configuration service
- **Scalability**: Rated 4/5 — acceptable for B2B logistics workloads; if extreme spikes occur, individual services can be scaled independently
- **Testability**: Rated 4/5 — good; coarse-grained services are easier to integration-test than microservices

### Evolution Path
- **Phase 1 (Now):** Service-based with 4-8 domain services, shared database with schema-per-tenant, event-driven mediator for workflows
- **Phase 2 (10+ tenants):** Extract high-traffic services (tracking, notifications) into independent microservices; introduce per-service databases where isolation is needed
- **Phase 3 (Scale):** Full microservices for services requiring independent scaling; event-driven backbone for async workflows; consider space-based for real-time tracking if elasticity demands grow

## Changelog
- 2026-03-29: Initial assessment
- 2026-03-29: Architecture style selected — Service-Based with event-driven workflow and microkernel configuration patterns
