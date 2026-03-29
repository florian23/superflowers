# ADR-004: Use PostgreSQL for persistence

## Status
Accepted

## Context
Three months after adopting SQLite (ADR-002), the system has evolved from a single-user internal tool to a multi-service architecture. Multiple services now need concurrent write access to the database. SQLite's single-writer limitation has become a blocker — writes from one service block all others, causing timeouts and data contention under concurrent workloads.

This supersedes ADR-002 because the original single-user assumption no longer holds.

PostgreSQL and MySQL were considered as replacements:
- **PostgreSQL:** MVCC-based concurrency, robust support for concurrent reads and writes, strong ecosystem, ACID-compliant, extensible type system.
- **MySQL:** Capable of concurrent access but weaker in advanced features (partial index support, JSON handling, extensibility).

## Decision
We will use PostgreSQL because it provides full MVCC-based concurrent write access, eliminating the single-writer bottleneck that blocks our multi-service architecture.

## Consequences
- Easier: Multiple services can write concurrently without contention; enables horizontal scaling and multi-node deployment; mature replication and connection pooling ecosystem; richer query capabilities (CTEs, window functions, JSONB)
- Harder: Requires a running database server (operational overhead); backups are more complex than copying a single file; local development setup needs a PostgreSQL instance or container; migration effort to move existing data from SQLite to PostgreSQL
