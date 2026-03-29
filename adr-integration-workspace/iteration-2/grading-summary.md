# Grading Summary -- ADR Integration Evals, Iteration 2

## Scorecard

| Eval | Description | With Skill | Without Skill | Delta |
|------|-------------|-----------|--------------|-------|
| 1 | At a Glance Correctness | **4/4** | 2.5/4 | +1.5 |
| 2 | Traceability | **3/3** | **3/3** | 0 |
| 3 | Decision Quality | **3/3** | 1.5/3 | +1.5 |
| 4 | Conflict Blocking | **4/4** | 3/4 | +1 |
| 5 | Full Cascade | **5/5** | 3.5/5 | +1.5 |
| **Total** | | **19/19** | **13.5/19** | **+5.5** |
| **Percentage** | | **100%** | **71%** | **+29pp** |

## Per-Eval Analysis

### Eval 1: At a Glance Correctness
- **With skill (4/4):** Perfect. Clean separation of At a Glance (Accepted only) from Index (all ADRs). Immutability preserved. Superseding chain explicit.
- **Without skill (2.5/4):** At a Glance section leaks deprecated ADR-003 context into the summary (A1 fail). ADR-002 content was rewritten rather than truly immutable (A3 partial). Index and superseding chain were correct.

### Eval 2: Traceability
- **With skill (3/3):** Perfect. Bidirectional matrix, Evolvability gap identified, no orphans.
- **Without skill (3/3):** Also perfect. Both outputs produced equivalent quality on this eval. The without-skill output even added useful analysis (FF overlap observations, style vs characteristic balance).

### Eval 3: Decision Quality
- **With skill (3/3):** Perfect. All three ADRs have rich alternatives with concrete pros/cons, honest negative consequences, and heavy quantification (scores, dollar amounts, TPS limits, latency numbers, ramp-up times).
- **Without skill (1.5/3):** ADR-003 listed only 1 alternative instead of 2+ (A1 partial). Negative consequences present but softened with immediate mitigations. Quantification thin -- only ADR-001 had strong numbers; ADR-002 had none; ADR-003 had minimal ratios (A3 partial).

### Eval 4: Conflict Blocking
- **With skill (4/4):** Perfect. All conflicts identified, brainstorming explicitly blocked with a gate, three resolution paths with tradeoffs, and a clear problem-vs-solution distinction.
- **Without skill (3/4):** Conflicts well-identified, problem-vs-solution distinguished, four resolution options provided. But brainstorming was never explicitly blocked (A2 fail) -- the resolution plan jumps straight to options rather than enforcing a decision gate.

### Eval 5: Full Cascade
- **With skill (5/5):** Perfect. ADR immutability preserved, old FFs removed by name with ADR-001 reference, new FFs added by name with ADR-006 reference, 6 quality scenarios flagged with impact levels and reasons, At a Glance update specified.
- **Without skill (3.5/5):** ADR-001 content was modified (new sections added -- violates immutability, A1 partial). FF removal/addition well-handled. Quality scenarios well-flagged with detailed impact analysis. But no At a Glance section produced or referenced (A5 fail).

## Key Differentiators

1. **Immutability discipline:** The skill enforces that superseded ADR content is never modified -- only the status line changes. Without the skill, both Eval 1 and Eval 5 showed content modifications to superseded ADRs.

2. **Explicit blocking gates:** The skill produces a hard "brainstorming CANNOT proceed" gate when conflicts are detected. Without the skill, conflicts are identified but the output moves directly to solutions without enforcing a stop.

3. **Quantification depth:** The skill produces ADRs with specific numbers (TPS, dollar costs, latency, ramp-up time). Without the skill, quantification is inconsistent -- some ADRs get numbers, others stay qualitative.

4. **At a Glance filtering:** The skill maintains a clean Accepted-only view. Without the skill, this concept is either absent or contaminated with non-Accepted ADR content.

5. **Traceability is a tie:** Both with-skill and without-skill produced excellent bidirectional traceability matrices. This suggests traceability is a well-understood pattern that does not require skill guidance.
