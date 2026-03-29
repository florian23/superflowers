# Quality Scenarios: IoT Sensor Platform (Event-Driven Architecture)

## Data Integrity Scenarios

### DI-1: Duplicate Detection During Normal Ingestion
| Aspect | Description |
|---|---|
| **Source** | Sensor device |
| **Stimulus** | Sensor sends the same reading twice (identical message ID) within 5 seconds |
| **Artifact** | Message ingestion pipeline |
| **Environment** | Normal operation, 50k concurrent connections |
| **Response** | System detects the duplicate via idempotency key and discards the second message |
| **Response Measure** | Zero duplicate records persisted; deduplication occurs within 10ms |

### DI-2: Data Integrity Under Broker Failover
| Aspect | Description |
|---|---|
| **Source** | Event broker cluster |
| **Stimulus** | Primary broker node fails mid-batch while processing 1,000 sensor events |
| **Artifact** | Event broker, persistence layer |
| **Environment** | Broker failover in progress |
| **Response** | Uncommitted events are redelivered by producers; consumers apply exactly-once processing via transactional outbox |
| **Response Measure** | 100% of events persisted exactly once; zero data loss; zero duplicates after recovery |

### DI-3: End-to-End Data Consistency Verification
| Aspect | Description |
|---|---|
| **Source** | Monitoring system (scheduled fitness function) |
| **Stimulus** | Nightly reconciliation job compares ingested event count against persisted record count |
| **Artifact** | Ingestion pipeline, time-series database |
| **Environment** | Normal operation after 24h of production traffic |
| **Response** | Reconciliation report generated; discrepancies flagged as critical alerts |
| **Response Measure** | Ingested count matches persisted count with 0% deviation; report completes within 15 minutes |

### DI-4: Schema Validation on Ingestion
| Aspect | Description |
|---|---|
| **Source** | Sensor device with outdated firmware |
| **Stimulus** | Sensor sends a reading with an invalid or missing field |
| **Artifact** | Message validation layer |
| **Environment** | Normal operation |
| **Response** | Invalid message routed to dead-letter queue; valid messages unaffected; alert raised |
| **Response Measure** | 100% of invalid messages caught; zero invalid records in primary store; dead-letter processing latency <100ms |

---

## Fault Tolerance Scenarios

### FT-1: Consumer Node Failure During Processing
| Aspect | Description |
|---|---|
| **Source** | Infrastructure failure |
| **Stimulus** | One of four consumer nodes crashes while processing a batch of events |
| **Artifact** | Event consumer cluster |
| **Environment** | Normal load, 60k concurrent connections |
| **Response** | Unacknowledged events on the failed consumer are rebalanced to surviving consumers; processing resumes |
| **Response Measure** | Zero data loss; rebalance completes within 30 seconds; no duplicate processing due to offset management |

### FT-2: Database Write Failure
| Aspect | Description |
|---|---|
| **Source** | Time-series database |
| **Stimulus** | Primary database node becomes unreachable for 2 minutes |
| **Artifact** | Persistence layer, event buffer |
| **Environment** | Normal operation under load |
| **Response** | Events buffered in the broker; write retries with exponential backoff; failover to replica if available |
| **Response Measure** | Zero events lost; all buffered events persisted within 5 minutes of database recovery; ingestion latency degrades gracefully (< 500ms p95 during outage) |

### FT-3: Full Broker Cluster Outage
| Aspect | Description |
|---|---|
| **Source** | Network partition / infrastructure failure |
| **Stimulus** | All broker nodes become unavailable for 60 seconds |
| **Artifact** | Sensor gateway, local buffer |
| **Environment** | Peak load, 100k concurrent connections |
| **Response** | Sensor gateways buffer events locally on disk; upon broker recovery, buffered events are forwarded in order |
| **Response Measure** | Zero data loss; all buffered events delivered within 10 minutes of recovery; event ordering preserved per sensor |

### FT-4: Cascading Failure Prevention
| Aspect | Description |
|---|---|
| **Source** | Downstream analytics service |
| **Stimulus** | Analytics service becomes unresponsive, causing backpressure |
| **Artifact** | Event processing pipeline |
| **Environment** | Normal operation |
| **Response** | Circuit breaker opens for analytics service; core ingestion and persistence pipeline continues unaffected |
| **Response Measure** | Core pipeline throughput unaffected (< 5% degradation); circuit breaker triggers within 5 seconds of detecting failure; no data loss on primary path |

---

## Scalability Scenarios

### SC-1: Sustained High Connection Count
| Aspect | Description |
|---|---|
| **Source** | 100,000 sensor devices |
| **Stimulus** | All sensors connect simultaneously and send readings at 1 msg/sec |
| **Artifact** | Ingestion gateway, event broker |
| **Environment** | Normal operation |
| **Response** | System accepts and processes all connections without rejections |
| **Response Measure** | 100k concurrent connections maintained; ingestion latency < 50ms p95; zero connection drops over 1 hour |

### SC-2: Traffic Spike Elasticity
| Aspect | Description |
|---|---|
| **Source** | Environmental event (e.g., storm triggers mass sensor activity) |
| **Stimulus** | Traffic increases 10x from baseline within 60 seconds |
| **Artifact** | Auto-scaling group, event consumers |
| **Environment** | Normal baseline load |
| **Response** | Additional consumer instances and gateway nodes provisioned automatically |
| **Response Measure** | Scale-out completed within 30 seconds; no data loss during scaling; latency < 200ms p95 during spike |

---

## Performance Scenarios

### PF-1: Ingestion Latency Under Load
| Aspect | Description |
|---|---|
| **Source** | Sensor devices |
| **Stimulus** | 80,000 sensors sending readings concurrently at steady state |
| **Artifact** | End-to-end ingestion pipeline |
| **Environment** | Normal operation |
| **Response** | Events flow from gateway through broker to persistence without queuing delays |
| **Response Measure** | End-to-end ingestion latency < 50ms p95; < 20ms p50 |
