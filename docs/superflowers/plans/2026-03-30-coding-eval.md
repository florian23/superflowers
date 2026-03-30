# Coding Eval Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superflowers:subagent-driven-development (recommended) or superflowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a fully automated eval skill that measures whether superflowers skills improve feature implementation quality using real FeatureBench tasks.

**Architecture:** Standalone skill with Python helper scripts. SKILL.md orchestrates the full pipeline: prepare → dispatch subagents → run Docker tests → generate report.

**Tech Stack:** Python 3 (scripts), Docker (test execution), HuggingFace datasets (task loading), Claude Code Agent tool (subagent dispatch)

**Architecture:** Extends existing superflowers skill ecosystem. No architecture.md changes needed — this is an eval tool, not a product feature.

**Feature Files:** `features/coding-eval.feature` — 9 scenarios

**Quality Scenarios:** N/A (eval tooling, not production code)

**Active ADRs:** None

---

## File Structure

```
skills/coding-eval/
├── SKILL.md                         # Core skill — orchestrates prepare/run/grade/report
├── scripts/
│   ├── prepare_task.py              # Downloads task from HF, clones repo, creates workspace
│   ├── run_tests.py                 # Runs FeatureBench Docker tests against a solution
│   └── generate_report.py           # Aggregates grading.json files into HTML report
├── prompts/
│   ├── without-skill-prompt.md      # Vanilla agent prompt (no skills)
│   └── with-skill-prompt.md         # Superflowers agent prompt (full workflow)
└── tasks/                           # Runtime directory (gitignored)
```

---

### Task 1: Create SKILL.md — Core Orchestration

**Files:**
- Create: `skills/coding-eval/SKILL.md`

- [ ] **Step 1: Write SKILL.md with full orchestration logic**

The skill must handle these invocations:
- `/coding-eval prepare --task <id>` — prepare a single task
- `/coding-eval prepare --top 3` — prepare N simplest Level 1 tasks from FeatureBench lite
- `/coding-eval run --task <id>` — run both agents on a prepared task
- `/coding-eval grade --task <id>` — run Docker tests against solutions
- `/coding-eval report` — generate comparison HTML report
- `/coding-eval --task <id>` — full pipeline (prepare + run + grade + report)
- `/coding-eval --all` — full pipeline for all prepared tasks

The SKILL.md orchestrates by calling Python scripts via Bash and dispatching subagents via the Agent tool. It does NOT contain Python code — it instructs Claude what to do step by step.

Key sections in SKILL.md:
1. **Frontmatter** with name, description
2. **Invocation** section listing all commands
3. **Prepare** section: calls `scripts/prepare_task.py`
4. **Run** section: dispatches 2 subagents (reading prompts from `prompts/`)
5. **Grade** section: calls `scripts/run_tests.py`
6. **Report** section: calls `scripts/generate_report.py`
7. **Full Pipeline** section: chains all steps
8. **Task Registry** section: lists the 3 default FeatureBench tasks

- [ ] **Step 2: Verify SKILL.md parses correctly**

Read the file back and check for completeness.

- [ ] **Step 3: Commit**

```bash
git add skills/coding-eval/SKILL.md
git commit -m "feat: add coding-eval skill orchestration"
```

---

### Task 2: Create prepare_task.py — Task Preparation

**Files:**
- Create: `skills/coding-eval/scripts/prepare_task.py`

- [ ] **Step 1: Write prepare_task.py**

