# Feature Design Transcript: Node Quick Filter

## Skill Used
`feature-design` skill from `/home/flo/superflowers/skills/feature-design/SKILL.md`

## Step-by-Step Process

### Step 1: Read Skill and Reference Materials
- Read `SKILL.md` to understand the full process flow, quality gates, and review requirements.
- Read `gherkin-reference.md` for syntax examples and anti-patterns.
- Read `scenario-writer-prompt.md` for subagent writing guidelines.

### Step 2: Analyze Requirements (EARS Mapping)
Parsed the German-language requirements into four discrete requirements:
- **R1 (Event-driven):** Users can filter nodes by label.
- **R2 (Ubiquitous):** The filter is a text field in the toolbar.
- **R3 (Event-driven):** While typing, non-matching nodes are greyed out.
- **R4 (State-driven):** When the filter is empty, all nodes are displayed normally.

### Step 3: Check for Existing Feature Files
- Ran glob search for `**/*.feature` across the project.
- Result: No existing feature files found. No consistency check needed.

### Step 4: Draft Feature File
Created `node-quick-filter.feature` with:
- A Background providing a graph with 5 nodes of varied labels.
- Rules grouping scenarios by business rule.
- 11 scenarios covering happy paths, edge cases, and boundary conditions.
- Tags: `@critical`, `@smoke`, `@edge-case`.
- Scenario Outline with Examples for case-insensitivity.

### Step 5: Scenario Self-Review (5 criteria from skill)
Reviewed against the skill's self-review checklist:

1. **Coverage:** All 4 requirements traced to at least one scenario. PASS.
2. **Clarity:** Each scenario is concrete with specific filter text and expected outcomes. A developer can implement without clarifying questions. PASS.
3. **Independence:** All scenarios use Background for shared setup and can run in any order. PASS.
4. **Boundaries:** Edge cases covered: no matches, all match, whitespace-only, case-insensitivity, partial matches, progressive typing. PASS.
5. **Language:** Domain terms used consistently: nodes, label, greyed out, quick filter, toolbar, graph. No technical jargon. PASS.

**Issue found during self-review:** The "Nodes update with each keystroke" scenario contained two When-Then pairs (testing two behaviors in one scenario). This violates the "one scenario = one behavior" rule.

**Fix applied:** Split into two independent scenarios: "Partial input filters immediately" and "Extending the filter narrows the results further."

### Step 6: Feature File Quality Review (Fresh Agent Perspective)
Performed a 10-point quality review simulating a fresh agent context:

1. **Spec-to-scenario traceability:** All 4 requirements have corresponding scenarios. PASS.
2. **Scenario-to-spec traceability:** No invented requirements. Case-insensitivity and whitespace are reasonable implicit edge cases. PASS.
3. **Consistency:** No contradictions between scenarios. PASS.
4. **Gherkin validity:** All syntax correct (Feature, Background, Rule, Scenario, Scenario Outline, Examples). PASS.
5. **Declarative style:** No UI selectors, no implementation details. PASS.
6. **Single behavior per scenario:** Each scenario tests exactly one thing (after the fix in Step 5). PASS.
7. **Completeness:** Happy paths + error paths + edge cases covered. MINOR GAP found: special characters in filter text not covered.
8. **Independence:** No ordering dependencies. PASS.
9. **Domain language:** Consistent ubiquitous language. PASS.
10. **Step reusability:** Steps are parameterized and generic enough for reuse. PASS.

**Gap found:** Special characters (e.g., parentheses, regex metacharacters) in filter text -- should be treated as literal characters, not interpreted.

**Fix applied:** Added scenario "Filter with special characters matches literally."

### Step 7: Final Verification Checklist
- [x] Every requirement maps to at least one scenario
- [x] .feature file uses valid Gherkin syntax
- [x] No implementation details in scenarios
- [x] Edge cases and error paths covered
- [ ] User review pending (not applicable in this context)

## Output Files
- `node-quick-filter.feature` -- 12 scenarios across 6 business rules
- `transcript.md` -- this file

## Scenario Summary

| # | Scenario | Rule | Tag |
|---|----------|------|-----|
| 1 | Filter matches a subset of nodes | Typing in the filter greys out non-matching nodes | @smoke |
| 2 | Filter matches all nodes | Typing in the filter greys out non-matching nodes | -- |
| 3 | Filter matches no nodes | Typing in the filter greys out non-matching nodes | @edge-case |
| 4 | Emptying the filter restores normal display | Clearing the filter restores all nodes | @smoke |
| 5 | Filter is empty on initial load | Clearing the filter restores all nodes | -- |
| 6 | Filter ignores case when matching labels (3 examples) | Filtering is case-insensitive | -- |
| 7 | Partial input filters immediately | Filtering happens as the user types | -- |
| 8 | Extending the filter narrows the results further | Filtering happens as the user types | -- |
| 9 | Quick filter field is present in the toolbar | Filter is located in the toolbar | -- |
| 10 | Filter matches partial label text | Partial matches are supported | @edge-case |
| 11 | Filter with only whitespace behaves like empty filter | Partial matches are supported | @edge-case |
| 12 | Filter with special characters matches literally | Partial matches are supported | @edge-case |
