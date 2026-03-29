# ADR-001: Use Service-Based Architecture

## Status

**Superseded** by [ADR-005](ADR-005.md)

## Date

Original: 2024-01-15
Superseded: 2026-03-29

## Context

The system was initially designed as a service-based architecture to decompose the monolith into coarse-grained services sharing a database. At the time, this was appropriate given the team size (2 teams) and the moderate scaling requirements.

## Decision

Adopt a service-based architecture style with 4-7 domain-aligned services communicating via REST, sharing a single database partitioned by schema.

## Consequences

### Positive

- Reduced deployment coupling compared to the monolith
- Simpler operational model than microservices
- Shared database simplified data consistency

### Negative

- Shared database became a scaling bottleneck as load grew
- Coarse-grained services limited independent team deployability
- Unable to scale individual functions independently under high-traffic scenarios

## Supersession Rationale

With the growth to 5 independent teams and the need for finer-grained scaling at the individual service level, the service-based approach no longer meets our architectural requirements. ADR-005 documents the migration to a microservices architecture that addresses these constraints.
