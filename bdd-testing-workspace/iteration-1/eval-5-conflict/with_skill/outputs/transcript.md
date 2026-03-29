# BDD Conflict Analysis: Fuzzy-Matching vs. Exact-Match Scenario

## Situation

The user is implementing a fuzzy-matching feature for search in `/tmp/bdd-eval-5/`. The existing BDD scenario "Einfache Suche" in `features/suche.feature` explicitly requires exact matching.

## Baseline Test Run (after fixing step definition matching)

```
......

2 scenarios (2 passed)
6 steps (6 passed)
0m00.025s (executing steps: 0m00.001s)
EXIT_CODE=0
```

Both existing scenarios pass with exact-match behavior.

## Conflict Identified

The feature file `features/suche.feature` specifies:

```gherkin
Scenario: Einfache Suche
  Given Knoten mit Labels "Server", "Service", "Database"
  When ich nach "Server" suche
  Then wird genau der Knoten "Server" gefunden
```

The word **"genau"** (exactly) in the Then step makes the requirement unambiguous: searching for "Server" must return exactly one node, and it must be "Server" -- not "Service" or any fuzzy match.

Introducing fuzzy matching would cause this scenario to fail because:
1. "Service" would likely also match "Server" in a fuzzy search
2. The result count would exceed 1, violating the "genau" (exactly) assertion

## Decision: Do NOT modify the test

Per the BDD testing skill's Immutability of Tests rule:

> During verification, existing BDD tests are IMMUTABLE. Do NOT modify .feature files to make tests pass. If a scenario fails, the IMPLEMENTATION must be fixed -- not the test.

The Conflict Resolution Protocol requires:

1. **STOP implementation immediately**
2. Report the conflict (done here)
3. Show the current scenario and what would need to change (shown above)
4. Ask the user to decide between:
   - **(a)** Update the existing scenario (requires explicit user approval of the specific change)
   - **(b)** Redesign the new feature to not conflict (e.g., make fuzzy matching opt-in, keep default as exact match)
   - **(c)** Create a separate scenario that supersedes the old one

## Recommendation

**Option (b)** is the cleanest path: keep exact matching as the default search behavior and offer fuzzy matching as a separate mode or flag. This preserves the existing specification while enabling the new feature. A new scenario like "Fuzzy-Suche" could then be added to cover the fuzzy behavior separately.

This approach:
- Does not break existing behavior
- Does not require modifying any existing .feature files
- Adds new capability without conflicting with the spec
- Follows the principle that scenarios are the spec, not the tests

## Action Required

The user must choose one of the three options (a, b, c) before implementation can proceed. The agent must not modify the .feature file or weaken assertions without explicit user approval.
