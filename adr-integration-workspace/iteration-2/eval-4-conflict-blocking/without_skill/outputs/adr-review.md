# ADR Conflict Review: Separate Analytics Service

## Proposed Change

"Separater Analytics-Service der unabhangig skaliert, weil Analytics-Queries die Hauptanwendung verlangsamen."

(Separate Analytics Service that scales independently because analytics queries slow down the main application.)

## Existing Decisions Under Review

| # | Decision | Status |
|---|----------|--------|
| 1 | Modular Monolith | Active |
| 2 | SQLite | Active |
| 3 | Single deployment artifact | Active |

## Conflict Analysis

### Conflict 1: Modular Monolith

**Severity: BLOCKING**

A modular monolith means all modules run within a single process boundary. Extracting analytics into a separate, independently scalable service directly violates this architecture style. It introduces a distributed system boundary, requiring inter-service communication (HTTP, messaging, etc.), separate deployment pipelines, and network-level concerns (latency, failure handling, serialization) that the modular monolith decision was specifically chosen to avoid.

- **Nature of conflict:** The proposal turns the architecture from a modular monolith into a partial microservices topology. Even extracting a single service means the system is no longer a monolith -- it is a distributed system with all the associated complexity.
- **Impact:** Service discovery, network resilience, API versioning, distributed tracing, and operational complexity all increase significantly.

### Conflict 2: SQLite

**Severity: BLOCKING**

SQLite is an embedded, file-based database designed for single-process access. A separate analytics service running in its own process cannot safely share the same SQLite database file with the main application due to SQLite's concurrency limitations (single-writer, file-level locking). This creates two sub-problems:

1. **Shared database access:** Two separate processes writing to or reading from the same SQLite file leads to lock contention, `SQLITE_BUSY` errors, and potential data corruption under concurrent write load -- precisely the performance problem the proposal aims to solve.
2. **Separate database requirement:** If the analytics service uses its own database, a data synchronization mechanism is needed (CDC, event streaming, ETL). This adds distributed data consistency concerns that conflict with the simplicity rationale behind choosing SQLite.

### Conflict 3: Single Deployment Artifact

**Severity: BLOCKING**

A single deployment artifact means the entire application is packaged and deployed as one unit. An independently scalable analytics service requires its own deployment artifact, its own scaling configuration, and its own lifecycle management. This directly breaks the single-artifact constraint and introduces:

- Multiple build pipelines or a more complex mono-build
- Independent versioning and release coordination
- Infrastructure for running and scaling two separate services (container orchestration, load balancing)

## Summary

All three existing decisions are in direct conflict with the proposed separate analytics service. None of the conflicts are minor or advisory -- each is blocking. The proposal fundamentally changes the system's architecture style, data strategy, and deployment model simultaneously. Proceeding without resolving these conflicts would invalidate the rationale behind all three existing decisions.
