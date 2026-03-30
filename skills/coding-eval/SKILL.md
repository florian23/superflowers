---
name: coding-eval
description: Evaluate whether superflowers skills improve feature implementation quality. Uses real FeatureBench tasks with Docker-based test execution. Dispatches two subagents (with/without skills) and generates a comparison report.
---

# Coding Eval

Evaluate superflowers skills against real-world feature implementation tasks from FeatureBench (ICLR 2026). Dispatches two subagents per task — one with superflowers skills, one without — and measures both test pass rate (hard metric) and artifact quality (soft metric).

**Announce at start:** "I'm running a coding eval to measure superflowers skill impact."

## Prerequisites

- Docker installed and running
- FeatureBench Python package available (from `featurebench-eval/` in project root)
- Internet access for cloning repos and pulling Docker images

## Invocation

```
/coding-eval --task <task-short-name>    # Evaluate a single prepared task
/coding-eval --all                       # Evaluate all prepared tasks
/coding-eval prepare --top 3             # Prepare the 3 simplest FeatureBench tasks
/coding-eval grade --task <name>         # Grade a task (run Docker tests)
/coding-eval report                      # Generate comparison HTML report
```

## Full Pipeline

When invoked with `--task <name>` or `--all`, execute these steps in order:

### Step 1: Prepare

If `tasks/<name>/` doesn't exist yet, run preparation:

```bash
cd skills/coding-eval
python3 scripts/prepare_task.py --task <instance_id> --base-dir tasks
```

Or to prepare multiple tasks at once:

```bash
python3 scripts/prepare_task.py --top 3 --base-dir tasks
```

This clones the repo, extracts the problem statement, and creates with_skill/ and without_skill/ working directories.

### Step 2: Run Without-Skill Agent

Dispatch a subagent using the Agent tool with `isolation: "worktree"`:

1. Read `prompts/without-skill-prompt.md`
2. Read `tasks/<name>/task.md` for the problem statement
3. Replace `{{PROBLEM_STATEMENT}}` with the task content
4. Replace `{{REPO_PATH}}` with the absolute path to `tasks/<name>/without_skill/repo/`
5. Dispatch the agent with the composed prompt

The without-skill agent MUST NOT have access to superflowers skills. Its prompt explicitly instructs it to implement directly without workflow skills.

Wait for the agent to complete before proceeding.

### Step 3: Run With-Skill Agent

Same process, but:
1. Read `prompts/with-skill-prompt.md`
2. Use `tasks/<name>/with_skill/repo/` as the repo path
3. The with-skill agent is encouraged to use the full superflowers workflow

Wait for the agent to complete.

### Step 4: Grade

Run Docker tests against both solutions:

```bash
python3 scripts/run_tests.py --task-dir tasks/<name> --config both
```

This produces `grading.json` in both `with_skill/` and `without_skill/`.

### Step 5: Report

Generate the comparison HTML report:

```bash
python3 scripts/generate_report.py --tasks-dir tasks --output-dir tasks
```

Report is saved as `tasks/YYYY-MM-DD-coding-eval-report.html`.

## Default Tasks (FeatureBench Lite, Level 1, sorted by difficulty)

| # | Task ID | Repo | Patch Lines |
|---|---------|------|-------------|
| 1 | `mwaskom__seaborn.7001ebe7.test_algorithms.1f0181c2.lv1` | mwaskom/seaborn | 249 |
| 2 | `mwaskom__seaborn.7001ebe7.test_statistics.0f2ae277.lv1` | mwaskom/seaborn | 367 |
| 3 | `pydata__xarray.97f3a746.test_backends_chunks.fa55f68a.lv1` | pydata/xarray | 480 |

## Output Structure

```
tasks/
├── <task-name>/
│   ├── meta.json           # Task metadata (repo, commit, tests, image)
│   ├── task.md             # Problem statement for the agent
│   ├── test_patch.diff     # FeatureBench test code
│   ├── reference_patch.diff # Reference solution (not shown to agent)
│   ├── repo/               # Base repo at correct commit
│   ├── with_skill/
│   │   ├── repo/           # Agent's working copy
│   │   └── grading.json    # Test results
│   └── without_skill/
│       ├── repo/
│       └── grading.json
├── benchmark.json           # Aggregated results
└── YYYY-MM-DD-coding-eval-report.html
```

## Metrics

**Hard (from Docker tests):**
- Resolved: all FAIL_TO_PASS + PASS_TO_PASS tests pass
- Partial: some FAIL_TO_PASS tests pass
- Failed: no FAIL_TO_PASS tests pass

**Soft (from agent workspace):**
- Specification artifacts created (architecture.md, .feature files, etc.)
- Lines of code changed
- Files modified
- Own tests written by agent

## References

- `scripts/prepare_task.py` — Task preparation from HuggingFace
- `scripts/run_tests.py` — Docker test execution
- `scripts/generate_report.py` — HTML report generation
- `prompts/*.md` — Subagent prompt templates
