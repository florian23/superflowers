# Architecture: Microservices
## E-Commerce Replatforming

## Last Updated: 2026-03-29

## Architecture Style

**Microservices** with API Gateway, asynchronous messaging, and per-service data stores.

## Top 3 Priority Characteristics

1. **Evolvability** -- Independent feature evolution across 3 teams
2. **Maintainability** -- Each team owns their domain independently
3. **Scalability** -- Black Friday: 50x checkout, 10x catalog

## Service Decomposition

| Service | Owning Team | Bounded Context |
|---------|------------|-----------------|
| Checkout Service | Team Checkout | Cart, payment, order placement |
| Catalog Service | Team Catalog | Product listings, search, inventory reads |
| Order Service | Team Fulfillment | Order lifecycle, fulfillment, returns |
| API Gateway | Platform | Routing, auth, rate limiting |

## Architecture Drivers

- 3 autonomous teams with Kubernetes experience
- Gradual monolith migration via Strangler Fig pattern
- Black Friday peak: 50x checkout traffic, 10x catalog traffic

---

## Fitness Functions

Fitness functions enforce the structural invariants of this microservices architecture. Each function is automated, runs in CI/CD, and has a clear pass/fail threshold.

### FF-1: Service Coupling (Evolvability)

**What it protects**: Independent deployability -- no service may depend on another service's internals.

**Metric**: Number of direct synchronous runtime dependencies between services (measured via static dependency analysis and runtime call graph).

**Threshold**: Each service has <= 2 synchronous downstream dependencies. Zero shared libraries beyond the approved platform SDK.

**Implementation**:
```yaml
# CI pipeline step
fitness-function:
  name: service-coupling-check
  type: static-analysis
  tool: archunit / custom dependency scanner
  rule: |
    For each service S in [checkout, catalog, order]:
      - S.sync_dependencies.count() <= 2
      - S.shared_libs subset_of APPROVED_PLATFORM_LIBS
      - S.imports intersect other_service.internal_packages == EMPTY
  trigger: every-commit
  failure-action: block-merge
```

**Measurement**: Parse service dependency manifests and import graphs. Flag any import of another service's internal package.

---

### FF-2: Independent Deployability (Evolvability + Maintainability)

**What it protects**: Any service can be deployed without deploying or restarting any other service.

**Metric**: Deployment independence ratio -- percentage of deployments that require zero coordinated changes in other services.

**Threshold**: >= 95% of deployments are single-service deployments. Zero deployments require synchronized multi-service releases.

**Implementation**:
```yaml
fitness-function:
  name: independent-deployability
  type: deployment-verification
  tool: custom CI check + contract tests
  rule: |
    For each service S:
      - S can start with all other services unavailable (circuit breakers activate)
      - S.api_contract is backward-compatible (checked via consumer-driven contract tests)
      - S.database_schema has no foreign keys to other service schemas
  trigger: every-deployment
  failure-action: block-deployment
```

**Measurement**: Consumer-driven contract tests (Pact) run on every PR. Startup isolation test runs the service with downstream stubs returning errors.

---

### FF-3: Data Isolation (Maintainability)

**What it protects**: Each service owns its data exclusively -- no shared databases.

**Metric**: Number of cross-service database access paths (direct DB connections, shared schemas, cross-service foreign keys).

**Threshold**: Zero cross-service database access. Each service has exactly one database schema that only it can read/write.

**Implementation**:
```yaml
fitness-function:
  name: data-isolation-check
  type: static-analysis + infrastructure-scan
  tool: database schema scanner / Terraform plan analysis
  rule: |
    For each service S:
      - S.database_credentials are unique to S
      - S.database_schema contains zero foreign keys referencing other service schemas
      - No other service has network access to S.database_host
      - K8s NetworkPolicies block cross-service DB access
  trigger: every-commit (schema), every-infra-change (network)
  failure-action: block-merge
```

**Measurement**: Scan Flyway/Liquibase migrations for cross-schema references. Validate Kubernetes NetworkPolicies deny cross-service DB port access.

---

### FF-4: Elastic Scalability (Scalability)

**What it protects**: Services scale independently to meet Black Friday targets (50x checkout, 10x catalog).

**Metric**: Autoscaling response time and throughput under load.

**Threshold**:
- Checkout: Sustains 50x baseline load with p99 latency < 500ms
- Catalog: Sustains 10x baseline load with p99 latency < 200ms
- Scale-up time from baseline to peak: < 3 minutes

**Implementation**:
```yaml
fitness-function:
  name: elastic-scalability
  type: load-test
  tool: k6 / Gatling
  rule: |
    For checkout-service:
      - Under 50x_baseline_rps: p99_latency < 500ms AND error_rate < 0.1%
      - HPA scales from baseline to target replicas in < 180s
    For catalog-service:
      - Under 10x_baseline_rps: p99_latency < 200ms AND error_rate < 0.1%
      - HPA scales from baseline to target replicas in < 180s
  trigger: weekly + pre-release
  failure-action: block-release
```

**Measurement**: Automated load tests in a staging environment that mirrors production K8s cluster sizing. HPA configuration validated against documented scaling targets.

---

### FF-5: API Contract Stability (Evolvability + Maintainability)

**What it protects**: API changes do not break consuming services.

**Metric**: Contract test pass rate across all consumer-provider pairs.

**Threshold**: 100% contract test pass rate. All API changes must be backward-compatible or versioned.

**Implementation**:
```yaml
fitness-function:
  name: api-contract-stability
  type: contract-test
  tool: Pact / Spring Cloud Contract
  rule: |
    For each provider service P:
      - All consumer contracts in Pact Broker pass against P.HEAD
      - P.openapi_spec has no removed fields or changed types (breaking change detector)
      - New API versions coexist with previous version for >= 1 release cycle
  trigger: every-commit
  failure-action: block-merge
```

**Measurement**: Pact Broker verification on every provider PR. OpenAPI diff tool flags breaking changes.

---

### FF-6: Service Size Guard (Maintainability)

**What it protects**: Prevents services from growing into mini-monoliths.

**Metric**: Lines of code, number of API endpoints, number of database tables per service.

**Threshold**:
- Max 10,000 LOC per service (excluding generated code and tests)
- Max 15 API endpoints per service
- Max 10 database tables per service

**Implementation**:
```yaml
fitness-function:
  name: service-size-guard
  type: static-analysis
  tool: cloc / custom metric collector
  rule: |
    For each service S:
      - S.loc (excluding tests, generated) <= 10000
      - S.api_endpoints.count() <= 15
      - S.database_tables.count() <= 10
  trigger: every-commit
  failure-action: warn (soft threshold), block-merge at 1.5x threshold
```

**Measurement**: Automated metric collection in CI. Trend dashboard alerts when services approach thresholds.

---

## Fitness Function Summary

| ID | Name | Characteristic | Trigger | Gate |
|----|------|---------------|---------|------|
| FF-1 | Service Coupling | Evolvability | Every commit | Block merge |
| FF-2 | Independent Deployability | Evolvability, Maintainability | Every deployment | Block deploy |
| FF-3 | Data Isolation | Maintainability | Every commit | Block merge |
| FF-4 | Elastic Scalability | Scalability | Weekly + pre-release | Block release |
| FF-5 | API Contract Stability | Evolvability, Maintainability | Every commit | Block merge |
| FF-6 | Service Size Guard | Maintainability | Every commit | Warn / Block |

## Changelog

- 2026-03-29: Initial architecture selection (Microservices) with 6 fitness functions
