# Context Map

## Last Updated: 2026-03-29

## Subdomains

| Subdomain | Type | Bounded Context(s) |
|---|---|---|
| Tourenplanung (Route Planning) | Core | Route Planning |
| Flotten-Telematik-Integration (Fleet Telematics) | Supporting | Fleet Integration |
| Multi-Tenant-Verwaltung (Tenant Management) | Supporting | Tenant Management |
| Reporting/Analytics | Supporting | Analytics |
| Abrechnungssystem (Billing) | Generic | Billing |
| Kundenportal (Customer Portal) | Supporting | Customer Portal |

## Bounded Contexts

### Route Planning
- **Subdomain:** Core
- **Responsibility:** Optimizes delivery routes based on constraints (time windows, vehicle capacity, driver availability, real-time traffic) — the company's competitive differentiator.
- **Team:** Team 1 (dedicated Core team)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Tour | A planned sequence of stops assigned to one vehicle for one day |
  | Stop | A delivery or pickup location with a time window and service duration |
  | Constraint | A business rule limiting route options (vehicle capacity, driver hours, customer time window) |
  | Optimization Run | A single execution of the planning engine producing a set of tours |
  | Vehicle Profile | Capacity, speed, and cost parameters for a specific vehicle type |
  | Planning Horizon | The time period for which tours are being optimized (typically 1-7 days) |

### Fleet Integration
- **Subdomain:** Supporting
- **Responsibility:** Ingests real-time GPS and telemetry data from fleet tracking devices, normalizes it, and provides vehicle position and status to other contexts.
- **Team:** Team 1 (co-owned with Route Planning)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Telemetry Event | A timestamped GPS position with speed, heading, and vehicle status |
  | Device | A GPS tracker hardware unit installed in a vehicle |
  | Vehicle Position | The last known location and timestamp of a vehicle |
  | Geofence | A geographic boundary that triggers events when a vehicle enters or exits |
  | Provider | An external telematics system supplying raw GPS data (e.g., Webfleet, Samsara) |

### Tenant Management
- **Subdomain:** Supporting
- **Responsibility:** Manages tenant lifecycle (onboarding, configuration, user management, subscription tier) and enforces data isolation across tenants.
- **Team:** Team 2
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Tenant | A logistics company that is a paying customer of the platform |
  | Workspace | The isolated data and configuration space belonging to one tenant |
  | Subscription Tier | The plan level (e.g., Basic, Professional, Enterprise) determining feature access and limits |
  | Tenant Admin | A user with full administrative rights within their tenant |
  | User | A person with login credentials and role-based permissions within a tenant |

### Billing
- **Subdomain:** Generic
- **Responsibility:** Manages subscription billing, invoicing, and payment processing based on tenant subscription tier and usage.
- **Team:** Team 2
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Invoice | A periodic charge document for a tenant based on their subscription and usage |
  | Subscription | The recurring billing agreement tied to a tenant's tier |
  | Usage Record | A metered data point (e.g., number of tours planned) used for billing calculation |
  | Payment Method | The tenant's stored payment instrument (credit card, SEPA direct debit) |

### Analytics
- **Subdomain:** Supporting
- **Responsibility:** Aggregates operational data across contexts to provide dashboards, KPI tracking, and exportable reports for tenant users.
- **Team:** Team 2 (initially), migrates to Team 3 when available
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Report | A predefined or custom data view showing operational KPIs |
  | Dashboard | A real-time visual overview of key metrics for a tenant |
  | KPI | A measurable value indicating operational performance (e.g., tours per day, on-time delivery rate) |
  | Data Export | A downloadable file (CSV, PDF) of report data |

### Customer Portal
- **Subdomain:** Supporting
- **Responsibility:** Provides the tenant's end-customers with shipment tracking, delivery time windows, and communication capabilities.
- **Team:** Team 2 (initially), migrates to Team 4 when available
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Shipment | A delivery from the tenant to their end-customer, with tracking status |
  | Tracking Link | A unique URL allowing an end-customer to see delivery status |
  | Delivery Window | The estimated time range when a delivery will arrive |
  | End-Customer | The recipient of a delivery — NOT the tenant, but the tenant's customer |
  | Notification | A message (email/SMS) sent to an end-customer about delivery status |

## Context Relationships

| Upstream | Downstream | Pattern | Notes |
|---|---|---|---|
| Route Planning | Fleet Integration | Partnership | Both evolve together — real-time positions feed re-optimization, route data feeds ETA calculations. Same team owns both. |
| Route Planning | Analytics | Customer-Supplier | Route Planning publishes tour execution data (planned vs. actual). Analytics consumes for KPI calculation. |
| Route Planning | Customer Portal | Customer-Supplier + Published Language | Route Planning provides ETAs and stop sequences as events. Portal consumes for tracking display. |
| Fleet Integration | Route Planning | Partnership | Bidirectional — live positions trigger re-optimization. Symmetric relationship. |
| Fleet Integration | Analytics | Customer-Supplier | Fleet Integration supplies vehicle utilization and mileage data. |
| Tenant Management | Route Planning | Open Host Service | Tenant config (vehicle fleet, constraints, business rules) provided via API to planning engine. |
| Tenant Management | Billing | Customer-Supplier | Tenant lifecycle events (created, tier changed, deactivated) drive billing actions. |
| Tenant Management | Analytics | Open Host Service | Tenant configuration and user data provided to analytics for scoping and access control. |
| Tenant Management | Customer Portal | Open Host Service | Tenant branding, configuration, and user permissions. |
| External Telematics Providers | Fleet Integration | Anti-Corruption Layer | Each GPS provider has a different API and data model. ACL translates to our normalized telemetry model. |
| External Payment Provider | Billing | Anti-Corruption Layer | Stripe/payment provider models translated at boundary. Keep billing domain clean. |

## Relationship Diagram

```
                    [External Telematics]
                            |
                          (ACL)
                            |
                            v
  [Tenant Management] --OHS--> [Route Planning] <--Partnership--> [Fleet Integration]
        |       |                    |       |                          |
        |       |                    |       |                          |
       C-S     OHS                  C-S    C-S+PL                     C-S
        |       |                    |       |                          |
        v       v                    v       v                          v
    [Billing] [Analytics] <---------+  [Customer Portal] <------------+
        |
      (ACL)
        |
        v
  [External Payment]

  Legend:
    OHS  = Open Host Service
    C-S  = Customer-Supplier
    PL   = Published Language
    ACL  = Anti-Corruption Layer
    <--> = Partnership (symmetric)
```
