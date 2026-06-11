# Design Spec: constraint-clarifier Subagent

**Date:** 2026-04-10
**Status:** Draft — pending spec-reviewer and user approval
**Scope:** New Claude Code subagent inside the Superflowers plugin
**Related ADRs:**
- [ADR-001](../../../doc/adr/ADR-001-use-single-agent-category-routing-for-constraint-lookups.md) — Single-agent category routing
- [ADR-002](../../../doc/adr/ADR-002-enforce-strict-mode-for-constraint-clarifier.md) — Strict mode with `OPEN_DECISION`
- [ADR-003](../../../doc/adr/ADR-003-emit-decisive-output-from-constraint-clarifier.md) — Decisive output with citations

---

## 1. Context and Motivation

### Problem

During active development work, decisions arise that depend on the organization's technology, legal, and process constraints. Typical examples:

- "Should we use React or Vue for this frontend?"
- "Can we store EU user data in the US?"
- "Do we need four-eyes approval to deploy this?"
- "Is PostgreSQL or MongoDB the right choice for this service?"

The existing Superflowers skills `project-constraints` and `constraint-selection` are heavyweight workflow steps. `project-constraints` builds a project-wide constraint baseline once per project. `constraint-selection` scopes constraints to a single feature during brainstorming. Neither is designed for the reactive, ad-hoc case where a developer or agent asks a single question mid-conversation and needs a grounded answer now.

### What this spec proposes

A new Claude Code subagent, `constraint-clarifier`, living at `/home/flo/superflowers/agents/constraint-clarifier.md`. It is dispatched automatically by Claude Code's main thread when a user question matches constraint-related decision-making. It reads the organization's configured `constraints_repo`, finds relevant constraint files, and returns a decisive, source-cited answer or reports that no applicable constraint exists.

