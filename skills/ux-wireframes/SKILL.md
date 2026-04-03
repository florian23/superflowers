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

> "Sollen wir den nächsten Screen designen, oder diesen Screen in High-fi ausarbeiten (Farben, Typography, visuelles Design)?"

If high-fi: apply visual design, render, get feedback.
If next screen: repeat from Turn 1 with next screen.

### Responsive (if relevant)

After key screens are designed, ask:

> "Wird das System hauptsächlich auf Desktop, Tablet oder Handy genutzt? Sollen wir eine mobile Variante designen?"

## After Wireframing: Independent Review

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
