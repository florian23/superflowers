# Architecture Assessment: PDF Export Feature

## Date: 2026-03-28
## Context: Existing Healthcare Application — New Feature Request

---

## 1. Feature Summary

**PDF Export** allows users to generate and download PDF documents from application data (e.g., patient reports, compliance documents, data exports). This is a common requirement in healthcare systems for regulatory submissions, patient records sharing, and audit trails.

---

## 2. Impact Analysis on Existing Architecture Characteristics

### 2.1 Operational Characteristics

| Characteristic | Current Priority | Impact | Risk Level | Notes |
|---|---|---|---|---|
| Performance | Critical (API <200ms p95) | **High** | **High** | PDF generation is CPU-intensive and time-consuming. A synchronous PDF generation endpoint will likely violate the <200ms p95 target. Large documents with images or charts can take seconds to render. |
| Availability | Important (99.9% uptime) | **Medium** | **Medium** | Heavy PDF generation under load could exhaust server resources (CPU, memory), degrading availability for other endpoints. |
| Scalability | Nice-to-have (1000 concurrent) | **Medium** | **Medium** | Concurrent PDF generation is resource-heavy. 1000 concurrent users requesting PDFs simultaneously could overwhelm the system without dedicated infrastructure. |

### 2.2 Structural Characteristics

| Characteristic | Current Priority | Impact | Risk Level | Notes |
|---|---|---|---|---|
| Testability | Critical (>80% coverage) | **Medium** | **Low** | PDF output is binary, making assertion-based testing harder. Requires strategy for testing (e.g., text extraction from generated PDFs, snapshot testing, visual regression). |
| Modularity | Important (no circular deps) | **Low** | **Low** | PDF export should be a self-contained module. If properly encapsulated, minimal impact on modularity. Risk increases if PDF logic is scattered across existing modules. |

### 2.3 Cross-Cutting Characteristics

| Characteristic | Current Priority | Impact | Risk Level | Notes |
|---|---|---|---|---|
| Security | Critical (No CVEs, PII encrypted) | **High** | **High** | PDFs will contain PII (healthcare data). Generated PDFs must be encrypted or access-controlled. Temporary files on disk during generation are a PII exposure risk. The PDF library itself introduces new dependency surface for CVEs. |
| Compliance | Important (GDPR) | **High** | **High** | Generated PDFs containing patient data are subject to GDPR. Must ensure right-to-erasure covers generated PDFs. Audit logging of who generated what PDF and when is likely required. |

---

## 3. Architecture Recommendations

### 3.1 Performance: Asynchronous Generation Pattern

**Problem:** Synchronous PDF generation will break the <200ms p95 API target.

**Recommendation:** Implement PDF export as an asynchronous operation:
1. API endpoint accepts export request and returns a job ID immediately (<200ms).
2. PDF generation runs in a background worker/queue.
3. Client polls for completion or receives a webhook/notification.
4. Completed PDF is served from object storage via a download endpoint.

**Fitness Function:** Existing load test must be extended to include PDF request submission (not generation) to ensure the request-acceptance path stays under 200ms.

### 3.2 Security: PII Protection in Generated Documents

**Problem:** PDFs containing healthcare PII create new attack surface.

**Recommendations:**
- Generated PDFs must be stored encrypted at rest (consistent with existing PII encryption policy).
- Temporary files during generation must be written to an encrypted volume or kept in-memory only.
- PDF download endpoints must enforce authentication and authorization (user can only download their own exports).
- PDF library dependency must be vetted for known CVEs and added to the vulnerability scanning pipeline.
- Consider PDF-level encryption/password protection for sensitive exports.

**Fitness Function:** Extend existing vulnerability scan to cover new PDF library dependencies. Add authorization test for PDF download endpoints.

### 3.3 Compliance: GDPR and Audit Trail

**Problem:** Generated PDFs are personal data under GDPR.

**Recommendations:**
- Implement retention policy for generated PDFs (auto-delete after configurable period).
- Include PDF artifacts in data deletion workflows (right-to-erasure).
- Log all PDF generation events (who, what data, when) for audit trail.
- Ensure data minimization: only include necessary data in exports.

**Fitness Function (new):** Automated check that generated PDFs are covered by the data retention/deletion pipeline.

### 3.4 Availability: Resource Isolation

**Problem:** PDF generation under load can starve other services of resources.

**Recommendations:**
- Run PDF generation workers in a separate process/container with resource limits (CPU, memory caps).
- Implement rate limiting on PDF export requests per user.
- Add a queue with bounded capacity to prevent overload.

**Fitness Function:** Health check should monitor PDF worker independently. Alert if queue depth exceeds threshold.

### 3.5 Testability: PDF Output Verification

**Problem:** Binary PDF output is harder to test than JSON API responses.

**Recommendations:**
- Use a PDF text extraction library in tests to assert content correctness.
- Separate concerns: test data assembly logic independently from PDF rendering.
- Use template-based PDF generation so templates can be visually reviewed.

**Fitness Function:** Coverage gate remains at >80%. PDF module must meet the same threshold.

---

## 4. New/Modified Architecture Characteristics

| Characteristic | Change | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|---|
| Performance | Modified | Critical | PDF request acceptance <200ms p95; PDF generation <30s p95 | Load test (extended) |
| Security | Modified | Critical | PDF library CVE-free; generated PDFs encrypted at rest; authorized access only | Vulnerability scan (extended) + auth tests |
| Compliance | Modified | Important | Generated PDFs covered by GDPR deletion; audit log for all exports | Retention pipeline check (new) |
| Availability | No change | Important | 99.9% uptime (PDF workers isolated) | Health check (extended) |

---

## 5. Proposed Architecture Changelog Entry

```
- 2026-03-28: Architecture assessment for PDF Export feature
  - Performance: Async generation pattern required to preserve <200ms API target
  - Security: PDF library vetting, encrypted storage, authorized download
  - Compliance: PDF retention policy, GDPR deletion coverage, audit logging
  - New fitness function: data retention pipeline check for generated PDFs
```

---

## 6. Risk Summary

| Risk | Severity | Mitigation |
|---|---|---|
| PDF generation breaks API performance SLA | High | Async pattern with job queue |
| PII leakage via generated PDFs or temp files | High | Encryption at rest, in-memory generation, auth on downloads |
| New PDF library introduces CVEs | Medium | Dependency vetting, automated vulnerability scanning |
| GDPR non-compliance for generated documents | High | Retention policy, deletion workflow integration, audit logging |
| Resource exhaustion under concurrent PDF load | Medium | Isolated workers, rate limiting, queue bounds |

---

## 7. Decision Required

Before implementation, the team should decide:

1. **Sync vs. Async:** Confirm async pattern is acceptable for UX (users wait for PDF instead of instant download).
2. **PDF Library Choice:** Evaluate options (e.g., wkhtmltopdf, Puppeteer/headless Chrome, Apache PDFBox, WeasyPrint) against CVE history and maintenance status.
3. **Storage:** Where to store generated PDFs (object storage like S3 with encryption, or ephemeral with short TTL).
4. **Retention Period:** How long generated PDFs are kept before auto-deletion (GDPR data minimization).
