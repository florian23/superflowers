# Architecture Style Analysis: Internes HR-Tool

## Context
- **Type**: Internal HR tool
- **Users**: ~50 (internal only)
- **Team**: 2 developers
- **Budget**: Minimal
- **Release cadence**: Weekly

## Architecture Characteristics (from architecture.md)
1. **Simplicity** (highest priority) — Small team must understand the entire system
2. **Testability** — >90% coverage required
3. **Deployability** — Weekly releases, low-risk deployments

## Architecture Styles Evaluated

### 1. Modular Monolith
- **Simplicity**: Excellent. Single deployable unit, one codebase, no distributed systems complexity. A 2-person team can reason about the entire system easily.
- **Testability**: Excellent. All tests run in-process, no service mocking needed, straightforward integration testing. Achieving >90% coverage is natural.
- **Deployability**: Good. Single artifact to deploy. Weekly releases are simple with a single deployment pipeline.
- **Cost**: Minimal. One server/container, one CI pipeline, one database.
- **Fit score**: 5/5

### 2. Layered Monolith (Traditional N-Tier)
- **Simplicity**: Good. Well-understood pattern, but rigid layering can lead to unnecessary abstractions for a small tool.
- **Testability**: Good. In-process testing, but strict layers may require more mocking between layers.
- **Deployability**: Good. Single artifact.
- **Cost**: Minimal.
- **Fit score**: 4/5

### 3. Microservices
- **Simplicity**: Poor. Distributed system complexity is unjustifiable for 50 users and 2 developers. Network calls, service discovery, distributed debugging.
- **Testability**: Poor. Integration tests require running multiple services. Contract testing overhead. Achieving >90% coverage across services is significantly harder.
- **Deployability**: Overkill. Multiple pipelines, orchestration, monitoring for each service.
- **Cost**: High. Multiple containers, infrastructure overhead.
- **Fit score**: 1/5

### 4. Service-Based Architecture
- **Simplicity**: Moderate. Less complex than microservices but still introduces network boundaries unnecessarily for this scope.
- **Testability**: Moderate. Cross-service testing adds friction.
- **Deployability**: Moderate. Multiple deployable units for a 50-user tool is overhead.
- **Cost**: Moderate.
- **Fit score**: 2/5

### 5. Serverless / FaaS
- **Simplicity**: Moderate. Event-driven model adds cognitive overhead. Cold starts, vendor lock-in.
- **Testability**: Moderate. Local testing of serverless functions requires emulation tooling.
- **Deployability**: Good for small changes, but function sprawl risk.
- **Cost**: Could be low at this scale, but vendor dependency.
- **Fit score**: 3/5

## Recommendation

**Modular Monolith** is the clear best fit.

### Rationale
All three priority characteristics strongly favor this style:
- **Simplicity**: A 2-developer team needs a single mental model. No distributed systems, no network boundaries, no service orchestration.
- **Testability**: In-process testing makes >90% coverage achievable with standard unit and integration tests. No service mocking or contract testing overhead.
- **Deployability**: One build, one artifact, one deploy. Weekly releases are low-risk and straightforward.

The system has no scaling concerns (50 internal users), no need for independent deployability of components, and no polyglot requirements. Every argument for distributed architectures is absent here. The modular monolith provides clean internal boundaries (HR modules like employees, leave, payroll) without the operational cost of distribution.

### Anti-Recommendations
- **Microservices**: Actively harmful for this context. Would triple operational complexity for zero benefit.
- **Service-Based**: Unnecessary distribution overhead for an internal tool.
