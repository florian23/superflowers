# Context Map

## Last Updated: 2026-03-29

## Subdomains

| Subdomain | Type | Bounded Context(s) |
|---|---|---|
| Product Catalog | Core | Catalog Context |
| Ordering (Cart + Checkout) | Core | Ordering Context |
| Payment | Generic | Payment Context |
| Shipping & Fulfillment | Supporting | Fulfillment Context |
| Customer Management | Supporting | Customer Context |
| Recommendation System | Core | Recommendation Context |

## Bounded Contexts

### Catalog Context
- **Subdomain:** Core
- **Responsibility:** Manages product data, taxonomy, search, pricing rules, and product availability for the storefront.
- **Team:** Team 1 (Storefront)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Product | A sellable item with name, description, images, variants, and pricing rules |
  | Variant | A specific configuration of a product (e.g., size M, color red) with its own SKU and price |
  | Category | A node in the product taxonomy tree used for navigation and filtering |
  | SKU | Stock Keeping Unit -- the unique identifier for a specific variant |
  | Price | The current selling price of a variant, subject to pricing rules and promotions |
  | Availability | Whether a variant is in stock and can be sold (stock count > 0) |

### Ordering Context
- **Subdomain:** Core
- **Responsibility:** Manages the shopping cart, checkout flow, order creation, discount/promotion application, and order lifecycle.
- **Team:** Team 2 (Commerce)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Cart | A mutable collection of items a customer intends to purchase. Becomes an Order at checkout. |
  | Order | A confirmed purchase with line items, applied discounts, shipping address, and payment reference |
  | Line Item | A product variant with quantity and price locked at the time of adding to cart |
  | Checkout | The process of converting a Cart into an Order -- validating items, applying discounts, confirming payment |
  | Discount | A price reduction applied to cart or line items based on promotion rules (coupon code, volume, etc.) |
  | Order Status | The lifecycle state of an order: Created, Paid, Shipped, Delivered, Cancelled |

### Payment Context
- **Subdomain:** Generic
- **Responsibility:** Processes payments, manages refunds, and handles reconciliation with external payment service providers.
- **Team:** Team 2 (Commerce)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Payment Intent | A request to charge a specific amount for an order, before the charge is confirmed |
  | Charge | A confirmed, successful payment transaction against a payment method |
  | Refund | A reversal of a previous charge, full or partial |
  | Payment Method | The instrument used to pay (credit card, PayPal, bank transfer) |
  | Reconciliation | Matching internal payment records against PSP settlement reports |
  | PSP | Payment Service Provider -- the external system processing the actual transaction (Stripe, Adyen) |

### Fulfillment Context
- **Subdomain:** Supporting
- **Responsibility:** Handles warehouse operations (pick, pack, ship), carrier integration, shipment tracking, and delivery confirmation.
- **Team:** Team 3 (Operations)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Shipment | A physical package being sent to a customer, with weight, dimensions, and tracking number |
  | Pick List | The list of items to retrieve from warehouse locations for a given order |
  | Shipping Label | The carrier-generated label with destination address, barcode, and routing info |
  | Tracking Number | The carrier-assigned identifier used to track shipment status |
  | Carrier | The logistics provider transporting the shipment (DHL, UPS, FedEx) |
  | Delivery Status | The shipment lifecycle: Picking, Packed, Shipped, In Transit, Delivered, Returned |

### Customer Context
- **Subdomain:** Supporting
- **Responsibility:** Manages customer profiles, addresses, preferences, account lifecycle, and authentication.
- **Team:** Team 3 (Operations)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Customer | A registered user with a profile, one or more addresses, and account preferences |
  | Profile | The customer's personal data: name, email, phone, communication preferences |
  | Address | A postal address associated with a customer, tagged as shipping or billing |
  | Account Status | The customer's account state: Active, Suspended, Closed |
  | Preference | A customer-defined setting (e.g., preferred language, newsletter opt-in, default address) |

