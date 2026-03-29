# Quality Scenarios

Generated from architecture.md quality goals using ATAM.

## Last Updated: 2026-03-29

## Scenario Summary

| ID | Characteristic | Scenario | Test Type | Priority |
|----|---------------|----------|-----------|----------|
| QS-001 | Scalability | 100k concurrent sensor connections under normal load | load-test | Critical |
| QS-002 | Scalability | Ramp from 10k to 100k connections within 60s | load-test | Critical |
| QS-003 | Scalability | 100k connections with 1 broker node degraded | chaos-test | Critical |
| QS-004 | Fault Tolerance | Kinesis shard failure during ingestion | chaos-test | Critical |
| QS-005 | Fault Tolerance | Lambda consumer crash mid-batch | chaos-test | Critical |
| QS-006 | Fault Tolerance | Network partition between producer and Kinesis | chaos-test | Critical |
| QS-007 | Data Integrity | Duplicate sensor readings from retry storms | integration-test | Critical |
| QS-008 | Data Integrity | Data reconciliation after node recovery | integration-test | Critical |
| QS-009 | Data Integrity | Concurrent writes for same sensor ID | integration-test | Critical |
| QS-010 | Elasticity | 10x traffic spike from sensor burst | load-test | Important |
| QS-011 | Elasticity | Scale-down after spike without data loss | load-test | Important |
| QS-012 | Performance | Ingestion latency under sustained 100k connections | load-test | Important |
| QS-013 | Deployability | Rolling deploy during peak ingestion | integration-test | Important |
| QS-014 | Observability | Distributed trace covers full event path | integration-test | Important |

## Test Type Distribution

| Test Type | Count | Scenarios |
|-----------|-------|-----------|
| unit-test | 0 | — |
| integration-test | 5 | QS-007, QS-008, QS-009, QS-013, QS-014 |
| load-test | 5 | QS-001, QS-002, QS-010, QS-011, QS-012 |
| chaos-test | 4 | QS-003, QS-004, QS-005, QS-006 |
| fitness-function | 0 | — (style fitness functions already cover structural invariants) |
| manual-review | 0 | — |

## Scenarios

### Scalability

#### QS-001: Sustained 100k Concurrent Sensor Connections
- **Characteristic:** Scalability
- **Source:** 100k IoT sensors sending data at 5s intervals
- **Stimulus:** All 100k sensors maintain persistent connections and send readings simultaneously
- **Environment:** Normal operation, all nodes healthy, steady-state traffic
- **Artifact:** Kinesis ingestion endpoint / connection gateway
- **Response:** System accepts and processes all incoming connections without dropping any
- **Response Measure:** 100k concurrent connections sustained for 30 minutes with 0 dropped connections and all readings acknowledged
- **Test Type:** load-test

#### QS-002: Ramp-Up to Full Capacity
- **Characteristic:** Scalability
- **Source:** Sensors coming online in waves (deployment rollout, morning activation)
- **Stimulus:** Connection count ramps from 10k to 100k within 60 seconds
- **Environment:** System running at baseline 10k connections, rapid ramp
- **Artifact:** Connection gateway, Kinesis shard auto-scaling
- **Response:** System scales to accommodate all connections without errors during ramp
- **Response Measure:** Zero connection rejections during ramp, all 100k connected within 90s, no data loss during scaling
- **Test Type:** load-test

#### QS-003: Full Load with Degraded Node
- **Characteristic:** Scalability
- **Source:** 100k sensors sending data while infrastructure is partially degraded
- **Stimulus:** 1 of N broker/gateway nodes goes down during peak load
- **Environment:** Peak load (100k connections), one node failure
- **Artifact:** Connection gateway cluster, load balancer
- **Response:** Remaining nodes absorb the traffic, connections re-establish automatically
- **Response Measure:** All 100k connections restored within 30s, zero data loss during failover
- **Test Type:** chaos-test

### Fault Tolerance

#### QS-004: Kinesis Shard Failure During Ingestion
- **Characteristic:** Fault Tolerance
- **Source:** AWS infrastructure failure
- **Stimulus:** A Kinesis shard becomes unavailable during active ingestion
- **Environment:** Normal load (50k active sensors), mid-stream ingestion
- **Artifact:** Kinesis data stream, producer retry logic
- **Response:** Producers buffer and retry, data is written to healthy shards or re-routed
- **Response Measure:** Zero data loss — every reading sent during the failure window is eventually persisted. Recovery within 60s.
- **Test Type:** chaos-test

