# Architecture Characteristics
## Last Updated: 2026-03-29
## Top 3 Priority Characteristics
1. Evolvability — Need to add features rapidly
2. Scalability — Growing from 1k to 100k users over 2 years
3. Deployability — Multiple deploys per day
## Architecture Drivers
- Startup growing fast, currently small team (4 devs), will grow to 3 teams
- Need to start simple but be ready to scale
- Budget: moderate, growing with revenue
## Changelog
- 2026-03-29: Initial assessment
- 2026-03-29: Architecture style selected — Service-Based with evolution path

## Selected Architecture Style

**Style:** Service-Based
**Partitioning:** Domain
**Cost Category:** $$

### Selection Rationale
- Driving characteristics: Evolvability (★★★★★), Scalability (★★★★), Deployability (★★★★)
- Fit score: 13/15
- Scores within 2 points of Microservices (15/15) at 1/5 the cost ($$  vs $$$$$)
- Team of 4 devs cannot sustain Microservices operational overhead — Service-Based provides the best cost-to-benefit ratio
- Domain partitioning aligns with planned growth to 3 teams, each owning 1-3 services

### Tradeoffs Accepted
- Scalability: Rated 4/5 — Sufficient for growth to 100k users. If specific domains need 5/5, extract those to microservices in Phase 2/3
- Simplicity: Rated 3/5 — More complex than monolith but manageable for a small team. Acceptable given the high evolvability and deployability requirements
- Elasticity: Rated 3/5 — Adequate for gradual growth. If burst capacity becomes critical, event-driven patterns can be added selectively

### Evolution Path

| Phase | Style | Trigger | Fitness Functions |
|-------|-------|---------|-------------------|
| **Phase 1 (now)** | Service-Based | Starting point — 4 devs, 1 team, 1k users | Service-Based fitness functions (below) |
| **Phase 2 (6-12 months)** | Service-Based + selective Microservices | Specific services need independent scaling OR team grows to 3 teams | Add Microservices fitness functions for extracted services |
| **Phase 3 (12-24 months)** | Microservices (high-scale domains) + Service-Based (rest) | User base approaches 100k, specific domains need 5/5 scalability | Full Microservices fitness functions for extracted domains |

Phase transitions are triggered by measurable criteria, not predictions. Each transition adds new fitness functions — previous ones are NOT removed unless the style explicitly replaces them.

### Architecture Style Fitness Functions

These fitness functions enforce the selected style's structural invariants. They are mandatory and immutable — if the implementation violates them, the implementation must change, not the fitness function.

**Current Phase: Phase 1 — Service-Based**

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| Service boundary alignment | Services align with documented domain boundaries | Directory/package structure check |
| Limited service count | Total number of services within defined range (typically 4-12) | Service registry/count check |
| No service-to-service chatter | Service-to-service calls within defined limits (< N calls per request) | Runtime tracing or static call graph |
| Database sharing discipline | If shared DB: each service accesses only its own tables/views | SQL analysis, ORM scope check |

> **Note:** Only Phase 1 (Service-Based) fitness functions are active. When the team transitions to Phase 2, Microservices fitness functions will be added for any extracted services. Phase 1 fitness functions remain in effect for services that stay Service-Based.
