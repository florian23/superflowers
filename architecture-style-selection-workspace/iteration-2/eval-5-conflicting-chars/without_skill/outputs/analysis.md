# Architecture Style Analysis

## Context
Solo developer building an MVP that needs to ship fast, with expectations of viral growth and unpredictable traffic spikes from social media.

## Tension Analysis

The stated characteristics are in direct conflict:

| Characteristic | Pull Toward | Rationale |
|---|---|---|
| Simplicity | Monolith | Solo dev, ship fast, minimal moving parts |
| Scalability (100x) | Distributed / Microservices | Handle massive growth in users and data |
| Elasticity (spikes) | Cloud-native / Serverless | Auto-scale on unpredictable demand |

**Simplicity vs. Scalability/Elasticity** is the core tension. A microservices architecture provides scalability and elasticity but is the opposite of simple for a solo developer. A monolith is simple but traditionally harder to scale elastically.

## Architecture Styles Evaluated

### 1. Modular Monolith
- **Simplicity**: Excellent. Single deployable, one codebase, one database.
- **Scalability**: Moderate. Vertical scaling has limits. Horizontal scaling requires stateless design. Breaking out modules later is feasible if boundaries are clean.
- **Elasticity**: Poor to moderate. Can run multiple instances behind a load balancer, but scaling is coarse-grained (whole app scales, not individual components).
- **Solo dev fit**: Excellent. Minimal operational overhead.

### 2. Serverless Functions (e.g., AWS Lambda, Vercel Functions)
- **Simplicity**: Good for small scope, degrades as app grows. No server management, but distributed debugging is harder. Cold starts add complexity.
- **Scalability**: Excellent. Each function scales independently to massive throughput.
- **Elasticity**: Excellent. Scale-to-zero and instant scale-up by design.
- **Solo dev fit**: Good. Low ops burden, pay-per-use matches bootstrap budget.

### 3. Microservices
- **Simplicity**: Poor. Multiple services, inter-service communication, distributed data, deployment pipelines per service. Overwhelming for a solo developer.
- **Scalability**: Excellent.
- **Elasticity**: Excellent.
- **Solo dev fit**: Poor. Operational overhead is prohibitive.

### 4. Modular Monolith deployed on an elastic platform (Recommended hybrid)
- **Simplicity**: Very good. Single codebase with clear module boundaries. One deployment unit.
- **Scalability**: Good. Horizontal scaling via container orchestration or PaaS auto-scaling. Clean module boundaries allow extracting services later if needed.
- **Elasticity**: Good. Platform handles scaling (e.g., Railway, Fly.io, Cloud Run, App Runner). Container-based auto-scaling responds to traffic spikes.
- **Solo dev fit**: Excellent. One thing to build, one thing to deploy, platform handles the rest.

## Recommendation

**Modular Monolith on an elastic container platform** (e.g., Google Cloud Run, AWS App Runner, Fly.io).

### Why this resolves the tension
- **Ship fast**: You build one app, deploy one container. No distributed systems complexity.
- **Handle viral growth**: The platform auto-scales container instances horizontally. Stateless design + managed database (e.g., PlanetScale, Neon, Supabase) handles the data tier.
- **Handle spikes**: Cloud Run / App Runner scale from 0 to N instances based on request volume. You pay for what you use — matches bootstrap budget.
- **Future-proof**: Clean module boundaries mean you can extract hot modules into separate services later when the team grows and the bottlenecks are known.

### Key design constraints
1. Keep the monolith stateless (sessions in Redis/DB, not in-memory)
2. Use clear module boundaries internally (domain-driven packages)
3. Use a managed, scalable database from day one
4. Design APIs with clear contracts so modules can become services later

## Trade-offs Accepted
- Coarse-grained scaling (whole app scales, not individual features) — acceptable until traffic patterns are understood
- Single deployment means a bug in one module can affect everything — acceptable for MVP speed
- Some cold-start latency on scale-up — acceptable vs. paying for always-on infrastructure
