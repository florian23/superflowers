# Architecture & Fitness Functions: Live-Betting Platform

## Last Updated: 2026-03-29

## Architecture Decision

**Selected Style:** Event-Driven Architecture with CQRS + Event Sourcing

**Driving Characteristics:** Responsiveness, Elasticity, Fault Tolerance

---

## Fitness Functions

### FF-1: Responsiveness — Real-Time Notification Latency

| Attribute | Value |
|-----------|-------|
| **Characteristic** | Responsiveness |
| **Metric** | End-to-end latency from odds change event to user notification delivery |
| **Threshold** | p99 < 100ms |
| **Failure Threshold** | p99 > 200ms |
| **Measurement** | Distributed tracing (OpenTelemetry) across event pipeline: OddsEngine -> Kafka -> NotificationService -> WebSocket -> Client |
| **Frequency** | Continuous (real-time monitoring) |
| **Automation** | Prometheus metrics + Grafana alert; load test in CI with Gatling simulating 100k concurrent WebSocket connections |
| **Owner** | Platform Team |

**Implementation:**

```yaml
# Prometheus alert rule
- alert: OddsNotificationLatencyHigh
  expr: histogram_quantile(0.99, rate(odds_notification_latency_seconds_bucket[5m])) > 0.1
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "p99 odds notification latency exceeds 100ms"
```

**CI/CD Gate:**
```
Gatling simulation: 100,000 concurrent WebSocket users
Pass criteria: p99 latency < 100ms for OddsUpdated events
Run: On every merge to main, nightly with full load profile
```

---

### FF-2: Elasticity — Auto-Scaling Under Traffic Spikes

| Attribute | Value |
|-----------|-------|
| **Characteristic** | Elasticity |
| **Metric** | Time to scale from baseline to 10x capacity; consumer lag during scaling |
| **Threshold** | Scale-out completes within 3 minutes; consumer lag < 10,000 messages during spike |
| **Failure Threshold** | Scale-out > 5 minutes OR consumer lag > 100,000 messages |
| **Measurement** | Kubernetes HPA metrics + Kafka consumer group lag (Burrow) |
| **Frequency** | Continuous monitoring + weekly chaos test |
| **Automation** | Kubernetes HPA with custom metrics (Kafka consumer lag); weekly automated spike test simulating 10x traffic |
| **Owner** | Infrastructure Team |

**Implementation:**

```yaml
# Kubernetes HPA for Bet Placement consumers
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: bet-placement-consumer-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: bet-placement-consumer
  minReplicas: 5
  maxReplicas: 50
  metrics:
    - type: External
      external:
        metric:
          name: kafka_consumer_group_lag
          selector:
            matchLabels:
              topic: bet-placement
        target:
          type: AverageValue
          averageValue: "1000"
```

**Chaos Test (weekly):**
```
1. Baseline: record current throughput and replica count
2. Inject: 10x traffic spike via load generator (Locust/k6)
3. Measure: time to reach target replica count
4. Assert: consumer lag never exceeds 10,000 messages
5. Recover: traffic returns to baseline, scale-in within 10 minutes
```

---

### FF-3: Fault Tolerance — Zero Message Loss Under Partial Outages

| Attribute | Value |
|-----------|-------|
| **Characteristic** | Fault Tolerance |
| **Metric** | Message loss rate during simulated broker/consumer failures |
| **Threshold** | 0 messages lost (zero tolerance) |
| **Failure Threshold** | Any message loss > 0 |
| **Measurement** | End-to-end message counting: producer sequence numbers vs. consumer acknowledgments; dead letter queue monitoring |
| **Frequency** | Continuous monitoring + weekly chaos test |
| **Automation** | Chaos Mesh/Litmus injecting broker failures; automated reconciliation job comparing produced vs. consumed counts |
| **Owner** | Platform Team |

**Implementation:**

```yaml
# Kafka producer config for guaranteed delivery
producer:
  acks: all
  retries: 2147483647
  max.in.flight.requests.per.connection: 1
  enable.idempotence: true

# Consumer config for at-least-once delivery
consumer:
  enable.auto.commit: false
  isolation.level: read_committed
```

