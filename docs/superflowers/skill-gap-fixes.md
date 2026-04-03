# Skill Gap Fixes — Draft for Review

Fixes für alle 8 Gaps aus der Evaluation gegen Superpowers-Standards.
Review-Agent soll jeden Fix gegen die Superpowers-Patterns und `docs/superflowers/upstream-tracking.md` prüfen.

## Gap 1: Bottom Line Statements (alle 20 Custom Skills)

Jeder Skill bekommt ein `## The Bottom Line` als letzten Abschnitt (vor Integration, falls vorhanden):

| Skill | Bottom Line |
|---|---|
| architecture-assessment | Architecture characteristics defined before any design decision. No exceptions. |
| architecture-decisions | Every significant architecture decision gets an ADR. Undocumented decisions are invisible decisions. |
| architecture-style-selection | The style serves the driving characteristics — not the other way around. |
| bdd-testing | Every Gherkin step has a Step Definition. Every scenario passes. Partial is failure. |
| bounded-context-design | Domain boundaries before architecture boundaries. If you can't name the ubiquitous language, you don't understand the boundary. |
| coding-eval | Measure skill impact with data, not intuition. RED vs GREEN — let the numbers decide. |
| compliance-report | Git history is the audit trail. If it's not in a commit, it didn't happen. |
| constraint-selection | Active constraints are guardrails, not obstacles. Every constraint has verification criteria. |
| domain-understanding | Understand the domain before designing the solution. If the glossary is empty, the model is invented. |
| feature-design | If you can't express it as Given-When-Then, you don't understand the requirement. |
| fitness-functions | Architecture without automated verification is wishful thinking. |
| market-analysis | Know your competition before you design your product. Core Subdomains are where you differentiate — everything else is table stakes. |
| project-constraints | Constraints are organizational reality. Ignoring them doesn't make them go away. |
| quality-scenarios | Every architecture characteristic needs a concrete, measurable quality scenario. Abstract goals produce abstract architecture. |
| risk-storming | Consensus on risk areas prevents surprise failures. If the team hasn't agreed on what's Red, nobody owns the mitigation. |
| upstream-sync | Every changeset gets a conscious decision. Blind merges destroy intentional divergence. |
| ux-design | UX design before UI implementation. Research → Flows → Wireframes — skip a phase, pay later. |
| ux-research | Draft personas from evidence, not imagination. Every persona has a goal and a frustration grounded in context. |
| ux-flows | Task flows describe what users DO, not what the system shows. If the flow has no decision points, it's a feature list. |
| ux-wireframes | Show options, not one answer. 2-3 layout alternatives with tradeoffs — then the user decides. |

## Gap 2: "user" vs "your human partner"

**Decision: Keep "user" in our fork.** 

Reasoning: "your human partner" is obra's deliberate terminology for Superpowers' relationship-building approach. Our fork uses "user" consistently and changing it would touch hundreds of lines across 20 skills for a stylistic preference. We document this as an intentional divergence, not a gap.

## Gap 3: Red Flags + Rationalization Tables (7 Skills)

### ux-research

```markdown
## Red Flags — STOP

- Personas invented without reading domain-profile.md or market-analysis.md (hallucinated personas)
- All personas have the same frustration (copy-paste personas)
- JTBD written as feature requests instead of user goals ("I want a dashboard" vs "I want to see my status at a glance")
- Skipping persona refinement ("3 personas are enough, let's move on" without user confirmation)
- HMW questions that are actually solutions ("How might we add a filter?" instead of "How might we help users find relevant items quickly?")

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "We already know our users" | Write it down. Implicit knowledge produces implicit assumptions. |
| "Personas are just overhead" | Every downstream skill (flows, wireframes, scenarios) needs a persona. Skip this, break the chain. |
| "One persona is enough" | One persona means one perspective. Edge cases live in the personas you didn't create. |
| "The spec already describes the users" | The spec describes features. Personas describe people — goals, frustrations, context. |
| "We can refine personas later" | Personas anchor every design decision. Refining later means redesigning later. |
```

### ux-flows

