# Quality Scenarios

Generated from architecture-assessment.md quality goals using ATAM.

## Last Updated: 2026-03-30

## Scenario Summary

| ID | Characteristic | Scenario | Test Type | Priority |
|----|---------------|----------|-----------|----------|
| QS-001 | Security (Encryption) | PII not present in application logs under normal operation | integration-test | Critical |
| QS-002 | Security (Encryption) | Database encryption at rest verified via TDE configuration | fitness-function | Critical |
| QS-003 | Security (Encryption) | Encryption keys managed in KMS, not hardcoded or in config files | fitness-function | Critical |
| QS-004 | Security (Authentication) | Unauthenticated request to payment endpoint rejected | integration-test | Critical |
| QS-005 | Security (Authentication) | Rate limiting enforced per user under burst traffic | load-test | Critical |
| QS-006 | Security (Input Validation) | SQL injection attempt on payment creation endpoint | integration-test | Critical |
| QS-007 | Security (Input Validation) | Card number masked in all API responses | unit-test | Critical |
| QS-008 | Data Integrity | Concurrent payment creation produces no duplicate or lost transactions | integration-test | Critical |
| QS-009 | Data Integrity | Partial failure during payment creation leaves no orphaned state | chaos-test | Critical |
| QS-010 | Data Integrity | Refund on already-refunded payment rejected atomically | unit-test | Critical |
| QS-011 | Compliance (GDPR Retention) | Automated deletion job removes data older than 36 months | integration-test | Critical |
| QS-012 | Compliance (GDPR Retention) | Right to Erasure endpoint deletes all PII for a user | integration-test | Critical |
| QS-013 | Compliance (Audit Logging) | createPayment and refundPayment produce immutable audit entries | integration-test | Critical |
| QS-014 | Compliance (Audit Logging) | Audit log entries contain zero PII fields | unit-test | Critical |
| QS-015 | Performance | API response time under peak load | load-test | Important |
| QS-016 | Availability | Service recovers after dependency failure | chaos-test | Important |
| QS-017 | Fault Tolerance | Payment retry succeeds after transient downstream failure | integration-test | Important |
| QS-018 | Recoverability | Pending payments resume after application restart | integration-test | Important |
| QS-019 | Observability | Structured JSON logs with correlation IDs across request lifecycle | integration-test | Important |
| QS-020 | Scalability | System handles 100 concurrent payment requests | load-test | Nice-to-have |
| QS-021 | Deployability | Zero-downtime deployment verified | manual-review | Important |

## Test Type Distribution

| Test Type | Count | Scenarios |
|-----------|-------|-----------|
| unit-test | 3 | QS-007, QS-010, QS-014 |
| integration-test | 10 | QS-001, QS-004, QS-006, QS-008, QS-011, QS-012, QS-013, QS-017, QS-018, QS-019 |
| load-test | 3 | QS-005, QS-015, QS-020 |
| chaos-test | 2 | QS-009, QS-016 |
| fitness-function | 2 | QS-002, QS-003 |
| manual-review | 1 | QS-021 |

## Scenarios

### Security (Encryption) -- Critical, Top 3

#### QS-001: No PII Leakage in Application Logs
- **Characteristic:** Security (Encryption)
- **Source:** Application processing a payment with PII fields (cardNumber, cardHolder, iban)
- **Stimulus:** POST /api/payments with full PII payload
- **Environment:** Normal operation
- **Artifact:** Application log output (stdout/file)
- **Response:** Log entries created for the request contain no plaintext cardNumber, cardHolder, or iban values
- **Response Measure:** Zero matches for PII patterns (card number regex, IBAN regex, cardholder name) in log output after processing 100 payment requests
- **Test Type:** integration-test
- **Constraint Reference:** SEC-001 verification criterion: "Keine sensiblen Daten im Klartext in Logs"

#### QS-002: Database Transparent Data Encryption Active
- **Characteristic:** Security (Encryption)
- **Source:** DevOps / CI pipeline
- **Stimulus:** Query PostgreSQL configuration for TDE status
- **Environment:** All environments (dev, staging, production)
- **Artifact:** PostgreSQL database configuration
- **Response:** TDE is enabled with AES-256 algorithm
- **Response Measure:** `SELECT setting FROM pg_settings WHERE name = 'data_encryption'` returns enabled, or equivalent TDE verification query confirms AES-256
- **Test Type:** fitness-function
- **Constraint Reference:** SEC-001 verification criterion: "Datenbank nutzt TDE"

#### QS-003: Encryption Keys in KMS, Not in Source
- **Characteristic:** Security (Encryption)
- **Source:** CI pipeline / static analysis
- **Stimulus:** Scan repository and configuration files for hardcoded encryption keys
- **Environment:** Build time
- **Artifact:** Source code repository, application.yml, environment configs
- **Response:** No encryption keys found in source; all key references point to KMS
- **Response Measure:** Zero hardcoded key material detected; application config references KMS endpoint for key retrieval
- **Test Type:** fitness-function
- **Constraint Reference:** SEC-001 verification criterion: "Encryption Keys im KMS"

