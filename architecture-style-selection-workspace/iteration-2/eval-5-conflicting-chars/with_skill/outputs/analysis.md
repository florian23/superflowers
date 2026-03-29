# Architecture Style Selection Analysis

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

Extracted from `architecture.md`:

**Top 3 Priority Characteristics:**
1. **Simplicity** — Solo developer startup, must ship fast
2. **Scalability** — Expecting viral growth, need to handle 100x traffic within months
3. **Elasticity** — Unpredictable traffic spikes from social media mentions

**Architecture Drivers:**
- Solo developer building MVP
- Expecting rapid growth if product-market fit is found
- Budget: bootstrapped, minimal infrastructure spend initially

**Conflict Identified:** Simplicity pulls strongly toward monolithic styles (Layered, Modular Monolith, Microkernel all score 5/5). Scalability and Elasticity pull strongly toward distributed styles (Microservices, Event-Driven, Space-Based all score 5/5 on both). No single style excels at all three simultaneously. This is a classic "start simple vs. build for scale" tension.

## Step 2: Score Styles Against Matrix

Top 3 Driving Characteristics: Simplicity, Scalability, Elasticity

| Rank | Style | Simplicity | Scalability | Elasticity | Fit Score | Cost |
|------|-------|------------|-------------|------------|-----------|------|
| 1 | Event-Driven | ★★ | ★★★★★ | ★★★★★ | 12/15 | $$$ |
| 2 | Microservices | ★ | ★★★★★ | ★★★★★ | 11/15 | $$$$$ |
| 3 | Space-Based | ★ | ★★★★★ | ★★★★★ | 11/15 | $$$$ |
| 4 | Service-Based | ★★★ | ★★★★ | ★★★ | 10/15 | $$ |
| 5 | Layered | ★★★★★ | ★ | ★ | 7/15 | $ |
| 5 | Modular Monolith | ★★★★★ | ★ | ★ | 7/15 | $ |
| 5 | Microkernel | ★★★★★ | ★ | ★ | 7/15 | $ |
| 8 | Service-Oriented | ★ | ★★★ | ★★★ | 7/15 | $$$$ |

**Top 3 Candidates:** Event-Driven (12), Microservices (11), Space-Based (11)

However, scores are close between the top 3 (within 1 point), and the conflict with simplicity is severe. Service-Based (10) is close behind and offers a much better balance.

## Step 3: Tradeoff Analysis

### Candidate 1: Event-Driven (12/15, $$$)

- **Strengths:** Highest fit score. Excellent scalability (5) and elasticity (5). Moderate cost compared to other distributed styles.
- **Weaknesses:** Simplicity rated 2/5 — a solo developer will face steep learning curve with async event processing, eventual consistency, and debugging distributed event flows. Testability is only 2/5, making it harder for a solo dev to maintain quality.
- **Cost:** $$$ — moderate, but requires event broker infrastructure (Kafka, RabbitMQ, etc.) from day one.
- **Partitioning:** Technical — events flow through brokers rather than being organized by domain, which can obscure business logic.

### Candidate 2: Microservices (11/15, $$$$$)

- **Strengths:** Perfect scalability (5) and elasticity (5). Excellent evolvability (5) and fault-tolerance (5).
- **Weaknesses:** Simplicity rated 1/5 — the worst possible score. A solo developer cannot realistically operate a microservices architecture (service mesh, distributed tracing, CI/CD per service, container orchestration). The $$$$$ cost is prohibitive for a bootstrapped startup.
- **Cost:** $$$$$ — the most expensive option. Directly conflicts with bootstrapped budget constraint.
- **Partitioning:** Domain — good mental model, but the operational overhead negates this benefit for a solo developer.

### Candidate 3: Space-Based (11/15, $$$$)

