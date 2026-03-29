# Architecture Decision: Service-Based with Evolution Path

## Last Updated: 2026-03-29

## Decision

**Gewaehlter Stil:** Service-Based Architecture
**Aktuelle Phase:** Phase 1 — Foundation

## Architecture Overview (Phase 1)

```
                    [Clients]
                       |
                [API Gateway]
                       |
        +--------------+--------------+
        |              |              |
  [User Service] [Core Domain] [Notification]
        |              |              |
        +--------------+--------------+
                       |
              [Shared PostgreSQL]
```

### Service-Schnitt (Phase 1)

| Service | Verantwortung | Team |
|---------|---------------|------|
| API Gateway | Routing, Auth, Rate Limiting | Alle |
| User Service | Registrierung, Profile, Auth | Team A |
| Core Domain Service | Kerngeschaeftslogik | Team A |
| Notification Service | E-Mail, Push, In-App | Team A |
| Payment Service (bei Bedarf) | Billing, Subscriptions | Team A |

### Technologie-Stack (Empfehlung)

| Komponente | Technologie | Begruendung |
|------------|-------------|-------------|
| Services | Kotlin/Quarkus oder Node.js | Schnelle Entwicklung, gute DX |
| API Gateway | Kong oder Traefik | Leichtgewichtig, erweiterbar |
| Database | PostgreSQL (shared) | Bewahrt, zuverlaessig, skalierbar |
| Deployment | Docker + Kubernetes (managed) | Standard, gute Tooling-Unterstuetzung |
| CI/CD | GitHub Actions | Schnell aufgesetzt, guenstig |

## Fitness Functions: Phase 1

Fitness Functions messen kontinuierlich, ob die Architektur die priorisierten Charakteristiken erfuellt. Sie werden automatisiert in der CI/CD Pipeline ausgefuehrt.

### FF-1: Deployment Frequency

**Charakteristik:** Deployability
**Metrik:** Anzahl erfolgreicher Deployments pro Woche
**Messung:** CI/CD Pipeline Metriken (GitHub Actions / Deployment Tracker)

| Schwelle | Wert |
|----------|------|
| Ziel (gruen) | >= 10 Deployments/Woche |
| Warnung (gelb) | 5-9 Deployments/Woche |
| Kritisch (rot) | < 5 Deployments/Woche |

**Implementierung:**
```bash
# fitness-function: deployment-frequency
# Ausfuehrung: Woechentlich (Montag)
DEPLOY_COUNT=$(gh api repos/{owner}/{repo}/actions/runs \
  --jq '[.workflow_runs[] | select(.conclusion=="success" and .name=="deploy")] | length')

if [ "$DEPLOY_COUNT" -ge 10 ]; then echo "PASS"; exit 0
elif [ "$DEPLOY_COUNT" -ge 5 ]; then echo "WARN"; exit 0
else echo "FAIL"; exit 1; fi
```

### FF-2: Deployment Lead Time

**Charakteristik:** Deployability
**Metrik:** Zeit von Commit bis Production
**Messung:** CI/CD Timestamps

| Schwelle | Wert |
|----------|------|
| Ziel (gruen) | < 15 Minuten |
| Warnung (gelb) | 15-30 Minuten |
| Kritisch (rot) | > 30 Minuten |

**Implementierung:**
```bash
# fitness-function: deployment-lead-time
# Ausfuehrung: Bei jedem Deployment
START=$(git log -1 --format=%ct HEAD)
END=$(date +%s)
LEAD_TIME_MIN=$(( (END - START) / 60 ))

if [ "$LEAD_TIME_MIN" -le 15 ]; then echo "PASS: ${LEAD_TIME_MIN}m"; exit 0
elif [ "$LEAD_TIME_MIN" -le 30 ]; then echo "WARN: ${LEAD_TIME_MIN}m"; exit 0
else echo "FAIL: ${LEAD_TIME_MIN}m"; exit 1; fi
```

### FF-3: Service Coupling (Afferent/Efferent)

**Charakteristik:** Evolvability
**Metrik:** Anzahl der direkten Abhaengigkeiten zwischen Services
**Messung:** Statische Code-Analyse / Dependency Check