#### QS-005: Lambda Consumer Crash Mid-Batch
- **Characteristic:** Fault Tolerance
- **Source:** Lambda runtime error (OOM, timeout, unhandled exception)
- **Stimulus:** Consumer Lambda crashes after reading 500 records from Kinesis but before committing the checkpoint
- **Environment:** Normal operation, batch processing active
- **Artifact:** Lambda consumer function, Kinesis checkpoint
- **Response:** Lambda is re-invoked with the same batch (Kinesis redelivers from last checkpoint), consumer processes records idempotently
- **Response Measure:** Zero data loss. No duplicate entries in the persistence layer despite reprocessing. Consumer checkpoint advances after successful completion.
- **Test Type:** chaos-test

#### QS-006: Network Partition Between Producer and Kinesis
- **Characteristic:** Fault Tolerance
- **Source:** Network infrastructure failure
- **Stimulus:** Network partition isolates the sensor gateway from Kinesis for 120 seconds
- **Environment:** Normal load, sudden network split
- **Artifact:** Sensor gateway, local buffer/queue, Kinesis producer
- **Response:** Gateway buffers readings locally, drains buffer after partition heals
- **Response Measure:** Zero data loss. All readings buffered during the 120s partition are persisted within 60s of partition recovery. No duplicate readings in final store.
- **Test Type:** chaos-test

### Data Integrity

#### QS-007: Duplicate Sensor Readings from Retry Storms
- **Characteristic:** Data Integrity
- **Source:** Producer retry logic after timeout (Kinesis acknowledged but response was lost)
- **Stimulus:** 1000 sensor readings are sent twice due to producer retries
- **Environment:** Degraded network (high latency causing timeouts), normal load
- **Artifact:** Consumer deduplication logic, persistence layer
- **Response:** Consumer detects and discards duplicate readings using idempotency keys (sensor_id + timestamp)
- **Response Measure:** Exactly 1000 unique readings persisted, zero duplicates in the data store
- **Test Type:** integration-test

#### QS-008: Data Reconciliation After Node Recovery
- **Characteristic:** Data Integrity
- **Source:** Recovery process after a node failure
- **Stimulus:** A consumer node was down for 5 minutes, comes back online and re-processes the backlog
- **Environment:** Post-failure recovery, backlog of 60k unprocessed readings
- **Artifact:** Kinesis consumer, persistence layer, reconciliation job
- **Response:** All backlogged readings are processed, final data store matches the expected count exactly
- **Response Measure:** Reconciliation job confirms: readings_sent == readings_persisted, zero missing, zero duplicates. Backlog fully drained within 10 minutes.
- **Test Type:** integration-test

#### QS-009: Concurrent Writes for Same Sensor ID
- **Characteristic:** Data Integrity
- **Source:** Multiple consumer instances processing events for the same sensor
- **Stimulus:** Two Lambda instances receive readings for sensor X at timestamps T1 and T2 and write concurrently
- **Environment:** Normal operation, parallel consumer processing
- **Artifact:** Persistence layer (DynamoDB / RDS), write conflict resolution
- **Response:** Both readings are persisted correctly without overwriting each other
- **Response Measure:** Both T1 and T2 readings exist in the data store. No lost updates. Query for sensor X returns both readings in correct chronological order.
- **Test Type:** integration-test

### Elasticity

#### QS-010: 10x Traffic Spike from Sensor Burst
- **Characteristic:** Elasticity
- **Source:** Environmental event causes all sensors to report simultaneously (e.g., threshold alert)
- **Stimulus:** Traffic spikes from 10k to 100k readings/second within seconds
- **Environment:** Baseline load, sudden 10x burst
- **Artifact:** Kinesis stream, Lambda concurrency, auto-scaling policies
- **Response:** System auto-scales to handle the spike within 30 seconds
- **Response Measure:** All readings during the spike are ingested. Auto-scaling completes within 30s. No readings dropped. Ingestion latency stays below 200ms p95 during spike.
- **Test Type:** load-test

#### QS-011: Scale-Down After Spike Without Data Loss
- **Characteristic:** Elasticity
- **Source:** Traffic returns to baseline after a spike
- **Stimulus:** Traffic drops from 100k to 10k readings/second
- **Environment:** Post-spike, system is scaled up
- **Artifact:** Lambda concurrency, Kinesis shard count, auto-scaling policies
- **Response:** System scales down gracefully, in-flight messages are fully processed before resources are released
- **Response Measure:** Zero data loss during scale-down. All in-flight batches complete before Lambda instances are terminated. Resource utilization returns to baseline within 5 minutes.
- **Test Type:** load-test

### Performance

