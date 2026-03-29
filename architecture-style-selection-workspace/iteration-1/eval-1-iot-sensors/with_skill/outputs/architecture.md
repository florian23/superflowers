# Architecture Characteristics

## Last Updated: 2026-03-29

## Top 3 Priority Characteristics
1. Scalability — Must handle 100k sensors sending data every 5 seconds
2. Elasticity — Traffic spikes 10x during peak hours (6-9 AM, 5-8 PM)
3. Fault Tolerance — Sensor data must not be lost even during partial system failures

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Scalability | Critical | 100k concurrent sensor connections | Yes - load test | Holistic (PR) |
| Elasticity | Critical | Handle 10x traffic spikes within 30s | Yes - spike test | Nightly |
| Fault Tolerance | Critical | Zero data loss during node failures | Yes - chaos test | Nightly |
| Performance | Important | Ingestion latency <50ms p95 | Yes - benchmark | Holistic (PR) |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Deployability | Important | Rolling deploys, zero downtime | Yes - deploy check | Atomic (commit) |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---|---|---|---|---|
| Observability | Important | Full distributed tracing | Yes - trace check | Atomic (commit) |

## Selected Architecture Style

**Style:** Event-Driven
**Partitioning:** technical
**Cost Category:** $$$

### Selection Rationale
- Driving characteristics: Scalability (★5), Elasticity (★5), Fault Tolerance (★5)
- Fit score: 15/15
- Event-Driven and Microservices both scored 15/15, but Event-Driven costs $$$ vs $$$$$ — same fit at lower cost
- IoT sensor data is inherently event-based: sensors emit events, the system consumes asynchronously
- Message brokers (Kafka/Kinesis) provide built-in fault tolerance via persistent, replayable message streams
- AWS cloud-native deployment aligns with Event-Driven patterns (IoT Core → Kinesis → Lambda/ECS)

### Tradeoffs Accepted
- Testability: Rated 2/5 — mitigated by integration tests with embedded message brokers (Testcontainers)
- Simplicity: Rated 2/5 — mitigated by strong observability investment (distributed tracing) and event flow documentation

### Evolution Path
- Start with Event-Driven for the core ingestion and processing pipeline
- If independent team ownership becomes important, extract domain services into a hybrid Event-Driven + Microservices pattern
- Space-Based (13/15) remains viable if in-memory processing becomes necessary for sub-millisecond latency requirements

## Architecture Drivers
- IoT scale: Massive concurrent connections with bursty traffic patterns
- Data integrity: Sensor readings are business-critical, no data loss acceptable
- Cloud-native: Deploying on AWS with auto-scaling groups

## Architecture Decisions
- Event-Driven architecture selected based on Architecture Styles Worksheet scoring

## Changelog
- 2026-03-29: Initial architecture assessment
- 2026-03-29: Selected Event-Driven architecture (fit score 15/15, $$$)
