---
name: architecture-assessment
description: Use AFTER brainstorming completes and BEFORE writing specs or feature files — when architecture characteristics need to be identified
---

# Architecture Assessment

Identify, document, and maintain architecture characteristics through structured dialogue with the user. The architecture is a persistent, evolving artifact — not a one-time decision.

**Semantic anchors:** This skill applies ATAM (Architecture Tradeoff Analysis Method) for quality attribute analysis and tradeoff identification, arc42 for structured architecture documentation, Clean Architecture for testability and layer independence, Domain-Driven Design for bounded contexts and strategic design, and Definition of Done with architecture compliance gates.

**Announce at start:** "I'm using the architecture-assessment skill to identify architecture characteristics for this project."

## When to Use

- After brainstorming completes and before writing specs, feature files, or plans
- When a new project needs architecture characteristics identified
- When an existing project's characteristics need updating for a new feature
- When the user asks about architecture characteristics, tradeoffs, or non-functional requirements

**When NOT to use:**
- If `architecture.md` already exists and is current — read it instead of re-running the full assessment
- For individual architecture decisions — use `superflowers:architecture-decisions` instead

## The Iron Law

```
NO SPEC WITHOUT ARCHITECTURE CHARACTERISTICS
```

You cannot make design decisions without knowing which quality attributes matter. Define them first.

<HARD-GATE>
Do NOT proceed to writing specs, feature-design, or writing-plans until
architecture characteristics are documented in architecture.md and the
user has confirmed them. This applies to EVERY project regardless of
perceived simplicity.
</HARD-GATE>

## Process Flow

```dot
digraph architecture_assessment {
    "Brainstorming complete" [shape=doublecircle];
    "architecture.md exists?" [shape=diamond];
    "Read existing architecture" [shape=box];
    "Show to user:\ncurrent characteristics" [shape=box];
    "Changes needed for\nthis feature?" [shape=diamond];
    "Critical review:\nwhy change?" [shape=box];
    "User confirms change?" [shape=diamond];
    "Update architecture.md\n(with changelog entry)" [shape=box];
    "Structured questionnaire\ndialog" [shape=box];
    "Top-3 prioritization" [shape=box];
    "User confirms\ncharacteristics?" [shape=diamond];
    "Write architecture.md" [shape=box];
    "Dispatch verification agent" [shape=box];
    "Return to brainstorming\n(feature-design next)" [shape=doublecircle];

    "Brainstorming complete" -> "architecture.md exists?";
    "architecture.md exists?" -> "Read existing architecture" [label="yes"];
    "architecture.md exists?" -> "Structured questionnaire\ndialog" [label="no"];
    "Read existing architecture" -> "Show to user:\ncurrent characteristics";
    "Show to user:\ncurrent characteristics" -> "Changes needed for\nthis feature?";
    "Changes needed for\nthis feature?" -> "Return to brainstorming\n(feature-design next)" [label="no — architecture stable"];
    "Changes needed for\nthis feature?" -> "Critical review:\nwhy change?" [label="yes"];
    "Critical review:\nwhy change?" -> "User confirms change?";
    "User confirms change?" -> "Changes needed for\nthis feature?" [label="no — keep existing"];
    "User confirms change?" -> "Update architecture.md\n(with changelog entry)" [label="yes — justified"];
    "Update architecture.md\n(with changelog entry)" -> "Dispatch verification agent";
    "Structured questionnaire\ndialog" -> "Top-3 prioritization";
    "Top-3 prioritization" -> "User confirms\ncharacteristics?";
    "User confirms\ncharacteristics?" -> "Structured questionnaire\ndialog" [label="revise"];
    "User confirms\ncharacteristics?" -> "Write architecture.md" [label="approved"];
    "Write architecture.md" -> "Dispatch verification agent";
    "Dispatch verification agent" -> "Return to brainstorming\n(feature-design next)";
}
```

## The Persistent Architecture File

**Path:** `architecture.md` in the project root.

This file evolves over time. It is NOT recreated for each feature — it is updated incrementally.

- **File exists:** Read it, show current characteristics to the user, critically assess whether changes are needed
- **File does not exist:** Create it through the structured questionnaire dialog
- **After changes:** Dispatch a fresh verification agent to check consistency (see `superflowers:architecture-reviewer agent (agents/architecture-reviewer.md)`)

### architecture.md Format