#### QS-012: Ingestion Latency Under Sustained Load
- **Characteristic:** Performance
- **Source:** 100k sensors sending readings at 5s intervals
- **Stimulus:** Sustained ingestion of 20k readings/second for 1 hour
- **Environment:** Normal operation, all systems healthy, sustained peak
- **Artifact:** Ingestion endpoint, Kinesis producer, end-to-end pipeline
- **Response:** Readings are ingested and acknowledged within the latency target
- **Response Measure:** p95 ingestion latency < 50ms measured at the gateway. p99 < 100ms. Zero timeouts over the 1-hour window.
- **Test Type:** load-test

### Deployability

#### QS-013: Rolling Deploy During Peak Ingestion
- **Characteristic:** Deployability
- **Source:** DevOps team deploying a new version
- **Stimulus:** Rolling deployment of new consumer Lambda version while system is processing 100k readings/second
- **Environment:** Peak load, active deployment
- **Artifact:** Lambda deployment, Kinesis consumer group, deployment pipeline
- **Response:** Old and new versions coexist during rollout, no readings are lost during the transition
- **Response Measure:** Zero downtime. Zero data loss during deployment window. Both old and new versions process events correctly. Deployment completes within 10 minutes.
- **Test Type:** integration-test

### Observability

#### QS-014: Distributed Trace Covers Full Event Path
- **Characteristic:** Observability
- **Source:** Operations team investigating a sensor reading
- **Stimulus:** A single sensor reading is traced from gateway ingestion through Kinesis to consumer to persistence
- **Environment:** Normal operation
- **Artifact:** Tracing infrastructure (X-Ray / OpenTelemetry), all pipeline components
- **Response:** A single trace ID follows the reading across all components, with timing for each hop
- **Response Measure:** Trace contains spans for: gateway receipt, Kinesis put, Lambda invocation, persistence write. No gaps in the trace chain. Latency per hop is visible.
- **Test Type:** integration-test

## Tradeoffs and Sensitivity Points

### Tradeoff: Consumer Idempotency vs. Ingestion Latency
- **Tension:** Data Integrity (QS-007, QS-009) vs Performance (QS-012)
- **Scenarios affected:** QS-007, QS-009, QS-012
- **Decision needed:** Deduplication requires a lookup (DynamoDB conditional write or read-before-write) that adds latency per record. The team must decide between synchronous dedup (higher latency, guaranteed no duplicates) vs. async dedup via reconciliation (lower latency, eventual consistency with short duplicate window).

### Tradeoff: Local Buffering vs. Memory Pressure
- **Tension:** Fault Tolerance (QS-006) vs Scalability (QS-001)
- **Scenarios affected:** QS-006, QS-001, QS-003
- **Decision needed:** Buffering readings locally during network partitions (QS-006) consumes gateway memory. At 100k connections (QS-001), the buffer size could exceed available memory during extended outages. The team must decide on buffer limits and overflow strategy (drop oldest? back-pressure to sensors? disk spill?).

### Tradeoff: Comprehensive Tracing vs. Throughput
- **Tension:** Observability (QS-014) vs Performance (QS-012)
- **Scenarios affected:** QS-014, QS-012
- **Decision needed:** Full distributed tracing for every reading adds overhead (trace context propagation, span creation, X-Ray API calls). At 20k readings/second, this is significant. The team should decide on a sampling rate (e.g., 1% tracing for normal operation, 100% for debug) that satisfies observability without impacting the 50ms p95 latency target.

### Sensitivity Point: Kinesis Shard Count
- **Parameter:** Number of Kinesis shards
- **Affects:** QS-001 (throughput capacity), QS-004 (blast radius of shard failure), QS-010 (spike absorption)
- **Current setting:** Not specified in architecture.md
- **Note:** Each shard handles 1MB/s or 1000 records/s. At 20k records/s, minimum 20 shards needed. More shards = better parallelism but higher cost and wider blast radius per shard failure. This parameter directly affects scalability, fault tolerance, and elasticity scenarios.

### Sensitivity Point: Lambda Batch Size and Timeout
- **Parameter:** Kinesis-to-Lambda batch size and function timeout
- **Affects:** QS-005 (larger batches = more reprocessing on crash), QS-012 (batch size affects latency), QS-008 (backlog drain speed)
- **Current setting:** Not specified in architecture.md
- **Note:** Larger batches improve throughput but increase the blast radius of a Lambda crash (QS-005) and add latency (QS-012). Smaller batches reduce risk but increase Lambda invocation costs and may not drain backlogs fast enough (QS-008).
