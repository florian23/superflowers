# Architecture Characteristics Questionnaire

Based on Neal Ford & Mark Richards' "Fundamentals of Software Architecture" methodology.

## How to Use

Walk through each category with the user. Ask ONE question at a time. For each characteristic rated "critical" or "important", follow up with a concrete goal.

## Operational Characteristics

### Availability
> "How critical is system availability? Can users tolerate planned or unplanned downtime?"
- **Critical:** 99.99% uptime (< 52 min/year downtime)
- **Important:** 99.9% uptime (< 8.7 hours/year)
- **Nice-to-have:** 99% uptime (< 87.6 hours/year)
- **Irrelevant:** No specific uptime requirements

Follow-up: "What are the peak usage windows? Is downtime acceptable during off-hours?"

### Performance
> "What are the response time expectations? Are there specific latency or throughput requirements?"
- **Critical:** p95 < 100ms, high throughput
- **Important:** p95 < 500ms, moderate throughput
- **Nice-to-have:** p95 < 2s
- **Irrelevant:** No specific performance targets

Follow-up: "What operations are performance-sensitive? API calls, page loads, batch processing?"

### Scalability
> "How many users or requests must the system handle? What growth is expected?"
- **Critical:** Must scale to 10x current load within minutes
- **Important:** Must handle steady growth, planned scaling
- **Nice-to-have:** Can handle moderate load increases
- **Irrelevant:** Single-user or fixed-load system

Follow-up: "Horizontal scaling (more instances) or vertical (bigger machines)? Elastic or planned?"

### Reliability
> "What happens when things fail? How quickly must the system recover?"
- **Critical:** Zero data loss, automatic recovery < 1 min
- **Important:** Minimal data loss acceptable, recovery < 15 min
- **Nice-to-have:** Manual recovery acceptable
- **Irrelevant:** Failures are tolerable

Follow-up: "What is the recovery point objective (RPO)? Recovery time objective (RTO)?"

### Fault Tolerance
> "Must the system continue operating during partial failures?"
- **Critical:** Graceful degradation required, no single point of failure
- **Important:** Core functionality must survive component failures
- **Nice-to-have:** Best-effort during failures
- **Irrelevant:** Full outage acceptable during failures

Follow-up: "Which components are most critical? What can degrade gracefully?"

## Structural Characteristics

### Modularity
> "How important is clean separation of concerns and component boundaries?"
- **Critical:** Strict module boundaries, independent deployment
- **Important:** Clear separation, shared deployment acceptable
- **Nice-to-have:** Reasonable structure
- **Irrelevant:** Monolithic is fine

Follow-up: "Are different teams responsible for different parts? Will components be independently versioned?"

### Extensibility
> "How often will new features be added? By whom?"
- **Critical:** Plugin architecture, third-party extensions, frequent additions
- **Important:** Regular feature additions by the core team
- **Nice-to-have:** Occasional additions
- **Irrelevant:** Feature set is largely fixed

Follow-up: "What types of extensions are expected? New integrations, new UI components, new data sources?"

### Testability
> "What level of automated testing is required?"
- **Critical:** >90% coverage, all paths tested, CI gate
- **Important:** >80% coverage, critical paths tested
- **Nice-to-have:** Basic test coverage
- **Irrelevant:** Manual testing sufficient

Follow-up: "Unit, integration, E2E — which levels matter most? Is TDD mandated?"

### Deployability
> "How often and how easily must the system be deployed?"
- **Critical:** Multiple deploys per day, zero-downtime, automated
- **Important:** Weekly deploys, brief maintenance windows acceptable
- **Nice-to-have:** Monthly releases
- **Irrelevant:** Infrequent, manual deployment acceptable

Follow-up: "Blue/green? Rolling? Canary? Rollback requirements?"

### Coupling
> "What external systems does this integrate with? How tightly?"
- **Critical:** Many integrations, loose coupling essential
- **Important:** Some integrations, well-defined interfaces
- **Nice-to-have:** Few integrations
- **Irrelevant:** Standalone system

Follow-up: "Synchronous or asynchronous communication? Message queues, REST, gRPC?"

## Cross-Cutting Characteristics

### Security
> "What data does the system handle? What are the authentication/authorization requirements?"
- **Critical:** PII, financial data, healthcare data, compliance-driven
- **Important:** User accounts, business data
- **Nice-to-have:** Basic authentication
- **Irrelevant:** Public data, no auth needed

Follow-up: "Encryption at rest and in transit? SSO? RBAC? Audit logging?"

### Compliance
> "Are there regulatory requirements (GDPR, HIPAA, SOC2, PCI-DSS)?"
- **Critical:** Multiple regulations, audit requirements
- **Important:** Single regulation, documentation needed
- **Nice-to-have:** Best-practice compliance
- **Irrelevant:** No regulatory requirements

Follow-up: "Which specific regulations? Data residency requirements? Retention policies?"

### Accessibility
> "Who are the end users? Are there accessibility requirements (WCAG)?"
- **Critical:** WCAG 2.1 AA required, public-facing
- **Important:** Basic accessibility for diverse users
- **Nice-to-have:** Reasonable accessibility
- **Irrelevant:** Internal tool, known user base

### Usability
> "Who are the users? What is their technical sophistication?"
- **Critical:** Non-technical users, consumer-facing, UX-driven
- **Important:** Mixed audience, clear UI needed
- **Nice-to-have:** Developer-facing, CLI acceptable
- **Irrelevant:** API-only, no direct users

### Observability
> "What logging, monitoring, and tracing requirements exist?"
- **Critical:** Full distributed tracing, real-time dashboards, alerting
- **Important:** Structured logging, basic monitoring
- **Nice-to-have:** Application logs
- **Irrelevant:** Minimal logging

Follow-up: "Specific tools required (Datadog, Grafana, CloudWatch)? SLA on alert response?"

## Top-3 Prioritization

After collecting all characteristics, present the critical and important ones:

> "Every architecture characteristic adds complexity and constrains design choices. From your critical and important characteristics, which are your TOP 3 — the ones that should drive architecture decisions above all others?"

Present as a numbered list for the user to select from. The top 3 become the primary architecture drivers documented in architecture.md.

Remind the user: "Supporting more than 3 primary characteristics significantly increases architecture complexity. Fewer is better."
