# Architecture Style Recommendation — IoT Sensor Data Processing

## Context

We need to select an architecture for an IoT sensor data processing service with these key requirements:
- 100k concurrent sensors sending data every 5 seconds (~20k msg/sec sustained, ~200k msg/sec peak)
- 10x traffic spikes during peak hours
- Zero data loss during failures

## Recommended Architecture: Event-Driven Architecture

### Why Event-Driven?

IoT sensor data processing is a textbook use case for event-driven architecture:

1. **Natural event flow**: Sensors produce data events → message broker buffers and distributes → consumers process asynchronously
2. **Scalability**: Consumer groups scale horizontally. Adding more consumers handles more throughput without architectural changes.
3. **Elasticity**: Auto-scaling consumer groups handle traffic spikes. Message broker absorbs bursts when consumers lag.
4. **Fault tolerance**: Durable message queues (Kafka, AWS Kinesis) persist messages. If a consumer crashes, messages are replayed from the last checkpoint.

### Suggested AWS Architecture

```
Sensors → IoT Core (MQTT) → Kinesis Data Streams → Lambda/ECS Consumers → DynamoDB/S3
```

- **IoT Core**: Manages 100k persistent MQTT connections
- **Kinesis**: Durable, scalable event stream with replay capability
- **Lambda or ECS**: Processing consumers, auto-scaled based on stream throughput
- **DynamoDB/S3**: Processed data storage

### Alternatives Considered

**Microservices**: Good scalability but the request/response model is a poor fit for high-throughput streaming. More operational overhead with service mesh and API gateways.

**Space-Based**: Excellent for extreme throughput with in-memory data grids, but adds significant complexity and in-memory data is vulnerable during failures — conflicts with zero data loss requirement.

### Tradeoffs

- Event-driven is harder to test and debug than synchronous architectures
- Need strong observability (distributed tracing) to track event flows
- Eventually consistent — not suitable if strong consistency is required (not the case here)
