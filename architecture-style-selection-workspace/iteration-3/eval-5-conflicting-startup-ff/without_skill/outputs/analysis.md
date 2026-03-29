# Architecture Analysis: MVP Speed vs. Scalability

## Conflict Assessment

The stated characteristics are in tension:

| Characteristic | Implication | Conflict |
|---|---|---|
| Simplicity | Monolith, minimal moving parts, fast to ship | Opposes distributed scalability |
| Scalability | Decomposed services, independent scaling | Opposes simplicity and solo-dev speed |
| Elasticity | Auto-scaling, stateless design, async processing | Adds operational complexity |

**Core tension:** Simplicity demands a monolith. Scalability and elasticity demand decomposition. A solo developer cannot build microservices in 4 weeks.

## Architecture Style Evaluation

### 1. Modular Monolith (Recommended)

- **Simplicity:** High. Single deployable, one repo, one pipeline.
- **Scalability:** Medium. Horizontal scaling of the whole unit. Internal module boundaries enable future extraction.
- **Elasticity:** Medium. Stateless design + container auto-scaling handles spikes. Not per-module, but sufficient for MVP.
- **Time to MVP:** 2-3 weeks.
- **Migration path:** Extract hot modules into services when traffic justifies it.

### 2. Serverless Functions

- **Simplicity:** Medium. No infra management, but cold starts, vendor lock-in, function orchestration complexity.
- **Scalability:** High. Per-function scaling.
- **Elasticity:** High. Inherent auto-scaling.
- **Time to MVP:** 3-4 weeks. Debugging and testing overhead is higher for a solo dev.
- **Risk:** Vendor lock-in, cost unpredictability at scale.

### 3. Microservices

- **Simplicity:** Low. Multiple repos, service discovery, distributed tracing, API contracts.
- **Scalability:** High.
- **Elasticity:** High.
- **Time to MVP:** 6-10 weeks. Not viable for 1 dev in 4 weeks.

## Recommendation

**Modular Monolith deployed as a container on a platform with auto-scaling** (e.g., Cloud Run, Fly.io, Railway).

Rationale:
- Ships in 4 weeks with 1 developer.
- Stateless container design gives elasticity via platform auto-scaling.
- Internal module boundaries (clear interfaces, no shared mutable state between modules) make future service extraction straightforward.
- This is a "scale later" strategy, not a "never scale" strategy.

## Fitness Functions

### FF-1: Deployment Simplicity

- **Metric:** Number of independently deployed artifacts.
- **Threshold:** Must equal 1 for MVP phase.
- **Measurement:** CI/CD pipeline artifact count.
- **Rationale:** More than 1 artifact means premature decomposition.

### FF-2: Module Coupling

- **Metric:** Cross-module direct dependencies (imports between module internals, not through public APIs).
- **Threshold:** 0 cross-module internal imports.
- **Measurement:** Static analysis / architecture linting (e.g., ArchUnit, deptry, eslint boundaries plugin).
- **Rationale:** Clean module boundaries are the prerequisite for future service extraction. If modules are tangled, extraction becomes a rewrite.

### FF-3: Horizontal Scalability Readiness

- **Metric:** Stateless request handling — no in-process session state, no local file system writes for request data.
- **Threshold:** 100% of endpoints stateless.
- **Measurement:** Automated test: spin up 2 instances behind a load balancer, run integration tests with round-robin routing. All tests must pass.
- **Rationale:** If the monolith can run as N identical instances, platform auto-scaling handles elasticity.

### FF-4: Response Time Under Load

- **Metric:** p95 response time under 10x baseline load.
- **Threshold:** p95 < 500ms at 10x expected baseline traffic.
- **Measurement:** Load test (k6, artillery) against staging, run weekly.
- **Rationale:** Detects scaling bottlenecks (database connections, blocking I/O) before they hit production.

### FF-5: Module Extraction Readiness

- **Metric:** Each module can be tested in isolation (own test suite, mock external module interfaces).
- **Threshold:** 100% of modules have isolated test suites that pass without other modules loaded.
- **Measurement:** CI job per module running tests with other modules stubbed.
- **Rationale:** If a module can test in isolation, it can deploy in isolation. This is the leading indicator for extractability.

## Migration Triggers

Move from modular monolith to extracted services when:
- A single module consumes >60% of total compute.
- Team grows beyond 3 developers working on the same module.
- Deployment frequency is blocked by unrelated module changes.

These triggers should be monitored, not anticipated.