```markdown
## Red Flags — STOP

- Flows without persona reference ("the user clicks..." — which user? Which goal?)
- Happy path only — no error branches, no edge cases
- Linear flow for a non-linear task (forcing wizard when hub-and-spoke fits better)
- Flow steps that describe system behavior instead of user actions ("system validates input" → "user sees validation error")
- Skipping Information Architecture ("we'll figure out navigation later")

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "The happy path is enough for now" | Error cases determine UI complexity. Discover them now or redesign later. |
| "Navigation is obvious" | Obvious to you. Test it with the persona's mental model, not yours. |
| "We don't need a diagram" | Diagrams expose missing steps. Text descriptions hide them. |
| "Edge cases are rare" | Rare cases are where users get stuck. Those are the flows that need the most design. |
| "We can add error handling later" | Error flows change the happy path. They're not additive — they're structural. |
```

### ux-wireframes

```markdown
## Red Flags — STOP

- Wireframes without referencing task flows (designing screens without knowing the flow)
- Only one layout option presented ("here's the design" instead of "here are 2-3 options")
- Missing states: no loading, no error, no empty state (only success state designed)
- Pixel-perfect details in low-fi phase (colors, fonts, shadows before structure is confirmed)
- Skipping usability validation ("the wireframes look good to me")

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "One layout is clearly the right choice" | Present options anyway. The user sees tradeoffs you don't. |
| "Empty states don't matter" | Empty state is the first thing new users see. It IS the onboarding. |
| "We'll handle errors in development" | Error states need design. A raw error message is not a design decision. |
| "Low-fi doesn't need all states" | Low-fi is where you discover missing states. That's the point. |
| "The review agent will catch issues" | The review agent validates against heuristics. It can't fix a missing layout alternative. |
```

### ux-design (Orchestrator)

```markdown
## The Iron Law

```
NO UI IMPLEMENTATION WITHOUT COMPLETING THE UX DESIGN PHASES
```

Research → Flows → Wireframes → Validation. Skip a phase, pay in rework.

<HARD-GATE>
Do NOT proceed to writing-plans or implementation until:
1. Personas and HMW questions exist (ux-research)
2. Task flows are mapped for priority scenarios (ux-flows)
3. Wireframes are designed with all states (ux-wireframes)
4. Usability validation passed (ux-reviewer agent returned APPROVED)
</HARD-GATE>

## Red Flags — STOP

- Jumping to wireframes without personas or flows
- "We know what the UI should look like" without evidence
- Skipping ux-reviewer validation ("wireframes look fine")
- Designing all screens at once instead of priority-first
- Running all three phases in one message instead of step-by-step dialog

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "The UI is simple, we don't need UX research" | Simple UIs still have users with goals and frustrations. |
| "We can do UX later" | UX after implementation means redesign, not refinement. |
| "We already have a design spec" | A spec is input to ux-research, not a replacement for it. |
| "We only have one screen" | One screen with 5 states is 5 designs. Research and flows still apply. |
```

### domain-understanding

```markdown
## Red Flags — STOP

- Domain profile written without reading any project files or documentation
- All terms in the glossary are technical (no business terms)
- Business rules section is empty ("no special rules")
- Domain profile contradicts existing code or documentation
- Skipping domain expert interview questions ("we understand the domain")

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "The spec already explains the domain" | The spec explains features. The domain profile explains the business — rules, constraints, language. |
| "This domain is well-known (e-commerce, CRM, etc.)" | Every business has domain-specific rules. "Well-known" domains have the most hidden assumptions. |
| "We can learn the domain during implementation" | Implementation decisions without domain understanding produce technical solutions to business problems. |
| "The domain profile is just documentation" | The domain profile feeds bounded-context-design and feature-design. Wrong domain model → wrong boundaries → wrong architecture. |
```

### coding-eval

```markdown
## Red Flags — STOP

- Comparing RED vs GREEN with different prompts or different tasks
- GREEN agent not loading the skill being evaluated
- Declaring a skill "works" based on a single task
- Ignoring RED agent results ("it failed without the skill, as expected")
- Modifying the skill between eval runs without restarting

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "One task is enough to validate" | One data point is an anecdote, not evidence. Run multiple tasks. |
| "The RED agent obviously fails" | If RED succeeds, your skill isn't adding value. That's a finding, not a bug. |
| "The skill clearly helps, we don't need evals" | Clearly to whom? Measure it. Intuition is not evidence. |
| "Eval setup takes too long" | A skill that doesn't improve outcomes wastes more time than the eval. |
```

