---
name: ux-wireframes
description: Use when screens need to be designed — creates wireframes at increasing fidelity (low → mid → high-fi) with all UI states (loading, error, empty, success)
---

# UX Wireframes

Create wireframes at increasing fidelity. For each key screen, explore 2-3 layout variants, then design all states. Third phase of the UX design process. Uses the Visual Companion as rendering engine.

**Semantic anchors:** Wireframing (low-fi → mid-fi → high-fi), UI States (Default, Loading, Error, Empty, Success), Visual Companion (HTML rendering), Content-First Design, Mobile-First Design.

**Announce at start:** "I'm creating wireframes — starting with low-fi layout options, then adding all states."

## When to Use

- After `superflowers:ux-flows` has produced user flows and IA
- When screens need visual design
- When the user asks to see mockups or layout options

**When NOT to use:**
- If user flows don't exist yet — run `ux-flows` first
- For architecture diagrams — use the Visual Companion directly

## Step 1: Low-fi Wireframes (2-3 Variants)

For each key screen, create 2-3 fundamentally different layout approaches. Render in Visual Companion side-by-side.

Focus on:
- Content hierarchy (what's most prominent?)
- Navigation placement
- Information density
- Primary action placement

Grayscale only, placeholder text, basic shapes. The point is structure, not aesthetics.

Present to user via AskUserQuestion: "Which layout direction fits best for [persona]'s workflow?"

## Step 2: Mid-fi Wireframes (All States)

For the chosen direction, design ALL states per screen:

| State | What the user sees | When it occurs |
|---|---|---|
| **Default** | Normal, populated view | Most of the time |
| **Loading** | Skeleton/spinner | Fetching data |
| **Error** | Error message + recovery action | Request failed |
| **Empty** | Helpful empty state + CTA | No data yet |
| **Success** | Confirmation | Action completed |
| **Partial** | Incomplete data | Some fields missing |

Each state is a separate wireframe — not "imagine an error here."

## Step 3: High-fi Wireframes (Visual Polish)

Apply visual design to mid-fi wireframes:
- Typography hierarchy
- Spacing and alignment
- Color for meaning (error = red, success = green, interactive = accent)
- Responsive considerations (mobile vs. desktop)

Render in Visual Companion for final review.

## Write to ux-design.md

Append the following sections:

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
