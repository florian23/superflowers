# Grading Summary — Bounded Context Skill, Iteration 1

## Scores

| Eval | Domain | With Skill | Without Skill | Delta |
|------|--------|-----------|---------------|-------|
| 1 | E-Commerce | 6/6 | 2.5/6 | +3.5 |
| 2 | Single Context (Time Tracking) | 6/6 (+A6) | 1.5/6 (+A6) | +4.5 |
| 3 | B2B SaaS Logistics | 6/6 | 3/6 | +3.0 |
| 4 | Legacy Decomposition (Insurance) | 7/7 (+A7) | 2.5/7 (+A7) | +4.5 |
| **Total** | | **25/25** | **9.5/25** | **+15.5** |

## Assertion Pass Rates

| Assertion | With Skill | Without Skill |
|-----------|-----------|---------------|
| A0: Output files exist | 4/4 | 4/4 |
| A1: Subdomain classification with rationale | 4/4 | 0.5/4 |
| A2: Domain-based context responsibilities | 4/4 | 4/4 |
| A3: Ubiquitous language tables per context | 4/4 | 2/4 |
| A4: Explicit DDD relationship patterns | 4/4 | 1/4 |
| A5: Structured context-map.md format | 4/4 | 0/4 |
| A6: Single context for simple system (Eval 2) | 1/1 | 0/1 |
| A7: ACL for legacy integration (Eval 4) | 1/1 | 0.5/1 |

## Key Findings

### Where the skill adds the most value

1. **Subdomain classification (A1):** The biggest gap. Without the skill, outputs consistently omit Core/Supporting/Generic classification or get it wrong (e.g., calling a time tracking tool "Core Domain"). The skill forces explicit classification with rationale, producing consistently correct results.

2. **Structured format (A5):** Without the skill, context-map.md outputs vary wildly in structure. No without-skill output included a proper subdomains table. The skill enforces a consistent, reviewable artifact format.

3. **Relationship pattern richness (A4):** Without the skill, outputs default to 2-3 pattern types (mostly Conformist and Customer-Supplier). With the skill, outputs use 4-5 pattern types appropriately (Partnership, Published Language, OHS, ACL, Customer-Supplier). ACL for external integrations is consistently missing without the skill.

4. **Over-engineering prevention (A6):** The skill's process flow ("Multiple domains?" decision point) correctly prevented over-engineering for the simple time tracking tool. Without the skill, 3 contexts were created for a 1-developer CRUD app.

### Where both perform similarly

- **A0 (files exist):** Both always produce output files.
- **A2 (domain-based contexts):** Both consistently identify domain-capability-based contexts rather than entity-based or technical ones. This is an area where the baseline LLM already performs well.

### Notable without-skill strengths

- Eval 2 without-skill: The analysis.md correctly identified that a single context was the right choice, even though the context-map.md contradicted it with 3 contexts. This suggests the LLM has the judgment but lacks the structured process to act on it.
- Eval 4 without-skill: Discovered 2 additional bounded contexts (Partner & Vertrieb, Inkasso & Buchhaltung) not in the prompt, showing good domain exploration.

### Notable without-skill weaknesses

- Eval 2 without-skill: Contradictory outputs (analysis says 1 context, map shows 3).
- Eval 3 without-skill: Incorrect use of Shared Kernel for Tenant Management, and confused ACL direction.
- Eval 4 without-skill: ACL mentioned as a principle but never structurally mapped in the relationships table.

## Conclusion

The skill produces a **perfect score (25/25)** vs **9.5/25 without**. The skill's primary contributions are: (1) forcing subdomain classification, (2) enforcing structured output format, (3) ensuring rich DDD pattern usage in relationships, and (4) preventing over-engineering through its process flow. The baseline LLM identifies reasonable contexts but consistently lacks DDD rigor in classification, language definition, and relationship mapping.
