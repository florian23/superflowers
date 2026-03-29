# Step 0: ADR Review

## Current Architecture at a Glance

| Aspect | Decision | ADR |
|--------|----------|-----|
| Architecture Style | Service-Based | ADR-001 |
| Persistence | PostgreSQL | ADR-002 |
| API Communication | REST | ADR-003 |

## Feature Under Consideration

Notifications-Service der Push-Notifications an Mobile-Geraete sendet.

## ADR Compatibility Assessment

### ADR-001: Use Service-Based architecture — COMPATIBLE

The new Notifications-Service fits naturally into the Service-Based architecture. Service-Based architecture is designed for independently deployable services with their own logic and data. Adding a new Notification-Service is a standard extension of this style — no structural conflict.

**Constraint noted:** The Notification-Service should be deployed as a separate service within the existing service-based topology. It communicates with other services through the established API layer, not through direct database access or shared libraries.

### ADR-002: Use PostgreSQL for persistence — COMPATIBLE

The Notification-Service will need to persist notification state (delivery status, user preferences, device tokens). PostgreSQL is suitable for this. The service gets its own schema or database instance, consistent with the service-based approach of owned data.

**Constraint noted:** The Notification-Service stores its data in PostgreSQL, following the same persistence strategy as existing services.

### ADR-003: Use REST for API communication — COMPATIBLE

Other services will trigger notifications by calling the Notification-Service's REST API. REST is adequate for fire-and-trigger notification requests (e.g., POST /notifications). The actual push delivery to mobile devices happens via external provider SDKs (APNs, FCM), which is outside the scope of inter-service communication.

**Constraint noted:** Inter-service communication with the Notification-Service uses REST endpoints. The push delivery to mobile devices via FCM/APNs is an external integration, not governed by this ADR.

## Conflicts Identified

None. All three active ADRs are compatible with the proposed feature.

## Recommendation

Proceed with adding the Notification-Service within the existing Service-Based architecture. No ADRs need to be superseded. A new ADR-004 should document the decision to introduce the Notification-Service and the approach chosen for push delivery.
