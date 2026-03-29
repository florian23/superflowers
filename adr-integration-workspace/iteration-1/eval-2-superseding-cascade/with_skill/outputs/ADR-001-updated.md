# ADR-001: Use Service-Based architecture

## Status
Superseded by ADR-005

## Context
The team needed an architecture style that balanced modularity with operational simplicity. With 2 teams and moderate scaling requirements, a fully distributed architecture (microservices) was considered too complex. A monolithic approach lacked the service isolation needed for independent team workflows. Service-Based architecture offered a middle ground: domain-aligned services with a shared deployment model and manageable operational overhead.

## Decision
We will use Service-Based architecture because it provides domain-level service boundaries (4-12 coarse-grained services) with lower operational cost than microservices, matching our current team size and scaling needs.

## Consequences
- Easier: Teams can work on separate services with clear domain boundaries
- Easier: Fewer services to monitor and deploy compared to microservices
- Harder: Shared database requires discipline to avoid cross-service table access
- Harder: Coarse-grained services limit independent scaling of individual capabilities
- Accepted tradeoff: Limited service count means less deployment independence than microservices
