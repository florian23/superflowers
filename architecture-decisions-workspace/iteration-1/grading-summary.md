# Grading Summary — Iteration 1

## Scores

| Eval | WITH skill | WITHOUT skill |
|------|-----------|---------------|
| 1 — Style Selection | 6/6 | 4/6 |
| 2 — REST vs GraphQL | 6/6 | 3/6 |
| 3 — Unplanned Message Queue | 6/6 | 4/6 |
| 4 — Superseding (SQLite to PostgreSQL) | 7/7 | 5/7 |
| **Total** | **25/25 (100%)** | **16/25 (64%)** |

## Assertion Breakdown

| Assertion | WITH (4 evals) | WITHOUT (4 evals) |
|-----------|----------------|-------------------|
| A0: Output files exist | 4/4 | 4/4 |
| A1: Nygard format (4 sections) | 4/4 | 1/4 |
| A2: Imperative title | 4/4 | 1/4 |
| A3: 2+ alternatives in Context | 4/4 | 3/4 |
| A4: Positive AND negative consequences | 4/4 | 3/4 |
| A5: Correct numbering | 4/4 | 4/4 |
| A6: Superseding handled correctly | 1/1 | 1/1 |

## Key Findings

### The skill's biggest impact: format discipline (A1, A2)

The WITHOUT outputs consistently failed on Nygard format compliance and imperative titles. Three of four WITHOUT outputs used German section headings ("Kontext", "Entscheidung", "Begruendung", "Konsequenzen") instead of the standard English Nygard headings. Three of four used descriptive noun-phrase titles instead of imperative form.

The WITH outputs were 100% compliant on both format and title conventions across all four evals.

### WITHOUT outputs sometimes add non-standard sections

The WITHOUT outputs frequently added extra sections not part of the Nygard format: "Begruendung" (separate from Decision), "Verworfene Alternativen", "Datum", "Bezug zu bestehenden Entscheidungen". While some of this content is useful, it breaks the standard four-section structure.

### Content quality was reasonable in both conditions

Both WITH and WITHOUT outputs generally identified relevant alternatives and included substantive analysis. The WITHOUT outputs were not lacking in domain understanding -- they failed primarily on structural/format adherence.

### Eval 2 WITHOUT was the weakest

Scored 3/6, failing on Nygard format, imperative title, and consequences (the Konsequenzen section listed only implementation follow-ups, not positive/negative trade-offs).

### Superseding (Eval 4) was handled well by both

Both conditions correctly updated the old ADR's status and created a new ADR with backward references. The WITHOUT output's only failure was omitting alternative databases in the new ADR's context (A3).
