# Architecture Style Selection — E-Commerce Replatforming

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

From `architecture.md`:

| # | Characteristic | Concrete Goal |
|---|---|---|
| 1 | **Evolvability** | Independent deployments per team |
| 2 | **Maintainability** | No cross-team code ownership |
| 3 | **Scalability** | 50x traffic on checkout during sales events |

## Step 2: Architecture Style Fit Analysis

Top 3 Driving Characteristics: Evolvability, Maintainability, Scalability

| Rank | Style | Evolvability | Maintainability | Scalability | Fit Score | Cost |
|------|-------|-------------|-----------------|-------------|-----------|------|
| 1 | **Microservices** | ★★★★★ | ★★★★★ | ★★★★★ | **15/15** | $$$$$ |
| 2 | **Service-Based** | ★★★★★ | ★★★★★ | ★★★★ | **14/15** | $$ |
| 3 | **Event-Driven** | ★★★★★ | ★★★ | ★★★★★ | **13/15** | $$$ |
| 4 | Space-Based | ★★★ | ★★★ | ★★★★★ | 11/15 | $$$$ |
| 5 | Microkernel | ★★★ | ★★★ | ★ | 7/15 | $ |
| 6 | Service-Oriented | ★ | ★ | ★★★ | 5/15 | $$$$ |
| 7 | Modular Monolith | ★ | ★★ | ★ | 4/15 | $ |
| 8 | Layered | ★ | ★ | ★ | 3/15 | $ |

## Step 3: Tradeoff Analysis

### Microservices (15/15, $$$$$)

**Strengths:**
- Perfect score across all 3 driving characteristics
- Domain partitioning aligns with 3 autonomous teams (catalog, checkout, fulfillment)
- Maximum independent deployability — each team ships independently
- Best testability (5/5) and deployability (5/5) as bonus

**Weaknesses:**
- Cost: $$$$$ — highest cost category. Requires service mesh, API gateway, distributed tracing, container orchestration
- Simplicity: 1/5 — significant operational complexity
- Responsiveness: 2/5 — inter-service communication adds latency

### Service-Based (14/15, $$)

**Strengths:**
- Only 1 point behind Microservices at a fraction of the cost
- Same evolvability and maintainability (both 5/5)
- Domain partitioning — coarser services still map to team boundaries
- Scalability 4/5 — sufficient for most traffic patterns, individual services can scale independently
- Simpler operational model than microservices

**Weaknesses:**
- Scalability: 4/5 vs 5/5 — may struggle with extreme 50x checkout spikes
- Coarser services mean less granular scaling (whole checkout service vs individual checkout functions)

### Event-Driven (13/15, $$$)

**Strengths:**
- Excellent scalability and evolvability (both 5/5)
- Good for asynchronous workflows (order processing, inventory updates, notifications)

**Weaknesses:**
- Maintainability: 3/5 — drops significantly compared to top 2 candidates
- Technical partitioning conflicts with domain-team structure
- Less natural for synchronous e-commerce flows (browse → add to cart → checkout)

## Step 4: Qualifying Context Questions

Scores are close between Microservices (15/15) and Service-Based (14/15). Qualifying questions:

**Q: How large are the teams?**
A: 3 teams of 4-6 developers each — sufficient for distributed architecture ownership.

**Q: What's the team's experience with distributed systems?**
A: Experienced with Docker/Kubernetes — operational complexity of microservices is manageable.

**Q: Are there budget constraints?**
A: Budget is not the primary concern but should be reasonable.

**Q: Is this a big-bang migration or gradual?**
A: **Gradual migration from monolith preferred** — this is the decisive factor.

## Step 5: Recommendation

**Service-Based Architecture** as the initial target, with an evolution path toward selective microservices.

### Why Service-Based over Microservices?

1. **Gradual migration**: Service-Based is ideal for strangler fig pattern. Extract 4-6 coarse services from the monolith (catalog-service, checkout-service, fulfillment-service, user-service). This is achievable incrementally.

2. **Cost efficiency**: $$ vs $$$$$ — the 1-point gap on scalability (4 vs 5) doesn't justify the cost difference for 90% of the year. Black Friday is 1-2 days.

3. **Team alignment**: 3 teams map to 3-4 coarse services. Each team owns their service completely. No need for 20+ microservices when 3 teams can own 4-6 services.

4. **Scalability gap is bridgeable**: For the 50x Black Friday spikes specifically on checkout, the checkout service can be further decomposed into microservices later — a targeted evolution rather than premature full microservices.

### Evolution Path

```
Phase 1: Strangler Fig → 4-6 Service-Based services (catalog, checkout, fulfillment, user)
Phase 2: Stabilize → each team owns their service, independent deploys
Phase 3: Selective extraction → decompose checkout into microservices for 50x scaling
Phase 4: Event-Driven augmentation → async workflows (order events, inventory sync) via event bus
```