- **Strengths:** Perfect scalability (5) and elasticity (5). Excellent responsiveness (5).
- **Weaknesses:** Simplicity rated 1/5. Extremely complex in-memory data grid architecture. Testability is 1/5. $$$$ cost is very high.
- **Cost:** $$$$ — requires specialized infrastructure (data grids, processing units, messaging grids). Not viable for bootstrapped budget.
- **Partitioning:** Technical — processing units are technical constructs, not domain-aligned.

### Alternative Candidate: Service-Based (10/15, $$)

- **Strengths:** Best balance across the conflicting characteristics. Simplicity at 3/5 is manageable for a solo developer. Scalability 4/5 and elasticity 3/5 are good. Excellent maintainability (5) and evolvability (5) support the growth story.
- **Weaknesses:** Doesn't maximize any single characteristic — it's the pragmatic middle ground. Elasticity at 3/5 may not fully handle extreme viral spikes.
- **Cost:** $$ — affordable for bootstrapped startup. 4-12 coarser services are operationally manageable.
- **Partitioning:** Domain — aligns well with how a solo developer thinks about the product.

## Step 4: Qualifying Context Assessment

Scores are close and there is a fundamental conflict. The context from architecture.md provides key answers:

**Team:** Solo developer. This is the single most important qualifying factor. Distributed architectures (Event-Driven, Microservices, Space-Based) require operational expertise and ongoing maintenance that a solo developer cannot sustain. The Red Flag from the skill applies: *"Small team + microservices score high -> warn about operational overhead, suggest service-based as a stepping stone."*

**Budget:** Bootstrapped, minimal spend. This eliminates Microservices ($$$$$) and Space-Based ($$$$) outright. Event-Driven ($$$) is borderline.

**Growth:** Expecting viral growth IF product-market fit is found. This is speculative — the product hasn't proven fit yet. Building for 100x scale before finding product-market fit is premature optimization.

**Red Flag — Premature Distribution:** The SKILL.md explicitly warns: *"If simplicity is a driving characteristic AND the system is new, distributed architectures should be questioned even if they score well on other characteristics."* This applies directly here.

**Rationalization Prevention:** "We'll need microservices eventually" — Start with the simplest style that fits. Evolve when the pain is real, not predicted. "Monoliths don't scale" — Modular monoliths scale vertically quite far. Service-based scales horizontally at moderate cost.

## Recommendation

**Primary Recommendation: Service-Based Architecture** (Fit Score: 10/15, Cost: $$)

Despite not having the highest raw score, Service-Based is the right choice when context is applied:

1. **Solo developer reality:** A solo dev can manage 4-6 coarser services. They cannot manage a microservices ecosystem or event broker infrastructure.
2. **Budget alignment:** $$ fits a bootstrapped startup. The higher-scoring alternatives ($$$-$$$$$) do not.
3. **Scalability is sufficient:** 4/5 scalability handles significant growth. Individual services can be scaled independently.
4. **Best evolution path:** Service-Based is explicitly the "stepping stone" architecture. When viral growth materializes and the team grows, extracting services into microservices or adding event-driven patterns is straightforward. Starting with microservices and realizing you need simplicity is much harder to reverse.
5. **Premature distribution warning addressed:** The system is new, simplicity is a driving characteristic — we honor that while still providing real scalability headroom.

**Alternative if simplicity must be maximized first:** Start with a **Modular Monolith** (7/15, $) and evolve to Service-Based when the first scaling bottleneck hits. This defers all distributed complexity but means re-architecture under pressure when growth arrives.

## Verification Checklist

- [x] architecture.md exists with top-3 prioritized characteristics
- [x] All 8 styles were scored against the driving characteristics
- [x] Top candidates include tradeoff analysis (strengths, weaknesses, cost)
- [x] Scores were close — qualifying context questions assessed from architecture drivers
- [x] Conflict between simplicity and scalability/elasticity explicitly addressed
- [x] Cost justified relative to benefit (Service-Based $$ fits bootstrapped budget)
- [x] Premature distribution red flag applied
- [x] Evolution path documented (Service-Based -> Microservices/Event-Driven as team grows)
