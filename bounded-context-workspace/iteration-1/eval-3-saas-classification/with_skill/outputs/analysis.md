# Bounded Context Analysis: B2B SaaS Logistics Platform

## Last Updated: 2026-03-29

## Domain Overview

B2B SaaS platform for logistics companies. Core product is a route planning engine (USP). Supporting capabilities include multi-tenant management, billing, reporting/analytics, fleet telematics integration, and a customer portal. Currently 2 teams, scaling to 4.

## Subdomain Classification

| Subdomain | Type | Rationale |
|---|---|---|
| Tourenplanung (Route Planning) | **Core** | This IS the product. The optimization algorithm is the competitive differentiator — what customers pay for and what no off-the-shelf solution provides. Highest investment, best engineers, most domain expertise required. |
| Flotten-Telematik-Integration (Fleet Telematics) | **Supporting** | Necessary for real-time route optimization (feeds the Core), but the integration itself is not differentiating. Custom-built because each telematics provider has a different API, but the logic is adapter/translation work, not algorithmic innovation. |
| Multi-Tenant-Verwaltung (Tenant Management) | **Supporting** | Essential for SaaS operation but not differentiating. Custom-built because tenant isolation, configuration, and lifecycle management must fit the specific product. No off-the-shelf multi-tenancy solution fits a domain-specific SaaS. |
| Reporting/Analytics | **Supporting** | Customers expect dashboards and KPIs, but the analytics themselves are not the reason they buy the product. Custom-built because the metrics are domain-specific (tour efficiency, on-time rate), but the infrastructure is standard. |
| Abrechnungssystem (Billing) | **Generic** | Subscription billing is a solved problem. Use Stripe, Chargebee, or similar. No competitive advantage in building custom payment processing. Lowest investment — integrate, don't build. |
| Kundenportal (Customer Portal) | **Supporting** | Adds value (tenants can offer their customers tracking), but it's not the core reason tenants choose this platform. Custom-built because it surfaces domain-specific data (ETAs from the planning engine), but the portal patterns are standard. |

## Classification Decisions and Rationale

### Why Route Planning is Core (not Supporting)

The route planning engine is explicitly stated as the USP. This is the algorithm that differentiates the product from competitors. Core domains deserve:
- The best developers assigned to this context
- The most sophisticated architecture (if complexity is warranted)
- The highest test coverage and domain modeling rigor
- Protection from external model contamination (other contexts should not leak their models into route planning)

### Why Fleet Telematics is Supporting (not Core)

While fleet telematics feeds the Core domain and is tightly coupled to route planning, the integration work itself is adapter logic — translating GPS provider APIs into a normalized model. The value comes from what Route Planning DOES with the telemetry data, not from the integration itself. If telematics integration were the USP (e.g., a fleet management platform), it would be Core.

### Why Billing is Generic (not Supporting)

Billing follows standard SaaS subscription patterns. There is no domain-specific billing logic that would justify custom development. The classification as Generic means: use an external provider (Stripe, Chargebee), wrap it with an Anti-Corruption Layer, and invest minimal engineering time. If the business later develops complex usage-based pricing tied to tour optimization metrics, this could be re-evaluated to Supporting.

### Why Customer Portal is Supporting (not Generic)

Although customer portals exist as off-the-shelf products, this portal must display domain-specific data (live ETAs from the planning engine, route-specific tracking). A generic portal solution would require significant customization. Custom-built, but with moderate investment.

## Bounded Context Boundaries

### Key Boundary Decisions

**Route Planning and Fleet Integration are separate contexts despite tight coupling.**
They have different rates of change (fleet integration changes when providers change their APIs; route planning changes when optimization algorithms improve) and different responsibilities. However, they are connected via Partnership because they evolve together and share a team.

**Tenant Management and Billing are separate contexts.**
Tenant lifecycle and billing are distinct concerns. A tenant exists before it is billed. Tenant configuration (vehicle fleet, constraints) has nothing to do with invoicing. Separating them allows Billing to be replaced with an external provider without touching Tenant Management.

**Analytics is its own context, not embedded in Route Planning.**
Analytics consumes data from multiple contexts (Route Planning, Fleet Integration, Tenant Management). It has its own read-optimized data model and different query patterns. Embedding analytics in Route Planning would bloat the Core domain with reporting concerns.

## Team Alignment (Conway's Law)

| Team | Bounded Context(s) | Rationale |
|---|---|---|
| Team 1 (Core) | Route Planning, Fleet Integration | Core domain gets a dedicated team. Fleet Integration is co-owned because it feeds the Core directly. Partnership pattern reflects this. |
| Team 2 (Platform) | Tenant Management, Billing | Platform concerns — multi-tenancy and billing are foundational SaaS infrastructure. |
| Team 3 (future) | Analytics | When the team grows, Analytics gets its own team. Data-intensive work with different skill set (data engineering). |
| Team 4 (future) | Customer Portal | Frontend-heavy, customer-facing. Different skill set and release cadence. |

With 2 teams today, Team 2 temporarily owns Analytics and Customer Portal. As the organization scales to 4 teams, these contexts migrate cleanly because they are already bounded.

## External Integrations

| External System | Integration Pattern | Rationale |
|---|---|---|
| GPS/Telematics Providers (Webfleet, Samsara, etc.) | Anti-Corruption Layer | Each provider has a wildly different API and data model. The ACL normalizes to a single internal telemetry model. New providers are added by writing a new adapter, not changing the domain. |
| Payment Provider (Stripe, etc.) | Anti-Corruption Layer | Payment provider models (charges, subscriptions, webhooks) must not leak into the Billing domain. Translate at the boundary. |

## Risk Assessment

| Risk | Mitigation |
|---|---|
| Route Planning context becomes too large | Monitor for sub-domain emergence. If optimization and scheduling diverge, consider splitting. |
| Fleet Integration coupled too tightly to Route Planning | Partnership is appropriate now (same team). If teams split, evolve to Customer-Supplier with Published Language. |
| Billing as Generic may under-invest | Acceptable. Billing is not differentiating. If complex pricing models emerge, re-classify to Supporting. |
| 6 contexts for 2 teams is too many | Contexts are logical boundaries, not deployment units. Start as modules in a modular monolith. Physical separation happens when teams grow. |

## Verification Checklist

- [x] Subdomains identified and classified (Core/Supporting/Generic)
- [x] Each bounded context has a clear responsibility (one sentence)
- [x] Ubiquitous language defined per context (key terms with meanings)
- [x] No technical boundaries masquerading as domain boundaries
- [x] Context relationships mapped with explicit patterns
- [x] Anti-Corruption Layer specified for external integrations (telematics, payment)
- [x] Context count proportional to system complexity (6 contexts, scaling to 4 teams)
- [x] Team alignment follows Conway's Law
- [x] context-map.md written
