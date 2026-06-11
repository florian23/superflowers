# ADR-001: Use Single-Agent Category Routing for Constraint Lookups

## Status
Accepted

## Context

The Superflowers plugin is adding a new Claude Code subagent, `constraint-clarifier`, that answers ad-hoc questions about technology, legal/compliance, and organizational process constraints by looking up the organization's constraint catalog (`constraints_repo`).

Three architectural approaches were considered during brainstorming (2026-04-10):

- **Approach A — Monolithic, no routing:** A single agent loads all constraint files on every request and synthesizes an answer from the full catalog.
- **Approach B — Single agent with in-prompt category routing:** One agent categorizes the incoming question into one or more of `technology`, `compliance`, `security`, `process`, then searches only the relevant category directories and matches against the `applies_to` frontmatter tags that already exist on each constraint file.
- **Approach C — Multi-agent pipeline:** Three specialized agents (`tech-constraint-agent`, `legal-constraint-agent`, `process-constraint-agent`) each tuned for their domain, plus an orchestrator agent that fans out for multi-category questions.

Claude Code dispatches subagents by matching the incoming user question against the `description` field of each agent's frontmatter. Three agents with overlapping trigger descriptions create dispatch ambiguity — CC may pick the wrong one, or dispatch multiple and confuse the main thread with competing answers. The existing constraint catalog format in this repo already carries `applies_to` frontmatter tags (e.g., `data-storage`, `database`, `api`), which makes category-based filtering inside a single agent straightforward.

## Decision

We will use Approach B — a single `constraint-clarifier` agent that performs category routing inside its prompt. The agent categorizes each incoming question, searches only the relevant category directories in the constraints repo, matches `applies_to` tags plus body keywords, and synthesizes one answer.

## Consequences

**Easier:**
- One `description` field means one unambiguous auto-dispatch trigger — no competing agents for overlapping questions.
- Combined-category questions ("PostgreSQL in the EU under GDPR" = technology + compliance) work in a single dispatch without coordination between agents.
- Reuses the existing `applies_to` frontmatter tagging — no new metadata convention.
- Only one agent file to maintain, test, and version.

**Harder:**
- All routing and synthesis logic lives inside one prompt. Adding deeply specialized per-category reasoning (e.g., legal-specific nuances) requires growing this single prompt rather than editing an isolated agent.
- Cannot parallelize category lookups across distinct agents — all category searches happen sequentially in one context.
- If prompt complexity becomes unmanageable in the future, splitting into Approach C later is a breaking change for callers that bind to the single `constraint-clarifier` identity.

**Tradeoff accepted:** We lose per-category specialization in exchange for unambiguous auto-dispatch and a single maintenance point. Revisit this ADR only if prompt length or reasoning quality degrades to the point where per-category agents become worth the dispatch-ambiguity cost.