```markdown
# Architecture Characteristics

## Last Updated: YYYY-MM-DD

## Top 3 Priority Characteristics
1. [Characteristic] — [Concrete metric/goal]
2. [Characteristic] — [Concrete metric/goal]
3. [Characteristic] — [Concrete metric/goal]

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Performance | Critical | API <200ms p95 | Yes - load test | Holistic (PR) |
| Availability | Important | 99.9% uptime | Yes - health check | Nightly |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Modularity | Critical | No circular deps | Yes - dependency check | Atomic (commit) |
| Testability | Important | >80% coverage | Yes - coverage gate | Atomic (commit) |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Security | Critical | No known CVEs | Yes - vulnerability scan | Atomic (commit) |

**Cadence values:** Atomic (every commit/CI run), Holistic (per PR, may need running services), Nightly (long-running, scheduled).

**Splitting compound characteristics:** If a characteristic has multiple distinct sub-goals (e.g., Security covering both "no CVEs" and "no SQL injection" and "input validation"), split them into separate rows. Each row should have one concrete, independently testable goal. This makes fitness function creation straightforward — one row, one automated check.

## Architecture Drivers
- [Driver]: [Why it matters, which characteristic it influences]

## Architecture Decisions
- [Decision]: [Rationale, which characteristic it addresses]

## Changelog
- YYYY-MM-DD: Initial architecture assessment
```

## Context Map Awareness

If `context-map.md` exists (from superflowers:bounded-context-design), read it before starting the questionnaire. Bounded contexts inform the assessment:

- **Modularity/Coupling:** How many contexts? How tightly coupled are their relationships? (Partnership = tight, Separate Ways = loose)
- **Interoperability:** Do contexts use different technologies or data formats? (Published Language = yes)
- **Scalability:** Do different contexts have different scaling needs? (e.g., Catalog handles 10x more reads than Fulfillment)
- **Per-context characteristics:** Some characteristics may be critical for one context but irrelevant for another. Note these differences — they inform architecture-style-selection about whether to treat contexts differently.

If no `context-map.md` exists, proceed with the questionnaire as normal.

## Constraint Awareness

If a feature constraints file exists in `docs/superflowers/constraints/` (from superflowers:constraint-selection), read the most recent one before the questionnaire. Active constraints inform the assessment:

- **Security constraints** (encryption, authentication) → elevate Security characteristic priority
- **Compliance constraints** (audit logging, data retention) → may introduce Compliance as a characteristic
- **Technology constraints** (specific frameworks, databases) → inform Deployability and Interoperability
- **Process constraints** (four-eyes, change management) → inform Testability and Deployability

Present the active constraints to the user during the questionnaire: "These organizational constraints are active for this feature and may affect architecture characteristics."

If no constraints file exists, proceed normally.

## The Questionnaire Dialog (New Projects)

**If `market-analysis.md` exists:** Use the competitive landscape to inform quality attribute prioritization. If the market analysis identifies performance or scalability as differentiators, weight those characteristics higher in the questionnaire.

Before asking any questions, read ALL available context:
- The brainstorming spec/design doc
- `domain-profile.md` (from domain-understanding)
- `market-analysis.md` (competitive landscape)
- `context-map.md` (bounded contexts, if exists)
- `docs/superflowers/constraints/` (active constraints)

Then follow `references/proactive-analysis.md`: draft a PROPOSED set of characteristics with priorities based on your analysis. Do NOT walk the user through each characteristic one by one asking "How important is X?".

### Phase 1: Independent Analysis & Proposal

Read all available context (see above). Then draft a proposed characteristics set:

1. For each of the 15 characteristics in `questionnaire-template.md`, assess relevance based on what you read — not by asking the user
2. Assign a proposed priority (Critical / Important / Nice-to-have / Irrelevant)
3. For Critical/Important ones, draft a concrete goal based on domain context

Present to the user:

> "Based on [spec/market-analysis/context-map], here are the architecture characteristics I think matter for this system:"
>
> **Critical:**
> - [Characteristic] ([concrete goal]) — because [reason from context]
> - [Characteristic] ([concrete goal]) — because [reason from context]
>
> **Important:**
> - [Characteristic] ([concrete goal]) — because [reason from context]
>
> **Irrelevant for this system:**
> - [Characteristic] — because [reason]
>
> "Does this match your understanding? What would you change — promote, demote, add, or remove?"

Wait for feedback. Incorporate changes.

### Phase 2: Concrete Goals Dialog

