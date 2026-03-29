# ADR-001: Use Service-Based architecture

## Status
Accepted

## Context
The system needs an architectural approach that balances modularity with operational simplicity. Alternatives considered:
- **Monolithic architecture** — simpler deployment but harder to scale and evolve independently.
- **Microservices architecture** — maximum independence but significant operational overhead for a team of this size.
- **Service-Based architecture** — coarse-grained services with a shared database option, balancing modularity and simplicity.

The team is small and deployment complexity must stay manageable while still allowing independent evolution of major domains.

## Decision
We will use Service-Based architecture because it provides domain-level modularity without the operational overhead of microservices, matching our team size and deployment constraints.

## Consequences
- **Easier:** Services can be developed and deployed semi-independently; clear domain boundaries reduce cognitive load.
- **Harder:** Shared infrastructure (e.g., database) introduces coupling risks; service granularity decisions require discipline.
- We accept coarser granularity than microservices in exchange for simpler operations.

---

# ADR-002: Use SQLite for persistence

## Status
Superseded by ADR-005

## Context
The system needs a persistence layer. Alternatives considered:
- **SQLite** — zero-configuration, embedded, file-based database suitable for simple deployments.
- **PostgreSQL** — full-featured relational database with strong concurrency support but requires separate server management.
- **MySQL** — widely used relational database but adds operational overhead similar to PostgreSQL without the advanced feature set.

At this stage, the system has low concurrency requirements and benefits from minimal infrastructure.

## Decision
We will use SQLite for persistence because it requires zero configuration, simplifies deployment, and is sufficient for our current scale.

## Consequences
- **Easier:** No database server to manage; single-file storage simplifies backups and local development.
- **Harder:** Limited concurrency; no network access for multiple services; migration to a full RDBMS will be needed if scale increases.
- We accept the scaling limitation in exchange for operational simplicity.

---

# ADR-003: Use REST for API communication

## Status
Deprecated

## Context
The system needs a protocol for inter-service and client-server communication. Alternatives considered:
- **REST (HTTP/JSON)** — widely understood, tooling-rich, stateless, and well-suited for CRUD-style operations.
- **GraphQL** — flexible querying for clients with diverse data needs, but adds schema complexity.
- **gRPC** — high-performance binary protocol, ideal for internal service-to-service calls, but less browser-friendly.

The team has strong REST experience and the API surface is predominantly CRUD-oriented.

## Decision
We will use REST for API communication because it aligns with team expertise, has mature tooling, and fits our CRUD-oriented API surface.

## Consequences
- **Easier:** Familiar to all team members; extensive tooling and documentation standards (OpenAPI); stateless request model simplifies scaling.
- **Harder:** Over-fetching / under-fetching for complex queries; no built-in streaming; versioning requires discipline.
- We accept REST's verbosity in exchange for simplicity and team familiarity.

---

# ADR-004: Introduce RabbitMQ for async messaging

## Status
Accepted

## Context
As the system grows, some operations (notifications, report generation, data syncing) should not block the request-response cycle. Alternatives considered:
- **Synchronous HTTP calls** — simple but couples services temporally and reduces resilience.
- **RabbitMQ** — mature, well-supported message broker with flexible routing, durable queues, and good monitoring.
- **Apache Kafka** — event streaming platform with strong ordering guarantees, but higher operational complexity than needed for our use case.
- **Redis Pub/Sub** — lightweight but lacks message durability and acknowledgment guarantees.

The system needs reliable async messaging for background tasks without the operational overhead of a full event streaming platform.

## Decision
We will introduce RabbitMQ for async messaging because it provides durable, reliable message delivery with flexible routing patterns at lower operational complexity than Kafka, matching our current scale.

## Consequences
- **Easier:** Services are decoupled temporally; background tasks (notifications, reports) no longer block API responses; RabbitMQ's management UI simplifies monitoring.
- **Harder:** New infrastructure dependency to operate and monitor; message ordering is per-queue only; developers must handle idempotency and dead-letter scenarios.
- We accept the added infrastructure complexity in exchange for improved resilience and responsiveness.

---

# ADR-005: Use PostgreSQL for persistence

## Status
Accepted

## Context
This supersedes ADR-002 because the system's concurrency and data requirements have outgrown SQLite's capabilities. With multiple services needing concurrent database access and increasing data volumes, an embedded database is no longer sufficient. Alternatives considered:
- **SQLite (status quo)** — no concurrency support for multiple services; file-locking issues under load.
- **PostgreSQL** — robust concurrency, ACID compliance, rich indexing, and strong ecosystem support.
- **MySQL** — viable but PostgreSQL offers superior support for complex queries, JSON data, and extensibility.

The Service-Based architecture (ADR-001) increasingly requires services to access persistent data concurrently, which SQLite cannot support reliably.

## Decision
We will use PostgreSQL for persistence because it provides the concurrency, reliability, and feature set required by our growing multi-service architecture.

## Consequences
- **Easier:** Multiple services can access the database concurrently; advanced indexing and query capabilities improve performance; strong migration tooling (Flyway, Liquibase) available.
- **Harder:** Requires a managed database server; operational overhead increases (backups, monitoring, connection pooling); local development setup is more complex than SQLite.
- We accept the increased operational complexity in exchange for production-grade concurrency and reliability.
