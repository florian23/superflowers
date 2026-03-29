# Architecture Style Analysis

## Context
- **System**: Internal compliance tool
- **Team**: 1 developer
- **Budget**: Minimal
- **Lifespan**: Long-lived internal system
- **Priority Characteristics**: Simplicity, Testability, Maintainability

## Candidate Styles Evaluated

### 1. Modular Monolith
| Characteristic | Score (1-5) | Rationale |
|---|---|---|
| Simplicity | 5 | Single deployable, no distributed systems complexity, one repo, one build |
| Testability | 5 | Module boundaries enable isolated unit/integration tests; no network mocking needed |
| Maintainability | 5 | Enforced module boundaries prevent spaghetti; clear ownership per module |
| **Total** | **15** | |

### 2. Layered Monolith (Traditional)
| Characteristic | Score (1-5) | Rationale |
|---|---|---|
| Simplicity | 4 | Simple to start but layers blur over time without enforced boundaries |
| Testability | 3 | Cross-layer dependencies make isolated testing harder |
| Maintainability | 2 | Layers degrade into a big ball of mud without strict discipline |
| **Total** | **9** | |

### 3. Microservices
| Characteristic | Score (1-5) | Rationale |
|---|---|---|
| Simplicity | 1 | Massive operational overhead for a solo developer |
| Testability | 3 | Each service testable in isolation but integration testing is complex |
| Maintainability | 3 | Good separation but 1 dev cannot maintain multiple deployables, infra, networking |
| **Total** | **7** | |

### 4. Event-Driven
| Characteristic | Score (1-5) | Rationale |
|---|---|---|
| Simplicity | 2 | Message brokers, async flows, eventual consistency add significant complexity |
| Testability | 2 | Async event flows are notoriously difficult to test deterministically |
| Maintainability | 3 | Decoupled but hard to trace and debug for a single developer |
| **Total** | **7** | |

## Decision

**Selected Style: Modular Monolith**

The modular monolith scores highest across all three priority characteristics. It gives a solo developer the deployment simplicity of a monolith while enforcing module boundaries that prevent the maintainability decay seen in traditional layered architectures. Testability is maximized because modules can be tested in isolation without network mocking or container orchestration.

### Key Trade-offs Accepted
- **Scalability**: Limited to vertical scaling. Acceptable for an internal compliance tool with a small, known user base.
- **Independent Deployability**: Not possible. Acceptable because there is only one developer and one release cadence.
- **Technology Diversity**: Locked to one tech stack per module. Acceptable given team size and budget.

### Migration Path
If requirements change (e.g., team grows, external users added), the enforced module boundaries make it straightforward to extract modules into independent services later.
