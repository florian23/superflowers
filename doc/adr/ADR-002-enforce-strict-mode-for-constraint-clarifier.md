# ADR-002: Enforce Strict Mode for constraint-clarifier

## Status
Accepted

## Context

The `constraint-clarifier` agent (see ADR-001) looks up the organization's constraint catalog to answer ad-hoc questions. A question may arrive for which no constraint exists in the catalog — e.g., "Should we use GraphQL federation?" when the org has no constraints about federation yet. Three behaviors were considered:

- **Strict:** The agent emits `OPEN_DECISION` and explicitly states that no applicable constraint was found. It never invents recommendations from LLM general knowledge.
- **Best-practice fallback:** When no constraint matches, the agent generates a recommendation based on LLM general knowledge, marked as "no constraint, own recommendation."
- **Escalate to user:** The agent asks a clarifying question back to the caller before deciding.

The agent's value proposition is that every recommendation is grounded in a specific constraint file with a traceable source. If it silently falls back to best-practice advice, callers cannot distinguish a constraint-grounded decision from an LLM guess. The constraint catalog would appear more comprehensive than it actually is, hiding coverage gaps and reducing organizational pressure to maintain the catalog.

## Decision

We will enforce strict mode. When no constraint in the catalog matches an incoming question, the agent emits `[constraint-clarifier]: OPEN_DECISION` as a first-class result in its output vocabulary. The agent never invents best-practice recommendations. `OPEN_DECISION` is a documented, stable output status that callers may branch on — the same way `DECISION`, `ESCALATION_REQUIRED`, and `NO_CONFIG` are documented output statuses.

## Consequences

**Easier:**
- The constraint catalog becomes the sole source of authority for grounded decisions. No caller has to reason about whether a given answer came from the catalog or from LLM priors.
- Coverage gaps are surfaced instead of hidden. Every `OPEN_DECISION` is a signal that the catalog needs attention in that area.
- The behavioral contract is simple and testable: `answer ∈ {DECISION, OPEN_DECISION, ESCALATION_REQUIRED, NO_CONFIG}`. No fuzzy "recommendation, probably-good, maybe-grounded" middle ground.
- Callers gain trust: when they receive `DECISION`, they can act on it without second-guessing the grounding.

**Harder:**
- The agent stays silent on uncovered ground. Users who expect an answer for every question may find this limiting — they must accept that some questions cannot be decided from the catalog.
- The organization must invest in constraint coverage to see increasing value from the agent. Questions in emerging technology areas or new regulations will consistently return `OPEN_DECISION` until the catalog catches up.
- Convenience is lower than a fallback mode — the agent will not produce an answer when one is wanted but not backed by policy.

**Tradeoff accepted:** Less convenience (no "nice-to-have" fallback advice) in exchange for contract clarity, honest coverage reporting, and the ability for callers to trust that `DECISION` really means grounded. This ADR is tightly coupled to ADR-003 (decisive output shape) — both define the agent's output contract, and changing either without the other is incoherent.
