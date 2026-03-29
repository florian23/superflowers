# Architecture Style Fitness Functions

Each architecture style has structural invariants that must hold throughout implementation.
These fitness functions are generated during architecture-style-selection and enforced by the fitness-functions skill.

Fitness functions are organized by style. When a style is selected, ALL fitness functions for that style become mandatory.
When an evolution path is defined (e.g., "start service-based, evolve to microservices"), the current phase's fitness functions apply.

## Layered

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| Layer dependency direction | No upward dependencies (presentation → business → persistence, never reverse) | dependency-cruiser, ArchUnit, import-linter |
| No layer bypass | Presentation never accesses persistence directly | Static analysis on import paths |
| Layer isolation | Each layer in its own package/module/directory | Directory structure check |

## Modular Monolith

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No circular module dependencies | Module A → B means B must not → A (directly or transitively) | dependency-cruiser, ArchUnit |
| Module boundary enforcement | Cross-module access only through public API (no internal imports) | Package visibility rules, lint rules |
| Single deployment artifact | Build produces exactly one deployable unit | Build script check |
| Database schema per module | Each module owns its tables, no cross-module direct table access | SQL analysis or ORM config check |

## Microkernel

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| Core-plugin separation | Core has no compile-time dependency on any plugin | Dependency analysis |
| Plugin interface compliance | All plugins implement the defined plugin interface/contract | Interface check, type check |
| Plugin isolation | Plugins cannot depend on other plugins directly | Import/dependency analysis |
| Core stability | Core API surface area does not grow with each plugin | API surface metric |

## Microservices

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No shared database | Each service has its own database/schema, no shared tables | DB connection config analysis |
| Independent deployability | Each service can be built and deployed independently | Build pipeline check |
| API contract compliance | Services communicate only via defined API contracts (REST/gRPC/events) | Contract testing (Pact, Spring Cloud Contract) |
| No shared libraries with business logic | Shared code limited to infrastructure concerns (logging, auth), not domain logic | Dependency analysis on shared packages |
| Service size bounds | Each service stays within defined LOC/complexity limits | Code metrics |

## Service-Based

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| Service boundary alignment | Services align with documented domain boundaries | Directory/package structure check |
| Limited service count | Total number of services within defined range (typically 4-12) | Service registry/count check |
| No service-to-service chatter | Service-to-service calls within defined limits (< N calls per request) | Runtime tracing or static call graph |
| Database sharing discipline | If shared DB: each service accesses only its own tables/views | SQL analysis, ORM scope check |

## Service-Oriented (SOA)

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| Service contract registry | All services have registered contracts in a central registry | Registry check |
| Orchestration layer exists | Business processes go through orchestration, not point-to-point | Architecture diagram validation |
| No direct service coupling | Services communicate through the bus/mediator, not directly | Network/import analysis |

## Event-Driven

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No synchronous coupling | Event producers don't wait for consumer responses (fire-and-forget or async) | Code analysis for sync calls between event components |
| Event schema registry | All events have defined schemas, versioned | Schema registry check |
| Consumer idempotency | Event consumers handle duplicate events safely | Test for idempotent processing |
| No event orchestration leaks | Mediator topology: only the mediator orchestrates; Broker topology: no central orchestrator | Architecture pattern check |
| Dead letter handling | Failed events go to dead letter queue, not silently dropped | DLQ configuration check |

## Space-Based

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No direct database writes in hot path | Processing units write to data grid, not directly to DB | Code analysis on write paths |
| Processing unit statelessness | Processing units can be replicated without shared mutable state | State analysis |
| Data replication configured | Data grid replication factor ≥ 2 for fault tolerance | Config check |
| Async database sync | Database writes happen through async data pumps, not synchronous | Architecture pattern check |

## How to use this reference

1. After selecting an architecture style, copy that style's fitness functions into `architecture.md` under a new "## Architecture Style Fitness Functions" section
2. During writing-plans, include tasks for implementing each fitness function
3. During implementation, the fitness-functions skill enforces these alongside characteristic-based fitness functions
4. During verification, ALL style fitness functions must pass — no exceptions

## Extending

To add fitness functions for a new style:
1. Identify the style's core structural invariants (what MUST be true for this to actually be that style?)
2. For each invariant, define what to check and how to automate it
3. Add a new section following the table format above
4. Ensure at least 3 fitness functions per style — fewer means the style isn't being enforced meaningfully
