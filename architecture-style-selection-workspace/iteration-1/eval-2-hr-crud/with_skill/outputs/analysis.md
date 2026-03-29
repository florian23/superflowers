# Architecture Style Selection — HR CRUD Tool

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

From `architecture.md`:

| # | Characteristic | Concrete Goal |
|---|---|---|
| 1 | **Simplicity** | New dev productive within 1 week |
| 2 | **Testability** | >90% test coverage |
| 3 | **Deployability** | <30min deploy, rollback in <5min |

## Step 2: Architecture Style Fit Analysis

Top 3 Driving Characteristics: Simplicity, Testability, Deployability

| Rank | Style | Simplicity | Testability | Deployability | Fit Score | Cost |
|------|-------|-----------|-------------|---------------|-----------|------|
| 1 | **Microkernel** | ★★★★★ | ★★★ | ★★★ | **11/15** | $ |
| 2 | **Service-Based** | ★★★ | ★★★★ | ★★★★ | **11/15** | $$ |
| 3 | **Microservices** | ★ | ★★★★★ | ★★★★★ | **11/15** | $$$$$ |
| 4 | **Modular Monolith** | ★★★★★ | ★★ | ★ | **8/15** | $ |
| 4 | **Layered** | ★★★★★ | ★★ | ★ | **8/15** | $ |
| 6 | Event-Driven | ★★ | ★★ | ★★★ | 7/15 | $$$ |
| 7 | Space-Based | ★ | ★ | ★★★ | 5/15 | $$$$ |
| 8 | Service-Oriented | ★ | ★ | ★ | 3/15 | $$$$ |

## Step 3: Tradeoff Analysis

### Microkernel (11/15, $) — Recommended

**Strengths:**
- Highest simplicity (5/5) — the core system is small and understandable
- Lowest cost ($) — minimal infrastructure
- Plugin architecture provides extensibility when needed (reports, integrations)
- Core + plugins model works well for CRUD: core = HR domain logic, plugins = report generators, data exports

**Weaknesses:**
- Testability (3/5) — adequate but not exceptional. Plugin isolation helps unit testing.
- Deployability (3/5) — single deployable unit, straightforward but not CI/CD optimized

**Why it wins over competitors:**
- Service-Based ties on score but costs $$ and drops simplicity to 3/5 — directly conflicts with the #1 priority
- Microservices ties on score but costs $$$$$ — absurd for a 50-user internal tool with 2 developers

### Red Flag Check
- **Premature distribution:** Simplicity is a driving characteristic AND this is a new system with 50 users. Distributed architectures (Microservices, Event-Driven, Space-Based) should not be considered. ✓ Eliminated.
- **Resume-driven architecture:** The matrix data shows Microservices at $$$$$ for a tool that doesn't need scaling. ✓ Correctly deprioritized.

### Modular Monolith (8/15, $) — Runner-up

Worth noting: scores lower due to testability (2/5) and deployability (1/5), but in practice a well-structured modular monolith can achieve >90% test coverage. The matrix penalizes monoliths on deployability because they require full redeployment, but with only weekly releases this is acceptable. If microkernel feels unusual for CRUD, modular monolith is the safe alternative.

## Step 4: Recommendation

**Microkernel** — best balance of simplicity and extensibility at minimum cost. The 2-person team can focus on building the core HR domain without operational overhead.

If the team prefers a more conventional pattern, **Modular Monolith** is a solid fallback — slightly lower matrix score but well-understood and proven for CRUD applications.
