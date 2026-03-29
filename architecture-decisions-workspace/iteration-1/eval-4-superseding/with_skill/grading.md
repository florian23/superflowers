# Grading: Eval 4 — Superseding SQLite to PostgreSQL (WITH skill)

## ADR-002 (old, superseded)

| Assertion | Pass/Fail | Notes |
|-----------|-----------|-------|
| A0: Output files exist with real content | PASS | File exists with content |
| A1: Nygard format | PASS | Status, Context, Decision, Consequences all present |
| A5: Correct sequential numbering | PASS | ADR-002 |

## ADR-004 (new)

| Assertion | Pass/Fail | Notes |
|-----------|-----------|-------|
| A0: Output files exist with real content | PASS | Substantive ADR |
| A1: Nygard format (Status, Context, Decision, Consequences) | PASS | All 4 sections present with correct headings |
| A2: Title in imperative form | PASS | "Use PostgreSQL for persistence" |
| A3: Context mentions at least 2 alternatives | PASS | PostgreSQL and MySQL discussed; SQLite mentioned as the incumbent being replaced |
| A4: Consequences include positive AND negative | PASS | "Easier" (4 items) and "Harder" (4 items) |
| A5: Correct sequential numbering | PASS | ADR-004 |

## Superseding (A6)

| Criterion | Pass/Fail | Notes |
|-----------|-----------|-------|
| Old ADR status changed to "Superseded by ADR-004" | PASS | Status reads "Superseded by ADR-004" |
| Old ADR content untouched (only status changed) | PASS | Context, Decision, Consequences remain intact and unchanged |
| New ADR references old ADR in Context | PASS | "Three months after adopting SQLite (ADR-002)" and "This supersedes ADR-002" |

**Score: 7/7** (A0-A6 all pass)
