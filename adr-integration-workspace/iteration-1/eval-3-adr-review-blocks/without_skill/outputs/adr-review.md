# ADR Review: Real-time Collaboration vs. REST-Only Architecture Decision

## Feature Under Review

**Real-time Collaboration** -- Multiple users edit the same document simultaneously, with live cursor positions, instant character-level updates, and conflict resolution (Google Docs-style).

## Existing Architecture Decision

- **Architecture Style:** Service-Based
- **API Protocol:** REST for all inter-service and client-server communication

## Conflict Analysis

### Why REST Cannot Serve This Feature

| Requirement | What REST Provides | What the Feature Needs |
|---|---|---|
| Update latency | Request-response (~100-300ms round-trip) | Sub-50ms push to all connected clients |
| Communication direction | Client-initiated only | Server-initiated push to all participants |
| Connection model | Stateless, short-lived | Persistent, stateful session per editor |
| Data granularity | Resource-level (full document or patch) | Character/operation-level deltas |
| Concurrency awareness | None (last-write-wins at best) | Operational Transformation (OT) or CRDT-based merge |
| Presence information | Requires polling | Continuous broadcast of cursor positions, selections |

REST is fundamentally request-response. Real-time collaboration requires a persistent, bidirectional channel where the server pushes every keystroke delta to every connected client within milliseconds. Polling over REST would generate extreme load and still deliver unacceptable latency (even at 100ms intervals, the user experience degrades noticeably compared to true push).

### Severity: Blocking

This is not a minor tension -- it is a hard architectural incompatibility. The feature **cannot be built to an acceptable quality level** using REST alone. Any attempt to do so (long-polling, aggressive short-polling) results in:

1. **Poor user experience** -- visible lag, cursor jumps, lost keystrokes
2. **Excessive server load** -- thousands of polling requests per document per minute
3. **Complex conflict resolution** -- without a persistent session, the server cannot maintain the OT/CRDT state machine per client

### Impact on Existing Decision

The REST-only decision was likely made assuming request-response workloads (CRUD, queries, commands). Real-time collaboration introduces an entirely different communication pattern that was probably not anticipated when the decision was recorded.

## Conclusion

The existing ADR mandating REST for all APIs must be revisited before this feature can proceed. Proceeding without revisiting it means either:

- Violating the ADR silently (introducing WebSockets without updating governance), or
- Delivering a degraded feature that does not meet user expectations for "real-time."

Neither outcome is acceptable. The ADR should be amended or superseded with a decision that accommodates bidirectional, low-latency communication for specific use cases.
