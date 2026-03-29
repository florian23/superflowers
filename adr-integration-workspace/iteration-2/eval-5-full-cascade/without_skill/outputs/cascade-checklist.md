# Cascade Checklist: ADR-001 (Modular Monolith) -> ADR-006 (Service-Based)

This checklist documents every artifact that must change when superseding ADR-001 with ADR-006.

## Trigger

- **Event:** Team growth from 1 team to 3 teams
- **Decision:** Adopt Service-Based Architecture (ADR-006), superseding Modular Monolith (ADR-001)

---

## 1. ADR Updates

| # | Artifact | Action | Details | Status |
|---|----------|--------|---------|--------|
| 1.1 | ADR-001 | Update status | Change status from "Accepted" to "Superseded by ADR-006" | Required |
| 1.2 | ADR-001 | Add superseded section | Add explicit note explaining why and linking to ADR-006 | Required |
| 1.3 | ADR-006 | Create | New ADR documenting the Service-Based style decision, context, and consequences | Required |
| 1.4 | ADR-006 | Link back | Include "Supersedes: ADR-001" with link | Required |
| 1.5 | ADR index | Update | Add ADR-006 entry; mark ADR-001 as superseded in the index table | Required |

---

## 2. architecture.md Changes

| # | Section | Action | Details |
|---|---------|--------|---------|
| 2.1 | Architecture Style | Rewrite | Change from "Modular Monolith" to "Service-Based Architecture". Update style description, characteristics, and diagrams. |
| 2.2 | Component Diagram | Rewrite | Replace module-in-monolith diagram with service topology showing domain services, BFF, and message bus. |
| 2.3 | Communication Model | Rewrite | Replace "in-process method calls" with "REST (sync) + messaging (async)" patterns. Document service contracts. |
| 2.4 | Data Architecture | Rewrite | Replace "shared database, schema-per-module" with "database-per-service". Document data ownership boundaries. |
| 2.5 | Deployment Model | Rewrite | Replace "single deployable artifact" with "independent deployment per service". Add pipeline-per-service description. |
| 2.6 | Team Topology | Add/Rewrite | Add team-to-service ownership mapping (Bloom, Petal, Root). |
| 2.7 | Technology Constraints | Update | Relax single-runtime constraint. Add service communication technology decisions (REST framework, message broker). |

---

## 3. Fitness Functions Changes

| # | Fitness Function | Action | Details |
|---|-----------------|--------|---------|
| 3.1 | FF-001 (cycle detection) | Update scope | Change from "module cycles" to "service dependency cycles". Update tooling to check service-level dependency graph. |
| 3.2 | FF-002 (API surface) | Retire + Replace | Retire module API surface area metric. Replace with service contract backward compatibility check (OpenAPI diff). |
| 3.3 | FF-003 (build time) | Update scope | Change from "full monolith build < 3 min" to "per-service build < 3 min". Update CI measurement. |
| 3.4 | FF-004 (coupling) | Update metric | Change from module instability metric to shared runtime dependency count. Target: 0 shared dependencies between services. |
| 3.5 | FF-005 (independent deployability) | Add new | New FF: verify each service can deploy without requiring coordination with other services. |
| 3.6 | FF-006 (inter-service latency) | Add new | New FF: P99 inter-service synchronous call latency < 100ms. |
| 3.7 | FF-007 (data ownership) | Add new | New FF: 0 direct cross-service database queries. Detect via static analysis or DB audit. |

**Net change:** 4 updated + 1 retired + 3 new = 7 active fitness functions (up from 4).

---

## 4. Quality Scenarios Changes (quality-scenarios.md)

| # | Scenario | Action | Key Change |
|---|----------|--------|------------|
| 4.1 | QS-001 Deployability | Rewrite | Single artifact -> independent per-service deploy. No cross-team coordination. |
| 4.2 | QS-002 Modifiability | Refine | Module isolation -> service isolation. Add contract versioning as the mechanism. |
| 4.3 | QS-003 Testability | Rewrite | Single test suite -> per-service tests (< 5 min) + contract tests (< 10 min) + E2E (< 20 min). |
| 4.4 | QS-004 Performance | Rewrite | In-process P99 < 5ms -> intra-service < 5ms, inter-service sync < 100ms, async < 500ms. |
| 4.5 | QS-005 Reliability | Rewrite | Single-process reliability -> per-service availability > 99.9% with bulkhead isolation. |
| 4.6 | QS-006 Maintainability | Refine | Single codebase onboarding -> team-scoped onboarding (1 week own services, 2 weeks cross-service). |

**Net change:** 4 rewritten, 2 refined. All 6 scenarios affected.

---

## 5. Index / Registry Update

| # | Artifact | Action | Details |
|---|----------|--------|---------|
| 5.1 | ADR index (e.g., adr/index.md or README) | Update | Add row for ADR-006. Update ADR-001 row to show "Superseded" status. |
| 5.2 | Fitness function registry | Update | Retire FF-002 (old). Update FF-001, FF-003, FF-004 scope. Add FF-005, FF-006, FF-007. |
| 5.3 | Quality scenario index | Update | Flag all 6 scenarios as requiring review/update for service-based style. |

---

## Summary

| Category | Created | Updated | Retired | Total Affected |
|----------|---------|---------|---------|----------------|
| ADRs | 1 (ADR-006) | 1 (ADR-001) | 0 | 2 |
| architecture.md sections | 1 (team topology) | 6 | 0 | 7 |
| Fitness Functions | 3 (FF-005, FF-006, FF-007) | 3 (FF-001, FF-003, FF-004) | 1 (FF-002 old form) | 7 |
| Quality Scenarios | 0 | 6 | 0 | 6 |
| Index entries | 1 | 3 | 0 | 4 |
| **Total** | **5** | **19** | **1** | **26** |

---

## Validation

Before closing this cascade, verify:

- [ ] ADR-001 status reads "Superseded by ADR-006"
- [ ] ADR-006 status reads "Accepted" and links back to ADR-001
- [ ] architecture.md reflects service-based style throughout (no leftover monolith references)
- [ ] All 7 fitness functions documented and measurable
- [ ] All 6 quality scenarios updated with service-based stimulus/response
- [ ] Index/registry entries are consistent with the new state
- [ ] No orphan references to "modular monolith" as the current style remain in living documents
