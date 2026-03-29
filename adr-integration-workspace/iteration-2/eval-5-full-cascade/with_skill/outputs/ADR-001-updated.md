# ADR-001: Use Modular Monolith

## Status
Superseded by ADR-006

## Context
The team started as a single co-located team building a new system. Simplicity, testability, and maintainability were identified as the top-3 driving characteristics. A modular monolith was considered alongside layered monolith and service-based architecture.

The modular monolith scored highest for the driving characteristics while keeping cost low, making it the clear winner for a single-team setup.

## Decision
We will use a Modular Monolith architecture because it best supports simplicity, testability, and maintainability for a single team, with low operational overhead and a clear evolution path toward services if needed.

## Consequences
- Easier: Simple deployment (single artifact), straightforward testing, low operational overhead, fast local development
- Harder: Independent scaling of modules not possible, all modules share the same release cycle, team boundaries harder to enforce as the team grows
- Accepted tradeoff: Limited independent deployability in exchange for simplicity
