# ADR Review: Real-time Collaboration Feature

## Feature Request

Real-time Collaboration -- multiple users edit the same document simultaneously (Google Docs-style).

## Current Architecture at a Glance

| Aspect | Decision | ADR |
|--------|----------|-----|
| Architecture Style | Service-Based | ADR-001 |
| API Communication | REST for all APIs | ADR-003 |

## ADR Compatibility Assessment

### ADR-001: Use Service-Based architecture -- COMPATIBLE

Real-time collaboration can be implemented as a dedicated service (e.g., `collaboration-service`) within the existing service-based architecture. The service would own real-time session state, cursor positions, and operational transforms (or CRDTs). This is a natural fit -- service-based architecture allows each service to choose internal patterns appropriate to its domain.

**Constraint to observe:** The collaboration service should own its data and communicate with other services through well-defined interfaces, consistent with the service-based approach.

### ADR-003: Use REST for all API communication -- CONFLICT

**This is a blocking conflict.**

REST is a request-response protocol. Real-time collaborative editing requires:

- **Persistent bidirectional connections** -- the server must push changes from User A to User B the instant they occur, without User B polling
- **Sub-second latency** -- collaborative editing feels broken at >200ms round-trip; REST polling at that frequency is wasteful and still introduces jitter
- **Server-initiated messages** -- REST has no mechanism for the server to push to the client without a pending request

The standard protocols for real-time collaboration are:

| Protocol | Fit for Real-time Collab |
|----------|--------------------------|
| WebSockets | Full-duplex, bidirectional, persistent connection. Industry standard for collaborative editing. |
| Server-Sent Events (SSE) | Server-to-client push only. Could work with REST for client-to-server, but adds complexity. |
| HTTP Long Polling | Simulates push over REST. High overhead, poor latency. Not viable for document-level collaboration. |
| REST Polling | Client polls for changes. Unacceptable latency or server load at the frequency needed. |

**Attempting to build Google Docs-style collaboration over pure REST would result in a degraded user experience that fails to meet the core requirement.** This is not a minor gap -- it is a fundamental protocol mismatch.

## Conflict Summary

| ADR | Status | Impact |
|-----|--------|--------|
| ADR-001: Service-Based architecture | Compatible | Collaboration service fits naturally |
| ADR-003: REST for all API communication | **CONFLICT** | REST cannot support real-time bidirectional streaming required for collaborative editing |

## Recommendation

**Do not proceed with brainstorming until ADR-003 is resolved.** Superseding an ADR must be a conscious, deliberate choice -- not a side effect of feature work. The resolution options are documented in `resolution-options.md`.
