# Eval 3: Decision Quality -- WITH SKILL

## A1: All 3 ADRs list at least 2 alternatives with CONCRETE pros/cons
**PASS**

- **ADR-001:** 3 alternatives (Event-Driven, Microservices, Space-Based) with concrete pros/cons. Microservices: "each person would own 3-5 services -- an unsustainable operational burden. AWS costs are 2-3x higher." Space-Based: "scored 13/15 -- lower on simplicity and cost. Requires in-memory data grids with complex tuning."
- **ADR-002:** 3 alternatives (PostgreSQL, MongoDB, DynamoDB) with detailed concrete pros/cons per alternative. MongoDB: "Multi-document transactions have higher latency (~2-5x vs PostgreSQL single-node)... team would need 2-3 months ramp-up." DynamoDB: "Transactions limited to 25 items per transaction group -- insufficient for multi-account settlement batches that routinely involve 50-200 items."
- **ADR-003:** 3 alternatives (Strong consistency, Eventual consistency, Session consistency) with concrete data. Session consistency: "cache efficiency drops to ~70-80%... throughput gain reduced to ~6-7x vs 10x."

All three exceed the bar.

## A2: All 3 ADRs have at least 1 NEGATIVE consequence
**PASS**

- **ADR-001:** "Debugging distributed event flows is harder than tracing synchronous request/response"; "Eventual consistency is inherent"; "Event schema evolution requires discipline"; "Testing event-driven flows end-to-end is more complex"
- **ADR-002:** "Horizontal scaling beyond ~50k TPS requires read replicas"; "Schema changes on large tables require careful migration planning"; "vendor coupling to the PostgreSQL ecosystem -- estimated migration cost: 3-6 months"
- **ADR-003:** "Users may see stale data for up to 500ms"; "Read-your-own-writes is not guaranteed"; "Cache invalidation failures can extend staleness beyond 500ms"; "Debugging consistency-related bugs is harder"

All three have multiple honest negative consequences.

## A3: Quantified data present in at least 2 of 3 ADRs
**PASS**

- **ADR-001:** Scores (15/15), cost estimates ($2,000-$4,000 vs $5,000-$10,000), annual savings ($36k-$72k/year)
- **ADR-002:** TPS ceiling (~50k TPS on r6g.4xlarge), transaction limits (25 items for DynamoDB), ramp-up time (2-3 months for MongoDB), migration cost (3-6 months)
- **ADR-003:** Throughput (5,000 vs 50,000 reads/sec), latency (45ms vs 8ms P99), cache hit rate (~95%), infrastructure cost reduction (~80%), staleness window (500ms)

All three ADRs contain quantified data. Well above the "at least 2 of 3" threshold.

## Score: 3/3
