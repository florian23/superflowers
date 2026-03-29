# Quality Scenarios — Performance vs. Audit-Logging Tradeoff

## Context

Financial services API requiring both sub-50ms p95 latency and complete audit logging (user, timestamp, payload, response) for regulatory compliance. These two characteristics create an inherent tension: audit logging adds I/O overhead to every request path.

---

## QS-1: Baseline Latency Without Audit Logging

| Field | Value |
|---|---|
| **ID** | QS-PERF-001 |
| **Characteristic** | Performance |
| **Source** | Trading client |
| **Stimulus** | 1000 concurrent order placement requests |
| **Environment** | Normal production load, audit logging disabled |
| **Response** | Orders processed and confirmed |
| **Response Measure** | p95 response time < 30ms |

**Purpose:** Establishes the latency baseline without audit overhead. The 30ms target leaves 20ms headroom for audit logging to stay within the 50ms budget.

---

## QS-2: Latency With Synchronous Audit Logging

| Field | Value |
|---|---|
| **ID** | QS-PERF-002 |
| **Characteristic** | Performance vs. Security |
| **Source** | Trading client |
| **Stimulus** | 1000 concurrent order placement requests |
| **Environment** | Normal production load, synchronous audit logging enabled (write-through to audit store) |
| **Response** | Orders processed, audit records persisted before response |
| **Response Measure** | p95 response time < 50ms |

**Purpose:** Tests whether synchronous audit logging — the simplest approach guaranteeing no audit gaps — fits within the latency budget. If this scenario fails, synchronous logging is not viable and an architectural compromise is required.

---

## QS-3: Latency With Asynchronous Audit Logging

| Field | Value |
|---|---|
| **ID** | QS-PERF-003 |
| **Characteristic** | Performance |
| **Source** | Trading client |
| **Stimulus** | 1000 concurrent order placement requests |
| **Environment** | Normal production load, asynchronous audit logging enabled (fire-and-forget to message queue) |
| **Response** | Orders processed and confirmed |
| **Response Measure** | p95 response time < 50ms |

**Purpose:** Tests the latency-optimized alternative. If this passes where QS-2 fails, async logging preserves performance — but introduces the audit gap risk tested by QS-5.

---

## QS-4: Audit Completeness Under Normal Load

| Field | Value |
|---|---|
| **ID** | QS-SEC-001 |
| **Characteristic** | Security (Audit) |
| **Source** | Compliance auditor |
| **Stimulus** | Request audit report for the last 24 hours of API activity |
| **Environment** | Normal production load, synchronous audit logging |
| **Response** | Complete audit trail returned: every API call has user, timestamp, request payload, response payload |
| **Response Measure** | 100% of API calls have a matching audit record; zero gaps |

**Purpose:** Validates the regulatory requirement under the synchronous (safe) path. This scenario should always pass with synchronous logging.

---

## QS-5: Audit Completeness After Crash With Async Logging

| Field | Value |
|---|---|
| **ID** | QS-SEC-002 |
| **Characteristic** | Security (Audit) vs. Performance |
| **Source** | Compliance auditor |
| **Stimulus** | Service node crashes during peak trading; 500 requests were in-flight |
| **Environment** | Asynchronous audit logging via message queue; node killed with SIGKILL |
| **Response** | After recovery, audit report for crashed node's last 60 seconds is requested |
| **Response Measure** | 100% of API calls have a matching audit record; zero gaps |

**Purpose:** This is the critical tradeoff scenario. If async logging is chosen for performance (QS-3), this scenario tests whether audit completeness survives a crash. A failure here means the performance gain from async logging comes at the cost of regulatory compliance risk.

---

## QS-6: Latency Under Audit Store Degradation

| Field | Value |
|---|---|
| **ID** | QS-PERF-004 |
| **Characteristic** | Performance vs. Security |
| **Source** | Trading client |
| **Stimulus** | 1000 concurrent order placement requests |
| **Environment** | Audit store responding with 500ms latency (degraded); synchronous audit logging |
| **Response** | System behavior observed |
| **Response Measure** | Either: (a) p95 < 50ms by circuit-breaking audit writes, OR (b) p95 degrades to > 500ms but audit completeness is maintained |

**Purpose:** Forces an explicit architectural decision. When the audit store is slow, the system cannot satisfy both characteristics simultaneously. The measured outcome reveals which characteristic the architecture actually prioritizes under stress.

---

## QS-7: Latency With Dual-Write Audit (Optimistic Local + Async Replication)

| Field | Value |
|---|---|
| **ID** | QS-PERF-005 |
| **Characteristic** | Performance + Security (compromise) |
| **Source** | Trading client |
| **Stimulus** | 1000 concurrent order placement requests |
| **Environment** | Audit logged synchronously to local WAL (write-ahead log), then asynchronously replicated to central audit store |
| **Response** | Orders processed, local audit record persisted before response |
| **Response Measure** | p95 response time < 50ms AND 100% local audit records written |

**Purpose:** Tests a middle-ground architecture: local synchronous write (fast, crash-safe) with async replication (centralized access). Validates whether this compromise satisfies both constraints.

---

## Tradeoff Matrix

| Scenario | Performance Target Met? | Audit Completeness Met? | Tradeoff Visible? |
|---|---|---|---|
| QS-1 (no audit) | Yes (baseline) | N/A | No — baseline |
| QS-2 (sync audit) | At risk | Yes | Yes — latency cost of sync writes |
| QS-3 (async audit) | Yes | At risk | Yes — audit gap risk |
| QS-4 (audit check, sync) | N/A | Yes | No — happy path |
| QS-5 (crash + async) | N/A | At risk | Yes — crash exposes async gap |
| QS-6 (degraded audit store) | One must lose | One must lose | Yes — forced choice |
| QS-7 (local WAL + async) | Likely yes | Likely yes | Yes — compromise viability |
