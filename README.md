<p align="center">
  <img src="assets/logo.svg" alt="Superflowers" width="600">
</p>

<p align="center">
  <strong>A composable skills library for coding agents that solves four problems spec-driven frameworks ignore.</strong>
</p>

Based on [Superpowers](https://github.com/obra/superpowers) v5.0.6 by [Jesse Vincent](https://github.com/obra).

## Why This Fork Exists

Spec-driven development frameworks (Cursor Rules, Claude CLAUDE.md, Copilot Instructions) help agents write better code. But they share four blind spots that compound as projects grow.

### 1. Organizational Constraints Are Invisible

Every organization has compliance policies, security guidelines, and technology standards. These live in wikis, Confluence pages, or separate repos — not in the codebase. Spec-driven frameworks don't know they exist. The agent builds a feature that violates your encryption-at-rest policy because nobody told it that policy exists.

Anthropic's own research confirms this: "Real work requires procedural knowledge and organizational context" that agents simply don't have access to ([Equipping Agents with Agent Skills](https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills), 2025). Their applied AI team frames context as "a finite strategic resource" — without deliberate context engineering, agents cannot access organizational knowledge outside the codebase ([Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), 2025). Research on autonomous agents shows they deprioritize ethical and compliance constraints under performance pressure, with 0% success on tasks requiring organizational context ([arXiv:2512.20798](https://arxiv.org/abs/2512.20798), 2024).

**Superflowers solution:** `constraint-selection` and `project-constraints` read from an external constraint repository and filter relevant constraints per feature. Downstream skills (architecture, feature design, planning) reference these constraints automatically. The constraints flow through the entire pipeline — they're not an afterthought.

### 2. Architecture Erodes Over Time

The longer a project runs, the more the agent forgets why early design decisions were made. It refactors a module in a way that breaks the architectural style. It changes a data flow that violates a quality attribute. There's no guardrail — just hope that the agent remembers.

This is measurable: a 40-person survey found signs of architectural erosion — lower cohesion — in AI-generated code as complexity increases ([arXiv:2506.17833](https://arxiv.org/abs/2506.17833), 2025). Empirical analysis of AI-generated microservices found an 80% architectural violation rate in open-weights models ([arXiv:2512.04273](https://arxiv.org/abs/2512.04273), 2025). Anthropic calls this "context rot" — as token count rises, n-squared attention relationships degrade recall of early decisions ([Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), 2025). The concept of fitness functions as automated architecture compliance checks was introduced by Ford, Parsons, and Kua in [Building Evolutionary Architectures](https://www.oreilly.com/library/view/building-evolutionary-architectures/9781491986356/) (O'Reilly, 2017).

**Superflowers solution:** `architecture-assessment` persists characteristics in `architecture.md`. `architecture-decisions` records every significant choice as an immutable ADR. `fitness-functions` creates automated checks that fail the build when architecture is violated. The architecture is a living, enforced artifact — not a forgotten document.

### 3. Existing Features Break Silently

When you add Feature B, Feature A might break. Spec-driven frameworks have no hard control gates for this — they rely on the agent noticing. It often doesn't.

GitClear's analysis of 211M lines of code found that AI-assisted development led to 4x growth in code cloning and doubled code churn, while refactoring dropped from 25% to under 10% ([AI Copilot Code Quality](https://www.gitclear.com/ai_assistant_code_quality_2025_research), 2025). CodeRabbit found AI-generated code creates 1.7x more issues than human code across all quality categories ([State of AI vs Human Code Generation](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report), 2025). Google's DORA team concluded: without robust testing, increased AI-driven change volume leads to instability — TDD is more critical than ever ([DORA Report](https://cloud.google.com/discover/how-test-driven-development-amplifies-ai-success), 2025). Thoughtworks warns of "complacency with AI-generated code" — agents generate larger change sets that are harder to review ([Technology Radar](https://www.thoughtworks.com/en-us/radar/techniques/complacency-with-ai-generated-code), 2024).

**Superflowers solution:** `feature-design` creates BDD scenarios as executable acceptance criteria. `bdd-testing` wires them to real step definitions. Every feature has a regression gate: if existing scenarios fail after your change, the pipeline stops. `verification-before-completion` requires evidence (actual test output), not claims ("tests pass").

### 4. Agents Review Their Own Work

Research warns against self-review: agents praise their own output and miss blind spots. Most frameworks have the same agent that wrote the code also verify it.

A NeurIPS 2024 oral paper proved a causal link between self-recognition and self-preference: LLMs that recognize their own output rate it higher ([Panickssery et al., arXiv:2404.13076](https://arxiv.org/abs/2404.13076)). Further research confirmed LLMs exhibit significant self-preference bias driven by familiarity ([arXiv:2410.21819](https://arxiv.org/abs/2410.21819), 2024). The foundational MT-Bench paper identified position bias, verbosity bias, and self-enhancement bias as systematic limitations of LLM-as-judge ([Zheng et al., NeurIPS 2023](https://arxiv.org/abs/2306.05685)). Multi-agent approaches with separate judge models reduce shared blind spots — improving HumanEval pass@1 from 76.4 to 82.6 compared to self-review ([arXiv:2512.20845](https://arxiv.org/abs/2512.20845), 2024).

**Superflowers solution:** 12 independent reviewer agents (`agents/`) each verify a specific artifact with fresh context. The review-loop pattern (`agents/reviewer-protocol.md`) dispatches a fresh agent, reads the verdict, fixes issues, and re-dispatches until APPROVED. The agent that wrote the code never reviews it.

## Installation

### From GitHub (recommended)

```bash
# In Claude Code:
/plugin marketplace add florian23/superflowers
/plugin install superflowers@florian23-superflowers
```

### Local Development

```bash
claude --plugin-dir /path/to/superflowers
```

### Verify

Start a new Claude Code session. Skills should load with the `superflowers:` prefix.

## The Complete Workflow

```
Brainstorming ──► Domain Understanding ──► Market Analysis ──► Constraint Selection
                                                                       │
Architecture Assessment ◄── Bounded Context Design ◄──────────────────┘
      │
      ▼
Style Selection ──► Quality Scenarios ──► Feature Design ──► Writing Plans
                                                                    │
                                                                    ▼
Implementation (TDD) ──► BDD Testing ──► Fitness Functions ──► Verification ──► Finishing
```

### Phase 1: Specification (what to build)

1. **brainstorming** — Refine the idea through questions, explore approaches, present design for validation
2. **domain-understanding** — Build a domain profile before design questions
3. **market-analysis** — Competitive landscape, differentiation strategy, Core/Supporting/Generic subdomain classification
4. **constraint-selection** — Select organizational constraints relevant to this feature
5. **bounded-context-design** — DDD strategic design: subdomain classification, context maps, ubiquitous language
6. **architecture-assessment** — Identify and prioritize architecture characteristics (Ford/Richards, ATAM)
7. **architecture-style-selection** — Score styles against driving characteristics, generate style fitness functions
8. **risk-storming** — 5 parallel agents assess architecture risks from independent perspectives (Security, Performance, Ops, Data, Code Drift), reach consensus, produce mitigation plan
9. **quality-scenarios** — Concrete, testable quality scenarios with test-type classification
10. **ux-design** — Orchestrates 4 UX phases: `ux-research` (personas, JTBD) → `ux-flows` (user flows, IA) → `ux-wireframes` (low→mid→high-fi, all states) → `ux-validate` (Nielsen's 10 heuristics)
11. **feature-design** — BDD acceptance criteria as Gherkin `.feature` files

### Phase 2: Planning

10. **writing-plans** — Break work into bite-sized TDD tasks referencing all specification artifacts

### Phase 3: Implementation

11. **using-git-worktrees** — Create isolated workspace on a new branch
12. **subagent-driven-development** or **executing-plans** — Execute plan with two-stage review per task
13. **test-driven-development** — RED-GREEN-REFACTOR cycle
14. **bdd-testing** — Wire `.feature` files to step definitions
15. **fitness-functions** — Implement and verify architecture compliance checks

### Phase 4: Verification & Delivery

16. **verification-before-completion** — Evidence-based completion gate (actual output, not claims)
17. **requesting-code-review** / **receiving-code-review** — Structured code review
18. **finishing-a-development-branch** — Verify tests, merge/PR/keep/discard, clean up

### Cross-Cutting

- **architecture-decisions** — Immutable ADRs (Nygard format) throughout the entire workflow
- **compliance-report** — Git-based tracking of workflow compliance over time
- **systematic-debugging** — 4-phase root cause analysis when blocked

## Architecture Decision Records (ADRs)

Every significant architecture decision — hard to reverse, structural impact — is captured as an immutable [ADR](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) (Nygard format) in `doc/adr/`.

**Created** by the `architecture-decisions` skill, triggered when decisions are made during:

| Event | Example ADR |
|---|---|
| Top-3 characteristics prioritized | "Prioritize Scalability, Security, Interoperability" |
| Architecture style selected | "Use Modular Monolith architecture" |
| Quality tradeoff resolved | "Accept eventual consistency for scalability" |
| Unplanned structural change | "Introduce Redis for session caching" |

**Verified** by the `architecture-decision-reviewer` after every ADR — checks format, consistency with active ADRs, superseding cascade correctness, and fitness function traceability.

**Enforced** through fitness functions: every FF has an ADR reference column tracing back to the decision that justified it. When an ADR is superseded, a cascade replaces affected FFs, updates the index, and re-evaluates downstream artifacts. The old ADR's content stays immutable — only its status changes.

## Independent Reviewer Agents

Every specification artifact is verified by a fresh agent that did not create it:

| Agent | Verifies | Dispatched by |
|---|---|---|
| architecture-reviewer | Characteristics completeness | architecture-assessment |
| architecture-decision-reviewer | ADR consistency and cascade | architecture-decisions |
| architecture-style-reviewer | Style scoring correctness | architecture-style-selection |
| constraint-reviewer | Constraint matching | constraint-selection |
| project-constraint-reviewer | Project baseline | project-constraints |
| quality-scenario-reviewer | Scenario coverage | quality-scenarios |
| feature-file-reviewer | Gherkin quality | feature-design |
| plan-reviewer | Plan completeness | writing-plans |
| bdd-step-reviewer | Step definition quality | bdd-testing |
| fitness-function-reviewer | FF correctness | fitness-functions |
| spec-reviewer | Code matches spec | subagent-driven-development |
| code-reviewer | Code quality | subagent-driven-development |

All reviewers follow the 4-step loop from `agents/reviewer-protocol.md`: dispatch → verdict → fix → re-dispatch until APPROVED.

## Key Artifacts

| Artifact | Created by | Consumed by |
|---|---|---|
| `domain-profile.md` | domain-understanding | brainstorming questions |
| `market-analysis.md` | market-analysis | bounded-context-design, architecture-assessment, feature-design |
| `context-map.md` | bounded-context-design | architecture-assessment, style-selection, feature-design, writing-plans |
| `architecture.md` | architecture-assessment, style-selection | All downstream skills |
| `quality-scenarios.md` | quality-scenarios | writing-plans, verification |
| `doc/adr/` | architecture-decisions | brainstorming (review), writing-plans, verification |
| `.feature` files | feature-design | bdd-testing, writing-plans, verification |

## Philosophy

- **Architecture-First** — Define characteristics, select style, document decisions before writing code
- **Constraints-Aware** — Organizational policies are first-class citizens, not afterthoughts
- **Independent Review** — Fresh agents verify artifacts; the author never reviews their own work
- **Evidence over Claims** — Verify before declaring success, no self-reported completions
- **Test-Driven** — Write tests first, always. BDD scenarios are executable acceptance criteria.
- **Immutable Decisions** — ADRs and fitness functions don't change; they get superseded with documented rationale

## License

MIT License - see LICENSE file for details

## Credits

Based on [Superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and [Prime Radiant](https://primeradiant.com).
