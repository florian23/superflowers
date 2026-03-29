# ADR-002: Use SQLite for persistence

## Status
Superseded by ADR-004

## Context
The project is an internal tool with a single user at a time. We need a simple, zero-configuration database. SQLite, PostgreSQL, and MySQL were considered.

## Decision
We will use SQLite because it requires no server setup, is file-based, and sufficient for single-user workloads.

## Consequences
- Easier: Zero configuration, no DB server to maintain, simple backups (copy file)
- Harder: Cannot handle concurrent writes, limited to single-node deployment
