---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| BDD scenarios pass | BDD run command: all scenarios green | "Unit tests pass" / "Most scenarios pass" |
| Fitness functions pass | Fitness function run: all checks green | "Code looks clean" / "Architecture is fine" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**BDD Scenarios (when .feature files exist — use superflowers:bdd-testing):**
```
✅ [Run BDD command] [See: 12 scenarios, 12 passed] "All BDD scenarios pass"
❌ "Unit tests pass so features work" / "Most scenarios pass"
```

**Fitness Functions (when architecture.md exists — use superflowers:fitness-functions):**
```
✅ [Run fitness functions] [See: 5/5 checks passed] "Architecture compliance verified"
❌ "Code follows the architecture" / "Looks structurally sound"
```

**Quality Scenarios (when quality-scenarios.md exists):**
```
✅ [Check each scenario by test type] [See: unit tests pass, integration tests pass, load test meets threshold] "All quality scenarios verified"
❌ "Tests pass" (which tests? which scenarios?) / "Quality looks good"
```
Quality scenarios define different test types. Verify each type ran:
- unit-test scenarios: covered by unit test suite
- integration-test scenarios: covered by integration test suite
- load-test scenarios: load test results meet response measures
- chaos-test scenarios: resilience tests passed
- fitness-function scenarios: already covered by fitness-functions check above
- manual-review scenarios: explicitly acknowledged with evidence or deferred with justification

**ADR Compliance (when doc/adr/ exists):**
```
✅ [Read active ADRs] [Check implementation against each] "Implementation consistent with all active ADRs"
❌ "We follow the architecture" / "ADRs are outdated anyway"
```
If implementation contradicts an active ADR, either fix the implementation or supersede the ADR — never silently violate it.

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- Claiming features are implemented (when .feature files exist, ALL scenarios must pass)
- Claiming architecture compliance (when architecture.md exists, ALL fitness functions must pass)
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
