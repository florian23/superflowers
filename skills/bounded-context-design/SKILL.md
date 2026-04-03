---
name: bounded-context-design
description: Use when the system has multiple business domains or teams, or when the user asks about domain boundaries, service decomposition, or microservice boundaries
---

# Bounded Context Design

> "The bounded context is the central pattern in Domain-Driven Design." — Eric Evans

Identify where domain boundaries are before deciding how to build the system. A bounded context defines where a particular model applies and where it stops. Without clear boundaries, you build accidental monoliths with tangled domains — where changing "Order" in checkout breaks "Order" in fulfillment because they're the same class but mean different things.

**Semantic anchors:** Domain-Driven Design (Eric Evans), Strategic Design, Context Mapping (Vaughn Vernon), Bounded Context, Ubiquitous Language.

**Announce at start:** "I'll help identify the bounded contexts in your domain — where the boundaries are, how contexts relate to each other, and what language each context speaks."

## The Iron Law

```
KNOW YOUR DOMAIN BOUNDARIES BEFORE CHOOSING YOUR ARCHITECTURE
```

Architecture decisions (monolith vs microservices, module boundaries, team ownership) depend on domain boundaries. If you partition by technical layers instead of domain contexts, you get distributed monoliths — the worst of both worlds.

## When to Use — and When Not

**Use this skill when:**
- The system involves multiple business domains (e-commerce: catalog + checkout + fulfillment)
- Multiple teams will work on the system
- You're decomposing a monolith into services
- The user asks about service boundaries or module structure
- Different parts of the system use the same terms with different meanings

**Skip this skill when:**
- The system is a single, focused tool (one domain, one team, one purpose)
- The project is a library or utility, not a business application
- The domain is already well-understood and boundaries are obvious from the spec

Not every system needs multiple bounded contexts. A small internal HR tool is likely one context. Forcing DDD strategic patterns onto a simple CRUD app adds complexity without value. When in doubt, ask: "Does this system have multiple subdomains with different business rules?" If no — skip.

## Process Flow

```dot
digraph bounded_context {
  rankdir=TB;
  node [shape=box, style=rounded];

  start [shape=ellipse, label="Start\n(design approved)"];
  needs_bc [shape=diamond, label="Multiple\ndomains?"];
  skip [label="Single context\n→ skip to assessment"];
  identify_subdomains [label="1. Identify\nsubdomains"];
  classify [label="2. Classify\n(Core/Supporting/Generic)"];
  find_boundaries [label="3. Find bounded\ncontext boundaries"];
  define_language [label="4. Define ubiquitous\nlanguage per context"];
  map_relationships [label="5. Map context\nrelationships"];
  present [label="6. Present to user"];
  user_ok [shape=diamond, label="User\nconfirms?"];
  write [label="7. Write\ncontext-map.md"];
  adr [label="8. Create ADR\nfor boundary decisions"];
  done [shape=doublecircle, label="Done"];

  start -> needs_bc;
  needs_bc -> skip [label="No"];
  needs_bc -> identify_subdomains [label="Yes"];
  skip -> done;
  identify_subdomains -> classify;
  classify -> find_boundaries;
  find_boundaries -> define_language;
  define_language -> map_relationships;
  map_relationships -> present;
  present -> user_ok;
  user_ok -> write [label="Yes"];
  user_ok -> find_boundaries [label="Revise"];
  write -> adr;
  adr -> done;
}
```

## Step 1: Identify Subdomains

Read the brainstorming output (design doc), `domain-profile.md`, and `market-analysis.md` (if they exist). Then follow `references/proactive-analysis.md`:

Draft the subdomain list yourself based on what you read. A subdomain is a coherent area of business capability — not a technical layer. Present to the user:

> "Based on the spec and domain profile, I see these business areas:"
>
> | Subdomain | Why I think it's distinct |
> |---|---|
> | [Name] | [Evidence from context: different rules, different stakeholders, different rate of change] |
>
> "Does this match your view? Any areas I'm missing or splitting wrong?"

Wait for feedback. Do NOT ask the user to list subdomains from scratch.

**Heuristics for finding subdomains:**
- Different business rules → different subdomain
- Different stakeholders or domain experts → different subdomain
- Different rate of change → likely different subdomain
- Could be outsourced or bought as SaaS → likely a subdomain boundary

## Step 2: Classify Subdomains

**If `market-analysis.md` exists:** Use the Core/Supporting/Generic classification and differentiation strategy from there as primary input. The market analysis identifies where competitive advantage lies — that determines what's Core vs. Generic.

For each subdomain, classify:

| Type | Definition | Investment Level | Example |
|---|---|---|---|
| **Core Subdomain** | Where competitive advantage lives. This is what makes the business unique. | Highest — build in-house, best developers, most attention | E-commerce: recommendation engine, pricing algorithm |
| **Supporting Subdomain** | Necessary for the business but not differentiating. Custom-built because no off-the-shelf solution fits. | Moderate — build in-house but with less investment | E-commerce: inventory management, order fulfillment |
| **Generic Subdomain** | Solved problems. Every business needs this, nothing unique about your version. | Lowest — buy/outsource/use SaaS | Auth, payment processing, email sending, file storage |

