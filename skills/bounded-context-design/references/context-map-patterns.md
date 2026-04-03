# Context Map Relationship Patterns

Detailed guide for each DDD context map relationship pattern.
Based on Eric Evans "Domain-Driven Design" and Vaughn Vernon "Implementing Domain-Driven Design".

## Partnership

**Relationship:** Symmetric — both teams coordinate closely.

**When to use:** Two bounded contexts that evolve together. Changes in one often require changes in the other. Teams are willing and able to synchronize.

**Example:** Checkout and Payment in an early-stage startup where the same team builds both and they change together with every new payment method.

**Implementation:** Shared planning, joint releases, direct communication between teams. No formal API contract — they evolve together.

**Warning:** Only works with high trust and close proximity. Falls apart when teams grow or become remote. Consider evolving to Customer-Supplier when coordination cost rises.

## Shared Kernel

**Relationship:** Symmetric — both teams share a small, well-defined subset of the model.

**When to use:** Two contexts need to share a small core model (e.g., Money value object, common events). The shared part is small, stable, and both teams agree on changes.

**Example:** All contexts share a `Money` value object and a `Currency` enum. Changes require agreement from both teams.

**Implementation:** Shared library or package. Changes require approval from all consuming teams. Automated tests verify the contract.

**Warning:** The shared kernel must stay SMALL. If it grows, you're building a distributed monolith. Measure: if more than ~5% of each context's model is shared, the kernel is too big.

## Customer-Supplier

**Relationship:** Upstream (supplier) provides, downstream (customer) consumes.

**When to use:** One context clearly serves another. The upstream team acknowledges the downstream team's needs and accommodates them in planning.

**Example:** Catalog (upstream) provides product data to Checkout (downstream). Catalog team prioritizes API changes that Checkout needs.

**Implementation:** Upstream exposes an API. Downstream specifies what it needs (consumer-driven contracts). Upstream accommodates within reason.

**Warning:** Only works if the upstream team is willing to listen. If they ignore downstream needs, this degrades to Conformist.

## Conformist

**Relationship:** Downstream conforms to upstream's model.

**When to use:** Downstream has no influence on upstream. The upstream model is imposed (e.g., third-party API, legacy system, regulated interface).

**Example:** Your system consumes a government tax API. You have zero influence on their data model — you conform to whatever they provide.

**Implementation:** Map the upstream model directly into your code. No translation layer. Accept the upstream's model as-is.

**Warning:** Only use when the upstream model is close enough to your domain that conforming doesn't corrupt your model. If it does — use Anti-Corruption Layer instead.

## Anti-Corruption Layer (ACL)

**Relationship:** Downstream protects itself from upstream's model.

**When to use:** The upstream model is different enough from your domain that using it directly would corrupt your domain model. Common when integrating with legacy systems, external APIs, or poorly-designed upstream contexts.

**Example:** Legacy ERP system uses "Material Number" where your domain uses "Product SKU". The ACL translates between the two models at the boundary.

**Implementation:** A translation layer (adapter/facade) that converts between the upstream model and your domain model. The rest of your code never sees the upstream model.

**When to use for legacy:** This is the DEFAULT pattern for legacy integration. Always protect new bounded contexts from legacy data models.

## Open Host Service (OHS)

**Relationship:** Upstream exposes a well-defined public API for multiple consumers.

**When to use:** Multiple downstream contexts need to consume from the same upstream. The upstream defines a stable, versioned API.

**Example:** User Profile bounded context exposes a REST API consumed by Checkout, Fulfillment, and Analytics.

**Implementation:** Versioned API (REST, gRPC, GraphQL). API documentation. Backward compatibility guarantees. Often combined with Published Language.

## Published Language

**Relationship:** Standard interchange format shared between contexts.

**When to use:** Multiple contexts need to exchange data in a well-defined, technology-agnostic format.

**Example:** Order events published as JSON Schema or Protobuf messages. Any context can consume them without coupling to the producer's internal model.

**Implementation:** Schema registry (Avro, Protobuf, JSON Schema). Event catalog. Versioned schemas with backward compatibility.

**Often combined with:** Open Host Service (API + schema) or event-driven architecture (events + schema).

## Separate Ways

**Relationship:** No integration — contexts are completely independent.

**When to use:** Two contexts have no meaningful data flow between them. They can be built, deployed, and evolved independently.

**Example:** Marketing website CMS and internal HR tool. They share a company name but nothing else.

**Implementation:** Nothing to implement — that's the point. No shared code, no shared data, no integration.

**Warning:** Make sure "no integration" is truly correct. If users need to log in to both systems, there's at least an Auth integration needed.

## Choosing the Right Pattern

```
Does the upstream model match your domain?
  → Yes, closely enough: Conformist
  → No, too different: Anti-Corruption Layer

Do you have influence on the upstream?
  → Yes: Customer-Supplier
  → No: Conformist or ACL

Do multiple consumers need the same upstream?
  → Yes: Open Host Service + Published Language
  → No: Customer-Supplier is sufficient

Are contexts completely independent?
  → Yes: Separate Ways
  → No: Choose from above based on coupling needs

Are two teams building intertwined features?
  → Yes, small shared model: Shared Kernel
  → Yes, evolving together: Partnership
  → No: Customer-Supplier
```
