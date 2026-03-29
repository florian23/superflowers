# Grading Summary: ADR Integration Skill -- Iteration 1

## Score Table

| Eval | Variant | A0 | A1 | A2 | A3 | A4 | A5 | Score |
|------|---------|----|----|----|----|----|----|-------|
| 1 Happy Path | WITH | PASS | PASS | PASS | PASS | n/a | n/a | 4/4 |
| 1 Happy Path | WITHOUT | PASS | PASS | PASS | PASS | n/a | n/a | 4/4 |
| 2 Superseding | WITH | PASS | PASS | PASS | PASS | PASS | PASS | 6/6 |
| 2 Superseding | WITHOUT | PASS | PASS | PASS | PASS | WEAK | FAIL | 4.5/6 |
| 3 Blocks | WITH | PASS | PASS | PASS | n/a | n/a | n/a | 3/3 |
| 3 Blocks | WITHOUT | PASS | PASS | PASS | n/a | n/a | n/a | 3/3 |

## Totals

| Variant | Total | Percentage |
|---------|-------|------------|
| WITH skill | 13/13 | 100% |
| WITHOUT skill | 11.5/13 | 88% |

## Where the Skill Made a Difference

### Eval 1 (Happy Path): No meaningful difference
Both variants produced strong outputs. The with-skill version had slightly more structured review formatting (table + per-ADR constraint notes). The without-skill version produced a more detailed ADR (included data model, provider abstraction). Both correctly identified all ADRs as compatible. **Verdict: tie.**

### Eval 2 (Superseding Cascade): Skill clearly better -- 2 assertion gap

**A4 (Cascade documentation):** The with-skill version nailed the governance mechanism:
- Named 4 specific FFs to REMOVE with explicit ADR-001 references
- Named 5 specific FFs to ADD with explicit ADR-005 references
- Explained that ADR supersession is what triggers FF removal
- Provided a diff summary mapping old FFs to new FFs

The without-skill version treated it as a technical migration analysis. It used "RETIRE", "ADAPT", "RETAIN" dispositions -- keeping 3 of 5 existing FFs with modifications instead of clean removal. No per-FF ADR reference column. The ADR-reference traceability mechanism was not articulated.

**A5 (ADR immutability):** The with-skill version changed only the Status line of ADR-001. The without-skill version rewrote the entire ADR (different Context, different Decision wording, changed service count range from 4-12 to 4-7, added new sections). This is a fundamental ADR governance violation -- superseded ADRs are historical records that must not be altered.

### Eval 3 (ADR Review Blocks): No meaningful difference
Both variants correctly identified the REST vs real-time conflict as blocking. Both provided resolution options with clear recommendations. The with-skill version explicitly framed the block as halting brainstorming. The without-skill version offered one additional option (reject feature) and one additional technical option (managed service). **Verdict: tie.**

## Key Findings

1. **The skill's value is concentrated in Eval 2 (superseding cascade).** This is the most governance-heavy scenario and the one where implicit knowledge about ADR immutability and FF-ADR traceability matters most.

2. **ADR immutability is the biggest without-skill failure.** The without-skill variant rewrote ADR-001's content when superseding it. This suggests that without explicit skill guidance, the model treats superseded ADRs as editable documents rather than immutable historical records.

3. **FF cascade governance is the second gap.** Without the skill, the model produces a reasonable technical migration analysis but misses the specific governance mechanism: that FFs reference ADRs, and when an ADR is superseded, its FFs must be removed (not adapted) and replaced with FFs referencing the new ADR.

4. **Happy path and conflict detection work fine without the skill.** For straightforward compatibility checks and conflict identification, the base model performs at skill-level quality.
