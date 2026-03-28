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

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superflowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

Read more: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/) (original project)

## License

MIT License - see LICENSE file for details

## Credits

Based on [Superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and [Prime Radiant](https://primeradiant.com).