| Schwelle | Wert |
|----------|------|
| Ziel (gruen) | Jeder Service hat max 2 direkte Service-Abhaengigkeiten |
| Warnung (gelb) | Ein Service hat 3 Abhaengigkeiten |
| Kritisch (rot) | Ein Service hat > 3 Abhaengigkeiten |

**Implementierung:**
```python
# fitness-function: service-coupling
# Ausfuehrung: Bei jedem PR
import ast, os, sys

MAX_DEPS = 2
SERVICES = ["user", "core", "notification", "payment"]

def count_service_imports(service_dir):
    deps = set()
    for root, _, files in os.walk(service_dir):
        for f in files:
            if f.endswith((".py", ".kt", ".ts")):
                content = open(os.path.join(root, f)).read()
                for other in SERVICES:
                    if other != os.path.basename(service_dir):
                        if f"from {other}" in content or f"import {other}" in content:
                            deps.add(other)
    return deps

violations = []
for svc in SERVICES:
    deps = count_service_imports(f"services/{svc}")
    if len(deps) > MAX_DEPS:
        violations.append(f"{svc}: {len(deps)} deps ({', '.join(deps)})")

if violations:
    print("FAIL: " + "; ".join(violations))
    sys.exit(1)
print("PASS")
```

### FF-4: Change Failure Rate

**Charakteristik:** Deployability
**Metrik:** Prozentsatz der Deployments die zu einem Rollback fuehren
**Messung:** Deployment + Rollback Tracking

| Schwelle | Wert |
|----------|------|
| Ziel (gruen) | < 5% |
| Warnung (gelb) | 5-15% |
| Kritisch (rot) | > 15% |

**Implementierung:**
```bash
# fitness-function: change-failure-rate
# Ausfuehrung: Woechentlich
TOTAL=$(kubectl get deployments -o json | jq '.items | length')
ROLLBACKS=$(kubectl rollout history deployment --all-namespaces | grep -c "rolled back")
RATE=$(( ROLLBACKS * 100 / TOTAL ))

if [ "$RATE" -le 5 ]; then echo "PASS: ${RATE}%"; exit 0
elif [ "$RATE" -le 15 ]; then echo "WARN: ${RATE}%"; exit 0
else echo "FAIL: ${RATE}%"; exit 1; fi
```

### FF-5: Feature Cycle Time

**Charakteristik:** Evolvability
**Metrik:** Durchschnittliche Zeit von Feature-Branch-Erstellung bis Merge
**Messung:** Git/GitHub Metriken

| Schwelle | Wert |
|----------|------|
| Ziel (gruen) | < 3 Tage |
| Warnung (gelb) | 3-7 Tage |
| Kritisch (rot) | > 7 Tage |

**Implementierung:**
```bash
# fitness-function: feature-cycle-time
# Ausfuehrung: Woechentlich
MERGED_PRS=$(gh pr list --state merged --limit 20 --json createdAt,mergedAt)
AVG_HOURS=$(echo "$MERGED_PRS" | jq '
  [.[] | ( (.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601) ) / 3600]
  | add / length')
AVG_DAYS=$(echo "$AVG_HOURS / 24" | bc)

if [ "$AVG_DAYS" -le 3 ]; then echo "PASS: ${AVG_DAYS}d"; exit 0
elif [ "$AVG_DAYS" -le 7 ]; then echo "WARN: ${AVG_DAYS}d"; exit 0
else echo "FAIL: ${AVG_DAYS}d"; exit 1; fi
```

### FF-6: Response Time P95

**Charakteristik:** Scalability
**Metrik:** 95. Perzentil der API Response Time
**Messung:** APM / Prometheus

| Schwelle | Wert |
|----------|------|
| Ziel (gruen) | < 200ms |
| Warnung (gelb) | 200-500ms |
| Kritisch (rot) | > 500ms |

**Implementierung:**
```promql
# fitness-function: response-time-p95
# Ausfuehrung: Kontinuierlich (Prometheus Alert)
# Prometheus Alert Rule
groups:
  - name: fitness-functions
    rules:
      - alert: P95LatencyHigh
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "P95 latency exceeds 500ms"
      - alert: P95LatencyWarning
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.2
        for: 5m
        labels:
          severity: warning
```

