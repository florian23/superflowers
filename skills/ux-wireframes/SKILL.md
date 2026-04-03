---
name: ux-wireframes
description: Use when screens need to be designed — creates wireframes at increasing fidelity (low → mid → high-fi) with all UI states (loading, error, empty, success)
---

# UX Wireframes

Create wireframes at increasing fidelity. **Work screen by screen with the user — don't design all screens at once.** Uses the Visual Companion as rendering engine.

**Semantic anchors:** Wireframing (low-fi → mid-fi → high-fi), UI States, Visual Companion, Content-First Design, Mobile-First Design.

**Announce at start:** "Let's design the screens — I'll show you 2-3 layout options per screen and you pick the direction."

## When to Use

- After `superflowers:ux-flows` has produced user flows
- When screens need visual design

**When NOT to use:**
- If user flows don't exist yet — run `ux-flows` first

## The Dialog Process

### Turn 1: Pick the First Screen

Read user flows from `ux-design.md`. Ask:

> "Der wichtigste Screen im Flow '[flow name]' ist '[screen]'. Sollen wir damit anfangen?"

Wait.

### Turn 2: Low-fi Options (2-3 Variants)

Create 2-3 fundamentally different layout approaches. Render in Visual Companion side-by-side. Focus on structure, not aesthetics — grayscale, placeholder text.

Ask via AskUserQuestion:

> "Welche Richtung passt besser für [Persona]s Workflow?"

Options should describe the tradeoff, not just "A or B":
- Option A: "Kompakte Liste — viele Patienten auf einen Blick, wenig Detail"
- Option B: "Detailkarten — weniger Patienten sichtbar, aber sofort alle Infos"
- Option C: "Split-View — Liste links, Detail rechts"

Wait for choice.

### Turn 3: States for Chosen Direction

Ask:

> "Wie soll der Screen aussehen wenn er lädt? Wenn keine Daten da sind? Wenn ein Fehler passiert?"

Draft states based on user input:

| State | What to design |
|---|---|
| **Default** | Normal, populated view |
| **Loading** | Skeleton or spinner |
| **Error** | Error message + recovery action |
| **Empty** | Helpful empty state + CTA |
| **Success** | Confirmation feedback |

Render each state. Ask per state: "Passt das, oder soll [State] anders aussehen?"

### Turn 4: Mid-fi Refinement

Refine the chosen layout with:
- Real content hierarchy (actual headings, realistic text length)
- Proper spacing
- Interaction annotations ("tap to expand", "swipe to dismiss")

Render and ask: "Stimmt die Gewichtung der Informationen? Ist das Wichtigste prominent genug?"

### Turn 5: Next Screen or High-fi

Ask:

> "Wie sollen wir weitermachen?"
>
> **Option A: Nächster Screen** — weiter mit dem nächsten Screen im Flow (Low-fi → Mid-fi)
> **Option B: High-fi Wireframe** — diesen Screen visuell verfeinern (Farben, Spacing, Typography) als Wireframe im Visual Companion
> **Option C: Production Design** — diesen Screen als echten, production-grade UI-Code umsetzen mit `frontend-design` Skill (HTML/CSS/JS oder React). Empfohlen wenn der Screen-Entwurf stabil ist.

If Option A: repeat from Turn 2 with next screen.
If Option B: apply visual design in Visual Companion, render, get feedback. Then return to this choice.
If Option C: invoke `frontend-design:frontend-design` with the wireframe context:
- Pass the confirmed layout direction, states, and content hierarchy from Turns 2-4
- Pass the persona and task flow context from ux-design.md
- Let frontend-design handle aesthetic direction, typography, color, animation
- After frontend-design completes: return to Turn 5 for next screen choice

### Responsive (if relevant)

After key screens are designed, ask:

> "Wird das System hauptsächlich auf Desktop, Tablet oder Handy genutzt? Sollen wir eine mobile Variante designen?"

## After Wireframing: Usability Validation

After all screens are designed, dispatch the `superflowers:ux-reviewer` agent for independent usability evaluation.

Follow the Review-Loop Pattern from `agents/reviewer-protocol.md`:
1. Dispatch ux-reviewer (fresh context — it did NOT create the wireframes)
2. If ISSUES_FOUND: fix the cited issues in the wireframes, then re-dispatch reviewer (fresh)
3. Repeat until reviewer returns APPROVED
4. Only then write final ux-design.md and proceed

<HARD-GATE>
Do NOT claim UX design is complete or proceed to feature-design
until the ux-reviewer returns APPROVED.
If ISSUES_FOUND: fix and re-dispatch. Do NOT ask the user whether to fix.
Severity 3-4 findings MUST be resolved — no exceptions.
</HARD-GATE>

## Write to ux-design.md

After ux-reviewer returns APPROVED, append:

```markdown
## Design Decisions

| Screen | Gewählte Variante | Begründung | Verworfene Alternativen |
|---|---|---|---|

## State Designs

> Consumed by: `superflowers:feature-design` (States = BDD Scenarios)
> Consumed by: `superflowers:writing-plans` (Frontend-Tasks)

| Screen | Default | Loading | Error | Empty | Success |
|---|---|---|---|---|---|
```

## Red Flags — STOP

- Wireframes without referencing task flows (designing screens without knowing the flow)
- Only one layout option presented ("here's the design" instead of "here are 2-3 options")
- Missing states: no loading, no error, no empty state (only success state designed)
- Pixel-perfect details in low-fi phase (colors, fonts, shadows before structure is confirmed)
- Skipping usability validation ("the wireframes look good to me")

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "One layout is clearly the right choice" | Present options anyway. The user sees tradeoffs you don't. |
| "Empty states don't matter" | Empty state is the first thing new users see. It IS the onboarding. |
| "We'll handle errors in development" | Error states need design. A raw error message is not a design decision. |
| "Low-fi doesn't need all states" | Low-fi is where you discover missing states. That's the point. |
| "The review agent will catch issues" | The review agent validates against heuristics. It can't fix a missing layout alternative. |

## Verification Checklist

- [ ] Each screen has 2-3 layout options with described tradeoffs
- [ ] User has chosen layout direction before state design
- [ ] All states designed: loading, error, empty, success (minimum)
- [ ] Wireframes reference task flows (not designed in isolation)
- [ ] ux-reviewer agent dispatched and returned APPROVED
- [ ] Output written to ux-design.md in correct format

## The Bottom Line

Show options, not one answer. 2-3 layout alternatives with tradeoffs — then the user decides.
