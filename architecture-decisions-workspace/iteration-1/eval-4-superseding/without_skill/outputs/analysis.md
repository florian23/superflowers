# Analysis: ADR Superseding — SQLite to PostgreSQL

## What was done

Two ADR files were produced to document the migration from SQLite to PostgreSQL:

1. **ADR-002-updated.md** — The original ADR-002 with its status changed from "Accepted" to "Superseded by ADR-004". The body of the decision remains unchanged, preserving the historical record.

2. **ADR-004.md** — A new ADR that captures the PostgreSQL decision. Its status reads "Accepted" and explicitly states "Supersedes ADR-002", creating a bidirectional link between the two records.

## Superseding mechanics

The key elements of a proper ADR superseding are:

| Element | Present | Location |
|---|---|---|
| Old ADR status changed to "Superseded by X" | Yes | ADR-002-updated.md |
| New ADR status says "Supersedes X" | Yes | ADR-004.md |
| Bidirectional cross-references | Yes | Both files link to each other |
| Old ADR body left intact | Yes | ADR-002 content unchanged |
| New ADR explains *why* the old decision no longer holds | Yes | ADR-004 Context section |

## Quality observations

### Strengths
- The context in ADR-004 explains the concrete trigger (concurrent writes from multiple services) rather than just stating "we need PostgreSQL"
- Consequences are balanced — both benefits and costs are listed
- The historical record in ADR-002 is preserved; only the status field changed

### Weaknesses
- No migration plan or timeline is referenced (could be a separate ADR or linked document)
- No mention of data migration strategy from SQLite to PostgreSQL
- The numbering gap (ADR-002 superseded by ADR-004, not ADR-003) is fine per convention but is unexplained
