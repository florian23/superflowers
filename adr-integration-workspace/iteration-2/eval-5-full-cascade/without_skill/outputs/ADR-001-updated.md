# ADR-001: Use Modular Monolith Architecture Style

**Status:** Superseded by [ADR-006](ADR-006.md)

**Date:** 2024-01-15

**Updated:** 2026-03-29

## Context

At the time of this decision, the team consisted of a single development team building the Superflowers platform. We needed an architecture style that would allow us to move quickly while maintaining clean boundaries between business domains.

A modular monolith offered the simplest deployment model, low operational overhead, and sufficient modularity for one team to work without stepping on each other.

## Decision

We adopted a **Modular Monolith** architecture style with the following characteristics:

- Single deployable unit
- Strict module boundaries enforced by package-level access rules
- Inter-module communication via in-process method calls through defined module APIs
- Shared database with schema-per-module ownership

## Fitness Functions

| ID | Fitness Function | Target | Rationale |
|----|-----------------|--------|-----------|
| FF-001 | No cyclic dependencies between modules | 0 cycles | Preserve modularity within the monolith |
| FF-002 | Module API surface area | Max 10 public types per module | Keep module interfaces narrow |
| FF-003 | Build time (full) | < 3 minutes | Single deployable must stay fast to build |
| FF-004 | Module coupling (afferent/efferent) | Instability < 0.7 per module | Prevent hidden coupling that blocks future extraction |

## Quality Scenarios

The following quality scenarios (from quality-scenarios.md) were designed under the assumption of a modular monolith:

| ID | Quality Attribute | Scenario Summary |
|----|------------------|-----------------|
| QS-001 | Deployability | Single artifact deployed in < 5 min with zero downtime |
| QS-002 | Modifiability | A change in one module requires no changes in other modules |
| QS-003 | Testability | Full integration test suite runs in < 10 minutes |
| QS-004 | Performance | P99 latency for in-process module calls < 5ms |
| QS-005 | Reliability | Single process failure rate < 0.1% monthly |
| QS-006 | Maintainability | New developer productive within 1 week using single codebase |

## Consequences

**Positive:**
- Simple deployment pipeline (one artifact)
- Easy local development (single process)
- Low operational overhead (no distributed systems concerns)
- In-process communication means no network latency between modules

**Negative:**
- Single scaling unit -- cannot scale modules independently
- Single point of failure for the entire application
- As team grows, merge conflicts and coordination overhead increase
- Technology choices locked to a single runtime

## Superseded

This ADR is superseded by [ADR-006: Use Service-Based Architecture Style](ADR-006.md) due to team growth from 1 to 3 teams. The modular monolith's single deployable unit created unacceptable coordination overhead and deployment contention across multiple teams. See ADR-006 for the full rationale.