Present the classification to the user:

```markdown
| Subdomain | Type | Rationale |
|---|---|---|
| Product Catalog | Core | Unique product taxonomy and search relevance drive conversions |
| Checkout | Core | Custom checkout flow is a competitive differentiator |
| Fulfillment | Supporting | Standard logistics, but custom warehouse integration needed |
| User Auth | Generic | Standard OAuth/OIDC, use an identity provider |
| Payment | Generic | Use Stripe/Adyen, no custom payment processing |
```

This classification matters because it drives architecture investment: Core subdomains get the best architecture, Generic subdomains get the simplest.

## Step 3: Find Bounded Context Boundaries

A bounded context is NOT the same as a subdomain — though they often align. A bounded context defines where a specific model is valid. The same real-world concept can mean different things in different contexts.

**The linguistic test:** If the same word means different things in different parts of the system, that's a context boundary.
- "Order" in Checkout = items + payment intent + shipping address
- "Order" in Fulfillment = pick list + shipping label + tracking number
- "Order" in Billing = invoice line items + payment status

**The team test:** If different teams own different parts, those are likely different contexts.

**The change test:** If two areas change for different reasons and at different rates, they're likely different contexts.

Apply the three tests (linguistic, team, change) to each subdomain yourself. Then follow `references/proactive-analysis.md` and present 2-3 candidate decompositions:

> "I've analyzed the subdomains using the linguistic, team, and change tests. Here are the candidate decompositions:"
>
> **Decomposition A (recommended): [N] contexts** — [one-line summary]
> Contexts: [list]. Merges [X] and [Y] because [reason from tests].
> Best when: [condition, e.g., small team, simple integration needed].
> Trade-off: [what you give up, e.g., less isolation between domains].
>
> **Decomposition B: [M] contexts** — [one-line summary]
> Contexts: [list]. Splits [X] from [Y] because [reason from tests].
> Best when: [condition, e.g., separate teams, different scaling needs].
> Trade-off: [what you give up, e.g., more integration complexity].
>
> **Decomposition C (if applicable): Hybrid** — [one-line summary]
> [Description with shared kernel or other pattern].
> Best when: [condition].
>
> "Which decomposition fits your situation — or should I adjust?"

Wait for the user's choice. Then proceed with defining ubiquitous language (Step 4) for the chosen decomposition only.

## Step 4: Define Ubiquitous Language

For each bounded context, define the key terms and what they mean IN THAT CONTEXT. This is the ubiquitous language — the shared vocabulary between developers and domain experts within one context.

```markdown
### Checkout Context — Ubiquitous Language

| Term | Meaning in this context |
|---|---|
| Order | A collection of items a customer intends to purchase, with payment and shipping details |
| Cart | A mutable, pre-order collection of items. Becomes an Order on checkout |
| Item | A product variant with quantity and price at time of adding to cart |
| Customer | The person making the purchase (name, email, shipping address) |
```

The ubiquitous language feeds directly into feature-design: Gherkin scenarios should use these exact terms, not technical jargon.

## Step 5: Map Context Relationships

For each pair of contexts that interact, define the relationship pattern. Read `references/context-map-patterns.md` for detailed descriptions of each pattern.

| Pattern | Upstream/Downstream | When to Use |
|---|---|---|
| **Partnership** | Symmetric | Two contexts evolving together, teams coordinate closely |
| **Shared Kernel** | Symmetric | Small shared model, both teams agree on changes |
| **Customer-Supplier** | Upstream supplies, downstream consumes | Clear provider/consumer, upstream accommodates downstream needs |
| **Conformist** | Upstream dictates | Downstream has no influence on upstream model |
| **Anti-Corruption Layer** | Downstream protects itself | Translate external/legacy models to keep your domain clean |
| **Open Host Service** | Upstream exposes API | Well-defined public API for multiple consumers |
| **Published Language** | Standard format | Shared interchange format (JSON Schema, Protobuf, events) |
| **Separate Ways** | No integration | Contexts are independent, no data flow between them |

**For legacy systems:** Default to Anti-Corruption Layer. Protect new bounded contexts from the legacy model by translating at the boundary. Never let legacy data models leak into new domain code.

## Step 6: Present to User

Present the complete context map based on the decomposition chosen in Step 3, now enriched with ubiquitous language (Step 4) and relationships (Step 5):

1. List of bounded contexts with their subdomain classification
2. Ubiquitous language per context
3. Relationship map between contexts

