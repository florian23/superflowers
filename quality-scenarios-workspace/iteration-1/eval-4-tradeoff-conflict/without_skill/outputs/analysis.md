# Analysis — Performance vs. Audit-Logging Tradeoff

## The Core Conflict

The architecture demands two things that work against each other:

1. **Performance:** Every API response under 50ms at p95.
2. **Audit completeness:** Every API call logged with user, timestamp, full request payload, and full response payload — no exceptions, no gaps.

Audit logging adds I/O to the hot path. The question is not whether there is a tradeoff, but where and how it manifests.

## How the Scenarios Surface the Tradeoff

### Layer 1: Direct Measurement (QS-1 vs. QS-2 vs. QS-3)

QS-1 establishes a baseline without audit overhead. QS-2 adds synchronous audit logging. QS-3 adds asynchronous audit logging. Running all three under identical load conditions produces a concrete latency delta — the exact cost of audit logging in milliseconds.

If QS-2 passes (sync audit stays under 50ms), the tradeoff is manageable and no compromise is needed. If QS-2 fails but QS-3 passes, the architecture must accept either:
- Async logging with its inherent risk (tested by QS-5), or
- A more complex middle-ground solution (tested by QS-7).

### Layer 2: Failure Mode Exposure (QS-5, QS-6)

QS-5 tests what happens when a node crashes while audit records are still in an async pipeline. In regulated financial services, even a single missing audit record can constitute a compliance violation. This scenario forces the team to answer: "Is the performance gain from async logging worth the regulatory risk?"

QS-6 is the most revealing scenario. When the audit store degrades, the system physically cannot deliver both <50ms latency and complete audit logging. The system's actual behavior under this condition reveals the implicit priority the architecture assigns — regardless of what the requirements document says.

### Layer 3: Compromise Validation (QS-7)

QS-7 tests a practical middle ground: synchronous write to a local write-ahead log (fast, durable, crash-safe) combined with asynchronous replication to the central audit store. This separates "audit record exists" from "audit record is centrally queryable" — potentially satisfying both constraints if the regulatory requirement allows delayed central availability.

## Architectural Decision Points Exposed

| Decision | If performance wins | If audit wins |
|---|---|---|
| Logging mode | Asynchronous (fire-and-forget to queue) | Synchronous (write-through before response) |
| Audit store failure | Circuit-break, continue serving | Block requests, maintain audit trail |
| Crash recovery | Accept potential audit gaps | Accept potential request loss |
| Payload logging | Log reference/hash only (smaller writes) | Log full payload (larger writes, slower) |

## Recommendations for This Architecture

Given the context — financial services, regulatory audit, low-latency trading — the following observations apply:

1. **Synchronous audit logging should be the starting assumption.** Regulatory fines for missing audit records typically dwarf the cost of slightly higher latency. QS-2 should be the first scenario tested. Only if it fails should alternatives be explored.

2. **The local WAL approach (QS-7) is the most promising compromise** if synchronous central writes exceed the latency budget. It provides crash-safe durability without central store latency on the hot path. The team must verify with compliance whether "audit record exists locally, replicated within N seconds" meets the regulatory definition of "logged."

3. **QS-6 should be an automated fitness function** running continuously. The behavior of the system when the audit store degrades is the single most revealing indicator of the architecture's actual priorities. If this behavior changes silently (e.g., after a dependency update or config change), the tradeoff balance shifts without anyone noticing.

4. **Payload size matters.** Full request and response payload logging (as specified) produces significantly more I/O than logging metadata only. The scenarios should be run with realistic payload sizes for the trading API — not synthetic small payloads that hide the real cost.

## Tradeoff Severity Assessment

| Severity | Condition |
|---|---|
| **Low** | QS-2 passes — synchronous audit fits within 50ms budget; no real conflict exists at current load |
| **Medium** | QS-2 fails, QS-7 passes — local WAL compromise works; regulatory acceptance of delayed central availability needed |
| **High** | QS-2 and QS-7 fail, only QS-3 passes — async-only logging meets performance, but audit completeness under crash (QS-5) is at risk |
| **Critical** | QS-2, QS-3, and QS-7 all fail — the 50ms target is not achievable with any form of audit logging; one requirement must be relaxed |
