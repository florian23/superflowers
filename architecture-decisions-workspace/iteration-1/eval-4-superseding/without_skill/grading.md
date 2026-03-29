# Grading: Eval 4 — Superseding SQLite to PostgreSQL (WITHOUT skill)

## ADR-002-updated (old, superseded)

| Assertion | Pass/Fail | Notes |
|-----------|-----------|-------|
| A0: Output files exist with real content | PASS | File exists with content |
| A1: Nygard format | PASS | Status, Context, Decision, Consequences present |
| A5: Correct sequential numbering | PASS | ADR-002 |

## ADR-004 (new)

| Assertion | Pass/Fail | Notes |
|-----------|-----------|-------|
| A0: Output files exist with real content | PASS | Substantive ADR |
| A1: Nygard format (Status, Context, Decision, Consequences) | PASS | All 4 sections present with correct headings |
| A2: Title in imperative form | PASS | "Use PostgreSQL for persistence" |
| A3: Context mentions at least 2 alternatives | FAIL | Context only mentions SQLite (the predecessor). No alternative to PostgreSQL is discussed — MySQL or other options are never mentioned. The ADR jumps straight to PostgreSQL without documenting what else was considered. |
| A4: Consequences include positive AND negative | PASS | "Easier" (4 items) and "Harder" (5 items) |
| A5: Correct sequential numbering | PASS | ADR-004 |

## Superseding (A6)

| Criterion | Pass/Fail | Notes |
|-----------|-----------|-------|
| Old ADR status changed to "Superseded by ADR-004" | PASS | Status reads "Superseded by [ADR-004](ADR-004.md)" |
| Old ADR content untouched (only status changed) | PASS | Context, Decision, Consequences appear to be brief but intact originals (content was already minimal) |
| New ADR references old ADR in Context | PASS | "SQLite (chosen in ADR-002)" referenced in Context |

**Score: 5/7** (A3 fails for new ADR)

Note: The "Supersedes [ADR-002](...)" line is placed in the Status section rather than the Context section. While it does create the backward reference, placing it in Context would be more conventional per Nygard format. However, since the Context section also references ADR-002, the A6 reference requirement is met.