If Steps 4-5 revealed that the chosen decomposition has problems (e.g., a relationship pattern doesn't work cleanly, or the linguistic test shows a term conflict within one context), flag this and offer to revisit Step 3 with adjusted options.

**Uncertainty handling:** If boundary placement remains ambiguous after Steps 3-5, follow `references/uncertainty-handling.md`: present the options with tradeoffs and let the user decide. Do NOT default to one boundary and ask "Passt das?".

Wait for user confirmation before writing.

## Step 7: Write context-map.md

Persist to `context-map.md` in the project root.

### context-map.md Format

```markdown
# Context Map

## Last Updated: YYYY-MM-DD

## Subdomains

| Subdomain | Type | Bounded Context(s) |
|---|---|---|
| [Name] | Core/Supporting/Generic | [Context name(s)] |

## Bounded Contexts

### [Context Name]
- **Subdomain:** [Core/Supporting/Generic]
- **Responsibility:** [What this context does, in one sentence]
- **Team:** [Which team owns this, if known]
- **Ubiquitous Language:**
  | Term | Meaning |
  |---|---|
  | ... | ... |

## Context Relationships

| Upstream | Downstream | Pattern | Notes |
|---|---|---|---|
| Catalog | Checkout | Customer-Supplier | Catalog provides product data, checkout consumes |
| Checkout | Fulfillment | Published Language | Order events as JSON schema |
| Legacy System | [New Context] | Anti-Corruption Layer | Translate legacy models at boundary |

## Relationship Diagram

[Text-based diagram showing contexts and their relationships]
```

## Step 8: Create ADR for Significant Boundary Decisions

If boundary decisions were non-obvious (e.g., "we decided to keep Billing and Checkout in one context" or "we split User into Auth and Profile"), invoke `superflowers:architecture-decisions` to document the decision. Not every boundary needs an ADR — only the ones where alternatives were considered and a conscious choice was made.

## Example: Good vs Bad Context Boundaries

❌ **BAD — Technical boundaries:**
| Context | Responsibility |
|---|---|
| Frontend Context | All UI code |
| Backend Context | All API code |
| Database Context | All persistence |

✅ **GOOD — Domain boundaries:**
| Context | Responsibility |
|---|---|
| Checkout | Order placement, payment intent, shipping selection |
| Fulfillment | Pick lists, shipping labels, tracking |
| Catalog | Product data, search, recommendations |

## Red Flags — STOP

- **Technical boundaries instead of domain boundaries:** "Frontend Context" and "Backend Context" are NOT bounded contexts. Contexts are about business domains, not technical layers.
- **One context per entity:** "Order Context", "Product Context", "User Context" — this is entity-driven decomposition, not DDD. A context groups related business capabilities, not individual data entities.
- **Too many contexts for a small system:** A 2-person team building an internal tool probably has 1-2 contexts, not 8. More contexts = more integration complexity.
- **Ignoring existing team structure:** Conway's Law is real. If the org has 3 teams, aim for ~3 contexts. Fighting the org chart usually loses.
- **Skipping ubiquitous language:** If you can't define the key terms per context, you haven't understood the domain well enough.

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "We can figure out boundaries later" | Later = distributed monolith. Boundaries are cheaper to define now than to refactor later. |
| "Everything is connected, we can't split" | Everything is connected in any business. The question is: where are the MINIMAL integration points? |
| "We need one database for consistency" | Bounded contexts can share a database initially. Context boundaries are logical, not physical. |
| "DDD is overkill for our project" | If you have multiple domains, you have bounded contexts — whether you name them or not. Making them explicit prevents accidental coupling. |
| "Our domain is too simple for this" | If a single context is the right answer, this skill tells you that in Step 0. It takes 2 minutes to confirm. |

## Verification Checklist

- [ ] Subdomains identified and classified (Core/Supporting/Generic)
- [ ] Each bounded context has a clear responsibility (one sentence)
- [ ] Ubiquitous language defined per context (key terms with meanings)
- [ ] No technical boundaries masquerading as domain boundaries
- [ ] Context relationships mapped with explicit patterns
- [ ] Anti-Corruption Layer specified for legacy/external integrations
- [ ] Context count is proportional to system complexity (not inflated)
- [ ] User reviewed and confirmed the context map
- [ ] context-map.md written to project root
- [ ] Significant boundary decisions documented as ADRs

## The Bottom Line

Domain boundaries before architecture boundaries. If you can't name the ubiquitous language, you don't understand the boundary.

## Integration

- **Called after:** `superflowers:brainstorming` (needs the design to identify domains)
- **Runs before:** `superflowers:architecture-assessment` (domain boundaries inform characteristics)
- **Informs:** `superflowers:architecture-style-selection` (contexts = potential service/module boundaries)
- **Informs:** `superflowers:feature-design` (ubiquitous language for Gherkin scenarios)
- **Referenced by:** `superflowers:writing-plans` (module/service decomposition follows context boundaries)
- **Pairs with:** `superflowers:architecture-decisions` (boundary decisions become ADRs)

## Reference Files

- `references/context-map-patterns.md` — Detailed description of each context map relationship pattern with examples and when to use each one
- `references/proactive-analysis.md` — The "analyze first, propose options" meta-pattern
