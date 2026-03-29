# Quality Scenarios

Generated from architecture.md quality goals using ATAM.

## Last Updated: 2026-03-29

## Scenario Summary

| ID | Characteristic | Scenario | Test Type | Priority |
|----|---------------|----------|-----------|----------|
| QS-001 | Performance | API response under normal load | load-test | Critical |
| QS-002 | Performance | API response under peak load | load-test | Critical |
| QS-003 | Performance | API response with audit logging enabled | load-test | Critical |
| QS-004 | Security | Audit log completeness under normal throughput | integration-test | Critical |
| QS-005 | Security | Audit log completeness under peak throughput | integration-test | Critical |
| QS-006 | Security | Audit log payload integrity | integration-test | Critical |
| QS-007 | Data Consistency | Read-after-write consistency under normal load | integration-test | Critical |
| QS-008 | Data Consistency | Read-after-write consistency under peak load | load-test | Critical |
| QS-009 | Data Consistency | Consistency with audit log write contention | integration-test | Critical |
| QS-010 | Availability | Health check under normal conditions | integration-test | Important |
| QS-011 | Availability | Service recovery after partial failure | chaos-test | Important |
| QS-012 | Observability | Metrics dashboard reflects real-time state | integration-test | Important |

## Test Type Distribution

| Test Type | Count | Scenarios |
|-----------|-------|-----------|
| unit-test | 0 | — |
| integration-test | 7 | QS-004, QS-005, QS-006, QS-007, QS-009, QS-010, QS-012 |
| load-test | 4 | QS-001, QS-002, QS-003, QS-008 |
| chaos-test | 1 | QS-011 |
| fitness-function | 0 | — |
| manual-review | 0 | — |

## Scenarios

### Performance

#### QS-001: API Response Time Under Normal Load
- **Characteristic:** Performance
- **Source:** External API consumer (trading client)
- **Stimulus:** 100 concurrent users send API requests across all endpoints
- **Environment:** Normal load, all services healthy, audit logging enabled
- **Artifact:** All API endpoints (order placement, portfolio query, market data)
- **Response:** Each request is processed, audit-logged, and returns within latency target
- **Response Measure:** p95 response time < 50ms across all endpoints
- **Test Type:** load-test

#### QS-002: API Response Time Under Peak Load
- **Characteristic:** Performance
- **Source:** External API consumers during market open/close
- **Stimulus:** 10x normal traffic spike — 1000 concurrent users across all endpoints
- **Environment:** Peak load, all services healthy, audit logging enabled
- **Artifact:** All API endpoints
- **Response:** System handles load spike without breaching latency target
- **Response Measure:** p95 response time < 50ms; p99 response time < 100ms; zero dropped requests
- **Test Type:** load-test

#### QS-003: API Response Time With Full Audit Pipeline Active
- **Characteristic:** Performance
- **Source:** External API consumer
- **Stimulus:** 500 concurrent users send requests while the audit subsystem is under write-heavy load (backlog of 10,000 unwritten audit entries)
- **Environment:** Degraded mode — audit subsystem backpressure active
- **Artifact:** API endpoints and audit logging pipeline
- **Response:** API responses are not blocked by audit log persistence; audit writes happen asynchronously without losing entries
- **Response Measure:** p95 response time < 50ms; zero audit log entries lost
- **Test Type:** load-test

### Security (Audit)

#### QS-004: Audit Log Completeness Under Normal Throughput
- **Characteristic:** Security
- **Source:** Regulatory compliance check (automated)
- **Stimulus:** 1,000 API calls over 60 seconds across all endpoints
- **Environment:** Normal load, all services healthy
- **Artifact:** Audit log storage (database/log sink)
- **Response:** Every API call has a corresponding audit entry with user ID, timestamp, request payload, and response payload
- **Response Measure:** 100% of API calls have matching audit entries; zero missing fields; timestamp drift < 1ms from actual request time
- **Test Type:** integration-test

#### QS-005: Audit Log Completeness Under Peak Throughput
- **Characteristic:** Security
- **Source:** Regulatory compliance check (automated)
- **Stimulus:** 10,000 API calls over 60 seconds (peak market conditions)
- **Environment:** Peak load, audit subsystem near capacity
- **Artifact:** Audit log storage
- **Response:** No audit entries are dropped even under backpressure; system may queue but must not lose
- **Response Measure:** 100% of API calls have matching audit entries; audit lag < 5 seconds from request to persisted entry
- **Test Type:** integration-test

