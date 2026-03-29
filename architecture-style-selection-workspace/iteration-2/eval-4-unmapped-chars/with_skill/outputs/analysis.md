# Architecture Style Fit Analysis

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

Extracted from `architecture.md`:

| Priority | Characteristic | Description |
|----------|---------------|-------------|
| 1 | **Workflow** | Complex multi-step business processes spanning multiple services |
| 2 | **Configurability** | Must support per-tenant configuration and white-labeling |
| 3 | **Interoperability** | Must integrate with 12+ external partner APIs |

Architecture Drivers:
- B2B SaaS platform for logistics
- Multi-tenant with per-customer configuration
- Heavy integration with shipping carriers, customs, ERP systems

## Step 2: Score Styles Against the Matrix

### Characteristic Mapping

Two of the three driving characteristics are **not directly rated** in the star-rating matrix. The mapping table in `references/architecture-styles-matrix.md` provides guidance:

| Characteristic | Matrix Status | Mapping Approach |
|---------------|--------------|------------------|
| **Workflow** | No direct rating | "Service-oriented and event-driven excel at complex workflows." Rated per-style based on inherent support for multi-step orchestration/choreography. |
| **Configurability** | No direct rating | "Microkernel excels; others depend on implementation." Rated per-style based on inherent support for runtime configuration and plug-in/tenant customization. |
| **Interoperability** | Direct rating | Used directly from the matrix. |

### Derived Ratings for Unmapped Characteristics

**Workflow** — rated by each style's structural support for multi-step, multi-service business processes:

| Style | Rating | Rationale |
|-------|--------|-----------|
| Layered | ★ (1) | No built-in workflow orchestration; all logic in business layer |
| Modular Monolith | ★★ (2) | Can coordinate across domain modules, but within a single process |
| Microkernel | ★★ (2) | Plugin model is feature-oriented, not workflow-oriented |
| Microservices | ★★★★ (4) | Supports orchestration and choreography across service boundaries |
| Service-Based | ★★★★ (4) | Coarse-grained services with shared DB simplify workflow coordination |
| Service-Oriented | ★★★★★ (5) | Built for orchestrated workflows via service bus and mediator |
| Event-Driven | ★★★★★ (5) | Mediator topology excels at complex multi-step event processing |
| Space-Based | ★★ (2) | Designed for throughput/elasticity, not multi-step workflow orchestration |

**Configurability** — rated by each style's structural support for per-tenant configuration and customization:

| Style | Rating | Rationale |
|-------|--------|-----------|
| Layered | ★★ (2) | Configuration possible but not a structural strength |
| Modular Monolith | ★★★ (3) | Domain modules can encapsulate tenant-specific config |
| Microkernel | ★★★★★ (5) | Plugin architecture is purpose-built for customization and configuration |
| Microservices | ★★★ (3) | Per-service config possible, but coordination overhead for tenant-wide config |
| Service-Based | ★★★ (3) | Moderate; tenant config can live in shared database |
| Service-Oriented | ★★★ (3) | Governance layer can manage configuration, but heavy |
| Event-Driven | ★★ (2) | Async event processing is not a natural fit for configuration management |
| Space-Based | ★★ (2) | In-memory grid focus, configuration is not a structural strength |

### Ranked Fit Table

Top 3 Driving Characteristics: Workflow, Configurability, Interoperability

| Rank | Style | Workflow | Configurability | Interoperability | Fit Score | Cost |
|------|-------|----------|-----------------|------------------|-----------|------|
| 1 | **Service-Oriented** | ★★★★★ (5) | ★★★ (3) | ★★★★★ (5) | **13/15** | $$$$ |
| 2 | **Event-Driven** | ★★★★★ (5) | ★★ (2) | ★★★ (3) | **10/15** | $$$ |
| 3 | **Microservices** | ★★★★ (4) | ★★★ (3) | ★★★★ (4) | **11/15** | $$$$$ |
| 4 | **Microkernel** | ★★ (2) | ★★★★★ (5) | ★★★ (3) | **10/15** | $ |
| 5 | **Service-Based** | ★★★★ (4) | ★★★ (3) | ★★ (2) | **9/15** | $$ |
| 6 | **Modular Monolith** | ★★ (2) | ★★★ (3) | ★ (1) | **6/15** | $ |
| 7 | **Layered** | ★ (1) | ★★ (2) | ★ (1) | **4/15** | $ |
| 8 | **Space-Based** | ★★ (2) | ★★ (2) | ★ (1) | **5/15** | $$$$ |

**Re-sorted by fit score:**

| Rank | Style | Fit Score | Cost |
|------|-------|-----------|------|
| 1 | Service-Oriented | 13/15 | $$$$ |
| 2 | Microservices | 11/15 | $$$$$ |
| 3 | Event-Driven | 10/15 | $$$ |
| 3 | Microkernel | 10/15 | $ |
| 5 | Service-Based | 9/15 | $$ |

## Step 3: Tradeoff Analysis — Top 3 Candidates

### Candidate 1: Service-Oriented (SOA) — 13/15, $$$$