**Chaos Test (weekly):**
```
1. Produce 1,000,000 sequenced test events to bet-placement topic
2. Kill 1 of 3 Kafka brokers mid-stream
3. Kill 2 of 5 consumer instances mid-processing
4. Wait for recovery (consumers rejoin, broker rebalances)
5. Assert: all 1,000,000 events consumed exactly once (idempotent consumer)
6. Assert: dead letter queue count = 0
```

**Reconciliation Job (hourly):**
```
SELECT COUNT(*) FROM event_store WHERE type = 'BetPlaced' AND timestamp > NOW() - INTERVAL '1 hour'
vs.
kafka-consumer-groups --describe --group bet-settlement | sum(current-offset - log-end-offset)
Mismatch > 0 triggers PagerDuty alert.
```

---

### FF-4: Auditability — Regulatory Compliance Trail

| Attribute | Value |
|-----------|-------|
| **Characteristic** | Auditability |
| **Metric** | Percentage of bets with complete, reconstructable event chain |
| **Threshold** | 100% of bets have full event chain (OddsPublished -> BetPlaced -> BetConfirmed -> BetSettled) |
| **Failure Threshold** | Any bet missing an event in its chain |
| **Measurement** | Nightly reconciliation job scanning event store for incomplete chains |
| **Frequency** | Nightly batch + on-demand regulatory report |
| **Automation** | Automated scan comparing bet IDs across event types; missing links trigger alert |
| **Owner** | Compliance Team |

**Implementation:**

```sql
-- Nightly audit query: find bets with incomplete event chains
SELECT bet_id,
       MAX(CASE WHEN event_type = 'OddsPublished' THEN 1 ELSE 0 END) AS has_odds,
       MAX(CASE WHEN event_type = 'BetPlaced' THEN 1 ELSE 0 END) AS has_placed,
       MAX(CASE WHEN event_type = 'BetConfirmed' THEN 1 ELSE 0 END) AS has_confirmed,
       MAX(CASE WHEN event_type = 'BetSettled' THEN 1 ELSE 0 END) AS has_settled
FROM audit_event_store
WHERE created_at > CURRENT_DATE - INTERVAL '1 day'
GROUP BY bet_id
HAVING MAX(CASE WHEN event_type = 'BetSettled' THEN 1 ELSE 0 END) = 1
   AND (MAX(CASE WHEN event_type = 'BetPlaced' THEN 1 ELSE 0 END) = 0
    OR  MAX(CASE WHEN event_type = 'BetConfirmed' THEN 1 ELSE 0 END) = 0);
-- Result must be empty. Any rows = compliance violation.
```

---

### FF-5: Performance — Bet Placement Throughput

| Attribute | Value |
|-----------|-------|
| **Characteristic** | Performance |
| **Metric** | Bet placement throughput (bets/second) at p99 latency |
| **Threshold** | >= 50,000 bets/second with p99 < 200ms |
| **Failure Threshold** | < 30,000 bets/second OR p99 > 500ms |
| **Measurement** | Load test in staging environment matching production topology |
| **Frequency** | On every release candidate; nightly in staging |
| **Automation** | k6 load test in CI pipeline; results compared against baseline |
| **Owner** | Bet Platform Team |

---

## Fitness Function Summary

| ID | Characteristic | Metric | Threshold | Frequency |
|----|---------------|--------|-----------|-----------|
| FF-1 | Responsiveness | Notification latency p99 | < 100ms | Continuous |
| FF-2 | Elasticity | Scale-out time + consumer lag | < 3min / < 10k lag | Continuous + weekly |
| FF-3 | Fault Tolerance | Message loss count | 0 | Continuous + weekly |
| FF-4 | Auditability | Complete event chains | 100% | Nightly |
| FF-5 | Performance | Bet throughput at p99 | >= 50k/s, < 200ms | Per release |

## Architecture Governance

- **All fitness functions are automated** -- no manual checks required for release gates.
- **FF-1, FF-2, FF-3** run continuously in production with alerting.
- **FF-1, FF-5** are CI/CD gates -- a release candidate that fails these cannot be deployed.
- **FF-3** chaos tests run weekly in staging; results reviewed in architecture review.
- **FF-4** runs nightly with results sent to compliance team; failures escalate immediately.
