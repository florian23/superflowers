# ADR Integration Review: Notifications-Service

## Feature Request

Notifications-Service der Push-Notifications an Mobile-Geräte sendet.

## Existing Architecture Decisions

| Decision | Status | Relevance |
|----------|--------|-----------|
| Service-Based Architecture | Adopted | **High** -- The Notifications-Service fits naturally as a dedicated service within the existing service-based architecture. No conflict. |
| PostgreSQL | Adopted | **Medium** -- PostgreSQL can store notification metadata (templates, delivery status, device tokens). However, the primary concern is outbound push delivery, not complex querying. PostgreSQL is sufficient but not the driving factor. |
| REST API | Adopted | **Medium** -- Other services will trigger notifications via a REST endpoint on the Notifications-Service. This aligns with the existing integration pattern. However, an asynchronous channel (message queue) should be evaluated for reliability and decoupling. |

## Impact Assessment

### Alignment

- **Service-Based Architecture**: Fully aligned. A Notifications-Service is a textbook bounded service with clear responsibility -- accepting notification requests and delivering them to mobile devices via platform push channels (APNs, FCM).
- **PostgreSQL**: Compatible. The service needs persistence for device registrations, notification logs, and delivery tracking. PostgreSQL handles this well.
- **REST API**: Partially aligned. Synchronous REST is fine for device registration and status queries. For triggering notifications from other services, an asynchronous mechanism (e.g., message queue) would improve resilience -- but this is an additive decision, not a contradiction.

### Tensions

1. **Synchronous triggering vs. reliability**: If the Notifications-Service is unavailable, a synchronous REST call from the triggering service will fail. A message queue would buffer requests. This tension does not violate the REST API decision but suggests an additional integration pattern may be needed.
2. **External dependency on FCM/APNs**: The service introduces a hard dependency on external push providers. This is inherent to the feature, not a conflict with existing decisions.

## Recommendation

Proceed with the Notifications-Service. No existing decisions need to be revised. One new decision is required:

- **ADR-004**: Document the approach for the Notifications-Service, including the push delivery mechanism and the integration pattern with other services.
