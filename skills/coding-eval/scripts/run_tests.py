#!/usr/bin/env python3
"""Run FeatureBench Docker tests against agent solutions.

Starts the task's Docker container, applies the test patch,
mounts the agent's repo, runs pytest, and writes grading.json.

Usage:
    python3 run_tests.py --task-dir tasks/mwaskom-seaborn-algorithms --config both
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path


def parse_test_list(value):
    """Parse FAIL_TO_PASS / PASS_TO_PASS from meta.json."""
    if isinstance(value, list):
        return value
    if isinstance(value, str):
        if value.startswith("["):
            return json.loads(value)
        return [value] if value else []
    return []


def run_tests_for_config(task_dir, config):
    """Run tests for a single configuration (with_skill or without_skill)."""
    task_dir = Path(task_dir)
    config_dir = task_dir / config
    repo_dir = config_dir / "repo"
    meta = json.loads((task_dir / "meta.json").read_text())

    image = meta["image_name"]
    f2p = parse_test_list(meta["FAIL_TO_PASS"])
    p2p = parse_test_list(meta.get("PASS_TO_PASS", ""))

    if not image:
        print(f"  {config}: No Docker image specified — skipping")
        return None

    # Check if Docker image exists locally
    check = subprocess.run(
        ["docker", "image", "inspect", image],
        capture_output=True, text=True,
    )
    if check.returncode != 0:
        print(f"  Pulling Docker image: {image}...")
        pull = subprocess.run(
            ["docker", "pull", image],
            capture_output=True, text=True, timeout=600,
        )
        if pull.returncode != 0:
            print(f"  {config}: Failed to pull image {image}")
            return {"status": "error", "error": "docker_pull_failed"}

    # FeatureBench Docker images have the test files baked in at /testbed/.
    # When we mount the agent's repo as /testbed, it shadows those tests.
    # Solution: copy the test files FROM the Docker image INTO the agent's repo
    # before mounting. This preserves the agent's implementation + FeatureBench tests.
    for test_path_str in f2p + p2p:
        test_file = repo_dir / test_path_str
        if not test_file.exists():
            test_file.parent.mkdir(parents=True, exist_ok=True)
            cp = subprocess.run(
                ["docker", "run", "--rm", image, "cat", f"/testbed/{test_path_str}"],
                capture_output=True, timeout=60,
            )
            if cp.returncode == 0:
                test_file.write_bytes(cp.stdout)

    results = {"f2p": {}, "p2p": {}}

    # Run FAIL_TO_PASS tests
    for test_path in f2p:
        results["f2p"][test_path] = run_single_test(repo_dir, image, test_path)

    # Run PASS_TO_PASS tests
    for test_path in p2p:
        results["p2p"][test_path] = run_single_test(repo_dir, image, test_path)

    # Calculate status
    f2p_passed = sum(1 for r in results["f2p"].values() if r["passed"])
    f2p_total = len(results["f2p"])
    p2p_passed = sum(1 for r in results["p2p"].values() if r["passed"])
    p2p_total = len(results["p2p"])

    all_f2p = f2p_passed == f2p_total and f2p_total > 0
    all_p2p = p2p_passed == p2p_total
    any_f2p = f2p_passed > 0

    results["status"] = "resolved" if (all_f2p and all_p2p) else ("partial" if any_f2p else "failed")
    results["f2p_passed"] = f2p_passed
    results["f2p_total"] = f2p_total
    results["p2p_passed"] = p2p_passed
    results["p2p_total"] = p2p_total

    # Soft metrics
    numstat = subprocess.run(
        ["git", "diff", "--numstat", "HEAD"],
        cwd=str(repo_dir), capture_output=True, text=True,
    )
    lines = numstat.stdout.strip().splitlines()
    added = sum(int(l.split("\t")[0]) for l in lines if l.split("\t")[0].isdigit())
    removed = sum(int(l.split("\t")[1]) for l in lines if l.split("\t")[1].isdigit())

    results["soft_metrics"] = {
        "lines_added": added,
        "lines_removed": removed,
        "files_changed": len(lines),
        "has_architecture_md": (repo_dir / "architecture.md").exists(),
        "has_feature_files": bool(list(repo_dir.rglob("*.feature"))),
        "has_quality_scenarios": (repo_dir / "quality-scenarios.md").exists(),
    }

    # Write grading.json
    (config_dir / "grading.json").write_text(json.dumps(results, indent=2))

    status_icon = {"resolved": "✓", "partial": "~", "failed": "✗"}.get(results["status"], "?")
    print(f"  {config}: {status_icon} {results['status']} (F2P: {f2p_passed}/{f2p_total}, P2P: {p2p_passed}/{p2p_total})")
    return results


def run_single_test(repo_dir, image, test_path):
    """Run a single test file in Docker.

    FeatureBench images use conda env 'testbed' with pytest installed.
    We activate it and run pytest from there.
    """
    try:
        r = subprocess.run(
            [
                "docker", "run", "--rm",
                "-v", f"{repo_dir.resolve()}:/testbed",
                "-w", "/testbed",
                image,
                "bash", "-c",
                f"source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed && "
                f"pip install -e . 2>/dev/null; pytest {test_path} -x --tb=short -q",
            ],
            capture_output=True, text=True, timeout=600,
        )
        return {
            "passed": r.returncode == 0,
            "output": (r.stdout + r.stderr)[-500:],
        }
    except subprocess.TimeoutExpired:
        return {"passed": False, "output": "TIMEOUT (300s)"}
    except Exception as e:
        return {"passed": False, "output": str(e)}


def main():
    parser = argparse.ArgumentParser(description="Run FeatureBench Docker tests")
    parser.add_argument("--task-dir", required=True, help="Path to task directory")
    parser.add_argument("--config", choices=["with_skill", "without_skill", "both"], default="both")
    args = parser.parse_args()

    task_name = Path(args.task_dir).name
    print(f"Grading: {task_name}")

    configs = ["without_skill", "with_skill"] if args.config == "both" else [args.config]
    for config in configs:
        run_tests_for_config(args.task_dir, config)


if __name__ == "__main__":
    main()
