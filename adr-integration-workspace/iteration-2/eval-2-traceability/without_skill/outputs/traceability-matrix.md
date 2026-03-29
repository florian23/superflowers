# ADR-to-Fitness-Function Traceability Matrix

## FF-to-ADR Mapping

| Fitness Function | Type | Governing ADR | Rationale |
|---|---|---|---|
| FF-1: Service Independence | Style | ADR-001 (Microservices) | Microservices require independently deployable services; validates no shared-database coupling |
| FF-2: API Contract Stability | Style | ADR-001 (Microservices) | Service boundaries demand stable, versioned API contracts between services |
| FF-3: Service Size Threshold | Style | ADR-001 (Microservices) | Microservices should remain small and focused; guards against monolith creep |
| FF-4: Inter-Service Communication Latency | Style | ADR-001 (Microservices) | Distributed microservices must keep synchronous call chains within acceptable latency bounds |
| FF-5: Deployment Independence | Style | ADR-001 (Microservices) | Each microservice must be independently buildable and deployable without coordinated releases |
| FF-6: Horizontal Scalability | Characteristic | ADR-002 (Scalability + Fault Tolerance + Evolvability) | Scalability priority requires services to scale out under load within defined thresholds |
| FF-7: Fault Isolation and Recovery | Characteristic | ADR-002 (Scalability + Fault Tolerance + Evolvability) | Fault tolerance priority requires failures in one service not to cascade; recovery time must meet SLA |

## ADR-to-FF Mapping

### ADR-001: Use Microservices Architecture

- **Status:** Accepted
- **Produces:** 5 style fitness functions

| FF | What It Guards |
|---|---|
| FF-1: Service Independence | No shared databases or tight runtime coupling |
| FF-2: API Contract Stability | Versioned contracts, no breaking changes without deprecation |
| FF-3: Service Size Threshold | Lines of code / responsibility scope stays within bounds |
| FF-4: Inter-Service Communication Latency | p95 latency of synchronous call chains under threshold |
| FF-5: Deployment Independence | Each service deployable in isolation; no coordinated releases |

### ADR-002: Prioritize Scalability, Fault Tolerance, and Evolvability

- **Status:** Accepted
- **Produces:** 2 characteristic fitness functions

| FF | What It Guards |
|---|---|
| FF-6: Horizontal Scalability | Auto-scaling response time and throughput under load |
| FF-7: Fault Isolation and Recovery | Blast radius containment and MTTR within SLA |

## Orphan Analysis

| Category | Items | Status |
|---|---|---|
| Orphaned FFs (no governing ADR) | None | All 7 FFs trace to an ADR |
| ADRs without FFs | None | Both ADRs produce at least one FF |
| Evolvability coverage gap | ADR-002 lists Evolvability as a priority but no dedicated FF guards it | **Gap identified** |

## Summary

- **Total ADRs:** 2
- **Total Fitness Functions:** 7 (5 style + 2 characteristic)
- **Full traceability:** All FFs map to a governing ADR; all ADRs produce at least one FF
- **Coverage gap:** ADR-002 names three architecture characteristics (Scalability, Fault Tolerance, Evolvability) but only two FFs exist, leaving Evolvability unguarded
