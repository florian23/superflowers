# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics

1. Simplicity — Solo developer startup, must ship fast
2. Scalability — Expecting viral growth, need to handle 100x traffic within months
3. Elasticity — Unpredictable traffic spikes from social media mentions

## Architecture Style

**Modular Monolith on Elastic Container Platform**

Deploy a single modular monolith as a container on an auto-scaling platform (e.g., Google Cloud Run, AWS App Runner, Fly.io).

### Why This Style

- Resolves the tension between simplicity (solo dev, ship fast) and scalability/elasticity (viral growth, traffic spikes)
- Single codebase and deployment unit keeps cognitive and operational overhead minimal
- Platform-managed auto-scaling handles both sustained growth and unpredictable spikes
- Pay-per-use pricing matches bootstrapped budget
- Clean module boundaries provide an extraction path to services if/when needed

### Key Constraints

1. **Stateless application** — No in-memory sessions; use managed Redis or database for state
2. **Module boundaries** — Enforce clear domain boundaries in code (packages/modules with defined interfaces)
3. **Managed scalable database** — Use a serverless or auto-scaling database (PlanetScale, Neon, Supabase)
4. **Contract-first APIs** — Design inter-module interfaces as if they could become service boundaries

### Migration Path

When team and traffic grow beyond what the monolith can handle:
1. Identify hotspot modules via monitoring
2. Extract hotspot into a separate service behind the existing API contract
3. Repeat only as needed — avoid premature decomposition

## Architecture Drivers

- Solo developer building MVP
- Expecting rapid growth if product-market fit is found
- Budget: bootstrapped, minimal infrastructure spend initially

## Changelog

- 2026-03-29: Initial assessment — selected Modular Monolith on Elastic Container Platform to balance simplicity against scalability/elasticity requirements
