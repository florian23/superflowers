# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics

1. Responsiveness — Real-time notifications within 100ms
2. Elasticity — 10x traffic spikes during live events
3. Fault Tolerance — No message loss during partial outages

## Architecture Drivers

- Real-time sports betting platform
- Live event streaming with millions of concurrent users
- Regulatory: all bets must be auditable

## Selected Architecture Style

**Style:** Event-Driven
**Partitioning:** technical
**Cost Category:** $$$

### Selection Rationale

- Driving characteristics: Responsiveness (★5), Elasticity (★5), Fault Tolerance (★5)
- Fit score: 15/15
- Event-Driven is the only style that scores 5/5 on all three driving characteristics — a perfect fit for a real-time betting platform
- Leads Space-Based (13/15, $$$$) by 2 points at lower cost, and Microservices (12/15, $$$$$) by 3 points at much lower cost
- Asynchronous event processing naturally supports sub-100ms notification delivery, elastic consumer scaling during live events, and guaranteed message delivery through persistent brokers

### Tradeoffs Accepted

- Testability: Rated 2/5 — mitigated by investing in event-tracing test infrastructure, consumer contract tests, and local broker setups for integration testing
- Simplicity: Rated 2/5 — acceptable because the problem domain (real-time betting with millions of users) inherently requires distributed, async processing; a simple architecture would not meet the driving characteristics
- Deployability: Rated 3/5 — acceptable; event processors are independently deployable but require coordinated schema evolution; mitigated by an event schema registry

### Evolution Path

- Phase 1: Event-Driven with broker topology (Kafka/Pulsar) for core bet placement, odds updates, and notification flows
- Phase 2: Introduce mediator topology for complex multi-step workflows (e.g., bet settlement, regulatory reporting)
- Phase 3: If individual event processors grow too complex or teams need full independence, extract high-traffic processors into microservices with their own data stores — but retain the event backbone

### Architecture Style Fitness Functions

These fitness functions enforce the selected style's structural invariants. They are mandatory and immutable — if the implementation violates them, the implementation must change, not the fitness function.

| Fitness Function | What it checks | Tool/Approach |
|---|---|---|
| No synchronous coupling | Event producers don't wait for consumer responses (fire-and-forget or async) | Code analysis for sync calls between event components |
| Event schema registry | All events have defined schemas, versioned | Schema registry check |
| Consumer idempotency | Event consumers handle duplicate events safely | Test for idempotent processing |
| No event orchestration leaks | Mediator topology: only the mediator orchestrates; Broker topology: no central orchestrator | Architecture pattern check |
| Dead letter handling | Failed events go to dead letter queue, not silently dropped | DLQ configuration check |

## Changelog

- 2026-03-29: Initial assessment
- 2026-03-29: Selected Event-Driven architecture style (fit score 15/15, cost $$$)
