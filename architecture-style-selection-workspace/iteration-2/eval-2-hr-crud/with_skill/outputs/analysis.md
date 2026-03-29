# Architecture Style Fit Analysis

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

**Source:** architecture.md

**Top 3 Priority Characteristics:**
1. **Simplicity** -- Small team (2 devs), must be easy to understand
2. **Testability** -- >90% test coverage required
3. **Deployability** -- Weekly releases, low-risk

**Architecture Drivers:**
- Small team: 2 developers
- Internal tool: 50 users max, no scaling concerns
- Budget: Minimal

## Step 2: Style Scoring Against the Matrix

All 8 architecture styles scored against the top-3 driving characteristics using the Architecture Styles Worksheet V2.0 (Ford/Richards).

| Rank | Style | Simplicity | Testability | Deployability | Fit Score | Cost |
|------|-------|------------|-------------|---------------|-----------|------|
| 1 | **Microkernel** | 5 | 3 | 3 | **11/15** | $ |
| 2 | **Service-Based** | 3 | 4 | 4 | **11/15** | $$ |
| 3 | Microservices | 1 | 5 | 5 | 11/15 | $$$$$ |
| 4 | Layered | 5 | 2 | 1 | 8/15 | $ |
| 5 | Modular Monolith | 5 | 2 | 1 | 8/15 | $ |
| 6 | Event-Driven | 2 | 2 | 3 | 7/15 | $$$ |
| 7 | Space-Based | 1 | 1 | 3 | 5/15 | $$$$ |
| 8 | Service-Oriented | 1 | 1 | 1 | 3/15 | $$$$ |

**Top 3 candidates:** Microkernel, Service-Based, and Microservices all score 11/15. Cost breaks the tie decisively.

## Step 3: Tradeoff Analysis of Top Candidates

### Candidate 1: Microkernel (11/15, $)

- **Strengths:** Maximum simplicity (5/5) -- ideal for a 2-person team. Low cost aligns with minimal budget. Plugin architecture allows adding HR modules (leave management, onboarding, reporting) incrementally.
- **Weaknesses:** Testability (3/5) and Deployability (3/5) are average, not excellent. The plugin model adds some indirection that can make integration testing harder. Deployability is limited because plugins and core ship together.
- **Cost implication:** $ -- cheapest possible. Perfect for minimal budget.
- **Partitioning:** Domain -- plugins map naturally to HR business domains (payroll, leave, employees).
- **Concern:** Microkernel excels for product-based applications with extensible features. An internal HR tool for 50 users may not need plugin extensibility -- it may be overengineering the extension model while underdelivering on testability.

### Candidate 2: Service-Based (11/15, $$)

- **Strengths:** Strong testability (4/5) and deployability (4/5) -- the two characteristics where Microkernel is weaker. Services can be tested independently. Individual services can be deployed without full system redeployment, supporting low-risk weekly releases.
- **Weaknesses:** Simplicity (3/5) -- moderate complexity. Introduces service boundaries, network communication, and operational concerns that a 2-person team must manage.
- **Cost implication:** $$ -- still low, but more than Microkernel. For an internal tool with minimal budget, this is acceptable but not ideal.
- **Partitioning:** Domain -- 4-6 coarse-grained services (e.g., employee-management, leave, payroll, reporting) sharing a database.
- **Concern:** A 2-person team managing multiple deployable services adds operational overhead. The team may spend more time on infrastructure than features.

### Candidate 3: Microservices (11/15, $$$$$)

- **Strengths:** Perfect testability (5/5) and deployability (5/5).
- **Weaknesses:** Simplicity (1/5) -- the worst possible score. Requires container orchestration, service discovery, API gateways, distributed tracing, and more. 2 developers cannot realistically manage this.
- **Cost implication:** $$$$$ -- maximum cost. Completely incompatible with "minimal budget."
- **Eliminated:** Fails the cost constraint and the simplicity requirement. This is textbook resume-driven architecture for a 50-user internal tool.

## Step 4: Qualifying Context Assessment

Scores are tied at 11/15 between Microkernel and Service-Based. Context breaks the tie:

| Question | Answer | Impact |
|----------|--------|--------|
| Team size? | 2 developers | Strongly favors simpler architectures. Service-Based adds operational burden. |
| Multiple teams? | No, single team | No need for service boundaries to separate team ownership. |
| Distributed systems experience? | Not stated, but team is small | Assume limited -- favors monolithic deployment. |
| Deployment constraints? | Weekly releases, low-risk | Both candidates support this adequately. |
| Existing system? | Not stated | Assume greenfield. |
| Budget? | Minimal | Eliminates $$$+ styles. Favors $ styles. |
| Growth trajectory? | 50 users max, no scaling concerns | No growth pressure. Simplest viable architecture wins. |
| Product or project? | Internal tool (project) | Microkernel's plugin extensibility is less valuable for a fixed-scope internal tool. |

**Verdict:** The context overwhelmingly favors Microkernel for its simplicity and cost, despite Service-Based scoring better on testability and deployability individually. A 2-person team building an internal tool for 50 users should not introduce service boundaries.

However, Microkernel's plugin model may be unnecessary complexity for a straightforward HR CRUD tool. The Layered architecture (8/15, $) deserves mention: it scores perfect simplicity (5/5) and is the most natural fit for a small CRUD application, but its poor testability (2/5) and deployability (1/5) conflict with the stated priorities.

## Recommendation

**Microkernel** is the recommended architecture style.

- It delivers the best balance of simplicity (5/5) with adequate testability (3/5) and deployability (3/5) at the lowest cost ($).
- The core system handles shared HR concerns (authentication, employee data model, database access), while domain-specific functionality (leave management, payroll, onboarding, reporting) is implemented as plugins/modules.
- Testability can be improved beyond the baseline 3/5 rating through disciplined plugin interface contracts and test automation -- the plugin architecture naturally isolates concerns for unit testing.
- Weekly deployability is achievable because the system deploys as a single unit with well-defined plugin boundaries.

**Why not Service-Based?** Despite equal fit score, Service-Based adds operational complexity (service deployment, network concerns, monitoring) that a 2-person team should avoid for a 50-user internal tool. The marginal testability and deployability gains (4 vs 3) do not justify the simplicity loss (3 vs 5) and higher cost.

**Why not Layered?** Despite perfect simplicity, Layered's poor testability (2/5) directly conflicts with the >90% coverage requirement, and its poor deployability (1/5) conflicts with low-risk weekly releases.
