# Architecture Style Selection Analysis

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

From `architecture.md`:

| Priority | Characteristic | Rationale |
|---|---|---|
| 1 | Evolvability | Independent feature evolution across 3 teams |
| 2 | Maintainability | Each team owns their domain independently |
| 3 | Scalability | Black Friday: 50x checkout, 10x catalog |

**Architecture Drivers:** 3 autonomous teams, Kubernetes experience, gradual monolith migration.

## Step 2: Architecture Style Fit Analysis

Top 3 Driving Characteristics: Evolvability, Maintainability, Scalability

| Rank | Style | Evolvability | Maintainability | Scalability | Fit Score | Cost |
|------|-------|-------------|----------------|-------------|-----------|------|
| 1 | Microservices | ★★★★★ | ★★★★★ | ★★★★★ | 15/15 | $$$$$ |
| 2 | Service-Based | ★★★★★ | ★★★★★ | ★★★★ | 14/15 | $$ |
| 3 | Event-Driven | ★★★★★ | ★★★ | ★★★★★ | 13/15 | $$$ |
| 4 | Space-Based | ★★★ | ★★★ | ★★★★★ | 11/15 | $$$$ |
| 5 | Microkernel | ★★★ | ★★★ | ★ | 7/15 | $ |
| 6 | Service-Oriented | ★ | ★ | ★★★ | 5/15 | $$$$ |
| 7 | Modular Monolith | ★ | ★★ | ★ | 4/15 | $ |
| 8 | Layered | ★ | ★ | ★ | 3/15 | $ |

## Step 3: Tradeoff Analysis — Top 3 Candidates

### Candidate 1: Microservices (15/15, $$$$$)

- **Strengths:** Perfect score across all three driving characteristics. Domain partitioning aligns with 3 autonomous teams. Each team can deploy independently. Scalability per service allows checkout to scale 50x while catalog scales 10x independently.
- **Weaknesses:** Maximum operational cost ($$$$$). Simplicity rated 1/5 — significant distributed systems complexity. Testability rated 5/5 but integration testing is hard. Requires mature DevOps practices.
- **Cost implication:** High, but the team has K8s experience which mitigates operational overhead. 3 autonomous teams justify the coordination cost.
- **Partitioning:** Domain — aligns perfectly with team ownership model.

### Candidate 2: Service-Based (14/15, $$)

- **Strengths:** Nearly as strong as microservices on evolvability and maintainability. Dramatically lower cost ($$). Simpler operational model with fewer services (4-12 typically). Good stepping stone from monolith.
- **Weaknesses:** Scalability rated 4/5 instead of 5/5 — shared database limits independent scaling. Black Friday 50x checkout spike may stress shared DB. Coarser granularity means less independent evolution per team.
- **Cost implication:** Excellent cost-to-benefit ratio. Only 1 point behind microservices at a fraction of the cost.
- **Partitioning:** Domain — aligns with team model.

### Candidate 3: Event-Driven (13/15, $$$)

- **Strengths:** Excellent evolvability and scalability. Asynchronous processing handles load spikes naturally. Good fit for e-commerce event flows (order placed → inventory reserved → payment processed).
- **Weaknesses:** Maintainability rated only 3/5 — async flows are harder to reason about and debug. Technical partitioning doesn't naturally align with team domain ownership. Responsiveness is excellent but adds eventual consistency complexity.
- **Cost implication:** Moderate cost, but the maintainability gap is a concern given it's the #2 priority.
- **Partitioning:** Technical — does not align with 3-team domain ownership model.

## Step 4: Context-Based Qualification

The architecture drivers provide strong qualifying context without needing additional questions:

| Factor | Context | Impact |
|---|---|---|
| Team size | 3 autonomous teams | Justifies distributed architecture — enough teams to own separate services |
| K8s experience | Existing Kubernetes skills | Mitigates microservices operational complexity significantly |
| Migration path | Gradual monolith migration | Microservices support incremental extraction; no big-bang rewrite needed |
| Black Friday scaling | 50x checkout, 10x catalog | Requires independent per-service scaling — microservices excel here |

**Service-Based concern:** The shared database pattern limits independent scaling. With a 50x checkout spike on Black Friday, the checkout domain needs its own database. This pushes toward microservices or a hybrid model.

**Microservices concern:** Cost is $$$$$, but K8s experience and 3 teams are exactly the prerequisites that make this cost manageable.

## Recommendation

**Selected: Microservices**

The perfect 15/15 fit score is justified by the context:
1. **3 autonomous teams** need independent deployability and domain ownership
2. **K8s experience** mitigates the primary cost driver (operational complexity)
3. **50x/10x Black Friday scaling** requires per-service scalability that shared-database architectures cannot deliver
4. **Gradual monolith migration** aligns with incremental service extraction

Service-Based (14/15, $$) was the strongest alternative and would be recommended if the team were smaller or lacked K8s experience. It remains a valid Phase 1 stepping stone if the team prefers gradual extraction.

## Verification Checklist

- [x] architecture.md exists with top-3 prioritized characteristics
- [x] All 8 styles were scored against the driving characteristics
- [x] Top candidates include tradeoff analysis (strengths, weaknesses, cost)
- [x] Qualifying context questions addressed through architecture drivers
- [x] Selection justified with concrete context (teams, K8s, scaling needs)
- [x] Cost justified: K8s experience + 3 teams + extreme scaling needs warrant $$$$$
- [x] Architecture style fitness functions to be generated in architecture.md
