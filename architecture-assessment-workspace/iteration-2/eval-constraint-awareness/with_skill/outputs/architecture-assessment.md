# Architecture Characteristics

## Last Updated: 2026-03-30

## Skill Used
I'm using the architecture-assessment skill to identify architecture characteristics for this project.

## Active Organizational Constraints

The following organizational constraints are active for this feature and affect architecture characteristics:

| ID | Constraint | Type | Impact on Characteristics |
|----|-----------|------|--------------------------|
| SEC-001 | Encryption at Rest (AES-256) | Security, Mandatory | Elevates **Security** to critical; requires TDE for PostgreSQL, KMS for key management, no plaintext PII in logs |
| SEC-002 | API Authentication (OAuth 2.0 / JWT) | Security, Mandatory | Elevates **Security** to critical; all endpoints (except /health) require JWT, rate limiting per user |
| COMP-001 | GDPR Data Retention (max 36 months, Right to Erasure) | Compliance, Mandatory | Introduces **Compliance** as a characteristic; requires automated deletion job and DELETE endpoint for PII (cardNumber, cardHolder, iban) |
| COMP-002 | Audit Logging (immutable audit log) | Compliance, Mandatory | Reinforces **Compliance** and **Observability**; all POST/PUT/DELETE operations must be logged, no PII in audit logs |

**Excluded:** SEC-003 (Network Segmentation) -- handled by Platform Team.

## Top 3 Priority Characteristics

1. **Security** -- All PII (cardNumber, cardHolder, iban) encrypted at rest (AES-256), all API endpoints authenticated via OAuth 2.0 / JWT, rate limiting per user. Driven by constraints SEC-001 and SEC-002.
2. **Data Integrity** -- Zero payment data loss, all transactions ACID-compliant, no partial payment states. Critical for a payment service handling financial transactions.
3. **Compliance** -- GDPR data retention max 36 months with automated deletion, Right to Erasure via API, immutable audit log for all write operations with no PII leakage. Driven by constraints COMP-001 and COMP-002.

## All Characteristics

### Operational

| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Performance | Important | API response <200ms p95 for all endpoints | Yes - load test with k6/Gatling | Holistic (PR) |
| Availability | Important | 99.9% uptime (max 8.7h downtime/year) | Yes - health check endpoint /actuator/health | Nightly |
| Scalability | Nice-to-have | Handle 100 concurrent payment requests | No - revisit when traffic grows | -- |
| Fault Tolerance | Important | Payment creation must not lose data on partial failure; refunds retry on downstream failure | Yes - chaos test for DB connection loss | Nightly |
| Recoverability | Important | Resume incomplete payment processing after crash, no orphaned payment states | Yes - restart test with pending transactions | Nightly |

### Structural

| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Testability | Important | >80% line coverage, all endpoints have integration tests | Yes - coverage gate in CI | Atomic (commit) |
| Deployability | Important | Containerized (Docker), zero-downtime deployment, <15 min from commit to production | Yes - deployment pipeline check | Holistic (PR) |
| Maintainability | Nice-to-have | Clean layered architecture (Controller -> Service -> Repository), no circular dependencies | Yes - ArchUnit dependency check | Atomic (commit) |
| Data Integrity | Critical | All payment transactions ACID-compliant, no partial payment states, zero data loss | Yes - transaction boundary test | Atomic (commit) |
| Data Consistency | Important | Single PostgreSQL database, no eventual consistency issues, all reads reflect latest writes | Yes - integration test verifying read-after-write | Holistic (PR) |

### Cross-Cutting

| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Security (Encryption) | Critical | All persisted data AES-256 encrypted (TDE), encryption keys in KMS, no plaintext PII in logs | Yes - log scanner for PII patterns (card numbers, IBAN) | Atomic (commit) |
| Security (Authentication) | Critical | All endpoints except /health require valid JWT, rate limiting 100 req/min per user | Yes - integration test for unauthorized access returns 401 | Atomic (commit) |
| Security (Input Validation) | Critical | No SQL injection, all inputs validated and sanitized, card numbers masked in all outputs | Yes - OWASP ZAP scan | Holistic (PR) |
| Compliance (GDPR Retention) | Critical | Automated deletion of payment data after 36 months, DELETE /api/payments/user/{userId} for Right to Erasure | Yes - test verifying data deletion after retention period | Nightly |
| Compliance (Audit Logging) | Critical | Immutable append-only audit log for createPayment and refundPayment, zero PII in audit entries | Yes - audit log format test, PII absence check | Atomic (commit) |
| Observability | Important | Structured logging (JSON), request tracing with correlation IDs, metrics for payment success/failure rates | Yes - log format validation | Atomic (commit) |

**Cadence values:** Atomic (every commit/CI run), Holistic (per PR, may need running services), Nightly (long-running, scheduled).

## Architecture Drivers

- **Payment Data Sensitivity:** The system handles PII (cardNumber, cardHolder, iban) and financial data. This drives Security and Compliance as top priorities. Constraints SEC-001, SEC-002, COMP-001, and COMP-002 are mandatory organizational requirements that cannot be traded off.
- **Regulatory Environment (GDPR):** European payment processing requires data retention limits, right to erasure, and audit trails. This makes Compliance a driving characteristic rather than an implicit one.
- **Financial Transaction Integrity:** Payments must be atomic -- a payment is either fully processed or not at all. No partial states, no lost transactions. This drives Data Integrity as a top-3 characteristic.
- **Operational Reliability:** As a payment service, downtime directly impacts revenue. 99.9% availability target and fault tolerance for downstream failures are essential.

## Architecture Decisions

- **Spring Boot with Spring Security:** Leverages spring-boot-starter-security for OAuth 2.0 / JWT authentication, addressing SEC-002 constraint directly.
- **PostgreSQL with TDE:** PostgreSQL as the data store with Transparent Data Encryption for SEC-001 compliance. Single database ensures strong consistency for payment transactions.
- **Kotlin on JVM 21:** Modern language with null safety, reducing runtime errors in payment processing logic. JVM 21 for virtual threads supporting concurrent request handling.
- **Container Deployment (Docker):** Eclipse Temurin 21 base image, single JAR deployment for consistent environments and straightforward deployability.
- **Layered Architecture:** Controller -> Service -> Repository separation visible in the existing code structure. Supports testability and maintainability goals.

## Tradeoffs

| Decision | Benefits | Costs |
|----------|----------|-------|
| AES-256 encryption at rest (SEC-001) | PII protection, regulatory compliance | Slight performance overhead on DB reads/writes, KMS dependency |
| JWT on all endpoints (SEC-002) | Stateless authentication, scalable | Token validation latency on every request, token refresh complexity |
| Immutable audit logging (COMP-002) | Regulatory compliance, forensic capability | Storage growth over time, no PII allowed requires careful log filtering |
| GDPR automated deletion (COMP-001) | Legal compliance, reduced data liability | Complexity of deletion job, must handle cascading deletes, retention tracking |
| Single PostgreSQL database | Strong ACID guarantees, data integrity | Vertical scaling limits, single point of failure without replication |

## Changelog

- 2026-03-30: Initial architecture assessment for Payment Service. Identified Security, Data Integrity, and Compliance as top-3 driving characteristics. Assessment informed by 4 active organizational constraints (SEC-001, SEC-002, COMP-001, COMP-002) from constraint-selection. Security and Compliance elevated from implicit to driving characteristics due to mandatory constraints.
