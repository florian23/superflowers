# Architecture Style Analysis: E-Commerce Replatforming

## Context
- 3 autonomous teams: Catalog, Checkout, Fulfillment
- Legacy monolith migration (gradual preferred)
- Revenue-critical system
- Black Friday peaks: 50x checkout traffic, 10x catalog traffic

## Priority Characteristics
1. **Evolvability** — Independent feature evolution across 3 teams
2. **Maintainability** — Each team owns their domain independently
3. **Scalability** — Extreme traffic spikes (Black Friday)

## Candidates Evaluated

### 1. Microservices Architecture
| Characteristic | Fit | Rationale |
|---|---|---|
| Evolvability | High | Each team deploys independently, own tech choices |
| Maintainability | High | Clear service boundaries per team domain |
| Scalability | High | Scale checkout independently from catalog |

- **Pros**: Perfect team-to-service alignment, independent scaling, independent deployment
- **Cons**: High operational complexity, distributed data management, eventual consistency challenges
- **Migration path**: Strangler Fig pattern from monolith — extract domain by domain

### 2. Modular Monolith
| Characteristic | Fit | Rationale |
|---|---|---|
| Evolvability | Medium | Modules can evolve, but shared deployment |
| Maintainability | Medium-High | Clear module boundaries, simpler ops |
| Scalability | Low | Cannot scale checkout independently from catalog |

- **Pros**: Simpler operations, shared database, good stepping stone
- **Cons**: Cannot independently scale for Black Friday peaks, single deployment unit blocks team autonomy
- **Migration path**: Good intermediate step but insufficient as target

### 3. Service-Based Architecture (Hybrid)
| Characteristic | Fit | Rationale |
|---|---|---|
| Evolvability | Medium-High | Coarser services still allow independent evolution |
| Maintainability | High | Fewer services = lower operational burden |
| Scalability | Medium-High | Can scale per domain, but less granular |

- **Pros**: Balance of independence and simplicity, 1 service per team domain
- **Cons**: Less granular scaling within a domain, risk of creating "mini-monoliths"
- **Migration path**: Natural Strangler Fig target — one service per domain extracted

## Decision Matrix

| Characteristic | Weight | Microservices | Modular Monolith | Service-Based |
|---|---|---|---|---|
| Evolvability | 35% | 5 (1.75) | 3 (1.05) | 4 (1.40) |
| Maintainability | 35% | 3 (1.05) | 4 (1.40) | 4 (1.40) |
| Scalability | 30% | 5 (1.50) | 2 (0.60) | 4 (1.20) |
| **Total** | | **4.30** | **3.05** | **4.00** |

## Recommendation

**Microservices Architecture** scores highest due to the combination of:
- 3 autonomous teams needing independent deployment and evolution
- Extreme scaling requirements (50x checkout spikes) demanding per-service scaling
- Revenue-critical nature requiring fault isolation (checkout failure must not take down catalog)

### Migration Strategy
Use **Strangler Fig** pattern:
1. **Phase 1**: Extract Catalog service (lowest risk, read-heavy)
2. **Phase 2**: Extract Checkout service (highest scaling need, revenue-critical)
3. **Phase 3**: Extract Fulfillment service (completes migration)

Each phase: monolith and new service run in parallel with traffic gradually shifted via facade/proxy.

### Key Risk
Operational complexity is the primary trade-off. Mitigate with:
- Platform team or shared infrastructure (CI/CD, observability, service mesh)
- Start with 3 coarse-grained services (one per team), decompose further only when needed
