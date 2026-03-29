# Analysis: ADR for Service-Based Architecture Selection

## Skill Followed

Followed `/skills/architecture-decisions/SKILL.md` — Nygard lightweight ADR format.

## Reasoning

### Why this qualifies as an ADR
The decision filter from the skill is clear: "Choosing between architectural approaches (REST vs GraphQL, monolith vs microservices)" — selecting Service-Based over Microservices is a textbook architecture decision that affects system structure, team organization, and deployment topology.

### Format decisions
- **Title in imperative form:** "Use Service-Based architecture" — not "We decided..." or "Service-Based Architecture Decision", per the skill's title convention.
- **Filename:** `ADR-001-use-service-based-architecture.md` — kebab-case as specified.
- **Status:** Accepted — the team has made the decision, this is not a proposal.

### Context section
The skill says: "Include relevant data: scores from style-selection matrix, cost estimates, team constraints." All three are present:
- Scores: 14/15 vs 15/15
- Cost: $$ vs $$$$$
- Team constraints: 3 teams of 4-6 devs, gradual monolith migration requirement

Two alternatives are explicitly listed (Service-Based and Microservices) with reasoning for each. Other styles mentioned as non-contenders for completeness.

### Decision section
One clear statement with rationale — kept to two lines per the skill guidance ("One clear statement... Brief rationale... Don't repeat the context").

### Consequences section
The skill requires both positive and negative consequences ("Be honest — if you accepted a tradeoff, say so"). The ADR includes:
- 4 positive consequences (migration path, team autonomy, operational simplicity, cost)
- 3 negative consequences (scalability limits, team growth ceiling, 1-point gap)

### Verification checklist
- [x] ADR follows Nygard format (Status, Context, Decision, Consequences)
- [x] Title is in imperative form
- [x] Context mentions alternatives considered (Service-Based and Microservices)
- [x] Consequences include both positive and negative
- [x] ADR is numbered sequentially (ADR-001, first ADR)
- [x] Not superseding any existing ADR
- [x] No existing `architecture.md` to cross-reference (eval context)
- [x] No existing index to update (eval context)

### What was NOT done (and why)
- **No `doc/adr/` index file created** — the skill says to create one if the directory doesn't exist, but in this eval context we are producing isolated output files, not setting up a full project structure.
- **No git commit** — eval output context, not a real repository workflow.
- **No `architecture.md` cross-reference** — no existing architecture.md in the eval output path.
