# Architecture Style Selection — IoT Sensor Data Processing Service

> "I'll now help select the best architecture style for your project based on the driving characteristics we identified."

## Step 1: Driving Characteristics

From `architecture.md`:

| # | Characteristic | Concrete Goal |
|---|---|---|
| 1 | **Scalability** | 100k concurrent sensor connections |
| 2 | **Elasticity** | Handle 10x traffic spikes within 30s |
| 3 | **Fault Tolerance** | Zero data loss during node failures |

## Step 2: Architecture Style Fit Analysis

Top 3 Driving Characteristics: Scalability, Elasticity, Fault Tolerance

| Rank | Style | Scalability | Elasticity | Fault Tolerance | Fit Score | Cost |
|------|-------|------------|------------|-----------------|-----------|------|
| 1 | **Event-Driven** | ★★★★★ | ★★★★★ | ★★★★★ | **15/15** | $$$ |
| 2 | **Microservices** | ★★★★★ | ★★★★★ | ★★★★★ | **15/15** | $$$$$ |
| 3 | Space-Based | ★★★★★ | ★★★★★ | ★★★ | 13/15 | $$$$ |
| 4 | Service-Based | ★★★★ | ★★★ | ★★★★ | 11/15 | $$ |
| 5 | Service-Oriented | ★★★ | ★★★ | ★★ | 8/15 | $$$$ |
| 6 | Layered | ★ | ★ | ★ | 3/15 | $ |
| 6 | Modular Monolith | ★ | ★ | ★ | 3/15 | $ |
| 6 | Microkernel | ★ | ★ | ★ | 3/15 | $ |

## Step 3: Tradeoff Analysis

### Event-Driven (15/15, $$$) — Recommended

**Strengths:**
- Perfect score across all 3 driving characteristics
- Natural fit for IoT: sensors emit events, system reacts asynchronously
- Message brokers (Kafka, AWS Kinesis) provide built-in fault tolerance via message persistence and replay
- Excellent elasticity through consumer group scaling

**Weaknesses:**
- Testability: 2/5 — async flows are harder to test end-to-end
- Simplicity: 2/5 — event flows can be complex to debug and trace
- Abstraction: 4/5 — moderate, manageable

**Cost:** $$$ — moderate infrastructure cost (message broker, processing nodes)

### Microservices (15/15, $$$$$)

**Strengths:**
- Also perfect 15/15 fit score
- Excellent deployability (5/5) and maintainability (5/5) as bonus
- Domain partitioning aligns well with separating ingestion, processing, storage

**Weaknesses:**
- Cost: $$$$$ — significantly more expensive than Event-Driven
- Operational overhead: service mesh, API gateways, distributed tracing
- Request/response pattern is less natural for high-throughput streaming than event-driven

**Cost:** $$$$$ — highest cost category

### Space-Based (13/15, $$$$)

**Strengths:**
- Excellent scalability and elasticity (both 5/5)
- In-memory data grids eliminate database bottleneck
- Processing units can scale independently

**Weaknesses:**
- Fault tolerance: 3/5 — in-memory data is vulnerable during failures
- Simplicity: 1/5 — most complex architecture to implement and operate
- Testability: 1/5 — very difficult to test locally
- Cost: $$$$ — expensive, and the extra cost doesn't buy better fault tolerance

## Step 4: Recommendation

**Event-Driven Architecture** is the clear winner:

- Same perfect fit score as Microservices (15/15) but at lower cost ($$$ vs $$$$$)
- IoT sensor data is inherently event-based — sensors produce events, the system consumes and processes them
- Message brokers provide exactly the fault tolerance model needed: persistent, replayable message streams
- Elasticity is achieved naturally by scaling consumer groups
- AWS ecosystem aligns perfectly: IoT Core → Kinesis/MSK → Lambda/ECS consumers

The $$$ → $$$$$ cost gap between Event-Driven and Microservices is significant and not justified when both score identically on the driving characteristics.

## Tradeoffs Accepted

- **Testability (2/5):** Mitigated by investing in integration test infrastructure with embedded message brokers (e.g., Testcontainers with Kafka)
- **Simplicity (2/5):** Mitigated by strong observability (distributed tracing already identified as important characteristic) and clear event flow documentation
