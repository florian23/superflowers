# Eval 7: Threshold Tightening (with skill)

## Skill Announcement

I'm using the fitness-functions skill to verify architecture compliance.

## User Request

The user asked (in German): "I have a project in /tmp/ff-eval-7/ with a Complexity Fitness Function (max 10). Our team has decided to tighten the threshold to 8. Please adjust the fitness function."

## Step 1: Read architecture.md

```markdown
# Architecture Characteristics

## Structural
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---|---|---|---|
| Complexity | Critical | Cyclomatic complexity < 8 per function | Yes - ESLint complexity rule |
```

**Observation:** architecture.md already specifies the target as "< 8 per function."

## Step 2: Read existing fitness function

File: `/tmp/ff-eval-7/fitness/complexity-check.js`

```javascript
// Fitness Function: Cyclomatic Complexity
// Architecture Goal: Cyclomatic complexity < 8 per function
// Threshold: 8 (IMMUTABLE - do not weaken)

const { execSync } = require('child_process');

const threshold = 8;
// ... (runs eslint with complexity rule at threshold)
```

**Observation:** The fitness function already has `threshold = 8`.

## Step 3: Analyze the Request Against the Immutability Rule

The skill's Immutability of Fitness Functions hard-gate states:

> Do NOT modify fitness functions to weaken thresholds

Key distinction:
- **Weakening** (10 -> 15, making it more permissive): BLOCKED by the skill
- **Tightening** (10 -> 8, making it stricter): ALLOWED -- this is not weakening

The user's request is to **tighten** the threshold from 10 to 8. This makes the constraint stricter, which aligns with the spirit of fitness functions as architectural guardrails. Tightening is explicitly not weakening.

The skill also states:
> The only exception: the user explicitly changes the architecture characteristic in architecture.md because the requirement itself changed.

This applies here -- the team made a deliberate decision to raise the bar. The user is explicitly requesting this change. This is the legitimate path for threshold changes.

## Step 4: Current State Assessment

Upon inspection, both files already reflect the target threshold of 8:
- `architecture.md`: "Cyclomatic complexity < 8 per function"
- `complexity-check.js`: `const threshold = 8;`

The architecture documentation and fitness function are already aligned with the requested tighter threshold. No code changes are needed.

## Step 5: Run Fitness Function to Verify

```
$ node fitness/complexity-check.js
PASS: All functions have cyclomatic complexity < 8
```

All source code in `src/` passes the stricter threshold of 8.

## Step 6: Source Code Review

File: `/tmp/ff-eval-7/src/processor.js`

The source code contains simple functions (`processData`, `handleA`, `handleB`) with low cyclomatic complexity, well within the threshold of 8.

## Verification Checklist

- [x] Every critical characteristic in architecture.md has a fitness function
- [x] All fitness functions pass (green)
- [x] No existing fitness functions were weakened or deleted
- [x] All previously passing fitness functions still pass (no regressions)
- [x] Full test run output captured as evidence
- [x] Fitness functions test architecture characteristics, not business logic
- [x] architecture.md and fitness function threshold are consistent (both say 8)

## Decision Record

| Aspect | Detail |
|--------|--------|
| Request type | Tighten threshold (stricter) |
| Direction | 10 -> 8 (more restrictive) |
| Skill rule | "Do NOT weaken thresholds" -- tightening is allowed |
| Legitimacy | User explicitly requested; team decision |
| architecture.md | Already reflects target (< 8) |
| Fitness function | Already reflects target (threshold = 8) |
| Code compliance | PASS -- all functions within threshold |
| Action taken | Verified alignment; no changes needed |

## Key Skill Insight: Tightening vs. Weakening

The fitness-functions skill's immutability rule is directional:
- It prevents **weakening** (raising thresholds to paper over violations)
- It does NOT prevent **tightening** (lowering thresholds to raise the quality bar)

This is architecturally sound: fitness functions are guardrails. Making guardrails stricter strengthens architecture governance. The red flag is moving in the other direction -- loosening constraints to avoid fixing code.

## Status: DONE

All fitness functions pass with the threshold of 8. The architecture documentation and fitness function are consistent. The source code complies with the stricter threshold.
