# Superflowers

Custom fork of Superpowers v5.0.6 — composable skills for coding agent workflows (DDD, architecture, BDD).

## Structure

- `skills/` — Each skill in its own directory with `SKILL.md` as entry point
- `agents/` — Reviewer agent definitions + shared `reviewer-protocol.md`
- `references/` — Shared patterns referenced by multiple skills (e.g., `uncertainty-handling.md`)
- `commands/` — CLI command definitions
- `hooks/` — Event hooks
- `tests/` — Skill tests
- `*-workspace/` — Test fixtures and smoke test projects (not part of the plugin)

## Skill Conventions

- Description field: starts with "Use when...", trigger conditions only, no workflow summaries
- Every skill has a "When to Use / When NOT to use" section
- HARD-GATEs use concrete procedural steps, not abstract instructions
- Review loops follow `agents/reviewer-protocol.md` (4-step pattern)
- Uncertainty at user-facing decision points follows `references/uncertainty-handling.md`

## Custom Skills (13)

architecture-assessment, architecture-decisions, architecture-style-selection,
bdd-testing, bounded-context-design, coding-eval, compliance-report,
constraint-selection, domain-understanding, feature-design, fitness-functions,
project-constraints, quality-scenarios

## Bundled Skills (14, from Superpowers)

brainstorming, dispatching-parallel-agents, executing-plans,
finishing-a-development-branch, receiving-code-review, requesting-code-review,
subagent-driven-development, systematic-debugging, test-driven-development,
using-git-worktrees, using-superflowers, verification-before-completion,
writing-plans, writing-skills

## Testing

Smoke tests: create a project in `smoke-test-workspace/`, run full workflow manually.
Integration evals: `integration-evals-workspace/` tests skill-to-skill handoffs.
Coding evals: `/coding-eval` measures skill impact on FeatureBench tasks (Docker required).
