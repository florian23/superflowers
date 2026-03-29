# Architecture Characteristics
## Last Updated: 2026-03-29
## Top 3 Priority Characteristics
1. Simplicity — Small team (2 devs), must be easy to understand
2. Testability — >90% test coverage required
3. Deployability — Weekly releases, low-risk

## Architecture Drivers
- Small team: 2 developers
- Internal tool: 50 users max, no scaling concerns
- Budget: Minimal

## Recommended Architecture Style: Modular Monolith

### Why Modular Monolith?
- **Simplicity**: Single codebase, single deployable unit. Two developers can fully understand and maintain the system without distributed systems expertise.
- **Testability**: All tests run in-process. No service mocking, no contract tests, no test environment orchestration. >90% coverage is straightforward to achieve.
- **Deployability**: One artifact to build, test, and deploy. Weekly releases require a single pipeline with minimal risk.

### Suggested Module Structure
```
hr-tool/
  modules/
    employees/       # Employee master data (CRUD)
    leave/           # Leave requests, approvals
    payroll/         # Salary, deductions
    reporting/       # Reports, dashboards
  shared/
    auth/            # Simple role-based access
    persistence/     # Shared database access
```

### Key Decisions
- **Single database**: One relational database (e.g., PostgreSQL) with schema-per-module separation
- **Single deployment**: One container or application server
- **Module boundaries**: Enforce via package/namespace conventions, not network calls
- **Testing**: Standard unit + integration tests against embedded or containerized database

### Trade-offs Accepted
- Cannot scale modules independently (not needed at 50 users)
- Cannot use different tech stacks per module (not needed with 2 devs)
- Must redeploy everything for any change (acceptable for weekly releases)

## Changelog
- 2026-03-29: Initial assessment
- 2026-03-29: Recommended Modular Monolith based on simplicity, testability, deployability priorities
