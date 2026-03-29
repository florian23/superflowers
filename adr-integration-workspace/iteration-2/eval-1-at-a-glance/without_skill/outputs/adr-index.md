# ADR Index

## Current Architecture at a Glance

The system follows a **service-based architecture** with **PostgreSQL** as the primary database and **RabbitMQ** for asynchronous messaging between services. REST was originally mandated as the inter-service communication style but is no longer enforced as a constraint; teams may adopt alternative protocols as appropriate.

## Decision Log

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](all-adrs.md#adr-001-adopt-service-based-architecture) | Adopt Service-Based Architecture | **Accepted** |
| [ADR-002](all-adrs.md#adr-002-use-sqlite-for-persistence) | Use SQLite for Persistence | **Superseded** by ADR-005 |
| [ADR-003](all-adrs.md#adr-003-use-rest-for-inter-service-communication) | Use REST for Inter-Service Communication | **Deprecated** |
| [ADR-004](all-adrs.md#adr-004-introduce-rabbitmq-for-asynchronous-messaging) | Introduce RabbitMQ for Asynchronous Messaging | **Accepted** |
| [ADR-005](all-adrs.md#adr-005-use-postgresql-for-persistence) | Use PostgreSQL for Persistence | **Accepted** |
