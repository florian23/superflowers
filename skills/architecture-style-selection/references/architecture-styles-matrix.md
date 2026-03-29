# Architecture Styles Matrix

Based on the Architecture Styles Worksheet V2.0 by Mark Richards (DeveloperToArchitect.com).
Source: "Fundamentals of Software Architecture" by Neal Ford & Mark Richards.

## How to read this matrix

Each architecture style is rated 1-5 stars per characteristic. Higher = better support for that characteristic.
Cost uses $ symbols ($ = cheap, $$$$$ = very expensive).
Partitioning indicates how the architecture divides the system (by technical layer or by business domain).

## Styles Overview

| Style | Partitioning | Cost | Description |
|---|---|---|---|
| Layered | technical | $ | Traditional n-tier architecture. Separates by technical concern (presentation, business, persistence). Simple, well-understood, low cost. |
| Modular Monolith | domain | $ | Single deployment unit partitioned by business domain. Domain modules have clear boundaries but share a runtime. |
| Microkernel | domain | $ | Core system with plug-in components. Good for product-based applications with customizable features. |
| Microservices | domain | $$$$$ | Independently deployable services, each owning its domain. Maximum decoupling at maximum operational cost. |
| Service-Based | domain | $$ | Coarser-grained services than microservices, typically 4-12 services sharing a database. Pragmatic middle ground. |
| Service-Oriented (SOA) | technical | $$$$ | Enterprise-scale with orchestration, service bus, and shared infrastructure. Heavy governance overhead. |
| Event-Driven | technical | $$$ | Asynchronous event processing. Broker or mediator topology. Excellent for responsiveness and scalability. |
| Space-Based | technical | $$$$ | In-memory data grids with processing units. Eliminates database bottleneck for extreme scalability/elasticity. |

## Star Rating Matrix

Rating scale: 1 = poor support, 2 = below average, 3 = average, 4 = good, 5 = excellent

| Characteristic | Layered | Modular Monolith | Microkernel | Microservices | Service-Based | Service-Oriented | Event-Driven | Space-Based |
|---|---|---|---|---|---|---|---|---|
| maintainability | 1 | 2 | 3 | 5 | 5 | 1 | 3 | 3 |
| testability | 2 | 2 | 3 | 5 | 4 | 1 | 2 | 1 |
| deployability | 1 | 1 | 3 | 5 | 4 | 1 | 3 | 3 |
| simplicity | 5 | 5 | 5 | 1 | 3 | 1 | 2 | 1 |
| scalability | 1 | 1 | 1 | 5 | 4 | 3 | 5 | 5 |
| elasticity | 1 | 1 | 1 | 5 | 3 | 3 | 5 | 5 |
| responsiveness | 3 | 3 | 3 | 2 | 3 | 1 | 5 | 5 |
| fault-tolerance | 1 | 1 | 1 | 5 | 4 | 2 | 5 | 3 |
| evolvability | 1 | 1 | 3 | 5 | 5 | 1 | 5 | 3 |
| abstraction | 1 | 1 | 3 | 1 | 1 | 5 | 4 | 1 |
| interoperability | 1 | 1 | 3 | 4 | 2 | 5 | 3 | 1 |

## Related Characteristics (a/b pairs)

Some characteristics are related — a system may need one or both:
- performance / responsiveness
- scalability / elasticity
- data integrity / data consistency
- adaptability / extensibility

When scoring, if the user's driving characteristic is one of these and the matrix rates the related one, use the related rating as a proxy.

## Characteristic Mapping

The matrix rates 11 characteristics directly. Some characteristics from the Architecture Characteristics Worksheet don't have direct ratings. Use these mappings:

| User Characteristic | Matrix Mapping | Rationale |
|---|---|---|
| performance | responsiveness | Processing time correlates with response time |
| availability | fault-tolerance | Fault tolerance is a primary driver of availability |
| recoverability | fault-tolerance | Recovery capability follows from fault handling |
| adaptability | evolvability | Adapting to change is a form of evolution |
| extensibility | evolvability | Extending functionality requires evolvability |
| data integrity | (no direct rating) | Evaluate per-style: monoliths favor ACID, distributed favor eventual consistency |
| data consistency | (no direct rating) | Same as data integrity — assess based on partitioning type |
| concurrency | scalability | Concurrent processing is implied by scalability |
| configurability | (no direct rating) | Microkernel excels; others depend on implementation |
| workflow | (no direct rating) | Service-oriented and event-driven excel at complex workflows |
| security | (no direct rating) | Implicit characteristic — all styles can implement security |
| observability | (no direct rating) | Implicit characteristic — distributed styles need more investment |
| feasibility | cost | Direct cost mapping from the worksheet |

## Adding New Architecture Styles

To extend this matrix with a new style:

1. Add a column to the **Styles Overview** table with partitioning, cost, and description
2. Rate the style 1-5 for each of the 11 characteristics in the **Star Rating Matrix**
3. Base ratings on the style's inherent structural properties, not on any specific implementation
4. Validate ratings by comparing against similar styles — a new style should not dominate all existing styles unless it truly is revolutionary
5. Document the source or reasoning for ratings in a comment below the table
