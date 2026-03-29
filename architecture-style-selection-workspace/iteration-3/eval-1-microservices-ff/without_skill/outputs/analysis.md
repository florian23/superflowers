# Architecture Style Selection Analysis
## E-Commerce Replatforming

## Last Updated: 2026-03-29

## Context

An e-commerce platform is being replatformed from a monolith. Three autonomous teams will own independent domains. The teams have Kubernetes experience and will migrate gradually.

## Architecture Characteristics (Prioritized)

| Priority | Characteristic | Rationale |
|----------|---------------|-----------|
| 1 | Evolvability | 3 teams must evolve features independently without cross-team coordination bottlenecks |
| 2 | Maintainability | Each team owns a bounded context; changes must be isolated to one service |
| 3 | Scalability | Black Friday requires 50x checkout scaling and 10x catalog scaling independently |

## Architecture Style Evaluation

### Candidate Styles

| Style | Evolvability | Maintainability | Scalability | Team Fit | Migration Path |
|-------|-------------|----------------|-------------|----------|----------------|
| Modular Monolith | Medium | Medium | Low | High | Easy |
| Service-Based | High | High | Medium | High | Medium |
| Microservices | Very High | Very High | Very High | High (K8s) | Gradual (Strangler Fig) |
| Event-Driven Micro. | Very High | High | Very High | Medium | Complex |

### Decision Matrix (1-5 scale, weighted)

| Criterion (Weight) | Modular Monolith | Service-Based | Microservices | Event-Driven |
|---------------------|------------------|---------------|---------------|--------------|
| Evolvability (0.30) | 2 (0.60) | 3 (0.90) | 5 (1.50) | 5 (1.50) |
| Maintainability (0.25) | 3 (0.75) | 4 (1.00) | 4 (1.00) | 3 (0.75) |
| Scalability (0.25) | 1 (0.25) | 3 (0.75) | 5 (1.25) | 5 (1.25) |
| Team Topology Fit (0.10) | 4 (0.40) | 4 (0.40) | 5 (0.50) | 3 (0.30) |
| Migration Feasibility (0.10) | 5 (0.50) | 4 (0.40) | 3 (0.30) | 2 (0.20) |
| **Total** | **2.50** | **3.45** | **4.55** | **4.00** |

## Recommendation

**Microservices Architecture** is the recommended style.

### Justification

1. **Scalability demands are non-negotiable**: 50x checkout scaling cannot be achieved by scaling a monolith or coarse-grained services. Independent scaling of checkout, catalog, and order services is essential.
2. **Team autonomy requires deployment independence**: Three autonomous teams need independent deployment pipelines. Microservices provide the strongest deployment decoupling.
3. **K8s experience reduces operational overhead**: The primary cost of microservices (operational complexity) is mitigated by existing Kubernetes expertise.
4. **Strangler Fig enables gradual migration**: Services can be extracted one bounded context at a time, reducing risk compared to a big-bang rewrite.

### Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Distributed data consistency | Use saga pattern for checkout flow; eventual consistency for catalog |
| Service-to-service latency | API gateway with circuit breakers; async messaging for non-critical paths |
| Operational complexity | Standardized observability stack (metrics, traces, logs) per service |
| Distributed debugging | Correlation IDs mandatory in all service calls |

### Rejected Alternatives

- **Modular Monolith**: Cannot meet the 50x independent scaling requirement for checkout.
- **Service-Based**: Coarser granularity limits independent scaling; shared database risk undermines team autonomy.
- **Event-Driven Microservices**: Added complexity of event choreography without sufficient team experience; can evolve toward this later.
