# Bounded Context Analysis: E-Commerce Platform

## Input Summary

- **Domain:** E-Commerce Platform
- **Capabilities mentioned:** Product Catalog, Cart/Checkout, Payment, Shipping/Fulfillment, Customer Management, Recommendation System
- **Teams:** 3
- **Target architecture:** Service-Based Architecture

---

## Step 1: Identify Subdomains

The user listed six business areas. Applying the subdomain heuristics:

| # | Subdomain | Reasoning |
|---|-----------|-----------|
| 1 | **Product Catalog** | Distinct business rules around taxonomy, search, product data. Different stakeholders (merchandising). |
| 2 | **Ordering (Cart + Checkout)** | Cart and Checkout are tightly coupled -- cart becomes an order upon checkout. Same business rules, same rate of change, same team would own this. Splitting them would create artificial integration overhead. |
| 3 | **Payment** | Standard payment processing (charge, refund, reconciliation). Could be outsourced to Stripe/Adyen. Different compliance rules (PCI-DSS). |
| 4 | **Shipping & Fulfillment** | Warehouse logistics, pick/pack/ship, tracking. Different stakeholders (operations). Different rate of change from ordering. |
| 5 | **Customer Management** | Customer profiles, preferences, addresses, account lifecycle. Shared across many areas but has its own rules. |
| 6 | **Recommendation System** | ML-driven suggestions, browsing behavior analysis, personalization. Highly specialized, different technology stack, different rate of change. |

Cart and Checkout were grouped into a single "Ordering" subdomain because:
- Cart is a pre-order construct that only exists to become an order
- They share the same domain model (items, prices, discounts)
- They change for the same reasons (new checkout flow, new discount type)
- Splitting them would force constant integration for a single user journey

## Step 2: Classify Subdomains

| Subdomain | Type | Rationale |
|---|---|---|
| Product Catalog | **Core** | Product taxonomy, search relevance, and rich product data directly drive conversion. This is what the customer browses -- if it's bad, they leave. |
| Ordering (Cart + Checkout) | **Core** | The checkout flow is a key differentiator. Cart abandonment rates depend on this. Custom discount logic, promotions, and checkout UX are competitive advantages. |
| Payment | **Generic** | Standard payment processing. Use Stripe, Adyen, or similar. PCI-DSS compliance is a solved problem -- don't reinvent it. Thin integration layer only. |
| Shipping & Fulfillment | **Supporting** | Standard logistics, but requires custom integration with warehouse systems and carriers. Not differentiating, but must be built because off-the-shelf doesn't fit the specific warehouse setup. |
| Customer Management | **Supporting** | Profiles, preferences, address books. Needed by many contexts but not differentiating. Standard CRUD with some business rules around data quality. |
| Recommendation System | **Core** | Personalized recommendations are a competitive advantage. This is what drives cross-sell and upsell. Unique algorithms based on domain-specific data. |

## Step 3: Find Bounded Context Boundaries

### Linguistic Test

- **"Product"** means different things:
  - In Catalog: full product with descriptions, images, taxonomy, variants, pricing rules
  - In Ordering: a line item with SKU, name, quantity, price-at-time-of-order
  - In Fulfillment: a physical item with weight, dimensions, warehouse location
  - In Recommendations: a feature vector with category, tags, purchase history correlation

- **"Customer"** means different things:
  - In Ordering: buyer identity with shipping address and payment method
  - In Customer Management: full profile with preferences, history, account status
  - In Recommendations: a behavioral profile with browsing patterns and purchase history

- **"Order"** means different things:
  - In Ordering: items + payment intent + shipping address + discount codes applied
  - In Fulfillment: pick list + shipping label + tracking number + delivery status
  - In Payment: invoice + charge amount + payment status + refund eligibility

These linguistic splits confirm the boundaries.

### Team Test (3 teams, Conway's Law)

The skill explicitly warns: "If the org has 3 teams, aim for ~3 contexts. Fighting the org chart usually loses."

With 3 teams and 6 subdomains, we need to group contexts pragmatically:

