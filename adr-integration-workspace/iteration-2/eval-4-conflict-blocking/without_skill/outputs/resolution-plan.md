# Resolution Plan: Analytics Performance Within Existing Constraints

## Problem Statement

Analytics queries slow down the main application. The proposed solution (separate analytics service) conflicts with all three active architectural decisions: Modular Monolith, SQLite, and Single deployment artifact.

## Recommendation: Resolve Within Current Architecture

The underlying problem -- analytics query load degrading application performance -- is valid. However, the proposed solution is disproportionate to the problem. There are multiple approaches that solve the performance issue without abandoning the existing architecture.

## Option A: Read Replica with Async Copy (Recommended)

**Approach:** Keep analytics as a module within the monolith, but route analytics queries to a read-only copy of the SQLite database.

- SQLite supports concurrent readers. A periodic file copy (or `VACUUM INTO`) creates a snapshot that the analytics module reads from, while the main application writes to the primary database.
- Copy interval can be tuned (e.g., every 30 seconds to 5 minutes) depending on freshness requirements. Analytics data rarely needs real-time consistency.
- The analytics module runs its heavy queries against the replica, eliminating lock contention on the primary database.

**Conflicts resolved:** All three. Single process, single artifact, SQLite retained. No distributed system complexity.

**Trade-off:** Analytics data is slightly stale (seconds to minutes). Disk usage increases (two copies of the database).

## Option B: Background Processing with Query Isolation

**Approach:** Run analytics queries on a background thread or worker within the monolith, using WAL mode and query timeouts to prevent blocking.

- Enable SQLite WAL (Write-Ahead Logging) mode, which allows concurrent reads while writes are happening.
- Execute analytics queries with `PRAGMA busy_timeout` and statement timeouts to prevent long-running queries from holding locks.
- Schedule heavy analytics computation during off-peak hours or as async background jobs.
- Pre-aggregate results into summary tables so that user-facing analytics reads are fast and lightweight.

**Conflicts resolved:** All three. No architectural changes needed.

**Trade-off:** Complex queries still compete for CPU and memory within the same process. Works well for moderate analytics load but has a ceiling.

## Option C: CQRS-Lite Within the Monolith

**Approach:** Implement a lightweight command-query separation within the monolith's analytics module.

- Write events/facts to an append-only analytics table on every relevant domain action.
- A background process within the monolith periodically materializes these events into pre-computed views or summary tables.
- Analytics reads only hit the materialized views, which are fast indexed lookups rather than expensive aggregations.

**Conflicts resolved:** All three. This is an internal module design pattern, not an architectural change.

**Trade-off:** Requires designing the event/materialization pipeline. More upfront implementation work, but scales well within a single process.

## Option D: Accept the Proposal (Supersede Existing ADRs)

**Approach:** If analytics load is genuinely beyond what a single-process architecture can handle, accept the separate service and formally supersede the three existing ADRs.

- Supersede "Modular Monolith" with "Modular Monolith + Analytics Sidecar"
- Supersede "SQLite" with "SQLite (application) + PostgreSQL/DuckDB (analytics)" or define a replication strategy
- Supersede "Single deployment artifact" with "Primary artifact + Analytics service artifact"
- Document the new operational requirements: orchestration, monitoring, inter-service communication

**When this is appropriate:** Only if measured analytics load exceeds what Options A-C can handle, or if analytics requirements are expected to grow significantly (e.g., real-time dashboards, ML pipelines, multi-tenant analytics).

**This option should be a last resort**, not a first choice. The complexity cost of going distributed is high and permanent.

## Decision Framework

| Question | If Yes | If No |
|----------|--------|-------|
| Can analytics tolerate data that is 1-5 minutes stale? | Option A | Options B or C |
| Is the analytics query load moderate (< 20% of total DB load)? | Option B | Options A or C |
| Are analytics requirements expected to grow significantly? | Option C (now), possibly D (later) | Option A or B |
| Has measured load proven that single-process solutions are insufficient? | Option D | Options A, B, or C |

## Recommended Next Step

1. **Measure first.** Profile the actual analytics queries causing slowdowns. Identify whether the bottleneck is CPU, I/O, or lock contention.
2. **Try Option A or B.** Both can be implemented in hours, not days, and require zero architectural changes.
3. **Escalate to Option C** if pre-aggregation is needed for query complexity.
4. **Only consider Option D** with concrete evidence that the monolith cannot handle the load after optimizations.
