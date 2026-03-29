# Architecture Style Fit Analysis

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Input: Driving Characteristics from architecture.md

**Top 3 Priority Characteristics:**
1. **Evolvability** — Independent feature evolution across 3 teams
2. **Maintainability** — Each team owns their domain independently
3. **Scalability** — Black Friday: 50x checkout, 10x catalog

**Architecture Drivers:**
- 3 autonomous teams (catalog, checkout, fulfillment), each 4-6 devs
- Legacy monolith: gradual migration preferred (Strangler Fig pattern implied)
- Revenue-critical system
- Kubernetes experience available
- Reasonable budget

## Step 2: Score All 8 Styles Against the Matrix

Ratings sourced from `references/architecture-styles-matrix.md`.

| Rank | Style | Evolvability | Maintainability | Scalability | Fit Score | Cost |
|------|-------|-------------|-----------------|-------------|-----------|------|
| 1 | Microservices | ★★★★★ (5) | ★★★★★ (5) | ★★★★★ (5) | **15/15** | $$$$$ |
| 2 | Service-Based | ★★★★★ (5) | ★★★★★ (5) | ★★★★ (4) | **14/15** | $$ |
| 3 | Event-Driven | ★★★★★ (5) | ★★★ (3) | ★★★★★ (5) | **13/15** | $$$ |
| 4 | Space-Based | ★★★ (3) | ★★★ (3) | ★★★★★ (5) | **11/15** | $$$$ |
| 5 | Microkernel | ★★★ (3) | ★★★ (3) | ★ (1) | **7/15** | $ |
| 6 | Service-Oriented | ★ (1) | ★ (1) | ★★★ (3) | **5/15** | $$$$ |
| 7 | Modular Monolith | ★ (1) | ★★ (2) | ★ (1) | **4/15** | $ |
| 8 | Layered | ★ (1) | ★ (1) | ★ (1) | **3/15** | $ |

**Top 3 Candidates:** Microservices (15), Service-Based (14), Event-Driven (13)

## Step 3: Tradeoff Analysis of Top Candidates

### Candidate 1: Microservices (15/15, $$$$$)

**Strengths:**
- Perfect score across all three driving characteristics
- Domain partitioning aligns naturally with 3 autonomous teams (catalog, checkout, fulfillment)
- Independent deployability enables each team to release on their own cadence
- Strong fault tolerance (5/5) — critical for revenue-critical system

**Weaknesses:**
- **Cost ($$$$$):** Most expensive style. Requires service mesh, distributed tracing, container orchestration, API gateways, per-service CI/CD pipelines
- **Simplicity (1/5):** Significant operational complexity — distributed transactions, eventual consistency, network latency
- **Testability (5/5):** Good in isolation, but integration/end-to-end testing across services is hard
- Gradual migration from monolith to full microservices is a multi-year effort

**Cost implication:** Maximum cost for maximum capability. With 3 teams of 4-6 devs (12-18 total), the operational overhead of a full microservices architecture is significant. Each team needs DevOps capability.

**Partitioning:** Domain — aligns perfectly with the 3-team structure.

### Candidate 2: Service-Based (14/15, $$)

**Strengths:**
- Near-perfect fit at a fraction of the cost ($$)
- Evolvability (5/5) and maintainability (5/5) match microservices
- Domain partitioning — coarser-grained services map directly to team boundaries (catalog service, checkout service, fulfillment service)
- Shared database simplifies data consistency for revenue-critical transactions
- Pragmatic middle ground: simpler than microservices, much more capable than monolith
- Ideal for gradual migration from monolith (Strangler Fig pattern fits naturally with 4-12 services)

**Weaknesses:**
- **Scalability (4/5):** One point below microservices. Services are coarser, so scaling is less granular. However, 4/5 still represents good horizontal scaling capability
- **Elasticity (3/5):** Burst scaling less fine-grained than microservices. For Black Friday 50x checkout, the checkout service may need to be decomposed further
- Shared database can become a bottleneck under extreme load

**Cost implication:** Dramatically lower cost than microservices. Fewer services means fewer pipelines, simpler networking, less operational overhead. The $$ cost is well within "reasonable budget."

**Partitioning:** Domain — maps 1:1 to teams.

### Candidate 3: Event-Driven (13/15, $$$)

**Strengths:**
- Excellent evolvability (5/5) and scalability (5/5)
- Outstanding elasticity (5/5) — handles Black Friday spikes naturally
- Strong fault tolerance (5/5) — event replay, dead letter queues
- Natural fit for order workflows (order placed -> payment processed -> fulfillment triggered)

**Weaknesses:**
- **Maintainability (3/5):** Event flows are harder to trace and debug than direct service calls
- **Testability (2/5):** Async event chains are notoriously difficult to test
- **Simplicity (2/5):** Event choreography vs orchestration decisions add complexity
- Technical partitioning — does not naturally align with team boundaries
- Error handling in async flows requires careful design (compensating transactions, saga patterns)

**Cost implication:** Moderate cost ($$$). Requires message broker infrastructure (Kafka/RabbitMQ), event schema registry, monitoring for event flows.

**Partitioning:** Technical — would require additional team coordination conventions to align with 3 domain teams.

## Step 4: Qualifying Context Assessment

Scores are close between Microservices (15) and Service-Based (14) — only 1 point difference. Qualifying context resolves this:

| Factor | Assessment | Favors |
|--------|-----------|--------|
| Team size: 3 teams of 4-6 | Medium teams. Microservices operational overhead is manageable but stretches capacity. Service-based is more proportionate. | Service-Based |
| K8s experience | Reduces operational barrier for distributed architectures. Teams can handle service deployment. | Microservices (slightly) |
| Budget: reasonable | Not unlimited. $$$$$ needs strong justification when $$ achieves 14/15. | **Service-Based** |
| Gradual migration | Service-based maps naturally to Strangler Fig: extract coarse services first. Microservices require more upfront decomposition. | **Service-Based** |
| Revenue-critical | Shared database in service-based provides stronger transactional guarantees for checkout. Distributed transactions in microservices add failure risk. | **Service-Based** |
| Black Friday 50x checkout | Service-based at 4/5 scalability may need the checkout service decomposed further. This is a minor concern — one service can be split later. | Microservices (slightly) |

**Verdict:** Service-Based architecture is the recommended style. It scores 14/15 at $$ cost, aligns with all qualifying context factors, and provides a natural evolution path toward microservices if needed.

## Recommendation

**Primary: Service-Based Architecture**

The 1-point gap to microservices does not justify the 3x+ cost increase ($$ vs $$$$$). Service-based architecture delivers the same evolvability and maintainability scores, with scalability at 4/5 that is sufficient for all but the most extreme scenarios. The checkout service can be further decomposed if Black Friday loads outgrow the coarse-grained service boundary.

**Evolution path:** Start service-based with 3 domain services (catalog, checkout, fulfillment). If Black Friday scaling demands exceed service-based capacity, extract the checkout service into finer-grained microservices. This "grow into microservices" approach avoids premature distribution while keeping the door open.

**Event-Driven as a complement, not a replacement:** Consider event-driven patterns within the service-based architecture (e.g., order events between checkout and fulfillment) without adopting full event-driven as the primary style.