For each Critical/Important characteristic where your proposed concrete goal needs user input (e.g., you don't know the SLA targets), ask ONE focused question:

> "[Characteristic] — I proposed [goal]. Is that the right target, or do you have a specific number in mind?"

Do NOT ask about characteristics the user already confirmed as irrelevant. One question per message.

### Phase 3: Fitness Function Confirmation

For each Critical characteristic, propose whether a fitness function makes sense and what type (Atomic/Holistic). Present as a table, ask for confirmation once — not per row:

> | Characteristic | Proposed FF | Cadence | Tool |
> |---|---|---|---|
> | Performance | API response < 200ms p95 | Holistic (PR) | k6/autocannon |
> | Modularity | No circular dependencies | Atomic (commit) | dependency-cruiser |
>
> "Should all of these have automated fitness functions, or would you skip any?"

### Phase 4: Top-3 Prioritization

Based on the confirmed characteristics, propose your top 3 with reasoning. Follow `references/proactive-analysis.md`:

> "Based on [domain drivers], I recommend these as the top 3:"
>
> **Option A (recommended): [char1], [char2], [char3]**
> Reasoning: [char1] because..., [char2] because..., [char3] because...
>
> **Option B: [char1], [char2], [char4]** — swapping [char3] for [char4]
> Better if [condition]. Trade-off: [what you lose].
>
> "Which prioritization fits — or would you rearrange?"

If the top 3 are clearly separated from the rest (e.g., three Critical characteristics and the rest is Important), present your recommendation directly and ask for confirmation. Only use the multi-option format when priorities are genuinely close — per `references/uncertainty-handling.md`.

**Uncertainty handling:** If you are unsure about prioritization (e.g., two characteristics seem equally important), follow the Uncertainty Handling Pattern in `references/uncertainty-handling.md`: name the uncertainty, present 2-3 options with tradeoffs, and use AskUserQuestion with structured choices. Do NOT present an uncertain recommendation as settled and ask "Passt das?".

The top 3 become the primary architecture drivers.

## Critical Update Mode (Existing Projects)

When `architecture.md` already exists, be SKEPTICAL about changes:

1. Show the user the current top 3 characteristics
2. Ask: "Does this new feature change our architecture requirements?"
3. If the user wants changes:
   - Ask: "Why does this change the architecture? What is different now?"
   - Challenge: "Could we achieve this within the current architecture constraints?"
   - If truly justified: Update with changelog entry and invoke `superflowers:architecture-decisions` to create an ADR documenting why the characteristics changed
   - If not justified: Recommend keeping the existing architecture

**Architecture should be stable.** Frequent changes to architecture characteristics are a red flag — either the initial assessment was incomplete or requirements are being confused with architecture.

## Example: Good vs Bad Characteristic Goals

❌ **BAD — Vague goals:**
| Characteristic | Goal |
|---|---|
| Performance | Good performance |
| Security | Secure system |
| Scalability | Must scale |

✅ **GOOD — Concrete, measurable goals:**
| Characteristic | Goal |
|---|---|
| Performance | API response < 200ms p95 under normal load |
| Security | Zero known CVEs in dependencies, all PII encrypted at rest |
| Scalability | Handle 10,000 concurrent users with < 5% latency increase |

## Red Flags — STOP

- Changing top-3 characteristics for every new feature (architecture is not feature-specific)
- Adding characteristics without removing or deprioritizing others (complexity budget)
- Vague goals like "good performance" without concrete metrics
- Skipping the questionnaire because "we already know what we need"
- Treating every requirement as a new architecture characteristic

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Architecture doesn't change for this feature" | Review it anyway. 2 minutes to confirm stability. |
| "We need to completely restructure" | Architecture evolves incrementally. Justify each change with concrete evidence. |
| "Performance isn't important yet" | Performance is an architecture characteristic, not an afterthought. Retrofitting is 10x harder. |
| "We'll figure out the architecture later" | Later = technical debt. Every design decision is an architecture decision. |
| "This is just a prototype" | Prototypes become products. Define characteristics now, even if minimal. |
| "The architecture is obvious" | Obvious to you. Document it so the implementing agent shares your understanding. |

## Verification

After writing or updating architecture.md, dispatch a fresh agent using `superflowers:architecture-reviewer agent (agents/architecture-reviewer.md)` to verify:
1. All characteristics have concrete, measurable goals
2. Top 3 are clearly identified and justified
3. No contradictions between characteristics
4. Fitness function column is populated for critical characteristics
5. Changelog reflects the change accurately

## Reference Files

- `../architecture-style-selection/references/architecture-characteristics-reference.md` — Canonical definitions for all architecture characteristics from the Ford/Richards Architecture Characteristics Worksheet. Use these definitions when walking the user through the questionnaire.
- `references/proactive-analysis.md` — The "analyze first, propose options" meta-pattern

## The Bottom Line

Architecture characteristics defined before any design decision. No exceptions.

## Integration

**Called after:** superflowers:bounded-context-design (domain boundaries inform characteristics)
**Reads:** `context-map.md` if it exists (from bounded-context-design)
**Runs before:** superflowers:architecture-style-selection (style selection needs characteristics)
**Then:** superflowers:feature-design (architecture informs scenarios)
**During implementation:** superflowers:fitness-functions verifies compliance
**Pairs with:** superflowers:feature-design (BDD for behavior, fitness functions for architecture)
