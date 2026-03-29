# Architecture Style Selection Analysis

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

From `architecture.md`:

| Priority | Characteristic | Rationale |
|---|---|---|
| 1 | Simplicity | Solo dev team, must ship fast |
| 2 | Testability | >90% coverage, regulatory compliance |
| 3 | Maintainability | Long-lived internal system, clean code essential |

**Architecture Drivers:** 1 developer, internal compliance tool, minimal budget.

## Step 2: Architecture Style Fit Analysis

Top 3 Driving Characteristics: Simplicity, Testability, Maintainability

| Rank | Style | Simplicity | Testability | Maintainability | Fit Score | Cost |
|------|-------|------------|-------------|-----------------|-----------|------|
| 1 | Service-Based | 3 | 4 | 5 | 12/15 | $$ |
| 2 | Microkernel | 5 | 3 | 3 | 11/15 | $ |
| 3 | Modular Monolith | 5 | 2 | 2 | 9/15 | $ |
| 4 | Layered | 5 | 2 | 1 | 8/15 | $ |
| 5 | Event-Driven | 2 | 2 | 3 | 7/15 | $$$ |
| 6 | Microservices | 1 | 5 | 5 | 11/15 | $$$$$ |
| 7 | Space-Based | 1 | 1 | 3 | 5/15 | $$$$ |
| 8 | Service-Oriented | 1 | 1 | 1 | 3/15 | $$$$ |

**Top 3 Candidates:** Service-Based (12), Microkernel (11), Microservices (11)

## Step 3: Tradeoff Analysis

### Candidate 1: Service-Based (12/15, $$)

- **Strengths:** Highest fit score. Excellent maintainability (5) and good testability (4). Domain-partitioned, which aligns well with a compliance tool's bounded contexts.
- **Weaknesses:** Simplicity rated only 3 — introduces distributed system complexity (service boundaries, inter-service communication, deployment of multiple services). For a single developer, this overhead is significant.
- **Cost:** $$ — moderate, but operational overhead of running multiple services is real for a solo dev.
- **Red Flag:** Simplicity is the #1 driving characteristic. Distributed architectures should be questioned when simplicity is driving and the system is new (per skill guidelines).

### Candidate 2: Microkernel (11/15, $)

- **Strengths:** Maximum simplicity (5), decent testability (3) and maintainability (3). Lowest cost. Plugin architecture enables extensibility.
- **Weaknesses:** A compliance tool is not naturally a plugin-based product. Microkernel excels when there is a stable core with variable features (e.g., IDEs, browsers). Compliance rules could theoretically be plugins, but the domain model is more naturally module-based.
- **Cost:** $ — minimal, very good for budget constraints.
- **Concern:** The plugin model adds architectural ceremony that may not match the domain's natural structure.

### Candidate 3: Microservices (11/15, $$$$$)

- **Strengths:** Perfect testability (5) and maintainability (5). Each service is independently testable and maintainable.
- **Weaknesses:** Simplicity rated 1 — the worst possible score. Extreme operational overhead. Completely disproportionate for 1 developer building an internal tool.
- **Cost:** $$$$$ — maximum cost, minimal budget available. Eliminated.
- **Red Flag:** Resume-driven architecture. The matrix doesn't lie: simplicity = 1 with a solo dev is a non-starter.

### Reconsidering: Modular Monolith (9/15, $)

Despite ranking 3rd by raw score, the Modular Monolith deserves reconsideration given the context:

- **Simplicity: 5** — Maximum. Single deployment, single process, single developer can reason about the entire system.
- **Testability: 2** — Rated low in the matrix, but this is the *structural* rating. A well-structured modular monolith with clear module boundaries and dependency injection achieves high testability. The low rating reflects monolith tendencies (tight coupling), which module boundaries explicitly prevent.
- **Maintainability: 2** — Same reasoning. The matrix rates the general monolith tendency. Domain-partitioned modules with enforced boundaries significantly improve maintainability over time.
- **Cost: $** — Minimal. Perfect for budget constraints.
- **Domain fit:** A compliance tool naturally decomposes into domain modules (rules management, audit logging, reporting, user management). This maps directly to modular monolith partitioning.

## Step 4: Qualifying Context

| Question | Answer | Implication |
|---|---|---|
| Team size? | 1 developer | Eliminates all distributed architectures. Solo dev cannot operate multiple services. |
| Budget? | Minimal | Eliminates $$+ styles unless justified by overwhelming fit. |
| Deployment constraints? | Internal tool | No need for independent deployability. Single deployment is a feature, not a bug. |
| Growth trajectory? | Internal compliance tool | Bounded user base. No need for horizontal scalability. |
| Requirements change rate? | Regulatory compliance | Rules change, but the domain model is stable. Module boundaries handle rule changes well. |
| Product or project? | Internal tool (project) | Not a product with customer-facing plugins. Microkernel less justified. |

## Decision: Modular Monolith

**Service-Based is eliminated** despite the highest fit score because:
- Simplicity is the #1 driving characteristic
- A single developer cannot sustainably operate distributed services
- The $$ cost, while moderate, includes hidden operational complexity

**Microkernel is a close alternative** but:
- The compliance domain does not naturally decompose into core + plugins
- Plugin architecture adds ceremony without matching the domain model

**Modular Monolith is selected** because:
- Maximum simplicity (5/5) — the #1 priority
- Domain-partitioned by business module — natural fit for compliance domains
- Low testability/maintainability matrix scores are mitigated by enforced module boundaries (the entire point of "modular" monolith vs plain monolith)
- $ cost — perfect for minimal budget
- Clear evolution path: modules can be extracted to services if the team grows

## Step 5: Selection Summary

| Attribute | Value |
|---|---|
| **Selected Style** | Modular Monolith |
| **Partitioning** | Domain |
| **Cost** | $ |
| **Fit Score** | 9/15 (mitigated by context) |
| **Runner-up** | Microkernel (11/15) |

### Why not the highest-scoring style?

Raw fit scores are necessary but not sufficient. The qualifying context — 1 developer, minimal budget, internal tool — makes distributed architectures impractical regardless of their matrix ratings. The Modular Monolith's low testability/maintainability ratings reflect the *worst case* of monolithic architecture; enforced module boundaries (verified by style fitness functions) specifically address these weaknesses.
