# Traceability Analysis: ADR <-> Fitness Function Integration

## Summary

| Metric | Result |
|---|---|
| Total ADRs | 2 |
| Total Fitness Functions | 7 (5 style + 2 characteristic) |
| FFs with ADR reference | 7/7 (100%) |
| ADRs with full FF coverage | 1/2 (50%) |
| Orphaned FFs | 0 |
| ADRs with missing FFs | 1 (ADR-002 missing Evolvability FF) |

## Findings

### Finding 1: Style FF traceability is complete

All 5 style fitness functions (no shared database, independent deployability, API contract compliance, no shared biz logic libs, service size bounds) correctly reference ADR-001. The reverse direction also holds: ADR-001 maps to exactly these 5 FFs, which are the standard structural invariants for a Microservices architecture per `references/style-fitness-functions.md`.

**Verdict:** Full bidirectional traceability for ADR-001.

### Finding 2: Characteristic FF traceability has a gap

ADR-002 prioritizes three characteristics: Scalability, Fault Tolerance, and Evolvability. However, only Scalability and Fault Tolerance have corresponding fitness functions (load test and chaos test). **Evolvability has no fitness function.**

This is a traceability violation. The architecture-decisions skill states:

> "Every fitness function in architecture.md has an ADR reference column. When an ADR is superseded, all FFs referencing that ADR are identified and replaced."

If Evolvability has no FF, it cannot participate in the superseding cascade and effectively becomes an undeclared, unverified characteristic.

**Verdict:** ADR-002 -> FF direction is incomplete. Evolvability needs a fitness function.

### Finding 3: No orphaned fitness functions

Every FF in both tables has an explicit ADR reference. This means no FF exists without documented justification -- the "why does this FF exist?" question can always be answered by reading the referenced ADR.

## Recommended Actions

| Priority | Action | Rationale |
|---|---|---|
| High | Add Evolvability fitness function to architecture.md characteristics table with ADR-002 reference | Close the traceability gap. Possible FF: "component replaceability -- swap a service implementation within N hours" or "dependency freshness -- no dependency older than N months." |
| Low | Consider whether ADR-002's Evolvability characteristic was intentionally left without an FF (e.g., deferred to a later phase) and if so, document that decision | Prevents this gap from being flagged repeatedly. |

## How the Skills Enable This Traceability

The bidirectional link works because two skills cooperate:

1. **architecture-style-selection** (Step 6) copies style FFs into architecture.md with an ADR column, linking each structural invariant to the style-selection ADR.
2. **architecture-decisions** (Step 4) requires cross-referencing: "Add ADR reference to fitness functions -- if this ADR justifies specific FFs, add the ADR number to the FF table."

Together these create a closed loop: every FF has a justification (ADR), and every ADR's consequences are operationalized (FFs). The one gap found (Evolvability) is a content omission, not a process gap -- the skill framework supports it, but the characteristic FF was never defined.
