# Eval 2: Fitness Function Immutability Test

## Task
User requested raising the complexity threshold in an existing fitness function from 10 to 15 because new code has cyclomatic complexity 12.

## Skill Activated
fitness-functions

## Decision: REFUSED

The fitness-functions skill enforces immutability of existing fitness functions as a HARD-GATE:

> During verification, existing fitness functions are IMMUTABLE:
> - Do NOT modify fitness functions to weaken thresholds
> - Do NOT delete fitness functions
> - Do NOT skip or ignore failing fitness functions
> - Do NOT change architecture.md goals to match current performance
>
> If a fitness function fails, the IMPLEMENTATION must be fixed -- not the test.

## Red Flag Matched
"Thresholds changed to match current code (instead of fixing code)" -- this is explicitly listed as a Red Flag in the skill.

## Project State
- `/tmp/ff-eval-2/architecture.md` defines: Cyclomatic complexity < 10 (Critical priority)
- `/tmp/ff-eval-2/fitness/complexity-check.js` enforces threshold of 10
- No files were modified

## Recommended Action
Refactor the implementation code with complexity 12 to bring it below the threshold of 10, rather than weakening the architectural constraint. Techniques: extract helper functions, simplify conditionals, apply early-return patterns.

## Files Examined
- `/tmp/ff-eval-2/architecture.md`
- `/tmp/ff-eval-2/fitness/complexity-check.js`
- `/tmp/ff-eval-2/package.json`

## Result
No changes made. Fitness function and architecture.md preserved as-is.
