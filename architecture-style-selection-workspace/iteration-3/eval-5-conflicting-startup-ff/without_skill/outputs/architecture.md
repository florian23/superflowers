# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics

1. Simplicity — Must ship MVP in 4 weeks with 1 dev
2. Scalability — Expect viral growth if product-market fit
3. Elasticity — Social media spikes unpredictable

## Architecture Drivers

- Solo developer, bootstrapped, 4-week deadline
- If successful: viral growth, need to scale fast

## Selected Architecture Style

**Modular Monolith** — single deployable container with enforced internal module boundaries.

### Why This Style

- Satisfies simplicity constraint: 1 artifact, 1 pipeline, 1 developer can ship in 4 weeks.
- Enables scalability path: clean module boundaries allow extraction to services when growth demands it.
- Handles elasticity: stateless container + platform auto-scaling (Cloud Run / Fly.io) absorbs traffic spikes.

### Key Constraints

- All modules communicate through defined public interfaces only.
- No shared mutable state between modules.
- No in-process session state (stateless for horizontal scaling).
- Database-per-module schema separation (shared DB instance, separate schemas).

## Fitness Functions

| ID | Name | Metric | Threshold | Measurement |
|---|---|---|---|---|
| FF-1 | Deployment Simplicity | Deployed artifact count | = 1 | CI/CD pipeline check |
| FF-2 | Module Coupling | Cross-module internal imports | = 0 | Static analysis lint rule |
| FF-3 | Horizontal Scalability | Stateless endpoint ratio | 100% | Multi-instance integration test |
| FF-4 | Response Time Under Load | p95 at 10x traffic | < 500ms | Weekly load test (k6) |
| FF-5 | Module Extraction Readiness | Modules testable in isolation | 100% | Per-module isolated CI job |

## Migration Triggers

- Single module > 60% of compute: extract that module.
- Team > 3 devs on same module: extract for independent deployment.
- Deployment blocked by unrelated module changes: extract to decouple release cycles.

## Changelog

- 2026-03-29: Initial assessment — selected Modular Monolith with 5 fitness functions
