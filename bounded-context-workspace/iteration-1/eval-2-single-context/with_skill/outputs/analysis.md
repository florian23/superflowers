# Bounded Context Analysis: Zeiterfassungs-Tool

## Date: 2026-03-29

## Input Summary

- **System:** Internal time tracking tool for 30 employees
- **Team:** One developer
- **Scope:** Employees log hours on projects, managers approve, monthly CSV export for accounting
- **Nature:** Simple CRUD application

## Skill Process Flow Trace

```
Start -> "Multiple domains?" -> NO -> "Single context -> skip to assessment"
```

The skill's process flow was followed. At the first decision point ("Multiple domains?"), the answer is clearly **No**. The skill explicitly states:

> "Skip this skill when: The system is a single, focused tool (one domain, one team, one purpose)"

> "Not every system needs multiple bounded contexts. A small internal HR tool is likely one context. Forcing DDD strategic patterns onto a simple CRUD app adds complexity without value."

This system matches all three skip criteria:
1. **One domain** -- time tracking (logging, approval, export are all part of the same domain)
2. **One team** -- single developer
3. **One purpose** -- track employee hours for accounting

## Why This Is Not Multiple Contexts

One might be tempted to split into "Time Entry", "Approval", and "Reporting/Export" contexts. This would be wrong because:

- **No linguistic boundaries:** "TimeEntry" means the same thing whether you are creating it, approving it, or exporting it. There is no semantic divergence.
- **No independent change drivers:** If the time entry model changes (e.g., adding a "task category" field), approval and export must both reflect that change. They are tightly coupled by nature, not by accident.
- **No team boundaries:** One developer owns everything. Splitting into contexts would create artificial interfaces within a single person's codebase.
- **No outsourcing boundary:** None of these capabilities would be bought as SaaS or delegated to another team.

Applying the skill's heuristics:
- Different business rules? **No.** The rules are simple and uniform.
- Different stakeholders? **No.** Same internal users (employees and their managers).
- Different rate of change? **No.** Changes to the data model affect all areas equally.
- Could be outsourced? **Not individually.** The whole tool could be replaced by commercial time tracking software, but you would not outsource "approval" separately from "logging."

## Subdomain Classification

| Subdomain | Type | Rationale |
|---|---|---|
| Zeiterfassung (Time Tracking) | Supporting | Internal operational tool. Not a competitive differentiator. Necessary for the business but standard functionality. |

This is **Supporting**, not Core: the company does not compete on time tracking. It is not Generic either, because the specific approval workflow and CSV format are custom to this organization (a generic SaaS tool might work, but the user chose to build custom).

## Rationalization Check

| Temptation | Skill Response |
|---|---|
| "Let's create separate contexts for future growth" | YAGNI. 30 users, 1 developer. If the system grows to need multiple contexts, refactoring a clean single-context app is straightforward. |
| "Approval is a separate domain" | No. Approval is a workflow step within time tracking, not a separate business domain with its own language and rules. |
| "Export/Reporting is its own context" | No. CSV export is a read-only view of approved time entries. It has no independent domain logic. |

## Verification Checklist

- [x] Subdomains identified and classified (Supporting)
- [x] Single bounded context recognized -- detailed mapping correctly skipped
- [x] Ubiquitous language defined (in context-map.md)
- [x] No technical boundaries masquerading as domain boundaries
- [x] Context relationships: N/A (single context)
- [x] Anti-Corruption Layer: N/A (no legacy integration mentioned)
- [x] Context count proportional to system complexity (1 context for a simple CRUD tool)
- [x] context-map.md written

## Recommendation

**Skip detailed context mapping. Proceed to architecture assessment.**

The architecture assessment should evaluate this as a single-module application. Key characteristics to assess: simplicity, maintainability by a solo developer, and low operational overhead for 30 users. Do not over-engineer.
