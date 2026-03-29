# ADR-001: Use REST for Booking API

## Status
Accepted

## Context
The Booking API needs a communication style for its web frontend clients. The team considered three alternatives during brainstorming:

1. **REST** — Well-understood by the team, mature tooling, straightforward for CRUD operations.
2. **GraphQL** — Flexible queries, single endpoint, client-driven data fetching.
3. **gRPC** — High performance, strong typing via Protobuf, bidirectional streaming.

Key forces:
- The team has existing REST experience and no GraphQL or gRPC expertise.
- Clients are simple web frontends with straightforward CRUD needs — no complex or flexible query requirements.
- Browser clients cannot call gRPC services directly without a proxy layer (grpc-web).

## Decision
We will use REST for the Booking API because the team has REST experience, the clients are simple web frontends with CRUD requirements, and there is no need for flexible queries that would justify GraphQL's additional complexity.

## Consequences
**Easier:**
- Fast onboarding — the team can start immediately without learning a new paradigm.
- Simple client integration — standard HTTP calls from any browser, no special client libraries needed.
- Broad ecosystem support — caching (HTTP caching, CDNs), monitoring, and debugging tooling works out of the box.

**Harder:**
- If query requirements become more complex (e.g., multiple frontends needing different data shapes), REST endpoints may proliferate or require backend-for-frontend patterns.
- No built-in schema evolution guarantees — API versioning must be managed manually (unlike Protobuf's backward compatibility).
- Over-fetching or under-fetching may occur if data needs diverge across clients in the future.