### Security (Authentication) -- Critical, Top 3

#### QS-004: Unauthenticated Request Rejected with 401
- **Characteristic:** Security (Authentication)
- **Source:** External client without valid JWT
- **Stimulus:** GET /api/payments/1 without Authorization header
- **Environment:** Normal operation
- **Artifact:** PaymentController, Spring Security filter chain
- **Response:** Request rejected before reaching controller logic
- **Response Measure:** HTTP 401 Unauthorized returned in <50ms; no payment data in response body
- **Test Type:** integration-test
- **Constraint Reference:** SEC-002 verification criterion: "Alle Endpunkte (ausser /health) erfordern JWT"

#### QS-005: Rate Limiting Under Burst Traffic
- **Characteristic:** Security (Authentication)
- **Source:** Single authenticated user
- **Stimulus:** 200 requests within 60 seconds to POST /api/payments
- **Environment:** Normal operation, single user hammering the API
- **Artifact:** Rate limiter middleware / Spring filter
- **Response:** First 100 requests succeed; subsequent requests receive HTTP 429
- **Response Measure:** Requests 101-200 return HTTP 429 Too Many Requests; no payment created beyond limit
- **Test Type:** load-test
- **Constraint Reference:** SEC-002 verification criterion: "Rate Limiting pro Nutzer"

### Security (Input Validation) -- Critical, Top 3

#### QS-006: SQL Injection Attempt Blocked
- **Characteristic:** Security (Input Validation)
- **Source:** Malicious external client
- **Stimulus:** POST /api/payments with cardHolder field containing `'; DROP TABLE payments; --`
- **Environment:** Normal operation
- **Artifact:** PaymentController, input validation layer, JPA parameterized queries
- **Response:** Request rejected with HTTP 400 or input sanitized; database unaffected
- **Response Measure:** Payments table intact after attack; no SQL execution beyond parameterized query; HTTP 400 returned
- **Test Type:** integration-test

#### QS-007: Card Number Masked in API Responses
- **Characteristic:** Security (Input Validation)
- **Source:** Any authenticated client
- **Stimulus:** GET /api/payments/1 for a payment with stored card number
- **Environment:** Normal operation
- **Artifact:** PaymentResponse serialization
- **Response:** Card number displayed as masked value (e.g., ****-****-****-1234)
- **Response Measure:** Full 16-digit card number never appears in any PaymentResponse JSON; only last 4 digits visible
- **Test Type:** unit-test

### Data Integrity -- Critical, Top 3

#### QS-008: No Duplicates or Lost Transactions Under Concurrency
- **Characteristic:** Data Integrity
- **Source:** 50 concurrent clients
- **Stimulus:** 50 simultaneous POST /api/payments with unique idempotency keys
- **Environment:** Normal load, PostgreSQL under concurrent write pressure
- **Artifact:** PaymentService, PostgreSQL transaction manager
- **Response:** Exactly 50 payment records created, each with correct amount and status
- **Response Measure:** COUNT(*) on payments table equals exactly 50; no duplicate idempotency keys; all amounts match submitted values
- **Test Type:** integration-test

#### QS-009: No Orphaned State on Partial Failure During Payment Creation
- **Characteristic:** Data Integrity
- **Source:** Infrastructure fault injection
- **Stimulus:** Database connection drops mid-transaction during payment creation
- **Environment:** Degraded mode -- database becomes unavailable after INSERT but before COMMIT
- **Artifact:** PaymentService transaction boundary, Spring @Transactional
- **Response:** Transaction rolled back; no partial payment record persisted
- **Response Measure:** Zero payment records with status "PENDING" or "INCOMPLETE" after DB recovery; client receives HTTP 500/503
- **Test Type:** chaos-test

#### QS-010: Double Refund Rejected Atomically
- **Characteristic:** Data Integrity
- **Source:** Authenticated client
- **Stimulus:** POST /api/payments/{id}/refund on a payment with status REFUNDED
- **Environment:** Normal operation
- **Artifact:** PaymentService.refund(), payment state machine
- **Response:** Refund rejected; payment state unchanged
- **Response Measure:** HTTP 409 Conflict or HTTP 400 returned; payment status remains REFUNDED; no double credit issued
- **Test Type:** unit-test

### Compliance (GDPR Retention) -- Critical, Top 3

