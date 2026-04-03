---
name: ux-research
description: Use when starting UX design for a new feature — identifies personas, jobs to be done, and problem statements before any visual design begins
---

# UX Research & Define

Understand who the users are and frame clear problems to solve. First phase of the UX design process.

**Semantic anchors:** Design Thinking Empathize+Define (IDEO), Jobs to Be Done (Christensen), Personas (Cooper), "How Might We" Problem Framing, Double Diamond Problem Space.

**Announce at start:** "I'm researching user needs — building personas and framing problems to solve."

## When to Use

- As first step in `superflowers:ux-design` orchestration
- When you need to understand users before designing UI
- When personas or problem statements don't exist yet

**When NOT to use:**
- If `ux-design.md` already has Personas and Problem Statements — skip to `ux-flows`

## Step 1: Build Personas

Derive 3-5 personas from available context:
- `domain-profile.md` (if exists) — domain roles and stakeholders
- `market-analysis.md` (if exists) — target audience from competitive analysis
- User input — ask the user about their users

Each persona:

| Field | Description |
|---|---|
| Name | Memorable name (e.g., "Dr. Müller") |
| Role | Role in the system |
| Goal | Primary goal when using the system |
| Frustration | Main pain point with current solutions |
| Tech Affinity | Low / Medium / High |
| Context of Use | Where/when/how they use the system |

## Step 2: Jobs to Be Done

For each persona, identify 2-3 JTBD:

> When [situation], I want [motivation], so I can [outcome].

## Step 3: Competitive UX Review

If `market-analysis.md` exists, extract UX-relevant findings:
- How do competitors solve the same UX problems?
- UX strengths/weaknesses from reviews?
- UX differentiation opportunity?

## Step 4: Problem Statements

For each persona's top frustration:

> How might we help [persona] [achieve goal] without [frustration]?

## Step 5: User Scenarios

For each Problem Statement, write a narrative scenario:

> [Persona] is [context]. They want to [goal]. They [action sequence]. They see [result].

Prioritize by subdomain classification (if `market-analysis.md` exists):
- **Core Domain** → full UX treatment
- **Supporting** → basic flows
- **Generic** → standard patterns

**Uncertainty handling:** If persona goals conflict, follow `references/uncertainty-handling.md`: present the conflict with options and let the user prioritize.

## Write to ux-design.md

Append or create the following sections in `ux-design.md`:

```markdown
## Personas

> Consumed by: `superflowers:feature-design` (Akteure in BDD Scenarios)

| Persona | Rolle | Ziel | Frustration | Tech-Affinität | Kontext |
|---|---|---|---|---|---|

## Jobs to Be Done

> Consumed by: `superflowers:feature-design` (jedes JTBD → Scenario)

- When [situation], I want [motivation], so I can [outcome]

## Problem Statements

- How might we [Problem]?

## User Scenarios

- [Narrative Scenarios, priorisiert nach Subdomain]
```
