# Fitness-Functions Skill — Eval Results (Iteration 2)

## Changes from Iteration 1

- **Eval 1** (JS Project): Now included — was run in Iteration 1 (late addition)
- **Eval 5** (Failing Function): Re-run with_skill with proper timing capture
- **Eval 6** (NEW): Adversarial — vague architecture.md with no concrete goals
- **Eval 7** (NEW): Threshold tightening — stricter threshold should be allowed

## All Evals Overview

| Eval | Name | with_skill | without_skill | Skill Delta |
|------|------|-----------|--------------|-------------|
| 1 | JS Project Fitness Creation | **7/7 (100%)** | 6/7 (86%) | +1 |
| 2 | Immutability No-Weakening | **5/5 (100%)** | 0/5 (0%) | +5 |
| 3 | Architecture-to-Fitness Mapping | **6/6 (100%)** | 4/6 (67%) | +2 |
| 4 | Python Project Detection | **6/6 (100%)** | 5/6 (83%) | +1 |
| 5 | Failing Function Escalation | **6/6 (100%)** | 3/6 (50%) | +3 |
| 6 | Adversarial Vague Architecture | **5/5 (100%)** | 0/5 (0%) | **+5** |
| 7 | Threshold Tightening Allowed | **5/5 (100%)** | 3/5 (60%) | +2 |

**Aggregate (All 7 Evals):**
- with_skill: **40/40 (100%)**
- without_skill: **21/40 (53%)**
- Skill impact: **+47 percentage points**

## Performance Overhead

| Eval | without_skill | with_skill | Token Delta | Time Delta |
|------|-------------|-----------|------------|------------|
| 1 | 13.4K / 68s | 22.9K / 160s | +71% | +136% |
| 2 | 10.6K / 30s | 13.6K / 43s | +28% | +42% |
| 3 | 11.1K / 45s | 16.5K / 54s | +49% | +20% |
| 4 | 12.2K / 54s | 17.6K / 61s | +44% | +13% |
| 5 | 12.9K / 64s | 17.9K / 57s | +39% | -11% |
| 6 | 15.9K / 99s | 17.5K / 57s | +10% | **-42%** |
| 7 | 11.8K / 51s | 18.1K / 66s | +53% | +29% |

**Average overhead:** +42% tokens, +27% time (excluding Eval 6 outlier where with_skill was faster by refusing to create unnecessary work).

## Skill Value by Category

| Category | Evals | with_skill | without_skill | Delta |
|----------|-------|-----------|--------------|-------|
| **Enforcement** (immutability, escalation) | 2, 5 | 11/11 (100%) | 3/11 (27%) | **+73pp** |
| **Adversarial** (vague input, edge cases) | 6, 7 | 10/10 (100%) | 3/10 (30%) | **+70pp** |
| **Detection & Mapping** | 3, 4 | 12/12 (100%) | 9/12 (75%) | +25pp |
| **Creation & Execution** | 1 | 7/7 (100%) | 6/7 (86%) | +14pp |

## Key Findings — New Evals

### Eval 6: Adversarial Vague Architecture (biggest new insight)

This is the most revealing eval. The skill's value is **dramatically visible** when architecture.md lacks concrete goals:

| Behavior | with_skill | without_skill |
|----------|-----------|--------------|
| Detects vagueness | Yes — flags all 4 characteristics | No — proceeds silently |
| Invents thresholds | No — refuses | Yes — picks 100ms, 50 lines, etc. |
| Asks for clarification | Yes — NEEDS_CONTEXT | No — creates 16 tests |
| Creates fitness functions | No — 0 functions | Yes — 4 files, 16 tests |
| Result quality | Correct refusal | 16 passing tests with no architectural basis |

**The without_skill agent created 16 passing tests that prove nothing.** They use arbitrary thresholds, test generic best practices, and would pass on any trivial Node.js project. This is the worst possible outcome for fitness functions — false confidence from meaningless checks.

The with_skill agent correctly identified this and refused to proceed, recommending architecture-assessment first. This is the skill's second-highest-value behavior after immutability.

### Eval 7: Threshold Tightening

Both configurations successfully made the change, but the skill adds **conceptual clarity**:

- **with_skill**: Explicitly reasons about tightening vs weakening as directional concepts. Documents the decision with a clear rationale. Confirms architecture.md consistency.
- **without_skill**: Just makes the change without discussing why it's allowed. Happens to also update architecture.md (good), but doesn't distinguish this from a weakening request.

The without_skill agent would have also changed 10→15 without hesitation (as shown in Eval 2). The skill provides the framework to distinguish the two.

### Eval 5 Rerun: Proper Escalation Confirmed

The rerun with timing confirms the skill correctly escalates violations:
- Status: BLOCKED
- Full evidence: function name, actual complexity (7), threshold (5), file location
- Root cause analysis provided but no code changes
- Explicit "What Must NOT Happen" section
- Iron Law cited: "NO COMPLETION CLAIM WITHOUT ALL FITNESS FUNCTIONS PASSING"

## Skill Strengths (confirmed across 7 evals)

1. **Perfect enforcement** — never weakens thresholds, never skips violations (Evals 2, 5)
2. **Vague input rejection** — refuses to create fitness functions without concrete goals (Eval 6)
3. **Role separation** — reports violations but doesn't fix code (Eval 5)
4. **Directional reasoning** — allows tightening, blocks weakening (Evals 2, 7)
5. **Structured output** — verification checklists, escalation status codes, evidence tables
6. **Framework detection** — correct tool selection for JS and Python (Evals 1, 3, 4)

## Remaining Weaknesses

1. **Performance test validity** — both with/without skill test raw function speed against API thresholds when no API exists (Eval 1). This is a fixture issue but the skill doesn't flag the mismatch.
2. **Token overhead** — 42% average increase. Acceptable for the quality improvement, but worth monitoring.
3. **No multi-language eval** — all evals test single-language projects. Mixed-language monorepo behavior untested.

## Comparison: Iteration 1 → Iteration 2

| Metric | Iteration 1 | Iteration 2 |
|--------|------------|------------|
| Evals run | 4 (Eval 1 missing) | 7 (all complete) |
| with_skill score | 23/23 (100%) | 40/40 (100%) |
| without_skill score | 12/23 (52%) | 21/40 (53%) |
| Eval coverage | Creation, Detection, Enforcement | + Adversarial, Edge Cases |
| Timing complete | 3/4 | 7/7 |
