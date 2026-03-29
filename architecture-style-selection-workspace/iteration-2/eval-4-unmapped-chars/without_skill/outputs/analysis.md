# Architecture Style Analysis

## Input Characteristics

The following architecture characteristics were identified as priorities:

1. **Workflow** — Complex multi-step business processes spanning multiple services
2. **Configurability** — Must support per-tenant configuration and white-labeling
3. **Interoperability** — Must integrate with 12+ external partner APIs

### Context

- B2B SaaS platform for logistics
- Multi-tenant with per-customer configuration
- Heavy integration with shipping carriers, customs, ERP systems

## Architecture Style Evaluation

### Candidate Styles Considered

| Style | Workflow | Configurability | Interoperability | Overall Fit |
|---|---|---|---|---|
| Modular Monolith | Medium | Medium | Low | Weak |
| Service-Based | High | High | High | Strong |
| Microservices | High | Medium | High | Moderate |
| Event-Driven | High | Low | Medium | Moderate |
| Space-Based | Low | Low | Medium | Weak |

### Detailed Assessment

#### Modular Monolith
- Workflow support is limited once processes span multiple bounded contexts
- Configurability can be handled but becomes tangled as tenant-specific logic grows
- Interoperability with 12+ external APIs creates a monolithic coupling risk
- **Verdict: Not recommended** — does not scale well for the integration and workflow complexity described

#### Service-Based Architecture
- Natural fit for complex workflows: each domain service (shipment tracking, customs clearance, carrier selection) owns its workflow segment, with orchestration across services
- Configurability is well-supported: a dedicated configuration service can manage per-tenant settings, and each domain service reads tenant context to adjust behavior
- Interoperability is a core strength: integration adapters can be isolated into dedicated services or an integration layer, keeping external API changes from rippling through the system
- Deployment units are coarse-grained enough to remain operationally manageable for a B2B SaaS team
- **Verdict: Strong fit**

#### Microservices
- Excellent for workflow and interoperability, but introduces significant operational overhead (service mesh, distributed tracing, independent deployments)
- Configurability requires a centralized config service plus distributed propagation, adding complexity
- For a logistics SaaS that is not yet at hyperscale, the operational cost may outweigh the benefits over a service-based approach
- **Verdict: Viable but over-engineered for stated requirements**

#### Event-Driven Architecture
- Strong for decoupled workflow orchestration via events/choreography
- Configurability is harder to implement in a purely event-driven model — tenant-aware routing adds complexity
- Interoperability benefits from async processing but requires careful error handling for external API calls
- Works well as a complementary pattern within another architecture, not as the sole style
- **Verdict: Recommended as a supporting pattern, not the primary style**

## Recommendation Summary

**Primary style: Service-Based Architecture**, augmented with event-driven patterns for asynchronous workflow steps and integration event processing.

This combination provides the best balance of workflow orchestration capability, tenant configurability, and integration flexibility without the operational overhead of full microservices.
