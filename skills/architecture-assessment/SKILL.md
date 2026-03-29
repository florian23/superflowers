---
name: architecture-assessment
description: Use AFTER brainstorming completes and BEFORE writing specs or feature files - identifies and documents architecture characteristics, drivers, and quality attributes through structured stakeholder dialogue. Maintains a persistent architecture.md file.
---

# Architecture Assessment

Identify, document, and maintain architecture characteristics through structured dialogue with the user. The architecture is a persistent, evolving artifact — not a one-time decision.

**Semantic anchors:** This skill applies ATAM (Architecture Tradeoff Analysis Method) for quality attribute analysis and tradeoff identification, arc42 for structured architecture documentation, Clean Architecture for testability and layer independence, Domain-Driven Design for bounded contexts and strategic design, and Definition of Done with architecture compliance gates.

**Announce at start:** "I'm using the architecture-assessment skill to identify architecture characteristics for this project."

## The Iron Law

```
NO SPEC WITHOUT ARCHITECTURE CHARACTERISTICS
```

You cannot make design decisions without knowing which quality attributes matter. Define them first.

<HARD-GATE>
Do NOT proceed to writing specs, feature-design, or writing-plans until
architecture characteristics are documented in architecture.md and the
user has approved them. This applies to EVERY project regardless of
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
    "User approves\ncharacteristics?" [shape=diamond];
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
    "Top-3 prioritization" -> "User approves\ncharacteristics?";
    "User approves\ncharacteristics?" -> "Structured questionnaire\ndialog" [label="revise"];
    "User approves\ncharacteristics?" -> "Write architecture.md" [label="approved"];
    "Write architecture.md" -> "Dispatch verification agent";
    "Dispatch verification agent" -> "Return to brainstorming\n(feature-design next)";
}
```

## The Persistent Architecture File

**Path:** `architecture.md` in the project root.

This file evolves over time. It is NOT recreated for each feature — it is updated incrementally.

- **File exists:** Read it, show current characteristics to the user, critically assess whether changes are needed
- **File does not exist:** Create it through the structured questionnaire dialog
- **After changes:** Dispatch a fresh verification agent to check consistency (see `architecture-reviewer-prompt.md`)

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
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---------------|----------|---------------|-----------------|
| Performance | Critical | API <200ms p95 | Yes - load test |
| Availability | Important | 99.9% uptime | Yes - health check |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---------------|----------|---------------|-----------------|
| Modularity | Critical | No circular deps | Yes - dependency check |
| Testability | Important | >80% coverage | Yes - coverage gate |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---------------|----------|---------------|-----------------|
| Security | Critical | No known CVEs | Yes - vulnerability scan |

## Architecture Drivers
- [Driver]: [Why it matters, which characteristic it influences]

## Architecture Decisions
- [Decision]: [Rationale, which characteristic it addresses]

## Changelog
- YYYY-MM-DD: Initial architecture assessment
```

## The Questionnaire Dialog (New Projects)

Walk the user through each category. Ask one question at a time. Use the full questionnaire from `questionnaire-template.md`.

### Phase 1: Operational Characteristics

For each characteristic, ask:
1. **Relevance:** "How important is [X] for this system?" (critical / important / nice-to-have / irrelevant)
2. **Concreteness** (if critical/important): "What does [X] mean concretely? For example: response time <200ms, 99.9% uptime, 1000 concurrent users"
3. **Fitness Function:** "Should we automate a check for this?" (yes/no)

Characteristics to assess:
- **Availability** — How much downtime is acceptable?
- **Performance** — What are the latency/throughput requirements?
- **Scalability** — How many users/requests must the system handle? Growth expectations?
- **Reliability** — What happens when things fail? Recovery requirements?
- **Fault Tolerance** — Must the system continue operating during partial failures?

### Phase 2: Structural Characteristics

- **Modularity** — How important is clean separation of concerns?
- **Extensibility** — How often will new features be added? By whom?
- **Testability** — What level of automated testing is required?
- **Deployability** — How often will the system be deployed? Blue/green? Rolling?
- **Coupling** — Are there integration points with external systems?

### Phase 3: Cross-Cutting Characteristics

- **Security** — What data is handled? Authentication/authorization requirements?
- **Compliance** — Regulatory requirements (GDPR, HIPAA, SOC2)?
- **Accessibility** — WCAG requirements?
- **Usability** — Who are the users? Technical sophistication?
- **Observability** — Logging, monitoring, tracing requirements?

### Phase 4: Top-3 Prioritization

After collecting all characteristics, present the critical/important ones and ask:

> "Every architecture characteristic adds complexity. Which are your TOP 3 — the ones that should drive architecture decisions above all others?"

The top 3 become the primary architecture drivers.

## Critical Update Mode (Existing Projects)

When `architecture.md` already exists, be SKEPTICAL about changes:

1. Show the user the current top 3 characteristics
2. Ask: "Does this new feature change our architecture requirements?"
3. If the user wants changes:
   - Ask: "Why does this change the architecture? What is different now?"
   - Challenge: "Could we achieve this within the current architecture constraints?"
   - If truly justified: Update with changelog entry
   - If not justified: Recommend keeping the existing architecture

**Architecture should be stable.** Frequent changes to architecture characteristics are a red flag — either the initial assessment was incomplete or requirements are being confused with architecture.

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

After writing or updating architecture.md, dispatch a fresh agent using `architecture-reviewer-prompt.md` to verify:
1. All characteristics have concrete, measurable goals
2. Top 3 are clearly identified and justified
3. No contradictions between characteristics
4. Fitness function column is populated for critical characteristics
5. Changelog reflects the change accurately

## Integration

**Called after:** superflowers:brainstorming
**Runs before:** superflowers:feature-design (architecture informs scenarios)
**During implementation:** superflowers:fitness-functions verifies compliance
**Pairs with:** superflowers:feature-design (BDD for behavior, fitness functions for architecture)
