# Domain Analysis: B2B SaaS Logistik-Plattform

## 1. Identified Bounded Contexts and Subdomain Classification

### 1.1 Route Planning Engine -- CORE Domain

**Subdomain type:** Core

**Rationale:** This is the stated USP of the product. The tour planning engine is what differentiates the company from competitors. It encodes proprietary optimization logic (vehicle routing problem variants, time windows, capacity constraints, driver regulations). Competitive advantage lives here.

**Key domain concepts:**
- Tour (a planned sequence of stops assigned to a vehicle)
- Stop (delivery/pickup location with time window)
- Route (geographic path between stops)
- Vehicle capacity and constraints
- Optimization run / planning horizon
- Driver assignment and shift rules (Lenk- und Ruhezeiten)

**Strategic investment:** Highest. Best engineers, deepest domain modeling, most rigorous testing. This context justifies custom development and should never be replaced by off-the-shelf software.

---

### 1.2 Fleet Telemetry Integration -- SUPPORTING Domain

**Subdomain type:** Supporting

**Rationale:** Real-time GPS and telematics data feeds into the core planning engine (live re-optimization) and into reporting. It requires domain knowledge about device protocols (FMS, OBD-II), data normalization, and handling unreliable connections. It is not the USP, but it enables the USP. Off-the-shelf integration platforms could partially cover this, but the specific needs of the planning engine demand custom adapters.

**Key domain concepts:**
- Telematics device / tracker
- Position event (lat, lng, timestamp, heading, speed)
- Vehicle status (ignition, fuel, mileage)
- Geofence event
- Connection health / data quality

**Strategic investment:** Medium. Build thin adapters, isolate behind an ACL. Consider third-party middleware if integration count grows.

---

### 1.3 Tenant Management -- GENERIC Domain

**Subdomain type:** Generic

**Rationale:** Multi-tenancy is a standard SaaS concern. It involves organization onboarding, user management, role-based access, tenant-level configuration. There is nothing logistics-specific here. Well-understood patterns exist, and identity providers (Auth0, Keycloak) can handle much of it.

**Key domain concepts:**
- Tenant / Organization
- User account and roles
- Subscription plan / feature flags
- Tenant configuration and branding

**Strategic investment:** Low. Use existing identity/access management solutions. Keep the shared kernel minimal to avoid coupling.

---

### 1.4 Billing -- SUPPORTING Domain

**Subdomain type:** Supporting

**Rationale:** The billing model is likely usage-based (tours planned, vehicles managed, API calls) which requires domain-specific metering tied to logistics concepts. It is not purely generic (like Stripe checkout for a simple SaaS) because pricing logic depends on the core domain's units. However, it is not the competitive differentiator.

**Key domain concepts:**
- Billing account (linked to tenant)
- Usage record (tours, vehicles, API calls)
- Pricing plan and tiers
- Invoice and line items
- Payment status

**Strategic investment:** Medium-low. Use a billing provider (Stripe, Chargebee) for payment processing. Build a thin metering layer that translates domain events into usage records.

---

### 1.5 Reporting & Analytics -- SUPPORTING Domain

**Subdomain type:** Supporting

**Rationale:** Logistics companies need operational KPIs (on-time delivery rate, cost per stop, fleet utilization, CO2 emissions). The reports require logistics domain knowledge to be meaningful, so this is not purely generic BI. However, it does not differentiate the product on its own -- the planning engine does.

**Key domain concepts:**
- KPI definition (on-time rate, cost per tour, utilization)
- Report template
- Dashboard / widget
- Data aggregation period
- Export / scheduled delivery

**Strategic investment:** Medium. Consider a hybrid: use a BI tool (Metabase, Redash) for ad-hoc analysis, build custom dashboards for the most valuable logistics-specific KPIs.

---

### 1.6 Customer Portal -- SUPPORTING Domain

**Subdomain type:** Supporting

**Rationale:** The portal lets end customers (the logistics company's clients) track deliveries, view ETAs, and access proof-of-delivery documents. It adds value but is a thin read-model on top of the core planning data. The portal itself does not contain complex business logic.

**Key domain concepts:**
- Shipment tracking view
- ETA and delivery notification
- Proof of delivery (signature, photo)
- Customer self-service (address book, time preferences)

**Strategic investment:** Low-medium. Primarily a UI/UX concern. Consumes the Open Host Service from Route Planning. Can be developed with a small team or even outsourced.

---

## 2. Subdomain Classification Summary

| Bounded Context           | Subdomain Type | Build vs. Buy          | Strategic Priority |
|---------------------------|---------------|------------------------|--------------------|
| Route Planning Engine     | Core          | Build (custom)         | Highest            |
| Fleet Telemetry Integr.   | Supporting    | Build + buy adapters   | Medium             |
| Tenant Management         | Generic       | Buy / reuse            | Low                |
| Billing                   | Supporting    | Buy + thin custom layer| Medium-low         |
| Reporting & Analytics     | Supporting    | Hybrid (BI tool + custom) | Medium          |
| Customer Portal           | Supporting    | Build (thin)           | Low-medium         |

---

## 3. Team Topology Alignment (2 -> 4 Teams)

### Current state (2 teams)
- **Team 1 -- Core Platform:** Route Planning Engine + Fleet Telemetry Integration
- **Team 2 -- SaaS Services:** Tenant Management + Billing + Customer Portal + Reporting

### Target state (4 teams)
- **Team 1 -- Route Planning (stream-aligned):** Owns the core domain exclusively. Highest autonomy, deepest domain expertise. This team should never be distracted by generic concerns.
- **Team 2 -- Fleet & Integration (stream-aligned):** Owns telemetry integration and external system adapters. Provides real-time data to the planning engine. Clear ACL boundary.
- **Team 3 -- Customer Experience (stream-aligned):** Owns Customer Portal and Reporting/Analytics. Both are outward-facing, read-heavy, and benefit from shared UX investment.
- **Team 4 -- Platform (platform team):** Owns Tenant Management, Billing, and cross-cutting infrastructure (CI/CD, observability, shared libraries). Provides self-service capabilities to the other three teams.

### Key principle
The Core domain (Route Planning) gets a dedicated team with full ownership. No shared responsibility for the USP. The bounded context boundaries align with team boundaries to minimize cross-team coordination (Conway's Law).

---

## 4. Risks and Recommendations

1. **Protect the Core domain boundary.** The biggest risk is that tenant management, billing, or portal concerns leak into the Route Planning codebase. Enforce the context boundaries via separate deployable units or at minimum separate modules with explicit APIs.

2. **ACL for telemetry is non-negotiable.** GPS tracker vendors change APIs, add devices, and deprecate protocols. The Anti-Corruption Layer must fully insulate Route Planning from these changes.

3. **Billing metering requires a contract with Route Planning.** Define a Published Language for usage events early. If the metering model changes (e.g., from per-tour to per-stop pricing), both teams need to coordinate -- keep this interface explicit and versioned.

4. **Reporting must not query the core database directly.** Use event-driven data replication (CQRS-style) to populate a read-optimized analytics store. Direct database access creates hidden coupling and performance interference.

5. **Tenant Management as Shared Kernel must stay thin.** Only tenant identity and coarse-grained authorization belong in the shared kernel. Business rules about what a tenant can do belong in the respective bounded contexts.
