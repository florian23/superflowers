# Architecture Characteristics

## Last Updated: 2026-03-28

## Status: BLOCKED -- Awaiting Concrete Metrics

The initial requirements ("schnell, sicher, gut skalierbar") are too vague to establish
architecture characteristics. Every characteristic below is marked BLOCKED until the
stakeholder provides specific, measurable targets.

**The Iron Law: NO SPEC WITHOUT ARCHITECTURE CHARACTERISTICS.**
**Corollary: NO ARCHITECTURE CHARACTERISTICS WITHOUT CONCRETE METRICS.**

---

## Top 3 Priority Characteristics (DRAFT -- Unconfirmed)

Based on the stated intent, the likely top 3 are:

1. **Performance** -- BLOCKED: No latency or throughput target defined
2. **Security** -- BLOCKED: No threat model, data classification, or compliance scope defined
3. **Scalability** -- BLOCKED: No user count, concurrency, or growth projection defined

These CANNOT be confirmed until concrete goals are provided.

---

## All Characteristics

### Operational

| Characteristic | Priority | Concrete Goal | Fitness Function |
|----------------|----------|---------------|------------------|
| Performance | Likely Critical | BLOCKED -- Need: p95 latency target (e.g., <200ms), throughput target (e.g., 500 req/s), payload size assumptions | BLOCKED |
| Scalability | Likely Critical | BLOCKED -- Need: concurrent user target (e.g., 10,000), growth rate (e.g., 2x/year), data volume projection | BLOCKED |
| Availability | Unknown | BLOCKED -- Need: uptime target (e.g., 99.9% = 8.7h downtime/year vs 99.99% = 52min/year) | BLOCKED |
| Reliability | Unknown | BLOCKED -- Need: acceptable error rate, recovery time objective (RTO), recovery point objective (RPO) | BLOCKED |
| Fault Tolerance | Unknown | BLOCKED -- Need: must the API continue serving during partial failures? Which degradation modes are acceptable? | BLOCKED |

### Structural

| Characteristic | Priority | Concrete Goal | Fitness Function |
|----------------|----------|---------------|------------------|
| Modularity | Unknown | BLOCKED -- Need: team size, ownership model, monolith vs microservices decision | BLOCKED |
| Extensibility | Unknown | BLOCKED -- Need: frequency of new endpoint additions, plugin/extension model? | BLOCKED |
| Testability | Unknown | BLOCKED -- Need: coverage target (e.g., >80%), integration test requirements | BLOCKED |
| Deployability | Unknown | BLOCKED -- Need: deployment frequency, zero-downtime requirement, rollback strategy | BLOCKED |
| Coupling | Unknown | BLOCKED -- Need: list of external system integrations, API contract stability requirements | BLOCKED |

### Cross-Cutting

| Characteristic | Priority | Concrete Goal | Fitness Function |
|----------------|----------|---------------|------------------|
| Security | Likely Critical | BLOCKED -- Need: data classification, auth model, encryption requirements, compliance scope | BLOCKED |
| Compliance | Unknown | BLOCKED -- Need: GDPR? SOC2? HIPAA? PCI-DSS? None? | BLOCKED |
| Observability | Unknown | BLOCKED -- Need: logging level, distributed tracing requirement, alerting SLAs | BLOCKED |
| Accessibility | N/A (API) | Not applicable for API | N/A |
| Usability | Unknown | BLOCKED -- Need: API consumer profile (internal teams? external developers? public?) | BLOCKED |

---

## Architecture Drivers

No drivers can be established until vague requirements are replaced with concrete metrics.

## Architecture Decisions

No decisions can be made. Decisions require concrete characteristics as input.

---

## Mandatory Questions Before Proceeding

The following questions MUST be answered with specific numbers before this assessment can be unblocked.

### Performance (currently vague: "schnell")

1. What is the target p95 API response time? (e.g., <100ms, <200ms, <500ms, <1s)
2. What is the target p99 API response time?
3. What throughput must the API sustain? (e.g., 100 req/s, 1,000 req/s, 10,000 req/s)
4. What is the expected average request payload size?
5. What is the expected average response payload size?
6. Are there specific endpoints with different latency budgets (e.g., search <500ms, CRUD <100ms)?

### Security (currently vague: "sicher")

7. What type of data does the API handle? (public, internal, PII, financial, health)
8. What authentication model is required? (API key, OAuth2, JWT, mTLS, none)
9. What authorization model is required? (RBAC, ABAC, simple scopes, none)
10. Is encryption at rest required? What standard? (AES-256, etc.)
11. Is mutual TLS required for service-to-service communication?
12. Which compliance frameworks apply? (GDPR, SOC2, HIPAA, PCI-DSS, none)
13. Is there a requirement for audit logging of all API access?
14. What is the vulnerability scan SLA? (e.g., no critical CVEs, patch within 24h)

### Scalability (currently vague: "gut skalieren")

15. How many concurrent users/connections must the API support today?
16. What is the expected growth rate? (e.g., 2x in 12 months, 10x in 24 months)
17. What is the expected peak-to-average traffic ratio? (e.g., 5:1, 10:1)
18. Must the system scale horizontally (add instances) or is vertical scaling acceptable?
19. Are there geographic distribution requirements? (single region, multi-region, global)
20. What is the expected data volume growth? (e.g., 100GB/month, 1TB/month)

### Additional Context Needed

21. What is the target availability? (99.9%, 99.95%, 99.99%)
22. What is the acceptable error budget? (e.g., 0.1% of requests may fail)
23. How frequently will the API be deployed? (daily, weekly, on-demand)
24. Who consumes this API? (internal teams, external partners, public developers)
25. What is the team size and structure? (affects modularity decisions)

---

## Changelog

- 2026-03-28: Initial architecture assessment -- BLOCKED. Requirements "schnell, sicher, gut skalierbar" rejected as too vague. 25 concrete questions documented that must be answered before characteristics can be established. No architecture decisions can proceed until metrics are provided.
