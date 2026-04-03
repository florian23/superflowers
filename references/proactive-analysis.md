# Proactive Analysis Pattern

When a skill step requires user input on a domain question, do NOT ask the user to provide the answer from scratch. Instead, follow this pattern:

## The Rule

**Analyze first, propose options, let user choose.**

## Pattern

1. **Read all available context** — spec, domain-profile.md, market-analysis.md, context-map.md, constraints, architecture.md. List what you read.
2. **Do independent analysis** — form your own assessment based on what you read. State your reasoning explicitly ("Based on X in the spec and Y in the market analysis, I think...").
3. **Present 2-3 options with tradeoffs** — not just your recommendation. Each option gets: a one-line summary, the key tradeoff, and when it would be the right choice.
4. **Lead with your recommendation** — mark one option as recommended and say why.
5. **Ask the user to choose or adjust** — via structured choices, not free-text.

## Format

> Based on [what I read], here's my analysis:
>
> **Option A (recommended): [Name]** — [one sentence]. Best when [condition].
> Trade-off: [what you give up].
>
> **Option B: [Name]** — [one sentence]. Best when [condition].
> Trade-off: [what you give up].
>
> **Option C: [Name]** — [one sentence]. Best when [condition].
> Trade-off: [what you give up].
>
> Which direction fits best — or should I adjust?

## Relationship to uncertainty-handling.md

- **uncertainty-handling.md** applies when you have ONE recommendation but are unsure about it. It prevents "Passt das?" on shaky ground.
- **proactive-analysis.md** applies BEFORE you have a recommendation — when the agent should do independent thinking instead of asking the user to provide the answer. It prevents passive questionnaires.

Both can apply to the same step: first do proactive analysis (think independently, propose options), and if your analysis reveals genuine uncertainty between options, use uncertainty-handling format for the presentation.

## When This Applies

- Persona creation (ux-research) — draft personas from context, don't ask "who are your users?"
- Characteristic identification (architecture-assessment) — propose characteristics from domain analysis
- Domain decomposition (bounded-context-design) — propose 2-3 boundary placements
- Flow structure (ux-flows) — propose navigation patterns, don't ask "how does the user get here?"
- Any step where the skill currently asks the user to provide something the agent could draft

## When This Does NOT Apply

- Clarifying questions about business facts the agent cannot know (budget, team size, compliance requirements)
- Binary confirmations of correct analysis
- Steps where the user's subjective preference is the actual input (e.g., "which problem feels most urgent?")
- When you are confident in ONE recommendation — present it directly, no need to manufacture alternatives
