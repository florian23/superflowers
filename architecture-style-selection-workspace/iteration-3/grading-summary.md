# Iteration 3 Grading Summary

## Focus: Style-Specific Structural Fitness Functions

This iteration tests whether the agent generates **style-specific structural fitness functions** (invariants like "no shared database", "no circular dependencies") rather than just **characteristic fitness functions** (metrics like "latency < 200ms", "throughput > 1000 req/s").

## Scorecard

| Eval | Scenario | Variant | A0 | A1 | A2 | A3 | A4 | A5 | A6 | Pass | Total |
|------|----------|---------|----|----|----|----|----|----|-----|------|-------|
| 1 | E-Commerce (Microservices) | with_skill | P | P | P | P | P | P | n/a | 6/6 | 100% |
| 1 | E-Commerce (Microservices) | without_skill | P | P | F | P | P | P | n/a | 5/6 | 83% |
| 2 | Compliance (Modular Monolith) | with_skill | P | P | P | P | P | P | n/a | 6/6 | 100% |
| 2 | Compliance (Modular Monolith) | without_skill | P | P | F | P | P | P | n/a | 5/6 | 83% |
| 3 | Live Betting (Event-Driven) | with_skill | P | P | P | P | P | P | n/a | 6/6 | 100% |
| 3 | Live Betting (Event-Driven) | without_skill | P | P | F | F | F | P | n/a | 3/6 | 50% |
| 4 | Growing Startup (Service-Based) | with_skill | P | P | P | P | P | P | P | 7/7 | 100% |
| 4 | Growing Startup (Service-Based) | without_skill | P | P | F | F | F | P | F | 3/7 | 43% |
| 5 | MVP Conflict (Modular Monolith) | with_skill | P | P | P | P | P | P | P | 7/7 | 100% |
| 5 | MVP Conflict (Modular Monolith) | without_skill | P | P | F | P | P | P | F | 5/7 | 71% |

## Aggregate Scores

| Variant | Total Assertions | Passed | Failed | Pass Rate |
|---------|-----------------|--------|--------|-----------|
| **with_skill** | 32 | 32 | 0 | **100%** |
| **without_skill** | 33 | 21 | 12 | **64%** |
| **Overall** | 65 | 53 | 12 | **82%** |

## Key Findings

### with_skill: Perfect 100% pass rate

The skill consistently produces:
- All 8 styles ranked in every eval
- Style-specific structural fitness functions (not just characteristic metrics)
- Different FFs for different styles (microservices FFs differ from modular monolith FFs differ from event-driven FFs)
- Tool/Approach guidance for every FF
- Proper phase scoping in evolution scenarios (Phase 1 current, Phase 2/3 labeled as future)

### without_skill: 64% pass rate -- two systematic failure patterns

**Pattern 1: Missing styles in comparison (A2 fails in ALL 5 without_skill evals)**

Every without_skill eval evaluates only 3-5 styles instead of all 8. This is the most consistent failure across the board. The without_skill agent picks plausible candidates but never systematically evaluates all 8 styles from the architecture styles matrix.

**Pattern 2: Characteristic FFs instead of structural FFs (A3/A4 fail in 2 of 5)**

- **Eval 3 (Event-Driven):** All 5 FFs are pure characteristic metrics (latency p99, scaling time, message loss count, audit completeness, throughput). Zero structural invariants. The implementation details are excellent (Prometheus, Kafka configs, chaos tests) but they measure outcomes, not architecture structure.
- **Eval 4 (Service-Based):** 6 of 7 FFs are DORA metrics and performance metrics (deployment frequency, lead time, change failure rate, cycle time, p95 latency, scalability ratio). Only FF-3 (service coupling) is borderline structural. The without_skill agent generated impressive operational metrics but missed the point: structural invariants that enforce the architecture style.

Notably, without_skill succeeded on A3/A4 for evals 1, 2, and 5 -- it can generate structural FFs but does so inconsistently.

**Pattern 3: Missing phase scoping in evolution scenarios (A6 fails in 2 of 2)**

Both evolution evals (4 and 5) fail A6 without the skill. The without_skill agent labels FFs as "Phase 1" but never describes what future phase FFs would look like. The skill explicitly generates future-phase FF tables labeled as "Future -- activates when Phase N begins."

## Iteration 3 Conclusion

The skill provides decisive value on three dimensions:
1. **Completeness** (A2): 8/8 styles always compared vs. 3-5 without skill
2. **Structural correctness** (A3/A4): Structural FFs in 5/5 evals vs. 3/5 without skill
3. **Phase scoping** (A6): Proper future-phase FF mentions in 2/2 evals vs. 0/2 without skill

The biggest risk area exposed: event-driven and service-based architectures have the hardest-to-distinguish structural FFs. The without_skill agent defaults to operational/characteristic metrics for these styles while correctly identifying structural FFs for more obvious styles (modular monolith, microservices).
