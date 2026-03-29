# ADR-001: Use Service-Based architecture

## Status
Accepted

## Context
We need to select an architecture style for our system. The team evaluated all 8 architecture styles using a weighted scoring matrix against our driving architecture characteristics.

**Alternatives considered:**

- **Service-Based architecture** — Scored 14/15 at $$ cost. Supports gradual migration from the existing monolith with coarse-grained domain services. Well-suited for our team topology of 3 teams with 4-6 developers each, where each team can own one or more domain services without excessive coordination overhead.
- **Microservices architecture** — Scored 15/15 at $$$$$ cost. Achieves maximum scores across all driving characteristics but requires significant infrastructure investment (service mesh, container orchestration, distributed tracing, CI/CD per service) and demands a level of operational maturity disproportionate to our current team size and structure.

Other styles (layered, pipeline, microkernel, event-driven, space-based, service-oriented) scored lower and were not serious contenders.

**Key forces:**
- The system is currently a monolith that must be migrated incrementally — a big-bang rewrite is not feasible.
- We have 3 teams of 4-6 developers. Microservices would require either more teams or significantly more DevOps investment per team.
- The cost differential between $$ and $$$$$ is substantial and not justified by the 1-point scoring difference.

## Decision
We will use Service-Based architecture because it delivers nearly the same architecture characteristic coverage as Microservices (14/15 vs 15/15) at a fraction of the cost, while naturally supporting our gradual monolith migration strategy and aligning with our team structure of 3 teams of 4-6 developers.

## Consequences
**Easier:**
- Gradual migration from the monolith — we can extract domain services one at a time without disrupting the running system.
- Team autonomy — each team owns one or more coarse-grained services with clear boundaries, without needing to coordinate dozens of fine-grained microservices.
- Operational simplicity — fewer deployable units mean simpler CI/CD pipelines, monitoring, and debugging compared to microservices.
- Lower infrastructure cost — no need for service mesh, advanced container orchestration, or per-service CI/CD from day one.

**Harder:**
- Fine-grained scalability — we cannot independently scale sub-components within a domain service the way microservices allow.
- If the system grows significantly beyond 3 teams, the coarse-grained service boundaries may become bottlenecks and we may need to decompose further toward microservices (see: evolutionary architecture).
- We accept a 1-point gap in architecture characteristic coverage (14/15 vs 15/15), which may surface as a constraint if that missing point maps to a critical scenario under load.