### Recommendation Context
- **Subdomain:** Core
- **Responsibility:** Generates personalized product recommendations based on browsing behavior, purchase history, and product similarity.
- **Team:** Team 1 (Storefront)
- **Ubiquitous Language:**

  | Term | Meaning |
  |---|---|
  | Recommendation | A ranked list of products suggested to a specific customer in a specific context (homepage, PDP, cart) |
  | Behavioral Signal | A customer action that informs recommendations: view, click, add-to-cart, purchase |
  | Product Affinity | A computed score representing how likely a customer is to be interested in a product |
  | Model | The trained ML model that produces recommendation scores |
  | Placement | The UI location where recommendations appear (homepage carousel, "you may also like", post-purchase) |
  | Cold Start | The challenge of recommending products to a new customer with no behavioral history |

## Context Relationships

| Upstream | Downstream | Pattern | Notes |
|---|---|---|---|
| Catalog | Ordering | Customer-Supplier | Catalog provides product data (name, price, availability). Ordering consumes it for cart and checkout. Catalog team prioritizes data needs of Ordering. |
| Catalog | Recommendation | Partnership | Same team. Recommendations need product metadata, catalog search incorporates recommendation scores. Evolve together, joint releases. |
| Ordering | Fulfillment | Published Language | Order-placed events published as versioned JSON schema. Fulfillment subscribes asynchronously. Decoupled deployment. |
| Ordering | Payment | Partnership | Same team. Payment intent created during checkout. Tightly coordinated -- checkout cannot complete without payment confirmation. Joint releases. |
| Customer | Ordering | Open Host Service | Customer context exposes a stable API for profile and address data. Ordering reads customer info at checkout. |
| Customer | Fulfillment | Open Host Service | Fulfillment reads customer shipping addresses via the same Customer API. |
| Customer | Recommendation | Customer-Supplier | Customer context supplies behavioral history and preferences. Recommendation consumes to build personalization models. |
| Payment | External PSP (Stripe/Adyen) | Anti-Corruption Layer | Translates PSP-specific models (Stripe PaymentIntent, Adyen authorisation) into internal Payment domain model. PCI scope contained here. |
| Fulfillment | External Carriers (DHL/UPS) | Anti-Corruption Layer | Translates carrier-specific APIs and tracking models into internal Fulfillment domain model. |

## Relationship Diagram

```
  +--------------------+          +---------------------+
  |   Catalog Context  |--------->|  Ordering Context   |
  |   (Core, Team 1)   | C/S     |  (Core, Team 2)     |
  +--------------------+          +---------------------+
        |  Partnership                   |  Partnership
        v                               v
  +--------------------+          +---------------------+
  | Recommendation Ctx |          |  Payment Context    |---[ACL]---> External PSP
  |  (Core, Team 1)    |          |  (Generic, Team 2)  |
  +--------------------+          +---------------------+
        ^                               ^
        | C/S                           | Pub. Lang.
        |                               |
  +--------------------+          +---------------------+
  | Customer Context   |--------->| Fulfillment Context |---[ACL]---> External Carriers
  | (Supporting, Tm 3) |  OHS    | (Supporting, Team 3)|
  +--------------------+          +---------------------+
        |          OHS                   ^
        +--------------------------------+

  Legend:
    C/S  = Customer-Supplier
    OHS  = Open Host Service
    ACL  = Anti-Corruption Layer
    Pub. Lang. = Published Language
    ---> = direction of data flow (upstream to downstream)
```

## Team Ownership Summary

| Team | Bounded Contexts | Focus |
|---|---|---|
| Team 1 (Storefront) | Catalog, Recommendation | Product discovery and personalization |
| Team 2 (Commerce) | Ordering, Payment | Purchase flow and payment processing |
| Team 3 (Operations) | Fulfillment, Customer | Post-purchase operations and customer data |

## Key Boundary Decisions

1. **Cart + Checkout merged into Ordering Context** -- Cart is a pre-order construct within the same user journey. Splitting them creates artificial integration overhead for no domain benefit.
2. **Payment kept as separate context from Ordering** -- Despite same team, Payment has different compliance requirements (PCI-DSS) and is largely a thin wrapper around an external PSP. Separate context contains PCI scope.
3. **Recommendation kept as separate context from Catalog** -- Different domain model (behavioral data, ML features vs. product master data), different technology stack, different rate of change.
4. **6 contexts for 3 teams (2 per team)** -- Respects Conway's Law while maintaining clean domain boundaries. Each team has a primary (Core/Supporting) and a secondary context.