#### QS-011: Automated Deletion of Data Older Than 36 Months
- **Characteristic:** Compliance (GDPR Retention)
- **Source:** Scheduled job (time-based trigger)
- **Stimulus:** Deletion job runs and finds payment records older than 36 months
- **Environment:** Normal operation, nightly batch
- **Artifact:** GDPR retention job, payments table
- **Response:** All payment records older than 36 months deleted, including associated PII
- **Response Measure:** Zero records with created_at older than 36 months after job completion; audit log entry for deletion created
- **Test Type:** integration-test
- **Constraint Reference:** COMP-001 verification criterion: "Automatischer Loesch-Job"

#### QS-012: Right to Erasure Deletes All User PII
- **Characteristic:** Compliance (GDPR Retention)
- **Source:** Data subject (via authenticated request)
- **Stimulus:** DELETE /api/payments/user/{userId}
- **Environment:** Normal operation
- **Artifact:** PaymentService, payments table, any associated PII storage
- **Response:** All PII (cardNumber, cardHolder, iban) for the specified user deleted or anonymized
- **Response Measure:** SELECT query for userId returns zero rows with non-null PII fields; HTTP 200/204 returned; audit log entry created for erasure
- **Test Type:** integration-test
- **Constraint Reference:** COMP-001 verification criterion: "DELETE Endpunkt fuer Datenloeschung"

### Compliance (Audit Logging) -- Critical, Top 3

#### QS-013: Write Operations Produce Immutable Audit Entries
- **Characteristic:** Compliance (Audit Logging)
- **Source:** Authenticated client
- **Stimulus:** POST /api/payments (createPayment) and POST /api/payments/{id}/refund (refundPayment)
- **Environment:** Normal operation
- **Artifact:** Audit log subsystem (append-only log store)
- **Response:** Each operation produces exactly one audit entry with timestamp, userId, action, and resource ID
- **Response Measure:** Audit log contains entries for both operations; entries cannot be modified or deleted (append-only verification); entry count matches operation count
- **Test Type:** integration-test
- **Constraint Reference:** COMP-002 verification criterion: "Alle POST/PUT/DELETE geloggt"

#### QS-014: Zero PII in Audit Log Entries
- **Characteristic:** Compliance (Audit Logging)
- **Source:** Audit log subsystem
- **Stimulus:** Audit entry created for a payment with full PII (cardNumber, cardHolder, iban)
- **Environment:** Normal operation
- **Artifact:** Audit log serializer / formatter
- **Response:** Audit entry contains action metadata but no PII values
- **Response Measure:** Regex scan of audit entry for card number patterns, IBAN patterns, and cardholder names returns zero matches
- **Test Type:** unit-test
- **Constraint Reference:** COMP-002 verification criterion: "Keine PII im Audit-Log"

### Performance -- Important

#### QS-015: API Response Time Under Peak Load
- **Characteristic:** Performance
- **Source:** 500 concurrent users
- **Stimulus:** Mixed workload (60% GET, 30% POST, 10% refund) sustained for 5 minutes
- **Environment:** Peak load conditions
- **Artifact:** All /api/payments endpoints
- **Response:** System remains responsive under sustained load
- **Response Measure:** p95 response time <200ms; zero HTTP 5xx errors; no connection pool exhaustion
- **Test Type:** load-test

### Availability -- Important

#### QS-016: Service Recovery After Dependency Failure
- **Characteristic:** Availability
- **Source:** Infrastructure (PostgreSQL becomes unreachable)
- **Stimulus:** Database connection lost for 30 seconds, then restored
- **Environment:** Degraded mode transitioning back to normal
- **Artifact:** Spring Boot application, HikariCP connection pool, /actuator/health
- **Response:** Service detects failure, returns HTTP 503 during outage, recovers automatically when DB returns
- **Response Measure:** /actuator/health returns UP within 60 seconds of DB recovery; no manual restart required; no data corruption
- **Test Type:** chaos-test

### Fault Tolerance -- Important

#### QS-017: Refund Retry After Transient Downstream Failure
- **Characteristic:** Fault Tolerance
- **Source:** Downstream payment gateway
- **Stimulus:** Refund request to external gateway times out on first attempt
- **Environment:** Degraded mode -- downstream service intermittently available
- **Artifact:** PaymentService.refund(), retry mechanism
- **Response:** System retries the refund operation; succeeds on subsequent attempt
- **Response Measure:** Refund completes within 3 retry attempts; payment status transitions to REFUNDED; exactly one refund processed (no duplicates)
- **Test Type:** integration-test

### Recoverability -- Important

#### QS-018: Pending Payments Resume After Application Restart
- **Characteristic:** Recoverability
- **Source:** Application crash / restart
- **Stimulus:** Application killed while 10 payments are in PENDING status; application restarted
- **Environment:** Recovery after crash
- **Artifact:** PaymentService, startup recovery logic, payments table
- **Response:** All PENDING payments either completed or rolled back; no payments stuck indefinitely
- **Response Measure:** Zero payments in PENDING state older than 5 minutes after restart; all payments in terminal state (COMPLETED or FAILED)
- **Test Type:** integration-test