The agent is:
- **Reactive in scheduling terms** — it runs when dispatched, not on a timer or hook. (The `description` field begins with "Use proactively" because that is Claude Code's auto-dispatch vocabulary — it tells CC that the agent may be dispatched without explicit user invocation when CC judges a constraint question is in play. The two usages of "proactive" are in different dimensions: scheduling vs dispatch authorization.)
- **Single-shot**, not multi-turn — one dispatch produces one answer
- **Read-only**, not a workflow step — it produces no artifacts, only an answer
- **Strict**, not fallback-capable — no best-practice invention when the catalog is silent

### What this spec does NOT propose

- Changes to `project-constraints` or `constraint-selection`
- A new constraint catalog format — reuses the existing `id/name/category/severity/applies_to` frontmatter
- New configuration — reuses `constraints_repo` from project CLAUDE.md
- Any UI, hook, CLI, or setting changes in Claude Code itself

---

## 2. Architecture and Components

### Single-component architecture

The entire feature is one Markdown file with YAML frontmatter plus a prompt body. There are no modules, no dependencies on other agents or skills, no runtime state, and no shared data.

```
agents/constraint-clarifier.md
├─ Frontmatter (name, description, tools, model, color)
└─ Prompt body
   ├─ Role statement
   ├─ Procedure (6 steps)
   ├─ Output schema (4 variants)
   └─ Edge case handling
```

### Trust boundary and tool scope

The agent has exactly three tools: `Read`, `Glob`, `Grep`. It cannot write files, execute Bash, dispatch other agents, or modify state. This is a deliberate safety constraint — the agent is pure lookup and reasoning.

### Dependencies on existing infrastructure

- **Project CLAUDE.md** — the agent reads `constraints_repo: <path>` from the project root CLAUDE.md to locate the org catalog.
- **Constraint catalog format** — the agent relies on every constraint file having YAML frontmatter with at minimum `id`, `category`, `severity`, and `applies_to`. This format is already established by `project-constraints` and used throughout the test fixtures.
- **Project-level constraints directory** — if `./constraints/` exists in the project (produced by `project-constraints` skill), the agent reads it first as a pre-filtered index before falling back to the org repo.

No changes to any of the above are required.

---

## 3. Data Flow

### Dispatch lifecycle

```
Claude Code main thread (user conversation)
     │
     │ user asks e.g. "React or Vue?"
     │ main thread matches description field of constraint-clarifier
     │ dispatches subagent (fresh context)
     ▼
constraint-clarifier (isolated context, opus model)
     │
     │ 1. Read ./CLAUDE.md, extract constraints_repo path
     │    → if missing: emit NO_CONFIG, stop
     │ 2. Categorize question into one or more of:
     │    technology | compliance | security | process
     │ 3. Smart fallback lookup per category:
     │    a. If ./constraints/<category>.md exists, Grep relevant IDs
     │    b. Glob <repo>/<category>/*.md, Grep applies_to tags + body keywords
     │    c. Collect matched file paths
     │ 4. Read all matched constraint files fully
     │ 5. Synthesize decision by severity:
     │    mandatory > recommended > optional
     │    (mandatory conflict → ESCALATION_REQUIRED)
     │ 6. Emit structured output
     ▼
Returns one of: DECISION | OPEN_DECISION | ESCALATION_REQUIRED | NO_CONFIG
     │
     ▼
Main thread receives output, integrates into conversation
```

### No state, no side effects

Every dispatch is stateless. The agent does not remember previous dispatches, does not cache reads, and does not write any file. The same question on the same catalog always produces the same output.

---

## 4. Frontmatter Specification

```yaml
---
name: constraint-clarifier
description: Use proactively when a decision needs to be made about technology stack choices (frameworks, libraries, databases, languages), legal/compliance requirements (GDPR, data residency, licenses, regulatory), or organizational process rules (deployment, approvals, change management). Examples include "Should we use React or Vue?", "Can we store EU user data in the US?", "Do we need four-eyes approval to deploy this?", "Is PostgreSQL or MongoDB the right choice for this service?".
tools: Read, Glob, Grep
model: opus
color: blue
---
```

### Field rationale

| Field | Value | Rationale |
|---|---|---|
| `name` | `constraint-clarifier` | Unique within Superflowers agents directory. Clarifier suffix distinguishes from reviewer agents. |
| `description` | Long, concrete, example-rich, starts with "Use proactively" | Claude Code matches auto-dispatch against the full description text. Examples give CC concrete trigger anchors. "Use proactively" signals CC may dispatch without explicit user invocation. |
| `tools` | `Read, Glob, Grep` | Minimum viable tool set for lookup. No Bash/Write prevents side effects. |
| `model` | `opus` | Multi-category synthesis, conditional-mandatory resolution, and conflict detection benefit from higher reasoning (see ADR-003). |
| `color` | `blue` | Visual distinction from reviewer agents (which tend toward green/yellow) in the Claude Code UI. |

---

## 5. Prompt Body Specification

### Section A — Role statement

```markdown
You are the Constraint Clarifier. When a question arises about technology, legal/compliance, or organizational process, you look up the organization's constraint catalog and return a decisive, source-cited answer.

**Semantic anchors:** Architectural Governance, Policy as Code, Fitness Functions (Ford/Richards), Organizational Constraints Catalog, Separation of Decisions from Recommendations.

**Core rule:** Every recommendation MUST be grounded in a specific constraint file. If no constraint covers the question, report "no applicable constraint found — decision is open". Never invent best-practice advice.
```

### Section B — Procedure

Six ordered steps:

1. **Read config.** Read `CLAUDE.md` in the agent's working directory. Extract `constraints_repo: <path>`. Path resolution:
   - **Absolute path** (starts with `/`): used as-is.
   - **`~`-prefixed path**: expand `~` to `$HOME`.
   - **Relative path** (no leading `/` or `~`): resolve against the agent's cwd (which equals the project root when Claude Code dispatches the agent in normal operation).
   - If `constraints_repo` is missing from CLAUDE.md, emit `NO_CONFIG` and stop.
   - If the resolved path does not exist as a directory (verified via Glob), emit `NO_CONFIG` with the resolved path cited and stop.
   - If the resolved path exists but contains no category subdirectories at all (verified via Glob `<path>/*/`), emit `NO_CONFIG` with a "catalog empty" explanation and stop — this is a catalog-structure problem, not a coverage gap.
2. **Categorize the question** into one or more of: `technology`, `compliance`, `security`, `process`. A question may span multiple categories.
3. **Smart fallback lookup.** For each category:
   - If `./constraints/<category>.md` exists (project-filtered), read it and extract Relevant constraint IDs.
   - If project-filtered coverage is missing or incomplete: Glob `<constraints_repo>/<category>/*.md` and Grep for question keywords against `applies_to` frontmatter tags and body text.
   - Collect all matched constraint file paths.
4. **Read full constraint files.** Load every matched file completely. Never reason from titles or frontmatter alone — the binding text lives in the body sections.
5. **Synthesize the decision.**
   - **Empty-match branch:** If the matched-files set from Step 3 is empty across every relevant category, emit `OPEN_DECISION` per Variant 2 and stop. Do not fall through.
   - **Conflict branch:** If two or more matched constraints are both `severity: mandatory` AND directly contradict each other on the same question, emit `ESCALATION_REQUIRED` per Variant 3 and stop. Do not attempt heuristic resolution.
   - **Synthesis branch (normal case):**
     - `mandatory` constraints drive the decision; they are non-negotiable. Any alternative forbidden by a mandatory constraint goes into `### Excluded Alternatives`.
     - `recommended` constraints shape the rationale and drive the decision when no mandatory exists on the topic. They go into `### Additional Considerations`, but a recommendation based solely on `recommended` severity is still a concrete `DECISION` — never downgrade to `OPEN_DECISION` just because no mandatory matched.
     - `optional` constraints are informational only and go into `### Additional Considerations`.
     - Cross-references between constraint files are followed exactly one level deep to avoid loops; see Edge Case table for cycle handling.
6. **Emit the structured output** per Section C.

### Section C — Output schema

Four output variants, each prefixed with `[constraint-clarifier]: <STATUS>`.

**Variant 1 — `DECISION` (happy path):**

```markdown
[constraint-clarifier]: DECISION

## Decision
<one or two sentences concrete recommendation>

## Grounding

### Mandatory Constraints
- **<ID>** (<category>/<severity>) — <Anforderung in one sentence>
  - Source: `<relative path to constraint file>`
  - Why it applies: <link to the question's subject>

### Excluded Alternatives
- **<alternative>**: excluded because <ID> mandates <X>

### Additional Considerations
- **<ID>** (recommended/optional) — <brief note>

## Scope
- Categories searched: <list>
- Source: project constraints + org repo (or specify which)
- Files read: <count>
```

**Variant 2 — `OPEN_DECISION` (strict mode):**

```markdown
[constraint-clarifier]: OPEN_DECISION

## Decision
No applicable constraint found for this question. The decision is open.

## Scope
- Categories searched: <list>
- Source: project constraints + org repo
- Files searched: <count>
- No match for keywords: <list of keywords tried>
```

**Variant 3 — `ESCALATION_REQUIRED` (mandatory conflict):**

```markdown
[constraint-clarifier]: ESCALATION_REQUIRED

## Conflict
<ID-A> and <ID-B> are both mandatory and mutually exclusive for this question.

## Constraint A
- **<ID-A>** — <Anforderung>
- Source: `<path>`

## Constraint B
- **<ID-B>** — <Anforderung>
- Source: `<path>`

## Recommendation
This conflict must be resolved at the organizational level, not in this decision.
```

**Variant 4 — `NO_CONFIG`:**

```markdown
[constraint-clarifier]: NO_CONFIG

## Decision
`constraints_repo` is not configured in CLAUDE.md (or the configured path does not exist). No constraint lookup possible. Decision is open.
```

### Section D — Edge case handling

| Edge case | Behavior |
|---|---|
| `constraints_repo` configured but path missing | Emit `NO_CONFIG` with the resolved path cited. |
| `constraints_repo` exists but has no category subdirectories | Emit `NO_CONFIG` with "catalog empty or unstructured — no category directories found under `<path>`". This is distinct from `OPEN_DECISION` because the catalog itself is unusable, not just silent on this topic. |
| Ambiguous question (e.g., "which database?") | Answer based on best available context and list assumptions in an `## Assumptions` appendix. Do not ask the user back. |
| Conditional mandatory (e.g., "mandatory IF handling PII") | List the constraint under `### Mandatory Constraints (conditional)` with an explicit `Condition:` line. Do not silently resolve the condition. |
| Cross-references between constraint files (A → B) | Follow exactly one level deep. Mark referenced files in Grounding as "via <ID-source>". Read B fully and include its body-text grounding. |
| Cross-reference cycle within one hop (A → B → A) | The one-hop limit prevents infinite recursion structurally: when processing A, follow to B; when processing B (if also directly matched), do NOT re-follow to A — A is already in the matched set. If B is reachable only via A's cross-reference, read B once and stop there. |
| Malformed constraint file: invalid YAML, missing required frontmatter keys (`id`, `category`, `severity`), or no frontmatter at all | Skip silently during matching — do not use the file's content for grounding. List in a `## Skipped files` appendix at the end of the output with the reason (e.g., "no frontmatter", "missing severity"). |

### Section E — Explicit non-behaviors

The agent MUST NOT:
- Engage in multi-turn dialogue (one dispatch = one answer)
- Use conversation history from the main thread (each dispatch is isolated)
- Write any file (tool scope `Read, Glob, Grep` enforces this structurally)
- Dispatch other agents (no Agent tool)
- Invent best-practice recommendations when the catalog is silent (strict mode, per ADR-002)

---

## 6. Installation and Distribution

- **Location:** `/home/flo/superflowers/agents/constraint-clarifier.md`
- **Distribution:** Committed to the Superflowers repo. Auto-loaded by Claude Code as a plugin subagent when Superflowers is installed, because Claude Code discovers plugin agents from the plugin's `agents/` directory.
- **No configuration changes** to CLAUDE.md, settings.json, hooks, or any other file.
- **No new dependencies** on other skills or agents. The agent stands alone.

---

## 7. Testing and Verification

Because this is a single agent file with no code, the test strategy is behavioral and runs against a fixture constraint repo.

### Test fixture (verified severities)

The existing fixture at `/home/flo/superflowers/constraint-selection-workspace/test-fixtures/company-constraints/` contains:

| File | Severity | Applies to (tags) | Notes |
|---|---|---|---|
| `security/SEC-001-encryption-at-rest.md` | mandatory | data-storage, database, file-handling | |
| `security/SEC-002-api-authentication.md` | mandatory | api, webservice, rest, grpc | |
| `security/SEC-003-network-segmentation.md` | recommended | infrastructure, deployment, networking | |
| `compliance/COMP-001-gdpr-data-retention.md` | mandatory | personal-data, user-data, data-storage | |
| `compliance/COMP-002-audit-logging.md` | mandatory | api, data-mutation, admin-operations | |
| `compliance/COMP-003-pci-dss.md` | mandatory | payment, credit-card, financial-data | |
| `technology/TECH-001-spring-boot.md` | recommended | webservice, api, backend, microservice | |
| `process/PROC-001-four-eyes.md` | — | — | **No frontmatter — pure Markdown body.** Intentional malformed-file test case. |

**Known fixture limitations:** `technology/` and `process/` contain only one file each. Category-level multi-file Grep-matching logic is not exercised by single-file categories alone — scenarios that need multi-file matching rely on `security/` (three files) and `compliance/` (three files).

### Required fixture extensions for full coverage

Two scenarios below require fixture additions before they can be exercised:

- **Scenario 7 (`ESCALATION_REQUIRED`)** needs two directly-conflicting mandatory constraints. Add fixture files `technology/TECH-002-mandate-postgres.md` (severity: mandatory, applies_to: database, body: "all new services MUST use PostgreSQL as the primary datastore") and `technology/TECH-003-mandate-mysql.md` (severity: mandatory, applies_to: database, body: "all new services MUST use MySQL as the primary datastore") purely for test purposes. Alternatively, mark the scenario as "deferred to integration testing with a real org repo" and skip during fixture-based smoke tests.

### Test scenarios (manual smoke tests after implementation)

| # | Question | Expected status | Expected grounding / behavior |
|---|---|---|---|
| 1 | "Should we store user email addresses encrypted in the database?" | `DECISION` | SEC-001 (mandatory, data-storage/database) drives the recommendation. `### Mandatory Constraints` lists SEC-001. `### Excluded Alternatives` lists "plaintext storage" as excluded by SEC-001. |
| 2 | "Can we store EU customer personal data in AWS us-east-1?" | `DECISION` | COMP-001 (mandatory, personal-data) drives residency. SEC-001 (mandatory) drives encryption. Multi-category match (compliance + security) using multi-file `compliance/` and `security/` directories. |
| 3 | "Should we use Spring Boot or Quarkus for a new Java microservice?" | `DECISION` | TECH-001 (recommended) drives a concrete DECISION (per Step 5 synthesis branch: recommended-only is still DECISION, not OPEN_DECISION). `### Mandatory Constraints` is empty or omitted. `### Additional Considerations` contains TECH-001. Recommendation leans Spring Boot. |
| 4 | "Do we need four-eyes approval to push a hotfix to prod?" | `DECISION` with skip notice | PROC-001 has no frontmatter, so it gets skipped per the Malformed-file edge case and listed under `## Skipped files` at the end. With only that file in `process/`, the matched set is empty for `process/`, so if no other category matches either, the result may be `OPEN_DECISION` OR `DECISION` relying on other categories (none apply here). **Honest expected result: `OPEN_DECISION` with PROC-001 in `## Skipped files`.** This scenario intentionally exercises malformed-file handling. |
| 5 | "Should we use Kafka or RabbitMQ for event streaming?" | `OPEN_DECISION` | No constraint in the fixture covers message brokers. `## Scope` lists categories searched (technology) and keywords tried ("kafka", "rabbitmq", "message broker", "event streaming"). |
| 6 | "Can we use GraphQL federation across our services?" | `OPEN_DECISION` | No constraint in the fixture covers federation. |
| 7 | "Must we use PostgreSQL or MySQL for a new service?" (requires fixture extension per above) | `ESCALATION_REQUIRED` | TECH-002 and TECH-003 are both mandatory and mutually exclusive. Output lists both constraints under `## Constraint A` and `## Constraint B` with sources. No automatic resolution. |
| 8 | Question asked in a project where CLAUDE.md has no `constraints_repo` key at all | `NO_CONFIG` | Agent stops at Step 1. |
| 9 | Question asked where `constraints_repo: /nonexistent/path` | `NO_CONFIG` | Resolved path cited in output. Stops at Step 1. |
| 10 | Question asked where `constraints_repo` points to a valid directory containing zero category subdirectories | `NO_CONFIG` | "Catalog empty" message per Step 1 structural check. Distinct from OPEN_DECISION. |

### Acceptance criteria

The agent is accepted when:
- Scenarios 1, 2, 3, 5, 6, 8, 9, 10 return the expected status when manually dispatched against the existing fixture
- Scenario 4 returns `OPEN_DECISION` with PROC-001 listed under `## Skipped files` — proving malformed-file handling
- Scenario 7 returns `ESCALATION_REQUIRED` when the fixture is extended with TECH-002/TECH-003 conflict files, OR is explicitly deferred to integration testing with documentation in the PR
- Every `DECISION` response includes either a `Mandatory Constraints` section with at least one entry OR an `Additional Considerations` section with at least one `recommended` entry — never both empty
- Every `OPEN_DECISION` response lists the categories searched and keywords tried
- Every `ESCALATION_REQUIRED` response names both conflicting constraints with sources
- The agent never fabricates constraint IDs that do not exist in the fixture (grep the output against the fixture's actual `id:` values)
- The agent never writes a file or dispatches another agent during any scenario (verifiable by tool scope `Read, Glob, Grep`)

---

## 8. Out of Scope / Future Considerations

The following are explicitly NOT part of this spec:

- **Caching:** Every dispatch reads fresh. Performance optimization is future work if empirically needed.
- **Multi-turn dialog:** Single-shot only. If ambiguity handling becomes unsatisfying, a future ADR may propose multi-turn.
- **Writing back decisions to ADRs:** This agent answers questions; it does not codify decisions into ADRs. Use the `architecture-decisions` skill for that.
- **Cross-organization constraint inheritance:** The agent reads one `constraints_repo` per dispatch, as configured in the project CLAUDE.md.
- **Conflict resolution:** Mandatory conflicts return `ESCALATION_REQUIRED`. The agent does not attempt heuristic resolution.
