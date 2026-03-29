# Resolution Options: ADR-003 Conflict

## The Conflict

ADR-003 mandates REST for all API communication. The real-time collaboration feature requires persistent, bidirectional connections (WebSockets or equivalent) that REST cannot provide.

## Option A: Supersede ADR-003

**New ADR-004: Use REST for service APIs, WebSockets for real-time client communication**

Replace the blanket "REST for all APIs" decision with a protocol-per-concern policy:

- REST remains the default for request-response interactions (CRUD, queries, commands)
- WebSockets are permitted for features requiring real-time bidirectional communication

**What gets easier:**
- Real-time collaboration is built on the right protocol from the start
- Future real-time features (notifications, live dashboards, chat) have a sanctioned path
- Each protocol is used for what it does best

**What gets harder:**
- Two communication protocols to maintain, monitor, and secure
- Client code needs WebSocket connection management alongside REST
- Load balancing and infrastructure must support persistent connections
- ADR-003 status changes to "Superseded by ADR-004"

**Cascade impact:**
- Update "Current Architecture at a Glance" in ADR index
- Check existing feature files and writing-plans for assumptions about REST-only communication
- Update architecture.md if it references ADR-003

**Recommendation: This is the right choice if real-time collaboration is a committed feature.** It is the honest architectural response -- acknowledging that "REST for everything" no longer fits the system's requirements.

## Option B: Narrow the Scope of ADR-003

**New ADR-004: Clarify ADR-003 scope to inter-service communication only**

Reinterpret ADR-003 as applying to service-to-service communication, not client-to-service communication. ADR-003 stays Accepted but its scope is clarified by ADR-004.

- Inter-service communication: REST (per ADR-003)
- Client-to-service communication: protocol chosen per feature need

**What gets easier:**
- ADR-003 is not superseded, reducing cascade impact
- Inter-service REST constraint remains clear and enforced
- Client protocol flexibility without touching existing service integration

**What gets harder:**
- This is arguably revisionist -- ADR-003 says "all API communication", not "inter-service communication"
- Creates ambiguity about what ADR-003 actually covers
- Two ADRs govern API communication, which can confuse future readers

**Recommendation: Use this only if ADR-003 was genuinely intended for inter-service communication and the "all API" wording was imprecise.** If ADR-003 was deliberately broad, this option papers over a real conflict.

## Option C: Find a REST-Compatible Solution

Attempt to deliver collaborative editing without violating ADR-003, using REST-based techniques:

- **HTTP Long Polling:** Client holds open a request; server responds when changes arrive, client immediately re-opens. Simulates push.
- **SSE + REST:** Server-Sent Events for server-to-client push (technically HTTP, arguably REST-adjacent), REST for client-to-server edits.
- **Short Polling:** Client polls for document changes every N milliseconds.

**What gets easier:**
- No ADR changes needed
- Existing infrastructure and tooling unchanged

**What gets harder:**
- Long polling: high connection overhead, unpredictable latency, complex error handling
- SSE + REST: SSE is not REST -- if this is acceptable, Option A is more honest about it
- Short polling: unacceptable latency at reasonable poll intervals, excessive server load with many concurrent editors
- All workarounds add complexity that WebSockets solve natively
- User experience will be measurably worse than competitors using WebSockets

**Recommendation: Do not choose this option.** It forces a technically inferior solution to avoid changing a document. ADRs exist to serve the system, not the other way around. If the system's requirements have changed, the ADRs should change with them.

## Decision Matrix

| Criterion | A: Supersede | B: Narrow Scope | C: REST-Compatible |
|-----------|-------------|-----------------|-------------------|
| Technical fit | Excellent | Good | Poor |
| Architectural honesty | High | Medium | Low |
| Implementation complexity | Medium | Medium | High |
| User experience quality | High | High | Degraded |
| Cascade impact | Moderate | Low | None |
| Future extensibility | High | Medium | Low |

## Recommended Path

**Option A: Supersede ADR-003.** The feature requirement has legitimately changed the system's communication needs. A new ADR-004 that distinguishes request-response from real-time communication is the cleanest, most honest architectural response.

This decision should be made explicitly with the user before brainstorming proceeds. Per the brainstorming skill: "Superseding an ADR is a conscious choice, not a side effect."
