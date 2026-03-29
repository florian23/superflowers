# Superflowers

Custom fork of [Superpowers](https://github.com/obra/superpowers) - a complete software development workflow for coding agents, built on composable "skills".

Based on Superpowers v5.0.6 by [Jesse Vincent](https://github.com/obra).

## Installation

### Claude Code (lokales Plugin)

**1. Plugin registrieren** in `~/.claude/plugins/installed_plugins.json`:

Folgenden Eintrag zum `"plugins"` Objekt hinzufuegen:

```json
"superflowers@local": [
  {
    "scope": "user",
    "installPath": "/home/flo/superflowers",
    "version": "0.1.0",
    "installedAt": "2026-03-28T19:00:00.000Z",
    "lastUpdated": "2026-03-28T19:00:00.000Z"
  }
]
```

**2. Plugin aktivieren** in `~/.claude/settings.json`:

Im `"enabledPlugins"` Objekt:

```json
"superpowers@claude-plugins-official": false,
"superflowers@local": true
```

**3. Verifizieren:**

Neue Claude Code Session starten. Die Skills sollten mit dem `superflowers:` Praefix geladen werden.

### Schnelltest (ohne dauerhafte Installation)

```bash
claude --plugin-dir /home/flo/superflowers
```

### Updates vom Upstream holen

```bash
cd /home/flo/superflowers
git fetch upstream
git merge upstream/main
```

## The Complete Workflow

```
ADR Review ──► Brainstorming ──► Bounded Context Design ──► Architecture Assessment
                  [ADR]              [context-map.md]            [ADR]
                                                                   │
                                                                   ▼
Feature Design ◄── Quality Scenarios ◄── Style Selection ◄─────────┘
                        [ADR]                [ADR]
      │
      ▼
Writing Plans ──► Implementation ──► Fitness Functions ──► Verification ──► Finishing
                   [BDD Testing]    [Style FFs + Char FFs]   [All checks]    [PR/Merge]
```

### Phase 1: Specification (what to build)

1. **ADR Review** — Before starting a new feature, read existing Architecture Decision Records. Check if the feature is compatible with active decisions or if ADRs need to be superseded.

2. **brainstorming** — Refine the idea through questions, explore 2-3 approaches, present design in sections for validation. Creates design document.

3. **bounded-context-design** — Identify bounded contexts, classify subdomains (Core/Supporting/Generic), create context map with DDD relationship patterns, define ubiquitous language per context. Skips automatically for single-domain projects. Creates `context-map.md`.

4. **architecture-assessment** — Identify and prioritize architecture characteristics (performance, scalability, security, ...) through structured dialogue, informed by context boundaries. Creates/updates `architecture.md` with Top-3 driving characteristics. Based on Ford/Richards Architecture Characteristics Worksheet.

5. **architecture-style-selection** — Score all 8 architecture styles against driving characteristics using the Ford/Richards star-rating matrix. Context boundaries inform service/module cuts. Select best fit, generate style-specific fitness functions. Updates `architecture.md`.

6. **quality-scenarios** — Create concrete, testable quality scenarios from architecture characteristics using ATAM. Each scenario gets the right test type: unit-test, integration-test, load-test, chaos-test, fitness-function, or manual-review. Creates `quality-scenarios.md`.

7. **feature-design** — Write BDD acceptance criteria as Gherkin `.feature` files, using ubiquitous language from context-map.md. Informed by architecture and quality scenarios.

### Phase 2: Planning

8. **writing-plans** — Break work into bite-sized tasks (2-5 minutes each). Module/service decomposition follows bounded context boundaries. References `context-map.md`, `architecture.md`, `quality-scenarios.md`, `.feature` files, and active ADRs.

### Phase 3: Implementation

8. **using-git-worktrees** — Create isolated workspace on a new branch.

9. **subagent-driven-development** or **executing-plans** — Execute the plan task by task. Dispatch fresh subagent per task with two-stage review, or execute in batches with human checkpoints.

10. **test-driven-development** — RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit.

11. **bdd-testing** — Implement step definitions for `.feature` files. Auto-detects framework (Cucumber, Jest-Cucumber, Behave, pytest-bdd, etc.).

12. **fitness-functions** — Implement and verify both characteristic fitness functions (quality attributes) and style fitness functions (structural invariants). All must pass before completion.

### Phase 4: Verification & Delivery

13. **verification-before-completion** — Run every check: unit tests, integration tests, load tests, BDD scenarios, fitness functions, quality scenarios, ADR compliance. Evidence required, no self-reported claims.

14. **requesting-code-review** / **receiving-code-review** — Pre-review checklist and feedback processing.

15. **finishing-a-development-branch** — Verify tests, present options (merge/PR/keep/discard), clean up worktree.

### Cross-Cutting: Architecture Decision Records

**architecture-decisions** — Captures significant decisions as immutable ADRs (Nygard format) throughout the entire workflow. Maintains a "Current Architecture at a Glance" index. Handles superseding with cascade: old fitness functions removed, new ones generated, quality scenarios re-evaluated. Every fitness function traces back to its justifying ADR.

## Skills Library

### Architecture & Design
- **bounded-context-design** — DDD strategic design: subdomain classification, context maps, ubiquitous language
- **architecture-assessment** — Identify architecture characteristics (Ford/Richards worksheet, ATAM)
- **architecture-style-selection** — Select architecture style from star-rating matrix, generate style fitness functions
- **architecture-decisions** — ADR management (Nygard format), superseding cascade, ADR-FF traceability
- **quality-scenarios** — ATAM quality scenarios with test-type classification
- **fitness-functions** — Automated architecture compliance (structural + characteristic)

### Specification & BDD
- **brainstorming** — Socratic design refinement with ADR review
- **feature-design** — BDD acceptance criteria as Gherkin scenarios
- **bdd-testing** — Step definition implementation, framework auto-detection

### Planning & Execution
- **writing-plans** — Detailed implementation plans referencing all specification artifacts
- **executing-plans** — Batch execution with checkpoints
- **subagent-driven-development** — Fast iteration with two-stage review
- **dispatching-parallel-agents** — Concurrent subagent workflows

### Testing & Verification
- **test-driven-development** — RED-GREEN-REFACTOR cycle
- **verification-before-completion** — Evidence-based completion gate
- **systematic-debugging** — 4-phase root cause process

### Collaboration & Git
- **requesting-code-review** — Pre-review checklist
- **receiving-code-review** — Responding to feedback
- **using-git-worktrees** — Parallel development branches
- **finishing-a-development-branch** — Merge/PR decision workflow

### Meta
- **writing-skills** — Create new skills following best practices
- **using-superflowers** — Introduction to the skills system

## Key Artifacts

| Artifact | Created by | Used by |
|---|---|---|
| `context-map.md` | bounded-context-design | architecture-assessment, style-selection, feature-design, writing-plans |
| `architecture.md` | architecture-assessment, architecture-style-selection | All downstream skills |
| `quality-scenarios.md` | quality-scenarios | writing-plans, verification |
| `doc/adr/` | architecture-decisions | brainstorming (review), writing-plans, verification |
| `.feature` files | feature-design | bdd-testing, writing-plans, verification |

## Philosophy

- **Architecture-First** — Define characteristics, select style, document decisions before writing code
- **Test-Driven Development** — Write tests first, always
- **Evidence over Claims** — Verify before declaring success, no self-reported completions
- **Immutable Decisions** — ADRs and fitness functions don't change; they get superseded with documented rationale
- **Systematic over Ad-hoc** — Process over guessing
- **Right Test for the Job** — Not everything is a fitness function; unit tests, integration tests, load tests, and manual reviews each have their place

Read more: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/) (original project)

## License

MIT License - see LICENSE file for details

## Credits

Based on [Superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and [Prime Radiant](https://primeradiant.com).