### compliance-report

```markdown
## Red Flags — STOP

- Report generated without reading git history ("based on project structure alone")
- Compliance scores without evidence (no commit references)
- Metrics plugin results not cross-referenced with actual files
- Report claims 100% compliance without verification commands run
- Report generated from file structure without running any verification commands

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "The report is just informational" | Compliance reports drive decisions. Wrong data drives wrong decisions. |
| "Git history is too large to analyze" | Use date ranges and path filters. Partial analysis beats no analysis. |
| "We trust the team followed the process" | Trust but verify. That's what compliance means. |
| "The metrics plugins handle compliance automatically" | Automation doesn't replace interpretation. Plugin output needs context. |
```

## Gap 4: Verification Sections (10 Skills)

### ux-research

```markdown
## Verification Checklist

- [ ] At least 2 personas created with all fields filled (Name, Role, Goal, Frustration, Tech Affinity, Context)
- [ ] Each persona has at least 1 JTBD in correct format (When/I want/So I can)
- [ ] HMW questions are framed as opportunities, not solutions
- [ ] Personas are grounded in context (domain-profile.md, market-analysis.md referenced)
- [ ] User has confirmed personas and prioritized HMW questions
- [ ] Output written to ux-design.md in correct format
```

### ux-flows

```markdown
## Verification Checklist

- [ ] Each task flow references a specific persona and scenario
- [ ] Happy path is complete (entry point → success state)
- [ ] Error branches are mapped (at least 2 per flow)
- [ ] Exit points are defined (what happens on abort?)
- [ ] Flow rendered as DOT diagram or numbered steps
- [ ] User has confirmed each flow before moving to next
- [ ] Output written to ux-design.md in correct format
```

### ux-wireframes

```markdown
## Verification Checklist

- [ ] Each screen has 2-3 layout options with described tradeoffs
- [ ] User has chosen layout direction before state design
- [ ] All states designed: loading, error, empty, success (minimum)
- [ ] Wireframes reference task flows (not designed in isolation)
- [ ] ux-reviewer agent dispatched and returned APPROVED
- [ ] Output written to ux-design.md in correct format
```

### domain-understanding

```markdown
## Verification Checklist

- [ ] Domain profile contains: business context, key entities, business rules, domain events, glossary
- [ ] Glossary uses business terms (not technical jargon)
- [ ] Business rules are concrete and testable (not vague "handle errors")
- [ ] Domain profile references project files or documentation as evidence
- [ ] User has confirmed the domain profile
- [ ] Output written to domain-profile.md
```

### market-analysis

```markdown
## Verification Checklist

- [ ] At least 3 competitors analyzed (direct or indirect)
- [ ] Feature comparison matrix with clear differentiation markers
- [ ] Subdomain classification complete (Core/Supporting/Generic with rationale)
- [ ] Quality requirements derived from market forces
- [ ] User has confirmed the analysis and differentiation strategy
- [ ] Output written to market-analysis.md
```

### risk-storming

```markdown
## Verification Checklist

- [ ] All bounded contexts / major components assessed for risk
- [ ] Risk ratings assigned (Red/Yellow/Green) with consensus
- [ ] Mitigation strategies proposed for Red risks
- [ ] Risk map rendered as table or DOT diagram
- [ ] User has confirmed risk assessment
- [ ] Mitigation strategies for Red risks documented with owner and timeline
```

### coding-eval

```markdown
## Verification Checklist

- [ ] RED agent (without skill) and GREEN agent (with skill) ran the same tasks
- [ ] Both agents used identical prompts and constraints
- [ ] Results compared quantitatively (pass/fail, quality metrics)
- [ ] At least 3 tasks evaluated
- [ ] Results documented with specific task names and outcomes
```

### compliance-report

```markdown
## Verification Checklist

- [ ] Git history analyzed for the specified date range
- [ ] Each compliance metric has commit-level evidence
- [ ] Metrics plugin results cross-referenced with actual files
- [ ] Report includes both passing and failing compliance items
- [ ] Interactive HTML report generated (if configured)
```

### constraint-selection

