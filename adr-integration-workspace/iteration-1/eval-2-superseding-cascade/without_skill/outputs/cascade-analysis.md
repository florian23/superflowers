# Fitness Function Cascade Analysis: Service-Based to Microservices Migration

## Summary

The migration from service-based (ADR-001) to microservices (ADR-005) requires a full review of existing fitness functions. Some are retired, some are adapted, and new ones are introduced to guard the properties that microservices demand.

---

## 1. Existing Service-Based Fitness Functions -- Disposition

### 1.1 Service Granularity Check

- **Original intent**: Ensure services stay within the 4-7 range and remain coarse-grained
- **Disposition**: **RETIRE**. The microservices model expects a higher count of fine-grained services. This fitness function's thresholds and philosophy no longer apply.

### 1.2 Shared Database Coupling

- **Original intent**: Ensure services access only their own schema partitions within the shared database
- **Disposition**: **RETIRE and REPLACE**. The shared database is eliminated entirely. Replaced by the new "Database-per-Service Isolation" fitness function below.

### 1.3 Inter-Service Synchronous Call Depth

- **Original intent**: Limit synchronous call chains between coarse-grained services to a maximum depth of 3
- **Disposition**: **ADAPT**. Still relevant but thresholds must tighten. In microservices, synchronous call depth is more dangerous. Reduce maximum allowed depth from 3 to 2 and add monitoring for cascading timeout risk.

### 1.4 Deployment Coupling

- **Original intent**: Verify that deploying one service does not require simultaneous deployment of another
- **Disposition**: **RETAIN with stricter enforcement**. This remains critical. Update the check to validate that each microservice has its own independent CI/CD pipeline and that no deployment requires coordinated releases across services.

### 1.5 Service Response Time SLA

- **Original intent**: Each service responds within 500ms at p95
- **Disposition**: **ADAPT**. Retain the concept but adjust. Microservices will add network hops. Measure end-to-end latency through the API gateway as well as individual service latency. Add a p99 target alongside p95.

---

## 2. New Fitness Functions for Microservices

### 2.1 Database-per-Service Isolation

- **What it guards**: No microservice directly accesses another service's datastore
- **Measurement**: Static analysis of database connection strings and ORM configurations; runtime monitoring of database connection sources
- **Threshold**: Zero cross-service direct database access. Any violation fails the build.
- **Rationale**: This is the foundational decoupling property of microservices. Without it, independent deployability and scaling are compromised.

### 2.2 Asynchronous Communication Ratio

- **What it guards**: The proportion of inter-service communication that is event-driven vs synchronous
- **Measurement**: Count async (message/event) vs sync (REST/gRPC) calls between services from distributed tracing data
- **Threshold**: At least 60% of inter-service interactions should be asynchronous
- **Rationale**: Over-reliance on synchronous calls creates temporal coupling and cascading failures, negating key microservices benefits.

### 2.3 Independent Deployability

- **What it guards**: Each microservice can be deployed to production without deploying any other service
- **Measurement**: CI/CD pipeline analysis -- verify each service has its own pipeline. Contract test results confirm no breaking API changes.
- **Threshold**: 100% of services must be independently deployable. Any shared deployment step fails the check.
- **Rationale**: Independent deployability is the primary driver for this migration (5 teams needing autonomy).

### 2.4 Service Per Team Ratio

- **What it guards**: No team owns too many or too few services, preventing cognitive overload or underutilization
- **Measurement**: Service ownership registry review
- **Threshold**: Each team owns 2-4 microservices. Violations trigger an architecture review.
- **Rationale**: With 5 teams, maintaining a balanced ownership model prevents bottlenecks and ensures accountability.

### 2.5 Distributed Tracing Coverage

- **What it guards**: Observability across the microservices mesh
- **Measurement**: Percentage of inter-service calls that include trace propagation headers and appear in the tracing backend
- **Threshold**: 95% trace coverage across all services
- **Rationale**: Without tracing, debugging production issues in a microservices topology becomes intractable. This fitness function ensures the operational prerequisite is met before scaling out further.

### 2.6 Circuit Breaker Presence

- **What it guards**: Fault isolation between services
- **Measurement**: Static analysis or configuration audit confirming every synchronous outbound call has a circuit breaker configured
- **Threshold**: 100% of synchronous outbound calls must have circuit breakers
- **Rationale**: Cascading failures are the primary operational risk in microservices. Circuit breakers are the frontline defense.

### 2.7 Contract Test Coverage

- **What it guards**: API compatibility between services without requiring integration environments
- **Measurement**: Percentage of inter-service APIs covered by consumer-driven contract tests (e.g., Pact)
- **Threshold**: 100% of public service APIs have contract tests from at least one consumer
- **Rationale**: With 5 teams deploying independently, contract tests replace the safety net that the shared database and coarse-grained integration previously provided.

---

## 3. Migration Fitness Function (Temporary)

### 3.1 Strangler Fig Progress

- **What it guards**: The migration is progressing and not stalling
- **Measurement**: Percentage of bounded contexts extracted from the old service-based services into independent microservices
- **Threshold**: Minimum 1 bounded context extracted per quarter until migration is complete
- **Rationale**: Architectural migrations that stall leave the system in a hybrid state that has the downsides of both styles and the benefits of neither. This temporary fitness function is retired when migration reaches 100%.

---

## 4. Summary Table

| Fitness Function | Origin | Disposition |
|---|---|---|
| Service Granularity Check | Existing | RETIRE |
| Shared Database Coupling | Existing | RETIRE and REPLACE |
| Inter-Service Sync Call Depth | Existing | ADAPT (max depth 3 -> 2) |
| Deployment Coupling | Existing | RETAIN (stricter) |
| Service Response Time SLA | Existing | ADAPT (add p99, add e2e) |
| Database-per-Service Isolation | New | -- |
| Asynchronous Communication Ratio | New | -- |
| Independent Deployability | New | -- |
| Service Per Team Ratio | New | -- |
| Distributed Tracing Coverage | New | -- |
| Circuit Breaker Presence | New | -- |
| Contract Test Coverage | New | -- |
| Strangler Fig Progress | New (temporary) | -- |
