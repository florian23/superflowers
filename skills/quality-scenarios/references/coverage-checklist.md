# Scenario Coverage Checklist

Commonly-missed scenario types. During Step 2 (Generate Scenarios), check whether any of these apply to
the feature — and if so, add scenarios **even when the upstream architecture goals didn't name them**.
Quality goals are often incomplete; these are the gaps that surface late as user complaints.

Keep this file as the growth point for coverage guidance — add new categories here rather than inlining
them into SKILL.md.

## Interactive & AI-latency features

Applies when a user waits on a response — a long-running operation, an AI/model call, a remote fetch, a
large upload or processing step. Generate BOTH:

- **Performance scenario** — a concrete duration/response-time target (e.g. "p95 end-to-end < 3s under
  normal load"). Verification type: usually load-test or integration-test.
- **Perceived-progress scenario** — the operation visibly shows progress and never looks stuck or crashed:
  a progress indicator, streaming output, or status update appears within N seconds, and the user always
  knows it is still working (and can tell success from failure). Verification type: usually manual-review
  or integration-test on the real system.

Users judge these features by **felt responsiveness**, not just throughput. A fast operation with no
feedback still reads as "frozen".

> Retro evidence (mieterrecht): *"wie bekommen wir die bearbeitungsdauer schneller … wie verhindern wir,
> dass der nutzer glaubt es geht nicht voran oder es stürzt ab"* — perceived progress was never modelled
> upfront and surfaced only as a complaint.