```markdown
## Verification Checklist

- [ ] All constraints from repository evaluated (none skipped)
- [ ] Each constraint classified as Relevant/Irrelevant/Uncertain with rationale
- [ ] Uncertain constraints escalated to user for decision
- [ ] Active constraints have concrete verification criteria
- [ ] User has confirmed the constraint selection
- [ ] Output written to docs/superflowers/constraints/
```

## Gap 5: Good/Bad Examples (Top 5 Skills)

### feature-design — Scenario Quality

```markdown
## Example: Good vs Bad Scenarios

❌ **BAD — Implementation details in scenarios:**
```gherkin
Scenario: User logs in
  Given the user sends POST /api/auth with {"email": "test@test.com", "password": "123"}
  When the server returns 200 with a JWT token
  Then the token is stored in localStorage
```

✅ **GOOD — Declarative, domain language:**
```gherkin
Scenario: Successful login
  Given a registered user with valid credentials
  When the user logs in
  Then the user sees their dashboard
```

❌ **BAD — Multiple behaviors in one scenario:**
```gherkin
Scenario: User management
  Given a new user registers
  When they verify their email
  And they update their profile
  Then their profile is complete
```

✅ **GOOD — Single behavior per scenario:**
```gherkin
Scenario: Email verification
  Given a newly registered user
  When they click the verification link
  Then their account is verified
```
```

### architecture-assessment — Characteristic Goals

```markdown
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
```

### bdd-testing — Step Definition Quality

```markdown
## Example: Good vs Bad Step Definitions

❌ **BAD — Business logic in Step Definition:**
```javascript
When('the order total is calculated', function() {
  let total = 0;
  for (const item of this.cart.items) {
    total += item.price * item.quantity;
    if (item.discount) total -= item.discount;
  }
  this.orderTotal = total;
});
```

✅ **GOOD — Thin glue, delegates to application code:**
```javascript
When('the order total is calculated', function() {
  this.orderTotal = this.orderService.calculateTotal(this.cart);
});
```
```

### quality-scenarios — Verification Type Classification

```markdown
## Example: Good vs Bad Verification Type Assignment

❌ **BAD — Everything is a unit-test:**
| Scenario | Verification Type |
|---|---|
| API responds within 200ms | unit-test |
| System recovers from database failure | unit-test |
| No circular dependencies between modules | unit-test |

✅ **GOOD — Matched to actual verification method:**
| Scenario | Verification Type |
|---|---|
| API responds within 200ms | load-test |
| System recovers from database failure | chaos-test |
| No circular dependencies between modules | fitness-function |
```

### bounded-context-design — Boundary Decisions

```markdown
## Example: Good vs Bad Context Boundaries

❌ **BAD — Technical boundaries:**
| Context | Responsibility |
|---|---|
| Frontend Context | All UI code |
| Backend Context | All API code |
| Database Context | All persistence |

✅ **GOOD — Domain boundaries:**
| Context | Responsibility |
|---|---|
| Checkout | Order placement, payment intent, shipping selection |
| Fulfillment | Pick lists, shipping labels, tracking |
| Catalog | Product data, search, recommendations |
```
```

## Gap 6: ux-design Orchestrator Aufwertung

Siehe Gap 3 oben — ux-design bekommt Iron Law, HARD-GATE, Red Flags, Rationalization.

## Gap 7: coding-eval und compliance-report

Siehe Gap 3 + Gap 4 oben — beide bekommen Red Flags, Rationalization, Verification.

## Gap 8: Semantic Anchors (6 Skills)

| Skill | Semantic Anchors |
|---|---|
| coding-eval | **Semantic anchors:** A/B Testing for skill evaluation, RED/GREEN comparison methodology, FeatureBench for standardized task evaluation. |
| compliance-report | **Semantic anchors:** Git-based audit trail, Microkernel plugin architecture for metrics, compliance verification through commit history analysis. |
| constraint-selection | **Semantic anchors:** Organizational constraints as architecture drivers, constraint verification criteria, feature-specific constraint scoping. |
| project-constraints | **Semantic anchors:** Organizational constraint repository, constraint catalog management, constraint lifecycle management. |
| upstream-sync | **Semantic anchors:** Git three-way merge, cherry-pick, semantic diff analysis, fork maintenance, upstream tracking. |
| ux-design | **Semantic anchors:** Design Thinking Double Diamond, UX orchestration (Research → Flows → Wireframes → Validation), Nielsen's 10 Usability Heuristics. |
