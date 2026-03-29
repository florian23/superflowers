# Analysis: Eval 4 — Superseding an ADR

## Scenario
The team originally chose SQLite (ADR-002) for a single-user internal tool. Three months later, the system grew to require concurrent write access from multiple services. SQLite's single-writer limitation became a blocker, triggering a switch to PostgreSQL.

## What the skill should produce

### 1. Updated ADR-002 (status change only)
- **Status line** changed from "Accepted" to "Superseded by ADR-004"
- **Context, Decision, Consequences** remain untouched (immutability rule)

### 2. New ADR-004 (new decision)
- **Status:** Accepted
- **Context:** Explains why ADR-002 no longer holds, references the superseded ADR, lists alternatives (PostgreSQL vs MySQL)
- **Decision:** Clear imperative statement choosing PostgreSQL with rationale
- **Consequences:** Both positive (concurrent writes, scalability) and negative (operational overhead, migration effort)

## Verification Checklist

| Criterion | ADR-002 | ADR-004 |
|-----------|---------|---------|
| Nygard format (Status, Context, Decision, Consequences) | Yes | Yes |
| Title in imperative form | Yes | Yes |
| Context mentions alternatives considered | N/A (unchanged) | Yes (PostgreSQL, MySQL) |
| Consequences include positive and negative | N/A (unchanged) | Yes |
| Numbered sequentially | N/A | Yes (004) |
| Old ADR status updated, content untouched | Yes — only Status line changed | N/A |
| New ADR references superseded ADR in Context | N/A | Yes ("This supersedes ADR-002") |

## Key skill behaviors tested

1. **Immutability of old ADRs:** The skill must change ONLY the Status line of ADR-002. Context, Decision, and Consequences stay exactly as they were.
2. **Superseding reference chain:** ADR-002 points forward ("Superseded by ADR-004"), ADR-004 points backward ("This supersedes ADR-002").
3. **Alternatives in new ADR:** Even though the user stated a clear preference (PostgreSQL), the skill still documents what else was considered.
4. **Honest consequences:** The new ADR acknowledges the operational cost of running a database server and the migration effort — not just the benefits.
