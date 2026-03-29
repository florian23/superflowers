# ADR-003: Introduce message queue for order-inventory communication

## Status
Accepted

## Context
The order processing system communicates with the inventory service via synchronous HTTP calls. Under load, these calls cause timeout issues — the inventory service cannot respond within acceptable time limits, leading to failed orders and degraded user experience.

This was not planned during the initial architecture assessment (ADR-001: Use Service-Based architecture). The assumption was that synchronous REST communication between services would be sufficient. Production load testing revealed this assumption to be wrong.

Alternatives considered:

1. **Increase timeouts and add retries** — Simple to implement but only masks the problem. Under sustained load, retries amplify traffic (retry storms) and make the situation worse. Does not address the fundamental coupling.
2. **Introduce a message queue (RabbitMQ or Kafka)** — Decouples order placement from inventory reservation. Orders are published to a queue and processed asynchronously. Adds infrastructure complexity but eliminates the synchronous bottleneck.
3. **Circuit breaker pattern on existing HTTP calls** — Prevents cascade failures but degrades functionality (orders would be rejected when the circuit is open). Treats the symptom, not the cause.

## Decision
We will introduce a message queue between the order service and the inventory service, because synchronous HTTP calls do not scale under production load and asynchronous messaging decouples the two services, allowing each to scale independently.

The specific technology choice (RabbitMQ vs Kafka) will be evaluated separately based on throughput requirements and operational expertise.

## Consequences

**What gets easier:**
- Order placement is no longer blocked by inventory service latency — orders are accepted immediately and processed asynchronously
- Each service can scale independently; inventory processing can be scaled horizontally via competing consumers
- Transient inventory service outages no longer cause order failures — messages are buffered in the queue

**What gets harder:**
- The system moves from request-response to eventual consistency for inventory reservation — the UI must handle "order accepted, inventory pending" states
- Operational complexity increases: the message queue becomes critical infrastructure that must be monitored, backed up, and kept available
- Debugging becomes harder — tracing a request across asynchronous boundaries requires distributed tracing (correlation IDs)
- Error handling is more complex: dead letter queues, poison messages, and idempotent consumers must be implemented

**Tradeoffs accepted:**
- Eventual consistency over immediate consistency for inventory checks
- Higher infrastructure complexity over simpler synchronous communication
