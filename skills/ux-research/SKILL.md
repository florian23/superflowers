---
name: ux-research
description: Use when starting UX design for a new feature — identifies personas, jobs to be done, and problem statements before any visual design begins
---

# UX Research & Define

Understand who the users are and frame clear problems to solve. First phase of the UX design process. **This is a dialog — work through each step with the user, not a batch process.**

**Semantic anchors:** Design Thinking Empathize+Define (IDEO), Jobs to Be Done (Christensen), Personas (Cooper), "How Might We" Problem Framing, Double Diamond Problem Space.

**Announce at start:** "Let's start by understanding your users. I'll ask questions step by step."

## When to Use

- As first step in `superflowers:ux-design` orchestration
- When you need to understand users before designing UI
- When personas or problem statements don't exist yet

**When NOT to use:**
- If `ux-design.md` already has Personas and Problem Statements — skip to `ux-flows`

## The Dialog Process

Work through personas ONE AT A TIME. Do not generate all personas at once.

### Turn 1: Discover User Roles

Read `domain-profile.md` and `market-analysis.md` if they exist. Then ask:

> "Wer sind die Hauptnutzer deines Systems? Welche Rollen gibt es — und wer nutzt es am häufigsten?"

Wait for the user's answer.

### Turn 2: First Persona

Based on the user's answer, draft the MOST IMPORTANT persona:

| Field | Value |
|---|---|
| Name | [Memorable name] |
| Role | [From user's answer] |
| Goal | [Derived from context] |
| Frustration | [Ask if unclear] |
| Tech Affinity | [Ask if unclear] |
| Context of Use | [Ask if unclear] |

Present this ONE persona and ask:

> "Stimmt dieses Bild? Was würdest du ändern — und was frustriert [Name] am meisten an der aktuellen Lösung?"

Wait. Incorporate feedback. Then ask:

> "Was will [Name] hauptsächlich erreichen wenn er/sie das System nutzt?"

Formulate 1-2 JTBD from the answer:
> When [situation], I want [motivation], so I can [outcome].

Confirm: "Trifft das [Name]s Hauptziel?"

### Turn 3-N: Next Personas

Repeat Turn 2 for each additional persona. After each:

> "Gibt es noch eine wichtige Nutzergruppe die wir vergessen? Oder reichen diese [N] Personas?"

Stop when the user says it's enough. Don't push for exactly 5 if 3 cover the use cases.

### After All Personas: Problem Framing

For each persona's top frustration, propose a Problem Statement:

> How might we help [persona] [achieve goal] without [frustration]?

Present ALL problem statements together and ask:

> "Welches dieser Probleme ist am dringendsten? Womit sollen wir anfangen?"

This prioritization determines which scenarios get full UX treatment (flows, wireframes, all states) vs. basic treatment.

### Competitive UX Review (if market-analysis.md exists)

Briefly summarize how competitors solve the prioritized problem:
- What do they do well?
- Where do they fail?
- Where is the UX differentiation?

Ask: "Gibt es etwas an der Konkurrenz-UX das dir besonders gefällt oder stört?"

### Final: User Scenarios

For the top-priority problem, write a narrative scenario:

> [Persona] is [context]. They want to [goal]. They [action sequence]. They see [result].

Present and ask: "Stimmt dieser Ablauf aus [Persona]s Sicht?"

## Write to ux-design.md

After user confirmation, append to `ux-design.md`:

```markdown
## Personas

> Consumed by: `superflowers:feature-design` (Akteure in BDD Scenarios)

| Persona | Rolle | Ziel | Frustration | Tech-Affinität | Kontext |
|---|---|---|---|---|---|

## Jobs to Be Done

> Consumed by: `superflowers:feature-design` (jedes JTBD → Scenario)

- When [situation], I want [motivation], so I can [outcome]

## Problem Statements (priorisiert)

1. How might we [dringendstes Problem]?
2. How might we [zweitdringendstes]?

## User Scenarios

- [Narrative Scenarios, priorisiert]
```
