# ADR-003: Emit Decisive Output from constraint-clarifier

## Status
Accepted

## Context

The `constraint-clarifier` agent (see ADR-001 and ADR-002) is dispatched by Claude Code's main thread in response to user questions like "Should we use React or Vue?" After looking up the constraint catalog, the agent has to decide what shape of answer to return. Three output shapes were considered:

- **Clarifier:** Return a list of potentially-relevant constraints and let the caller synthesize a recommendation. Output is informational — the agent does no decision-making.
- **Decisive:** Return a concrete recommendation plus the mandatory constraints that drove it, excluded alternatives with the constraint that forbids each, and additional considerations from recommended constraints. Output is actionable.
- **Hybrid:** Return both — a full list of constraints and a recommendation marked as "the agent's suggestion, callers may override freely."

The agent is dispatched specifically to answer the question — the main thread hands off because constraint lookup is the specialty. If the agent returns only a list of constraints, synthesis work falls back to the main thread, which then has to re-read constraint text and reason about it with less specialization. The value of dispatching a dedicated agent evaporates. The hybrid mode creates ambiguity about who is responsible for the final decision and encourages callers to ignore the recommendation in favor of their own re-synthesis.

## Decision

We will emit decisive output. The agent's output vocabulary is `[constraint-clarifier]: DECISION | OPEN_DECISION | ESCALATION_REQUIRED | NO_CONFIG`. A `DECISION` response contains:
- A concrete recommendation in one or two sentences.
- **Mandatory constraints** section listing each constraint that drove the decision, with ID, category, severity, source path, and the reason it applies.
- **Excluded alternatives** section naming each alternative the caller might consider and citing the constraint that forbids it.
- **Additional considerations** section listing recommended or optional constraints that shape the rationale but did not mandate it.
- **Scope** section stating which categories were searched and how many files were read.

Callers branch on the status prefix and may consume the structured sections programmatically or present them to the user verbatim.

## Consequences

**Easier:**
- Callers receive an actionable recommendation directly. No re-synthesis in the main thread. The main thread can pass the output through to the user with minimal post-processing.
- The output contract is clear and machine-parseable — the status prefix supports programmatic branching, and the section headers are stable.
- Conditional-mandatory resolution (e.g., "mandatory IF handling PII") and mandatory-conflict detection happen once, inside the agent, rather than being duplicated at every caller site.
- Coupling with ADR-002 is explicit: `OPEN_DECISION` is part of the same output vocabulary, so strict mode and decisive mode share one contract surface.

**Harder:**
- The agent takes responsibility for synthesis, conditional resolution, and conflict detection. This raises the reasoning bar — the decision to use the `opus` model is a direct consequence of this output shape.
- Changing the output shape later is a breaking change for any caller that branches on `DECISION` vs `OPEN_DECISION` or parses the structured sections. This contract must be versioned carefully.
- The agent cannot defer decisions to the caller when it has sufficient constraint information. If it has the data, strict mode (ADR-002) forces a concrete answer — `DECISION` or `ESCALATION_REQUIRED` for conflicts, but never "here are the facts, you decide."

**Tradeoff accepted:** Contract rigidity (output shape cannot change without breaking callers) in exchange for actionable answers and a clear handoff boundary between the agent's specialty (constraint reasoning) and the main thread's job (conversation flow). This ADR is tightly coupled to ADR-001 (single agent does all synthesis) and ADR-002 (strict mode defines when the agent declines to decide). The three together describe the agent's complete contract.
