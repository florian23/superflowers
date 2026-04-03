---
name: ux-validate
description: Use when wireframes or UI designs need evaluation against usability heuristics — applies Nielsen's 10 with severity ratings and triggers redesign for critical findings
---

# UX Validate

Evaluate designs against Nielsen's 10 Usability Heuristics. Findings with Severity 3-4 trigger redesign. Fourth and final phase of the UX design process.

**Semantic anchors:** Nielsen's 10 Usability Heuristics (Jakob Nielsen, 1994/2020), Heuristic Evaluation, Severity Rating Scale (0-4), Shneiderman's 8 Golden Rules, Peter Morville's UX Honeycomb.

**Announce at start:** "I'm evaluating the wireframes against Nielsen's 10 usability heuristics."

## When to Use

- After `superflowers:ux-wireframes` has produced wireframes
- When existing UI needs a usability review
- When the user asks "is this usable?" or "review the UX"

**When NOT to use:**
- If no wireframes or UI exists yet — run `ux-wireframes` first
- For code quality reviews — use `superflowers:requesting-code-review`

## Heuristic Evaluation

Apply each heuristic to the designed screens:

| # | Heuristic | Check |
|---|---|---|
| 1 | **Visibility of system status** | User always knows what's happening? Loading indicators? Progress? |
| 2 | **Match between system and real world** | UI uses the user's language (ubiquitous language from context-map)? |
| 3 | **User control and freedom** | Undo, cancel, go back? Emergency exits? |
| 4 | **Consistency and standards** | Same action = same result everywhere? Platform conventions? |
| 5 | **Error prevention** | Input validation before submission? Confirmation for destructive actions? |
| 6 | **Recognition rather than recall** | Options visible? No need to remember from previous screens? |
| 7 | **Flexibility and efficiency** | Shortcuts for experts? Doesn't burden novices? |
| 8 | **Aesthetic and minimalist design** | Every element serves a purpose? No clutter? |
| 9 | **Help users recover from errors** | Error messages in plain language? Constructive suggestions? |
| 10 | **Help and documentation** | Contextual help where needed? |

## Severity Rating

Per finding:
- **0** — Not a problem
- **1** — Cosmetic only
- **2** — Minor usability issue
- **3** — Major — significant impact on task completion
- **4** — Catastrophe — prevents task completion

<HARD-GATE>
Findings with Severity 3 or 4 MUST be addressed before proceeding.
Go back to superflowers:ux-wireframes and redesign the affected screens.
Do NOT proceed to feature-design or writing-plans with unresolved
Severity 3-4 findings.
</HARD-GATE>

## Write to ux-design.md

Append the following section:

```markdown
## Heuristic Evaluation

> Nielsen's 10 Usability Heuristics

| # | Heuristik | Status | Finding | Severity |
|---|---|---|---|---|
| 1 | Visibility of system status | Pass/Fail | ... | 0-4 |
| 2 | Match between system and real world | Pass/Fail | ... | 0-4 |
| 3 | User control and freedom | Pass/Fail | ... | 0-4 |
| 4 | Consistency and standards | Pass/Fail | ... | 0-4 |
| 5 | Error prevention | Pass/Fail | ... | 0-4 |
| 6 | Recognition rather than recall | Pass/Fail | ... | 0-4 |
| 7 | Flexibility and efficiency of use | Pass/Fail | ... | 0-4 |
| 8 | Aesthetic and minimalist design | Pass/Fail | ... | 0-4 |
| 9 | Help users recover from errors | Pass/Fail | ... | 0-4 |
| 10 | Help and documentation | Pass/Fail | ... | 0-4 |
```
