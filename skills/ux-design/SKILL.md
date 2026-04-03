---
name: ux-design
description: Use when building user-facing features that need UI design, user flows, or wireframes — or when the user asks about UX, navigation, screen layouts, or interaction design
---

# UX Design

Orchestrates the full UX design process through 4 phase skills. Each phase produces a section in `ux-design.md` and can be invoked independently.

**Announce at start:** "I'm running the UX design process — checking which phases are needed."

## When to Use

- When building user-facing features that need UI design
- When the user asks about user flows, screen layouts, navigation, or interaction design
- After brainstorming has clarified requirements and before feature-design writes BDD scenarios

**When NOT to use:**
- For API-only services with no user interface
- For pure backend/infrastructure work

## Process

```dot
digraph ux_design {
  start [shape=ellipse, label="Start"];
  check [shape=diamond, label="ux-design.md\nexists?"];
  read [label="Read existing\nux-design.md"];
  research [label="ux-research\n(Personas, JTBD,\nProblem Statements)"];
  flows [label="ux-flows\n(User Flows, IA)"];
  wireframes [label="ux-wireframes\n(Low→Mid→High-fi,\nall States)"];
  validate [label="ux-validate\n(Nielsen's 10\nHeuristics)"];
  severity [shape=diamond, label="Severity\n3-4?"];
  done [shape=doublecircle, label="Return to\nbrainstorming"];

  start -> check;
  check -> read [label="yes"];
  check -> research [label="no"];
  read -> research [label="incomplete"];
  read -> done [label="all phases done"];
  research -> flows;
  flows -> wireframes;
  wireframes -> validate;
  validate -> severity;
  severity -> wireframes [label="redesign"];
  severity -> done [label="proceed"];
}
```

## Phase Skills

| Phase | Skill | Produces (in ux-design.md) | Consumed by |
|---|---|---|---|
| 1. Research & Define | `superflowers:ux-research` | Personas, JTBD, Problem Statements | feature-design |
| 2. Ideate | `superflowers:ux-flows` | User Flows, Information Architecture | feature-design, writing-plans |
| 3. Design | `superflowers:ux-wireframes` | Wireframes, State Designs, Design Decisions | writing-plans, feature-design |
| 4. Validate | `superflowers:ux-validate` | Heuristic Evaluation | Redesign loop, quality-scenarios |

## Orchestration Logic

1. Check if `ux-design.md` exists
2. If yes: read it, determine which sections are filled → skip completed phases
3. Invoke the next incomplete phase skill
4. After each phase: check if user wants to continue or pause
5. After ux-validate: if Severity 3-4 findings → invoke ux-wireframes again
