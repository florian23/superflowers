# ADR-002: Use SQLite for persistence

## Status
Superseded by [ADR-004](ADR-004.md)

## Context
Internal tool, single user. SQLite chosen for simplicity.

## Decision
Use SQLite — no server, file-based, simple.

## Consequences
- Easier: Zero config, simple backups
- Harder: No concurrent writes, single-node only
