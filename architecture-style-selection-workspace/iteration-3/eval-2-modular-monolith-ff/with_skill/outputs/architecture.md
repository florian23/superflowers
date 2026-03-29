# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics

1. Simplicity — Solo dev team, must ship fast
2. Testability — >90% coverage, regulatory compliance
3. Maintainability — Long-lived internal system, clean code essential

## Architecture Drivers

- 1 developer, internal compliance tool, minimal budget

## Selected Architecture Style

**Style:** Modular Monolith
**Partitioning:** Domain
**Cost Category:** $

### Selection Rationale

- Driving characteristics: Simplicity (5/5), Testability (2/5), Maintainability (2/5)
- Fit score: 9/15
- Selected over Service-Based (12/15, $$) because simplicity is the #1 priority and a single developer cannot sustainably operate distributed services
- Selected over Microkernel (11/15, $) because the compliance domain does not naturally decompose into core + plugins
- Solo developer with minimal budget makes $ cost category essential — distributed architectures are eliminated by context regardless of matrix scores

### Tradeoffs Accepted

- **Testability:** Rated 2/5 — mitigated by enforcing module boundaries with clear public APIs, dependency injection, and >90% test coverage as a fitness function. Modules are tested in isolation through their public interfaces.
- **Maintainability:** Rated 2/5 — mitigated by strict module boundary enforcement (no circular dependencies, no cross-module internal imports). Domain-partitioned modules keep changes localized. Fitness functions enforce these boundaries continuously.
- **Scalability:** Rated 1/5 — acceptable because this is an internal compliance tool with a bounded user base. Vertical scaling is sufficient.
- **Deployability:** Rated 1/5 — acceptable because single deployment simplifies operations for a solo developer. No need for independent service deployability.

### Evolution Path

- **Phase 1 (current):** Modular Monolith — domain modules with enforced boundaries, single deployment unit
- **Phase 2 (if team grows to 2-3 devs):** Extract high-change modules to Service-Based architecture, keeping stable modules in the monolith
- **Phase 3 (if multiple teams):** Selective Microservices extraction for modules that need independent deployability

### Architecture Style Fitness Functions

These fitness functions enforce the selected style's structural invariants. They are mandatory and immutable — if the implementation violates them, the implementation must change, not the fitness function.

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No circular module dependencies | Module A -> B means B must not -> A (directly or transitively) | dependency-cruiser, ArchUnit |
| Module boundary enforcement | Cross-module access only through public API (no internal imports) | Package visibility rules, lint rules |
| Single deployment artifact | Build produces exactly one deployable unit | Build script check |
| Database schema per module | Each module owns its tables, no cross-module direct table access | SQL analysis or ORM config check |

## Changelog

- 2026-03-29: Initial assessment
- 2026-03-29: Selected Modular Monolith based on style-selection analysis (simplicity-first for solo dev compliance tool)