- **Team 1 -- Storefront:** Product Catalog + Recommendation System (both customer-facing discovery, search and recommendations are tightly coupled in the user journey)
- **Team 2 -- Commerce:** Ordering (Cart + Checkout) + Payment (the purchase flow end-to-end, payment is a thin integration layer within ordering)
- **Team 3 -- Operations:** Shipping & Fulfillment + Customer Management (post-purchase operations and customer data management)

### Boundary Decisions

**Decision 1: Keep Cart + Checkout as one context ("Ordering")**
Cart and Checkout are one user journey. Splitting them creates an artificial boundary that forces integration for every cart modification. The ubiquitous language overlaps completely.

**Decision 2: Payment as a separate bounded context despite being on the same team as Ordering**
Payment has different compliance requirements (PCI-DSS), different domain language (charges, refunds, reconciliation vs. carts, orders, discounts), and is largely a wrapper around an external payment provider. It's a logical boundary even if the same team owns it. Keeping it separate means PCI scope is contained.

**Decision 3: Recommendation as a separate bounded context despite being on the same team as Catalog**
Recommendations have a fundamentally different model (behavioral data, ML features) even though they consume catalog data. Different rate of change (ML model retraining vs. catalog updates). Different technology (likely a different runtime/store).

**Decision 4: Customer Management as a separate context**
Customer data is consumed by many contexts but owned in one place. Keeps profile management logic from leaking into Ordering or Fulfillment.

### Final Bounded Contexts (6 contexts, 3 teams)

1. **Catalog Context** (Team 1)
2. **Recommendation Context** (Team 1)
3. **Ordering Context** (Team 2)
4. **Payment Context** (Team 2)
5. **Fulfillment Context** (Team 3)
6. **Customer Context** (Team 3)

## Step 4: Ubiquitous Language

See `context-map.md` for the full language definitions per context.

## Step 5: Map Context Relationships

| Relationship | Pattern | Rationale |
|---|---|---|
| Catalog -> Ordering | **Customer-Supplier** | Catalog supplies product data (name, price, availability). Ordering consumes it. Catalog team accommodates Ordering's data needs. |
| Catalog -> Recommendation | **Partnership** | Same team, closely intertwined. Recommendations need catalog data, catalog search results can incorporate recommendation scores. They evolve together. |
| Ordering -> Fulfillment | **Published Language** | Order-placed events as a defined schema (JSON). Fulfillment subscribes to order events. Clear contract, asynchronous. |
| Ordering -> Payment | **Partnership** | Same team, tightly coupled in the checkout flow. Payment intent is created during checkout. They coordinate closely and release together. |
| Customer -> Ordering | **Open Host Service** | Customer data (profile, addresses) consumed by Ordering and potentially other contexts. Stable API with multiple consumers. |
| Customer -> Fulfillment | **Open Host Service** | Fulfillment needs customer addresses for shipping. Same API as above. |
| Customer -> Recommendation | **Customer-Supplier** | Recommendation consumes customer behavioral data. Customer context supplies preference and history data. |
| Payment -> (External PSP) | **Anti-Corruption Layer** | External payment provider (Stripe/Adyen) has its own model. ACL translates between PSP model and internal payment domain. |
| Fulfillment -> (External Carriers) | **Anti-Corruption Layer** | External shipping carriers (DHL, UPS) have their own APIs. ACL translates carrier models to internal fulfillment domain. |

## Verification Checklist

- [x] Subdomains identified and classified (Core/Supporting/Generic)
- [x] Each bounded context has a clear responsibility (one sentence)
- [x] Ubiquitous language defined per context (key terms with meanings)
- [x] No technical boundaries masquerading as domain boundaries
- [x] Context relationships mapped with explicit patterns
- [x] Anti-Corruption Layer specified for external integrations (PSP, carriers)
- [x] Context count proportional to system complexity (6 contexts for 3 teams -- 2 per team)
- [x] Conway's Law respected (3 teams, contexts grouped by team)
- [x] context-map.md written
