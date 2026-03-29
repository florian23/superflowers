# Architecture Style Analysis: Live-Betting Platform

## Last Updated: 2026-03-29

## Architecture Characteristics (Priority-Ranked)

| # | Characteristic | Priority | Rationale |
|---|---------------|----------|-----------|
| 1 | Responsiveness | Critical | Real-time odds updates and bet placement within 100ms |
| 2 | Elasticity | Critical | 10x traffic spikes during live events (Champions League final, Super Bowl) |
| 3 | Fault Tolerance | Critical | No message loss; regulatory requirement for bet auditability |
| 4 | Scalability | High | Millions of concurrent users during peak events |
| 5 | Auditability | High | Regulatory compliance: every bet must be traceable end-to-end |
| 6 | Performance | High | Sub-second latency for odds calculation and bet confirmation |

## Architecture Style Evaluation

### Candidate Styles

| Style | Responsiveness | Elasticity | Fault Tolerance | Score |
|-------|---------------|------------|-----------------|-------|
| **Event-Driven** | 5 | 5 | 5 | **15** |
| Microservices | 4 | 5 | 4 | 13 |
| Space-Based | 5 | 5 | 3 | 13 |
| Service-Based | 3 | 3 | 4 | 10 |
| Modular Monolith | 2 | 1 | 3 | 6 |

(Scale: 1 = poor fit, 5 = excellent fit)

### Recommended Style: Event-Driven Architecture (with CQRS + Event Sourcing)

**Why Event-Driven wins for Live Betting:**

1. **Responsiveness**: Asynchronous event streams (Kafka/Pulsar) deliver odds changes to millions of subscribers in real-time via push, not poll. Event-driven decouples producers (odds engine) from consumers (user sessions), eliminating synchronous bottlenecks.

2. **Elasticity**: Event brokers absorb traffic spikes natively. Consumer groups scale horizontally -- add partitions and consumers during a Champions League final without affecting producers. Back-pressure handling is built into the messaging layer.

3. **Fault Tolerance**: Event logs (Kafka) provide durable, replayable message storage. No bet is lost even if downstream services crash -- they replay from the last committed offset. Event Sourcing gives full audit trail for regulatory compliance.

4. **Auditability**: Event Sourcing stores every state change as an immutable event. Regulators can reconstruct the exact sequence: odds published -> bet placed -> bet confirmed -> settlement. This is not an afterthought but a natural byproduct of the architecture.

### Topology Recommendation

```
Event-Driven Architecture with:
- Broker Topology (Kafka/Pulsar as central event backbone)
- CQRS (separate read/write models for odds vs. bet placement)
- Event Sourcing (immutable event log for all bets)
- Saga pattern for distributed bet settlement
```

### Key Components

| Component | Role | Event Interaction |
|-----------|------|-------------------|
| Odds Engine | Calculates live odds from data feeds | Publishes `OddsUpdated` events |
| Bet Placement Service | Accepts and validates bets | Consumes `OddsUpdated`, publishes `BetPlaced` |
| Settlement Service | Settles bets after event outcome | Consumes `EventResultConfirmed`, publishes `BetSettled` |
| Notification Service | Real-time push to users | Consumes all relevant events, pushes via WebSocket |
| Audit Service | Regulatory compliance trail | Consumes ALL events, writes to immutable audit store |
| User Session Service | Manages concurrent connections | Publishes `SessionStarted`/`SessionEnded` |

### Trade-offs Accepted

| Trade-off | Mitigation |
|-----------|-----------|
| Eventual consistency (odds shown vs. odds at bet time) | Optimistic locking + version vector on odds; reject stale bets |
| Increased operational complexity | Invest in observability (distributed tracing, event lineage) |
| Debugging difficulty with async flows | Correlation IDs on every event; centralized event replay tooling |
| Higher infrastructure cost | Justified by regulatory requirements and revenue impact of downtime |

## Rejected Alternatives

- **Microservices (synchronous)**: REST-based synchronous calls create cascading failures under load. Not suitable for real-time odds distribution to millions.
- **Space-Based**: Excellent for elasticity but in-memory data grids add risk for durability. Regulatory audit trail harder to guarantee.
- **Service-Based**: Too coarse-grained. Cannot independently scale odds engine vs. bet placement.
- **Modular Monolith**: Cannot elastically scale individual components. Single deployment unit is a fault tolerance risk.
