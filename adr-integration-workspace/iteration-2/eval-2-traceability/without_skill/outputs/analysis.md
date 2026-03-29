# Traceability Analysis

## Approach

Built a bidirectional traceability matrix linking every fitness function to its governing ADR and every ADR to the fitness functions it produces. Then checked for orphans in both directions and assessed whether the declared architecture characteristics in ADR-002 are fully covered.

## Findings

### 1. All FFs have governing ADRs -- no orphans

Every fitness function traces directly to an architectural decision:

- **FF-1 through FF-5** (style FFs) all derive from ADR-001's choice of Microservices. These guard the structural properties that make the style work: service independence, contract stability, bounded size, communication latency, and deployment independence.
- **FF-6 and FF-7** (characteristic FFs) derive from ADR-002's prioritization of Scalability and Fault Tolerance. These guard the runtime quality attributes the system must exhibit.

### 2. All ADRs produce FFs -- no unguarded decisions

Neither ADR is "decision-only." Both have concrete, automatable fitness functions that enforce them over time.

### 3. Coverage gap: Evolvability is unguarded

ADR-002 explicitly prioritizes three characteristics: Scalability, Fault Tolerance, and Evolvability. However, only two characteristic FFs exist:

| ADR-002 Characteristic | Guarding FF | Status |
|---|---|---|
| Scalability | FF-6: Horizontal Scalability | Covered |
| Fault Tolerance | FF-7: Fault Isolation and Recovery | Covered |
| Evolvability | -- | **Not covered** |

This is the single most significant finding. Evolvability -- the ease with which the system can accommodate new features or changing requirements -- has no fitness function enforcing it. A possible FF could measure:

- **Component coupling metrics** (afferent/efferent coupling ratios)
- **Breaking-change frequency** in API contracts
- **Time-to-integrate** a new service into the mesh

### 4. Style vs. Characteristic FF balance

The 5:2 ratio of style-to-characteristic FFs is notable. ADR-001 (Microservices) is heavily guarded while ADR-002's characteristics have thinner coverage. This is partly natural -- a style decision creates many structural constraints -- but it means the system is better protected against structural drift than against quality-attribute degradation.

### 5. Potential overlap between style and characteristic FFs

FF-1 (Service Independence) and FF-7 (Fault Isolation) overlap conceptually: independent services naturally contain blast radius. Similarly, FF-5 (Deployment Independence) supports both the microservice style and scalability. These overlaps are not harmful but should be acknowledged to avoid redundant alerting.

## Recommendations

1. **Add an Evolvability fitness function** to close the ADR-002 coverage gap. Candidate: measure afferent coupling per service and flag when it exceeds a threshold, indicating a service that is becoming a change bottleneck.
2. **Document overlap** between FF-1/FF-7 and FF-5/FF-6 so teams understand that a single violation may trigger multiple alerts.
3. **Re-evaluate the matrix** whenever a new ADR is accepted or an existing ADR is superseded, to maintain traceability over time.
