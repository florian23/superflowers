# Uncertainty Handling Pattern

When you are uncertain about a recommendation, do NOT present it as settled and ask "Passt das?". Instead, follow this pattern:

## The Rule

**Uncertainty gets structured options, not open questions.**

## Pattern

1. **Name the uncertainty** — what exactly are you unsure about and why?
2. **Present 2-3 options** — each with a brief tradeoff assessment
3. **Use AskUserQuestion** — with concrete, selectable choices (not free-text)
4. **Only then proceed** — with the user's chosen option

## Example

Instead of:
> "Ich empfehle Scalability als Top-1 Characteristic. Passt das?"

Do this:
> "Scalability und Performance sind beide stark durch dieses Feature betroffen. Ich bin unsicher, welche priorisiert werden soll."
>
> **Option A: Scalability priorisieren** — passt wenn das System wachsen muss (mehr Nutzer, mehr Daten). Trade-off: einzelne Requests könnten langsamer sein.
>
> **Option B: Performance priorisieren** — passt wenn Antwortzeiten kritisch sind (Echtzeit-UI, SLAs). Trade-off: horizontales Skalieren wird aufwändiger.
>
> **Option C: Beide als Top-3** — sicherer, aber erhöht die Architektur-Komplexität.

## When This Applies

- Characteristic prioritization (architecture-assessment)
- Close style scores (architecture-style-selection)
- Constraint relevance unclear (constraint-selection, project-constraints)
- Scenario test-type classification ambiguous (quality-scenarios)
- Domain boundary placement (bounded-context-design)
- Conflicting feature interpretations (feature-design)

## When This Does NOT Apply

- When you are confident in your recommendation — present it directly
- For automated review-loop gates — those follow reviewer-protocol.md
- For binary yes/no confirmations where there's no real uncertainty
