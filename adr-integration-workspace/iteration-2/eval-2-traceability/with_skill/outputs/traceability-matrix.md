# ADR-FF Bidirectional Traceability Matrix

## Direction 1: FF -> ADR (Which ADR justifies each FF?)

### Style Fitness Functions (from architecture.md style section)

| # | Fitness Function | What it checks | Tool/Approach | Traced to ADR | Status |
|---|---|---|---|---|---|
| SF-1 | No shared database | Each service owns DB | Config check | ADR-001 | Traced |
| SF-2 | Independent deployability | Build/deploy independently | Pipeline check | ADR-001 | Traced |
| SF-3 | API contract compliance | Only defined API contracts | Pact testing | ADR-001 | Traced |
| SF-4 | No shared biz logic libs | Shared = infra only | Dep analysis | ADR-001 | Traced |
| SF-5 | Service size bounds | LOC/complexity limits | Code metrics | ADR-001 | Traced |

### Characteristic Fitness Functions (from architecture.md characteristics section)

| # | Characteristic | Priority | Goal | FF Description | Cadence | Traced to ADR | Status |
|---|---|---|---|---|---|---|---|
| CF-1 | Scalability | Critical | 100k users | Load test | Nightly | ADR-002 | Traced |
| CF-2 | Fault Tolerance | Critical | Zero data loss | Chaos test | Nightly | ADR-002 | Traced |

## Direction 2: ADR -> FFs (Which FFs does each ADR produce?)

| ADR | Title | Status | Produces FFs |
|---|---|---|---|
| ADR-001 | Use Microservices architecture | Accepted | SF-1, SF-2, SF-3, SF-4, SF-5 (5 style FFs) |
| ADR-002 | Prioritize Scalability, Fault Tolerance, Evolvability | Accepted | CF-1, CF-2 (2 characteristic FFs) |

## Orphan Check: FFs Without ADR Reference

| FF | Has ADR? | Status |
|---|---|---|
| SF-1 through SF-5 | Yes (ADR-001) | OK |
| CF-1, CF-2 | Yes (ADR-002) | OK |

**Result: 0 orphaned fitness functions.** All 7 FFs trace back to a justifying ADR.

## Coverage Check: ADRs Without Corresponding FFs

| ADR | Has FFs? | Expected FFs | Actual FFs | Gap? |
|---|---|---|---|---|
| ADR-001 | Yes | Style FFs for Microservices | 5 style FFs | No gap |
| ADR-002 | Partial | FFs for Scalability, Fault Tolerance, **Evolvability** | 2 of 3 characteristics have FFs | **Gap: Evolvability** |

**Result: 1 gap detected.** ADR-002 declares Evolvability as a driving characteristic but no corresponding fitness function exists.
