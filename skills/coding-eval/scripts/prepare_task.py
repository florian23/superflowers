#!/usr/bin/env python3
"""Prepare FeatureBench tasks for evaluation.

Downloads task data from HuggingFace, clones repos, and creates
with_skill/without_skill working directories.

Usage:
    python3 prepare_task.py --top 3 --base-dir tasks
    python3 prepare_task.py --task "mwaskom__seaborn.7001ebe7.test_algorithms.1f0181c2.lv1"
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path


def load_tasks(task_id=None, top_n=None):
    """Load task(s) from FeatureBench HuggingFace dataset."""
    try:
        from datasets import load_dataset
    except ImportError:
        print("Error: 'datasets' package not found.")
        print("Run from featurebench-eval venv or install: pip install datasets")
        sys.exit(1)

    ds = load_dataset("LiberCoders/FeatureBench", split="lite")

    if task_id:
        for i in range(len(ds)):
            if ds[i]["instance_id"] == task_id:
                return [ds[i]]
        print(f"Error: Task '{task_id}' not found.")
        print("Available tasks:")
        for i in range(len(ds)):
            print(f"  {ds[i]['instance_id']}")
        sys.exit(1)

    if top_n:
        tasks = [
            ds[i] for i in range(len(ds))
            if len(ds[i]["patch"].splitlines()) > 0  # Level 1 only
        ]
        tasks.sort(key=lambda t: len(t["patch"].splitlines()))
        return tasks[:top_n]

    # Default: simplest task
    return load_tasks(top_n=1)


def short_name(instance_id):
    """Extract short name: 'mwaskom-seaborn-algorithms' from instance_id."""
    parts = instance_id.split(".")
    repo = parts[0].replace("__", "-")
    test = parts[2].replace("test_", "")
    return f"{repo}-{test}"


def clone_repo(repo_slug, commit, dest):
    """Clone a GitHub repo at a specific commit."""
    url = f"https://github.com/{repo_slug}.git"
    print(f"  Cloning {repo_slug}...")

    subprocess.run(
        ["git", "clone", "--no-checkout", url, str(dest)],
        check=True, capture_output=True, text=True,
    )
    subprocess.run(
        ["git", "fetch", "origin", commit],
        cwd=str(dest), check=True, capture_output=True, text=True,
    )
    subprocess.run(
        ["git", "checkout", commit],
        cwd=str(dest), check=True, capture_output=True, text=True,
    )


def prepare_task(task_data, base_dir):
    """Prepare a single task workspace."""
    name = short_name(task_data["instance_id"])
    task_dir = base_dir / name

    if task_dir.exists():
        print(f"  {name}: already prepared (skipping)")
        return name

    task_dir.mkdir(parents=True)

    # meta.json
    meta = {
        "instance_id": task_data["instance_id"],
        "repo": task_data["repo"],
        "base_commit": task_data["base_commit"],
        "image_name": task_data.get("image_name", ""),
        "FAIL_TO_PASS": task_data["FAIL_TO_PASS"],
        "PASS_TO_PASS": task_data.get("PASS_TO_PASS", ""),
        "patch_lines": len(task_data["patch"].splitlines()),
    }
    (task_dir / "meta.json").write_text(json.dumps(meta, indent=2))

    # task.md (problem statement for the agent)
    (task_dir / "task.md").write_text(task_data["problem_statement"])

    # test_patch.diff (FeatureBench test code — applied before grading)
    if task_data.get("test_patch"):
        (task_dir / "test_patch.diff").write_text(task_data["test_patch"])

    # reference_patch.diff (ground truth — never shown to agent)
    if task_data.get("patch"):
        (task_dir / "reference_patch.diff").write_text(task_data["patch"])

    # Clone repo
    repo_dir = task_dir / "repo"
    clone_repo(task_data["repo"], task_data["base_commit"], repo_dir)

    # Create working copies for each configuration
    for config in ["with_skill", "without_skill"]:
        config_dir = task_dir / config
        config_dir.mkdir()
        print(f"  Creating {config} working copy...")
        subprocess.run(
            ["cp", "-r", str(repo_dir), str(config_dir / "repo")],
            check=True,
        )

    print(f"  Prepared: {name}")
    return name


def main():
    parser = argparse.ArgumentParser(description="Prepare FeatureBench tasks")
    parser.add_argument("--task", help="Specific task instance_id")
    parser.add_argument("--top", type=int, help="Prepare N simplest Level 1 tasks")
    parser.add_argument("--base-dir", default="tasks", help="Output directory")
    args = parser.parse_args()

    base_dir = Path(args.base_dir)
    base_dir.mkdir(parents=True, exist_ok=True)

    print("Loading FeatureBench dataset...")
    tasks = load_tasks(task_id=args.task, top_n=args.top)
    print(f"Preparing {len(tasks)} task(s)...\n")

    prepared = []
    for task_data in tasks:
        name = prepare_task(task_data, base_dir)
        prepared.append(name)

    print(f"\nDone. Prepared {len(prepared)} tasks:")
    for name in prepared:
        print(f"  tasks/{name}/")


if __name__ == "__main__":
    main()
