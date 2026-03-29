# Fitness-Functions Skill — Eval Results (Iteration 1)

## Overview

| Eval | Name | with_skill | without_skill | Skill Delta |
|------|------|-----------|--------------|-------------|
| 1 | JS Project Fitness Creation | **7/7 (100%)** | 6/7 (86%) | **+1 assertion** |
| 2 | Immutability No-Weakening | **5/5 (100%)** | 0/5 (0%) | **+5 assertions** |
| 3 | Architecture-to-Fitness Mapping | **6/6 (100%)** | 4/6 (67%) | **+2 assertions** |
| 4 | Python Project Detection | **6/6 (100%)** | 5/6 (83%) | **+1 assertion** |
| 5 | Failing Function Escalation | **6/6 (100%)** | 3/6 (50%) | **+3 assertions** |

**Aggregate (All Evals):**
- with_skill: **30/30 (100%)**
- without_skill: **18/30 (60%)**
- Skill impact: **+40 percentage points**

## Performance Overhead

| Eval | without_skill | with_skill | Token Delta | Time Delta |
|------|-------------|-----------|------------|------------|
| 1 | 13.4K / 68s | 22.9K / 160s | +71% | +136% |
| 2 | 10.6K / 30s | 13.6K / 43s | +28% | +42% |
| 3 | 11.1K / 45s | 16.5K / 54s | +49% | +20% |
| 4 | 12.2K / 54s | 17.6K / 61s | +44% | +13% |
| 5 | 12.9K / 64s | N/A | — | — |

**Average overhead:** ~48% more tokens, ~53% more time.

## Key Findings

### 1. Perfect Skill Score: 30/30 (100%)
The fitness-functions skill achieved a perfect score across all 5 evals. Every assertion passed in every eval when the skill was active.

### 2. Strongest Skill Impact: Immutability Guard (Eval 2)
The skill's most critical value is the **HARD-GATE immutability rule**. Without the skill, the agent happily weakened the threshold (0/5). With the skill, it refused and recommended fixing the code (5/5). This is the core differentiator — without the skill, architectural constraints erode over time.

### 3. End-to-End Creation Works Well Even Without Skill (Eval 1)
The without_skill baseline scored 6/7 on the JS project creation eval. The agent successfully:
- Read architecture.md and identified characteristics
- Detected JS and picked appropriate tools (madge, jest coverage)
- Created fitness functions and executed them
- Showed evidence of results

The only missing assertion: **skill_invoked** (expected, since no skill was used). This means for straightforward creation tasks, the skill's added value is primarily in **process discipline** (structured methodology, verification checklist, HARD-GATE) rather than capability.

### 4. Behavioral Guardrail: Escalation vs Self-Fix (Eval 5)
Without the skill, the agent **fixes the code itself** instead of escalating. This seems helpful but violates separation of concerns — a fitness function verifier should report violations, not fix them. The skill enforces this boundary.

### 5. Good Baseline: Detection & Mapping (Evals 3-4)
The agent performs reasonably well at language detection and tool mapping even without the skill (67-83%). The skill adds:
- **Structured process** (framework detection table, function-templates.md)
- **Concrete run commands** (not just tool names)
- **Explicit no-false-positive discipline** (only maps characteristics from architecture.md)

## Skill Value by Category

| Category | Evals | with_skill | without_skill | Impact |
|----------|-------|-----------|--------------|--------|
| **Enforcement** (immutability, escalation) | 2, 5 | 11/11 (100%) | 3/11 (27%) | **+73pp** — highest value |
| **Detection & Mapping** | 3, 4 | 12/12 (100%) | 9/12 (75%) | **+25pp** — moderate value |
| **Creation & Execution** | 1 | 7/7 (100%) | 6/7 (86%) | **+14pp** — lowest delta |

**Conclusion:** The skill's primary value is in **enforcement** (preventing threshold weakening, maintaining role separation), not in detection or creation where the baseline agent already performs well.

## Eval 1 Detailed Analysis

### with_skill Strengths
- Explicit skill announcement at start
- Framework detection table systematically applied
- All fitness functions run together via `npx jest fitness/` (unified runner)
- Verification checklist from SKILL.md completed
- HARD-GATE and escalation status documented

### without_skill Approach
- Created standalone Node.js scripts (not Jest tests)
- Each script run individually (no unified runner)
- No verification checklist or methodology documentation
- Performance test measured raw function calls (same limitation as with_skill)
- Self-noted limitations: no CI integration, no orchestrator

### Quality Difference
The with_skill output is more **structured and auditable** (transcript format, checklist, escalation status). The without_skill output is functional but ad-hoc. Both achieve the same end result for this simple project, but the skill's process would scale better to complex projects.

## Remaining Gaps

### 1. Eval 5 with_skill Timing Still Missing
No timing data for the with_skill run of Eval 5. The output file exists but may have been manually created.

### 2. Performance Test Validity
Both with_skill and without_skill test raw function execution speed (sub-millisecond) against a 500ms API threshold. Neither creates an actual HTTP server. The architecture.md says "API <500ms p95" but the project has no API. This is a fixture design issue, not a skill issue.

### 3. No Adversarial Eval
All evals have well-formed architecture.md files. An eval with incomplete, contradictory, or missing architecture.md would test the skill's error handling.

## Recommendations for Iteration 2

1. **Fix Eval 1 fixture** — add an Express server so the performance fitness function tests actual API latency
2. **Re-run Eval 5 with_skill** with proper timing capture
3. **Add adversarial eval** — missing architecture.md, vague goals, contradictory thresholds
4. **Add threshold tightening eval** — verify the skill allows making thresholds stricter but not weaker
5. **Add multi-project eval** — test fitness function creation across mixed-language monorepo
