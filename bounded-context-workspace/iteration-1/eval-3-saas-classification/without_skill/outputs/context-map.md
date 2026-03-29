# Context Map: B2B SaaS Logistik-Plattform

## Bounded Contexts

```
+---------------------------------------------------------------------+
|                                                                     |
|  +---------------------+        +---------------------+            |
|  |   Route Planning    |        |  Fleet Telemetry    |            |
|  |     (Core)          |------->|   Integration       |            |
|  |                     |  ACL   |   (Supporting)      |            |
|  +---------------------+        +---------------------+            |
|         |        |                       |                          |
|         |        |                       |                          |
|         | OHS    | PUB                   |                          |
|         |        |                       |                          |
|         v        v                       |                          |
|  +-------------+ +---------------------+|                          |
|  |  Customer   | |    Reporting &      ||                          |
|  |   Portal    | |    Analytics        |<-----------+              |
|  | (Supporting)| |   (Supporting)      |            |              |
|  +-------------+ +---------------------+            |              |
|         |                    ^                       |              |
|         |                    |                       |              |
|         |                    |                       |              |
|  +---------------------+    |          +---------------------+     |
|  |   Tenant            |    |          |    Billing          |     |
|  |   Management        |----+          |    (Supporting)     |     |
|  |   (Generic)         |               |                     |     |
|  +---------------------+               +---------------------+     |
|                                                                     |
+---------------------------------------------------------------------+
```

## Relationships

| Upstream              | Downstream            | Relationship Pattern         |
|-----------------------|-----------------------|------------------------------|
| Route Planning        | Customer Portal       | Open Host Service (OHS)      |
| Route Planning        | Reporting & Analytics | Published Language (PUB)     |
| Fleet Telemetry Int.  | Route Planning        | Anti-Corruption Layer (ACL)  |
| Fleet Telemetry Int.  | Reporting & Analytics | Conformist                   |
| Tenant Management     | All other contexts    | Shared Kernel                |
| Billing               | Reporting & Analytics | Conformist                   |
| Route Planning        | Billing               | Customer-Supplier            |

## Relationship Details

### Route Planning <-> Fleet Telemetry Integration (ACL)
The Route Planning context consumes real-time GPS data from external telematics providers. An Anti-Corruption Layer translates external device protocols and data models into the route planning domain model. This protects the core domain from instability in third-party APIs.

### Route Planning -> Customer Portal (OHS)
Route Planning exposes a stable API (Open Host Service) that the Customer Portal consumes to display tour status, ETAs, and route details to end customers. The portal has no influence on the core model.

### Route Planning -> Reporting & Analytics (PUB)
Route Planning publishes domain events (tour completed, delay detected, route optimized) in a well-defined Published Language. Reporting subscribes to these events for aggregation and analysis.

### Tenant Management -> All Contexts (Shared Kernel)
Tenant identity, organization structure, and access policies form a thin shared kernel consumed by every bounded context for authorization and data isolation.

### Route Planning -> Billing (Customer-Supplier)
Billing depends on usage data from Route Planning (tours planned, vehicles dispatched) to calculate charges. Route Planning is the supplier; Billing is the customer that negotiates what data it needs.

### Fleet Telemetry Integration -> Reporting & Analytics (Conformist)
Reporting conforms to the telemetry data model for fleet utilization dashboards. No translation -- it uses the integration context's model directly.
