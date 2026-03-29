# Architecture Style Analysis: Schnell wachsendes Startup

## Last Updated: 2026-03-29

## Ausgangslage

| Faktor | Status |
|--------|--------|
| Team | 4 Devs, wachsend auf 3 Teams |
| User | 1k aktuell, Ziel 100k in 2 Jahren |
| Deploys | Mehrfach pro Tag |
| Budget | Moderat, wachsend |
| Top-Charakteristiken | Evolvability, Scalability, Deployability |

## Bewertung der Architekturstile

### 1. Modular Monolith

| Charakteristik | Score (1-5) | Begr. |
|----------------|-------------|-------|
| Evolvability | 3 | Module austauschbar, aber Gesamtdeployment |
| Scalability | 2 | Nur vertikal oder Replikation der gesamten App |
| Deployability | 2 | Gesamtes System muss deployt werden |
| **Gesamt** | **7/15** | |

Gut als Startpunkt, aber schnell limitierend bei 3 Teams und 100k Usern.

### 2. Service-Based Architecture

| Charakteristik | Score (1-5) | Begr. |
|----------------|-------------|-------|
| Evolvability | 4 | Domänen-Services unabhängig erweiterbar |
| Scalability | 4 | Services individuell skalierbar |
| Deployability | 4 | Unabhängige Deployments pro Service |
| **Gesamt** | **12/15** | |

Optimaler Sweet Spot: weniger Komplexität als Microservices, aber die nötige Flexibilität für schnelles Wachstum. 4-8 grobgranulare Services passen perfekt zu 3 Teams.

### 3. Microservices

| Charakteristik | Score (1-5) | Begr. |
|----------------|-------------|-------|
| Evolvability | 5 | Maximale Unabhängigkeit |
| Scalability | 5 | Feingranulare Skalierung |
| Deployability | 5 | Volle Deployment-Unabhängigkeit |
| **Gesamt** | **15/15** | |

Theoretisch perfekt, aber der Overhead ist für ein 4-Dev-Team viel zu hoch. Distributed Computing Komplexität (Service Discovery, Circuit Breakers, Distributed Tracing) frisst die gesamte Velocity.

## Empfehlung: Service-Based Architecture

**Warum:** Service-Based bietet den besten Trade-off zwischen Flexibilität und Komplexität für ein schnell wachsendes Startup. Es ermöglicht unabhängige Deployments und Skalierung ohne den vollen Microservices-Overhead.

### Risiken

| Risiko | Mitigation |
|--------|-----------|
| Service-Grenzen falsch gezogen | Domain-Driven Design Workshop vor dem Schnitt |
| Distributed Data Management | Shared DB in Phase 1, DB-per-Service ab Phase 2 |
| Team-Overhead durch zu viele Services | Max 4-6 Services in Phase 1 |

## Evolution Path

### Phase 1: Foundation (Jetzt - Monat 6)
**Architektur:** Service-Based mit 4-6 Domain Services + Shared DB

```
[API Gateway]
    |
    +-- [User Service]
    +-- [Core Domain Service]
    +-- [Notification Service]
    +-- [Payment Service]
    |
[Shared PostgreSQL]
```

**Team:** 4 Devs, 1 Team
**Fokus:** Feature Velocity, Domain Boundaries validieren
**Trigger fuer Phase 2:** >10k User ODER >2 Teams ODER Deployment-Konflikte >2x/Woche

### Phase 2: Scale (Monat 6 - 12)
**Architektur:** Service-Based mit DB-per-Service + Event Bus

```
[API Gateway / BFF]
    |
    +-- [User Service] -- [User DB]
    +-- [Core Domain Service] -- [Core DB]
    +-- [Notification Service] -- [Notification DB]
    +-- [Payment Service] -- [Payment DB]
    +-- [Analytics Service] -- [Analytics DB]
    |
[Event Bus (RabbitMQ/Kafka)]
```

**Team:** 2 Teams (8-10 Devs)
**Fokus:** Service-Ownership pro Team, Async Communication
**Trigger fuer Phase 3:** >50k User ODER Latenz-Probleme ODER >3 Teams mit Koordinationsproblemen

### Phase 3: Mature (Monat 12 - 24)
**Architektur:** Selektive Microservices fuer Hot Paths

```
[API Gateway]
    |
    +-- [User Service Cluster] -- [User DB]
    +-- [Core Service A] -- [Core DB]
    +-- [Core Service B] -- [Core DB Read Replica]
    +-- [Search Microservice] -- [Elasticsearch]
    +-- [Notification Service] -- [Notification DB]
    +-- [Payment Service] -- [Payment DB]
    +-- [Analytics Pipeline] -- [ClickHouse]
    |
[Kafka Event Streaming]
[Redis Cache Layer]
```

**Team:** 3 Teams (12-15 Devs)
**Fokus:** Performance-kritische Pfade als Microservices extrahieren
**Entscheidung:** Nur Services mit nachgewiesenem Bottleneck werden aufgesplittet

## Phase-Transition Kriterien

| Von | Nach | Harte Trigger | Weiche Trigger |
|-----|------|---------------|----------------|
| Phase 1 | Phase 2 | >10k User, Deployment-Konflikte >2x/Woche | Zweites Team onboarded, Service-Kopplung spuerbar |
| Phase 2 | Phase 3 | >50k User, P95 Latenz >500ms | Drittes Team, einzelne Services werden zum Bottleneck |
