# Architecture Style Selection Analysis

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics from architecture.md

**Top 3 Priority Characteristics:**
1. **Simplicity** -- Must ship MVP in 4 weeks with 1 dev
2. **Scalability** -- Expect viral growth if product-market fit
3. **Elasticity** -- Social media spikes unpredictable

**Architecture Drivers:**
- Solo developer, bootstrapped, 4-week deadline
- If successful: viral growth, need to scale fast

## Step 2: Architecture Style Fit Analysis

Top 3 Driving Characteristics: Simplicity, Scalability, Elasticity

| Rank | Style | Simplicity | Scalability | Elasticity | Fit Score | Cost |
|------|-------|------------|-------------|------------|-----------|------|
| 1 | Service-Based | ★★★☆☆ (3) | ★★★★☆ (4) | ★★★☆☆ (3) | 10/15 | $$ |
| 2 | Modular Monolith | ★★★★★ (5) | ★☆☆☆☆ (1) | ★☆☆☆☆ (1) | 7/15 | $ |
| 3 | Microkernel | ★★★★★ (5) | ★☆☆☆☆ (1) | ★☆☆☆☆ (1) | 7/15 | $ |
| 4 | Layered | ★★★★★ (5) | ★☆☆☆☆ (1) | ★☆☆☆☆ (1) | 7/15 | $ |
| 5 | Event-Driven | ★★☆☆☆ (2) | ★★★★★ (5) | ★★★★★ (5) | 12/15 | $$$ |
| 6 | Space-Based | ★☆☆☆☆ (1) | ★★★★★ (5) | ★★★★★ (5) | 11/15 | $$$$ |
| 7 | Microservices | ★☆☆☆☆ (1) | ★★★★★ (5) | ★★★★★ (5) | 11/15 | $$$$$ |
| 8 | Service-Oriented | ★☆☆☆☆ (1) | ★★★☆☆ (3) | ★★★☆☆ (3) | 7/15 | $$$$ |

**Key observation: No style scores well on ALL three characteristics. This is a fundamental conflict.**

## Conflict Analysis: Simplicity vs. Scalability/Elasticity

The driving characteristics are inherently contradictory:

- **Simplicity** (★★★★★) lives in: Layered, Modular Monolith, Microkernel
- **Scalability + Elasticity** (★★★★★ + ★★★★★) lives in: Microservices, Event-Driven, Space-Based

These two groups share zero overlap. Every simple architecture scores 1/5 on scalability and elasticity. Every scalable/elastic architecture scores 1-2/5 on simplicity. There is no style that excels at all three.

This is not a tie to be broken with context questions -- it is a **structural conflict** that requires a phased approach.

## Step 3: Tradeoff Analysis of Top Candidates

### Candidate 1: Modular Monolith (Start Here)

- **Fit Score:** 7/15 (but 5/5 on the most time-critical characteristic)
- **Strengths:** Maximum simplicity. 1 dev can ship MVP in 4 weeks. Single deployment, single database, minimal operational overhead.
- **Weaknesses:** Scalability (1/5) and elasticity (1/5) are terrible. If viral growth happens, this architecture will hit a ceiling.
- **Cost:** $ -- Fits a bootstrapped solo developer perfectly.
- **Partitioning:** Domain -- Clean module boundaries enable future extraction.
- **Why consider it:** Simplicity is the gating constraint. If you miss the 4-week deadline, scalability is irrelevant because there's no product.

### Candidate 2: Service-Based (Evolve To)

- **Fit Score:** 10/15 -- Best balanced score across all three characteristics
- **Strengths:** Moderate scalability (4/5) and elasticity (3/5) without the operational complexity of microservices. 4-12 coarser-grained services are manageable.
- **Weaknesses:** Simplicity (3/5) is average -- a solo dev can handle it but it's slower to build initially. Not as elastic as event-driven or space-based.
- **Cost:** $$ -- Reasonable for a growing startup.
- **Partitioning:** Domain -- Natural evolution from modular monolith.
- **Why consider it:** The pragmatic middle ground. When the monolith's scaling limits hurt, this is the next step.

### Candidate 3: Event-Driven (Highest Raw Score -- but Disqualified for Phase 1)

- **Fit Score:** 12/15 -- Highest raw score
- **Strengths:** Best-in-class scalability (5/5) and elasticity (5/5). Perfect for unpredictable social media spikes.
- **Weaknesses:** Simplicity (2/5). A solo dev building an event-driven system in 4 weeks is extremely risky. Async processing adds debugging complexity, eventual consistency headaches, and infrastructure overhead (message brokers, dead letter queues).
- **Cost:** $$$ -- Requires message broker infrastructure from day one.
- **Why not Phase 1:** Per the Red Flags rule: "If simplicity is a driving characteristic AND the system is new, distributed architectures should be questioned even if they score well on other characteristics." This applies directly.

## Step 4: Qualifying Context

Given the structural conflict, context questions confirm what the drivers already tell us:

| Question | Answer (from drivers) | Implication |
|---|---|---|
| Team size? | 1 solo developer | Rules out microservices, event-driven, space-based for Phase 1 |
| Budget? | Bootstrapped | Rules out $$$+ styles for Phase 1 |
| Deadline? | 4 weeks | Only $ styles are realistic |
| Growth trajectory? | Viral if PMF | Must have an evolution path to scalable styles |
| Experience with distributed systems? | Not stated (solo dev) | Conservative assumption: avoid distributed complexity initially |

## Recommendation: Phased Architecture with Evolution Path

**Phase 1 (Now -- MVP, 4 weeks): Modular Monolith**
- Ship fast. Clean domain module boundaries. Single deployment.
- Simplicity: ★★★★★ -- meets the gating constraint
- Prepare for evolution by enforcing module boundaries with fitness functions

**Phase 2 (Post-PMF, when scaling hurts): Service-Based**
- Extract domain modules into 4-8 coarser services
- Scalability: ★★★★ / Elasticity: ★★★ -- handles significant growth
- Shared database initially, migrate to per-service schemas over time

**Phase 3 (If needed, viral scale): Selective Event-Driven for hot paths**
- Only for components that need extreme elasticity (e.g., notification fan-out, feed generation)
- Scalability: ★★★★★ / Elasticity: ★★★★★
- Keep non-critical paths service-based

This phased approach is not "we'll need microservices eventually" rationalization -- it is a deliberate response to a measured conflict between driving characteristics. The modular monolith's domain partitioning and enforced module boundaries make Phase 2 extraction a mechanical refactor, not a rewrite.
