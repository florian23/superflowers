---
name: ux-research
description: Use when starting UX design for a new feature — identifies personas, jobs to be done, and HMW questions before any visual design begins
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
- If `ux-design.md` already has Personas and HMW Questions — skip to `ux-flows`

## The Dialog Process

Work through personas ONE AT A TIME. Do not generate all personas at once.

### Turn 1: Draft Candidate Personas

Read `domain-profile.md`, `market-analysis.md`, and the brainstorming spec (if they exist). Then follow `references/proactive-analysis.md`:

Draft 2-3 candidate personas based on what you read. For each, fill in what you can infer and mark what you're guessing:

> "Based on the spec and domain profile, I see these user groups:"
>
> **1. [Name] — [Role]**
> Goal: [inferred from spec]. Frustration: [inferred or "?"].
> Tech Affinity: [inferred or "?"]. Context: [inferred or "?"].
> Why I think they're a user: [evidence from context].
>
> **2. [Name] — [Role]**
> [same format]
>
> **3. [Name] — [Role]** (if applicable)
> [same format]
>
> "Are these the right user groups? Which ones are spot-on, which need adjustment, and is anyone missing?"

Wait for feedback. This replaces the open "Wer sind die Hauptnutzer?" question.

### Turn 2-N: Refine Personas One at a Time

Take the user's feedback from Turn 1 and refine ONE persona at a time, starting with the most important one.

For each persona, present the full table (with user's corrections incorporated) and ask ONE question to fill the remaining gaps:

| Field | Value |
|---|---|
| Name | [confirmed or adjusted] |
| Role | [confirmed or adjusted] |
| Goal | [confirmed or adjusted] |
| Frustration | [filled in from user feedback, or ask now] |
| Tech Affinity | [filled in or ask now] |
| Context of Use | [filled in or ask now] |

If gaps remain, ask only what's still unknown — one question, not three:

> "Was frustriert [Name] am meisten an der aktuellen Lösung?"

Then formulate 1-2 JTBD from what you know:
> When [situation], I want [motivation], so I can [outcome].

Confirm: "Trifft das [Name]s Hauptziel?"

After confirming each persona:

> "Nächste Persona, oder reichen diese [N]?"

Stop when the user says it's enough. Don't push for exactly 5 if 3 cover the use cases.

### After All Personas: How Might We (HMW) Questions

For each persona's top frustration, propose an HMW Question:

> How might we help [persona] [achieve goal] without [frustration]?

Present ALL HMW questions together and ask:

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

## Reference Files

- `references/proactive-analysis.md` — The "analyze first, propose options" meta-pattern

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

## How Might We Questions (priorisiert)

1. How might we [dringendstes Problem]?
2. How might we [zweitdringendstes]?

## User Scenarios

- [Narrative Scenarios, priorisiert]
```

## Red Flags — STOP

- Personas invented without reading domain-profile.md or market-analysis.md (hallucinated personas)
- All personas have the same frustration (copy-paste personas)
- JTBD written as feature requests instead of user goals ("I want a dashboard" vs "I want to see my status at a glance")
- Skipping persona refinement ("3 personas are enough, let's move on" without user confirmation)
- HMW questions that are actually solutions ("How might we add a filter?" instead of "How might we help users find relevant items quickly?")

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "We already know our users" | Write it down. Implicit knowledge produces implicit assumptions. |
| "Personas are just overhead" | Every downstream skill (flows, wireframes, scenarios) needs a persona. Skip this, break the chain. |
| "One persona is enough" | One persona means one perspective. Edge cases live in the personas you didn't create. |
| "The spec already describes the users" | The spec describes features. Personas describe people — goals, frustrations, context. |
| "We can refine personas later" | Personas anchor every design decision. Refining later means redesigning later. |

## Verification Checklist

- [ ] At least 2 personas created with all fields filled (Name, Role, Goal, Frustration, Tech Affinity, Context)
- [ ] Each persona has at least 1 JTBD in correct format (When/I want/So I can)
- [ ] HMW questions are framed as opportunities, not solutions
- [ ] Personas are grounded in context (domain-profile.md, market-analysis.md referenced)
- [ ] User has confirmed personas and prioritized HMW questions
- [ ] Output written to ux-design.md in correct format

## The Bottom Line

Draft personas from evidence, not imagination. Every persona has a goal and a frustration grounded in context.
