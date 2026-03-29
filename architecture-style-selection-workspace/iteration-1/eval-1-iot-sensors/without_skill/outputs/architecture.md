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

**Style:** Event-Driven Architecture
**Rationale:** Natural fit for IoT sensor streaming. Kafka/Kinesis provides fault tolerance via durable message streams. Consumer groups enable horizontal scaling and elastic burst handling.

## Architecture Drivers
- IoT scale: Massive concurrent connections with bursty traffic patterns
- Data integrity: Sensor readings are business-critical, no data loss acceptable
- Cloud-native: Deploying on AWS with auto-scaling groups

## Changelog
- 2026-03-29: Initial architecture assessment
- 2026-03-29: Selected Event-Driven architecture
