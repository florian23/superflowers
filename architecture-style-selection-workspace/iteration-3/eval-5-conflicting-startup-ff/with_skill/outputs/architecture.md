# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics

1. Simplicity -- Must ship MVP in 4 weeks with 1 dev
2. Scalability -- Expect viral growth if product-market fit
3. Elasticity -- Social media spikes unpredictable

## Architecture Drivers

- Solo developer, bootstrapped, 4-week deadline
- If successful: viral growth, need to scale fast

## Characteristic Conflict

Simplicity is structurally opposed to Scalability and Elasticity in the architecture styles matrix. No single architecture style scores above 3/5 on all three simultaneously. This conflict is resolved through a phased evolution path rather than a single style selection.

## Selected Architecture Style

**Style:** Modular Monolith (Phase 1) -> Service-Based (Phase 2) -> Selective Event-Driven (Phase 3)
**Current Phase:** Phase 1 -- Modular Monolith
**Partitioning:** domain
**Cost Category:** $ (Phase 1), $$ (Phase 2), $$$ (Phase 3)

### Selection Rationale

- Driving characteristics: Simplicity (★5), Scalability (★1), Elasticity (★1)
- Fit score: 7/15 (Phase 1), 10/15 (Phase 2), 12/15 (Phase 3)
- Simplicity is the gating constraint: missing the 4-week deadline eliminates all other concerns
- No single style satisfies all three driving characteristics -- phased evolution is the only honest answer
- Domain partitioning in the modular monolith enables mechanical extraction to services (not a rewrite)
- Solo developer + bootstrapped budget disqualifies distributed architectures ($$$+) for Phase 1

### Tradeoffs Accepted

- **Scalability:** Rated 1/5 in Phase 1 -- Accepted because there are no users yet. Vertical scaling (bigger machine) buys time until Phase 2. Module boundaries ensure extraction is possible when needed.
- **Elasticity:** Rated 1/5 in Phase 1 -- Accepted because social media spikes are only a problem after product-market fit. If the product doesn't succeed, elasticity is irrelevant.
- **Simplicity:** Drops to 3/5 in Phase 2 -- Accepted because by Phase 2, revenue or funding should support the added complexity. Team size will likely have grown.

### Evolution Path

- **Phase 1 (Now, MVP):** Modular Monolith. Ship in 4 weeks. Enforce strict module boundaries with fitness functions. Each domain module communicates through a public API only -- no internal imports across modules.
- **Phase 2 (Post-PMF, scaling pain):** Extract to Service-Based architecture. Domain modules become 4-8 coarser services. Trigger: response times degrade under load OR deployment frequency needs exceed monolith comfort.
- **Phase 3 (Viral scale, selective):** Add Event-Driven processing for hot paths only (e.g., notification fan-out, feed generation, analytics ingestion). Keep non-critical paths as services. Trigger: specific components need elasticity beyond what service-based provides.

Phase transitions are triggered by measured pain, not predicted need. Fitness functions below enforce the current phase's structural invariants.

### Architecture Style Fitness Functions

These fitness functions enforce the selected style's structural invariants. They are mandatory and immutable -- if the implementation violates them, the implementation must change, not the fitness function.

**Phase 1: Modular Monolith (Current)**

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No circular module dependencies | Module A -> B means B must not -> A (directly or transitively) | dependency-cruiser, ArchUnit |
| Module boundary enforcement | Cross-module access only through public API (no internal imports) | Package visibility rules, lint rules |
| Single deployment artifact | Build produces exactly one deployable unit | Build script check |
| Database schema per module | Each module owns its tables, no cross-module direct table access | SQL analysis or ORM config check |

**Phase 2: Service-Based (Future -- activates when Phase 2 begins)**

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| Service boundary alignment | Services align with documented domain boundaries | Directory/package structure check |
| Limited service count | Total number of services within defined range (typically 4-12) | Service registry/count check |
| No service-to-service chatter | Service-to-service calls within defined limits (< N calls per request) | Runtime tracing or static call graph |
| Database sharing discipline | If shared DB: each service accesses only its own tables/views | SQL analysis, ORM scope check |

**Phase 3: Event-Driven (Future -- activates when Phase 3 begins, for hot-path components only)**

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No synchronous coupling | Event producers don't wait for consumer responses (fire-and-forget or async) | Code analysis for sync calls between event components |
| Event schema registry | All events have defined schemas, versioned | Schema registry check |
| Consumer idempotency | Event consumers handle duplicate events safely | Test for idempotent processing |
| No event orchestration leaks | Mediator topology: only the mediator orchestrates; Broker topology: no central orchestrator | Architecture pattern check |
| Dead letter handling | Failed events go to dead letter queue, not silently dropped | DLQ configuration check |

## Changelog

- 2026-03-29: Initial assessment
- 2026-03-29: Architecture style selected -- Modular Monolith with phased evolution to Service-Based and selective Event-Driven. Conflict between simplicity and scalability/elasticity resolved through evolution path. Style fitness functions added for all three phases.