**Strengths:**
- Highest fit score by 2 points — excels at both workflow (5) and interoperability (5)
- Service bus and orchestration engine are purpose-built for the multi-carrier/ERP integration pattern
- Enterprise integration patterns (EIP) align with 12+ partner API requirement
- Technical partitioning supports centralized governance of integrations

**Weaknesses:**
- Simplicity: ★ (1) — Heavy governance and ceremony
- Testability: ★ (1) — Integration testing across the service bus is complex
- Deployability: ★ (1) — Coupled deployment cycles through shared infrastructure
- Maintainability: ★ (1) — Difficult to maintain due to enterprise complexity
- Cost: $$$$ — Significant investment in middleware and governance

**Cost implication:** High cost ($$$$ ) is justified IF the integration complexity truly demands enterprise-level orchestration. For a B2B logistics platform with 12+ partner APIs, this may be warranted.

**Partitioning:** Technical — may conflict with multi-tenant domain boundaries.

---

### Candidate 2: Microservices — 11/15, $$$$$

**Strengths:**
- Strong across workflow (4), interoperability (4), and configurability (3)
- Domain partitioning aligns well with multi-tenant SaaS model
- Independent deployability per service supports per-tenant configuration
- Excellent scalability (5), fault tolerance (5), and evolvability (5)

**Weaknesses:**
- Simplicity: ★ (1) — Most complex architecture style
- Cost: $$$$$ — Most expensive, needs strong justification
- Configurability (3) requires additional patterns (feature flags, config service)
- Operational overhead: container orchestration, service mesh, distributed tracing

**Cost implication:** Highest cost category. For a B2B logistics platform, the question is whether the team size and growth trajectory justify this investment.

**Partitioning:** Domain — aligns well with multi-tenant model.

---

### Candidate 3: Event-Driven — 10/15, $$$

**Strengths:**
- Excellent workflow support (5) via mediator topology
- Scalability (5) and elasticity (5) for handling shipping/logistics spikes
- Moderate cost ($$$) — significantly cheaper than SOA or microservices
- Fault tolerance (5) — critical for a logistics platform where failures cascade

**Weaknesses:**
- Configurability: ★★ (2) — Not a natural fit for per-tenant config/white-labeling
- Interoperability: ★★★ (3) — Moderate; external APIs often need synchronous request/reply patterns
- Testability: ★★ (2) — Async event flows are harder to test
- Technical partitioning may not align with tenant isolation needs

**Cost implication:** Best cost-to-workflow ratio. If configurability can be addressed through complementary patterns, this is the most cost-effective option.

**Partitioning:** Technical — needs careful design for multi-tenant isolation.

---

### Notable Alternative: Microkernel — 10/15, $

**Why it's interesting:** Highest configurability (5) at lowest cost ($). The plugin architecture is a natural fit for per-tenant white-labeling. However, it scores low on workflow (2) and moderate on interoperability (3), which are the other two driving characteristics. Best suited as a complementary pattern within a larger architecture (e.g., a microkernel-based configuration engine inside a service-based or event-driven system).

## Step 4: Qualifying Context Questions

Scores are close between Service-Oriented (13), Microservices (11), and Event-Driven (10). The following questions would break the tie:

**Team & Organization:**
- How large is the team? Small teams struggle with SOA governance and microservices operational overhead.
- How many teams will work on this system? Multiple teams benefit from service boundaries (favors microservices/service-based).
- What's the team's experience with distributed systems? SOA and microservices require significant distributed systems expertise.

**Constraints:**
- Are there deployment constraints? Cloud-native favors microservices; on-premise may favor SOA or service-based.
- Is there an existing system being replaced? Migration path matters.
- Budget constraints? SOA ($$$$ ) and Microservices ($$$$$) need strong justification vs. Service-Based ($$).

**Growth & Change:**
- How quickly do partner integrations change? High change rate favors evolvability (microservices/event-driven).
- What's the expected tenant growth trajectory? Rapid growth favors scalable styles.
- Is configurability primarily at deploy-time or runtime? Runtime favors microkernel patterns.

## Preliminary Recommendation

**Without qualifying context**, the data suggests:

**Service-Based architecture (9/15, $$) as the pragmatic starting point**, potentially evolving toward microservices or incorporating event-driven patterns for workflow orchestration. Rationale:

1. Service-Oriented scored highest (13/15) but its $$$$ cost and governance overhead is concerning for a platform that hasn't proven product-market fit at enterprise scale.
2. Service-Based scores 9/15 at only $$ — best cost-efficiency ratio among distributed styles.
3. Service-Based can incorporate event-driven patterns (mediator) for complex workflows without committing to full event-driven architecture.
4. A **microkernel pattern** can be embedded within the configuration service for per-tenant customization.
5. The architecture can evolve toward microservices as the team and tenant base grow.

However, if the organization has mature distributed systems capabilities and budget to match, **Service-Oriented** is the highest-scoring style and directly addresses the workflow + interoperability combination that defines this logistics platform.
