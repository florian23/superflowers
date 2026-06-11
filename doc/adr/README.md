# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the **Superflowers plugin itself** — meta-decisions about how this plugin is built (agent design, skill structure, internal conventions). For per-project ADRs produced by the `architecture-decisions` skill in user projects, see each project's own `doc/adr/` directory.

ADRs document significant architecture decisions following Michael Nygard's format.

## Current Architecture at a Glance

_Derived from active (Accepted) ADRs. Updated whenever an ADR is written or superseded._

| Aspect | Decision | ADR |
|--------|----------|-----|
| Subagent routing for ad-hoc constraint questions | Single agent with in-prompt category routing (not multi-agent pipeline) | ADR-001 |
| Uncovered question behavior | Strict mode — emit `OPEN_DECISION`, never fall back to best-practice advice | ADR-002 |
| Constraint-clarifier output contract | Decisive recommendation + constraint citations (not clarifier-only listing) | ADR-003 |

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](ADR-001-use-single-agent-category-routing-for-constraint-lookups.md) | Use Single-Agent Category Routing for Constraint Lookups | Accepted | 2026-04-10 |
| [ADR-002](ADR-002-enforce-strict-mode-for-constraint-clarifier.md) | Enforce Strict Mode for constraint-clarifier | Accepted | 2026-04-10 |
| [ADR-003](ADR-003-emit-decisive-output-from-constraint-clarifier.md) | Emit Decisive Output from constraint-clarifier | Accepted | 2026-04-10 |
