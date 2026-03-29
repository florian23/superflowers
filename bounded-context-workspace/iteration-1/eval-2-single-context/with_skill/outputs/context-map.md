# Context Map

## Last Updated: 2026-03-29

## Decision: Single Bounded Context

This system does **not** require multiple bounded contexts. Detailed context mapping is skipped per the skill's process flow ("Multiple domains?" -> No -> "Single context -> skip to assessment").

### Rationale

- **One domain:** Time tracking is a single, cohesive business area. Logging hours, approving hours, and exporting hours are all facets of the same domain -- not separate domains with different business rules.
- **One team:** A single developer builds and maintains the system.
- **One purpose:** Internal tool for 30 employees to track hours on projects.
- **No linguistic ambiguity:** "TimeEntry", "Project", "Employee", "Approval" mean the same thing everywhere in this system. There is no case where the same term carries different meaning in different parts of the application.
- **No competing business rules:** Approval and export follow straightforward, uniform rules. There is no tension between subdomains.

### Red Flags Check (from skill)

| Red Flag | Applies? | Assessment |
|---|---|---|
| Technical boundaries instead of domain boundaries | No | Not splitting by frontend/backend |
| One context per entity | No | Not creating separate contexts for Employee, Project, TimeEntry |
| Too many contexts for a small system | No | Recommending exactly one |
| Ignoring existing team structure | No | One developer = one context |

## Single Context: Zeiterfassung (Time Tracking)

- **Type:** Supporting (necessary internal tool, not a competitive differentiator)
- **Responsibility:** Employees log hours on projects, managers approve time entries, monthly CSV export for accounting.
- **Team:** Single developer
- **Ubiquitous Language:**

| Term | Meaning |
|---|---|
| Mitarbeiter (Employee) | A person who logs time entries against projects |
| Projekt (Project) | A billable or internal project that hours are logged against |
| Zeiteintrag (Time Entry) | A record of hours worked by one employee on one project on a given day |
| Manager | An employee with the authority to approve or reject time entries |
| Genehmigung (Approval) | A manager's confirmation that a time entry is correct and accepted |
| CSV-Export | Monthly extraction of approved time entries for accounting |

## Subdomains

| Subdomain | Type | Bounded Context(s) |
|---|---|---|
| Zeiterfassung (Time Tracking) | Supporting | Zeiterfassung |

## Context Relationships

None. Single context -- no inter-context relationships to map.

## Recommendation

Proceed directly to architecture assessment. A single bounded context implemented as a simple modular monolith (or even a straightforward CRUD application) is the right fit. Do not introduce microservices, event-driven patterns, or multi-module splits -- they would add accidental complexity with no benefit for this scope.