### FF-7: Horizontal Scalability

**Charakteristik:** Scalability
**Metrik:** Throughput skaliert linear mit Instanzen (+-20%)
**Messung:** Load Test in CI (woechentlich)

| Schwelle | Wert |
|----------|------|
| Ziel (gruen) | Throughput-Ratio >= 0.8 bei Verdopplung der Instanzen |
| Warnung (gelb) | Ratio 0.6-0.8 |
| Kritisch (rot) | Ratio < 0.6 |

**Implementierung:**
```bash
# fitness-function: horizontal-scalability
# Ausfuehrung: Woechentlich (Staging)
# 1. Baseline: 1 Instanz
kubectl scale deployment core-service --replicas=1
sleep 30
BASELINE=$(k6 run --quiet load-test.js | grep "http_reqs" | awk '{print $2}')

# 2. Scaled: 2 Instanzen
kubectl scale deployment core-service --replicas=2
sleep 30
SCALED=$(k6 run --quiet load-test.js | grep "http_reqs" | awk '{print $2}')

RATIO=$(echo "scale=2; $SCALED / ($BASELINE * 2)" | bc)

if (( $(echo "$RATIO >= 0.8" | bc -l) )); then echo "PASS: ratio=${RATIO}"; exit 0
elif (( $(echo "$RATIO >= 0.6" | bc -l) )); then echo "WARN: ratio=${RATIO}"; exit 0
else echo "FAIL: ratio=${RATIO}"; exit 1; fi
```

## Fitness Function Dashboard (Phase 1)

| # | Fitness Function | Charakteristik | Frequenz | Automatisiert |
|---|-----------------|----------------|----------|---------------|
| FF-1 | Deployment Frequency | Deployability | Woechentlich | Ja (CI) |
| FF-2 | Deployment Lead Time | Deployability | Pro Deploy | Ja (CI) |
| FF-3 | Service Coupling | Evolvability | Pro PR | Ja (CI) |
| FF-4 | Change Failure Rate | Deployability | Woechentlich | Ja (CI) |
| FF-5 | Feature Cycle Time | Evolvability | Woechentlich | Ja (CI) |
| FF-6 | Response Time P95 | Scalability | Kontinuierlich | Ja (Prometheus) |
| FF-7 | Horizontal Scalability | Scalability | Woechentlich | Ja (Staging) |

## Phase-Transition Trigger (automatisiert)

Die folgenden Fitness Functions signalisieren, wann ein Phasenwechsel noetig ist:

```yaml
# phase-transition-triggers.yml
phase_1_to_2:
  trigger_any:
    - metric: active_users
      threshold: ">= 10000"
    - metric: deployment_conflicts_per_week
      threshold: ">= 2"
    - metric: team_count
      threshold: ">= 2"
  action: "Erstelle ADR fuer Phase 2 Migration"

phase_2_to_3:
  trigger_any:
    - metric: active_users
      threshold: ">= 50000"
    - metric: p95_latency_ms
      threshold: ">= 500"
    - metric: team_count
      threshold: ">= 3"
  action: "Identifiziere Hot-Path Services fuer Microservice-Extraktion"
```

## ADR: Architecture Style Selection

**Status:** Accepted
**Kontext:** Schnell wachsendes Startup, 4 Devs aktuell, Ziel 3 Teams und 100k User in 2 Jahren. Brauchen eine Architektur die mitwachsen kann ohne das Team zu ueberlasten.
**Entscheidung:** Service-Based Architecture mit geplantem Evolution Path ueber 3 Phasen.
**Begruendung:** Microservices waeren zu komplex fuer das aktuelle Team. Ein Monolith wuerde bei 3 Teams und 100k Usern zum Bottleneck. Service-Based bietet den optimalen Trade-off.
**Konsequenzen:**
- Pro: Unabhaengige Deployments, klare Team-Ownership, ueberschaubare Komplexitaet
- Contra: Weniger feingranulare Skalierung als Microservices, Shared DB in Phase 1 ist ein Kompromiss
- Risiko: Service-Grenzen muessen sorgfaeltig geschnitten werden (DDD empfohlen)
