# Architecture Characteristics
## Last Updated: 2026-03-29
## Top 3 Priority Characteristics
1. Scalability — Must handle 100k sensors sending data every 5 seconds
2. Elasticity — Traffic spikes 10x during peak hours
3. Fault Tolerance — Zero data loss during partial system failures

## Architecture Drivers
- IoT scale: Massive concurrent connections with bursty traffic
- Cloud-native: AWS deployment

## Selected Architecture Style
**Event-Driven Architecture**

### Why Event-Driven?
- Sensors are natural event producers; the architecture maps directly to the IoT domain
- Message brokers (Kinesis/Kafka) absorb 10x traffic spikes without back-pressure on producers
- Durable event logs guarantee zero data loss — failed consumers replay from last checkpoint
- Producers and consumers scale independently, matching both scalability and elasticity needs
- AWS provides fully managed event-driven services (IoT Core, Kinesis, Lambda, EventBridge)

### Considered Alternatives
| Style | Weighted Score | Reason Not Selected |
|---|---|---|
| Space-Based | 28/30 | High memory cost, limited AWS-native tooling, harder to guarantee durability |
| Microservices | 24/30 | Synchronous calls risk data loss; needs event backbone anyway |
| Service-Based | 18/30 | Coarse scaling insufficient for IoT burst patterns |
| Microkernel | 6/30 | No horizontal scaling; single point of failure |

### Reference Architecture (AWS)
```
[100k Sensors] --MQTT--> [AWS IoT Core] --> [Kinesis Data Streams]
                                                    |
                                        +-----------+-----------+
                                        |                       |
                                [Lambda / ECS Consumers]   [Kinesis Firehose]
                                        |                       |
                                  [DynamoDB]               [S3 Data Lake]
                                        |
                                  [API Gateway] --> [Dashboard]
```

### Key Design Decisions
- **Partition strategy:** Sensor ID as Kinesis partition key to preserve per-device ordering
- **Consumer scaling:** Lambda for sub-second latency; ECS for stateful aggregation workloads
- **Durability:** Kinesis retention 7 days minimum; S3 for long-term archival via Firehose
- **Dead-letter queues:** SQS DLQ for failed processing events — no silent data loss

## Changelog
- 2026-03-29: Initial assessment
- 2026-03-29: Selected Event-Driven Architecture based on weighted analysis of 5 candidate styles
