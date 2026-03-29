# Step 0: ADR Review -- Analytics-Service Feature Request

> **Feature request:** "Wir muessen einen separaten Analytics-Service bauen der unabhaengig skaliert werden kann, weil die Analytics-Queries die Hauptanwendung verlangsamen."
>
> (Translation: "We need to build a separate Analytics service that can scale independently because analytics queries are slowing down the main application.")

## Current Architecture at a Glance

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | Use Modular Monolith architecture | Accepted |
| ADR-002 | Use SQLite for persistence | Accepted |
| ADR-003 | Single deployment artifact | Accepted |

These are the current architecture decisions that affect this feature. Assessment follows.

---

## ADR-001: Use Modular Monolith Architecture

**Verdict: CONFLICT**

The feature request explicitly asks for "einen separaten Analytics-Service" -- a separate service that scales independently. A modular monolith, by definition, runs all modules in a single process. Independent scaling of a single module is not possible without breaking the monolith boundary.

**Specifically what conflicts:**
- Independent scaling requires a separate process. A modular monolith is one process.
- "Separater Service" implies a network boundary between analytics and the main application. The modular monolith assumes in-process communication between modules.
- The motivation ("unabhaengig skaliert") is fundamentally incompatible with the monolith's single-unit scaling model.

**What must change:** ADR-001 would need to be **superseded** by a new ADR that permits at least a partial decomposition -- for example, moving to a service-based architecture where analytics is extracted as a separately deployable service while the rest remains a monolith. Alternatively, the feature request itself must be reframed to work within the monolith (e.g., CQRS with a read replica within the same process, background job queues for heavy queries).

**Recommendation:** Investigate further. The underlying problem (analytics queries slowing down the main application) may be solvable without breaking the monolith. But if independent scaling is truly required, ADR-001 must be superseded.

---

## ADR-002: Use SQLite for Persistence

**Verdict: CONFLICT (likely)**

SQLite has fundamental limitations that conflict with the analytics use case:

- **Concurrent write contention:** SQLite uses file-level locking. Heavy analytics reads competing with application writes will cause exactly the performance problem the feature request is trying to solve -- even if you keep everything in the monolith.
- **Single-machine constraint:** SQLite is an embedded database. If you extract analytics as a separate service, it cannot share the same SQLite file across a network boundary (SQLite does not support networked access).
- **No read replicas:** SQLite has no built-in replication. The common pattern of directing analytics to a read replica is not available.
- **Scale ceiling:** Analytics workloads tend to grow with data volume. SQLite's practical limits (single writer, ~1TB practical max, no query parallelism) will be reached faster by analytical queries than by OLTP workloads.

**Specifically what conflicts:**
- Separate service + SQLite = impossible (no network access to SQLite).
- Even within a monolith, heavy analytics queries on SQLite will lock the database for writes.

**What must change:** If the analytics service is extracted, ADR-002 must be **superseded** for at least the analytics data store (e.g., PostgreSQL, DuckDB for OLAP, or ClickHouse). If staying within the monolith, a secondary read-optimized store or a WAL-mode configuration with careful query isolation may be sufficient -- but this stretches SQLite beyond its design intent.

**Recommendation:** Investigate further. The answer depends on whether analytics stays in-process or becomes a separate service. Either way, SQLite alone is unlikely to be sufficient for the analytics workload long-term.

---

## ADR-003: Single Deployment Artifact

**Verdict: CONFLICT**

A separate analytics service is, by definition, a second deployment artifact. ADR-003 states there should be one.

**Specifically what conflicts:**
- "Separater Service" = separate deployment. "Single deployment artifact" = one deployment. These are mutually exclusive.
- Independent scaling requires independent deployment. You cannot independently scale something that is bundled into a single artifact.

**What must change:** ADR-003 must be **superseded** by a new ADR that permits multiple deployment artifacts -- at minimum, the main application and the analytics service. This also introduces operational complexity: separate CI/CD pipelines, health monitoring, versioning, and deployment coordination.

**Recommendation:** If ADR-001 is superseded to allow service extraction, ADR-003 must be superseded as well. They are coupled -- you cannot change one without the other.

---

## Summary

| ADR | Compatibility | Action Required |
|-----|--------------|-----------------|
| ADR-001: Modular Monolith | **CONFLICT** | Supersede or reframe the feature request |
| ADR-002: SQLite | **CONFLICT (likely)** | Supersede for analytics store, or investigate in-monolith alternatives |
| ADR-003: Single deployment | **CONFLICT** | Supersede if service extraction proceeds |

## Blocking Decision

**Brainstorming CANNOT proceed.** Three active ADRs conflict with the feature request. Continuing to brainstorm solutions while ignoring these conflicts would produce a design that contradicts the project's own recorded architecture decisions.

Before brainstorming can begin, the team must:

1. Decide whether the underlying problem (analytics slowing down the main app) truly requires a separate service, or whether it can be solved within the current architecture constraints.
2. If a separate service is required: consciously supersede ADR-001, ADR-002 (for analytics), and ADR-003 through the architecture-decisions skill, documenting WHY the original decisions no longer hold.
3. If the problem can be solved within the monolith: reframe the feature request and proceed without superseding any ADRs.

This is not a formality. Superseding an ADR is a conscious architectural choice with cascading consequences -- it triggers re-evaluation of fitness functions, quality scenarios, and existing implementation plans that reference those ADRs.