The script takes a FeatureBench task ID (or `--top N`) and:
1. Loads the task from HuggingFace dataset `LiberCoders/FeatureBench` split `lite`
2. Creates directory structure: `tasks/<task-short-name>/`
3. Writes `meta.json` with: instance_id, repo, base_commit, image_name, FAIL_TO_PASS, PASS_TO_PASS
4. Writes `task.md` with the problem_statement
5. Writes `test_patch.diff` with the test code (from the dataset's test_patch field)
6. Clones the repo into `tasks/<task-short-name>/repo/` at the base_commit
7. Creates two working copies: `with_skill/repo/` and `without_skill/repo/` (git worktrees or cp -r)

```python
#!/usr/bin/env python3
"""Prepare a FeatureBench task for evaluation."""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

def load_dataset_task(task_id=None, top_n=None):
    """Load task(s) from FeatureBench HuggingFace dataset."""
    from datasets import load_dataset
    ds = load_dataset("LiberCoders/FeatureBench", split="lite")

    if task_id:
        for i in range(len(ds)):
            if ds[i]["instance_id"] == task_id:
                return [ds[i]]
        print(f"Error: Task '{task_id}' not found in dataset")
        sys.exit(1)

    if top_n:
        # Filter to Level 1 tasks (have actual patches), sort by patch size
        tasks = [(i, ds[i]) for i in range(len(ds)) if len(ds[i]["patch"].splitlines()) > 0]
        tasks.sort(key=lambda x: len(x[1]["patch"].splitlines()))
        return [t[1] for t in tasks[:top_n]]

    return [ds[0]]

def short_name(instance_id):
    """Extract short name from instance_id."""
    parts = instance_id.split(".")
    repo_part = parts[0].replace("__", "-")
    test_part = parts[2].replace("test_", "")
    return f"{repo_part}-{test_part}"

def prepare_task(task_data, base_dir):
    """Prepare a single task."""
    name = short_name(task_data["instance_id"])
    task_dir = base_dir / name
    task_dir.mkdir(parents=True, exist_ok=True)

    # Write meta.json
    meta = {
        "instance_id": task_data["instance_id"],
        "repo": task_data["repo"],
        "base_commit": task_data["base_commit"],
        "image_name": task_data.get("image_name", ""),
        "FAIL_TO_PASS": task_data["FAIL_TO_PASS"],
        "PASS_TO_PASS": task_data.get("PASS_TO_PASS", ""),
    }
    (task_dir / "meta.json").write_text(json.dumps(meta, indent=2))

    # Write task.md (problem statement)
    (task_dir / "task.md").write_text(task_data["problem_statement"])

    # Write test patch
    if task_data.get("test_patch"):
        (task_dir / "test_patch.diff").write_text(task_data["test_patch"])

    # Write reference patch (for comparison, not given to agent)
    if task_data.get("patch"):
        (task_dir / "reference_patch.diff").write_text(task_data["patch"])

    # Clone repo
    repo_dir = task_dir / "repo"
    if not repo_dir.exists():
        repo_url = f"https://github.com/{task_data['repo']}.git"
        subprocess.run(
            ["git", "clone", "--depth", "1", repo_url, str(repo_dir)],
            check=True, capture_output=True
        )
        subprocess.run(
            ["git", "fetch", "--depth", "1", "origin", task_data["base_commit"]],
            cwd=str(repo_dir), check=True, capture_output=True
        )
        subprocess.run(
            ["git", "checkout", task_data["base_commit"]],
            cwd=str(repo_dir), check=True, capture_output=True
        )

    # Create working copies
    for config in ["with_skill", "without_skill"]:
        config_dir = task_dir / config
        config_repo = config_dir / "repo"
        if not config_repo.exists():
            config_dir.mkdir(parents=True, exist_ok=True)
            subprocess.run(
                ["cp", "-r", str(repo_dir), str(config_repo)],
                check=True
            )

    print(f"Prepared: {name} ({task_data['repo']})")
    return name

def main():
    parser = argparse.ArgumentParser(description="Prepare FeatureBench tasks")
    parser.add_argument("--task", help="Specific task instance_id")
    parser.add_argument("--top", type=int, help="Prepare N simplest Level 1 tasks")
    parser.add_argument("--base-dir", default="tasks", help="Base directory for task workspaces")
    args = parser.parse_args()

    base_dir = Path(args.base_dir)
    base_dir.mkdir(parents=True, exist_ok=True)

    tasks = load_dataset_task(task_id=args.task, top_n=args.top)

    prepared = []
    for task_data in tasks:
        name = prepare_task(task_data, base_dir)
        prepared.append(name)

    print(f"\nPrepared {len(prepared)} tasks: {', '.join(prepared)}")

if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Test the script with --top 1**

Run: `cd skills/coding-eval && python3 scripts/prepare_task.py --top 1 --base-dir tasks`
Expected: Task directory created with meta.json, task.md, repo/, with_skill/repo/, without_skill/repo/

- [ ] **Step 3: Commit**

```bash
git add skills/coding-eval/scripts/prepare_task.py
git commit -m "feat: add task preparation script for coding-eval"
```

---

### Task 3: Create Subagent Prompts

**Files:**
- Create: `skills/coding-eval/prompts/without-skill-prompt.md`
- Create: `skills/coding-eval/prompts/with-skill-prompt.md`

- [ ] **Step 1: Write without-skill-prompt.md**

```markdown
# Feature Implementation Task (Baseline — No Skills)

You are a software developer. Implement the feature described below in the given repository.

## Rules

- Read the codebase first to understand the structure and patterns
- Implement the feature directly — write production code
- Do NOT use any brainstorming, architecture, BDD, or workflow skills
- Do NOT create specification documents (architecture.md, .feature files, quality-scenarios.md)
- Focus on making the tests pass
- You may write your own tests to verify your implementation
- Commit your changes when done

## Feature Requirement

{{PROBLEM_STATEMENT}}

## Repository

Working directory: {{REPO_PATH}}

## Success Criteria

The implementation should make the project's test suite pass. Focus on correctness.
```

- [ ] **Step 2: Write with-skill-prompt.md**

```markdown
# Feature Implementation Task (With Superflowers Skills)

You are a software developer with access to the superflowers skill framework.

## Rules

- Use the superflowers workflow to approach this task systematically
- Begin by understanding the requirement thoroughly before writing code
- Use test-driven development where possible
- Create specification artifacts if they help clarify the requirement
- Verify your solution before claiming completion
- Commit your changes when done

## Feature Requirement

{{PROBLEM_STATEMENT}}

## Repository

Working directory: {{REPO_PATH}}

## Success Criteria

The implementation should make the project's test suite pass. Focus on correctness and code quality.
```

- [ ] **Step 3: Commit**

```bash
git add skills/coding-eval/prompts/
git commit -m "feat: add subagent prompts for with/without skill evaluation"
```

---

### Task 4: Create run_tests.py — Docker Test Execution

**Files:**
- Create: `skills/coding-eval/scripts/run_tests.py`

- [ ] **Step 1: Write run_tests.py**

The script takes a task directory and configuration (with_skill/without_skill) and:
1. Reads meta.json for image_name, FAIL_TO_PASS, PASS_TO_PASS
2. Generates a patch from the agent's changes (`git diff` in the config's repo/)
3. Applies the test_patch.diff (FeatureBench's test code) to the config's repo
4. Starts the Docker container from the FeatureBench image
5. Copies the modified repo into the container
6. Runs the test command
7. Parses results and writes grading.json

```python
#!/usr/bin/env python3
"""Run FeatureBench Docker tests against an agent's solution."""

import argparse
import json
import subprocess
import sys
from pathlib import Path

def run_tests(task_dir, config):
    """Run tests for a specific configuration."""
    task_dir = Path(task_dir)
    config_dir = task_dir / config
    repo_dir = config_dir / "repo"
    meta = json.loads((task_dir / "meta.json").read_text())

    image = meta["image_name"]
    f2p_tests = meta["FAIL_TO_PASS"]
    p2p_tests = meta.get("PASS_TO_PASS", [])

    if isinstance(f2p_tests, str):
        f2p_tests = json.loads(f2p_tests) if f2p_tests.startswith("[") else [f2p_tests]
    if isinstance(p2p_tests, str):
        p2p_tests = json.loads(p2p_tests) if p2p_tests.startswith("[") else ([p2p_tests] if p2p_tests else [])

    # Apply test patch if exists
    test_patch = task_dir / "test_patch.diff"
    if test_patch.exists():
        subprocess.run(
            ["git", "apply", "--allow-empty", str(test_patch)],
            cwd=str(repo_dir), capture_output=True
        )

    # Collect agent's changes as a patch
    agent_diff = subprocess.run(
        ["git", "diff", "--no-ext-diff"],
        cwd=str(repo_dir), capture_output=True, text=True
    )
    agent_patch = agent_diff.stdout

    # Also collect untracked files
    untracked = subprocess.run(
        ["git", "ls-files", "--others", "--exclude-standard"],
        cwd=str(repo_dir), capture_output=True, text=True
    )

    results = {"f2p": {}, "p2p": {}, "resolved": False, "partial": False}

    # Run each F2P test
    for test_path in f2p_tests:
        try:
            r = subprocess.run(
                ["docker", "run", "--rm",
                 "-v", f"{repo_dir.resolve()}:/testbed",
                 "-w", "/testbed",
                 image,
                 "python", "-m", "pytest", test_path, "-x", "--tb=short", "-q"],
                capture_output=True, text=True, timeout=300
            )
            passed = r.returncode == 0
            results["f2p"][test_path] = {
                "passed": passed,
                "output": (r.stdout + r.stderr)[-500:]
            }
        except subprocess.TimeoutExpired:
            results["f2p"][test_path] = {"passed": False, "output": "TIMEOUT"}
        except Exception as e:
            results["f2p"][test_path] = {"passed": False, "output": str(e)}

    # Run each P2P test
    for test_path in p2p_tests:
        try:
            r = subprocess.run(
                ["docker", "run", "--rm",
                 "-v", f"{repo_dir.resolve()}:/testbed",
                 "-w", "/testbed",
                 image,
                 "python", "-m", "pytest", test_path, "-x", "--tb=short", "-q"],
                capture_output=True, text=True, timeout=300
            )
            passed = r.returncode == 0
            results["p2p"][test_path] = {"passed": passed, "output": (r.stdout + r.stderr)[-500:]}
        except subprocess.TimeoutExpired:
            results["p2p"][test_path] = {"passed": False, "output": "TIMEOUT"}
        except Exception as e:
            results["p2p"][test_path] = {"passed": False, "output": str(e)}

    # Calculate status
    f2p_passed = all(r["passed"] for r in results["f2p"].values())
    p2p_passed = all(r["passed"] for r in results["p2p"].values()) if results["p2p"] else True
    f2p_any = any(r["passed"] for r in results["f2p"].values())

    results["resolved"] = f2p_passed and p2p_passed
    results["partial"] = f2p_any and not results["resolved"]
    results["status"] = "resolved" if results["resolved"] else ("partial" if results["partial"] else "failed")
    results["f2p_passed"] = sum(1 for r in results["f2p"].values() if r["passed"])
    results["f2p_total"] = len(results["f2p"])
    results["p2p_passed"] = sum(1 for r in results["p2p"].values() if r["passed"])
    results["p2p_total"] = len(results["p2p"])

    # Collect soft metrics
    diff_stat = subprocess.run(
        ["git", "diff", "--stat"],
        cwd=str(repo_dir), capture_output=True, text=True
    )
    numstat = subprocess.run(
        ["git", "diff", "--numstat"],
        cwd=str(repo_dir), capture_output=True, text=True
    )
    lines_added = sum(int(l.split("\t")[0]) for l in numstat.stdout.strip().splitlines() if l.split("\t")[0] != "-")
    lines_removed = sum(int(l.split("\t")[1]) for l in numstat.stdout.strip().splitlines() if l.split("\t")[1] != "-")
    files_changed = len(numstat.stdout.strip().splitlines())

    results["soft_metrics"] = {
        "lines_added": lines_added,
        "lines_removed": lines_removed,
        "files_changed": files_changed,
        "has_architecture_md": (repo_dir / "architecture.md").exists(),
        "has_feature_files": any(repo_dir.rglob("*.feature")),
        "has_quality_scenarios": (repo_dir / "quality-scenarios.md").exists(),
    }

    # Write grading.json
    grading_path = config_dir / "grading.json"
    grading_path.write_text(json.dumps(results, indent=2))

    print(f"  {config}: {results['status']} (F2P: {results['f2p_passed']}/{results['f2p_total']}, P2P: {results['p2p_passed']}/{results['p2p_total']})")
    return results

def main():
    parser = argparse.ArgumentParser(description="Run FeatureBench tests")
    parser.add_argument("--task-dir", required=True, help="Path to task directory")
    parser.add_argument("--config", choices=["with_skill", "without_skill", "both"], default="both")
    args = parser.parse_args()

    configs = ["with_skill", "without_skill"] if args.config == "both" else [args.config]

    print(f"Grading: {Path(args.task_dir).name}")
    for config in configs:
        run_tests(args.task_dir, config)

if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Commit**

```bash
git add skills/coding-eval/scripts/run_tests.py
git commit -m "feat: add Docker test execution for coding-eval"
```

---

### Task 5: Create generate_report.py — HTML Report Generation

**Files:**
- Create: `skills/coding-eval/scripts/generate_report.py`

- [ ] **Step 1: Write generate_report.py**

The script reads all grading.json files from tasks/, aggregates into benchmark.json, and generates an interactive HTML comparison report. Same dark theme and SVG charts as the compliance report.

Report sections:
1. **Summary:** Resolved rate comparison (with_skill vs without_skill)
2. **Per-Task Comparison:** Side-by-side results for each task
3. **Soft Metrics:** Which config produced more artifacts, cleaner code
4. **Aggregate:** Total tests passed, average metrics

```python
#!/usr/bin/env python3
"""Generate comparison HTML report from grading results."""

import argparse
import json
from datetime import date
from pathlib import Path

def load_results(tasks_dir):
    """Load all grading.json files."""
    results = []
    for task_dir in sorted(tasks_dir.iterdir()):
        if not task_dir.is_dir():
            continue
        meta_path = task_dir / "meta.json"
        if not meta_path.exists():
            continue
        meta = json.loads(meta_path.read_text())
        entry = {"name": task_dir.name, "meta": meta}
        for config in ["with_skill", "without_skill"]:
            grading = task_dir / config / "grading.json"
            if grading.exists():
                entry[config] = json.loads(grading.read_text())
            else:
                entry[config] = None
        results.append(entry)
    return results

def generate_benchmark(results):
    """Aggregate results into benchmark.json format."""
    benchmark = {
        "generated": str(date.today()),
        "tasks_total": len(results),
        "with_skill": {"resolved": 0, "partial": 0, "failed": 0},
        "without_skill": {"resolved": 0, "partial": 0, "failed": 0},
        "tasks": []
    }
    for r in results:
        task_entry = {"name": r["name"], "repo": r["meta"]["repo"]}
        for config in ["with_skill", "without_skill"]:
            if r.get(config):
                status = r[config]["status"]
                benchmark[config][status] = benchmark[config].get(status, 0) + 1
                task_entry[config] = {
                    "status": status,
                    "f2p": f"{r[config]['f2p_passed']}/{r[config]['f2p_total']}",
                    "soft": r[config].get("soft_metrics", {})
                }
            else:
                task_entry[config] = {"status": "not_run"}
        benchmark["tasks"].append(task_entry)
    return benchmark

def status_color(status):
    if status == "resolved": return "#22c55e"
    if status == "partial": return "#eab308"
    return "#ef4444"

def status_label(status):
    if status == "resolved": return "Resolved"
    if status == "partial": return "Partial"
    if status == "not_run": return "Not Run"
    return "Failed"

def generate_html(benchmark, results):
    """Generate single-file HTML report."""
    n = benchmark["tasks_total"]
    ws = benchmark["with_skill"]
    wos = benchmark["without_skill"]

    task_rows = ""
    for t in benchmark["tasks"]:
        ws_s = t.get("with_skill", {}).get("status", "not_run")
        wos_s = t.get("without_skill", {}).get("status", "not_run")
        ws_f2p = t.get("with_skill", {}).get("f2p", "-")
        wos_f2p = t.get("without_skill", {}).get("f2p", "-")
        ws_soft = t.get("with_skill", {}).get("soft", {})
        wos_soft = t.get("without_skill", {}).get("soft", {})
        task_rows += f"""<tr>
            <td class="mono">{t['name']}</td>
            <td class="mono">{t['repo']}</td>
            <td><span class="badge" style="background:rgba({','.join(str(int(status_color(wos_s)[i:i+2],16)) for i in (1,3,5))},.15);color:{status_color(wos_s)}">{status_label(wos_s)}</span> {wos_f2p}</td>
            <td><span class="badge" style="background:rgba({','.join(str(int(status_color(ws_s)[i:i+2],16)) for i in (1,3,5))},.15);color:{status_color(ws_s)}">{status_label(ws_s)}</span> {ws_f2p}</td>
        </tr>"""

    html = f"""<!DOCTYPE html>
<html lang="de"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Coding Eval Report — {benchmark['generated']}</title>
<style>
:root{{--bg:#0f1117;--surface:#1a1d27;--border:#2d3244;--text:#e4e6ed;--muted:#8b8fa3;--accent:#6366f1;--green:#22c55e;--yellow:#eab308;--red:#ef4444}}
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:var(--bg);color:var(--text);font-family:-apple-system,system-ui,sans-serif;padding:2rem;max-width:1100px;margin:0 auto;line-height:1.6}}
h1{{font-size:1.75rem;margin-bottom:.5rem}}h2{{font-size:1.2rem;color:var(--accent);border-bottom:1px solid var(--border);padding-bottom:.5rem;margin:1.5rem 0 1rem}}
.card{{background:var(--surface);border:1px solid var(--border);border-radius:8px;padding:1.5rem;margin-bottom:1rem}}
.grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:.75rem;margin-bottom:1rem}}
.stat{{background:var(--surface);border:1px solid var(--border);border-radius:8px;padding:1rem;text-align:center}}
.sv{{font-size:2rem;font-weight:700;font-family:'JetBrains Mono',monospace}}.sl{{color:var(--muted);font-size:.8rem}}
.mono{{font-family:'JetBrains Mono',monospace;font-size:.85rem}}
.badge{{display:inline-block;padding:.1rem .5rem;border-radius:4px;font-size:.75rem;font-weight:600;font-family:'JetBrains Mono',monospace}}
table{{width:100%;border-collapse:collapse;font-size:.88rem}}th,td{{padding:.5rem .7rem;text-align:left;border-bottom:1px solid var(--border)}}th{{color:var(--muted);font-weight:600;font-size:.75rem;text-transform:uppercase}}
</style></head><body>
<h1>Coding Eval: superflowers vs Baseline</h1>
<p style="color:var(--muted);margin-bottom:1.5rem">Generiert am {benchmark['generated']} — {n} FeatureBench Tasks</p>
<div class="grid">
<div class="stat"><div class="sl">Without Skill</div><div class="sv" style="color:{status_color('resolved') if wos['resolved']>0 else status_color('failed')}">{wos.get('resolved',0)}/{n}</div><div class="sl">Resolved</div></div>
<div class="stat"><div class="sl">With Skill</div><div class="sv" style="color:{status_color('resolved') if ws['resolved']>0 else status_color('failed')}">{ws.get('resolved',0)}/{n}</div><div class="sl">Resolved</div></div>
<div class="stat"><div class="sv" style="color:var(--accent)">{ws.get('resolved',0)-wos.get('resolved',0):+d}</div><div class="sl">Delta</div></div>
</div>
<h2>Ergebnisse pro Task</h2>
<div class="card" style="overflow-x:auto"><table>
<thead><tr><th>Task</th><th>Repo</th><th>Without Skill</th><th>With Skill</th></tr></thead>
<tbody>{task_rows}</tbody></table></div>
<footer style="text-align:center;color:var(--muted);font-size:.75rem;padding:1.5rem 0;border-top:1px solid var(--border);margin-top:1.5rem">
Coding Eval Report — superflowers — {benchmark['generated']}</footer>
<script>const DATA={json.dumps(benchmark)}</script>
</body></html>"""
    return html

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tasks-dir", default="tasks")
    parser.add_argument("--output-dir", default=".")
    args = parser.parse_args()

    tasks_dir = Path(args.tasks_dir)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    results = load_results(tasks_dir)
    if not results:
        print("No results found"); sys.exit(1)

    benchmark = generate_benchmark(results)
    (output_dir / "benchmark.json").write_text(json.dumps(benchmark, indent=2))

    html = generate_html(benchmark, results)
    report_path = output_dir / f"{date.today()}-coding-eval-report.html"
    report_path.write_text(html)
    print(f"Report: {report_path}")

if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Commit**

```bash
git add skills/coding-eval/scripts/generate_report.py
git commit -m "feat: add HTML report generation for coding-eval"
```

---

### Task 6: Add .gitignore for runtime data

**Files:**
- Create: `skills/coding-eval/tasks/.gitignore`

- [ ] **Step 1: Create .gitignore**

```
# Task workspaces are runtime data, not committed
*
!.gitignore
```

- [ ] **Step 2: Commit**

```bash
git add skills/coding-eval/tasks/.gitignore
git commit -m "chore: gitignore coding-eval runtime task data"
```

---

### Task 7: Integration Test — Full Pipeline on 1 Task

- [ ] **Step 1: Prepare the simplest task**

Run: `cd skills/coding-eval && python3 scripts/prepare_task.py --top 1 --base-dir tasks`
Expected: `tasks/mwaskom-seaborn-algorithms/` created with meta.json, task.md, repo/, with_skill/repo/, without_skill/repo/

- [ ] **Step 2: Verify task structure**

```bash
ls tasks/mwaskom-seaborn-algorithms/
# Expected: meta.json task.md test_patch.diff reference_patch.diff repo/ with_skill/ without_skill/
```

- [ ] **Step 3: Pull Docker image**

```bash
docker pull libercoders/featurebench-specs_seaborn-instance_52738fbb
```

- [ ] **Step 4: Verify Docker tests work with reference patch**

Apply the reference patch to verify the test infrastructure works:
```bash
cd tasks/mwaskom-seaborn-algorithms/with_skill/repo
git apply ../../reference_patch.diff
cd ../..
python3 ../../scripts/run_tests.py --task-dir . --config with_skill
```
Expected: grading.json with status "resolved"

- [ ] **Step 5: Generate report**

```bash
cd skills/coding-eval
python3 scripts/generate_report.py --tasks-dir tasks --output-dir tasks
```
Expected: HTML report generated

- [ ] **Step 6: Commit integration test results**

```bash
git add features/coding-eval.feature docs/superflowers/specs/2026-03-30-coding-eval-design.md
git commit -m "feat: add coding-eval integration test and feature file"
```
