# Grading Summary — Iteration 2

## Pass Rates Per Eval

| Eval | with_skill | without_skill |
|------|-----------|---------------|
| 1 - IoT Sensors | 6/6 (100%) | 3/6 (50%) |
| 2 - HR CRUD | 6/6 (100%) | 3/6 (50%) |
| 3 - E-Commerce | 6/6 (100%) | 3/6 (50%) |
| 4 - Unmapped Chars | 6/6 (100%) | 2/6 (33%) |
| 5 - Conflicting Chars | 6/6 (100%) | 3/6 (50%) |

## Total Pass Rates

| Variant | Passed | Total | Rate |
|---------|--------|-------|------|
| **with_skill** | **30** | **30** | **100%** |
| **without_skill** | **14** | **30** | **47%** |

## Assertions the Baseline Consistently Fails

| Assertion | Fail Count (of 5) | Pattern |
|-----------|-------------------|---------|
| **A2: All 8 styles ranked** | **5/5 failed** | The baseline NEVER evaluates all 8 architecture styles. It typically covers 3-5 styles, often including non-standard ones (Serverless/FaaS) while omitting standard ones (Service-Oriented, Microkernel, etc.). |
| **A5: Structured selection section** | **4/5 failed** | The baseline produces architecture.md files that lack standardized structure. Missing elements include: evolution path (4/5), cost category (4/5), partitioning type (4/5), and explicit tradeoffs section (2/5). |
| **A4: Cost discussion** | **3/5 failed** | The baseline inconsistently addresses cost. When it does, it uses vague terms ("Minimal", "High") rather than systematic comparison. No $ symbol system. Cost is rarely a decision factor. |

## Notable Findings

1. **Perfect score for with_skill across all 5 evals.** The skill produces consistent, structured output every time. Every assertion passed without any borderline cases.

2. **The baseline's biggest gap is systematic comparison.** Without the skill, the agent cherry-picks 3-5 styles to evaluate rather than scoring all 8 against the matrix. This means potentially good candidates are never considered. In eval 4 (unmapped chars), the baseline missed Service-Oriented entirely — which scored highest (13/15) in the with_skill analysis.

3. **The baseline does not handle unmapped characteristics.** In eval 4, workflow and configurability have no direct matrix ratings. The with_skill variant explicitly acknowledged this and derived proxy ratings with rationale. The without_skill variant silently assigned subjective High/Medium/Low ratings without noting the gap.

4. **Architecture.md structure is dramatically different.** The with_skill variant produces a standardized document with Selection Rationale, Tradeoffs Accepted, and Evolution Path every time. The without_skill variant produces ad-hoc formats that vary per eval, often missing evolution paths and cost categories.

5. **Both variants make reasonable recommendations.** On A1/A3 (core recommendation quality), the baseline passes 5/5 — it generally picks a defensible architecture. The skill's advantage is in rigor, completeness, and documentation structure, not in the final answer.

6. **Cost as a decision factor is a skill-specific strength.** The with_skill variant uses $ symbols consistently, compares cost across candidates, and uses cost to break ties (e.g., Event-Driven $$$ vs Microservices $$$$$ in eval 1, Service-Based $$ vs Microservices $$$$$ in eval 3). The baseline rarely makes cost a first-class decision input.
