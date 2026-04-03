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
- Downstream-consumed artifact sections use `> Consumed by: skill-name (Step N)` markers
- Bundled skills (from Superpowers) should not be modified directly
- Skills that produce artifacts must be DIALOG, not batch — work step by step with the user, not generate everything at once
- Validation/review of artifacts belongs in reviewer AGENTS (fresh context), never in skills (same context = self-review)

## Custom Skills (19)

architecture-assessment, architecture-decisions, architecture-style-selection,
bdd-testing, bounded-context-design, coding-eval, compliance-report,
constraint-selection, domain-understanding, feature-design, fitness-functions,
market-analysis, project-constraints, quality-scenarios, risk-storming,
ux-design (orchestrator), ux-research, ux-flows, ux-wireframes

## Bundled Skills (14, from Superpowers)

brainstorming, dispatching-parallel-agents, executing-plans,
finishing-a-development-branch, receiving-code-review, requesting-code-review,
subagent-driven-development, systematic-debugging, test-driven-development,
using-git-worktrees, using-superflowers, verification-before-completion,
writing-plans, writing-skills

## Skill Testing (RED/GREEN)

- New skills are tested with parallel subagents: RED (without skill) vs GREEN (with skill)
- Use `isolation: "worktree"` for test agents to avoid repo pollution
- Technique skills: test with application scenarios (can the agent apply it correctly?)
- Discipline skills: test with pressure scenarios (does the agent comply under stress?)
- Key metric: downstream-nutzbarkeit — can the next skill in the chain consume the output directly?

## Environment

- VPS hosted at Hostinger, accessible via Tailscale VPN
- Visual Companion server auto-detects Tailscale and binds to tailnet IP
- Workspace directories (*-workspace/, smoke-test-workspace/) are gitignored — test data only

## Gotchas

- Skill length is NOT the cause of agent non-compliance — abstract instructions are
- Workflow descriptions in skill `description:` fields cause Claude to skip the skill body (CSO research)
- Context is distributed across 6 artifacts (architecture.md, context-map.md, quality-scenarios.md, constraints/*.md, spec, .feature files) — no single consolidated view

## Testing

Smoke tests: create a project in `smoke-test-workspace/`, run full workflow manually.
Integration evals: `integration-evals-workspace/` tests skill-to-skill handoffs.
Coding evals: `/coding-eval` measures skill impact on FeatureBench tasks (Docker required).
