# Resolution Plan: Analytics Feature vs. Active ADRs

## The Core Question

The feature request assumes a separate service. But the actual problem is: **analytics queries are slowing down the main application.** These are not the same thing. The resolution path depends on which problem we are solving.

---

## Path A: Solve Within the Monolith (Preserve All ADRs)

**Approach:** Keep ADR-001, ADR-002, ADR-003 intact. Solve the performance problem without architectural decomposition.

**Techniques:**
- **CQRS-lite within the monolith:** Separate the analytics read model from the write model. Analytics queries run against a denormalized read-optimized structure, updated asynchronously via domain events within the same process.
- **SQLite WAL mode + connection isolation:** Use WAL mode to allow concurrent reads during writes. Dedicate a separate connection pool for analytics with lower priority.
- **Background processing:** Move expensive analytics computations to background jobs. Pre-aggregate results. Users see cached/materialized analytics, not live queries.
- **Query optimization:** Profile the specific queries that cause slowdowns. Add indexes, materialized views (via triggers in SQLite), or summary tables.

**ADR impact:** None. All three ADRs remain Accepted.

**Tradeoffs:**
- Analytics data may be slightly stale (eventual consistency within seconds/minutes)
- SQLite's ceiling will eventually be reached if data volume grows significantly
- Less architectural complexity, less operational overhead

**When to choose this path:** The analytics workload is moderate, the data volume is bounded, and "independent scaling" was a solution assumption rather than a hard requirement.

---

## Path B: Extract Analytics Service (Supersede ADRs)

**Approach:** Accept that the analytics workload genuinely needs independent scaling. Supersede the conflicting ADRs and extract analytics as a separate service.

**ADRs to supersede:**

### 1. Supersede ADR-001: Modular Monolith -> Service-Based Architecture (partial)

New ADR (e.g., ADR-004): "Extract analytics as a separate service while maintaining the modular monolith for core domain."

- Status of ADR-001: Superseded by ADR-004
- The core application remains a monolith. Only analytics is extracted.
- Communication between core and analytics: async events (not synchronous calls) to maintain decoupling.

### 2. Supersede ADR-002: SQLite -> Dual persistence strategy

New ADR (e.g., ADR-005): "Use SQLite for core application, use [PostgreSQL/DuckDB/ClickHouse] for analytics."

- Status of ADR-002: Superseded by ADR-005
- Core application keeps SQLite (it works well for OLTP at current scale)
- Analytics service uses a store optimized for analytical queries
- Data flows from core to analytics via events, not shared database access

### 3. Supersede ADR-003: Single deployment -> Two deployment artifacts

New ADR (e.g., ADR-006): "Deploy core application and analytics service as separate artifacts."

- Status of ADR-003: Superseded by ADR-006
- Introduces: separate CI/CD, health monitoring, versioning for each artifact
- Enables: independent scaling, independent deployment cycles

**Superseding Cascade (per architecture-decisions skill):**

| Superseded ADR | Cascade Action |
|----------------|----------------|
| ADR-001 (architecture style) | Re-run architecture-style-selection for the analytics service. Re-evaluate quality scenarios that assumed single-process execution. |
| ADR-002 (technology choice) | Update architecture.md. Check quality scenarios for affected test specifications (e.g., persistence-related fitness functions). |
| ADR-003 (deployment approach) | Check writing-plans for deployment-related tasks. Update fitness functions that reference single-artifact assumptions. |

**Tradeoffs:**
- Operational complexity increases significantly (two services, two stores, event pipeline)
- Team needs expertise in distributed systems patterns
- Gains true independent scaling for analytics
- Analytics can use purpose-built OLAP tooling

**When to choose this path:** Analytics volume is large and growing, the performance impact is severe and not addressable by query optimization alone, and the team is prepared for the operational overhead of multiple services.

---

## Path C: Investigate First (Recommended)

Before committing to Path A or Path B, gather data:

### Step 1: Quantify the problem
- [ ] Which specific analytics queries are slow? Profile them.
- [ ] What is the current data volume? What is the growth rate?
- [ ] How much write contention is caused by analytics reads? Measure SQLite lock wait times.
- [ ] What latency is acceptable for analytics results? (Real-time? Minutes? Hours?)

### Step 2: Test Path A techniques
- [ ] Enable WAL mode if not already active. Measure impact.
- [ ] Add indexes/summary tables for the slowest queries. Measure impact.
- [ ] Prototype background pre-aggregation for the heaviest analytics. Measure impact.

### Step 3: Decide
- If Path A techniques resolve the performance problem: proceed with Path A. No ADRs superseded.
- If Path A techniques are insufficient: proceed with Path B. Supersede ADRs through the architecture-decisions skill, triggering the full cascade.
- Document the decision itself as an ADR: "Solve analytics performance via [chosen path] because [evidence from investigation]."

---

## Decision Gate

**Brainstorming for the analytics feature is blocked until one of these paths is chosen.** The resolution must be an explicit, documented decision -- not an implicit drift away from the existing architecture.

| Path | ADRs Affected | Complexity | When Appropriate |
|------|---------------|------------|------------------|
| A: Solve within monolith | None | Low | Moderate analytics load, bounded data |
| B: Extract service | Supersede ADR-001, 002, 003 | High | Heavy analytics, growing data, team ready |
| C: Investigate first | TBD | Medium | Unclear whether Path A suffices |

**Next action:** Choose a path. If Path C, define the investigation timebox (suggest: 1-2 days of profiling and prototype testing). Then return to brainstorming with the architecture constraints resolved.
