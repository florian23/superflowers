#!/usr/bin/env python3
"""Generate HTML comparison report from coding eval results.

Reads grading.json from all task directories, aggregates into
benchmark.json, and generates a single-file HTML report.

Usage:
    python3 generate_report.py --tasks-dir tasks --output-dir tasks
"""

import argparse
import json
import sys
from datetime import date
from pathlib import Path


def load_results(tasks_dir):
    """Load all grading.json files from task directories."""
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
            entry[config] = json.loads(grading.read_text()) if grading.exists() else None

        results.append(entry)
    return results


def generate_benchmark(results):
    """Aggregate results into benchmark.json."""
    bm = {
        "generated": str(date.today()),
        "tasks_total": len(results),
        "with_skill": {"resolved": 0, "partial": 0, "failed": 0, "not_run": 0},
        "without_skill": {"resolved": 0, "partial": 0, "failed": 0, "not_run": 0},
        "tasks": [],
    }

    for r in results:
        task = {"name": r["name"], "repo": r["meta"]["repo"]}
        for cfg in ["with_skill", "without_skill"]:
            if r.get(cfg):
                s = r[cfg]["status"]
                bm[cfg][s] = bm[cfg].get(s, 0) + 1
                task[cfg] = {
                    "status": s,
                    "f2p": f"{r[cfg]['f2p_passed']}/{r[cfg]['f2p_total']}",
                    "lines_added": r[cfg].get("soft_metrics", {}).get("lines_added", 0),
                    "files_changed": r[cfg].get("soft_metrics", {}).get("files_changed", 0),
                    "has_artifacts": any([
                        r[cfg].get("soft_metrics", {}).get("has_architecture_md"),
                        r[cfg].get("soft_metrics", {}).get("has_feature_files"),
                        r[cfg].get("soft_metrics", {}).get("has_quality_scenarios"),
                    ]),
                }
            else:
                bm[cfg]["not_run"] += 1
                task[cfg] = {"status": "not_run"}
        bm["tasks"].append(task)

    return bm


def sc(status):
    """Status to hex color."""
    return {"resolved": "#22c55e", "partial": "#eab308", "failed": "#ef4444", "not_run": "#8b8fa3"}.get(status, "#8b8fa3")


def sl(status):
    """Status to label."""
    return {"resolved": "Resolved", "partial": "Partial", "failed": "Failed", "not_run": "—"}.get(status, "?")