#### QS-006: Audit Log Payload Integrity
- **Characteristic:** Security
- **Source:** Security auditor (manual or automated)
- **Stimulus:** API calls with varying payload sizes (1KB to 1MB) including edge cases (unicode, nested JSON, binary-encoded fields)
- **Environment:** Normal load
- **Artifact:** Audit log storage
- **Response:** Stored payload is byte-identical to the original request and response; no truncation, no encoding corruption
- **Response Measure:** SHA-256 hash of stored payload matches hash of original for 100% of entries
- **Test Type:** integration-test

### Data Consistency

#### QS-007: Read-After-Write Consistency Under Normal Load
- **Characteristic:** Data Consistency
- **Source:** Trading client
- **Stimulus:** Client writes an order, immediately reads the order back
- **Environment:** Normal load, single service-based domain
- **Artifact:** Order service, database
- **Response:** Read returns the exact data that was written — no stale reads
- **Response Measure:** 100% of read-after-write operations return the latest write; zero stale reads across 10,000 operations
- **Test Type:** integration-test

#### QS-008: Read-After-Write Consistency Under Peak Load
- **Characteristic:** Data Consistency
- **Source:** Multiple trading clients
- **Stimulus:** 500 concurrent write-then-read sequences against the same data partition
- **Environment:** Peak load, connection pool under pressure
- **Artifact:** Order service, database, connection pool
- **Response:** Strong consistency holds even with concurrent writes and reads to the same partition
- **Response Measure:** Zero stale reads; zero lost writes; all 500 sequences return consistent data
- **Test Type:** load-test

#### QS-009: Consistency With Audit Log Write Contention
- **Characteristic:** Data Consistency
- **Source:** Trading client
- **Stimulus:** Client places an order; the order write and the audit log write compete for database/IO resources
- **Environment:** High audit write volume, shared infrastructure
- **Artifact:** Order service, audit service, shared database or IO subsystem
- **Response:** Order data is consistently readable regardless of audit log write pressure; neither write blocks or corrupts the other
- **Response Measure:** Zero stale reads; zero data corruption; order write latency does not increase by more than 10% due to audit contention
- **Test Type:** integration-test

### Availability

#### QS-010: Health Check Under Normal Conditions
- **Characteristic:** Availability
- **Source:** Load balancer / monitoring system
- **Stimulus:** Health check request every 30 seconds
- **Environment:** Normal load, all services healthy
- **Artifact:** Health check endpoint on each service
- **Response:** Returns HTTP 200 with service status within timeout
- **Response Measure:** 100% of health checks return 200 within 500ms over a 24-hour period (supports 99.9% SLA)
- **Test Type:** integration-test

#### QS-011: Service Recovery After Partial Failure
- **Characteristic:** Availability
- **Source:** Infrastructure failure
- **Stimulus:** One of three service instances is killed mid-request
- **Environment:** Degraded mode — 1 of 3 instances down
- **Artifact:** Service-based deployment, load balancer
- **Response:** Remaining instances absorb traffic; failed requests are retried; no data loss
- **Response Measure:** System returns to full availability within 30 seconds; zero permanent request failures; audit log completeness maintained
- **Test Type:** chaos-test

### Observability

#### QS-012: Real-Time Metrics Dashboard Accuracy
- **Characteristic:** Observability
- **Source:** Operations team
- **Stimulus:** API traffic generates metrics (request count, latency, error rate)
- **Environment:** Normal load
- **Artifact:** Metrics pipeline, dashboard
- **Response:** Dashboard reflects actual system state within acceptable lag
- **Response Measure:** Dashboard metrics lag < 10 seconds from actual events; zero dropped metric data points over 1-hour window
- **Test Type:** integration-test

## Tradeoffs and Sensitivity Points

### Tradeoff: Performance vs. Security (Audit Completeness)

- **Tension:** Performance (< 50ms p95) vs. Security (full audit trail for every call)
- **Scenarios affected:** QS-001, QS-002, QS-003 vs. QS-004, QS-005, QS-006
- **Mechanism:** Every API call must produce an audit entry containing the full request payload, response payload, user ID, and timestamp. This audit write adds latency to the request path. Synchronous audit writes guarantee completeness but add 10-30ms to each request — consuming 20-60% of the 50ms budget. Asynchronous audit writes protect latency but introduce a window where entries can be lost during crashes or backpressure.
- **Decision needed:** The team must choose an audit write strategy:
  1. **Synchronous audit writes** — guarantees 100% completeness but makes the 50ms target extremely difficult under peak load. Leaves only 20-40ms for actual business logic + DB query.
  2. **Asynchronous audit writes with durable queue** — a durable message queue (e.g., Kafka) receives audit entries in-process, adding only 1-3ms latency. Entries are persisted asynchronously. This protects latency but requires infrastructure for exactly-once delivery and introduces audit lag (QS-005 allows up to 5 seconds).
  3. **Write-ahead log pattern** — audit entry is appended to a local WAL before the response is sent (1-2ms), then flushed to the audit store asynchronously. Crash recovery replays the WAL. Complexity is moderate; latency impact is minimal.
