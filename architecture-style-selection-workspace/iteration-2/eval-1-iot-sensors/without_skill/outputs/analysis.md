# Architecture Style Analysis — IoT Sensor Service

## Input Summary

| Characteristic | Priority | Requirement |
|---|---|---|
| Scalability | 1 | 100k sensors, data every 5 seconds |
| Elasticity | 2 | 10x traffic spikes during peak hours |
| Fault Tolerance | 3 | Zero data loss during partial failures |

**Drivers:** Massive concurrent IoT connections, bursty traffic, AWS cloud-native deployment.

## Candidate Architecture Styles

### 1. Event-Driven Architecture (EDA)

**Fit for characteristics:**

- **Scalability (high fit):** Event brokers like Kafka or AWS Kinesis handle millions of events per second. 100k sensors at 5-second intervals produce ~20k messages/second — well within capacity.
- **Elasticity (high fit):** Consumers scale independently from producers. During 10x spikes (~200k msg/s), additional consumer instances spin up without affecting ingestion.
- **Fault Tolerance (high fit):** Message brokers provide durable, replicated storage. Events persist until processed, guaranteeing zero data loss even when downstream services fail.

**Trade-offs:** Eventual consistency, increased operational complexity for broker management, debugging async flows is harder.

**Star rating:** 5/5

### 2. Microservices Architecture

**Fit for characteristics:**

- **Scalability (high fit):** Individual services scale independently; ingestion service scales differently from processing or storage services.
- **Elasticity (medium fit):** Container orchestration (ECS/EKS) enables auto-scaling, but each service needs its own scaling policy — more configuration overhead.
- **Fault Tolerance (medium fit):** Service isolation prevents cascading failures. However, without an event broker, synchronous inter-service calls risk data loss during failures.

**Trade-offs:** Significant operational overhead, distributed data management complexity, network latency between services.

**Star rating:** 3/5

### 3. Space-Based Architecture

**Fit for characteristics:**

- **Scalability (high fit):** In-memory data grids handle extreme throughput.
- **Elasticity (high fit):** Processing units replicate on demand.
- **Fault Tolerance (medium fit):** Relies on replication for durability. In-memory state can be lost in catastrophic failures unless backed by persistent storage.

**Trade-offs:** High cost (memory-intensive), complex to implement and test, limited AWS-native tooling support.

**Star rating:** 3/5

### 4. Microkernel (Plugin) Architecture

**Fit for characteristics:**

- **Scalability (low fit):** Monolithic core limits horizontal scaling.
- **Elasticity (low fit):** Cannot independently scale subsystems.
- **Fault Tolerance (low fit):** Core failure takes down the entire system.

**Star rating:** 1/5

### 5. Service-Based Architecture

**Fit for characteristics:**

- **Scalability (medium fit):** Coarser-grained services scale, but less granularly than microservices.
- **Elasticity (medium fit):** Fewer services to scale, but each service is larger.
- **Fault Tolerance (medium fit):** Shared database can become single point of failure.

**Star rating:** 2/5

## Scoring Matrix

| Style | Scalability (w:3) | Elasticity (w:2) | Fault Tolerance (w:1) | Weighted Score |
|---|---|---|---|---|
| Event-Driven | 5 (15) | 5 (10) | 5 (5) | **30** |
| Microservices | 5 (15) | 3 (6) | 3 (3) | **24** |
| Space-Based | 5 (15) | 5 (10) | 3 (3) | **28** |
| Service-Based | 3 (9) | 3 (6) | 3 (3) | **18** |
| Microkernel | 1 (3) | 1 (2) | 1 (1) | **6** |

*Weights reflect priority ranking: Scalability=3, Elasticity=2, Fault Tolerance=1.*

## Recommendation

**Event-Driven Architecture** is the strongest fit for this IoT sensor service.

### Rationale

1. **Natural IoT alignment:** Sensors are inherently event producers. An event-driven model maps directly to the domain — each sensor reading is an event, routed through a broker (AWS Kinesis or MSK/Kafka) to consumers.

2. **Scalability at the required scale:** AWS Kinesis can ingest millions of records per second. 100k sensors at 5-second intervals (~20k events/sec baseline, ~200k events/sec peak) is comfortably within capacity without exotic infrastructure.

3. **Elastic by design:** Producers (sensors) and consumers (processing services) are fully decoupled. During 10x traffic spikes, only the consumer tier needs to scale — the broker absorbs the burst. AWS Lambda consumers or auto-scaled ECS tasks handle this natively.

4. **Zero data loss guarantee:** Kinesis retains data for 24h-365 days. Kafka provides replicated commit logs. If a consumer fails, it resumes from its last checkpoint. No data is lost.

5. **AWS-native support:** Kinesis Data Streams, EventBridge, SQS, and Lambda provide a fully managed event-driven stack, reducing operational burden.

### Suggested AWS Implementation

- **Ingestion:** AWS IoT Core (MQTT) -> Kinesis Data Streams
- **Processing:** Lambda or ECS consumers reading from Kinesis
- **Storage:** S3 (raw), DynamoDB or Timescale (processed)
- **Buffering:** SQS dead-letter queues for failed processing

### Risks to Mitigate

- **Ordering:** Kinesis preserves order per shard; use sensor ID as partition key.
- **Consumer lag monitoring:** CloudWatch alarms on iterator age to detect processing bottlenecks.
- **Schema evolution:** Use a schema registry to handle sensor payload changes over time.
