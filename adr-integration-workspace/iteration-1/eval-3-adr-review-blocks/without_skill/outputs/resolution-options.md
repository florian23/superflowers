# Resolution Options: REST-Only Constraint vs. Real-time Collaboration

## Option 1: Amend ADR -- Add WebSocket Exception for Real-time Features

**Description:** Keep REST as the default protocol for all standard APIs. Add an explicit exception: features requiring bidirectional, low-latency communication (real-time collaboration, live notifications) may use WebSockets.

**How it works:**
- The collaboration service exposes a WebSocket endpoint (`wss://`) for document editing sessions
- REST endpoints remain for document CRUD (create, list, delete, load initial state)
- The WebSocket channel carries OT/CRDT operations, cursor positions, and presence data
- All other services continue using REST exclusively

**Trade-offs:**
- (+) Solves the problem cleanly with the right tool
- (+) Minimal disruption -- only one service gains a WebSocket endpoint
- (+) Well-understood pattern (Google Docs, Figma, Miro all use this split)
- (-) Introduces a second protocol to operate, monitor, and secure
- (-) WebSocket connections are stateful -- load balancing requires sticky sessions or a pub/sub layer (Redis, NATS)
- (-) Team needs WebSocket expertise

**Recommendation: Preferred.** This is the industry-standard approach for exactly this problem.

---

## Option 2: Server-Sent Events (SSE) + REST POST

**Description:** Use SSE for server-to-client push and REST POST for client-to-server operations. Avoids introducing a fully bidirectional protocol.

**How it works:**
- Client opens an SSE connection to receive all document deltas, cursor positions, and presence events
- Client sends its own edits via REST POST to a `/operations` endpoint
- Server fans out received operations to all other SSE subscribers

**Trade-offs:**
- (+) Stays closer to HTTP -- SSE is just a long-lived HTTP response
- (+) Easier to load-balance than WebSockets (no upgrade handshake)
- (+) Can argue it is still "REST" in spirit (HTTP-based, resource-oriented)
- (-) Half-duplex: client-to-server path is still request-response, adding latency on the send side
- (-) SSE is text-only (no binary frames), slightly higher overhead for high-frequency small payloads
- (-) At very high edit rates (fast typing by multiple users), the POST overhead becomes noticeable
- (-) Reconnection logic for SSE can be fragile under poor network conditions

**Recommendation: Acceptable compromise** if the team strongly resists WebSockets, but expect a measurably worse editing experience under concurrent heavy use.

---

## Option 3: Use a Managed Real-time Service (Firebase, Liveblocks, Yjs + y-websocket)

**Description:** Delegate the real-time collaboration problem entirely to a purpose-built service or library, keeping the project's own APIs REST-only.

**How it works:**
- Document editing sessions are managed by an external real-time engine (e.g., Liveblocks, or a self-hosted Yjs server)
- The project's collaboration service handles only metadata, permissions, and persistence via REST
- The client connects to the external real-time engine directly for editing, and to the project's REST APIs for everything else

**Trade-offs:**
- (+) The REST-only ADR remains technically unviolated for the project's own services
- (+) Battle-tested CRDT implementations out of the box (Yjs, Automerge)
- (+) Fastest path to a working prototype
- (-) Introduces an external dependency for a core feature
- (-) Data residency and compliance concerns (if using a SaaS provider)
- (-) Operational complexity shifts rather than disappears
- (-) Cost scales with concurrent editing sessions

**Recommendation: Strong option for speed-to-market**, but the team must accept an external dependency on a critical path.

---

## Option 4: Reject the Feature as Architecturally Incompatible

**Description:** Acknowledge that the current architecture does not support real-time collaboration and decline to build it until a broader architectural evolution is planned.

**How it works:**
- Document the incompatibility formally
- Offer a reduced-scope alternative (e.g., turn-based editing with locking, or periodic auto-merge)
- Revisit when the architecture roadmap includes event-driven or streaming capabilities

**Trade-offs:**
- (+) Preserves architectural consistency
- (+) Avoids rushing a protocol change that may be poorly integrated
- (-) Feature is not delivered -- business stakeholders may not accept this
- (-) A reduced-scope alternative (document locking) is a fundamentally different and inferior product experience

**Recommendation: Last resort.** Only appropriate if the business priority for real-time collaboration is genuinely low.

---

## Decision Matrix

| Criterion | Option 1 (WS Exception) | Option 2 (SSE+POST) | Option 3 (Managed Service) | Option 4 (Reject) |
|---|---|---|---|---|
| User experience quality | High | Medium | High | Low |
| Architectural consistency | Medium | Medium-High | High | High |
| Implementation complexity | Medium | Medium | Low-Medium | None |
| Operational complexity | Medium | Low-Medium | Medium | None |
| Long-term scalability | High | Medium | Depends on provider | N/A |
| Team skill requirements | WebSocket ops | Minimal new skills | Vendor-specific SDK | None |

## Recommended Path

**Option 1** -- amend the ADR to permit WebSockets for explicitly identified real-time use cases. This is the most honest resolution: it acknowledges that REST-only was the right default but that one specific communication pattern requires a different tool. The amended ADR should:

1. State the original rationale for REST-only (simplicity, uniformity, tooling)
2. Identify the class of requirements REST cannot serve (bidirectional, sub-100ms, server-push)
3. Permit WebSockets exclusively for those cases, with mandatory review before each new WebSocket endpoint
4. Require that all non-real-time communication remains REST
