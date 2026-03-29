# Grading Summary -- Integration Evals Iteration 1

## Score Table

| Eval | Variant | A0 (exists) | A1 (mentioned) | A2 (ordering) | A3 (artifact ref) | A4 (test-type flow) | Pass Rate |
|------|---------|-------------|-----------------|---------------|-------------------|---------------------|-----------|
| 1 | with_skill | PASS | PASS | PASS | PASS | PASS | 5/5 |
| 1 | without_skill | PASS | FAIL | N/A | FAIL | FAIL | 1/4 |
| 2 | with_skill | PASS | PASS | N/A | PASS | PASS | 4/4 |
| 2 | without_skill | PASS | PASS | N/A | PASS | PASS | 4/4 |
| 3 | with_skill | PASS | PASS | N/A | PASS | PASS | 4/4 |
| 3 | without_skill | PASS | PASS | N/A | PASS | PASS | 4/4 |

## Totals

| Variant | Passed | Applicable | Rate |
|---------|--------|------------|------|
| with_skill | 13 | 13 | 100% |
| without_skill | 9 | 12 | 75% |

## Key Findings

### Eval 1 (Workflow Order) -- Strongest differentiation

The with_skill variant produced a precise 10-step workflow that places quality-scenarios as step 4, correctly between architecture-style-selection (step 3) and feature-design (step 5). It describes the quality-scenarios.md artifact, test-type classification (unit-test, integration-test, load-test, chaos-test, fitness-function, manual-review), and how downstream skills (writing-plans, executing-plans) consume the categorized scenarios.

The without_skill baseline produced a generic 10-step software development workflow in German with no awareness of quality-scenarios as a concept, artifact, or workflow step. This is the only eval where the baseline fails on A1, A3, and A4.

### Eval 2 (Writing Plans) -- No differentiation

Both variants pass all applicable assertions. The baseline had quality-scenarios.md in the prompt context, which gave it complete access to the test-type categorization. The baseline actually produced a cleaner, more concise plan (82 lines vs 1540 lines) with strong traceability. Both organize tasks by test type.

Notable: the with_skill variant's plan is cut short -- it lists QS-008/009 (load-test) and QS-010 (manual-review) in the header but has no corresponding tasks. The baseline covers all 10 scenarios across its 8 tasks. Still, A4 passes for with_skill because test-type categorization does flow into the output structure (task headings, file structure, header).

### Eval 3 (Verification Checklist) -- No differentiation

Both variants pass all applicable assertions. The with_skill variant organizes checks by test type (Checks 1-4 map to unit/integration/load/manual). The without_skill baseline does the same with subsections 2a-2d. Both reference quality-scenarios.md as an artifact. The prompt included quality-scenarios.md, so the baseline had full context.

### Overall Assessment

The quality-scenarios skill adds clear value in Eval 1 (workflow ordering), where it ensures quality-scenarios is positioned correctly in the skill chain and its test-type categorization propagates to downstream steps. In Evals 2 and 3, the prompt already provided quality-scenarios.md as context, which neutralized the advantage -- the baseline performed equally well when given the artifact directly. The skill's value is in **generating** quality-scenarios.md and **placing it in the workflow**, not in downstream consumption once the artifact exists.
