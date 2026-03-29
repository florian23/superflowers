# Critical Review: PO Request to Add IoT Support and Reprioritize Characteristics

## Date: 2026-03-28
## Reviewer: Architecture Team
## Context: Healthcare Domain, Public-Facing API

---

## 1. Summary of PO Request

The Product Owner requests:
1. Add IoT device support
2. Drop Performance from Critical priority ("not important anymore")
3. Add Fault Tolerance as new Top Priority

---

## 2. Assessment of Current Architecture Characteristics

The existing architecture (as of 2026-03-15) is built around:

| # | Characteristic | Priority | Rationale |
|---|---------------|----------|-----------|
| 1 | Performance | Critical | API <200ms p95 — public-facing API |
| 2 | Security | Critical | Healthcare PII, GDPR |
| 3 | Testability | Critical | >80% coverage gate |

Supporting characteristics: Availability (99.9%), Modularity, Scalability, Compliance.

---

## 3. Critical Review of Each Proposed Change

### 3.1 "Performance is no longer important"

**Verdict: STRONGLY DISAGREE — This claim is incorrect.**

Reasons:

- **IoT makes performance MORE important, not less.** IoT devices typically have constrained bandwidth, intermittent connectivity, and high message volumes. The system must process telemetry data efficiently. Dropping the <200ms p95 API target would degrade the experience for ALL existing API consumers, not just IoT devices.
- **The existing public-facing API still exists.** The architecture driver "Public-facing API: Performance and availability are user-facing concerns" has not changed. Removing Performance as a priority would be a regression for current users.
- **Healthcare context demands timely data processing.** If IoT devices are health-monitoring devices (likely, given the healthcare domain), delayed processing of vital signs or alerts could have patient safety implications.

**Recommendation:** Keep Performance as Critical. If anything, add specific IoT-related performance targets (e.g., message ingestion throughput, telemetry processing latency).

### 3.2 "Fault Tolerance as Top Priority"

**Verdict: PARTIALLY AGREE — Fault Tolerance is important for IoT, but needs nuance.**

The PO is correct that IoT introduces new failure modes:
- Device disconnections and reconnections
- Unreliable networks (cellular, LoRa, satellite)
- High volume of potentially faulty sensor data
- Need for graceful degradation when devices go offline

However, concerns:

- **Fault Tolerance overlaps with existing Availability (99.9%).** These are related but distinct. We should clarify how Fault Tolerance differs from and complements the existing Availability target.
- **Fault Tolerance needs a concrete, measurable goal.** The PO has not defined what Fault Tolerance means. Without a fitness function, it becomes a vague aspiration. Examples of concrete goals:
  - System continues operating when up to 30% of IoT devices disconnect simultaneously
  - No data loss during network partitions (messages queued and retried)
  - Graceful degradation: core API remains functional even if IoT subsystem is down
- **Adding a 4th Critical characteristic is a red flag.** The current architecture already has 3 Critical characteristics. Architecture theory (e.g., Richards & Ford) warns that more than 3 top priorities means nothing is truly prioritized. Something must give.

**Recommendation:** Add Fault Tolerance as Important (not Critical) initially, with concrete goals and fitness functions. Elevate Availability from Important to Critical instead, as it more directly addresses the resilience concern. If Fault Tolerance must be Critical, one of the existing Critical characteristics must be downgraded.

### 3.3 "Adding IoT support — this changes everything!"

**Verdict: PARTIALLY AGREE — IoT is significant, but "changes everything" is an overstatement.**

What IoT actually changes:
- **New communication protocols** (MQTT, CoAP, AMQP) alongside existing REST API
- **New data ingestion patterns** (event streaming, time-series data)
- **New security surface** (device authentication, firmware updates, physical tampering)
- **New scalability concerns** (potentially thousands of devices, each sending frequent telemetry)

What IoT does NOT change:
- The healthcare domain still requires Security as Critical
- GDPR compliance still applies (IoT health data is still PII)
- The public-facing API still needs Performance
- Testability remains essential (and becomes harder with IoT)

**Recommendation:** IoT is a significant addition that warrants new characteristics and modified priorities, but the existing foundation remains valid.

---

## 4. Proposed Revised Characteristics

Instead of the PO's blanket changes, here is a more balanced proposal:

### Top 3 Priority Characteristics (Revised)
1. **Security** — Critical (UNCHANGED, even more important with IoT device attack surface)
2. **Performance** — Critical (RETAINED, with expanded scope for IoT throughput)
3. **Availability / Fault Tolerance** — Critical (MERGED and ELEVATED from Important)

### Updated Operational Table

| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Performance | Critical | API <200ms p95; IoT ingestion <500ms p95 | Yes - load test (expanded) |
| Availability | Critical | 99.9% uptime; graceful degradation if IoT subsystem fails | Yes - health check + chaos test |
| Fault Tolerance | Critical | No data loss on network partition; system operable with 30% device loss | Yes - chaos engineering test |
| Scalability | Important | Handle 10,000 concurrent devices + 1000 API users | Yes - load test |

### New Cross-Cutting Concerns for IoT

| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Interoperability | Important | Support MQTT 5.0, REST, and at least one additional IoT protocol | Yes - integration test |
| Deployability | Important | OTA firmware update capability for devices | No (needs definition) |

---

## 5. Key Risks and Concerns

1. **Scope creep without validation:** The PO should validate IoT requirements with actual users/stakeholders before making sweeping architecture changes.
2. **Testability becomes harder:** IoT introduces hardware-in-the-loop testing, network simulation, and device emulation challenges. Testability should remain Critical.
3. **Security attack surface expands dramatically:** IoT devices are notoriously vulnerable. Security must remain the top priority, not be displaced by Fault Tolerance.
4. **No fitness functions defined for new characteristics:** Any new characteristic without a measurable fitness function is architectural wishful thinking.
5. **"Changes everything" mindset is dangerous:** Incremental, validated changes to architecture are safer than wholesale rewrites driven by a single new requirement.

---

## 6. Summary and Recommendation

| PO Claim | Assessment | Action |
|----------|-----------|--------|
| "Performance is not important anymore" | **Wrong** — IoT makes performance harder, not irrelevant | Keep Performance as Critical |
| "Fault Tolerance as top priority" | **Partially correct** — important for IoT, but needs concrete definition | Add as Important with fitness functions; merge with elevated Availability |
| "This changes everything" | **Overstated** — significant addition, not a rewrite | Extend architecture incrementally; keep existing foundations |

**Bottom line:** The PO is right that IoT support requires Fault Tolerance, but wrong that Performance can be dropped. The correct response is to ADD characteristics for the IoT context while RETAINING the existing ones that are still driven by valid architecture drivers (healthcare domain, public-facing API). No architecture driver has been removed — so no Critical characteristic should be removed.