- **Recommendation:** Option 2 or 3. The 50ms budget is too tight for synchronous audit writes at scale. The team should accept audit lag (bounded, e.g., < 5 seconds) in exchange for meeting the latency target. QS-003 explicitly tests this scenario.

### Tradeoff: Performance vs. Data Consistency (Strong Consistency)

- **Tension:** Performance (< 50ms p95) vs. Data Consistency (reads always return latest write)
- **Scenarios affected:** QS-001, QS-002 vs. QS-007, QS-008
- **Mechanism:** Strong consistency requires that every read hits the primary database (or uses synchronous replication). This eliminates the option of read replicas for horizontal read scaling and prevents response caching. Under peak load (QS-002, QS-008), all read and write traffic funnels through a single primary, increasing connection pool contention and query latency. Caching — the most common tool for achieving sub-50ms responses — is effectively forbidden because cached data may be stale.
- **Decision needed:** The team must decide how to achieve < 50ms reads without caching or read replicas:
  1. **Single-primary with aggressive indexing and connection pooling** — keeps strong consistency but requires careful DB tuning, possibly in-memory storage (Redis as primary store, not cache), and limits horizontal scaling.
  2. **Synchronous replication with read-from-replica** — allows read scaling while maintaining consistency, but synchronous replication adds write latency (5-15ms), eating into the 50ms budget for write-then-read operations.
  3. **Scope the consistency guarantee** — strong consistency only for the order/transaction path; eventual consistency acceptable for non-critical reads (portfolio summary, historical data). This relaxes QS-007/QS-008 for specific endpoints.
- **Recommendation:** Option 3 is pragmatic for a service-based architecture. The team should define which data domains require strong consistency (trading orders, account balances) and which can tolerate bounded staleness (dashboards, reports). This avoids a global performance penalty.

### Tradeoff: Security (Audit) vs. Data Consistency (Write Contention)

- **Tension:** Security (audit log write for every call) vs. Data Consistency (order writes must not be delayed or corrupted)
- **Scenarios affected:** QS-004, QS-005 vs. QS-007, QS-009
- **Mechanism:** If the audit log shares the same database or IO subsystem as the transactional data, audit writes compete for disk IO, connection pool slots, and transaction log space. Under peak load, 10,000 audit writes per minute compete with order writes, potentially increasing transaction commit latency and risking lock contention. QS-009 tests this explicitly.
- **Decision needed:**
  1. **Separate storage** — audit logs go to a dedicated store (separate database, append-only log, object storage). Eliminates contention entirely but adds operational complexity.
  2. **Shared storage with write prioritization** — transaction writes get priority; audit writes are queued. Risk: under sustained load, audit queue grows unboundedly.
  3. **Same-transaction audit write** — audit entry is written in the same DB transaction as the order. Guarantees atomicity (order and audit entry are always consistent) but increases transaction duration by 30-50%.
- **Recommendation:** Option 1. In a service-based architecture, the audit service should own its own data store. This eliminates IO contention with the order service and aligns with the service-based style's principle of domain-scoped data ownership.

### Sensitivity Point: Audit Write Latency

- **Parameter:** Audit write mode (synchronous vs. asynchronous) and queue depth limit
- **Affects:** QS-001, QS-002, QS-003 (each ms added to audit write directly reduces the latency budget for business logic)
- **Current setting:** Not yet decided — this is the critical architectural decision
- **Impact curve:** Synchronous write adds 10-30ms (leaves 20-40ms for business logic). Async with durable queue adds 1-3ms. Local WAL adds 1-2ms. The difference between sync and async audit writes determines whether the 50ms target is achievable at all.

### Sensitivity Point: Connection Pool Size

- **Parameter:** Database connection pool size per service instance
- **Affects:** QS-002 (peak load latency), QS-008 (consistency under load), QS-009 (audit contention)
- **Current setting:** Not yet decided
- **Impact curve:** Too small: requests queue waiting for connections, p95 latency spikes. Too large: database overwhelmed with concurrent queries, query latency increases for all. Sweet spot depends on DB capacity and expected concurrent users — requires load testing (QS-002) to calibrate.

### Sensitivity Point: Consistency Scope

- **Parameter:** Which data domains require strong consistency vs. bounded staleness
- **Affects:** QS-007 (read-after-write guarantee), QS-001 (latency budget)
- **Current setting:** architecture.md states "strong consistency across all reads" — no scoping
- **Impact curve:** Global strong consistency means no caching, no read replicas, all reads hit primary. Scoping consistency to transaction-critical paths (orders, balances) frees non-critical paths for caching, dramatically improving p95 latency for those endpoints.
