# Architecture Decision Records

---

## ADR-001: Adopt Service-Based Architecture

**Status:** Accepted

### Context

The system needs a clear architectural style that balances modularity with operational simplicity. A monolithic approach would become difficult to maintain as the codebase grows, while a full microservices architecture introduces operational complexity that is not yet justified.

### Decision

We will adopt a service-based architecture. The system will be decomposed into a set of coarse-grained, independently deployable services, each owning a distinct domain capability.

### Consequences

- Services can be developed and deployed independently, improving team autonomy.
- Coarse-grained services keep operational overhead lower than a microservices approach.
- Clear service boundaries enforce separation of concerns.
- Inter-service communication patterns must be explicitly defined.

---

## ADR-002: Use SQLite for Persistence

**Status:** Superseded by [ADR-005](#adr-005-use-postgresql-for-persistence)

### Context

The system needed a lightweight persistence layer during early development. SQLite offered zero-configuration setup and file-based storage, making it easy to get started.

### Decision

We will use SQLite as the primary database for all services.

### Consequences

- Zero operational overhead for database setup.
- Single-file storage simplifies backups and local development.
- Limited support for concurrent writes across multiple service instances.
- No built-in network access, making shared database patterns difficult.

---

## ADR-003: Use REST for Inter-Service Communication

**Status:** Deprecated

### Context

Services in the system need a standard protocol for synchronous communication. REST over HTTP is widely understood, well-tooled, and aligns with the service-based architecture.

### Decision

We will use REST as the standard protocol for inter-service communication.

### Consequences

- Familiar to most developers, reducing onboarding friction.
- Rich ecosystem of tooling for documentation (OpenAPI), testing, and monitoring.
- Synchronous request/response model can introduce coupling and latency chains.
- Not ideal for event-driven or fire-and-forget communication patterns.

### Deprecation Note

REST is no longer enforced as a mandatory constraint. With the introduction of RabbitMQ (ADR-004), teams may choose the communication style that best fits their use case, including asynchronous messaging. Existing REST endpoints remain valid but new services are not required to expose them.

---

## ADR-004: Introduce RabbitMQ for Asynchronous Messaging

**Status:** Accepted

### Context

As the system grew, several inter-service interactions proved to be a poor fit for synchronous REST calls. Long-running processes, event notifications, and fire-and-forget commands introduced tight coupling and fragile latency chains. The architecture needs an asynchronous messaging capability to complement synchronous communication.

### Decision

We will introduce RabbitMQ as the message broker for asynchronous inter-service communication. Services may publish and consume messages for event-driven workflows, background processing, and decoupled integration.

### Consequences

- Enables event-driven patterns that reduce temporal coupling between services.
- Improves resilience: producers and consumers do not need to be available simultaneously.
- Supports workload buffering and back-pressure for high-throughput scenarios.
- Adds operational complexity: the broker must be deployed, monitored, and maintained.
- Teams must manage message schemas, idempotency, and dead-letter handling.

---

## ADR-005: Use PostgreSQL for Persistence

**Status:** Accepted

**Supersedes:** [ADR-002](#adr-002-use-sqlite-for-persistence)

### Context

SQLite (ADR-002) served well during early development but has become a bottleneck. Multiple service instances now require concurrent write access, and the system needs features such as robust indexing, full-text search, role-based access control, and network-accessible connections that SQLite cannot provide.

### Decision

We will replace SQLite with PostgreSQL as the primary relational database. All services will migrate their persistence layer to PostgreSQL.

### Consequences

- Full support for concurrent reads and writes across multiple service instances.
- Rich feature set including advanced indexing, JSONB columns, and full-text search.
- Network-accessible, enabling shared and per-service database patterns.
- Requires operational investment: provisioning, backups, connection pooling, and monitoring.
- Migration effort needed to move existing SQLite schemas and data.
