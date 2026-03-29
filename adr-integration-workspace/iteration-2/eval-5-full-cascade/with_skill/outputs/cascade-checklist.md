# Superseding Cascade Checklist: ADR-001 -> ADR-006

Modular Monolith -> Service-Based Architecture

## 1. ADR Changes

- [x] **ADR-001 status updated** to "Superseded by ADR-006"
  - Only the Status line changed. Context, Decision, and Consequences are untouched (immutability rule).

- [x] **ADR-006 created** with status "Accepted"
  - Context references "This supersedes ADR-001 because..." with the reason (team growth from 1 to 3 teams).
  - Alternatives considered: keep modular monolith, microservices, service-based.
  - Consequences include both positive/negative and reference affected fitness functions.

## 2. ADR Index Update

- [ ] **doc/adr/ index** — Update the Index table:
  - ADR-001 status column changed from "Accepted" to "Superseded by ADR-006"
  - ADR-006 row added: "Use Service-Based Architecture | Accepted | [date]"

## 3. "Current Architecture at a Glance" Update

- [ ] **Remove ADR-001 entry** from the "At a Glance" table (superseded ADRs are excluded)
- [ ] **Add ADR-006 entry:**

  | Aspect | Decision | ADR |
  |--------|----------|-----|
  | Architecture Style | Service-Based Architecture | ADR-006 |

## 4. architecture.md: Style Section Replaced

- [ ] **Selected Architecture Style** section updated:
  - Style: Service-Based
  - Partitioning: Domain
  - Cost Category: $$

- [ ] **Selection Rationale** updated:
  - References growth from 1 to 3 teams as the driving context change
  - Notes that driving characteristics (Simplicity, Testability, Maintainability) remain the same but organizational context changed

- [ ] **Tradeoffs Accepted** updated:
  - Simplicity drops from 5/5 to 3/5 — mitigated by coarse-grained services
  - Increased operational overhead — mitigated by keeping services coarse-grained (not microservices)

- [ ] **Evolution Path** updated:
  - "Start with coarse-grained service-based; extract to microservices selectively if a specific service needs independent scaling"

## 5. architecture.md: Old Style Fitness Functions REMOVED

All FFs referencing ADR-001 are identified and removed. This is legitimate per the fitness-functions skill immutability exception: the ADR that justified them has been superseded.

- [ ] **REMOVED:** No circular module dependencies (ADR-001)
- [ ] **REMOVED:** Module boundary enforcement — cross-module via public API only (ADR-001)
- [ ] **REMOVED:** Single deployment artifact — one deployable unit (ADR-001)
- [ ] **REMOVED:** DB schema per module — no cross-module table access (ADR-001)

## 6. architecture.md: New Style Fitness Functions ADDED

New service-based style FFs added, all referencing ADR-006:

- [ ] **ADDED:** No shared database between services — each service owns its datastore exclusively (ADR-006)
- [ ] **ADDED:** No circular service dependencies — Service A calls B, B must not call A (ADR-006)
- [ ] **ADDED:** Service communication via defined API contracts — no direct database access across service boundaries (ADR-006)
- [ ] **ADDED:** Independent deployability — each service deployable without redeploying others (ADR-006)

  | Fitness Function | What it checks | Tool/Approach | ADR |
  |---|---|---|---|
  | No shared database | Each service owns its DB; no cross-service table access | DB config analysis, schema ownership check | ADR-006 |
  | No circular service deps | Service dependency graph is acyclic | Dependency analysis on service call graph | ADR-006 |
  | API contract enforcement | Inter-service communication via versioned API contracts only | Contract testing (Pact or similar) | ADR-006 |
  | Independent deployability | Each service can be deployed without redeploying others | Deployment pipeline verification | ADR-006 |

## 7. quality-scenarios.md: Re-Evaluation Required

6 existing scenarios (3 unit-test, 2 integration-test, 1 manual-review) need review. The architecture style change from monolith to distributed services affects:

### Scenarios Requiring Re-Evaluation

- [ ] **Unit-test scenarios (3):**
  - **Review trigger:** Module boundaries become service boundaries. Unit tests that previously tested cross-module calls within a single process now need to account for service boundaries. Tests may still be valid but their scope definition ("module" vs "service") needs updating.
  - **Likely change:** Test descriptions and scope references updated from "module" to "service". Assertion targets remain similar.

- [ ] **Integration-test scenarios (2):**
  - **Review trigger:** Integration tests that validated in-process module communication now must validate inter-service HTTP/gRPC communication. This is the most impacted category.
  - **Likely change:** Test approach changes significantly. In-process method calls become network calls. Need to add contract tests, handle network failure modes, and test service discovery. May need to split into service-level integration tests + cross-service integration tests.

- [ ] **Manual-review scenario (1):**
  - **Review trigger:** If the manual review covers deployment or module structure, it needs updating for the service-based topology.
  - **Likely change:** Review criteria updated to reflect service boundaries, API contracts, and independent deployability rather than module boundaries.

### New Scenarios to Consider

- [ ] **Service contract compatibility** — When a service API changes, dependent services must not break (contract testing)
- [ ] **Cross-service latency budget** — End-to-end scenarios that previously had in-process latency now have network hops; latency budgets may need adjustment
- [ ] **Independent deployment verification** — Deploying service A does not break services B and C

## 8. Traceability Verification

- [ ] Every removed FF references ADR-001 (superseded) — confirmed
- [ ] Every added FF references ADR-006 (accepted) — confirmed
- [ ] ADR-006 Context explains why ADR-001 was superseded — confirmed (team growth)
- [ ] ADR-001 content (Context, Decision, Consequences) is untouched — confirmed (only Status changed)
- [ ] "At a Glance" reflects only Accepted ADRs — confirmed (ADR-001 removed, ADR-006 added)

## Summary of All Changed Artifacts

| Artifact | Change Type | Details |
|----------|------------|---------|
| ADR-001 | Status update only | "Accepted" -> "Superseded by ADR-006" |
| ADR-006 | New file | "Use Service-Based Architecture" — Accepted |
| doc/adr/ index | Update | ADR-001 status changed, ADR-006 row added |
| "At a Glance" block | Rebuild | ADR-001 entry removed, ADR-006 entry added |
| architecture.md — Style section | Replace | Modular Monolith -> Service-Based |
| architecture.md — Style FFs | Remove + Add | 4 old FFs (ADR-001) removed, 4 new FFs (ADR-006) added |
| quality-scenarios.md | Re-evaluate | All 6 scenarios flagged; integration-test scenarios most affected |