def generate_html(bm):
    """Generate self-contained HTML report."""
    n = bm["tasks_total"]
    ws = bm["with_skill"]
    wos = bm["without_skill"]
    delta = ws["resolved"] - wos["resolved"]
    delta_sign = "+" if delta > 0 else ""

    rows = ""
    for t in bm["tasks"]:
        for cfg in ["without_skill", "with_skill"]:
            d = t.get(cfg, {})
            s = d.get("status", "not_run")
            if cfg == "without_skill":
                rows += f'<tr><td rowspan="2" class="mono">{t["name"]}</td>'
                rows += f'<td>Baseline</td>'
            else:
                rows += f'<tr><td style="color:var(--accent)">With Skills</td>'
            rows += f'<td><span class="badge" style="background:color-mix(in srgb,{sc(s)} 15%,transparent);color:{sc(s)}">{sl(s)}</span></td>'
            rows += f'<td class="mono">{d.get("f2p", "—")}</td>'
            rows += f'<td class="mono">{d.get("lines_added", "—")}</td>'
            rows += f'<td class="mono">{d.get("files_changed", "—")}</td>'
            rows += f'<td>{"✓" if d.get("has_artifacts") else "—"}</td>'
            rows += '</tr>'

    return f"""<!DOCTYPE html>
<html lang="de"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Coding Eval — {bm['generated']}</title>
<style>
:root{{--bg:#0f1117;--surface:#1a1d27;--sh:#242836;--border:#2d3244;--text:#e4e6ed;--muted:#8b8fa3;--accent:#6366f1;--green:#22c55e;--yellow:#eab308;--red:#ef4444}}
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:var(--bg);color:var(--text);font-family:-apple-system,system-ui,sans-serif;padding:2rem;max-width:1100px;margin:0 auto;line-height:1.6}}
h1{{font-size:1.75rem;margin-bottom:.5rem}}h2{{font-size:1.2rem;color:var(--accent);border-bottom:1px solid var(--border);padding-bottom:.5rem;margin:1.5rem 0 1rem}}
.card{{background:var(--surface);border:1px solid var(--border);border-radius:8px;padding:1.5rem;margin-bottom:1rem}}
.grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:.75rem;margin-bottom:1rem}}
.stat{{background:var(--surface);border:1px solid var(--border);border-radius:8px;padding:1.25rem;text-align:center}}
.sv{{font-size:2.2rem;font-weight:700;font-family:'JetBrains Mono',monospace}}.sl{{color:var(--muted);font-size:.8rem;margin-top:.2rem}}
.mono{{font-family:'JetBrains Mono',monospace;font-size:.85rem}}
.badge{{display:inline-block;padding:.15rem .5rem;border-radius:4px;font-size:.75rem;font-weight:600;font-family:'JetBrains Mono',monospace}}
table{{width:100%;border-collapse:collapse;font-size:.88rem}}th,td{{padding:.5rem .7rem;text-align:left;border-bottom:1px solid var(--border)}}th{{color:var(--muted);font-weight:600;font-size:.75rem;text-transform:uppercase}}tr:hover{{background:var(--sh)}}
</style></head><body>
<h1>Coding Eval: superflowers vs Baseline</h1>
<p style="color:var(--muted);margin-bottom:1.5rem">{bm['generated']} — {n} FeatureBench Tasks — FeatureBench-Adapter Evaluation</p>

<div class="grid">
  <div class="stat"><div class="sl">Baseline</div><div class="sv" style="color:{sc('resolved') if wos['resolved'] else sc('failed')}">{wos['resolved']}/{n}</div><div class="sl">Resolved</div></div>
  <div class="stat"><div class="sl">With Skills</div><div class="sv" style="color:{sc('resolved') if ws['resolved'] else sc('failed')}">{ws['resolved']}/{n}</div><div class="sl">Resolved</div></div>
  <div class="stat"><div class="sv" style="color:{'var(--green)' if delta>0 else 'var(--red)' if delta<0 else 'var(--muted)'}">{delta_sign}{delta}</div><div class="sl">Delta Resolved</div></div>
  <div class="stat"><div class="sv" style="color:var(--yellow)">{ws['partial']}</div><div class="sl">Partial (Skills)</div></div>
</div>

<h2>Ergebnisse pro Task</h2>
<div class="card" style="overflow-x:auto"><table>
<thead><tr><th>Task</th><th>Config</th><th>Status</th><th>F2P Tests</th><th>Lines+</th><th>Files</th><th>Artifacts</th></tr></thead>
<tbody>{rows}</tbody></table></div>

<h2>Methodik</h2>
<div class="card">
<p>Jeder Task wird von zwei Agents bearbeitet:</p>
<ul style="padding-left:1.5rem;margin:.5rem 0">
<li><strong>Baseline:</strong> Claude Code ohne superflowers Skills — implementiert direkt</li>
<li><strong>With Skills:</strong> Claude Code mit vollem superflowers Workflow</li>
</ul>
<p style="margin-top:.5rem">Tests werden in FeatureBench Docker-Containern ausgeführt. <strong>Resolved</strong> = alle Tests bestanden.</p>
</div>

<footer style="text-align:center;color:var(--muted);font-size:.75rem;padding:1.5rem 0;border-top:1px solid var(--border);margin-top:1.5rem">
Coding Eval — superflowers — {bm['generated']}</footer>
<script>const DATA={json.dumps(bm)}</script>
</body></html>"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tasks-dir", default="tasks")
    parser.add_argument("--output-dir", default=".")
    args = parser.parse_args()

    tasks_dir = Path(args.tasks_dir)
    output_dir = Path(args.output_dir)

    results = load_results(tasks_dir)
    if not results:
        print("No results found in", tasks_dir)
        sys.exit(1)

    bm = generate_benchmark(results)
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "benchmark.json").write_text(json.dumps(bm, indent=2))

    html = generate_html(bm)
    report = output_dir / f"{date.today()}-coding-eval-report.html"
    report.write_text(html)
    print(f"Report: {report}")
    print(f"Benchmark: {output_dir / 'benchmark.json'}")


if __name__ == "__main__":
    main()
