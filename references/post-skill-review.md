# Post-Skill Review Pattern

After a skill produces artifacts (design documents, architecture files, context maps, quality scenarios), follow this pattern to capture decisions as ADRs and verify artifact quality.

## The Rule

**Every skill that produces architecture-relevant artifacts gets a post-skill review: ADR capture first, then quality review.**

## Pattern

```
Skill completes → artifacts produced
    ↓
1. Dispatch adr-decision-agent (agents/adr-decision-agent.md)
   → Agent scans dialog for ADR-worthy decisions
   → Agent writes ADRs autonomously (trusted, no user gate)
   → Agent reports: created ADRs or NO_DECISIONS
    ↓
2. Dispatch the skill's reviewer agent (fresh context)
   → Include in prompt: "New ADRs created: [list]" (if any)
   → Reviewer checks artifact quality + ADR consistency
   → Standard review-loop per reviewer-protocol.md
    ↓
3. If reviewer returns ISSUES_FOUND:
   → Fix the issues in the artifact
   → Re-dispatch reviewer (fresh)
   → Repeat until APPROVED
```

## When This Applies

| Skill | Dispatch After | Reviewer Agent |
|---|---|---|
| brainstorming | Step 6 (design confirmed by user) | spec-reviewer |
| architecture-assessment | Characteristics confirmed | architecture-reviewer |
| architecture-style-selection | Style selected | architecture-style-reviewer |
| quality-scenarios | Scenarios confirmed | quality-scenario-reviewer |
| bounded-context-design | Context map confirmed | (no dedicated reviewer yet) |

Skills that already have explicit ADR triggers (architecture-style-selection Step 7, bounded-context-design Step 8) keep them. The adr-decision-agent catches **additional** decisions the explicit triggers miss.

## When This Does NOT Apply

- Skills that don't produce architecture-relevant artifacts (ux-research, ux-flows, ux-wireframes)
- Implementation skills (executing-plans, subagent-driven-development) — these follow the Specification Verification Gate instead
- Pure verification skills (fitness-functions, bdd-testing) — these ARE the review, not a review target

## How to Reference This Pattern

In the skill's completion section, add:

```markdown
After [artifact] is confirmed by the user, follow `references/post-skill-review.md`:
1. Dispatch `adr-decision-agent` to capture architecture decisions from this dialog
2. Dispatch `[reviewer-name]` with new ADR context for artifact quality review
```