### Observability -- Important

#### QS-019: Structured Logging with Correlation IDs
- **Characteristic:** Observability
- **Source:** External client making a payment request
- **Stimulus:** POST /api/payments triggers log entries across controller, service, and repository layers
- **Environment:** Normal operation
- **Artifact:** Logging framework configuration, MDC (Mapped Diagnostic Context)
- **Response:** All log entries for one request share the same correlation ID; logs are valid JSON
- **Response Measure:** 100% of log lines for a given request parseable as JSON; all share identical correlationId field; log entries span all three layers
- **Test Type:** integration-test

### Scalability -- Nice-to-have

#### QS-020: 100 Concurrent Payment Requests Handled
- **Characteristic:** Scalability
- **Source:** 100 concurrent clients
- **Stimulus:** 100 simultaneous POST /api/payments
- **Environment:** Peak load
- **Artifact:** Application thread pool, HikariCP connection pool, PostgreSQL
- **Response:** All 100 requests processed without rejection or timeout
- **Response Measure:** 100% success rate (HTTP 2xx); p99 response time <500ms; no connection pool exhaustion
- **Test Type:** load-test

### Deployability -- Important

#### QS-021: Zero-Downtime Deployment Verification
- **Characteristic:** Deployability
- **Source:** DevOps team
- **Stimulus:** New version deployed to production via rolling update
- **Environment:** Production deployment
- **Artifact:** Kubernetes deployment / Docker container, /actuator/health
- **Response:** No dropped requests during deployment; old and new versions coexist briefly
- **Response Measure:** Zero HTTP 5xx during deployment window; /actuator/health returns UP throughout; deployment completes in <15 minutes
- **Test Type:** manual-review

## Tradeoffs and Sensitivity Points

### Tradeoff: Audit Logging Completeness vs. Performance
- **Tension:** Compliance (Audit Logging) vs. Performance
- **Scenarios affected:** QS-013, QS-015
- **Description:** Immutable audit logging for every write operation (QS-013) adds I/O overhead per request. Under peak load (QS-015), synchronous audit writes could push p95 response time above the 200ms target.
- **Decision needed:** Should audit logging be synchronous (guaranteeing log-before-response) or asynchronous (better latency but risk of lost audit entries on crash)?

### Tradeoff: Encryption at Rest vs. Query Performance
- **Tension:** Security (Encryption) vs. Performance
- **Scenarios affected:** QS-002, QS-015
- **Description:** TDE (QS-002) adds encryption/decryption overhead on every database read and write. Under peak load (QS-015), this overhead accumulates across concurrent requests, potentially degrading p95 latency.
- **Decision needed:** Accept the performance overhead as cost of compliance, or investigate column-level encryption for only PII fields to reduce the blast radius.

### Tradeoff: Rate Limiting Strictness vs. Legitimate Burst Traffic
- **Tension:** Security (Authentication) vs. Availability
- **Scenarios affected:** QS-005, QS-020
- **Description:** Strict per-user rate limiting at 100 req/min (QS-005) protects against abuse but may reject legitimate batch operations. A merchant submitting 100 payments in rapid succession would be throttled.
- **Decision needed:** Is 100 req/min the right threshold? Should batch payment endpoints have a separate, higher limit?

### Tradeoff: GDPR Deletion vs. Audit Trail Completeness
- **Tension:** Compliance (GDPR Retention) vs. Compliance (Audit Logging)
- **Scenarios affected:** QS-011, QS-012, QS-013
- **Description:** Right to Erasure (QS-012) requires deleting all user PII. But audit logs (QS-013) must be immutable and may reference the deleted user's transactions. Deleting audit entries violates immutability; keeping them with userId may violate GDPR.
- **Decision needed:** Pseudonymize user references in audit logs (replace userId with hash) to satisfy both requirements, or define audit log retention as a separate legal basis under GDPR Art. 6(1)(c)?

### Sensitivity Point: HikariCP Connection Pool Size
- **Parameter:** Maximum connection pool size (HikariCP `maximumPoolSize`)
- **Affects:** QS-008 (concurrent writes wait for connections), QS-015 (response time under load), QS-020 (100 concurrent requests need 100 connections)
- **Current setting:** Default (10)
- **Risk:** With 100 concurrent payment requests (QS-020), a pool of 10 means 90 requests queue for a connection, directly inflating response times and threatening the <200ms p95 target.

### Sensitivity Point: JWT Token Validation Caching
- **Parameter:** JWT signature verification caching duration
- **Affects:** QS-004 (validation latency), QS-015 (per-request overhead at scale)
- **Current setting:** Not configured (every request validates signature from scratch)
- **Risk:** Without caching, JWT validation on every request adds constant latency. At 500 concurrent users (QS-015), this overhead compounds against the 200ms target.
